function EFFECT:Init( data )
	
	local vOffset = data:GetOrigin()
		self.Origin = data:GetOrigin()
	self.DirVec = data:GetNormal()
	self.Scale = data:GetScale()
		self.Magnitude = data:GetMagnitude()
	self.Emitter = ParticleEmitter( self.Origin )

	local emitter = ParticleEmitter( vOffset )

				for i=1,5 do 
			local Flash = self.Emitter:Add( "particles/dlc03fxteslacorestreams02", self.Origin )
			if (Flash) then
				Flash:SetVelocity( VectorRand()*50 )
				Flash:SetAirResistance( 200 )
				Flash:SetDieTime( 1 )
				Flash:SetStartAlpha( 1000 )
				Flash:SetEndAlpha( 0 )
				Flash:SetStartSize( 400 )
				Flash:SetEndSize( 0 )
				Flash:SetRoll( math.Rand(180,480) )
				Flash:SetGravity( Vector( math.Rand(-100, 100) * self.Scale, math.Rand(-100, 100) * self.Scale, math.Rand(0, -100) ) ) 	
				Flash:SetRollDelta( math.Rand(-2,2) )
				Flash:SetColor(255,255,255)	
			end
		end


		for i=1,2 do 
			local particle = emitter:Add( "particle/dlc03plasmaeffect01", vOffset )

				particle:SetVelocity( 10 * data:GetNormal() )
				particle:SetAirResistance( 600 )

				particle:SetDieTime( 1 )

				particle:SetStartAlpha( math.Rand(0, 55) )
				particle:SetEndAlpha( 0 )

				particle:SetStartSize( 40 * i )
				particle:SetEndSize( 5 * i )

				particle:SetRoll( math.Rand(180,480) )
				particle:SetRollDelta( math.Rand(-1,1) )

				particle:SetColor(255,255,255)	
				particle:SetGravity( Vector( math.Rand(-100, 100) * self.Scale, math.Rand(-100, 100) * self.Scale, math.Rand(0, -100) ) ) 		
		end
		
	
			local particle = emitter:Add( "particle/dlc03plasmaeffect01", vOffset )

				particle:SetVelocity( 80 * data:GetNormal() + 20 * VectorRand() )
				particle:SetAirResistance( 200 )

				particle:SetDieTime( math.Rand(0.2, 1) )
				particle:SetStartAlpha( math.Rand(0, 55) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.random(200,400) )
				particle:SetEndSize( 3 )

				particle:SetColor(255,255,255)	
				particle:SetRoll( math.Rand(180,480) )
				particle:SetRollDelta( math.Rand(-1,1) )

	emitter:Finish()
	
end

function EFFECT:Think()
return false
end

function EFFECT:Render()

end