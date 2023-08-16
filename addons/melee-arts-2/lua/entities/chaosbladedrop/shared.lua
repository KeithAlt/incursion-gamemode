ENT.Type 			= "anim"
ENT.PrintName		= "MeleeArtsChaosBlade"
ENT.Author			= ""
ENT.Information		= "MeleeArtsChaosBlade"
ENT.Category		= "MeleeArts"

if SERVER then

AddCSLuaFile( "shared.lua" )

function ENT:Initialize()
	self.Entity:SetModel("models/models/danguyen/iaito.mdl")
	self.Entity:SetColor(Color(219, 237, 255, 255))
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow( true )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(1)
	end
	
	self.timeleft = CurTime() + 3
	self:Think()
	self.Entity:SetUseType(SIMPLE_USE)
end

 function ENT:Think()

	self.Entity:NextThink( CurTime() )
	return true
end

function ENT:PhyHitDamn()
		end


function ENT:Use(activator, caller)
	if (activator:IsPlayer()) then		
		activator:Give("meleearts_blade_chaosblade")
		self.Entity:Remove()
	end
end

function ENT:PhysicsCollide(data,phys)

	if data.Speed > 2 then
		self.Entity:EmitSound( "npc/combine_gunship/gunship_ping_search.wav",60)
	end
	self:PhyHitDamn()
	--local impulse = -data.Speed * data.HitNormal * 0.9 + (data.OurOldVelocity * -0.7)
--	phys:ApplyForceCenter(impulse)
	
end

end