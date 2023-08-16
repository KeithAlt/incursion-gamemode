include("shared.lua")

local ACTIVE_SMOKES = {}

function ENT:Initialize()
	self.m_Particles = {}
end

function ENT:OnRemove()
	for _, v in pairs (self.m_Particles or {}) do
		if (v ~= NULL) then
			v:SetLifeTime(v:GetDieTime() + 0.1)
		end
	end
end

hook.Add("HUDDrawTargetID", "SMOKEGRENADE_HUDDrawTargetID", function()
	if (!SMOKEGRENADE_SETTINGS.BlockLOS) then
		return end

	local tr = LocalPlayer():GetEyeTrace()
	local start, endpos = tr.StartPos, tr.HitPos

	for k, v in pairs (ACTIVE_SMOKES) do
		if (!IsValid(v)) then
			ACTIVE_SMOKES[k] = nil
			continue
		end

		local dist = util.DistanceToLine(start, endpos, v.m_vSmokeCenter)
		if (dist <= v.m_fBlockRange) then
			return false
		end
	end
end)

net.Receive("SMOKEGRENADE_DETONATE", function()
	local ent = net.ReadEntity()
	if (!IsValid(ent)) then
		return end

	local n = tostring(ent)

	local pos = ent:GetPos()
	ent.m_bDetonated = true

	local emitter = ParticleEmitter(pos)
	local particles = {}
	ent.m_Particles = ent.m_Particles or {}

	local dur = SMOKEGRENADE_SETTINGS.LifeTime
	local r = SMOKEGRENADE_SETTINGS.Range * 0.275
	
	ent.m_fBlockRange = SMOKEGRENADE_SETTINGS.Range * 0.5
	ent.m_vSmokeCenter = ent:GetPos() + Vector(0, 0, r)
	ACTIVE_SMOKES[n] = ent
	
	local c = SMOKEGRENADE_SETTINGS.SmokeColor

	for i = 1, math.random(35, 40) do
		local vOffset = Vector(math.Rand(-r, r), math.Rand(-r, r), math.random(5, 20))

		local smoke = emitter:Add("particle/particle_smokegrenade2", pos + vOffset)
		smoke:SetVelocity(VectorRand() * math.Rand(200, 225))
		smoke:SetGravity(Vector(math.Rand(-10, 10), math.Rand(-10, 10), math.Rand(1, 2)))
		smoke:SetDieTime(dur * 0.15)
		smoke:SetStartAlpha(0)
		smoke:SetEndAlpha(200)
		smoke:SetStartSize(SMOKEGRENADE_SETTINGS.Range * math.Rand(0.3, 0.4))
		smoke:SetEndSize(smoke:GetStartSize())
		smoke:SetRoll(math.Rand(-180, 180))
		smoke:SetRollDelta(math.Rand(-0.2, 0.2))
		smoke:SetColor(c.r, c.g, c.b)
		smoke:SetAirResistance(180)
		table.insert(particles, smoke)
		table.insert(ent.m_Particles, smoke)
	end

	timer.Simple(dur * 0.149, function()
		if (!IsValid(ent)) then
			return end

		for _, smoke in pairs (particles) do
			local smoke2 = emitter:Add("particle/particle_smokegrenade2", smoke:GetPos())
			smoke2:SetVelocity(smoke:GetVelocity())
			smoke2:SetGravity(smoke:GetGravity())
			smoke2:SetDieTime(dur)
			smoke2:SetStartAlpha(200)
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

	timer.Simple(dur, function()
		ACTIVE_SMOKES[n] = nil
	end)
end)