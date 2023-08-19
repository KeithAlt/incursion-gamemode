AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/mosi/fallout4/furniture/workstations/chemistrystation01.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:PhysWake()
end

function ENT:Use(ply)
    net.Start("ChemsOpenMenu")
        net.WriteEntity(self)
    net.Send(ply)
end

function ENT:Think()
    local activeCrafts = self:getNetVar("activeCrafts", {})

    for i = 1, #activeCrafts do
        local craft = activeCrafts[i]

        if !craft then continue end

        if CurTime() >= craft.endTime then
            self:FinishProduction(craft.item, craft.quality)
        end
    end
end

function ENT:StartProduction(uniqueID, ply)
    local activeCrafts = self:getNetVar("activeCrafts", {})

    if #activeCrafts >= jChems.Config.MaxCrafts then
        ply:notify("This chem bench's craft slots are all taken!")
        return
    end

    local recipe = jChems.Chems[uniqueID].recipe

    local char = ply:getChar()
    local inv = char:getInv()

    --Check they have the required components
    local items = {}
    for component, amtRequired in pairs(recipe) do
        local componentItems = inv:getItemsByUniqueID(component)
        local amt = #componentItems

        if amt < amtRequired then
            ply:notify("You don't have the required materials to craft this!")
            return
        end

        local itemsToAdd = {}
        for i = 1, amtRequired do
            itemsToAdd[#itemsToAdd + 1] = componentItems[i]
        end

        items = table.Add(items, itemsToAdd)
    end

    --Remove the components from their inventory
    for k, v in ipairs(items) do
        v:remove()
    end

    --Start the craft timer
    activeCrafts[#activeCrafts + 1] = {
        item = uniqueID,
        startTime = CurTime(),
        endTime = CurTime() + jChems.Chems[uniqueID].time,
        quality = ply:hasSkerk("chemist") or 0
    }

    self:StartSoundLoop()

    self:setNetVar("activeCrafts", activeCrafts)
end

function ENT:FinishProduction(uniqueID, quality)
    quality = quality or 0

    local activeCrafts = self:getNetVar("activeCrafts", {})

    for k, craft in pairs(activeCrafts) do
        if craft.item == uniqueID then
            table.remove(activeCrafts, k)
            break
        end
    end
    self:setNetVar("activeCrafts", activeCrafts)

    local items = self:getNetVar("items", {})
    items[uniqueID] = items[uniqueID] or {}
    items[uniqueID][quality] = (items[uniqueID][quality] or 0) + 1

    if #activeCrafts <= 0 then
        self:StopSoundLoop()
    end

    self:setNetVar("items", items)
end

function ENT:TakeItems(ply)
    local char = ply:getChar()
    local inv = char:getInv()

    local items = self:getNetVar("items", {})
    if jlib.TableSum(items) <= 0 then
        ply:notify("No items to take!")

        return
    end

    for item, amts in pairs(items) do
        for quality, amt in pairs(amts) do
            for i = 1, amt do
                local x, y = inv:add(item)

                if !x then
                    ply:notify("You don't have space to take any more items!")

                    return
                end

                local chem = inv:getItemAt(x, y)
                chem:setData("quality", quality)

                amts[quality] = math.max(amts[quality] - 1, 0)
            end
        end
    end

    self:setNetVar("items", items)
end

function ENT:TakeItem(ply, uniqueID)
    local char = ply:getChar()
    local inv = char:getInv()

    local items = self:getNetVar("items", {})
    if jlib.TableSum(items[uniqueID]) <= 0 then
        ply:notify("No " .. uniqueID .. " left to take!")

        return
    end

    for quality, amt in pairs(items[uniqueID]) do
        if amt > 0 then
            local x, y = inv:add(uniqueID)

            if !x then
                ply:notify("You don't have space to take this item!")

                return
            end

            local chem = inv:getItemAt(x, y)
            chem:setData("quality", quality)

            items[uniqueID][quality] = math.max(items[uniqueID][quality] - 1, 0)
            break
        end
    end

    self:setNetVar("items", items)
end