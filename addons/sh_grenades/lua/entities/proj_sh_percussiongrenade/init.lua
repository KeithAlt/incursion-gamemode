AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.m_fDieTime = CurTime() + self.LifeTime

	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if (IsValid(phys)) then
		phys:SetMass(1)
	end

	self:SetSubMaterial(0, "models/weapons/w_models/w_eq_percussiongrenade/w_eq_percussiongrenade")
end

function ENT:PhysicsCollide(data, phys)
	if (20 < data.Speed and 0.25 < data.DeltaTime) then
		self.m_fDieTime = 0
	end
end

function ENT:Think()
	if (self.m_fDieTime and self.m_fDieTime <= CurTime()) then
		self:Explode()
	end

	self:NextThink(CurTime())
	return true
end

function ENT:Explode(cooked)
	self:DoExplode()
end

function ENT:DoExplode()
	if (self.m_bExploded) then
		return end
		
	local mypos = self:GetPos()

	local trs = util.TraceLine({start = mypos + Vector(0, 0, 128), endpos = mypos + Vector(0, 0, -128), filter = self})
	util.Decal("Scorch", trs.HitPos + trs.HitNormal, trs.HitPos - trs.HitNormal)

	local eff = EffectData()
	eff:SetOrigin(mypos)
	if (!PERCUSSIONGRENADE_SETTINGS.DefaultExplosionSound) then
		eff:SetFlags(4)
		self:EmitSound(self.ExplosionSounds[math.random(#self.ExplosionSounds)])
	end
	util.Effect("Explosion", eff, false, true)
	
	util.BlastDamage(self, IsValid(self:GetOwner()) and self:GetOwner() or self, mypos, PERCUSSIONGRENADE_SETTINGS.Radius, PERCUSSIONGRENADE_SETTINGS.Damage)
		
	self:Remove()
end