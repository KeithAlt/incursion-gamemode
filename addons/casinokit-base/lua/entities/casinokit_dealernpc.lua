AddCSLuaFile()

ENT.Base = "casinokit_npc"
ENT.Delay = CurTime()

DEFINE_BASECLASS("casinokit_npc")

-- Voices lines the NPC will say on game events
local voiceLine = {
	[0] = "npc/mrhandy/cg04_goodbye_0006b231_1.mp3",
	[1] = "npc/mrhandy/dialogueri_rcgoodbye_00002e5d_1.mp3",
	[2] = "npc/mrhandy/dialogueri_rcgoodbye_00002e60_1.mp3",
	[3] = "npc/mrhandy/dialogueri_rcgoodbye_00002e34_1.mp3",
	[4] = "npc/mrhandy/dialogueri_rcgoodbye_00002e5d_1.mp3",
	[5] = "npc/mrhandy/cg03_idlechatter_0009b15a_1.mp3",
	[6] = "npc/mrhandy/genericrobot_alertidle5.mp3",
	[7] = "npc/mrhandy/genericrobot_alertidle1.mp3",
	[8] = "npc/mrhandy/dialoguerivetcity_hello_00038340_1.mp3",
	[9] = "npc/mrhandy/ffeuniquea_ffeu10robottalk_00059995_1.mp3",
	[10] = "npc/mrhandy/freeformdc_dc11talkhomebot_000335af_1.mp3"
}

function ENT:SetDealer(dealerId)
	local obj = CasinoKit.getDealer(dealerId)
	assert(not not obj, "dealer '" .. tostring(dealerId) .. "' is nil")

	self:SetDealerObj(obj)
end

function ENT:SetDealerObj(obj)
	self.dealer = obj

	self:SetModel(obj.Model)
	self:SetSequence("idle")

	if obj.ModelBodygroups then
		for k,v in pairs(obj.ModelBodygroups) do
			local bg = self:FindBodygroupByName(k)
			if bg ~= -1 then
				self:SetBodygroup(bg, v)
			end
		end
	end
end

function ENT:Initialize()
	if SERVER then
		if not self.dealer then
			self:SetDealer("default")
		end
	end

	BaseClass.Initialize(self)

	self:SetSkin(1)
end

if CLIENT then
	function ENT:Draw()
		-- If localplayer is nearby do look op
		if LocalPlayer():EyePos():Distance(self:GetPos()) < 512 then
			local lookAtPos = nil

			-- yeezus christ this is a lot of NESTED SCOPES. TODO
			local tblEnt = self:GetParent()
			if IsValid(tblEnt) then
				local game = tblEnt.Game
				if game then
					local apos = game:getActivityPosition(tblEnt, tblEnt.TableLocalOrigin)
					if apos then
						lookAtPos = apos
					end
				end
			end

			if lookAtPos then
				self:LookAt(lookAtPos)
			else
				self:LookAroundIdly()
			end
		end

		BaseClass.Draw(self)
	end
end

