function EFFECT:Init(data)
	
	//self.Position = self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)
	self.Position = data:GetOrigin()
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	
	local light = DynamicLight( 0 )
	if( light ) then	
		light.Pos = self:GetPos()
		light.Size = 50
		light.Decay = 200
		light.R = 255
		light.G = 0		
		light.B = 0
		light.Brightness = 1
		light.DieTime = CurTime() + 0.4
	end
	
	local AddVel = 5//self.WeaponEnt:GetOwner():GetVelocity()
	local emitter = ParticleEmitter(self.Position)

	
	
for i=1, 1 do
	if emitter != nil then	
		local particle = emitter:Add( "effects/yellowflare", self.Position, (Color(255,0,0,255)) )
		if particle != nil then

			particle:SetVelocity( 0 * VectorRand() + 0 * VectorRand() + 0 * VectorRand() )
			--particle:SetGravity( Vector( 0, 0, -50 ) )
			--particle:SetAirResistance( 90 )
			particle:SetColor( 255,0,0 )

			particle:SetDieTime( 0.3 )

			particle:SetStartSize( 20 )
			particle:SetEndSize( 1 )
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