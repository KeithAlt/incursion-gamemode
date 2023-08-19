//Fog effects
TheCloud.Emitter = ParticleEmitter(Vector(0, 0, 0))

local function removeFog(zoneID)
    if !TheCloud.Zones[zoneID].particles then return end
    for k,v in pairs(TheCloud.Zones[zoneID].particles) do
        v:SetLifeTime(v:GetDieTime())
    end
    TheCloud.Zones[zoneID].particles = nil
end

local function createFog(zone, life)
    local area = zone.area
    local center = zone.center

    if IsValid(LocalPlayer()) and LocalPlayer():GetPos():Distance(center) - area / 7000 > 2200 then return end

    local amt = area / 7000 * GetConVar("falloutRadsZonePlacer_fogDens"):GetFloat()

    local particles = {}
    for i=1,amt do
        local particle = TheCloud.Emitter:Add(string.format("particle/smokesprites_00%02d",math.random(7,16)), Vector( math.Rand(zone.maxs.x, zone.mins.x), math.Rand(zone.maxs.y, zone.mins.y), math.max(zone.maxs.z, zone.mins.z)))
        particle:SetAirResistance(0)
        particle:SetVelocity(Vector(0, 0, -100000))
        particle:SetLifeTime(0)
        particle:SetDieTime(life)
        particle:SetColor(180, 0, 0)
        particle:SetStartAlpha(120)
        particle:SetEndAlpha(120)
        particle:SetCollide(true)
        particle:SetStartSize(100)
        particle:SetEndSize(100)
        particle:SetRoll(math.Rand(0,360))
        particle:SetRollDelta(0.01 * math.Rand(-40, 40))
        table.insert(particles, particle)
    end
    TheCloud.Zones[zone.id]["particles"] = particles
end

local function receiveZone(zone, particleLife)
    local centerX = (zone.mins.x + zone.maxs.x)/2
    local centerY = (zone.mins.y + zone.maxs.y)/2
    local centerZ = (zone.mins.z + zone.maxs.z)/2
    local center = Vector(centerX, centerY, centerZ)
    zone.center = center

    local w = zone.maxs.x - zone.mins.x
    local h = zone.maxs.y - zone.mins.y
    local area = math.abs(w * h)
    zone.area = area

    local id = table.insert(TheCloud.Zones, zone)
    TheCloud.Zones[id]["id"] = id

    createFog(zone, timer.TimeLeft("cloudTimer"))
end

timer.Create("cloudTimer", 300, 0, function()
    if #TheCloud.Zones == 0 then return end
    for k,v in pairs(TheCloud.Zones) do
        createFog(v, 300)
    end
end)

net.Receive("TheCloudSendZones", function()
    for k,v in pairs(TheCloud.Zones) do
        removeFog(k)
    end
    TheCloud.Zones = {}

    local zones = net.ReadTable()

    for k,v in pairs(zones) do
        if timer.Exists("cloudTimer") then
            receiveZone(v, timer.TimeLeft("cloudTimer"))
        else
            receiveZone(v, 300)
        end
    end
end)

hook.Add("Think", "cloudRenderDist", function()
    for k,v in pairs(TheCloud.Zones) do
        local inRange = LocalPlayer():GetPos():Distance(v.center) - v.area / 7000 > 2200
        if inRange and v.particles then
            removeFog(k)
        elseif !inRange and !v.particles then
            createFog(v, timer.TimeLeft("cloudTimer"))
        end
    end
end)

net.Receive("TheCloudZoneRemoved", function()
    local zone = net.ReadTable()

    for k,v in pairs(TheCloud.Zones) do
        if v.mins == zone.mins and v.maxs == zone.maxs then
            removeFog(k)
            return
        end
    end
end)