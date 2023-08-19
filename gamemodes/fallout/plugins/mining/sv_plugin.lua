local PLUGIN = PLUGIN

-- Network strings
util.AddNetworkString("RefineryOpenMenu")
util.AddNetworkString("RefineryStartMelt")
util.AddNetworkString("RefineryTakeAll")
util.AddNetworkString("RefineryTakeProduct")

-- Make ores and refineries permanent
PLUGIN.SavedRocks = PLUGIN.SavedRocks or {}

function PLUGIN:PreCleanupMap()
	PLUGIN.SavedRocks = {}

	for k, ent in pairs( ents.FindByClass( "fo_mine_rock" ) ) do
        table.insert( PLUGIN.SavedRocks, {ent:GetPos(), ent:GetAngles(), ent:getNetVar("mineType", PLUGIN.DefaultType), ent:getNetVar("mineMaxHp", PLUGIN.DefaultMaxHp), ent.RefreshRate, ent.RefreshAmount, ent:getNetVar("mineHp", PLUGIN.DefaultHp), ent.NextRefresh} )
	end
end

local function SaveData()
	local Save = {}

	for k, ent in pairs( ents.FindByClass( "fo_mine_rock" ) ) do
		table.insert( Save, {ent:GetPos(), ent:GetAngles(), ent:getNetVar("mineType", PLUGIN.DefaultType), ent:getNetVar("mineMaxHp", PLUGIN.DefaultMaxHp), ent.RefreshRate, ent.RefreshAmount} )
	end

	local path = "nutscript/"..SCHEMA.folder.."/mining_data.txt"
    file.CreateDir("nutscript/"..SCHEMA.folder.."/")

    file.Write(path, util.TableToJSON(Save))
end

concommand.Add("Mining.SaveRocks", SaveData)
hook.Add("ShutDown", "fallout_mining_shutdown", SaveData)

local function recreateRock(data)
    local ent = ents.Create("fo_mine_rock")
    ent:SetPos(data[1])
    ent:SetAngles(data[2])
    ent:setNetVar("mineType", data[3])
    ent:setNetVar("mineMaxHp", data[4])
    ent.RefreshRate = data[5]
    ent.RefreshAmount = data[6]
    ent:setNetVar("mineHp", data[7] or data[4])
    ent.NextRefresh = data[8]
    ent:Spawn()
    ent:Activate()
end

local function LoadData()
	print("Loading mining rocks")

	local path = "nutscript/"..SCHEMA.folder.."/mining_data.txt"
    local tbl = util.JSONToTable(file.Read(path, "DATA") or "[]")

	for k, rockData in pairs(tbl) do
        recreateRock(rockData)
	end
end
hook.Add("PlayerInitialSpawn", "FalloutMiningLoadData", function()
	hook.Remove("PlayerInitialSpawn", "FalloutMiningLoadData")

	LoadData()
end)

function PLUGIN:PostCleanupMap()
	for k, rockData in pairs( PLUGIN.SavedRocks ) do
        recreateRock(rockData)
	end
end

-- Refinery stuff
net.Receive("RefineryStartMelt", function(len, ply)
    local uniqueID = net.ReadString()
    local refinery = net.ReadEntity()

    if ( !IsValid(refinery) or !PLUGIN:InDistance(ply:GetPos(), refinery:GetPos(), 500 ) ) then
        return
    end

    refinery:StartMelting(uniqueID, ply)
end)

net.Receive("RefineryTakeAll", function(len, ply)
    local refinery = net.ReadEntity()

    if ( !IsValid(refinery) or !PLUGIN:InDistance(ply:GetPos(), refinery:GetPos(), 500 ) ) then
        return
    end

    refinery:TakeItems(ply)
end)

net.Receive("RefineryTakeProduct", function(len, ply)
    local uniqueID = net.ReadString()
    local refinery = net.ReadEntity()

    if ( !IsValid(refinery) or !PLUGIN:InDistance(ply:GetPos(), refinery:GetPos(), 500 ) ) then
        return
    end

    refinery:TakeItem(ply, uniqueID)
end)
