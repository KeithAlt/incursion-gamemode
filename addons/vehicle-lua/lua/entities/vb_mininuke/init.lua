
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:SpawnEffects()
	local entity = self

	timer.Simple(0, function() -- Call on next tick required for certain functions
		if IsValid(entity) then
			ParticleEffectAttach( "_ax_barrel_fire_flame", 1, entity, 1 )
			entity:EmitSound("fo_sfx/explosion/artillery/far/fx_explosion_artillery_far_02.ogg")
		end
	end)
end

function ENT:Initialize()
	self:SetMoveCollide(3)
	self:SetModel("models/fallout/weapons/proj_mininuke.mdl")
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

	self:SpawnEffects() -- Effect code
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

function ENT:SetDamage(dmg)
	self.dmg = dmg
end

function ENT:GetDamage()
	return self.dmg || 700
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
	util.Effect( "nuke_blastwave_fallout", effectData )
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
	ent:SetKeyValue( "iMagnitude", self:GetDamage() )
	ent:Fire( "Explode", 0, 0 )

	-- Effect code --

	util.ScreenShake(self:GetPos(), 100, 100, 4, 4000)
	self:StopParticles()
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
