include("shared.lua")

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(20, 32)
	self.m_fNextEmit = 0
	self:SetSubMaterial(0, "models/weapons/v_models/eq_mustardgas/mustardgas")
end

function ENT:Think()
	if (self.Emitter and IsValid(self.Emitter)) then
		self.Emitter:SetPos(self:GetPos())
	end

	local MySelf = LocalPlayer()
	if (self.m_bDetonated and MySelf:Alive() and MySelf:EyePos():Distance(self:GetPos()) <= MUSTARDGAS_SETTINGS.Range * 0.55) then
		MySelf.m_fLastWasInGas = CurTime()
	end
end

function ENT:OnRemove()
	if (self.m_Particles) then
		for _, v in pairs (self.m_Particles) do
			v:SetDieTime(0)
		end
	end

	if (self.Emitter and IsValid(self.Emitter)) then
		self.Emitter:Finish()
		self.Emitter = nil
	end
end

local vecGrav = Vector(0, 0, 80)
function ENT:Draw()
	self:DrawModel()

	if (!self.Emitter or !IsValid(self.Emitter) or RealTime() <= self.m_fNextEmit or self.m_bDetonated) then
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
	particle:SetColor(255, 230, math.random(40, 80))

	self.m_fNextEmit = RealTime() + math.Rand(0.03, 0.05)
end

local frac = 0
local was = false

local colmod = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

hook.Add("RenderScreenspaceEffects", "MUSTARDGAS_RenderScreenspaceEffects", function()
	local MySelf = LocalPlayer()
	if (!MySelf:Alive()) then
		MySelf.m_fLastWasInGas = 0
		MySelf.m_bInGas = false
		frac = 0

		if (MySelf.m_GasBreathingSound) then
			MySelf.m_GasBreathingSound:FadeOut(0.1)
		end

		return
	end

	local f = MySelf.m_fLastWasInGas
	local ct = CurTime()
	if (f) then
		MySelf.m_bInGas = ct - f < 0.5

		if (MySelf:SH_HasGasMask()) then
			if (MUSTARDGAS_SETTINGS.BreathingSound and was ~= MySelf.m_bInGas) then
				was = MySelf.m_bInGas

				if (was) then
					if (!MySelf.m_GasBreathingSound) then
						MySelf.m_GasBreathingSound = CreateSound(MySelf, "npc/zombie_poison/pz_breathe_loop1.wav")
					end
					MySelf.m_GasBreathingSound:Play()
				else
					if (MySelf.m_GasBreathingSound) then
						MySelf.m_GasBreathingSound:FadeOut(1)
					end
				end
			end
		else
			if (ct - f < MUSTARDGAS_SETTINGS.GasRemainTime) then
				frac = math.Approach(frac, MySelf.m_bInGas and 1 or 0, FrameTime())

				if (MUSTARDGAS_SETTINGS.MotionBlur) then
					DrawMotionBlur(0.4, 0.8 * frac, 0.01)
				end

				if (MUSTARDGAS_SETTINGS.Bloom) then
					DrawBloom(0.32, frac, 9, 9, 1, 1, 1, 1, 1)
				end

				if (MUSTARDGAS_SETTINGS.ColorModify) then
					colmod["$pp_colour_addr"] = frac * 0.5
					colmod["$pp_colour_addg"] = frac * 0.45
					DrawColorModify(colmod)
				end
			end
		end
	end
end)

local staggerdir = VectorRand()
hook.Add("CreateMove", "MUSTARDGAS_CreateMove", function(cmd)
	if (!MUSTARDGAS_SETTINGS.Stagger) then
		return end

	local MySelf = LocalPlayer()
	local f = MySelf.m_fLastWasInGas
	local ct = CurTime()
	if (f and ct - f < MUSTARDGAS_SETTINGS.GasRemainTime) then
		local ft = FrameTime()

		staggerdir = (staggerdir + ft * 8 * VectorRand()):GetNormal()

		local ang = cmd:GetViewAngles()
		local rate = ft * frac * 10
		ang.pitch = math.NormalizeAngle(ang.pitch + staggerdir.z * rate)
		ang.yaw = math.NormalizeAngle(ang.yaw + staggerdir.x * rate)
		cmd:SetViewAngles(ang)
	end
end)

net.Receive("MUSTARDGAS_DETONATE", function()
	local ent = net.ReadEntity()
	if (!IsValid(ent)) then
		return end

	local pos = ent:GetPos()
	ent.m_bDetonated = true

	local emitter = ParticleEmitter(pos)
	local dur = MUSTARDGAS_SETTINGS.GasTime
	local particles = {}
	ent.m_Particles = {}

	local r = MUSTARDGAS_SETTINGS.Range * 0.275

	for i = 1, math.random(35, 40) do
		local vOffset = Vector(math.Rand(-r, r), math.Rand(-r, r), math.random(5, 20))

		local smoke = emitter:Add("particle/particle_smokegrenade1", pos + vOffset)
		smoke:SetVelocity(VectorRand() * math.Rand(200, 225))
		smoke:SetGravity(Vector(math.Rand(-10, 10), math.Rand(-10, 10), math.Rand(10, 20)))
		smoke:SetDieTime(dur * 0.15)
		smoke:SetStartAlpha(0)
		smoke:SetEndAlpha(255)
		smoke:SetStartSize(MUSTARDGAS_SETTINGS.Range * math.Rand(0.3, 0.4))
		smoke:SetEndSize(smoke:GetStartSize())
		smoke:SetRoll(math.Rand(-180, 180))
		smoke:SetRollDelta(math.Rand(-0.2, 0.2))
		smoke:SetColor(255, 230, math.random(40, 80))
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

hook.Add("TTTBodySearchPopulate", "MUSTARDGAS_TTTBodySearchPopulate", function(search, raw)
	if (!raw.eq_gasmask) then
		return end

	local highest = 0
	for _, v in pairs (search) do
		highest = math.max(highest, v.p)
	end

	search.eq_gasmask = {img = "vgui/ttt/icon_gasmask", text = "They had a gas mask on.", p = highest + 1}
end)

hook.Add("TTTBodySearchEquipment", "MUSTARDGAS_TTTBodySearchEquipment", function(search, eq)
	search.eq_gasmask = util.BitSet(eq, EQUIP_GASMASK)
end)