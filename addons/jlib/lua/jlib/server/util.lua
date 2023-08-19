--[[
	ResetPlayer
	Purpose: Respawn the player in the same place, with all the same stuff
]]
function jlib.ResetPlayer(ply)
	ply.NoProtect = true

	ply:SetParent()
	ply:UnSpectate()

	local weapons = {}
	local ammoCount = {}

	local activeWep = ply:GetActiveWeapon()
	local activeClass

	if IsValid(activeWep) then
		activeClass = activeWep:GetClass()
	end

	for k,v in pairs(ply:GetWeapons()) do
		table.insert(weapons, { class = v:GetClass(), rarity = v:GetNWInt("rarity", 1), clip = v:Clip1()})
		ammoCount[v:GetClass()] = ply:GetAmmoCount(v:GetPrimaryAmmoType())
	end

	local pos   = ply:GetPos()
	local hp    = ply:Health()
	local armor = ply:Armor()
	local ang   = ply:EyeAngles()

	ply:Spawn()
	ply:SetPos(pos)
	ply:SetHealth(hp)
	ply:SetArmor(armor)
	ply:StripWeapons()
	ply:SetEyeAngles(ang)

	for k, v in ipairs(weapons) do
		local wep = ply:Give(v.class)
		wep:SetClip1(v.clip)
		if v.rarity > 1 then
			wep:SetNWInt("rarity", v.rarity)
		end
	end

	ply:SelectWeapon(activeClass)

	for k, v in pairs(ammoCount) do
		ply:GiveAmmo(v, k, true)
	end

	ply.NoProtect = nil
end

--[[
	HealOverTime
	Purpose: Heal the player a certain amount over a certain period of time
	Notes: Two heals with the same idPrefix will extend the current heal with that prefix
	Two heals with different prefixes will run concurrently
]]
function jlib.HealOverTime(ply, idPrefix, healAmt, totalTime)
	local id = idPrefix .. ply:SteamID64()
	local deaths = ply:Deaths()
	local time = 1 / (healAmt / totalTime)

	local timerFunc = function()
		if !IsValid(ply) or ply:Deaths() > deaths then
			timer.Remove(id)
			return
		end

		if ply:IsInCombat(8) then return end
		
		ply:SetHealth(math.min(ply:Health() + 1, ply:GetMaxHealth()))
	end

	if timer.Exists(id) then
		local reps = timer.RepsLeft(id)
		reps = reps + healAmt
		timer.Adjust(id, time, reps, timerFunc)
		return
	end

	timer.Create(id, time, healAmt, timerFunc)
end

--[[
	Create/DeleteRagdoll
]]
function jlib.CreateRagdoll(ply)
	local ragdoll = ents.Create("prop_ragdoll")
	ragdoll.IsjDoll = true
	ragdoll.Ply = ply
	ragdoll:SetModel(ply:GetModel())
	ragdoll:SetPos(ply:GetPos())
	ragdoll:SetAngles(ply:GetAngles())
	ragdoll:Spawn()
	timer.Simple(0, function()
		if IsValid(ragdoll) then
			ragdoll:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
		end
	end)


	local velocity = ply:GetVelocity()
	for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
		local bone = ragdoll:GetPhysicsObjectNum(i)

		if bone and bone.IsValid and bone:IsValid() then
			local bonepos, boneang = ply:GetBonePosition(ragdoll:TranslatePhysBoneToBone(i))
			bone:SetPos(bonepos)
			bone:SetAngles(boneang)
			bone:SetVelocity(velocity)
		end
	end

	ply.jDoll = ragdoll
	ply:SetNWEntity("jDoll", ragdoll)
	ragdoll:SetNWEntity("RagdollOwner", ply)

	timer.Simple(0.25, function()
		for k, client in pairs(player.GetAll()) do
			netstream.Start(client, "deathRagdollRender", ply, ply.Accessories)
		end
	end)

	return ragdoll
