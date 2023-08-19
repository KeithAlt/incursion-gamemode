AddCSLuaFile("fusion_config.lua")

util.AddNetworkString("StartReactorClaim")
util.AddNetworkString("HaltReactorClaim")
util.AddNetworkString("ReactorOpenMenu")
util.AddNetworkString("ReactorRequestInv")
util.AddNetworkString("ReactorOpenInv")
util.AddNetworkString("ReactorAsk")
util.AddNetworkString("ReactorConfirm")
util.AddNetworkString("ReactorContest")
util.AddNetworkString("ReactorClaimStarted")
util.AddNetworkString("ReactorClaimHalted")
util.AddNetworkString("ReactorEjectFuel")
util.AddNetworkString("ReactorInsertFuel")
util.AddNetworkString("ReactorFactionAccessToggle")

resource.AddSingleFile("materials/reactorenemy.png")
resource.AddSingleFile("sound/Fusion_Start.wav")
resource.AddSingleFile("sound/Fusion_Loop.wav")
resource.AddSingleFile("sound/Fusion_Stop.wav")
--resource.AddWorkshop("671395231")

net.Receive("ReactorRequestInv", function(len, ply)
    local ent = net.ReadEntity()
    if ply:GetPos():Distance(ent:GetPos()) > 150 then return end
    if (ply != ent:GetOwnership()) and (!ent:GetFactionAccess() or ent:GetFaction() != nut.faction.indices[ply:getChar():getFaction()].uniqueID) then return end
    ent:OpenInventory(ply)
end)

net.Receive("ReactorConfirm", function(len, ply)
    local ent = net.ReadEntity()
    if ply:GetPos():Distance(ent:GetPos()) > 150 then return end
    ent:StartClaim(ply)
end)

net.Receive("ReactorInsertFuel", function(len, ply)
    local reactor = net.ReadEntity()
    if ply:GetPos():Distance(reactor:GetPos()) > 150 then return end

    local items = ply:getChar():getInv():getItems()
    for _,item in pairs(items) do
        if item.uniqueID == "component_nuclear_material" and item:getData("uses", fusionConfig.maxUses) > 0 then
            reactor:SetFuel(item:getData("uses", fusionConfig.maxUses))
            item:remove()
            reactor:OnFueled()
            return
        end
    end

    ply:notify("You lack the nuclear material required to fuel this reactor!")
end)

net.Receive("ReactorEjectFuel", function(len, ply)
    local reactor = net.ReadEntity()
    if ply:GetPos():Distance(reactor:GetPos()) > 150 then return end

    local inv = ply:getChar():getInv()
    nut.item.instance(0, "component_nuclear_material", nil, nil, nil, function(item)
        item:setData("uses", reactor:GetFuel())
        inv:add(item.id)
    end)

    reactor:SetFuel(0)
    reactor:OnFuelEjected()
end)

net.Receive("ReactorFactionAccessToggle", function(len, ply)
    local reactor = net.ReadEntity()

    if ply != reactor:GetOwnership() then return end

    reactor:SetFactionAccess(!reactor:GetFactionAccess())
end)

hook.Add("CanItemBeTransfered", "ReactorBodygroup", function(item, oldInv, newInv)
    if oldInv.vars and oldInv.vars.isBag == "reactor" and item.uniqueID == "fusion_core" then
        local ent = oldInv.reactor

        if oldInv:getItemCount("fusion_core") == 1 and IsValid(ent) then
            ent:SetBodygroup(ent:FindBodygroupByName("core"), 1)
        end
    elseif newInv.vars and newInv.vars.isBag == "reactor" and item.uniqueID == "fusion_core" then
        local ent = newInv.reactor

        if IsValid(ent) then
            ent:SetBodygroup(ent:FindBodygroupByName("core"), 0)
        end
    end
end)
