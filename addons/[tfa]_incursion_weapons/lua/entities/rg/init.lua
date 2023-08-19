AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local FlyingSound = Sound("Missile.Accelerate")

/*---------------------------------------------------------
   Name: ENT:Initialize()
---------------------------------------------------------*/
function ENT:Initialize()

	self.Owner = self.Entity.Owner

	self.Entity:SetModel( "models/Items/AR2_Grenade.mdl" )
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	self.Entity:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	
	self.Entity:SetFriction(0)
	
	local phys = self.Entity:GetPhysicsObject()
	
	if phys:IsValid() then
		phys:Wake()
	end
	
	self.Flying = false
	
end

/*---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage(dmginfo)

	self.Entity:TakePhysicsDamage(dmginfo)
	
end

/*---------------------------------------------------------
   Name: ENT:Use()
---------------------------------------------------------*/
function ENT:Use(activator, caller)
	
	if !self.Flying then
		self.Entity:Remove()
		if (activator:IsPlayer()) then
			activator:GiveAmmo(1, "SMG1_Grenade")
		end
	end
	
end

/*---------------------------------------------------------
   Name: ENT:Think()
---------------------------------------------------------*/
function ENT:Think()
	
	local vel = self.Entity:GetVelocity()
	local vellen = vel:Length()
	
	if vellen >= 500 and !self.Flying then
		self.Entity:EmitSound(FlyingSound)
		self.Flying = true
	elseif vellen < 500 and self.Flying then
		self.Entity:StopSound(FlyingSound)
		self.Flying = false
	end
	
end

/*---------------------------------------------------------
   Name: ENT:OnRemove()
---------------------------------------------------------*/
function ENT:OnRemove()
	self.Entity:StopSound(FlyingSound)
end