if SERVER then
	function ENT:Use(ply)
		ply:ConCommand("casinokit_table_npc " .. self:GetParent():EntIndex())
	end

	function ENT:ProcessGameEvent(id, args)
		if self.Delay <= CurTime() then
			self:EmitSound(voiceLine[math.random(0,#voiceLine)])
			self.Delay = CurTime() + 20
		end

		/** -- NOTE: Disabled due to no support (by Keith)
		local reaction

		-- try to figure out reaction
		if self.dealer and self.dealer.GetReaction then
			reaction = self.dealer:GetReaction(id, args)
		end

		if not reaction then
			-- TODO handle common event ids
		end

		-- handle reaction
		if reaction and reaction.voice then
			local path = reaction.voice

			local url = path:match("^url:(.*)")
			if url then
				self:SpeakUrl(url)
			else
				local file = path:match("^file:(.*)")
				self:SpeakFile(file or path)
			end
		end
		**/
	end

	function ENT:SayVoicePhrase(id)
		local sounds = self.dealer.Voices and self.dealer.Voices[id]
		if sounds and #sounds > 0 then
			self:SpeakFile(table.Random(sounds))
		end
	end
end

if CLIENT then
	local L = CasinoKit.L

	local htmlTemplate = [[
	<html>
		<head>
			<link href='http://fonts.googleapis.com/css?family=Roboto' rel='stylesheet' type='text/css'>
			<style>
				body {
					margin: 0px;
					padding: 0px;

					font-family: "Roboto";

					background-color: white;
					text-align: center;
				}
			</style>
		</head>
		<body>
			%s
		</body>
	</html>
	]]
	concommand.Add("casinokit_table_npc", function(ply, cmd, args)
		local entIndex = args[1]
		if not tonumber(entIndex) then return end

		local tableEntity = Entity(entIndex)
		if not IsValid(tableEntity) then return end

		local fr = vgui.Create("DFrame")
		fr:SetTitle(L"dealer")
		fr:SetSize(380, 270)
		fr:Center()

		local langBox = fr:Add("DComboBox")
		langBox:SetPos(200, 4)
		langBox:SetSize(80, 17)

		local curLang, curLangObj = CasinoKit.getActiveLanguage(), CasinoKit.getActiveLanguageObject()
		langBox:SetValue(curLangObj.language_name_own or curLang, curLang)

		for _,lk in pairs(CasinoKit.getAvailableLanguages()) do
			local obj = CasinoKit.getLanguageObject(lk)
			langBox:AddChoice(obj.language_name_own or lk, lk)
		end
		langBox.OnSelect = function(panel, index, value, data)
			GetConVar("casinokit_language"):SetString(data)
		end

		local tabs = fr:Add("DPropertySheet")
		tabs:Dock(FILL)

		local exchangepanel = fr:Add("CasinoKitChipExchange")
		exchangepanel:SetEntity(tableEntity)
		tabs:AddSheet(L"chipdealer_exchangetab", exchangepanel, "icon16/coins.png")

		if tableEntity.Game and tableEntity.Game.htmlHelp then
			local helppanel = fr:Add("DPanel")
			helppanel:Dock(FILL)
			helppanel.Paint = function(pself)
				-- poor man's lazy loading
				local helphtml = helppanel:Add("DHTML")
				helphtml:Dock(FILL)
				helphtml:AddFunction("gmod", "OpenUrl", function(url)
					gui.OpenURL(url)
				end)
				helphtml:SetHTML(htmlTemplate:format(tableEntity.Game:getHelpHTML()))

				pself.Paint = nil
			end

			tabs:AddSheet(L"chipdealer_rules", helppanel, "icon16/information.png")
		end

		local settings = fr:Add("DForm")
		settings:SetName("Game")

		if tableEntity.Game then
			tableEntity.Game:addGameSettings {
				integer = function(_, name, key, value, min, max)
					local slider = settings:NumSlider(name, nil, min, max, 0)
					slider:SetValue(value or min)
					slider.OnValueChanged = function(slider, newval)
						timer.Create("CasinoKit_tablesetting_" .. key, 0.2, 1, function()
							net.Start("casinokit_tablecfg")
							net.WriteEntity(tableEntity)
							net.WriteString(key)
							net.WriteType(newval)
							net.SendToServer()
						end)
					end
				end
			}
		end

		if tableEntity.AddGameSettings then
			tableEntity:AddGameSettings {
				integer = function(_, name, key, value, min, max)
					local slider = settings:NumSlider(name, nil, min, max, 0)
					slider:SetValue(value or min)
					slider.OnValueChanged = function(slider, newval)
						timer.Create("CasinoKit_tablesetting_" .. key, 0.2, 1, function()
							tableEntity:ApplyGameSetting(key, newval)
						end)
					end
				end
			}
		end

		tabs:AddSheet(L"chipdealer_tablesettings", settings, "icon16/cog.png")

		fr:SetSkin("CasinoKit")
		fr:MakePopup()
	end)

	concommand.Add("casinokit_animtool", function(ply)
		local e = ply:GetEyeTrace().Entity
		local seqs = e:GetSequenceList()

		local fr = vgui.Create("DFrame")
		fr:SetPos(ScrW() - 400, ScrH()/2 - 300)
		fr:SetSize(300, 600)

		local list = fr:Add("DListView")
		list:Dock(FILL)
		list:AddColumn("sequence")

		for _,s in pairs(seqs) do
			list:AddLine(s)
		end

		list.OnRowSelected = function(_, _, line)
			e:ResetSequenceInfo()
			e:SetCycle( 0 )
			e:SetPlaybackRate( 1  );

			e:SetSequence(line:GetColumnText(1))
		end

		fr:MakePopup()
	end)
end
