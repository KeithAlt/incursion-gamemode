local PANEL = FindMetaTable("Panel")

function PANEL:ScaleToRes(origX, origY)
	origX, origY = origX or 1920, origY or 1080

	local scrW, scrH = ScrW(), ScrH()
	local xMod, yMod = math.Clamp(scrW / origX, 0, 1), math.Clamp(scrH / origY, 0, 1)
	local curW, curH = self:GetSize()

	self:SetSize(curW * xMod, curH * yMod)
end

local cursorShown = false
local cursorPos = {x = ScrW()/2, y = ScrH()/2}
hook.Add("PlayerButtonDown", "jlibShowCursor", function(ply, key)
	if !IsFirstTimePredicted() then return end
	if ply != LocalPlayer() then return end
	if key == KEY_F8 then
		cursorShown = !cursorShown
		gui.EnableScreenClicker(cursorShown)
		if cursorShown then
			input.SetCursorPos(cursorPos.x, cursorPos.y)
		else
			cursorPos.x, cursorPos.y = input.GetCursorPos()
		end
	end
end)

function jlib.Hallucinate(time, music, models)
	if timer.Exists("jlibHallucinate") then return end

	local ply = LocalPlayer()

	models = models or {
		"models/props_c17/statue_horse.mdl",
		"models/Gibs/HGIBS.mdl",
		"models/fo3_virgo2.mdl",
		"models/props_vehicles/van001a_physics.mdl",
		"models/props_junk/bicycle01a.mdl",
		"models/props_junk/watermelon01.mdl",
		"models/arachnit/fallout4/synths/synthgeneration1.mdl",
		"models/maxib123/throne.mdl",
		"models/props_fallout/carstack002.mdl"
	}

	ply.popUpEnts = ply.popUpEnts or {}

	local jlibHallucinateMusic

	timer.Create("jlibHallucinate", time, 1, function()
		hook.Remove("RenderScreenspaceEffects", "jlibHallucinate")
		hook.Remove("Think", "jlibHallucinate")

		if IsValid(jlibHallucinateMusic) then jlibHallucinateMusic:Stop() end

		for k,v in pairs(ply.popUpEnts) do
			v:Remove()
		end
		ply.popUpEnts = {}
	end)

	local deaths = ply:Deaths()

	hook.Add("Think", "jlibHallucinate", function()
		if ply:Deaths() > deaths then
			hook.Remove("RenderScreenspaceEffects", "jlibHallucinate")
			hook.Remove("Think", "jlibHallucinate")

			if IsValid(jlibHallucinateMusic) then jlibHallucinateMusic:Stop() end

			for k,v in pairs(ply.popUpEnts) do
				v:Remove()
			end
			ply.popUpEnts = {}

			timer.Remove("jlibHallucinate")

			return
		end

		if #ply.popUpEnts >= 50 then return end

		if math.Rand(0, 100) <= 99.9 then return end

		local spookyProp = ents.CreateClientProp(models[math.random(1, #models)])
		spookyProp:SetPos(ply:GetEyeTrace().HitPos)
		spookyProp:SetAngles(AngleRand())
		spookyProp:Spawn()

		table.insert(ply.popUpEnts, spookyProp)
	end)

	hook.Add("RenderScreenspaceEffects", "jlibHallucinate", function()
		local color = jlib.Rainbow(100)

		DrawColorModify({
			["$pp_colour_addr"] = (color.r/255)/10,
			["$pp_colour_addg"] = (color.g/255)/10,
			["$pp_colour_addb"] = (color.b/255)/10,
			["$pp_colour_brightness"] = 0,
			["$pp_colour_contrast"] = 1,
			["$pp_colour_colour"] = 3,
			["$pp_colour_mulr"] = (color.r/255)/10,
			["$pp_colour_mulg"] = (color.g/255)/10,
			["$pp_colour_mulb"] = (color.b/255)/10
		})
		DrawSobel(0.5)
		DrawMotionBlur(0.4, 0.8, 0.01)
	end)

	if music then
		sound.PlayURL(music, "noblock", function(soundchannel, errorID, errorname)
			soundchannel:SetVolume(1)
			soundchannel:EnableLooping(true)
			soundchannel:Play()

			jlibHallucinateMusic = soundchannel
		end)
	end
end

--[[
	ServerTime
	Purpose: Tell the client what time it is for the server so they can
	calculate how much time has passed from something that happened
	on the server
]]
function jlib.GetServerTime()
	return jlib.ServerTime
end

hook.Add("Think", "jlibServerTime", function()
	if jlib.ServerTime then
		jlib.ServerTime = jlib.ServerTime + RealFrameTime()
	end
end)

net.Receive("jlibServerTime", function()
	jlib.ServerTime = net.ReadInt(32)
end)

jlib.Dots = {
	"",
	".",
	"..",
	"..."
}

function jlib.DotDotDot(text, interval)
	interval = interval or 0.5

	if CurTime() >= (jlib.NextDot or CurTime()) then
		jlib.NextDot = CurTime() + 0.5
		jlib.dot = (jlib.dot or 1) + 1
		if jlib.dot > 4 then jlib.dot = 1 end
	end

	return text .. jlib.Dots[jlib.dot]
end

--[[
	Adding sound fading to IGModAudioChannel
]]
jlib.ChannelFades = jlib.ChannelFades or {}

local IGModAudioChannel = FindMetaTable("IGModAudioChannel")

function IGModAudioChannel:FadeTo(targetVol, time, callback)
	local curVol = self:GetVolume()
	jlib.ChannelFades[self] = {CurTime(), time, curVol, targetVol - curVol, callback}
end

function IGModAudioChannel:FadeIn(targetVol, time, callback)
	self:SetVolume(0)
	self:FadeTo(targetVol, time, callback)
end

function IGModAudioChannel:FadeOut(time, callback)
	self:FadeTo(0, time, callback)
end

function IGModAudioChannel:StopFade()
	jlib.ChannelFades[self] = nil
end

hook.Add("Think", "IGModAudioChannelFade", function()
	for chnl, fade in pairs(jlib.ChannelFades) do
		local startTime, duration, origVol, volChange, callback = unpack(fade)
		if IsValid(chnl) then
			local factor = math.Clamp(0, 1, (CurTime() - startTime) / duration)
			chnl:SetVolume(origVol + (volChange * factor))

			if factor >= 1 then
				jlib.ChannelFades[chnl] = nil

				if isfunction(callback) then
					callback(chnl)
				end
			end
		else
			jlib.ChannelFades[chnl] = nil
		end
	end
end)

--[[
	Possession
]]
hook.Add("CalcView", "PsykersPossession", function(ply, pos, angles, fov, znear, zfar)
	local slave = ply:GetSlave()
	if IsValid(slave) then
		return {
			origin = slave:EyePos() - (angles:Forward() * 105),
			angles = angles,
			fov = fov
		}
	end
end)

hook.Add("ShouldDrawLocalPlayer", "PsykersPossession", function(ply)
	if IsValid(ply:GetSlave()) then return true end
end)

hook.Add("ArmorShouldRemoveCSEnts", "PsykersPossession", function(ply)
	if ply == LocalPlayer():GetSlave() then return false end
end)

-- Detouring some methods to make sure crosshairs, etc align
local PLAYER = FindMetaTable("Player")

local detours = {
	"GetShootPos",
	"GetAimVector",
	"GetEyeTrace",
	"GetEyeTraceNoCursor"
}

for i, detour in ipairs(detours) do
	local defaultDetour = "Default" .. detour
	PLAYER[defaultDetour] = PLAYER[defaultDetour] or PLAYER[detour]

	PLAYER[detour] = function(self)
		local slave = self:GetSlave()
		if IsValid(slave) then
			return slave[defaultDetour](slave)
		end

		return self[defaultDetour](self)
	end
end

-- Detouring SetPlayer for AvatarImage panels
PANEL.DefaultSetPlayer = PANEL.DefaultSetPlayer or PANEL.SetPlayer

function PANEL:SetPlayer(ply, size)
	local slave = ply:GetSlave()
	if IsValid(slave) then
		return self:DefaultSetPlayer(slave, size)
	end

	return self:DefaultSetPlayer(ply, size)
end

-- Hook for possession
hook.Add("ShouldRenderRunescapeChat", "jlibPossession", function(ply, text, fx)
	if IsValid(ply) and IsValid(ply:GetSlave()) then return false end
end)

--[[
	Nutscript chatbox & Serverguard icons compatibility
]]
hook.Add("GetPlayerIcon", "NSChatBoxIcons", function(ply)
	return serverguard.ranks.stored[ply:GetUserGroup()].texture or "icon16/user.png"
end)

netstream.Hook("deathRagdollRender", function(client, accessories)
	local target = client:GetNWEntity("jDoll")
	
	if(!IsValid(target)) then return end
	
	-- Removes the Clientside Entities when the target ragdoll is removed
	target:CallOnRemove("deathRagdollRemove", function()
		if(target.Arms) then
			SafeRemoveEntity(target.Arms)
		end
		
		if(target.Head) then
			SafeRemoveEntity(target.Head)
		end
		
		if(target.Accessories) then
			for k, accessory in pairs(target.Accessories) do
				SafeRemoveEntity(accessory)
			end
		end
	end)

	local group = Armor.GetGroupFromMdl(client:GetModel())
	local forceArms = true
	local forceHead = true
	local race = client:GetRace()
	local sex = client:GetSex()
	local path = Armor.Consts.BodiesPath .. group .. "/"
	
	local armsPath = path .. "/arms/" .. sex .. "_arm.mdl"
	util.PrecacheModel(armsPath)

	if IsValid(target.Arms) then
		target.Arms:Remove()
	end

	local arms = (armsPath and ClientsideModel(armsPath, RENDERGROUP_OPAQUE)) or false
	if IsValid(arms) and (!client:GetForceNoArms() or forceArms) then
		arms:SetParent(target)
		arms:AddEffects(EF_BONEMERGE)
		arms:Spawn()
		arms:SetSkin(client:GetHeadSkin())
		arms.ply = target
		arms.IsArms = true
		arms.type = "Arms"
		arms.RenderOverride = Armor.RenderOverride

		Armor.EndCSEntMonitor(arms)

		target.Arms = arms
	end

	if !IsValid(target.Head) then
		Armor.MakeHeadRagdoll(client, target, forceHead)
	end
	
	for aType, accessory in pairs(accessories or client.Accessories or {}) do
		Armor.AddAccessoryRagdoll(client, target, accessory.id or accessory)
	end
end)