AddCSLuaFile("factionstore_config.lua")

util.AddNetworkString("factionstoreOpenInv")
util.AddNetworkString("facionstoreInvClosed")
util.AddNetworkString("factionstoreChange")
util.AddNetworkString("factionstoreDelete")
util.AddNetworkString("factionstoreLog")
util.AddNetworkString("factionstoreRequestLogs")
util.AddNetworkString("factionstoreSendLogs")
util.AddNetworkString("openFSConfigMenu")

FactionStorage = FactionStorage or {}
FactionStorage.log = jlib.GetPrintFunction("[Faction Storage]", Color(255, 196, 0))

hook.Add("InitializedSchema", "FactionStoreInit", function()
    sql.Query([[
    CREATE TABLE IF NOT EXISTS `nut_factionstore` (
        `_id` INTEGER PRIMARY KEY,
        `invID` INTEGER,
        `pos` STRING,
        `ang` STRING,
        `faction` STRING,
        `classes` STRING,
		`spawn` TINYINT,
        UNIQUE(invID)
        );
    ]])
end)

-- Allow players to handle faction storage without 'Remove' properties access
-- FIXME: Move to faction management addon system for organization sake
hook.Add("PhysgunPickup", "AllowStoragePickup", function(ply, ent)
	if ent:GetClass() == "faction-storage" and ent:GetFactionID() and ent:GetFactionID() == ply:Team() and hcWhitelist.isHC(ply) then
		return true
	end

	if ent:GetClass() == "workbench" and ent:getNetVar("faction") and ent:getNetVar("faction") == nut.faction.indices[ply:Team()].uniqueID and hcWhitelist.isHC(ply) then
		return true
	end
end)

net.Receive("facionstoreInvClosed", function(len, ply)
    if IsValid(ply.factionStoreEnt) then
        ply.factionStoreEnt.IsUsed = false
        ply.factionStoreEnt = nil
    end
end)

net.Receive("factionstoreLog", function(len, ply)
    local deposit = net.ReadBool()
    local itemName = net.ReadString()
    local invID = net.ReadInt(32)

    local inv = nut.item.inventories[invID]
    local logs = inv.vars.log or {}
    if type(logs) == "string" then
        logs = util.JSONToTable(util.Decompress(logs))
    end

    local log = {
        ["steamID"] = ply:SteamID(),
        ["name"] = ply:Nick(),
        ["time"] = os.time(),
        ["itemName"] = itemName,
        ["action"] = deposit and "Deposit" or "Withdraw"
    }
    table.insert(logs, log)

    while #logs > 2500 do
        table.remove(logs, 1)
    end

    if !file.Exists("factionstorelogs", "DATA") then
        file.CreateDir("factionstorelogs")
    end

    inv.vars.log = util.Compress(util.TableToJSON(logs))
    file.Write("factionstorelogs/" .. invID .. ".dat", inv.vars.log)
end)

net.Receive("factionstoreRequestLogs", function(_, ply)
    local invID = net.ReadInt(32)

    local logs = nut.item.inventories[invID].vars.log or {}
    local data

    if type(logs) == "table" then --Support for legacy data
        data = util.Compress(util.TableToJSON(logs))
    elseif type(logs) == "string" then
        data = logs
    end
    local len = #data

    net.Start("factionstoreSendLogs")
        net.WriteInt(len, 32)
        net.WriteData(data, len)
    net.Send(ply)
end)

hook.Add("PlayerDisconnected", "factionStoreUnused", function(ply)
    if IsValid(ply.factionStoreEnt) then
        ply.factionStoreEnt.IsUsed = false
    end
end)

function FactionStorage.updateStorages()
	FactionStorage.log("Updating faction storages")

	sql.Query([[
		ALTER TABLE nut_factionstore
		ADD COLUMN spawn TINYINT(1);
    ]])
end

local function DeleteStore(invID)
    sql.Query("DELETE FROM `nut_factionstore` WHERE `invID` LIKE " .. invID)
end

local function SaveStore(ent)
    ent:Save()
end

-- Toggle the storage spawn var by ID in DB
-- FIXME/NOTE: ??????????????????????????????
function FactionStorage.toggleStorSpawnByID(id, boolean)
	local id = id
	local boolean = boolean
	local bool_to_number = {[true] = 1, [false] = 0} -- Used for boolean toggling in MySQL

	timer.Simple(0, function() -- Called on next tick to prevent map cleanup dysnc
		sql.Query("UPDATE nut_factionstore SET spawn='" .. bool_to_number[boolean] .. "' WHERE _id='" .. id .. "'")
		FactionStorage.log(jlib.Colors.Neutral, "Changed", Color(255,255,255),  " set faction-storage[" .. id .. "] to a spawn state of - ", jlib.Colors.Neutral, tostring(boolean) .. "\n")
	end)
end

