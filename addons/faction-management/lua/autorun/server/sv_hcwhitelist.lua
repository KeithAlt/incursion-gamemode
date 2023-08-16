AddCSLuaFile("hcwhitelist_config.lua")

util.AddNetworkString("hcSendMembers")
util.AddNetworkString("hcSetFaction")
util.AddNetworkString("hcViewLogs")
util.AddNetworkString("hcShowMOTD")
util.AddNetworkString("hcAction")
util.AddNetworkString("hcMOTD")
util.AddNetworkString("hcLog")
util.AddNetworkString("hcDeployableSpawn")
util.AddNetworkString("sendFactionDeployablesList")
util.AddNetworkString("getFactionStoragesByID")
util.AddNetworkString("sendFactionStoragesByID")

for k, file in ipairs(file.Find("materials/hcwhitelist/*.png", "GAME")) do
    resource.AddSingleFile("materials/hcwhitelist/" .. file)
end

hcWhitelist = hcWhitelist or {}
hcWhitelist.config = hcWhitelist.config or {}
hcWhitelist.motds = hcWhitelist.motds or {}
include("hcwhitelist_config.lua")

function hcWhitelist.setClass(charID, id, hcMem) --Set player's class by uniqueID or numeric ID
    local char = nut.char.loaded[charID]
    if !char then
        hcWhitelist.consoleLog("Failed to find char with ID " .. charID)
        return
    end

    if !isnumber(id) then
        id = hcWhitelist.uniqueIDToID(id)

        if !id then
            hcWhitelist.consoleLog("Failed to find class with uniqueID " .. id, true)
            return
        end
    end

    local class = nut.class.list[id]
    if !class then
        hcWhitelist.consoleLog("Failed to find class with ID " .. id, true)
        return
    end

    local success, msg
    local ply = char:getPlayer()
    if IsValid(ply) and ply:getChar():getID() == charID then
        success, msg = char:joinClass(id)
    else
        success = true
    end

    if success then
        char:setClass(id)
        char:setData("class", class.uniqueID)
        hcWhitelist.consoleLog("Successfully set " .. char:getName() .. "'s class to " .. class.uniqueID)

        hcWhitelist.setClassOffline(charID, class.uniqueID, hcMem)
    else
        if msg then
            hcWhitelist.consoleLog("Failed to set " .. char:getName() .. "'s class to " .. class.uniqueID .. ". Error: " .. msg, true)
        else
            hcWhitelist.consoleLog("Failed to set " .. char:getName() .. "'s class to " .. class.uniqueID, true)
        end
    end
end

function hcWhitelist.setFaction(charID, uniqueID, hcMem) --Set player's faction by uniqueID
    local char = nut.char.loaded[charID]
    if !char then
        hcWhitelist.consoleLog("Failed to find char with ID " .. charID)
        return
    end

    local faction = nut.faction.teams[uniqueID]
    if faction then
        char.vars.faction = faction.uniqueID
        char:setFaction(faction.index)

        if isfunction(faction.onTransfered) then
            faction.onTransfered()
        end

        if IsValid(char:getPlayer()) then
            net.Start("hcSetFaction")
                net.WriteString(faction.uniqueID)
                net.WriteEntity(char:getPlayer())
            net.Broadcast()
        end

        hcWhitelist.consoleLog("Successfully set " .. char:getName() .. "'s faction to " .. uniqueID)

        hcWhitelist.setFactionOffline(charID, uniqueID, true, hcMem)

        local defaultClass = hcWhitelist.getDefaultClass(faction.index).index
        hcWhitelist.setClass(charID, defaultClass, hcMem)
    else
        hcWhitelist.consoleLog("Failed to find faction with uniqueID " .. uniqueID, true)
    end
end

function hcWhitelist.setName(charID, name, hcMem)
    local char = nut.char.loaded[charID]
    if !char then
        hcWhitelist.consoleLog("Failed to find char with ID " .. charID)
        return
    end

    local ply = char:getPlayer()
    if IsValid(ply) and ply:getChar():getID() == charID then
        ply:notify(hcMem:Nick() .. " has changed your name to " .. name .. ".")
    end

    char:setName(name)
    hcWhitelist.setNameOffline(charID, name, hcMem)
