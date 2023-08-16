include("shared.lua")

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(20, 32)
	self.m_fNextEmit = 0
	self:SetSubMaterial(0, "models/weapons/v_models/eq_healgrenade/healgrenade")
end

function ENT:Think()
	if (self.Emitter) then
		self.Emitter:SetPos(self:GetPos())
	end
end

function ENT:OnRemove()
	if (self.m_Particles) then
		for _, v in pairs (self.m_Particles) do
			v:SetDieTime(0)
		end
	end

	if (self.Emitter) then
		self.Emitter:Finish()
	end
end

local vecGrav = Vector(0, 0, 80)
function ENT:Draw()
	self:DrawModel()

	if (!self.Emitter or RealTime() <= self.m_fNextEmit or self.m_bDetonated) then
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
	particle:SetColor(0, 200, math.random(225, 255))

	self.m_fNextEmit = RealTime() + math.Rand(0.03, 0.05)
end

net.Receive("HEALGRENADE_DETONATE", function()
	local ent = net.ReadEntity()
	if (!IsValid(ent)) then
		return end

	local pos = ent:GetPos()
	ent.m_bDetonated = true

	local emitter = ParticleEmitter(pos)
	local dur = HEALGRENADE_SETTINGS.GasTime
	local particles = {}
	ent.m_Particles = {}

	local r = HEALGRENADE_SETTINGS.Range * 0.275

	for i = 1, math.random(35, 40) do
		local vOffset = Vector(math.Rand(-r, r), math.Rand(-r, r), math.random(5, 20))

		local smoke = emitter:Add("particle/particle_smokegrenade1", pos + vOffset)
		smoke:SetVelocity(VectorRand() * math.Rand(200, 225))
		smoke:SetGravity(Vector(math.Rand(-10, 10), math.Rand(-10, 10), math.Rand(10, 20)))
		smoke:SetDieTime(dur * 0.15)
		smoke:SetStartAlpha(0)
		smoke:SetEndAlpha(255)
		smoke:SetStartSize(HEALGRENADE_SETTINGS.Range * math.Rand(0.3, 0.4))
		smoke:SetEndSize(smoke:GetStartSize())
		smoke:SetRoll(math.Rand(-180, 180))
		smoke:SetRollDelta(math.Rand(-0.2, 0.2))
		smoke:SetColor(0, 200, math.random(225, 255))
		smoke:SetAirResistance(180)
		table.insert(particles, smoke)
		table.insert(ent.m_Particles, smoke)
	end

	timer.Simple(dur * 0.149, function()
		for _, smoke in pairs (particles) do
			if (!IsValid(ent)) then
				break end

			local smoke2 = emitter:Add("particle/particle_smokegrenade1", smoke:GetPos())
			smoke2:SetVelocity(smoke:GetVelocity())
			smoke2:SetGravity(smoke:GetGravity())
			smoke2:SetDieTime(dur)
			smoke2:SetStartAlpha(255)
			smoke2:SetEndAlpha(0)
			smoke2:SetStartSize(smoke:GetStartSize())
			smoke2:SetEndSize(smoke:GetStartSize())
			smoke2:SetRoll(smoke:GetRoll())
			smoke2:SetRollDelta(smoke:GetRollDelta())
			smoke2:SetAirResistance(smoke:GetAirResistance())
			smoke2:SetColor(smoke:GetColor())
			table.insert(ent.m_Particles, smoke2)
		end

		emitter:Finish()
	end)
end)