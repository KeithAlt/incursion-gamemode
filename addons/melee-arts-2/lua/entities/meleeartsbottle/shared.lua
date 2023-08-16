ENT.Type = "anim"
ENT.PrintName			= "Bottle"
ENT.Author			= "danguyen"
ENT.Contact			= "sdfgsdfgsg"
ENT.Purpose			= "sdfgdfsgsdfgsdfg"
ENT.Instructions			= "sdfgsdfgsdfgfdsg"

if SERVER then
AddCSLuaFile( "shared.lua" )

function ENT:Initialize()

	self.Owner = self.Entity.Owner
	
	self.Entity:SetModel("models/props_junk/garbage_glassbottle003a.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow( true )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )
	self.Entity:SetModelScale(1)
	self.Entity:SetNWBool("debounce",false)
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
	phys:Wake()
	phys:SetMass(1)
	phys:AddAngleVelocity(phys:GetAngleVelocity()+Vector(0,1000,0))
	end
	self:Think()
end

 function ENT:Think()
	self.Entity:NextThink( CurTime() )
	return true
end

function ENT:kaboom()
	local effectdata = EffectData() 
	effectdata:SetOrigin( self:GetPos() ) 
	effectdata:SetNormal( self:GetPos():GetNormal() ) 
	effectdata:SetEntity( self ) 	
	util.Effect( "GlassImpact", effectdata )
	self.Entity:EmitSound( "physics/glass/glass_bottle_break2.wav" )		
	self.Entity:Remove()
end

function ENT:PhysicsCollide(data,phys)

	if data.Speed > 50 then
		self.Entity:kaboom()
		self.Entity:EmitSound("physics/glass/glass_bottle_break1.wav")
	end
	
	if data.HitEntity:IsPlayer() and data.HitEntity != self.Owner then
		paininfo = DamageInfo()
			paininfo:SetDamage(5)
			paininfo:SetDamageType(DMG_CLUB)
			paininfo:SetAttacker(self.Entity:GetOwner())
			data.HitEntity:TakeDamageInfo(paininfo)
			local wep = data.HitEntity:GetActiveWeapon()
			wepCheck = string.find( wep:GetClass(), "meleearts" )
			data.HitEntity:EmitSound("physics/flesh/flesh_strider_impact_bullet2.wav")
			data.HitEntity:ViewPunch( Angle( -20, 0, 0 ) )
			if wepCheck then
				wep.NextStun = CurTime() + 2
			end

	end

	if data.HitEntity:IsNPC() then
		paininfo = DamageInfo()
			paininfo:SetDamage(5)
			paininfo:SetDamageType(DMG_SLASH)
			paininfo:SetAttacker(self.Entity:GetOwner())
			data.HitEntity:TakeDamageInfo(paininfo)
			data.HitEntity:LostEnemySound()
			data.HitEntity:ClearEnemyMemory()
			data.HitEntity:SetCondition( 11 )
			data.HitEntity:SetSchedule( 40 )
			
	end
	
end

end

--[[if CLIENT then
function ENT:Initialize()
		self.cmodel = ClientsideModel( "models/props_junk/garbage_metalcan001a.mdl" )
		self.cmodel:SetPos( self:GetPos() )
					local ang = self:GetAngles()
			        ang:RotateAroundAxis(ang:Right(), 0)
			        ang:RotateAroundAxis(ang:Up(), 90)
				    ang:RotateAroundAxis(ang:Forward(), 0)
		self.cmodel:SetParent( self )
		self.cmodel:SetAngles( ang )
		
end

function ENT:OnRemove()
	self.cmodel:Remove()
end

function ENT:Draw()
end
end]]--
