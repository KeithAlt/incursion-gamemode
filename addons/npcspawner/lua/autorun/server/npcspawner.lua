npcSpawnerConfig = npcSpawnerConfig or {}
include("npcspawnerconfig.lua")

resource.AddSingleFile("materials/spawnpoint.png")
util.AddNetworkString("jonjoSendSpawn")
util.AddNetworkString("jonjoRemoveSpawn")
util.AddNetworkString("jonjoGetSpawnPoints")
util.AddNetworkString("jonjoSendSpawnPoints")

npcSpawnerConfig.NPCS = npcSpawnerConfig.NPCS or {}

--Data funcs
function NPCSpawnerInit()
    if not file.Exists("jonjonpcspawns", "DATA") then --Create files if they don't already exist
        file.CreateDir("jonjonpcspawns")
    end
    if not file.Exists("jonjonpcspawns/spawns.txt", "DATA") then --Create files if they don't already exist
        file.Write("jonjonpcspawns/spawns.txt", "")
    end
    loadSpawns()
end

function addSpawn(spawnTable)
    spawnTable.lastSpawned = 0
    table.insert(npcSpawnerConfig.Spawns, spawnTable)
end

function saveSpawns() --Call this every time the tool is used
    local json = util.TableToJSON(npcSpawnerConfig.Spawns, false)
    file.Write("jonjonpcspawns/spawns.txt", json)
end

function loadSpawns() --Call on NPCSpawnerInit
    local json  = file.Read("jonjonpcspawns/spawns.txt", "DATA")
    local data = util.JSONToTable(json)
    if data then
        npcSpawnerConfig.Spawns = data
    end
    if npcSpawnerConfig.Spawns then
        for k,v in pairs(npcSpawnerConfig.Spawns) do --reset the lastSpawned value
            v.lastSpawned = 0
        end
    end
end
NPCSpawnerInit() --no point in putting it in a hook, this runs on start anyway

--Data net
net.Receive("jonjoSendSpawn", function(len, ply)
    if !IsValid(ply) or !ply:IsSuperAdmin() then
        return
    end

    local dataTable = net.ReadTable()
    for k,v in pairs(dataTable.npcs) do
		local testEnt = ents.Create(v)
        if !IsValid(testEnt) then --entity class validation, don't let the user create script errors
            ply:ChatPrint("ERROR: Invalid entity class in position #" .. k)
            return
		else
			testEnt:Remove()
        end
    end
    ply:ChatPrint("Successfully added spawn point")
    addSpawn(dataTable)
    saveSpawns()
    if npcSpawnerConfig.Spawns then
        local data = {}
        for k,v in pairs(npcSpawnerConfig.Spawns) do
            table.insert(data, v.vector)
        end
        net.Start("jonjoSendSpawnPoints")
            net.WriteTable(data)
        net.Send(ply)
    end
end)

--Spawning funcs
local offset = Vector(45, 15, 0) --Used later in moving the NPC when there is already an entity on the spawnpoint
--[[local function playerInRadius(origin, radius)
    local entsList = ents.FindInSphere(origin, radius)
    for k,v in pairs(entsList) do
        if v:IsPlayer() and !v:IsFlagSet(FL_NOTARGET) then
            return true
        end
    end
    return false
end]]

local function playerInRadius(origin, radius)
	local radiusSqr = radius ^ 2

	for _, ply in ipairs(player.GetAll()) do
		if !ply:IsFlagSet(FL_NOTARGET) and ply:GetPos():DistToSqr(origin) < radiusSqr then
			return true
		end
	end

	return false
end

local function removeNPCS(index)
    local entsList = npcSpawnerConfig.NPCS
    for npc,_ in pairs(entsList) do
        if npc.spawnedFrom == index then
            npc:Remove()
        end
    end
end

local function entityOnEntity(NPC)
    local vector = NPC:GetPos()
    local entsList = ents.FindInBox(vector, vector) --Finds ents on a point

    for k,v in pairs(entsList) do
        if v != NPC and (v:IsNPC() or v:IsPlayer() or v:GetClass() == "prop_physics") then --Stops false positives and infinite loops
            return true
        end
    end
    return false
end

