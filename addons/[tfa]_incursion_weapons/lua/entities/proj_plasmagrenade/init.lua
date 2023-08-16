AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("ELECTRICGRENADE")

function ENT:Initialize()
	self.m_fDieTime = CurTime() + 4

	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phys = self:GetPhysicsObject()
	if (IsValid(phys)) then
		phys:SetMass(7)
	end

	self:SetSubMaterial(0, "models/weapons/v_models/eq_electricgrenade/electricgrenade")
	self:SetElasticity(1)
end

function ENT:PhysicsCollide(data, phys)
	if (20 < data.Speed and 0.25 < data.DeltaTime) then
		self:EmitSound(self.BounceSound, nil, math.random(150, 175))
	end
end

function ENT:Think()
	if (self.m_fDieTime and self.m_fDieTime <= CurTime()) then
		self:Explode()
	end

	return self:DamageThink()
end

function ENT:DamageThink()
	if (self.m_fRemoveIn and self.m_fRemoveIn <= CurTime()) then
		self:Remove()
		return
	end

	if (self.m_bExploded) then
		local owner = self.Owner
		if (!IsValid(owner)) then
			return end

		local origin = self:GetPos()

		local tazed = {}
		for _, victim in ipairs (player.GetAll()) do
			if (!victim:Alive() or victim:GetObserverMode() ~= OBS_MODE_NONE or hook.Call("PlayerShouldTakeDamage", GAMEMODE, victim, self.Owner) == false) then
				continue end

			local np = victim:LocalToWorld(victim:OBBCenter())
			local t = {
				start = origin,
				endpos = np,
				filter = self,
			}
			local dist = t.start:Distance(t.endpos)
			if (dist > 150) then
				continue end

			local tr = util.TraceLine(t)

			if (tr.Entity == victim) then
				local dmg = DamageInfo()
				dmg:SetDamageType(DMG_ACID)
				dmg:SetDamage(35)
				dmg:SetInflictor(self)
				dmg:SetAttacker(owner)
				victim:TakeDamageInfo(dmg)

				local eff = EffectData()
				eff:SetStart(tr.StartPos)
				eff:SetEntity(self)
				eff:SetAttachment(1)
				eff:SetOrigin(np)
				util.Effect("vortigaunt_beam", eff, true, true)

				if IsValid(self) then
					victim:ScreenFade(SCREENFADE.IN, Color(255, 255, 255, 100), 0.2, 0)
				end

				if IsValid(self) then
					victim:AnimRestartGesture(GESTURE_SLOT_CUSTOM, ACT_GMOD_GESTURE_RANGE_FRENZY, true)
					table.insert(tazed, victim)
				end
			end

			if (#tazed > 0) then
				net.Start("ELECTRICGRENADE")
					net.WriteUInt(#tazed, 16)
					for i = 1, #tazed do
						net.WriteEntity(tazed[i])
					end
				net.SendPVS(origin)
			end
		end

		self:NextThink(CurTime() + 1)
		return true
	end
end

function ENT:Explode(cooked)
	self:DoExplode()

	util.BlastDamage(self, self.Owner, self:GetPos(), 300, 125)
	util.ScreenShake(self:GetPos(), 25, 25, 1, 1500)

	for k, v in pairs(ents.FindInSphere(self:GetPos(), 1500)) do
		if v:IsPlayer() and v:Alive() and v:GetMoveType() ~= MOVETYPE_NOCLIP then
			v:ScreenFade(SCREENFADE.IN, Color(0,255,0, 55), 0.5, 0.5)

			if v:GetPos():Distance(self:GetPos()) < 500 then
				v:Ignite(6)
			end
		end
	end

	ParticleEffect("pgex*", self:GetPos(), self:GetAngles(), NULL)
	ParticleEffect("_sai_green_fire_3", self:GetPos(), self:GetAngles(), self)

	self:EmitSound("weapons/plasmagrenade/plasma_grenade_explosion.ogg")

	timer.Simple(0.5, function()
		if IsValid(self) then
			self:EmitSound("ambient/energy/weld" .. math.random(1,2) .. ".wav")
		end
	end)
end

function ENT:DoExplode()
	if (self.m_bExploded) then
		return end

	self.m_bExploded = true
	self.m_fDieTime = nil
	self.m_fRemoveIn = CurTime() + 5

	self:SetNotSolid(true)

	local phys = self:GetPhysicsObject()
	if (IsValid(phys)) then
		phys:Sleep()
		phys:EnableMotion(false)
	end
end
