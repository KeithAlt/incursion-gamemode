//Option tab
CreateClientConVar("falloutRadsZonePlacer_fogDens", "1")

hook.Add("PopulateToolMenu", "radZoneSettings", function()

    spawnmenu.AddToolMenuOption("Utilities", "Radiation Zones", "fogSettings", "Settings", "", "", function(pnl)
        local slider = pnl:NumSlider("Radiation Fog Density", "falloutRadsZonePlacer_fogDens", 0.3, 1)
        slider.Think = function(self) --hard lock the value between the min/max
            if self:GetValue() < self:GetMin() then
                self:SetValue(self:GetMin())
            elseif self:GetValue() > self:GetMax() then
                self:SetValue(self:GetMax())
            end
        end
    end)

end)

zones = {}
rads = 0
local originalMaxHealth = 0
local inZone = false
local isImmune = false
local rate = 1
local radAmount
local gChannel
local emitter = ParticleEmitter(Vector(0, 0, 0)) --use one global emitter to create particles for all zones

//sound
local function startSound()
    sound.PlayFile("sound/radzones/rads.wav", "noblock", function(channel)
        channel:EnableLooping(true)
        channel:Play()
        channel:SetVolume(2)
        gChannel = channel
    end)
end

//net
net.Receive("radzones_plyEnteredZone", function()
    inZone    = true
    rate      = net.ReadInt(16)
    radAmount = net.ReadInt(16)
    isImmune  = net.ReadBool()
    if isImmune then return end
    //client calc for what our rads should be
    rads = rads + radAmount
    if timer.Exists("radCalc") then timer.Remove("radCalc") end
    timer.Create("radCalc", rate, 0, function()
        if isImmune then return end
        rads = rads + radAmount
    end)
    startSound()
end)

net.Receive("radzones_plyLeftZone", function()
    inZone = false
    if timer.Exists("radCalc") then timer.Remove("radCalc") end
    rads = net.ReadInt(16)
    if gChannel then
        gChannel:Stop()
    end
end)

net.Receive("radzones_updateRads", function()
    //stop rad calculation and reset rads
    if timer.Exists("radCalc") then timer.Remove("radCalc") end
    rads = net.ReadInt(16)
end)

net.Receive("radzones_updateRadsManual", function() --Same as above but dont stop the timer and play the sound once if they're not in the zone
    rads = net.ReadInt(16)
    if !inZone then --Play the sound real quick
        sound.PlayFile("sound/radzones/rads.wav", "", function(channel)
            channel:SetVolume(2)
            channel:SetTime(4)
            channel:Play()
        end)
    end
end)

net.Receive("radzones_updateImmune", function()
    isImmune = net.ReadBool()

    //Start or stop the sound depending on the new isImmune value
    if isImmune and gChannel then
        gChannel:Stop()
    elseif !isImmune and !IsValid(gChannel) and inZone then
        startSound()
    end
end)

net.Receive("radzones_updateOriginalMaxHealth", function()
    originalMaxHealth = net.ReadInt(32)
end)

//HUD
local radSign = Material("radiationsign.png")
local radW = 50
local radH = 51
hook.Add("HUDPaint", "radZonesHUD", function()
    //Rads bar
    surface.SetDrawColor(240, 81, 61, 255)
    surface.DrawRect(85+(256-math.ceil(256*(rads/originalMaxHealth))), ScrH() - 67, math.ceil(256*(rads/originalMaxHealth)), 8)
    if !inZone or isImmune then return end
    surface.SetMaterial(radSign)
    surface.SetDrawColor(240, 81, 61, 255)
    surface.DrawTexturedRect(355, ScrH() - radH - 50, radW, radH)

    if !radAmount then return end
    surface.SetFont("Trebuchet24")
    local textW = surface.GetTextSize("+" .. radAmount .. " RADS")
    surface.SetTextColor(240, 81, 61, 255)
    surface.SetTextPos(350 - textW, ScrH() - radH - 50) --rad text 5 pixels to the left of the rad symbol
    surface.DrawText("+" .. radAmount .. " RADS")
end)

