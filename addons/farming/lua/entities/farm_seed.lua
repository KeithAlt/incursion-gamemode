AddCSLuaFile()

--Shared
ENT.Type      = "anim"
ENT.Base      = "base_gmodentity"

ENT.Category  = "Claymore Gaming"
ENT.PrintName = "Farm Seed"
ENT.Author    = "jonjo"

ENT.Spawnable = true

if SERVER then --Server-side
    local seedTypes = {
        "food_tato",
        "food_carrot",
        "food_mutfruit",
        "food_tarberry",
		"jalapeno",
		"barrelcactus",
		"coyotetobacco",
		"honeymesquite",
		"pricklypear",
		"fungus",
		"flower",
		"banana",
		"razorgraine",
		"whitehorsenettle",
		"nevadaagave",
		"xanderroot",
		"pintopod",
		"buffalogoard",
		"food_melon",
		"food_pumpkin"
    }

    function ENT:Initialize()
        self:SetModel("models/props_junk/garbage_bag001a.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        local phys = self:GetPhysicsObject()
	    if (phys:IsValid()) then
		    phys:Wake()
	    end
        self.type = self.type or seedTypes[math.random(1, #seedTypes)]
    end
end

if CLIENT then --Client-side
    function ENT:Draw()
        self:DrawModel()
    end
end
