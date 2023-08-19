FORTIFICATIONS = FORTIFICATIONS or {}

util.AddNetworkString("FORTIFICATIONS_ARTILLERYMENU")
util.AddNetworkString("FORTIFICATIONS_ARTILLERYREMOVECONTROLLER")

util.AddNetworkString("FORTIFICATIONS_ARTILLERYSHOOT")

util.AddNetworkString("FORTIFICATIONS_ARTILLERYROTATELEFT")
util.AddNetworkString("FORTIFICATIONS_ARTILLERYROTATERIGHT")

util.AddNetworkString("FORTIFICATIONS_ARTILLERYBARRELUP")
util.AddNetworkString("FORTIFICATIONS_ARTILLERYBARRELDOWN")


util.AddNetworkString("FORTIFICATIONS_ARTILLERYROTATEPUSH")
util.AddNetworkString("FORTIFICATIONS_ARTILLERYROTATEPULL")

util.AddNetworkString("FORTIFICATIONS_ARTILLERYBUILD")

local minDistance = 250*250
local function checkDistance(vec1, vec2)
    return vec1:DistToSqr(vec2) < minDistance 
end

local function ValidateUse( ent, ply )
    if IsValid(ent) and checkDistance(ent:GetPos(), ply:GetPos()) and ent:GetController() == ply then
        return true
    end

    return false
end

net.Receive("FORTIFICATIONS_ARTILLERYREMOVECONTROLLER", function(len, ply)
    local artillery = net.ReadEntity()
    if IsValid(artillery) and artillery:GetController() == ply then
        artillery:SetController(nil)
    end
end)

net.Receive("FORTIFICATIONS_ARTILLERYLOAD", function(len, ply)
    local artillery = net.ReadEntity()
    if !ValidateUse(artillery, ply) then return end
end)

net.Receive("FORTIFICATIONS_ARTILLERYSHOOT", function(len, ply)
    local artillery = net.ReadEntity()
    if !ValidateUse(artillery, ply) then return end

    artillery:Shoot()

end)

net.Receive("FORTIFICATIONS_ARTILLERYROTATELEFT", function(len, ply)
    local artillery = net.ReadEntity()
    if !ValidateUse(artillery, ply) then return end

    local angles = artillery:GetAngles()
    angles = angles + Angle(0,1, 0)
    artillery:SetAngles(angles)
end)

net.Receive("FORTIFICATIONS_ARTILLERYROTATERIGHT", function(len, ply)
    local artillery = net.ReadEntity()
    if !ValidateUse(artillery, ply) then return end

    local angles = artillery:GetAngles()
    angles = angles + Angle(0, -1, 0)
    artillery:SetAngles(angles)
end)


net.Receive("FORTIFICATIONS_ARTILLERYBARRELUP", function(len, ply)
    local artillery = net.ReadEntity()
    if !ValidateUse(artillery, ply) then return end

    artillery:AdjustPitch(Angle(-1, 0, 0))
end)

net.Receive("FORTIFICATIONS_ARTILLERYBARRELDOWN", function(len, ply)
    local artillery = net.ReadEntity()
    if !ValidateUse(artillery, ply) then return end

    artillery:AdjustPitch(Angle(1, 0, 0))
end)


net.Receive("FORTIFICATIONS_ARTILLERYROTATEPUSH", function(len, ply)
    local artillery = net.ReadEntity()
    if !ValidateUse(artillery, ply) then return end

    artillery:GetPhysicsObject():SetVelocity( ply:GetForward() * 100 )

end)

net.Receive("FORTIFICATIONS_ARTILLERYROTATEPULL", function(len, ply)
    local artillery = net.ReadEntity()
    if !ValidateUse(artillery, ply) then return end
    artillery:GetPhysicsObject():SetVelocity( ply:GetForward() * -100 )
end)

net.Receive("FORTIFICATIONS_ARTILLERYBUILD", function(len, ply)
    local fortification = net.ReadString()

    if FORTIFICATIONS.Deployables[fortification] == nil then return end
    if ply:getNetVar("building") != nil then ply:falloutNotify("You already have a fortification ready.") return end
    
    local data = FORTIFICATIONS.Deployables[fortification]

    local inv = ply:getChar():getInv()
    local items = {}
    for id, item in pairs(inv:getItems()) do
        if item.uniqueID == "fortification_material" then
            items[#items + 1] = id
        end
    end

    if #items >= data.itemCost then
        local removed = 0
        for _, item in ipairs(items) do
            if removed >= data.itemCost then break end
            inv:remove(item)
            removed = removed + 1
        end
        
        ply:setNetVar("building", fortification)
        ply:falloutNotify("Prepared " .. fortification)
    end
end)