AddCSLuaFile()

ENT.Type      = "anim"
ENT.Base      = "base_gmodentity"

ENT.PrintName = "Head Spike"
ENT.Author    = "jonjo"

ENT.Spawnable = true

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/maxib123/legionheadpike.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		self:SetHealth(30)
		self:SetMaxHealth(30)
    end

	function ENT:OnTakeDamage(dmg)
	    self:SetHealth(self:Health() - dmg:GetDamage())

		if self:Health() <= 0 then
			SafeRemoveEntityDelayed(self, 0)
		end
	end

	--[[function ENT:Use(ply)
		if ply:getChar() then
			ply:getChar():getInv():add("playerhead", 1, {headowner = self:GetHead()})
			self:Remove()
		end
	end]]
end

if CLIENT then
	function ENT:Initialize()
	    self.MinDist = 250
		self.MinDistSqr = self.MinDist ^ 2
		self.alpha = 0
	end

    function ENT:Draw()
        self:DrawModel()

		local ply = LocalPlayer()
		self.alpha = self.alpha or 0

		if ply:GetPos():DistToSqr(self:GetPos()) < self.MinDistSqr then

			if ply:GetEyeTrace().Entity == self then
				self.alpha = math.Clamp(self.alpha + 2, 0, 255)
			else
				self.alpha = math.Clamp(self.alpha - 2, 0, 255)
			end

			if self.alpha <= 0 then return end

			local eyeAng = EyeAngles()
            eyeAng.p = 0
            eyeAng.y = eyeAng.y - 90
            eyeAng.r = 90

			cam.Start3D2D(self:GetPos() + Vector(0, 0, self:OBBMaxs().z + 10), eyeAng, 0.05)
                jlib.ShadowText(self:GetHead() .. "'s head", "WB3D2D", 0, 0, Color(255, 255, 255, self.alpha), Color(0, 0, 0, self.alpha), 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            cam.End3D2D()
		end
    end
end

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "Head")

	if SERVER then
		self:SetHead("Someone")
	end
end