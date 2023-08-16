ENT.Type = "anim"
ENT.PrintName			= "Firecracker"
ENT.Author			= "danguyen"
ENT.Contact			= "sdfgsdfgsg"
ENT.Purpose			= "sdfgdfsgsdfgsdfg"
ENT.Instructions			= "sdfgsdfgsdfgfdsg"

if SERVER then
AddCSLuaFile( "shared.lua" )

function ENT:Initialize()

	self.Owner = self.Entity.Owner
	
	self.Entity:SetModel("models/models/danguyen/tabscrusaderknightsword.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow( true )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )
	self.Entity:SetModelScale(1)
	self.Entity:SetMaterial("dev/white")
	self.Entity:SetNWBool("debounce",false)
	self:SetAngles(self:GetAngles()+Angle(0,0,90))
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
	phys:Wake()
	phys:SetMass(1)
	phys:AddAngleVelocity(phys:GetAngleVelocity()+Vector(0,0,-1500))
	phys:EnableGravity( false )
	end
	self.timeleft = CurTime() + 0.6
	self:Think()

end

 function ENT:Think()
	
	if self.timeleft < CurTime() and self.Entity:GetNWBool("debounce") == false then
		self:kaboom()	
		self.Entity:SetNWBool("debounce",true)
	end
	



	self.Entity:NextThink( CurTime() )
	return true
end

function ENT:kaboom()
	local effectdata = EffectData() 
	effectdata:SetOrigin( self:GetPos() ) 
	effectdata:SetNormal( self:GetPos():GetNormal() ) 
	effectdata:SetEntity( self ) 
	util.Effect( "cball_explode", effectdata ) 	
	util.Effect( "cball_bounce", effectdata ) 	
	self.Entity:EmitSound("weapons/physcannon/energy_bounce2.wav")
	self.Entity:Remove()
end

function ENT:PhysicsCollide(data,phys)

	if data.Speed > 50 then
		self:kaboom()
	end
	
	if data.HitEntity:IsPlayer() and data.HitEntity != self.Owner then
		self:kaboom()
		paininfo = DamageInfo()
			paininfo:SetDamage(30)
			paininfo:SetDamageType(1024)
			paininfo:SetAttacker(self.Entity:GetOwner())
			data.HitEntity:EmitSound("ambient/machines/slicer4.wav")
			data.HitEntity:TakeDamageInfo(paininfo)
			
			local effectdata = EffectData() 
			local blood = data.HitEntity:GetBloodColor()
			effectdata:SetColor(blood)
			effectdata:SetOrigin( self.Entity:GetPos() ) 
			effectdata:SetNormal( data.HitEntity:GetPos():GetNormal() ) 
			effectdata:SetEntity( data.HitEntity ) 
			effectdata:SetAttachment(5)
			if data.HitEntity:GetBloodColor()==0 then
				util.Effect( "bloodsplat", effectdata )
			else
				util.Effect( "bloodsplatyellow", effectdata )
			end
			util.Effect( "BloodImpact", effectdata ) 
	end

	if data.HitEntity:IsNPC() then
		self:kaboom()
		paininfo = DamageInfo()
			paininfo:SetDamage(30)
			paininfo:SetDamageType(1024)
			paininfo:SetAttacker(self.Entity:GetOwner())
			data.HitEntity:EmitSound("ambient/machines/slicer4.wav")
			data.HitEntity:TakeDamageInfo(paininfo)
			
			local effectdata = EffectData() 
			local blood = data.HitEntity:GetBloodColor()
			effectdata:SetColor(blood)
			effectdata:SetOrigin( self.Entity:GetPos() ) 
			effectdata:SetNormal( data.HitEntity:GetPos():GetNormal() ) 
			effectdata:SetEntity( data.HitEntity ) 
			effectdata:SetAttachment(5)
			if data.HitEntity:GetBloodColor()==0 then
				util.Effect( "bloodsplat", effectdata )
			else
				util.Effect( "bloodsplatyellow", effectdata )
			end
			util.Effect( "BloodImpact", effectdata ) 
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
