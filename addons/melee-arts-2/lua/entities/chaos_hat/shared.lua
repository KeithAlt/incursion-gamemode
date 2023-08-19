ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "chaoshat"
ENT.Category		= "Melee Arts II"

ENT.Spawnable		= false
ENT.AdminOnly = false
ENT.DoNotDuplicate = true

if SERVER then

AddCSLuaFile("shared.lua")

function ENT:Initialize()

	self.Entity:SetModel("models/player/items/humans/top_hat.mdl")
	self.Entity:SetColor(Color(255,0,0,255))
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phys = self.Entity:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Wake()
	end

self.timeleft = CurTime() + 15
	self:Think()
end
 function ENT:Think()
	
	
	
	if self.timeleft < CurTime() then
		local effectdata = EffectData() 
		effectdata:SetOrigin( self:GetPos() + Vector(0,0,5) ) 
		effectdata:SetNormal( self:GetPos():GetNormal() ) 
		effectdata:SetEntity( self ) 
		util.Effect( "darkenergyshit", effectdata )
		self.Entity:Remove()	
	end

	self.Entity:NextThink( CurTime() )
	return true
end
function ENT:Use(activator, caller)

	
	if (activator:IsPlayer()) then
		local effectdata = EffectData() 
		effectdata:SetOrigin( self:GetPos() + Vector(0,0,5) ) 
		effectdata:SetNormal( self:GetPos():GetNormal() ) 
		effectdata:SetEntity( self ) 
		util.Effect( "darkenergyshit", effectdata )
		self.Entity:Remove()
	end
end

end