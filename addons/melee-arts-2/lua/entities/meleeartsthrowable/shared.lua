ENT.Type 			= "anim"
ENT.PrintName		= "MeleeArtsThrowable"
ENT.Author			= ""
ENT.Information		= "MeleeArtsThrowable"
ENT.Category		= "MeleeArts"

if SERVER then

AddCSLuaFile( "shared.lua" )

function ENT:Initialize()

	self.Owner = self.Entity.Owner

	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow( true )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )
	self:SetAngles(self:GetAngles()+self.Entity:GetNWAngle( 'anglefix' ))
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:AddAngleVelocity(phys:GetAngleVelocity()+self.Entity:GetNWVector( 'spinvector' ))
		phys:Wake()
		--phys:SetDragCoefficient( 0 ) makes throwing ridiculous... might renable in the future
		phys:SetMass(1)
	end
	self.Entity:SetNWBool("active",true)
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
	if (activator:IsPlayer() and self.Entity:GetNWBool("active")==false) then
		if activator:HasWeapon(self.Entity:GetNWInt( 'weaponname' )) then
			activator:PrintMessage(HUD_PRINTTALK,"You already have this weapon!")
		return end
		activator:Give(self.Entity:GetNWInt( 'weaponname' ))
		if self.Entity:GetNWInt( 'weaponname' )=="meleearts_gun" then
			activator:GetWeapon("meleearts_gun"):SetClip1(self.Entity:GetNWInt( 'gunammo' ))
		end
		self.Entity:Remove()
	end
end

function ENT:PhysicsCollide(data,phys)

	if data.Speed > 2 then
		local w = math.random(1)
		w = math.random(1,2)
		if w == 1 and self.Entity:GetNWBool("active")==true then  
			self.Entity:EmitSound( self.Entity:GetNWInt( 'impact1sound' ),60)
		elseif w == 2 and self.Entity:GetNWBool("active")==true then
			self.Entity:EmitSound( self.Entity:GetNWInt( 'impact2sound' ),60)
		end
		if self.Entity:GetNWBool("active")==true then
			timer.Simple(.1, function()
				self.Entity:SetNWBool("active",false)
			end)
		end
	end
	self:PhyHitDamn()


	if data.HitEntity:IsPlayer() or data.HitEntity:IsNPC() then
		if self.Entity:GetNWBool("active")==false then return end
		local dmginfo = DamageInfo()

		local attacker = self.Entity:GetOwner()
		if ( !IsValid( attacker ) ) then attacker = self end
		dmginfo:SetAttacker( attacker )
		dmginfo:SetDamageType(4)
		dmginfo:SetInflictor( self )
		dmginfo:SetDamage( self.Entity:GetNWInt( 'throwdamage' ) )
		dmginfo:SetDamageForce( self.Owner:GetForward() * 5000 )
		
		data.HitEntity:TakeDamageInfo( dmginfo )
		
		if data.Speed > 2 then
			local w = math.random(1)
			w = math.random(1,2)
			if w == 1 then  
				self.Entity:EmitSound( self.Entity:GetNWInt( 'impact1sound' ),60)
			elseif w == 2 then
				self.Entity:EmitSound( self.Entity:GetNWInt( 'impact2sound' ),60)
			end
			timer.Simple(.1, function()
				self.Entity:SetNWBool("active",false)
			end)
		end
		
		if data.HitEntity:GetBloodColor()~=-1 then
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
			else
				local effectdata = EffectData() 
				effectdata:SetOrigin( self.Entity:GetPos() ) 
				effectdata:SetNormal( data.HitEntity:GetPos():GetNormal() ) 
				effectdata:SetEntity( data.HitEntity ) 
				effectdata:SetAttachment(5)
				util.Effect( "MetalSpark", effectdata)
			end
		local w = math.random(1)
		w = math.random(1,3)
		if w == 1 then  
			self.Entity:EmitSound( self.Entity:GetNWInt( 'hit1sound' ))
		elseif w == 2 then
			self.Entity:EmitSound( self.Entity:GetNWInt( 'hit2sound' ))
		elseif w == 3 then
			self.Entity:EmitSound( self.Entity:GetNWInt( 'hit3sound' ))
		end
		self.Entity:SetNWBool("active",false)
	end

	--local impulse = -data.Speed * data.HitNormal * 0.9 + (data.OurOldVelocity * -0.7)
--	phys:ApplyForceCenter(impulse)
	
end

end