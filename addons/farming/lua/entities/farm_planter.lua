AddCSLuaFile()
AddCSLuaFile("farming_config.lua")

--Shared
ENT.Type      = "anim"
ENT.Base      = "base_gmodentity"

ENT.Category  = "Claymore Gaming"
ENT.PrintName = "Farm Planter"
ENT.Author    = "jonjo"

ENT.Spawnable = true

farmingConfig = farmingConfig or {}
include("farming_config.lua")
local maxWater = farmingConfig.maxWater
local waterReplenish = farmingConfig.waterReplenish

if SERVER then --Server-side
    local models = {
        ["food_tato"] = "models/a31/fallout4/props/plants/tatoplant01.mdl",
        ["food_mutfruit"] = "models/a31/fallout4/props/plants/mutfruit_plant.mdl",
        ["food_carrot"] = "models/fallout/consumables/carrot.mdl",
        ["food_kiyya"] = "models/props/de_inferno/potted_plant3_p1.mdl",
        ["food_tarberry"] = "models/fallout/consumables/tarberry.mdl",
		["jalapeno"] = "models/mosi/fnv/props/plants/jalapeno.mdl",
		["barrelcactus"] = "models/mosi/fnv/props/plants/barrelcactus.mdl",
		["coyotetobacco"] = "models/mosi/fnv/props/plants/coyotetobacco.mdl",
		["honeymesquite"] = "models/mosi/fnv/props/plants/honeymesquite.mdl",
		["pricklypear"] = "models/mosi/fnv/props/plants/pricklypearcactus.mdl",
		["fungus"] = "models/mosi/fnv/props/plants/cavefungus.mdl",
		["flower"] = "models/mosi/fnv/props/plants/brocflower.mdl",
		["banana"] = "models/mosi/fnv/props/plants/bananayucca.mdl",
		["razorgraine"] = "models/mosi/fnv/props/plants/maize.mdl",
		["xanderroot"] = "models/mosi/fnv/props/plants/xanderroot02.mdl",
		["nevadaagave"] = "models/mosi/fnv/props/plants/nevadaagave.mdl",
		["whitehorsenettle"] = "models/mosi/fnv/props/plants/whitehorsenettle.mdl",
		["pintopod"] = "models/mosi/fnv/props/plants/pinto.mdl",
		["food_melon"] = "models/a31/fallout4/props/plants/melon_item.mdl",
		["food_pumpkin"] = "models/a31/fallout4/props/plants/pumpkin_item.mdl",
		["buffalogoard"] = "models/mosi/fnv/props/buffalogourd.mdl",
	}

    local zOff = {
        ["food_tarberry"] = 1,
        ["food_kiyya"] = -7,
		["buffalogoard"] = 1,
		["food_pumpkin"] = 3,
		["food_melon"] = -2
    }

    function ENT:Initialize()
        self:SetModel("models/fallout/plot/planter.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        local phys = self:GetPhysicsObject()
	    if (phys:IsValid()) then
            phys:SetMass(1000) --It's like a feather by default
		    phys:Wake()
	    end
        self.slots = {}
        self:SetNWInt("water", 0)

        timer.Create(self:EntIndex() .. "farmTimer", 0.1, 0, function() --Handles the lowering of the water and the growing of the plants
            if !IsValid(self) then timer.Remove(self:EntIndex() .. "farmTimer") return end
            local water = self:GetNWInt("water", 0)
            if water <= 0 then return end --We're out of water, don't need to do anything

            water = math.max(water - ((0.01 * #self.slots) * farmingConfig.waterConsumptionMultiplier), 0)
            self:SetNWInt("water", water)

            for k,v in pairs(self.slots) do
                local growth = math.min(v:GetNWInt("growth") + (0.05 / farmingConfig.growthMultiplier), 100)
                v:SetNWInt("growth", growth)
                v:SetModelScale(0.5 * (1 + (growth/100)), 0.1)
            end
        end)
    end

    function ENT:PlantSeed(seedType)
        if #self.slots >= 9 then return end --Planter is full
        local crop = ents.Create("farm_plant")

        --Plant the seed in the first available slot
        local i
        for j = 1,9 do
            if !self.slots[j] then
                self.slots[j] = crop
                i = j
                break
            end
        end

        local line = math.ceil(i/3)
        local yMod = 20  * (i - (3 * line))
        local xMod = 40 * (line - 2)
        local z = 5

        --Change the Z value depending on what row we're on since the height of the dirt changes
        if line == 1 then
            z = 3
        elseif line == 2 then
            z = 7
        end

        z = z + (zOff[seedType] or 0)

        crop.item   = seedType
        crop:SetNWInt("growth", 0)
        crop:SetNWInt("plantName", seedType)
        crop:SetModel(models[seedType])
        crop:SetModelScale(0.5)
        crop:SetPos(Vector(xMod, yMod + 20, z))
        crop:SetMoveParent(self)
    end

    function ENT:StartTouch(ent)
        local class = ent:GetClass()

        if class == "farm_seed" then --Plant the seed
            if #self.slots >= 9 then return end --Planter is full
            self:PlantSeed(ent.type)
            ent:Remove()
        elseif class == "farm_water" then --Water the planter
            local water = self:GetNWInt("water", 0)
            if water == maxWater then return end --It's already fully watered, do nothing

            self:SetNWInt("water", math.min(water + waterReplenish, maxWater))
            ent:Remove()
        end
    end

    function ENT:Use(activator, caller)
        if #self.slots == 0 then
            nut.util.notify("There are no crops planted here yet, plant some seeds first.", caller)
            return
        end

        local collected = false
        for k,v in pairs(self.slots) do
            if v:GetNWInt("growth", 0) >= 100 then
				v:EmitSound("physics/flesh/flesh_squishy_impact_hard1.wav") --Remove the crop from the planter and give the caller the yield
                v:Remove()
                self.slots[k] = nil
                local itemClass = v.item
                local inv = caller:getChar():getInv()

                for i = 1, farmingConfig.plantYield do
                    nut.item.instance(0, itemClass, nil, nil, nil, function(item)
                        inv:add(item.id)
                    end)
                end

                collected = true

				nut.leveling.giveXP(caller, 1)
            end
        end

        if collected then
            nut.util.notify("You have collected all the ripe crops.", caller)
        else
            nut.util.notify("None of the crops planted are ripe yet!", caller)
        end
    end

    function ENT:OnRemove() --Timer cleanup
        if timer.Exists(self:EntIndex() .. "farmTimer") then timer.Remove(self:EntIndex() .. "farmTimer") end
    end
end

if CLIENT then --Client-side
    local function ShadowText(text, font, x, y, colortext, colorshadow, dist, xalign, yalign)
	    draw.SimpleText(text, font, x + dist, y + dist, colorshadow, xalign, yalign)
	    draw.SimpleText(text, font, x, y, colortext, xalign, yalign)
    end
    surface.CreateFont("farm3D2D", {font = "Arial", size = 72})

    function ENT:Initialize()
        self.alpha = 0
    end

    function ENT:Draw()
        self:DrawModel()

        if LocalPlayer():GetEyeTrace().Entity == self then --Fade in the hud
            if self.alpha < 255 then self.alpha = self.alpha + 2 end
        else                                               --Fade out the hud
            if self.alpha > 0 then self.alpha = self.alpha - 2 end
        end

        if self.alpha == 0 then return end --Don't bother drawing it at all

        local eyeAng = EyeAngles()
        eyeAng.p = 0
        eyeAng.y = eyeAng.y - 90
        eyeAng.r = 90

        local h = 75
        local w = 1000

        cam.Start3D2D(self:GetPos() + Vector(0, 0, 50), eyeAng, 0.05)
            surface.SetDrawColor(0, 0, 0, self.alpha/2)
            surface.DrawRect(-(w + 8)/2, -4, w + 8, h + 8)
            surface.SetDrawColor(66, 134, 244, self.alpha)
            surface.DrawRect(-w/2, 0, w * (self:GetNWInt("water", 0)/maxWater), h)

            ShadowText("Water Remaining", "farm3D2D", 0, h/2, Color(255, 255, 255, self.alpha), Color(0, 0, 0, self.alpha), 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end
end
