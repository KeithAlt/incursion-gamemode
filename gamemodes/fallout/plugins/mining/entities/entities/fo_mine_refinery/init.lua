local PLUGIN = PLUGIN

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_c17/oildrum001.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:PhysWake()
end

function ENT:Use(ply)
    net.Start("RefineryOpenMenu")
        net.WriteEntity(self)
    net.Send(ply)
end

function ENT:Think()
    local activeMelts = self:getNetVar("activeMelts", {})

    for i = 1, #activeMelts do
        local product = activeMelts[i]

        if ( not product ) then continue end

        if ( CurTime() >= product.endTime ) then
            self:FinishMelting(product.item)
        end
    end
end

function ENT:StartMelting(uniqueID, ply)
    local activeMelts = self:getNetVar("activeMelts", {})

    if ( #activeMelts >= PLUGIN.MaxMelts ) then
        ply:notify("The refinery is full!")
        return
    end

    local recipe = PLUGIN.Recipes[uniqueID][2]

    local char = ply:getChar()
    local inv = char:getInv()

    --Check they have the required ingredients
    local ids = {}
    for component, amtRequired in pairs(recipe) do
        local amt = 0

        for k, v in pairs(inv:getItems()) do
            if v.uniqueID == component then
                amt = amt + 1

                ids[#ids + 1] = k

                if amt >= amtRequired then
                    break
                end
            end
        end

        if amt < amtRequired then
            ply:notify("You don't have the required items to product this!")
            return
        end
    end

    --Remove the ingredients from their inventory
    for k, v in ipairs(ids) do
        inv:remove(v)
    end

    --Start the melting timer
    activeMelts[#activeMelts + 1] = {
        item = uniqueID,
        startTime = CurTime(),
        endTime = CurTime() + PLUGIN.Recipes[uniqueID][1]
    }

    self:setNetVar("activeMelts", activeMelts)

    if ( #activeMelts == 1 ) then
        -- Tell clients to start melt animation
    end
end

function ENT:FinishMelting(uniqueID)
    local activeMelts = self:getNetVar("activeMelts", {})

    for k, product in pairs(activeMelts) do
        if ( product.item == uniqueID ) then
            table.remove(activeMelts, k)
            break
        end
    end
    self:setNetVar("activeMelts", activeMelts)

    local items = self:getNetVar("items", {})
    items[uniqueID] = (items[uniqueID] or 0) + 1

    self:setNetVar("items", items)

    if ( #activeMelts <= 0 ) then
        -- Tell clients to stop melt animation
    end
end

function ENT:TakeItems(ply)
    local char = ply:getChar()
    local inv = char:getInv()

    local items = self:getNetVar("items", {})

    if ( PLUGIN:TableSum(items) <= 0 ) then
        ply:notify("No items to take!")

        return
    end

    for item, amt in pairs(items) do

        local amount = amt

        for i = 1, amt do
            local x, y = inv:add(item)

            if !x then
                ply:notify("You don't have space to take any more items!")

                return
            end

            amount = math.max(amount - 1, 0)
        end

        items[item] = amount
    end

    self:setNetVar("items", items)
end

function ENT:TakeItem(ply, uniqueID)
    local char = ply:getChar()
    local inv = char:getInv()

    local items = self:getNetVar("items", {})
    if ( items[uniqueID] <= 0 ) then
        ply:notify("No " .. uniqueID .. " left to take!")

        return
    end

    if ( items[uniqueID] > 0 ) then
        local x, y = inv:add(uniqueID)

        if !x then
            ply:notify("You don't have space to take this item!")

            return
        end

        items[uniqueID] = math.max(items[uniqueID] - 1, 0)
    end

    self:setNetVar("items", items)
end