AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/mosi/fallout4/furniture/workstations/cookingstation04.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:PhysWake()
end

function ENT:Use(ply)
    net.Start("CookOpenMenu")
        net.WriteEntity(self)
    net.Send(ply)
end

function ENT:Think()
    local activeCooks = self:getNetVar("activeCooks", {})

    for i = 1, #activeCooks do
        local cook = activeCooks[i]

        if !cook then continue end

        if CurTime() >= cook.endTime then
            self:FinishCooking(cook.item, cook.quality)
        end
    end
end

function ENT:StartCooking(uniqueID, ply)
    local activeCooks = self:getNetVar("activeCooks", {})

    if #activeCooks >= foCook.Config.MaxCooks then
        ply:notify("This cook station's slots are all taken!")
        return
    end

    local recipe = foCook.Foods[uniqueID].recipe

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

    --Start the cooking timer
    activeCooks[#activeCooks + 1] = {
        item = uniqueID,
        startTime = CurTime(),
        endTime = CurTime() + foCook.Foods[uniqueID].time,
        quality = ply:hasSkerk("cooker") or 0
    }

    self:StartFireEffect()

    self:setNetVar("activeCooks", activeCooks)
end

function ENT:FinishCooking(uniqueID, quality)
    quality = quality or 0

    local activeCooks = self:getNetVar("activeCooks", {})

    for k, cook in pairs(activeCooks) do
        if cook.item == uniqueID then
            table.remove(activeCooks, k)
            break
        end
    end
    self:setNetVar("activeCooks", activeCooks)

    local items = self:getNetVar("items", {})
    items[uniqueID] = items[uniqueID] or {}
    items[uniqueID][quality] = (items[uniqueID][quality] or 0) + 1

    if #activeCooks <= 0 then
        self:StopFireEffect()
    end

    self:setNetVar("items", items)
end

function ENT:TakeItems(ply)
    local char = ply:getChar()
    local inv = char:getInv()

    local items = self:getNetVar("items", {})
    PrintTable(items)
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

                local food = inv:getItemAt(x, y)
                food:setData("quality", quality)

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

            local food = inv:getItemAt(x, y)
            food:setData("quality", quality)

            items[uniqueID][quality] = math.max(items[uniqueID][quality] - 1, 0)
            break
        end
    end

    self:setNetVar("items", items)
end

function ENT:StartFireEffect()
    if ( not self.fireActive ) then
        self:EmitSound("ambient/fire/mtov_flame2.wav", 60, 100)

        self.loopSound = CreateSound(self, "ambient/fire/fire_small_loop1.wav")
        self.loopSound:SetSoundLevel(60)
        self.loopSound:Play()

        netstream.Start(player.GetAll(), "forpCookStartFire", self)

        self.fireActive = true
    end
end

function ENT:StopFireEffect()
    if ( self.fireActive ) then
        self.loopSound:ChangeVolume(0, 1) -- Fade off the campfire sound

        timer.Simple(1, function()
            local ent = self

            if ( IsValid(ent) and ent.loopSound ) then
                self.loopSound:Stop()
                self.loopSound = nil
            end
        end)

        netstream.Start(player.GetAll(), "forpCookStopFire", self)

        self.fireActive = false
    end
end

function ENT:OnRemove()
    if ( self.loopSound ) then
        self.loopSound:Stop()
    end
end