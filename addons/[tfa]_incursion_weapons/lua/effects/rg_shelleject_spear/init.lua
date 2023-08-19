
function EFFECT:Init( data )
	
	local angle, pos = self.Entity:GetBulletEjectPos( data:GetOrigin(), data:GetEntity(), data:GetAttachment() )
	
	local direction = angle:Forward()
	local ang = LocalPlayer():GetAimVector():Angle()

	self.Entity:SetPos( pos )
	self.Entity:SetModel( "models/props_junk/harpoon002a.mdl" )
	local Low, High = self.Entity:WorldSpaceAABB()
	
	self.Entity:SetModelScale( Vector( .2, .2, .2 ) )
	self.Entity:PhysicsInitBox( Vector(-1,-0.2,-0.2), Vector(1,0.2,0.2) )

	self.Entity:SetCollisionGroup( COLLISION_GROUP_PLAYER )
	self.Entity:SetCollisionBounds( Low, High )
	
	local phys = self.Entity:GetPhysicsObject()
	if IsValid( phys ) then
		self.Entity:SetAngles( ang )
		phys:Wake()
		phys:SetVelocity( LocalPlayer():GetVelocity() + direction * math.random(100,200)  )
		phys:AddAngleVelocity((VectorRand() * 2500))
		phys:SetMaterial( "gmod_silent" )
		self.Entity.LastVel = phys:GetVelocity()
	
	end
	
	self.Shell = self.Entity
	
	self.HitSound = ( "player/pl_shell" .. math.random(1, 3) .. ".wav" )
	self.HitPitch = math.random( 80, 100 )

	self.LifeTime = CurTime() + 10
	self.Alpha = 255
	self.CandSound = true
	self.ReboundTime = CurTime() + 0.1
	
	self.Normal = data:GetNormal()
	
	self.Forward = self.Normal:Angle():Right()
	self.Angle = self.Forward:Angle()
	
	local emitter = ParticleEmitter(pos)
	local AddVel = data:GetEntity():GetOwner():GetVelocity()
		
	for i=1,4 do
		local particle = emitter:Add("particle/particle_smokegrenade", pos)
		particle:SetVelocity(10*i*self.Forward + 1.02*AddVel)
		particle:SetDieTime(math.Rand(0.4,0.7))
		particle:SetStartAlpha(math.Rand(150,250))
		particle:SetStartSize(math.random(0.5,1))
		particle:SetEndSize(math.Rand(2.5,5))
		particle:SetRoll(math.Rand(180,480))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetColor(245,245,245)
		particle:SetLighting(true)
		particle:SetAirResistance(200)
	end

	if math.random(1,4) == 1 then
		for i=1,2 do
			local particle = emitter:Add("effects/muzzleflash"..math.random(1,4), pos)
			particle:SetVelocity(30*i*self.Forward + AddVel)
			particle:SetGravity(AddVel)
			particle:SetDieTime(0.1)
				particle:SetStartAlpha(250)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.random(0.1,0.5))
			particle:SetEndSize(math.random(1,1.5))
			particle:SetRoll(math.Rand(180,480))
			particle:SetRollDelta(math.Rand(-1,1))
			particle:SetColor(255,255,255)	
		end
			
		for i = 1, 3 do
			local particle = emitter:Add("effects/yellowflare", pos)
			particle:SetVelocity(math.Rand( 30, 40 ) * self.Forward + VectorRand() * 20 )
			particle:SetDieTime(math.Rand(0.1, 0.3))
			particle:SetStartAlpha(255)
			particle:SetStartSize(1)
			particle:SetEndSize(0)
			particle:SetRoll(0)
			particle:SetGravity(Vector(0, 0, 0))
			particle:SetCollide(true)
			particle:SetBounce(0.8)
			particle:SetAirResistance(160)
			particle:SetStartLength(0)
			particle:SetEndLength(0.1)
			particle:SetVelocityScale(true)
			particle:SetCollide(true)
		end
			
	end
	
	emitter:Finish()
	
end

function EFFECT:GetBulletEjectPos( Position, Ent, Attachment )

	if (!Ent:IsValid()) then return Angle(), Position end
	if (!Ent:IsWeapon()) then return Angle(), Position end

	// Shoot from the viewmodel
	if ( Ent:IsCarriedByLocalPlayer() && GetViewEntity() == LocalPlayer() ) then
	
		local ViewModel = LocalPlayer():GetViewModel()
		
		if ( ViewModel:IsValid() ) then
			
			local att = ViewModel:GetAttachment( Attachment )
			if ( att ) then
				return att.Ang, att.Pos
			end
			
		end
	
	// Shoot from the world model
	else
	    
		local WorldPos = (WorldPos or 0)
		local WorldAng = (WorldAngor or 0)
		
		WorldPos = Ent:GetAttachment(self.Attachment)
		if not WorldPos then return end
		
		self.Forward = self.Normal:Angle():Right()
		self.Angle = self.Forward:Angle()
		Position = WorldPos.Pos - (0.5*Ent:BoundingRadius())*WorldPos.Ang:Forward()

        return Angle(), Position		
	
	end

	return Angle(), Position

end

function EFFECT:Think( )

	if self.RemoveMe then return false end
	local phys = self.Entity:GetPhysicsObject()
	
	if self.LifeTime < CurTime() then
	
		self.Alpha = ( self.Alpha or 255 ) - 2
		self.Entity:SetColor( 255, 255, 255, self.Alpha )
		
	end
	
	local tr = {}
	tr.start = self.Entity:GetPos()
	tr.endpos = self.Entity:GetPos() + Vector(0,0, -10)
	tr.filter = self.Entity
	tr.mask = MASK_SHOT
	local trace = util.TraceLine( tr )
	
	if !trace.Hit then
		self.Currentvel = phys:GetVelocity()
	end
	

	if trace.Hit and trace.Entity:IsWorld() and self.CandSound and self.Currentvel then
		self.CandSound = nil
		Sound( self.HitSound, self.Entity:GetPos(), 75, self.HitPitch ) 
		phys:SetVelocity( self.Entity.LastVel + ( VectorRand() * 50 + Vector(0,0,self.Currentvel:Length() / 10)) )
		phys:AddAngleVelocity( ( VectorRand() * math.random(1000,10000) ) )
		self.ReboundTime = CurTime() + 0.5
	elseif !trace.Hit and self.CandSound == nil and self.ReboundTime and self.ReboundTime < CurTime() then
		self.Entity.LastVel = phys:GetVelocity()
		self.CandSound = true
	end

	return self.Alpha > 2 
	
end

function EFFECT:Render()

	self.Entity:DrawModel()

end