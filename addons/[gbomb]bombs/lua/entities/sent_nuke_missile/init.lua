AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

local sndThrustLoop = Sound("Missile.Accelerate")
local sndStop = Sound("ambient/_period.wav")

local Arm = function(EntTable)

	EntTable.Armed = true
	EntTable.Entity:SetNWBool("armed",true)
	EntTable.PhysObj:EnableGravity(false)
	EntTable:SpawnTrail()
	EntTable:StartSounds()
	
end


function ENT:Initialize()

	self.Entity:SetModel( "models/Weapons/W_missile_closed.mdl" )

	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )	
	self.Entity:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self.Entity:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
	end
	
	self.Owner = self.Entity:GetVar("owner",Entity(1))
	self.EmittingSound = false
	self.NextUse = 0
	
	self.Armed = false
	self.Entity:SetNWBool("armed",false)

	timer.Simple(0.5, function() Arm(self) end)
	
end


function ENT:PhysicsCollide( data, physobj )

	if self.Armed and data.Speed > 50 and data.DeltaTime > 0.15 then
		local nuke = ents.Create("sent_nuke")
		nuke:SetPos( self.Entity:GetPos() )
		nuke:SetVar("owner",self.Owner)
		nuke:Spawn()
		nuke:Activate()
		self:StopSounds()	
		self.Entity:Remove()
	end

end


function ENT:OnTakeDamage( dmginfo )

	self.Entity:TakePhysicsDamage( dmginfo )
	
end


function ENT:Use( activator, caller )
if self.NextUse > CurTime() then return end
	if self.Armed then	
		self.Armed = false
		self.PhysObj:EnableGravity(true)
		self.Entity:SetNWBool("armed",false)
		self.Trail:Remove()
		self:StopSounds()	
	else
		Arm(self)
		self.Owner = activator
	end
self.NextUse = CurTime() + 0.3
end


function ENT:Think()

	if self.Armed then
		
		self.PhysObj:SetVelocity(self.Entity:GetForward()*900)
		
		if self.Trail and self.Trail:IsValid() then
			self.Trail:SetPos(self.Entity:GetPos() - 16*self.Entity:GetForward())
			self.Trail:SetLocalAngles(Angle(0,0,0))
		else
			self:SpawnTrail()
		end
		
		self:StartSounds()	
	end

end

function ENT:OnRemove()
	self:StopSounds()
end

function ENT:StartSounds()	
	if not self.EmittingSound then
		self.Entity:EmitSound(sndThrustLoop)
		self.EmittingSound = true
	end
end

function ENT:StopSounds()
	if self.EmittingSound then
		self.Entity:StopSound(sndThrustLoop)
		self.Entity:EmitSound(sndStop)
		self.EmittingSound = false
	end	
end

function ENT:SpawnTrail()

	self.Trail = ents.Create("env_rockettrail")
	self.Trail:SetPos(self.Entity:GetPos() - 16*self.Entity:GetForward())
	self.Trail:SetParent(self.Entity)
	self.Trail:SetLocalAngles(Angle(0,0,0))
	self.Trail:Spawn()
	
end


