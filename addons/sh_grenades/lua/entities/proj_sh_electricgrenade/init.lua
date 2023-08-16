AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("ELECTRICGRENADE")

function ENT:Initialize()
	self.m_fDieTime = CurTime() + self.LifeTime

	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phys = self:GetPhysicsObject()
	if (IsValid(phys)) then
		phys:SetMass(1)
	end

	self:SetSubMaterial(0, "models/weapons/v_models/eq_electricgrenade/electricgrenade")
	self:SetElasticity(2)
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
			if (dist > ELECTRICGRENADE_SETTINGS.Range) then
				continue end

			local tr = util.TraceLine(t)

			if (tr.Entity == victim) then
				local dmg = DamageInfo()
				dmg:SetDamageType(DMG_SHOCK)
				dmg:SetDamage(ELECTRICGRENADE_SETTINGS.Damage)
				dmg:SetInflictor(self)
				dmg:SetAttacker(owner)
				victim:TakeDamageInfo(dmg)

				local eff = EffectData()
				eff:SetStart(tr.StartPos)
				eff:SetEntity(self)
				eff:SetAttachment(1)
				eff:SetOrigin(np)
				util.Effect("ToolTracer", eff, true, true)

				if (ELECTRICGRENADE_SETTINGS.FlashScreen) then
					victim:ScreenFade(SCREENFADE.IN, Color(255, 255, 255, 100), 0.2, 0)
				end

				local f = ELECTRICGRENADE_SETTINGS.StunTime
				if (f > 0) then
					victim:Freeze(true)

					timer.Simple(f, function()
						if (IsValid(victim)) then
							victim:Freeze(false)
						end
					end)
				end

				if (ELECTRICGRENADE_SETTINGS.FlailArms) then
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


		if (ELECTRICGRENADE_SETTINGS.EmitSounds) then
			self:EmitSound("npc/scanner/cbot_discharge1.wav")
		end

		self:NextThink(CurTime() + ELECTRICGRENADE_SETTINGS.DamageInterval)
		return true
	end
end

function ENT:Explode(cooked)
	self:DoExplode()

	local centerarch = ents.Create("mr_effect44")
	centerarch:SetPos(self:GetPos())
	centerarch:Spawn()
	centerarch:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	centerarch:GetPhysicsObject():EnableMotion(false)

	local arch = ents.Create("mr_effect19")
	arch:SetPos(self:GetPos())
	arch:Spawn()
	arch:EmitSound("npc/roller/mine/rmine_shockvehicle1.wav")
	arch:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	arch:GetPhysicsObject():EnableMotion(false)

	timer.Simple(20, function()
		centerarch:Remove()
		arch:Remove()
		self:EmitSound("npc/roller/mine/rmine_explode_shock1.wav")
	end)
end

function ENT:DoExplode()
	if (self.m_bExploded) then
		return end

	self.m_bExploded = true
	self.m_fDieTime = nil
	self.m_fRemoveIn = CurTime() + ELECTRICGRENADE_SETTINGS.LifeTime

	self:SetNotSolid(true)

	local phys = self:GetPhysicsObject()
	if (IsValid(phys)) then
		phys:Sleep()
		phys:EnableMotion(false)
	end
end
