
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetMoveCollide(3)
	self:SetModel("models/chappi/mininuq.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_CUSTOM)
	self:SetHealth(1)

	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(5)
		phys:SetBuoyancyRatio(0)
		phys:EnableGravity(true)
		phys:EnableDrag(true)
	end
	self.delayRemove = CurTime() +8
end

function ENT:GetHitEntity()
	return self:GetNetworkedEntity("hitent")
end

function ENT:OnRemove()
end

function ENT:SetEntityOwner(ent)
	self:SetOwner(ent)
	self.entOwner = ent
end

function ENT:GetEntityOwner()
	return IsValid(self.entOwner) && self.entOwner || self
end

function ENT:Think()
	if CurTime() >= self.delayRemove then self:Remove(); return end
	self:NextThink(CurTime())
	return true
end

function ENT:Hit()
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:EnableMotion(false)
	end
	--
	local effectData = EffectData()
	effectData:SetScale(1)
	effectData:SetOrigin(self:GetPos())
	util.Effect( "nuke_blastwave", effectData )
	--util.Effect( "nuke_blastwave", effectdata )
	--
	self.flLight = 6
	self.bHit = true
	self.bHitWorld = true
	self.delayRemove = CurTime() + 0.5
	self:SetNoDraw(true)
	self:DrawShadow(false)
	--
	local ent = ents.Create( "env_explosion" )
	ent:SetPos( self:GetPos() )
	ent:SetOwner( self )
	ent:Spawn()
	ent:SetKeyValue( "iMagnitude", "800" )
	ent:Fire( "Explode", 0, 0 )
end

function ENT:SetDamage(dmg)
	self.dmg = dmg
	dmg:addRadsUpdate(35)
end

function ENT:PhysicsCollide(data, physobj)
	if !data.HitEntity || self.bHit then return true end
	if IsValid(self) && (!IsValid(data.HitEntity) || (!data.HitEntity:IsPlayer() && !data.HitEntity:IsNPC())) then self:EmitSound("weapons/shock_roach/shock_impact.wav", 75, 100); self:Hit(data.HitEntity); return true end
	local owner = self:GetEntityOwner()
	data.HitEntity.attacker = owner
	data.HitEntity.inflictor = self
	self:Hit()
	return true
end
