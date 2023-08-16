AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("MUSTARDGAS_DETONATE")

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

	self:SetSubMaterial(0, "models/weapons/v_models/eq_mustardgas/mustardgas")
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

		for _, victim in pairs (player.GetAll()) do
			if (victim:SH_HasGasMask() or !victim:Alive() or victim:GetObserverMode() ~= OBS_MODE_NONE or !GAMEMODE:PlayerShouldTakeDamage(owner, victim)) then
				continue end

			local inrange = victim:GetPos():Distance(origin) <= MUSTARDGAS_SETTINGS.Range * 0.55
			if (victim.m_fLastGassed and CurTime() - victim.m_fLastGassed <= MUSTARDGAS_SETTINGS.AfterGasTime) or (inrange) then
				local a = owner:Armor()
				if (a > 0) then
					owner:SetArmor(0)
				end

				local dmg = DamageInfo()
				dmg:SetDamage(MUSTARDGAS_SETTINGS.Damage)
				dmg:SetInflictor(self)
				dmg:SetAttacker(owner)
				victim:TakeDamageInfo(dmg)
				if (inrange) then
					victim.m_fLastGassed = victim:Alive() and CurTime() or -1
				end

				if (MUSTARDGAS_SETTINGS.EnableCoughing and (!victim.m_fLastCough or CurTime() - victim.m_fLastCough >= 2) and math.random(2) == 2) then
					victim.m_fLastCough = CurTime()
					victim:EmitSound("ambient/voices/cough" .. math.random(4) .. ".wav")
				end

				if (a > 0) then
					owner:SetArmor(a)
				end
			end
		end

		self:NextThink(CurTime() + MUSTARDGAS_SETTINGS.DamageInterval)
		return true
	end
end

function ENT:Explode(cooked)
	self:DoExplode()
end

function ENT:DoExplode()
	if (self.m_bExploded) then
		return end

	self.m_bExploded = true
	self.m_fDieTime = nil
	self.m_fRemoveIn = CurTime() + MUSTARDGAS_SETTINGS.GasTime

	net.Start("MUSTARDGAS_DETONATE")
		net.WriteEntity(self)
	net.Broadcast()

	self:EmitSound("weapons/smokegrenade/sg_explode.wav")
	self:SetNotSolid(true)

	local phys = self:GetPhysicsObject()
	if (IsValid(phys)) then
		phys:Sleep()
		phys:EnableMotion(false)
	end
end