//Fog effects
local function removeFog(zoneID)
    if !zones[zoneID].particles then return end
    for k,v in pairs(zones[zoneID].particles) do
        v:SetLifeTime(v:GetDieTime())
    end
    zones[zoneID].particles = nil
end

local function createFog(zone, life)
    local area = zone.area
    local center = zone.center

    if IsValid(LocalPlayer()) and LocalPlayer():GetPos():Distance(center) - area/7000 > 2200 then return end --don't draw fog for zones that are already out of render distance

    //make the amount of particles relative to the area of the rect
    local amt = area/7000 * GetConVar("falloutRadsZonePlacer_fogDens"):GetFloat() --area and client density setting

    local particles = {}
    for i=1,amt do
        //place each particle in a random pos within the zone
        local particle = emitter:Add(string.format("particle/smokesprites_00%02d",math.random(7,16)), Vector( math.Rand(zone.endPos.x, zone.startPos.x), math.Rand(zone.endPos.y, zone.startPos.y), math.max(zone.endPos.z, zone.startPos.z) ))
        particle:SetAirResistance(0)
        particle:SetVelocity(Vector(0, 0, -100000)) --we spawn the fog at the max height of the zone so move it down asap so it hits the ground
        particle:SetLifeTime(0)
        particle:SetDieTime(life)
        particle:SetColor(103, 114, 36)
        particle:SetStartAlpha(120)
        particle:SetEndAlpha(120)
        particle:SetCollide(true)
        particle:SetStartSize(100)
        particle:SetEndSize(100)
        particle:SetRoll(math.Rand(0,360))
        particle:SetRollDelta(0.01*math.Rand(-40,40))
        table.insert(particles, particle)
    end
    zones[zone.id]["particles"] = particles
end

local function receiveZone(zone, particleLife) --Initializes area, center and ID then creates fog
    local centerX = (zone.startPos.x + zone.endPos.x)/2
    local centerY = (zone.startPos.y + zone.endPos.y)/2
    local centerZ = (zone.startPos.z + zone.endPos.z)/2
    local center = Vector(centerX, centerY, centerZ)
    zone.center = center

    local w = zone.endPos.x - zone.startPos.x
    local h = zone.endPos.y - zone.startPos.y
    local area = w*h
    if area < 0 then area = area * -1 end --make sure its always positive
    zone.area = area

    local id = table.insert(zones, zone)
    zones[id]["id"] = id

    createFog(zone, timer.TimeLeft("fogTimer")) --make sure its in sync with the timer
end

timer.Create("fogTimer", 300, 0, function() --re-creates fog effects every 5 mins
    if #zones == 0 then return end
    for k,v in pairs(zones) do
        createFog(v, 300)
    end
end)

//Receive batch of zones
net.Receive("radzones_sendZones", function()
    local initZones = net.ReadTable()
    for k,v in pairs(initZones) do
        if timer.Exists("fogTimer") then
            receiveZone(v, timer.TimeLeft("fogTimer"))
        else
            receiveZone(v, 300)
        end
    end
end)

//Receive new zones and create fog effects for them
net.Receive("radzones_zoneCreated", function()
    local newZone = net.ReadTable()
    receiveZone(newZone, timer.TimeLeft("fogTimer"))
end)

//Remove zones
net.Receive("radzones_announceRemoveZone", function()
    local oldZone = net.ReadTable()

    for k,v in pairs(zones) do
        if v.startPos == oldZone.startPos and v.endPos == oldZone.endPos then
            removeFog(k)
            zones[k] = nil
            return
        end
    end

    //Given that the zone was removed we should have exited the function by now, if this is not the case throw an error
    print("Attempt to remove client-side rad zone failed")
end)

//Execute render distance
hook.Add("Think", "radFogRender", function()
    for k,v in pairs(zones) do
        local inRange = LocalPlayer():GetPos():Distance(v.center) - v.area/7000 > 2200
        if inRange and v.particles then
            removeFog(k)
        elseif !inRange and !v.particles then
            createFog(v, timer.TimeLeft("fogTimer"))
        end
    end
end)

hook.Add("ShutDown", "radEmitter", function()
    emitter:Finish()
end)