-- Returns a table of storages from a specific faction
function FactionStorage.getStoragesByFac(fac_id)
    local data = sql.Query("SELECT * FROM nut_factionstore WHERE faction= '" .. fac_id .. "'")

    if !data then
		FactionStorage.log("FAILED to fetch storages with faction ID of: " .. (fac_id or "NULL"))
		return false
	end

	FactionStorage.log("Succesfully fetched storages with faction ID of: " .. (fac_id or "NULL"))
	--PrintTable(data)
	return data or false
end


-- Loads a specific faction storage by ID
function FactionStorage.spawnStorByID(id, pos, ply)
    local data = sql.Query("SELECT * FROM nut_factionstore WHERE _id= '" .. id .. "'")

    if !data then
		ErrorNoHalt("Failed to load data from storage id " .. id)
		return
	end

	if data[1].spawn == "0" then -- FIXME/NOTE: Prevents spawn of storage if already exists in the world
		ErrorNoHalt(jlib.SteamIDName(ply) .. " attempted to spawn faction storage[" .. id .. "] with false set data; halting spawn")
		return false
	end

    for k, v in ipairs(data) do
        if !file.Exists("factionstorelogs/" .. v.invID .. ".dat", "DATA") and file.Exists("factionstorelogs/" .. v.invID .. ".txt", "DATA") then --using legacy data
            --convert it to the new compressed save data
            file.Write("factionstorelogs/" .. v.invID .. ".dat", util.Compress(file.Read("factionstorelogs/" .. v.invID .. ".txt")))
            file.Delete("factionstorelogs/" .. v.invID .. ".txt", "DATA")
        end

        local factionID = -1
        for key, faction in pairs(nut.faction.indices) do
            if faction.uniqueID == v.faction then
                factionID = key
                break
            end
        end

        if tonumber(v.faction) then factionID = tonumber(v.faction) end

        local classes = {}
        local needsSave = false
        for _, classUID in pairs(util.JSONToTable(v.classes)) do
            if isbool(classUID) then --This faction storage ent is using legacy data
                classes = util.JSONToTable(v.classes)
                needsSave = true
                break
            end

            for ID, class in pairs(nut.class.list) do
                if class.uniqueID == classUID then
                    classes[ID] = true
                end
            end
        end

		local trace = {}

		if IsValid(ply) then
			local start = ply:EyePos()
			trace.start = start
			trace.endpos = start + (ply:GetAimVector() * 150)
			trace.filter = ply

			local effectdata = EffectData()
			effectdata:SetOrigin( trace.endpos )
			util.Effect( "flash_smoke", effectdata )

			jlib.Announce(ply, Color(255,0,0), "[REMINDER] ", Color(255,155,155), "Remember to save the position of the faction storage!")
		end

        local ent = ents.Create("faction-storage")
        local ang = (ply:GetForward() or Angle(0,90))
        ent:SetPos(pos or trace.endpos)
        ent:SetAngles(Angle(ang.pitch, ang.yaw, ang.roll))
        ent.InvID = tonumber(v.invID)
        ent:SetClasses(classes)
        ent:SetFaction(factionID)
		ent.ID = v._id
        ent:Spawn()

        local physObj = ent:GetPhysicsObject()
        physObj:EnableMotion(false)

		if IsValid(ply) then
			hook.Run("AllowStoragePickup", ply, ent)
		end

        if tonumber(v.faction) or needsSave then SaveStore(ent) end
    end
end

/**
local function checkValidStorages()
	local data = sql.Query("SELECT invID, pos, ang FROM nut_factionstore")
	local storages = {}

	if !data then return end
	FactionStorage.log("Starting validity check . . .")

	for k, v in pairs(ents.FindByClass("faction-storage")) do
		if v.inventory and v.inventory:getID() then
			table.insert(storages, v.inventory:getID())
		end
	end

	local query = sql.Query("SELECT * FROM nut_factionstore")

	for k, v in pairs(query) do
		if v.spawn == 0 and !storages[v.invID] then
			--toggleStorSpawnByID(v._id, true)
			FactionStorage.log("Failed to verify the existence of faction storage[" .. v._id .. "]: Toggling to be spawnable")
		end
	end

	FactionStorage.log("Finished validity check")
end
**/

