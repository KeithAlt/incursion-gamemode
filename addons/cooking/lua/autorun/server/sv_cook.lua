util.AddNetworkString("CookUse")
util.AddNetworkString("CookOpenMenu")
util.AddNetworkString("CookStartCook")
util.AddNetworkString("CookTakeAll")
util.AddNetworkString("CookTakeFood")

--Cooking
net.Receive("CookStartCook", function(len, ply)
    local uniqueID = net.ReadString()
    local station = net.ReadEntity()

    if !IsValid(station) or ply:GetPos():DistToSqr(station:GetPos()) > 500 * 500 then
        return
    end

    station:StartCooking(uniqueID, ply)
end)

net.Receive("CookTakeAll", function(len, ply)
    local station = net.ReadEntity()

    if !IsValid(station) or ply:GetPos():DistToSqr(station:GetPos()) > 500 * 500 then
        return
    end

    station:TakeItems(ply)
end)

net.Receive("CookTakeFood", function(len, ply)
    local uniqueID = net.ReadString()
    local station = net.ReadEntity()

    if !IsValid(station) or ply:GetPos():DistToSqr(station:GetPos()) > 500 * 500 then
        return
    end

    station:TakeItem(ply, uniqueID)
end)