AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("SMOKEGRENADE_DETONATE")

function ENT:Initialize()
	self.m_fDieTime = CurTime() + SMOKEGRENADE_SETTINGS.LifeTime

	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phys = self:GetPhysicsObject()
	if (IsValid(phys)) then
		phys:SetMass(1)
	end

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

	if (self.m_fRemoveIn and self.m_fRemoveIn <= CurTime()) then
		self:Remove()
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
	self.m_fRemoveIn = CurTime() + SMOKEGRENADE_SETTINGS.LifeTime

	net.Start("SMOKEGRENADE_DETONATE")
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