end

function jlib.DeleteRagdoll(ply)
	if IsValid(ply.jDoll) then
		ply.jDoll:Remove()

		ply.jDoll = nil
		ply:SetNWEntity("jDoll", NULL)
	end
end

function jlib.ToggleRagdoll(ply)
	if IsValid(ply.jDoll) then
		jlib.DeleteRagdoll(ply)
	else
		jlib.CreateRagdoll(ply)
	end
end

function jlib.TimedRagdoll(ply, time)
	local ragdoll = jlib.CreateRagdoll(ply)
	ragdoll.IsKnockoutDoll = true
	timer.Simple(time, function()
		if IsValid(ply) then
			jlib.DeleteRagdoll(ply)
		end
	end)
	return ragdoll
end

--[[
	SpectateEntity/StopSpectate
]]
function jlib.SpectateEntity(ply, ent)
	ply:SetParent(ent)
	ply:Spectate(OBS_MODE_CHASE)
	ply:SpectateEntity(ent)
end

function jlib.StopSpectate(ply)
	ply:SetParent()
	ply:UnSpectate()
end

function jlib.TimedSpectate(ply, ent, time)
	jlib.SpectateEntity(ply, ent)
	timer.Simple(time, function()
		if IsValid(ply) then
			jlib.StopSpectate(ply)
		end
	end)
end

--[[
	ServerTime
	Purpose: Tell the client what time it is for the server so they can
	calculate how much time has passed from something that happened
	on the server
]]
util.AddNetworkString("jlibServerTime")

function jlib.SendServerTime(ply)
	net.Start("jlibServerTime")
		net.WriteInt(os.time(), 32)
	net.Send(ply)
end
hook.Add("PlayerInitialSpawn", "jlibServerTime", jlib.SendServerTime)

--[[
	Discord Functions
	Uses discordintegration addon's API to send regular and embedded messages to the configured discord server
]]
function DiscordMsg(msg, channel)
	if !Discord then ErrorNoHalt("Discord API not installed.\n") return end
	if !Discord.Config.Relay.Channels[channel] then channel = 'IncursionChat' end

	Discord.Backend.API:Send(Discord.OOP:New('Message'):SetChannel(channel or 'Relay'):SetMessage(msg):ToAPI())
end

function DiscordEmbed(msg, title, color, channel)
	if !Discord then ErrorNoHalt("Discord API not installed.\n") return end
	if !Discord.Config.Relay.Channels[channel] then channel = 'IncursionChat' end
	if !Discord.Backend.API then ErrorNoHalt("Discord API is falting.") return end

	Discord.Backend.API:Send(
		Discord.OOP:New('Message'):SetChannel(channel or 'IncursionChat'):SetEmbed({
			color = tonumber(jlib.ColorToHex(color or Color(255, 255, 255))),
			title = title,
			description = msg
		}):ToAPI()
	)
end

--[[
	AddDirectory
	resource.AddSingleFile all files in a given directory
]]
function jlib.AddDirectory(dir)
	dir = dir:Replace("\\", "/")
	dir = dir:Trim("/")
	local files, dirs = file.Find(dir .. "/*", "GAME")
	for _, fileName in ipairs(files) do
		local fullPath = dir .. "/" .. fileName
		jlib.Print("Adding file ", fullPath)
		resource.AddSingleFile(fullPath)
	end

	for _, subDir in ipairs(dirs) do
		jlib.AddDirectory(dir .. "/" .. subDir)
	end
end

--[[
	kickbots
	Console command to kick all bots from the server
]]
concommand.Add("kickbots", function()
	for _, bot in ipairs(player.GetBots()) do
		bot:Kick("All bots kicked")
	end
end)

