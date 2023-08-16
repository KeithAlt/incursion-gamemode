local PLUGIN = PLUGIN


---------------
--[[ Fonts ]]--
---------------
surface.CreateFont( "FearRP_DermaMedium", {
	font		= "Roboto",
	size		= 28,
	weight		= 500,
	extended	= true
})

surface.CreateFont( "FearRP_DermaLarge", {
	font		= "Roboto",
	size		= 35,
	weight		= 650,
	outline     = true,
	extended	= true
})

--[[surface.CreateFont( "FearRP_Intimidate",{
	font = "Roboto",
	size = 38,
	weight = 400,
	underline = 0,
	additive = false,
	outline = false,
	blursize = 0
})--]]


-------------------------------------------
--[[ FearRP indicator on players heads ]]--
-------------------------------------------
local TEXT_OFFSET = Vector(0, 0, 15)
local toScreen = FindMetaTable("Vector").ToScreen
local colorAlpha = ColorAlpha
local drawText = nut.util.drawText

function PLUGIN:DrawEntityInfo(entity, alpha, position)
	if (!entity:GetNW2Bool("nut_fearrp_is_under_fear")) then return end

	position = position or toScreen(entity.LocalToWorld(entity, entity.OBBCenter(entity)) + TEXT_OFFSET)
	local x, y = position.x, position.y

	drawText(L"fearrp_under", x, y, colorAlpha(color_white, alpha), 1, 1, "FearRP_DermaMedium", alpha * 0.65)
	drawText(L"fearrp_fearRp", x, y + 30, colorAlpha(Color(230, 0, 0), alpha), 1, 1, "FearRP_DermaLarge", alpha * 0.65)
end


--------------------------------------------------------------
--[[ Check that we can threaten the player in front of us ]]--
--------------------------------------------------------------
--[[PLUGIN.threatenedPlayers = PLUGIN.threatenedPlayers or {}

netstream.Hook("nut_fearrp_threatener_add", function(victim)
	PLUGIN.threatenedPlayers[victim] = true
end)

netstream.Hook("nut_fearrp_threatener_remove", function(victim)
	PLUGIN.threatenedPlayers[victim] = nil
end)


local nextCheck = 0
local previousShowInvokeFearHUD = false
local showInvokeFearHUD = false

function PLUGIN:Tick()
	if (!LocalPlayer().GetEyeTraceNoCursor || CurTime() < nextCheck) then return end

	local trace = LocalPlayer():GetEyeTraceNoCursor()
	local ent = trace.Entity

	previousShowInvokeFearHUD = showInvokeFearHUD
	showInvokeFearHUD = self:CanThreatenPlayer(LocalPlayer(), ent)

	nextCheck = CurTime() + 0.1
end-|]]


-------------------------------------------------------------
--[[ HUD that shows when the localplayer is under FearRP ]]--
--[[ and that shows the "[key] Threaten" action text if  ]]--
--[[ the check above succeed                             ]]--
-------------------------------------------------------------
PLUGIN.fearSoundStation = PLUGIN.fearSoundStation

function PLUGIN:HUDPaint()
	if nut.gui.char and (g_ContextMenu:IsVisible() or nut.gui.char:IsVisible()) then return end

	if (LocalPlayer():GetNW2Bool("nut_fearrp_is_under_fear")) then
		if (!self.fearSoundStation) then
			self.fearSoundStation = CreateSound( LocalPlayer(), "fearrp/fear.wav" )
			self.fearSoundStation:Play()

			timer.Create( "fearrp_fear_sound_stop", 17, 1, function()
				if (self.fearSoundStation) then
					self.fearSoundStation:Stop()
				end
			end )
		end

		drawText(L"fearrp_youUnder", ScrW() / 2, 150, colorAlpha(color_white, alpha), 1, 1, "FearRP_DermaMedium", 255)
		drawText(L"fearrp_fearRpComply", ScrW() / 2, 150 + 30, colorAlpha(Color(230, 0, 0), alpha), 1, 1, "FearRP_DermaLarge", 255)
	elseif (self.fearSoundStation) then
		timer.Remove("fearrp_fear_sound_stop")
		self.fearSoundStation:FadeOut(1)
		self.fearSoundStation = nil
	end

	--[[if (previousShowInvokeFearHUD && showInvokeFearHUD) then
		local text = "["..string.upper(NUT_CVAR_FEAR_KEY:GetString()).."] "..L"fearrp_threaten"
		local x = ScrW() / 2
		local y = ScrH() - 100

		nut.util.drawText(text, x, y, Color(230, 0, 0), 1, 1, "FearRP_Intimidate", 1)
		draw.TextShadow( {
			text = text,
			font = "FearRP_Intimidate",
			pos = {[1] = x, [2] = y},
			xalign = 1,
			yalign = 1,
			color = Color(230, 0, 0)
		}, 2, 255 )
	end]]
end


------------------------
--[[ Hotkey binding ]]--
------------------------
if (jSettings && jSettings.AddBinder) then
	jSettings.AddBinder("Binds", "Inflict FearRP", {"+fearRP"})
	jBinds.SetDefault(KEY_F, {"+fearRP"})
end
