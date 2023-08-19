AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
local GrenadeModel = "models/items/AR2_Grenade.mdl"
util.PrecacheModel(GrenadeModel)
function ENT:Initialize()
	self.Entity:SetModel(GrenadeModel)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self.PhysObj = self.Entity:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
	end
	self.Damage = self.Entity:GetVar("Damage",350)
	self.Owner = self.Entity:GetOwner()
	self.Armed = true
	
	local eyetrace = self.Owner:GetEyeTrace();
	-- this gets where you are looking. The SWep is making an explosion where you are LOOKING, right?
	local explode = ents.Create( "env_explosion" ) -- creates the explosion
	explode:SetPos( eyetrace.HitPos )
	-- this creates the explosion through your self.Owner:GetEyeTrace, which is why I put eyetrace in front
	explode:SetOwner( self.Owner ) -- this sets you as the person who made the explosion
	explode:Spawn() --this actually spawns the explosion
	explode:SetKeyValue( "iMagnitude", "220" ) -- the magnitude
	explode:Fire( "Explode", 0, 0 )
end
function ENT:Explode(normal)
	local Position = 1
	local WeaponEnt = 1
	local Owner = 1
	util.Effect("Explosion")
	end
	-- Effect
	local fx = EffectData()
	fx:SetOrigin(Vector(1,1,1))
	util.Effect("Explosion",fx)
function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo)
end