--[[
	Visual/sound effects
]]
function jlib.Zap(ply)
	local effect = EffectData()
	effect:SetOrigin(ply:GetPos())
	effect:SetEntity(ply)
	util.Effect("TeslaHitboxes", effect)
	util.Effect("ManhackSparks", effect)

	ply:EmitSound("ambient/levels/labs/electric_explosion" .. math.random(1, 5) .. ".wav")
	ply:EmitSound("weapons/physcannon/superphys_small_zap" .. math.random(1, 4) .. ".wav")

	timer.Simple(1 / 3, function()
		if IsValid(ply) then
			util.Effect("TeslaHitboxes", effect)
			ply:EmitSound("ambient/energy/zap" .. math.random(1, 3) .. ".wav")
			ply:EmitSound("weapons/physcannon/superphys_small_zap" .. math.random(1, 4) .. ".wav")
		end
	end)
end

--[[
	Possession
]]
function jlib.PossessKeepMaster(master, slave)
	master:SetSlave(slave)
	slave:SetMaster(master)

	for ammoType, ammoCount in pairs(master:GetAmmo()) do
		slave:SetAmmo(ammoCount, ammoType)
	end

	jlib.Zap(slave)
	master.PosBeforePossess = master:GetPos()
end

function jlib.Possess(master, slave)
	jlib.PossessKeepMaster(master, slave)

	master:SetPos(slave:GetPos())
	master:SetParent(slave)
	master:SetNoDraw(true)
	master:SetNotSolid(true)
end

function jlib.UnPossess(target)
	local plys = {target, target:GetMaster(), target:GetSlave()}

	for i, ply in ipairs(plys) do
		if IsValid(ply) then
			ply:SetMaster(NULL)
			ply:SetSlave(NULL)
			ply:SetParent()
			ply:SetNoDraw(false)
			ply:SetMoveType(MOVETYPE_WALK)
			ply:SetNotSolid(false)

			if ply.PosBeforePossess then
				ply:SetPos(ply.PosBeforePossess)
				ply.PosBeforePossess = nil
			end
		end
	end
end

hook.Add("PlayerCanHearPlayersVoice", "jlibPossession", function(listener, talker)
	if IsValid(talker:GetMaster()) then return false end
end)

hook.Add("PlayerDeath", "jlibPossession", jlib.UnPossess)
hook.Add("PlayerSilentDeath", "jlibPossession", jlib.UnPossess)
hook.Add("PlayerDisconnected", "jlibPossession", jlib.UnPossess)
hook.Add("PlayerKnockedOut", "jlibPossession", function(ply)
	if IsValid(ply:GetMaster()) or IsValid(ply:GetSlave()) then
		jlib.UnPossess(ply)
	end
end)

function jlib.IsDev()
	return cookie.GetNumber("jlibDev", 0) == 1
end

function jlib.SetDev(bool)
	jlib.Print((bool and "Enabling" or "Disabling") .. " developer mode")
	cookie.Set("jlibDev", bool and 1 or 0)
end

--[[
	SpawnEnt
	Purpose: Spawn an entity for a player
]]
function jlib.SpawnEnt(ply, class, skipSafety)
	local stored = scripted_ents.GetStored(class)
	if !stored then return NULL end
	local tbl = stored.t

	local start = ply:EyePos()

	local trace = {}
	trace.start = start
	trace.endpos = start + (ply:GetAimVector() * 150)
	trace.filter = ply

	local tr = util.TraceLine(trace)

	local spawnFunc = scripted_ents.GetMember(class, "SpawnFunction") or scripted_ents.GetMember("base_entity", "SpawnFunction")
	local ent = spawnFunc(tbl, ply, tr, class)

	if skipSafety != true then
		jlib.EntSafety(ent)
	end

	return ent
end

