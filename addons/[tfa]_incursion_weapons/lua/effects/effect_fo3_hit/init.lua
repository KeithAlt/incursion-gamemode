 function EFFECT:Init( data ) 
	
	self.Origin = data:GetOrigin()
	self.DirVec = data:GetNormal()
	self.Scale = 1
	self.Emitter = ParticleEmitter( self.Origin )

		Sound( "bulletimpact/metalsolid/fx_bullet_impact_metalsolid_0"..math.random(1,10)..".wav", self.Origin,75, 100)
		
	for i=0, 15*self.Scale do
	
		local Smoke = self.Emitter:Add( "particles/Dirt", self.Origin )
		if (Smoke) then
			Smoke:SetVelocity( self.DirVec * math.random( 0,500*self.Scale) + VectorRand():GetNormalized()*100*self.Scale )
			Smoke:SetDieTime( math.Rand( 1 , 2.5 )*self.Scale )
			Smoke:SetStartAlpha( math.Rand( 50, 90 ) )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 12*self.Scale )
			Smoke:SetEndSize( 30*self.Scale )
			Smoke:SetRoll( math.Rand(150, 360) )
			Smoke:SetRollDelta( math.Rand(-2, 2) )			
			Smoke:SetAirResistance( 300 ) 			 
			Smoke:SetGravity( Vector( math.Rand(-70, 70) * self.Scale, math.Rand(-70, 70) * self.Scale, math.Rand(0, -100) ) ) 			
			Smoke:SetColor( 232,204,178 )
		end
	end

	for i=0, 10*self.Scale do
	
		local Smoke = self.Emitter:Add( "particle/particle_composite", self.Origin )
		if (Smoke) then
			Smoke:SetVelocity( self.DirVec * math.random( 0,400*self.Scale) + VectorRand():GetNormalized()*20*self.Scale )
			Smoke:SetDieTime( math.Rand( 0.5 , 1.5 )*self.Scale )
			Smoke:SetStartAlpha( 150 )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 20*self.Scale )
			Smoke:SetEndSize( 30*self.Scale )
			Smoke:SetRoll( math.Rand(150, 360) )
			Smoke:SetRollDelta( math.Rand(-2, 2) )			
			Smoke:SetAirResistance( 400 ) 			 
			Smoke:SetGravity( Vector( math.Rand(-50, 50) * self.Scale, math.Rand(-50, 50) * self.Scale, math.Rand(0, -100) ) ) 			
			Smoke:SetColor( 105,100,90 )
		end
	end

	for i=0, 10*self.Scale do
	
		local Debris = self.Emitter:Add( "effects/fleck_cement"..math.random(1,2), self.Origin )
		if (Debris) then
			Debris:SetVelocity ( self.DirVec * math.random(200,300*self.Scale) + VectorRand():GetNormalized() * 300*self.Scale )
			Debris:SetDieTime( math.random( 0.6, 1) )
			Debris:SetStartAlpha( 255 )
			Debris:SetEndAlpha( 0 )
			Debris:SetStartSize( math.random(2,5*self.Scale) )
			Debris:SetRoll( math.Rand(0, 360) )
			Debris:SetRollDelta( math.Rand(-5, 5) )			
			Debris:SetAirResistance( 50 ) 			 			
			Debris:SetColor( 105,100,90 )
			Debris:SetGravity( Vector( 0, 0, -600) ) 
			Debris:SetCollide( true )
			Debris:SetBounce( 1 )			
		end
	end
	
		for i=0,1 do 
			local Flash = self.Emitter:Add( "effects/muzzleflash"..math.random(1,4), self.Origin )
			if (Flash) then
				Flash:SetVelocity( self.DirVec*100 )
				Flash:SetAirResistance( 200 )
				Flash:SetDieTime( 0.1 )
				Flash:SetStartAlpha( 255 )
				Flash:SetEndAlpha( 0 )
				Flash:SetStartSize( math.Rand( 30, 40 )*self.Scale )
				Flash:SetEndSize( 0 )
				Flash:SetRoll( math.Rand(180,480) )
				Flash:SetRollDelta( math.Rand(-1,1) )
				Flash:SetColor(255,255,255)	
			end
		end

 end 
   
   
/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	return false
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()
end