function EFFECT:Init(data)
	
	//self.Position = self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)
	self.Position = data:GetOrigin()
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	
	local AddVel = 5//self.WeaponEnt:GetOwner():GetVelocity()
	local emitter = ParticleEmitter(self.Position)
	
for i=0, 25 do
	if emitter != nil then	
		local particle = emitter:Add( "effects/splashwake1", self.Position, (Color(0,0,0,25)) )
		if particle != nil then

			particle:SetVelocity( 4 * VectorRand() + 4 * VectorRand() + 4 * VectorRand() )
			particle:SetGravity( Vector( 0, 0, -20 ) )
			particle:SetAirResistance( 0 )
			particle:SetColor(0, 0, 0,255)

			particle:SetDieTime( 5 )

			particle:SetStartSize( 5 )
			particle:SetEndSize( 20 )

			particle:SetRoll( 360 )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetBounce( 0 )
			particle:SetCollide( true )
		end
	
	end
end

	
for i=0, 25 do
	if emitter != nil then	
		local particle = emitter:Add( "effects/splash1", self.Position, (Color(0,0,0,25)) )
		if particle != nil then

			particle:SetVelocity( 8 * VectorRand() + 8 * VectorRand() + 8 * VectorRand() )
			particle:SetGravity( Vector( 0, 0, -20 ) )
			particle:SetAirResistance( 0 )
			particle:SetColor(0, 0, 0,255)

			particle:SetDieTime( 4 )

			particle:SetStartSize( 5 )
			particle:SetEndSize( 13 )

			particle:SetRoll( 360 )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetBounce( 0 )
			particle:SetCollide( true )
		end
	
	end
end

emitter:Finish()
end
//end

function EFFECT:Think()

	return false
end


function EFFECT:Render()
end