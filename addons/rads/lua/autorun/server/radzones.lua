radsConfig = {}
include("rads_config.lua")
AddCSLuaFile("autorun/client/cl_radZones.lua")
AddCSLuaFile("rads_config.lua")

util.AddNetworkString("radzones_plyEnteredZone")
util.AddNetworkString("radzones_plyLeftZone")
util.AddNetworkString("radzones_sendZone")
util.AddNetworkString("radzones_removeZone")
util.AddNetworkString("radzones_sendZones")
util.AddNetworkString("radzones_zoneCreated")
util.AddNetworkString("radzones_updateRads")
util.AddNetworkString("radzones_updateImmune")
util.AddNetworkString("radzones_announceRemoveZone")
util.AddNetworkString("radzones_updateOriginalMaxHealth")
util.AddNetworkString("radzones_updateRadsManual")

PLAYER = FindMetaTable("Player")
local zones = {}
local playersInZone = {}

//meta methods for the player
function PLAYER:RadImmunity(ignoreImmuneVar)
	if !self:getChar() then return false end
	return (!ignoreImmuneVar and self.isImmune) or self:hasSkerk("norads") or nut.class.list[self:getChar():getClass()].radImmune
end

function PLAYER:initPlyOriginHP()
    if !IsValid(self) then return end

    self.originalMaxHealth = self:GetMaxHealth()
    net.Start("radzones_updateOriginalMaxHealth")
        net.WriteInt(self.originalMaxHealth, 32)
    net.Send(self)
end

function PLAYER:enteredZone(zone)
    if !IsValid(self) then return end

    self.inZone = true
    net.Start("radzones_plyEnteredZone")
        net.WriteInt(radsConfig.tickRate, 16)
        net.WriteInt(zone.radAmount, 16)
        net.WriteBool(self:RadImmunity())
    net.Send(self)
end

function PLAYER:leftZone()
    if !IsValid(self) then return end

    self.inZone = false
    net.Start("radzones_plyLeftZone")
        net.WriteInt(self.rads, 16)
    net.Send(self)
end

function PLAYER:addRads(radAmount)
    if !IsValid(self) then return end
    if self:RadImmunity() then return end //Player is immune because of faction
    if !self:Alive() then return end //Don't add rads to a dead player

    if !self.rads then self.rads = radAmount end
    self.rads = self.rads + radAmount
    self:SetMaxHealth(self:GetMaxHealth() - radAmount)
    //Useful when lethality is very high
    if self:GetMaxHealth() <= 0 and self:Alive() then
        self:Kill()
    else
        self:TakeDamage(radAmount)
    end
end

function PLAYER:addRadsUpdate(radAmount) --Adds rads and immediately updates the user, for use when rads are being added while not inside a zone
    self:addRads(radAmount)
    net.Start("radzones_updateRadsManual")
        net.WriteInt(self.rads, 16)
    net.Send(self)
end

function PLAYER:getRads()
    return self.rads
end

//player hooks
hook.Add("PlayerSpawn", "resetRads", function(ply) //Reset their rads and origin HP in-case it changed
    timer.Simple(2, function() --Wait to init the origin HP as it could get changed shortly after this hook
        ply:initPlyOriginHP()
    end)
    ply.rads = 0
    net.Start("radzones_updateRads")
        net.WriteInt(0, 16)
    net.Send(ply)

    //Remove rad-x effects if they are present
    ply.isImmune = false
    if timer.Exists("immuneTimer" .. ply:SteamID64()) then timer.Remove("immuneTimer" .. ply:SteamID64()) end
end)

hook.Add("PlayerInitialSpawn", "sendZones", function(ply)
    net.Start("radzones_sendZones")
        net.WriteTable(zones)
    net.Send(ply)
end)

//data
hook.Add("Initialize", "radZonesInit", function()
    //Create dirs/files if they don't already exist
    if !file.Exists("radzones", "DATA") then
        file.CreateDir("radzones")
    end
    if !file.Exists("radzones/zones.txt", "DATA") then
        file.Write("radzones/zones.txt", "")
    end

    //Load data from file
    local rawData = file.Read("radzones/zones.txt", "DATA")
    local table   = util.JSONToTable(rawData)
    if table then zones = table end
end)

local function saveZones()
    local json = util.TableToJSON(zones)
    file.Write("radzones/zones.txt", json)
end

local function nearestZone(pos)
    local nearestDist
    local nearest
    for k,v in pairs(zones) do
        local centerX = (v.startPos.x + v.endPos.x)/2
        local centerY = (v.startPos.y + v.endPos.y)/2
        local center = Vector(centerX, centerY)
        local distance = center:Distance(pos)
        if !nearestDist or nearestDist > distance then
            nearestDist = distance
            nearest = v
        end
    end
    return nearest
end

//zone net
net.Receive("radzones_sendZone", function(len, ply)
    if !ply:IsSuperAdmin() then return end

    local mins      = net.ReadVector()
    local maxs      = net.ReadVector()
    local lethality = net.ReadInt(16)

    local zone = {}
    //Make it 500 taller to make sure it will get players inside of it
    if mins.z > maxs.z then
        mins.z = mins.z + 500
    else
        maxs.z = maxs.z + 500
    end
    zone.startPos  = mins
    zone.endPos    = maxs
    zone.radAmount = lethality
    table.insert(zones, zone)

    //Update players
    net.Start("radzones_zoneCreated")
        net.WriteTable(zone)
    net.Broadcast()

    //Save zones to file
    saveZones()
end)

net.Receive("radzones_removeZone", function(len, ply)
    if !ply:IsSuperAdmin() then return end

    //Get the nearest zone to the pos given
    local pos = net.ReadVector()
    local zone = nearestZone(pos)
    if !zone then nut.util.notify("No zones found", ply) return end

    //Remove the zone
    table.RemoveByValue(zones, zone)

    //Update players
    net.Start("radzones_announceRemoveZone")
        net.WriteTable(zone)
    net.Broadcast()

    //Save to file
    saveZones()

    nut.util.notify("Successfully removed zone", ply)
end)

//zone functions
local function playersInBox(mins, maxs)
    local entsList = ents.FindInBox(mins, maxs)
    local plyList = {}
    for k,v in pairs(entsList) do
        if IsValid(v) and v:IsPlayer() and v:GetMoveType() != MOVETYPE_NOCLIP then
            table.insert(plyList, v)
        end
    end
    return plyList
end

local function startTimer()
    timer.Create("zoneTick", radsConfig.tickRate, 0, function()
        if not zones then return end

        local globalPlyList = {}
        for k, zone in pairs(zones) do
            local plyList = playersInBox(zone.startPos, zone.endPos)
            for _,v in pairs(plyList) do
                globalPlyList[v] = true
                if !v.inZone then v:enteredZone(zone) end
                if !v.originalMaxHealth then v:initPlyOriginHP() end //init originalMaxHealth before we change maxhealth
                v:addRads(zone.radAmount) //add rads to all players in the zone
            end
        end

        //if ply is in the playersInZone table but NOT in the globalPlyList they have just left the zone
        for k,v in pairs(playersInZone) do
            if IsValid(k) and !globalPlyList[k] then --Check if they're valid in-case they left while inside the zone
                k:leftZone()
            end
        end

        playersInZone = globalPlyList
    end)
end
startTimer()

hook.Add("Think", "radzones_timerCreator", function() --in case the timer fails for some reason it will be re-created
    if !timer.Exists("zoneTick") then print("radzone timer failed, restarting") startTimer() end
end)
