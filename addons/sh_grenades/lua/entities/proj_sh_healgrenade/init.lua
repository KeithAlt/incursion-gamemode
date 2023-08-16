AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("HEALGRENADE_DETONATE")

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

	self:SetSubMaterial(0, "models/weapons/v_models/eq_healgrenade/healgrenade")
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
		local origin = self:GetPos()

		for _, victim in ipairs (player.GetAll()) do
			if (!victim:Alive() or victim:GetObserverMode() ~= OBS_MODE_NONE or victim:Health() >= victim:GetMaxHealth()) then
				continue end

			local inrange = victim:GetPos():Distance(origin) <= HEALGRENADE_SETTINGS.Range * 0.55
			if (inrange) then
				victim.m_fLastHealGassed = victim:Alive() and CurTime() or -1
			end

			if (victim.m_fLastHealGassed and CurTime() - victim.m_fLastHealGassed <= HEALGRENADE_SETTINGS.AfterGasTime) or (inrange) then
				victim:SetHealth(math.min(victim:Health() + HEALGRENADE_SETTINGS.HealAmount, victim:GetMaxHealth()))
			end
		end

		self:NextThink(CurTime() + HEALGRENADE_SETTINGS.HealInterval)
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
	self.m_fRemoveIn = CurTime() + HEALGRENADE_SETTINGS.GasTime

	net.Start("HEALGRENADE_DETONATE")
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