--[[
	CreateVehicle
	Purpose: Create a vehicle entity using the parameters from the vehicles list
]]
function jlib.CreateVehicle(class)
	local veh = list.Get("Vehicles")[class]

	if !veh then return NULL end

	local ent = ents.Create(veh.Class)

	if !IsValid(ent) then return NULL end

	ent:SetModel(veh.Model)

	if veh.KeyValues then
		for k, v in pairs(veh.KeyValues) do
			ent:SetKeyValue(k, v)
		end
	end

	if veh.Members then
		table.Merge(ent, veh.Members)
	end

	if isfunction(ent.SetVehicleClass) then
		ent:SetVehicleClass(class)
	end

	ent.VehicleTable = veh
	ent.VehicleName = class
	ent.ClassOverride = veh.Class

	return ent
end

--[[
	EntSafety
	Purpose: Temporarily disables collisions between the entity and vehicles/players for len seconds
]]
function jlib.EntSafety(ent, len)
	local oldColor = ent:GetColor()
	local oldMaterial = ent:GetMaterial()
	local oldCollisionGroup = ent:GetCollisionGroup()

	ent:EmitSound("physics/metal/metal_barrel_impact_hard" .. math.random(1, 7) .. ".wav")
	ent:SetMaterial("models/props_combine/portalball001_sheet")
	ent:SetColor(Color(255, 255, 0, 255))
	ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	ent:SetDisallowPickup(true)

	timer.Simple(len or 4, function()
		if IsValid(ent) then
			ent:EmitSound("physics/metal/metal_barrel_impact_hard" .. math.random(1, 7) .. ".wav")
			ent:SetMaterial(oldMaterial or "")
			ent:SetColor(oldColor or color_white)
			ent:SetCollisionGroup(oldCollisionGroup or COLLISION_GROUP_NONE)
			ent:SetAllowPickup(true)
		end
	end)
end

--[[
	Obfuscation
	NOTE: The parser used was made with regular Lua in mind, not GLua.
	Any GLua specific operators or keywords (other than continue) will need to be replaced.
	https://wiki.facepunch.com/gmod/Specific_Operators
]]
include("parser.lua")

function jlib.GetRandomCyrillicString(len)
	local nums = {}
	for i = 1, (len or 1) do
		nums[i] = math.random(0x400, 0x52F)
	end

	return utf8.char(unpack(nums))
end

-- A lot of this is commented out because a parser upgrade
-- is needed before the desired effects can be done properly
function jlib.Obfuscate(str)
	-- Parse
	local ast = Parser.CreateLuaParser(str)
	local globalScope, rootScope = Parser.AddVariableInfo(ast)

	-- Minify
	Parser.StripAst(ast)

	-- Replace all variable names with cyrillics
	local namesUsed = {}
	-- local localizedNames = {}

	local function RenameVar(var, newName)
		if !newName then
			repeat newName = jlib.GetRandomCyrillicString(math.random(3, 10)) until !namesUsed[newName]
		end
		var:Rename(newName)
		namesUsed[newName] = true
		return newName
	end

	-- -- Renaming globals
	-- for i, var in ipairs(globalScope) do
	-- 	local oldName = var.Name
	-- 	local newName = RenameVar(var, localizedNames[oldName])

	-- 	localizedNames[oldName] = newName
	-- end

	-- Renaming locals
	for i, var in ipairs(Parser.GetLocalVars(rootScope)) do
		RenameVar(var)--, localizedNames[var.Name])
	end

	local obfuscatedCode = Parser.AstToString(ast)

	-- Localize the globals we renamed
	-- for oldName, newName in pairs(localizedNames) do
	-- 	obfuscatedCode = string.format("local %s=%s", newName, oldName) .. " " .. obfuscatedCode
	-- end

	return obfuscatedCode
end

function jlib.ToByteCode(str)
	return str:gsub(".", function(b) return "\\" .. b:byte() end)
end

function jlib.FromByteCode(str)
	return str:gsub("\\%d+", function(bc) return string.char(tonumber(string.sub(bc, 2))) end)
end

function jlib.GetRunString(str)
	return "CompileString('" .. str .. "', '', false)()"