local function spawnNPCS(key)
    --for k,v in pairs(npcSpawnerConfig.Spawns) do
    local spawnPoint = npcSpawnerConfig.Spawns[key].vector
    local choice = (npcSpawnerConfig.Spawns[key].npcs[math.random(#npcSpawnerConfig.Spawns[key].npcs)])
    local NPC = ents.Create(choice)
    NPC:SetPos(spawnPoint)
    NPC:DropToFloor() --Incase the original spawnpoint is elevated
    NPC:SetPos(NPC:GetPos() + Vector(0, 0, 15)) --So they don't fall through the ground
    NPC.DropsEnabled = npcSpawnerConfig.Spawns[key].DropsEnabled

    --Using GetPos() to calculate rather then spawnPoint to account for the DropToFloor
    while entityOnEntity(NPC) do --Don't spawn the NPC inside another entity
        --While it is ontop another entity move it over until it isn't
        NPC:SetPos(NPC:GetPos() + offset)
    end

    if NPC:IsInWorld() then --Don't spawn the NPC if it isn't inside the map
        NPC:Spawn()
        NPC.spawnedFrom = key
        npcSpawnerConfig.NPCS[NPC] = true
		npcSpawnerConfig.Spawns[key].NPC = NPC
    else
        NPC:Remove()
    end
end

hook.Add("EntityRemoved", "NPCSpawnerRemoveNPC", function(ent)
    if !ent.spawnedFrom then return end
    npcSpawnerConfig.NPCS[ent] = nil
end)

hook.Add("OnNPCKilled", "NPCSpawnerNPCKilled", function(npc)
    if !npc.spawnedFrom then return end
	npcSpawnerConfig.Spawns[npc.spawnedFrom].lastSpawned = CurTime() + npcSpawnerConfig.Spawns[npc.spawnedFrom].spawnInterval
	npcSpawnerConfig.Spawns[npc.spawnedFrom].NPC = nil
    npcSpawnerConfig.NPCS[npc] = nil
end)

--Toolgun func
function getNearestSpawn(point) --Gets the nearest defined spawn point to the given point
    local nearest
    local nearestDistance
    if npcSpawnerConfig.Spawns and next(npcSpawnerConfig.Spawns) then --If there are any spawns set up
        for k,v in pairs(npcSpawnerConfig.Spawns) do
            local spawnPointVector = v.vector
            local distance         = point:Distance(spawnPointVector)
            if not nearest then
                nearest = v.vector
                nearestDistance = distance
            elseif nearestDistance > distance then
                nearest = v.vector
                nearestDistance = distance
            end
        end
        return nearest
    else
        return false
    end
end

net.Receive("jonjoRemoveSpawn", function(len, ply)
    if !IsValid(ply) or !ply:IsSuperAdmin() then
        return
    end

    local vector = net.ReadVector()
    local nearest = getNearestSpawn(vector)
    local plyDistance
    if nearest then plyDistance = nearest:Distance(ply:GetPos()) end
    if plyDistance and plyDistance < 500 then --dont remove a spawn that is accross the map from the player
        removeSpawnPoint(nearest)
        ply:ChatPrint("Successfully removed spawn point")
    elseif plyDistance then
        ply:ChatPrint("There are no spawns nearby, the closest one is " .. math.Round(plyDistance) .. "m away")
    else
        ply:ChatPrint("There are no spawns to remove")
    end
    if npcSpawnerConfig.Spawns then
        local data = {}
        for k,v in pairs(npcSpawnerConfig.Spawns) do
            table.insert(data, v.vector)
        end
        net.Start("jonjoSendSpawnPoints")
            net.WriteTable(data)
        net.Send(ply)
    end
end)

net.Receive("jonjoGetSpawnPoints", function(len, ply)
    if npcSpawnerConfig.Spawns then
        local data = {}
        for k,v in pairs(npcSpawnerConfig.Spawns) do
            table.insert(data, v.vector)
        end
        net.Start("jonjoSendSpawnPoints")
            net.WriteTable(data)
        net.Send(ply)
    end
end)

function removeSpawnPoint(point)
    if point then
        for k,v in pairs(npcSpawnerConfig.Spawns) do
            if v.vector == point then
                npcSpawnerConfig.Spawns[k] = nil
                saveSpawns()
                return
            end
        end
    end
end

--Util function
function In(inTable, value)
    for k,v in pairs(inTable) do
        if v == value then return true end
    end
    return false
end

--Command to get the player's current position
concommand.Add("NPCSpawnGetPos", function(ply)
    pos = ply:GetPos()
    ply:PrintMessage(HUD_PRINTCONSOLE, "Vector( " .. math.Round( pos.x ) .. ", " .. math.Round( pos.y ) .. ", " .. math.ceil( pos.z ) .. " )")
end)

--Spawn the NPCs every X seconds

local function npcCheck(index)
	local npc = npcSpawnerConfig.Spawns[index].NPC
	if IsValid(npc) and (npc:Health() > 0 or npc:IsRagdoll()) then
		return false
	else
		return true
	end
end

timer.Create("NPCSpawnTimer", 1, 0, function()
    if npcSpawnerConfig.Spawns then
        for k,v in pairs(npcSpawnerConfig.Spawns) do
            if CurTime() >= v.lastSpawned then
				local inRadius = playerInRadius(v.vector, v.radius)

                if inRadius and npcCheck(k) then
                    spawnNPCS(k)
                elseif !inRadius then
                    removeNPCS(k)
                end
            end
        end
    end
end)
