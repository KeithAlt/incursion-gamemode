AddCSLuaFile()

ENT.Type      = "anim"
ENT.Base      = "base_gmodentity"

ENT.PrintName = "Harvestable Plant"
ENT.Category  = "Claymore Gaming"
ENT.Author    = "jonjo"

ENT.Spawnable = true

if SERVER then
    function ENT:Initialize()
        self:SetModel(self.Model or "models/props/de_inferno/bushgreensmall.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end
    end

	function ENT:Use(ply)
		if (!self.Harvested or self.Harvested + self.SpawnRate < CurTime()) and ply:getChar():getInv():add(self:GetPlantType():lower()) then
			local dat = EffectData()
			dat:SetColor(BLOOD_COLOR_ANTLION_WORKER)
			dat:SetOrigin(self:GetPos() + (Vector(0, 0, self:OBBMaxs().z / 2)))

			util.Effect("BloodImpact", dat, true, true)
			self:EmitSound("physics/flesh/flesh_squishy_impact_hard1.wav")

			self:SetBodygroup(1, 1)

			nut.leveling.giveXP(ply, 5)

			self.Harvested = CurTime()
		end
	end

	function ENT:Think()
	    if self.Harvested and self.Harvested + self.SpawnRate < CurTime() then
			self:SetBodygroup(1, 0)
			self.Harvested = nil
		end
	end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "PlantType")

	if SERVER then
		self:SetPlantType("Jalapeno")

		self:NetworkVarNotify("PlantType", function(s, id, old, new)
			self.Model = Harvest.Plants[new].PlantModel
			self:SetModel(self.Model)
		end)
	end
end
