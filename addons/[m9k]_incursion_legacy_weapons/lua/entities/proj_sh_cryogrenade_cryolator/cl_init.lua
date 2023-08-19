include("shared.lua")

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(20, 32)
	self.m_fNextEmit = 0
	self:SetSubMaterial(0, "models/weapons/v_models/eq_cryogrenade/cryogrenade")
end

function ENT:Think()
	if (self.Emitter) then
		self.Emitter:SetPos(self:GetPos())
	end
end

function ENT:OnRemove()
	if (self.Emitter) then
		self.Emitter:Finish()
	end
end

local vecGrav = Vector(0, 0, 80)
function ENT:Draw()
	self:DrawModel()

	if (!self.Emitter or RealTime() <= self.m_fNextEmit) then
		return end

	local pos, ang = self:LocalToWorld(self:OBBCenter()), self:GetAngles()
		
	local particle = self.Emitter:Add("particle/snow", pos + ang:Up() * 4.5)
	particle:SetVelocity(VectorRand() * 25)
	particle:SetDieTime(math.Rand(0.8, 1.2))
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-20, 20))
	particle:SetStartSize(math.Rand(1, 3))
	particle:SetEndSize(0)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(127.5)
	
	self.m_fNextEmit = RealTime() + math.Rand(0.03, 0.05)
end