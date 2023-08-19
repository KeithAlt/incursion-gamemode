AddCSLuaFile("autorun/client/cl_oobzones.lua")

util.AddNetworkString("oobzones_plyEnteredZone") --can leave alone
util.AddNetworkString("oobzones_plyLeftZone") --can leave alone
util.AddNetworkString("oobzones_sendZone") --can leave alone
util.AddNetworkString("oobzones_removeZone") --can leave alone
util.AddNetworkString("oobzones_sendZones") --can leave alone
util.AddNetworkString("oobzones_zoneCreated") --can leave alone
util.AddNetworkString("oobzones_updateImmune") --update this
util.AddNetworkString("oobzones_announceRemoveZone") --look into this

PLAYER = FindMetaTable("Player")
local oobzones = {}
local playersInZone = {}

//meta methods for the player
function PLAYER:OOBImmunity()
	local immune = (self:GetMoveType() == MOVETYPE_NOCLIP) or self:InVehicle()

	return immune
end

function PLAYER:enteredOOBZone(zone)
    if !IsValid(self) then return end

	if(!self:OOBImmunity()) then
		self.oobTime = 10
		self.inZone = true

		net.Start("oobzones_plyEnteredZone")
			net.WriteBool(self:OOBImmunity())
		net.Send(self)
	end
end

function PLAYER:leftOOBZone()
    if !IsValid(self) then return end

	self.oobTime = nil
    self.inZone = false
    net.Start("oobzones_plyLeftZone")
    net.Send(self)
end

//player hooks
hook.Add("PlayerSpawn", "resetOOB", function(ply) //Reset their rads and origin HP in-case it changed
	ply.oobTime = nil --reset the countdown for their respawn just in case
end)

hook.Add("PlayerInitialSpawn", "sendOOBZones", function(ply)
    net.Start("oobzones_sendZones")
        net.WriteTable(oobzones)
    net.Send(ply)
end)

//data
hook.Add("Initialize", "oobZonesInit", function()
    //Create dirs/files if they don't already exist
    if !file.Exists("oobzones", "DATA") then
        file.CreateDir("oobzones")
    end
    if !file.Exists("oobzones/zones.txt", "DATA") then
        file.Write("oobzones/zones.txt", "")
    end

    //Load data from file
    local rawData = file.Read("oobzones/zones.txt", "DATA")
    local table   = util.JSONToTable(rawData)
    if table then oobzones = table end
end)

local function saveZones()
    local json = util.TableToJSON(oobzones)
    file.Write("oobzones/zones.txt", json)
end

local function nearestZone(pos)
    local nearestDist
    local nearest
    for k,v in pairs(oobzones) do
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
net.Receive("oobzones_sendZone", function(len, ply)
    if !(ply:SteamID() == "STEAM_0:0:68317481") then return end

    local mins      = net.ReadVector()
    local maxs      = net.ReadVector()

    local zone = {}
    //Make it 500 taller to make sure it will get players inside of it
    if mins.z > maxs.z then
        mins.z = mins.z + 500
    else
        maxs.z = maxs.z + 500
    end
    zone.startPos  = mins
    zone.endPos    = maxs
    table.insert(oobzones, zone)

    //Update players
    net.Start("oobzones_zoneCreated")
        net.WriteTable(zone)
    net.Broadcast()

    //Save zones to file
    saveZones()
end)

net.Receive("oobzones_removeZone", function(len, ply)
    if !(ply:SteamID() == "STEAM_0:0:68317481") then return end

    //Get the nearest zone to the pos given
    local pos = net.ReadVector()
    local zone = nearestZone(pos)
    if !zone then nut.util.notify("No zones found", ply) return end

    //Remove the zone
    table.RemoveByValue(oobzones, zone)

    //Update players
    net.Start("oobzones_announceRemoveZone")
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
        if IsValid(v) and v:IsPlayer() then
            table.insert(plyList, v)
        end
    end
    return plyList
end

local function startTimer()
    timer.Create("oobZoneTick", 1, 0, function() --ticks every 1 second
        if not oobzones then return end

        local globalPlyList = {}
        for k, zone in pairs(oobzones) do
            local plyList = playersInBox(zone.startPos, zone.endPos)
            for _,v in pairs(plyList) do
                globalPlyList[v] = true
                if !v.inZone then v:enteredOOBZone(zone) end

				if(v.oobTime) then
					if(v.oobTime > -1) then -- at 0 it looked weird
						v.oobTime = v.oobTime - 1
					else
						v:Spawn() --respawns them
					end
				end
            end
        end

        //if ply is in the playersInZone table but NOT in the globalPlyList they have just left the zone
        for k,v in pairs(playersInZone) do
            if IsValid(k) and !globalPlyList[k] then --Check if they're valid in-case they left while inside the zone
                k:leftOOBZone()
            end
        end

        playersInZone = globalPlyList
    end)
end
startTimer()

hook.Add("Think", "oobzones_timerCreator", function() --in case the timer fails for some reason it will be re-created
    if !timer.Exists("oobZoneTick") then print("oobzone timer failed, restarting") startTimer() end
end)