end

function jlib.RunByteCode(str)
	RunString(jlib.GetRunString(str))
end

--[[
	TransferFaction
]]
function jlib.TransferFaction(ply, faction_id, class_id)
	local char = ply:getChar()

	if (!IsValid(ply) or !char) then
		return false
	end

	-- Find the specified faction.
	local oldFaction = nut.faction.indices[char:getFaction()]
    local faction = nut.faction.indices[faction_id]
    if (!faction) then
        for k, v in pairs(nut.faction.indices) do
            if (nut.util.stringMatches(v.name, name)) then
                faction = v
                break
            end
        end
    end

    if (!faction) then
        error("Invalid FACTION_ID param used")
        return false
    end

    -- Change to the new faction.
    char.vars.faction = faction.uniqueID
    char:setFaction(faction.index)
    ply:notify("Your faction has been updated")
    if (faction.onTransfered) then
        faction:onTransfered(ply, oldFaction)
    end

    hook.Run("CharacterFactionTransfered", char, oldFaction, faction)

    --changes class if one is supplied
    if (class_id) then
        local num = isnumber(tonumber(class_id)) and tonumber(class_id) or -1

        if (nut.class.list[num]) then
            local v = nut.class.list[num]

            if (char:joinClass(num)) then
                local class = nut.class.list[num]
                char:setData("class", class.uniqueID)

                return
            else
                return
            end
        else
            for k, v in ipairs(nut.class.list) do
                if (nut.util.stringMatches(v.uniqueID, class) or nut.util.stringMatches(v.name, class)) then
                    if (char:joinClass(k)) then
                        local class = nut.class.list[k]
                        character:setData("class", class.uniqueID)

                        return
                    else
                        return
                    end
                end
            end
        end
    end
end

--[[
	Steam API functions
]]

jlib.Steam = jlib.Steam or {}
jlib.Steam.Key = "601BD514840668E6830591D582E574E6"
jlib.Steam.API_URL = "https://api.steampowered.com/"

jlib.Steam.SummaryCache = jlib.Steam.SummaryCache or {}
function jlib.Steam.GetPlayerSummaries(...)
	local args = {...}
	local callback = isfunction(args[#args]) and args[#args] or nil

	local results = {}
	local totalSIDs = 0
	for i, steamID in ipairs(args) do
		if isstring(steamID) then
			results[#results + 1] = jlib.Steam.SummaryCache[steamID]
			totalSIDs = totalSIDs + 1
		end
	end

	if #results == totalSIDs then
		callback(results)
		return
	end

	http.Fetch(jlib.Steam.API_URL .. "ISteamUser/GetPlayerSummaries/v0002/?key=" .. jlib.Steam.Key .. "&steamids=" .. table.concat(args, ",", 1, #args - 1), function(response)
		local data = util.JSONToTable(response).response

		for i, summary in ipairs(data.players) do
			jlib.Steam.SummaryCache[summary.steamid] = summary
		end

		callback(data.players)
	end)
end

function jlib.Steam.RequestPlayerInfo(steamID64, callback)
	jlib.Steam.GetPlayerSummaries(steamID64, function(data)
		callback(#data > 0 and data[1].personaname or "Unknown")
	end)
end

-- util for notifying all players
function jlib.falloutNotifyAll(msg, soundPath)
	for k, v in pairs(player.GetAll()) do
		v:falloutNotify(msg, soundPath or false)
	end
end

-- Scuffed hack to make MsgC work properly on Linux
if jit.os == "Linux" and jlib.IsDev() then
	function MsgC(...)
		local args = {...}

		for i, arg in ipairs(args) do
			if IsColor(arg) then
				args[i] = string.format("\x1b[38;2;%u;%u;%um", arg.r, arg.g, arg.b)
			end
		end

		args[#args + 1] = "\x1b[0m"

		Msg(unpack(args))
	end
end