end

function hcWhitelist.setClassOffline(charID, uniqueID, hcMem) --Set offline character's class uniqueID
    hcWhitelist.consoleLog("Setting character with id " .. charID .. "'s class to " .. uniqueID .. " in DB")

    nut.db.query("SELECT * FROM `nut_characters` WHERE `_id` = '" .. charID .. "';", function(result)
        if !result then
            hcWhitelist.consoleLog("Character with ID " .. charID .. " not found")
            return
        end
        result = result[1]

        local data = util.JSONToTable(result._data)
        data.class = uniqueID

        local json = util.TableToJSON(data)
        nut.db.updateTable({
    		_data = json
    	}, function() hcWhitelist.consoleLog("Successfully set character with id " .. charID .. "'s class to " .. uniqueID) end, "characters", "_id = " .. charID)
    end)
end

function hcWhitelist.setFactionOffline(charID, uniqueID, skipDefault, hcMem) --Set offline character's faction by uniqueID
    hcWhitelist.consoleLog("Setting character with id " .. charID .. "'s faction to " .. uniqueID .. " in DB")

    nut.db.updateTable({
		_faction = uniqueID
	}, function() hcWhitelist.consoleLog("Successfully set character with id " .. charID .. "'s faction to " .. uniqueID) end, "characters", "_id = " .. charID)

    if skipDefault then --Avoid doing the same thing twice
        return
    end

    --Set them to the default class for this faction
    local faction = nut.faction.teams[uniqueID]
    local defaultClass = hcWhitelist.getDefaultClass(faction.index)

    if !defaultClass then
        return
    end

    local classUID = defaultClass.uniqueID

    hcWhitelist.setClassOffline(charID, classUID, hcMem)
end

function hcWhitelist.setNameOffline(charID, name, hcMem)
    hcWhitelist.consoleLog("Setting character with id " .. charID .. "'s name to " .. name .. " in DB")

    nut.db.updateTable({
		_name = name
	}, function() hcWhitelist.consoleLog("Successfully set character with id " .. charID .. "'s name to " .. name) end, "characters", "_id = " .. charID)