local function LoadStore() -- FIXME/NOTE: Runs on startup & map cleanup
    local data = sql.Query("SELECT * FROM nut_factionstore")
    if !data then return end

    FactionStorage.log(jlib.Colors.Success, " Loading " .. #data .. " faction storages\n")

    for k, v in ipairs(data) do
        if !file.Exists("factionstorelogs/" .. v.invID .. ".dat", "DATA") and file.Exists("factionstorelogs/" .. v.invID .. ".txt", "DATA") then --using legacy data
            --convert it to the new compressed save data
            file.Write("factionstorelogs/" .. v.invID .. ".dat", util.Compress(file.Read("factionstorelogs/" .. v.invID .. ".txt")))
            file.Delete("factionstorelogs/" .. v.invID .. ".txt", "DATA")
        end

        local factionID = -1
        for key, faction in pairs(nut.faction.indices) do
            if faction.uniqueID == v.faction then
                factionID = key
                break
            end
        end

        if tonumber(v.faction) then factionID = tonumber(v.faction) end

        local classes = {}
        local needsSave = false
        for _, classUID in pairs(util.JSONToTable(v.classes)) do
            if isbool(classUID) then --This faction storage ent is using legacy data
                classes = util.JSONToTable(v.classes)
                needsSave = true
                break
            end

            for ID, class in pairs(nut.class.list) do
                if class.uniqueID == classUID then
                    classes[ID] = true
                end
            end
        end

		-- this deletes NULL entries that shouldnt exist in the first place, mostly for debug
		--[[
		if v._id == "NULL" then
			--print("Deleting", v.invID)

			sql.Query("DELETE FROM `nut_factionstore` WHERE `invID` LIKE " ..v.invID)

			continue
		end
		--]]

		if v.spawn == '1' then -- FIXME/NOTE: True = don't spawn
			FactionStorage.log("Prevented storage[" .. v._id .. "] belonging to '" .. v.faction .. "' from spawning\n")
			continue
		end

        local ent = ents.Create("faction-storage")
        local pos = util.JSONToTable(v.pos)
        local ang = util.JSONToTable(v.ang)

		-- This condition exists for a wipe day utility that allows us to relocate
		-- Pre-existing faction storages to a different position for setup purposes.
		if WIPEDAY then
			ent:SetPos(WIPEDAYPOS_STORAGE)
			print("moved faction storage to wipe day position.")
		else
        	ent:SetPos(Vector(pos.x, pos.y, pos.z))
		end

        ent:SetAngles(Angle(ang.pitch, ang.yaw, ang.roll))
        ent.InvID = tonumber(v.invID)
        ent:SetClasses(classes)
        ent:SetFaction(factionID)
		ent.ID = v._id
        ent:Spawn()

        local physObj = ent:GetPhysicsObject()

		if IsValid(physObj) then
        	physObj:EnableMotion(false)
		end

        if tonumber(v.faction) or needsSave then SaveStore(ent) end
    end
	--checkValidStorages() -- Check faction storages that those that exist should
end

hook.Add("InitializedPlugins", "FactionstoreLoad", LoadStore)
hook.Add("PostCleanupMap", "FactionstoreLoad", LoadStore)

local function ChangeFactionAndClass(ent, tbl)
    ent:SetFaction(tbl.faction)
    ent:SetClasses(tbl.classes)
    SaveStore(ent)
end

net.Receive("factionstoreChange", function(len, ply)
    if !ply:IsSuperAdmin() then return end

    local ent = net.ReadEntity()
    local tbl = net.ReadTable()
    ChangeFactionAndClass(ent, tbl)

	FactionStorage.toggleStorSpawnByID(ent.ID, false)
	jlib.Announce(ply, Color(255,255,0), "[INFORMATION]", Color(0,255,0), " Succesfully ", Color(255,255,155), "saved faction storage position & config data")
	ply:notify("Faction storage updated & saved")
	sql.Query("UPDATE nut_factionstore SET pos = '" .. ent:GetPosSerialized() .. "', ang = '" .. ent:GetAngSerialized() .. "' WHERE _id = " .. ent.ID)
	table.Inherit(hcWhitelist.FactionDeployables, hcWhitelist.getFactionStorages(nut.faction.indices[ent:GetFactionID()].uniqueID)) -- FIXME: Scuffed solution to update our data tables
end)

net.Receive("factionstoreDelete", function(len, ply)
    if !ply:IsSuperAdmin() then return end

    local ent = net.ReadEntity()
    DeleteStore(ent.inventory:getID())

    ent:Remove()
end)

local function ExportPositions(filename)
	local data = sql.Query("SELECT _id, pos, ang FROM nut_factionstore")
	local export = ""
	for i, store in ipairs(data) do
		export = export .. store._id .. "~" .. store.pos .. "~" .. store.ang .. "|"
	end
	export = export:Trim("|")

	file.Write(filename .. ".dat", export)
end

local function ImportPositions(filename)
	local importString = file.Read(filename .. ".dat")

	if !importString or #importString <= 0 then
		error("No import file found")
	end

	for i, store in ipairs(string.Split(importString, "|")) do
		local data = string.Split(store, "~")
		sql.Query("UPDATE nut_factionstore SET pos = '" .. data[2] .. "', ang = '" .. data[3] .. "' WHERE _id = " .. data[1])
	end
end

concommand.Add("Factionstore.Export", function(ply, cmd, args)
	local argStr = table.concat(args)
	if !argStr or #argStr <= 0 then
		error("You must provide the filename")
	end
	ExportPositions(argStr)
	print("Export complete")
end)

concommand.Add("Factionstore.Import", function(ply, cmd, args)
	local argStr = table.concat(args)
	if !argStr or #argStr <= 0 then
		error("You must provide the filename")
	end
	ImportPositions(argStr)
	game.CleanUpMap()
	print("Import complete")
end)
