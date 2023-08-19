
   
 /*--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------*/ 
 function EFFECT:Init( data ) 
	
	self.Origin = data:GetOrigin()
	self.Scale = data:GetScale()
	self.Magnitude = data:GetMagnitude()
	self.Emitter = ParticleEmitter( self.Origin )

	sound.Play( "ambient/explosions/explode_" .. math.random(1, 4) .. ".wav", self.Origin, 75, 100, 1 )
		
	for i=0, 40*self.Scale do
	
		local Smoke = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.Origin )
		if (Smoke) then
		Smoke:SetVelocity( VectorRand():GetNormalized()*math.Rand(500, 1500)*self.Scale )
		Smoke:SetDieTime( math.Rand( 1 , 3 )*self.Scale )
		Smoke:SetStartAlpha( math.Rand( 100, 120 ) )
		Smoke:SetEndAlpha( 0 )
		Smoke:SetStartSize( 70*self.Scale )
		Smoke:SetEndSize( math.Rand(100, 130)*self.Scale )
		Smoke:SetRoll( math.Rand(0, 360) )
		Smoke:SetRollDelta( math.Rand(-2, 2) )			
		Smoke:SetAirResistance( 400 ) 			 		
		Smoke:SetColor( 60,60,60 )
		end
		end
	

		for i=0, 40*self.Scale do
		local Shrapnel = self.Emitter:Add( "effects/fleck_cement"..math.random(1,2), self.Origin )
		if (Shrapnel) then
		Shrapnel:SetVelocity ( VectorRand():GetNormalized()*math.Rand(3000, 5000)*self.Scale )
		Shrapnel:SetDieTime( math.random( 0.3, 0.6) )
		Shrapnel:SetStartAlpha( 255 )
		Shrapnel:SetEndAlpha( 0 )
		Shrapnel:SetStartSize( math.random(4,7*self.Scale) )
		Shrapnel:SetRoll( math.Rand(0, 360) )
		Shrapnel:SetRollDelta( math.Rand(-5, 5) )			
		Shrapnel:SetAirResistance( 20 ) 			 			
		Shrapnel:SetColor( 53,50,45 )
		Shrapnel:SetGravity( Vector( 0, 0, -600) ) 		
		end
		end

		for i=1,3 do 
		local Flash = self.Emitter:Add( "effects/muzzleflash"..math.random(1,4), self.Origin )
		if (Flash) then
		Flash:SetVelocity( VectorRand() )
		Flash:SetAirResistance( 200 )
		Flash:SetDieTime( 0.1 )
		Flash:SetStartAlpha( 255 )
		Flash:SetEndAlpha( 0 )
		Flash:SetStartSize( self.Magnitude*10 )
		Flash:SetEndSize( 0 )
		Flash:SetRoll( math.Rand(180,480) )
		Flash:SetRollDelta( math.Rand(-1,1) )
		Flash:SetColor(255,255,255)	
		end
		end

		for i=1,1 do 
		local Shockwave = self.Emitter:Add( "sprites/heatwave", self.Origin )
		if (Shockwave) then
		Shockwave:SetVelocity( VectorRand() )
		Shockwave:SetAirResistance( 200 )
		Shockwave:SetDieTime( 0.07 )
		Shockwave:SetStartAlpha( 255 )
		Shockwave:SetEndAlpha( 0 )
		Shockwave:SetStartSize( self.Magnitude*25 )
		Shockwave:SetEndSize( self.Magnitude*20 )
		Shockwave:SetRoll( math.Rand(180,480) )
		Shockwave:SetRollDelta( math.Rand(-1,1) )
		Shockwave:SetColor(255,255,255)	
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

 