end
net.Receive("hcAction", function(len, ply)
    if !hcWhitelist.isNCO(ply) then
        hcWhitelist.consoleLog(ply:Nick() .. " attempted to perform an HC action while not HC", true)
        return
    end

    local action = net.ReadString()
    local args   = net.ReadTable()

	local NCOActions = {
		["setName"] = true,
		["setClass"] = true,
		["setFaction"] = true
	}

	if hcWhitelist.isNCO(ply) and !hcWhitelist.isHC(ply) then
		if !NCOActions[action] then
			hcWhitelist.consoleLog(ply:Nick() .. " attempted to perform an HC action while NCO", true)
			ply:notify("You do not have permission to do that.")
			return
		end

		local charID = args[1]
		local char   = nut.char.loaded[charID]
		local class  = char:getClass()
		local classTable = nut.class.list[class]

		if classTable.NCO or classTable.Officer then
			hcWhitelist.consoleLog(ply:Nick() .. " attempted to perform an NCO action against another NCO+", true)
			ply:notify("Action failed, you cannot perform actions on this person.")
			return
		end

		if ply[action] then
			local time = CurTime() - ply[action]

			if time < hcWhitelist.config.NCOCooldown then
				ply:notify("Action failed, you can next perform that action in " .. string.NiceTime(hcWhitelist.config.NCOCooldown - time))
				return
			end
		end

		ply[action] = CurTime()
	end

    if hcWhitelist[action] then
        args[#args + 1] = ply
        hcWhitelist.consoleLog("Calling HC action " .. action .. " for " .. ply:Nick())
        hcWhitelist[action](unpack(args))
    else
        hcWhitelist.consoleLog("Couldn't find action " .. action, true)
    end
end)

net.Receive("getFactionStoragesByID", function(len, ply)
	local facID = net.ReadString()
	local workbenches = hcWhitelist.getWorkbenches(facID) or {}
	local storages = hcWhitelist.getFactionStorages(facID) or {}
	--PrintTable(workbenches)
	--PrintTable(storages)
	table.Merge(storages, workbenches)

	local facTbl = storages or false

	if !facTbl then return end

	for k, v in pairs(facTbl) do
		for x, y in pairs(facTbl[k]) do
			if facTbl[k].canUse and !isbool(facTbl[k].canUse) then
				facTbl[k].canUse = facTbl[k].canUse() or false
			end
			facTbl[k].callback = nil -- Doesn't matter for client purposes
		end
	end

	net.Start("sendFactionStoragesByID")
		net.WriteTable(facTbl)
	net.Send(ply)
end)


function hcWhitelist.getFactionStorages(fac_id) -- Get faction storage data for a specific faction
	local storages = FactionStorage.getStoragesByFac(fac_id)
    if !storages then return end

	local data = {}

    for k, v in pairs(storages) do
		insertion = {
		    ["faction_storage_" .. storages[k]._id] = {
		        name = "Faction Storage [#" .. storages[k]._id .. "]",
				id = storages[k]._id,
		        model = "models/llama/locker03.mdl",
		        faction = storages[k].faction,
		        ent = "faction-storage",
		        canUse = function()
		            return tobool(storages[k].spawn) or false
		        end,
		        callback = false
		    },
		}
        table.Merge(data, insertion)
    end
	return data
end

function hcWhitelist.getWorkbenches(fac_id) -- Get faction storage data for a specific faction
	local workbenches = Workbenches.GetBenchesByFaction(fac_id)
    if !workbenches then return end

	local data = {}

    for k, v in pairs(workbenches) do
		insertion = {
		    ["workbench_" .. workbenches[k].benchID] = {
		        name = workbenches[k].name .. " [#" .. (workbenches[k].benchID or "NA") .. "]",
				id = workbenches[k].benchID,
		        model = workbenches[k].model or "models/props_c17/furnitureStove001a.mdl",
		        faction = workbenches[k].faction,
		        ent = "workbench",
		        canUse = function()
		            return tobool(workbenches[k].spawn) or false
		        end,
		        callback = false
		    },
		}
        table.Merge(data, insertion)
    end
	return data
end

function hcWhitelist.getFactionDeployables(id) -- Get the deployables for a specific faction
    return hcWhitelist.getFactionStorages(id) or {}
end

function hcWhitelist.addToList(tbl) -- Add an array of listings to the main list
	table.Merge(hcWhitelist.FactionDeployables, tbl)
end

function hcWhitelist.initalizeStorages()
	for k, v in pairs(nut.faction.indices) do
		local storages = hcWhitelist.getFactionDeployables(v.uniqueID)

		if !table.IsEmpty(storages) then
			hcWhitelist.addToList(storages)
			hcWhitelist.Print(jlib.Colors.Success, "Succesfully ", Color(255,255,255), "added faction storages to the deployables menu for: " .. v.name)
		else
			hcWhitelist.Print(jlib.Colors.Error, "Failed ", Color(255,255,255), "to load any storages for: " .. v.name)
		end
	end
	--PrintTable(hcWhitelist.FactionDeployables)
end

function hcWhitelist.initalizeWorkbenches()
	for k, v in pairs(nut.faction.indices) do
		local workbenches = hcWhitelist.getWorkbenches(v.uniqueID)

		if !table.IsEmpty(workbenches) then
			hcWhitelist.addToList(workbenches)
			hcWhitelist.Print(jlib.Colors.Success, "Succesfully ", Color(255,255,255), "added workbench to the deployables menu for: " .. v.name)
		else
			hcWhitelist.Print(jlib.Colors.Error, "Failed ", Color(255,255,255), "to load any workbenches for: " .. v.name)
		end
	end
end

function hcWhitelist.initalizeDeployables()
	timer.Simple(0, function()
		hcWhitelist.FactionDeployables = {}
		hcWhitelist.initalizeStorages() -- Add fac. storages to deployables table
		hcWhitelist.initalizeWorkbenches() -- Add workbenches to deployables table
	end)
end
hcWhitelist.initalizeDeployables()
function hcWhitelist.GetFactionMembers(faction, ply) --Get the data for a given faction and send it to the player requesting it
    hcWhitelist.log("Getting " .. faction .. "'s data for " .. ply:Nick(), ply:SteamID64(), "none", true)

    local startTime
    if hcWhitelist.config.debug then
        startTime = SysTime()
        hcWhitelist.consoleLog("Starting DB query")
    end

    nut.db.query("SELECT * FROM `nut_characters` WHERE `_faction` LIKE " .. sql.SQLStr(faction) .. ";", function(result)
        if hcWhitelist.config.debug then
            hcWhitelist.consoleLog("Query complete, runtime: " .. SysTime() - startTime .. "s")
        end

        if !result then
            hcWhitelist.consoleLog("Found no results for faction " .. faction)
            return
        end

        local chars = {}

        local defaultClass = hcWhitelist.getDefaultClass(nut.faction.teams[faction].index).uniqueID --Get the default class in-case their class is not stored in their data
        for i = 1, #result do --Extract just the data we need from the results to minimize size
            local charRaw = result[i]

            local class = defaultClass
            local data = util.JSONToTable(charRaw._data)
            if data and isstring(data.class) then --Get their class if it exists
                class = data.class
            end

            local char = {
                ["name"] = charRaw._name,
                ["lastseen"] = charRaw._lastJoinTime,
                ["steamid"] = charRaw._steamID,
                ["charid"] = charRaw._id,
                ["class"] = class
            }
            chars[#chars + 1] = char
        end

        local json = util.TableToJSON(chars)
        local data = util.Compress(json) --WARNING: There may come a time when this is too large to network
        local len  = #data

        if len > 65536 then
			ply:notify("Your faction cannot be managed")
            hcWhitelist.consoleLog("WARNING: Length of compressed data for " .. faction .. " exceeds 64KB!", true)
			return
        end

        net.Start("hcSendMembers")
            net.WriteUInt(len, 32)
            net.WriteData(data, len)
        net.Send(ply)

        if hcWhitelist.config.debug then
            hcWhitelist.consoleLog("Full query + data compression runtime: " .. SysTime() - startTime .. "s")
            hcWhitelist.consoleLog("Compressed data len: " .. len)
            hcWhitelist.consoleLog("Amount of faction members: " .. #result)
        end
    end)
end

function hcWhitelist.fixClasses() --Checks if each character is in a class that does not belong to their faction, if they are sets them to the default class for their faction
    nut.db.query("SELECT * FROM `nut_characters`", function(result)
        for i = 1, #result do
            local charRaw = result[i]

            local data = util.JSONToTable(charRaw._data)
            local uniqueID
            if data and isstring(data.class) then --Get their class if it exists
                uniqueID = data.class
            end

            if !uniqueID then continue end

            local ID = hcWhitelist.uniqueIDToID(uniqueID)
            if !ID then continue end

            local class = nut.class.list[ID]
            if !class then continue end

            local faction = nut.faction.teams[charRaw._faction]
            if !faction then continue end

            if class.faction != faction.index then
                local defaultClass = hcWhitelist.getDefaultClass(faction.index)
                if !defaultClass then
                    hcWhitelist.consoleLog("Char with ID " .. charRaw._id .. " in incorrect class: '" .. class.name .. "' but no default class could be found for faction: '" .. faction.name .. "'", true)
                    continue
                end

                hcWhitelist.consoleLog("Char with ID " .. charRaw._id .. " in incorrect class: '" .. class.name .. "' setting to default class: '" .. defaultClass.name .. "'", true)
                hcWhitelist.setClassOffline(charRaw._id, defaultClass.index)
            end
        end
    end)
end

function hcWhitelist.setMOTD(uniqueID, motd, teamID)
    hcWhitelist.motds[uniqueID] = motd

    local json = util.TableToJSON(hcWhitelist.motds)
    file.Write("hcwhitelistmotds.txt", json)

    local data = util.Compress(json)
    local len  = #data

    net.Start("hcMOTD")
        net.WriteUInt(len, 32)
        net.WriteData(data, len)
    net.Send(team.GetPlayers(teamID))
end

net.Receive("hcMOTD", function(len, ply)
    local motd = net.ReadString()
    local faction = nut.faction.indices[ply:getChar():getFaction()]

    if faction and hcWhitelist.isHC(ply) then
        hcWhitelist.setMOTD(faction.uniqueID, motd, ply:Team())
        hcWhitelist.log(ply:Nick() .. " has set the MOTD for " .. faction.name, ply:SteamID64(), "none", true)
	else
		ply:notify("You don't have permission to do that.")
    end
end)

net.Receive("hcDeployableSpawn", function(len,ply)
    if hcWhitelist.canOpenDeployable(ply) and IsValid(ply) and ply:IsPlayer() then

		if nut.config.get("requireDeployablesInArea") then
			local inZone = (Areas and Areas.inOwnedArea(ply)) or false -- Verify ply is within their zone/territory

			if !inZone and !ply:IsSuperAdmin() then
				ply:notify("Failed to place deployable")
				jlib.Announce(ply, Color(255,0,0), "[NOTICE] ", Color(255,155,155), "You cannot place a deployable outside of your owned faction territory")
				return
			elseif !inZone and ply:IsSuperAdmin() then
				jlib.Announce(ply, Color(255,0,0), "[NOTICE] ", Color(255,155,155), "You have forcefully spawned this deployable via admin override")
			end
		end

        deployable = net.ReadTable()

		-- FIXME: Duplication exploit can be performed on non-storages & non-workbenches
        if deployable.callback and isfunction(deployable.callback) and deployable.ent then
			hcWhitelist.FactionDeployables[id].callback(deploy, ply)
			deployable.canUse = false
			return
		elseif net.ReadTable().canUse == false then
			ply:notify("This entity has been deployed")
			return
        elseif deployable.id then
			if deployable.ent == "faction-storage" then
				FactionStorage.spawnStorByID(deployable.id, ply:GetShootPos() + (ply:GetAimVector() * 200), ply)
				deployable.canUse = false
				return
			elseif deployable.ent == "workbench" then
				Workbenches.SpawnByID(ply, deployable.id, ply:GetShootPos() + (ply:GetAimVector() * 200))
				deployable.canUse = false
			end
		else
			MsgC(Color(0,0,255), "\n[FACTION MANAGER LOG]", Color(255,0,0), " Failed to run a non-existent callback!")
        end
	end
end)

hook.Add("Initialize", "hcWhitelistLoadMOTDs", function()
    if !file.Exists("hcwhitelistmotds.txt", "DATA") then
        hcWhitelist.consoleLog("Failed to load MOTDs, file not found")
    else
        local json = file.Read("hcwhitelistmotds.txt")
        hcWhitelist.motds = util.JSONToTable(json)
    end
end)

hook.Add("PlayerLoadedChar", "hcWhitelistSendMOTDs", function(ply, char, oldChar)
    local faction = nut.faction.indices[ply:getChar():getFaction()]
    if hcWhitelist.motds[faction.uniqueID] then
        local json = util.TableToJSON(hcWhitelist.motds)
        local data = util.Compress(json)
        local len  = #data

        net.Start("hcMOTD")
            net.WriteUInt(len, 32)
            net.WriteData(data, len)
        net.Send(ply)
    end
end)

--Actually update the lastJoinTime since NS doesn't
hook.Add("PlayerLoadedChar", "JoinTimeUpdate", function(ply, char, oldChar)
    local time = math.floor(os.time())
    local id = char:getID()

    hcWhitelist.consoleLog(ply:steamName() .. " has loaded character '" .. char:getName() .. "' with id " .. id .. " updating last seen time to " .. os.date("%d/%m/%Y - %H:%M:%S", time))

    nut.db.updateTable({
		_lastJoinTime = time
	}, nil, "characters", "_id = " .. id)
end)

-- Ensure players are not able to unfreeze entities they're unintended to
if serverguard then
	hook.Add( "CanPlayerUnfreeze", "PropsUnfreezeCheck", function(ply, ent)
		local ownerSteamID = (ent.serverguard and ent.serverguard.steamID) or false

		if ownerSteamID == ply:SteamID() then
			return true
		else
			return false
		end
	end)
else
	ErrorNoHalt("Failed to detected Server Guard; halting initalization of PropsUnfreezeCheck hook")
end
