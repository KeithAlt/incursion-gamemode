
					//Sound,Impact

					// 1        2       3      4      5
					//Dirt, Concrete, Metal, Glass, Flesh

					// 1     2     3      4      5      6      7      8         9
					//Dust, Dirt, Sand, Metal, Smoke, Wood,  Glass, Blood, YellowBlood
local mats={				
	[MAT_ALIENFLESH]		={5,9},
	[MAT_ANTLION]			={5,9},
	[MAT_BLOODYFLESH]		={5,8},
	[MAT_CLIP]			={3,5},
	[MAT_COMPUTER]			={4,5},
	[MAT_FLESH]			={5,8},
	[MAT_GRATE]			={3,4},
	[MAT_METAL]			={3,4},
	[MAT_PLASTIC]			={2,5},
	[MAT_SLOSH]			={5,5},
	[MAT_VENT]			={3,4},
	[MAT_FOLIAGE]			={1,5},
	[MAT_TILE]			={2,5},
	[MAT_CONCRETE]			={2,1},
	[MAT_DIRT]			={1,2},
	[MAT_SAND]			={1,3},
	[MAT_WOOD]			={2,6},
	[MAT_GLASS]			={4,7},
}

local sounds={
	[1]={"Bullet.Dirt",},
	[2]={"Bullet.Concrete",},
	[3]={"Bullet.Metal",},
	[4]={"Bullet.Glass",},
	[5]={"Bullet.Flesh",},
}

function EFFECT:Init(data)
	self.Origin = data:GetOrigin()
	self.DirVec = data:GetNormal()
	self.Scale  = data:GetScale()
	self.Radius = data:GetRadius()
	self.Emitter = ParticleEmitter( self.Origin )

	self.Mat=math.ceil(self.Radius)


	
	if(self.Mat != nil)then
		if     mats[self.Mat][2]==1 then	self:Dust()	
		elseif mats[self.Mat][2]==2 then	self:Dirt()
		elseif mats[self.Mat][2]==3 then	self:Sand()
		elseif mats[self.Mat][2]==4 then	self:Metal()
		elseif mats[self.Mat][2]==5 then	self:Smoke()
		elseif mats[self.Mat][2]==6 then	self:Wood()
		elseif mats[self.Mat][2]==7 then	self:Glass()
		elseif mats[self.Mat][2]==8 then	self:Blood()
		elseif mats[self.Mat][2]==9 then	self:YellowBlood()
		else 					self:Smoke()
		end
	else
		self:Dirt()
	end
end
 
 function EFFECT:Dust()
	sound.Play( "Bullet.Impact", self.Origin)
	self.Emitter = ParticleEmitter( self.Origin )
		
	for i=0, 15*self.Scale do
		local Smoke = self.Emitter:Add( "particles/smokey", self.Origin )
		if (Smoke) then
		Smoke:SetVelocity( self.DirVec * math.random( 0,500*self.Scale) + VectorRand():GetNormalized()*100*self.Scale )
		Smoke:SetDieTime( math.Rand( 1 , 2.5 )*self.Scale )
		Smoke:SetStartAlpha( math.Rand( 80, 100 ) )
		Smoke:SetEndAlpha( 0 )
		Smoke:SetStartSize( 12*self.Scale )
		Smoke:SetEndSize( 30*self.Scale )
		Smoke:SetRoll( math.Rand(150, 360) )
		Smoke:SetRollDelta( math.Rand(-2, 2) )			
		Smoke:SetAirResistance( 300 ) 			 
		Smoke:SetGravity( Vector( math.Rand(-70, 70) * self.Scale, math.Rand(-70, 70) * self.Scale, math.Rand(0, -100) ) ) 			
		Smoke:SetColor( 130,125,115 )
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
 
 function EFFECT:Dirt()
		sound.Play( "Bullet.Impact", self.Origin)
	self.Emitter = ParticleEmitter( self.Origin )
		
	for i=0, 15*self.Scale do
		local Smoke = self.Emitter:Add( "particles/smokey", self.Origin )
		if (Smoke) then
		Smoke:SetVelocity( self.DirVec * math.random( 0,500*self.Scale) + VectorRand():GetNormalized()*100*self.Scale )
		Smoke:SetDieTime( math.Rand( 1 , 2.5 )*self.Scale )
		Smoke:SetStartAlpha( math.Rand( 80, 100 ) )
		Smoke:SetEndAlpha( 0 )
		Smoke:SetStartSize( 12*self.Scale )
		Smoke:SetEndSize( 30*self.Scale )
		Smoke:SetRoll( math.Rand(150, 360) )
		Smoke:SetRollDelta( math.Rand(-2, 2) )			
		Smoke:SetAirResistance( 300 ) 			 
		Smoke:SetGravity( Vector( math.Rand(-70, 70) * self.Scale, math.Rand(-70, 70) * self.Scale, math.Rand(0, -100) ) ) 			
		Smoke:SetColor( 90,85,75 )
		end
	end

	for i=0, 10*self.Scale do
		local Smoke = self.Emitter:Add( "particle/particle_composite", self.Origin )
		if (Smoke) then
		Smoke:SetVelocity( self.DirVec * math.random( 0,400*self.Scale) + VectorRand():GetNormalized()*20*self.Scale )
		Smoke:SetDieTime( math.Rand( 0.5 , 1.5 )*self.Scale )
		Smoke:SetStartAlpha( 200 )
		Smoke:SetEndAlpha( 0 )
		Smoke:SetStartSize( 20*self.Scale )
		Smoke:SetEndSize( 30*self.Scale )
		Smoke:SetRoll( math.Rand(150, 360) )
		Smoke:SetRollDelta( math.Rand(-2, 2) )			
		Smoke:SetAirResistance( 400 ) 			 
		Smoke:SetGravity( Vector( math.Rand(-50, 50) * self.Scale, math.Rand(-50, 50) * self.Scale, math.Rand(0, -100) ) ) 			
		Smoke:SetColor( 90,85,75 )
		end
	end

	for i=0, 15*self.Scale do
		local Debris = self.Emitter:Add( "effects/fleck_cement"..math.random(1,2), self.Origin )
		if (Debris) then
		Debris:SetVelocity ( self.DirVec * math.random(200,300*self.Scale) + VectorRand():GetNormalized() * 300*self.Scale )
		Debris:SetDieTime( math.random( 0.75, 1.25) )
		Debris:SetStartAlpha( 255 )
		Debris:SetEndAlpha( 0 )
		Debris:SetStartSize( math.random(3,7*self.Scale) )
		Debris:SetRoll( math.Rand(0, 360) )
		Debris:SetRollDelta( math.Rand(-5, 5) )			
		Debris:SetAirResistance( 50 ) 			 			
		Debris:SetColor( 90,85,75 )
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
			Flash:SetStartSize( math.Rand( 10, 20 )*self.Scale )
			Flash:SetEndSize( 0 )
			Flash:SetRoll( math.Rand(180,480) )
			Flash:SetRollDelta( math.Rand(-1,1) )
			Flash:SetColor(255,255,255)	
			end
		end
 end

 function EFFECT:Sand()
		sound.Play( "Bullet.Impact", self.Origin)
	self.Emitter = ParticleEmitter( self.Origin )
		
	for i=0, 15*self.Scale do
		local Smoke = self.Emitter:Add( "particles/smokey", self.Origin )
		if (Smoke) then
		Smoke:SetVelocity( self.DirVec * math.random( 0,500*self.Scale) + VectorRand():GetNormalized()*100*self.Scale )
		Smoke:SetDieTime( math.Rand( 1 , 2.5 )*self.Scale )
		Smoke:SetStartAlpha( math.Rand( 60, 80 ) )
		Smoke:SetEndAlpha( 0 )
		Smoke:SetStartSize( 12*self.Scale )
		Smoke:SetEndSize( 30*self.Scale )
		Smoke:SetRoll( math.Rand(150, 360) )
		Smoke:SetRollDelta( math.Rand(-2, 2) )			
		Smoke:SetAirResistance( 300 ) 			 
		Smoke:SetGravity( Vector( math.Rand(-70, 70) * self.Scale, math.Rand(-70, 70) * self.Scale, math.Rand(0, -100) ) ) 			
		Smoke:SetColor( 120,110,90 )
		end
	end

	for i=0, 20*self.Scale do
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
		Smoke:SetColor( 120,110,90 )
		end
	end

	
 end

 function EFFECT:Metal()
			sound.Play( "Bullet.Impact", self.Origin)
	self.Emitter = ParticleEmitter( self.Origin )
		
	for i=0, 15*self.Scale do
		local Smoke = self.Emitter:Add( "particle/smokestack", self.Origin )
		if (Smoke) then
		Smoke:SetVelocity( self.DirVec * math.random( 0,50*self.Scale) + VectorRand():GetNormalized()*200*self.Scale )
		Smoke:SetDieTime( math.Rand( 3 , 7 )*self.Scale )
		Smoke:SetStartAlpha( math.Rand( 50, 70 ) )
		Smoke:SetEndAlpha( 0 )
		Smoke:SetStartSize( 20*self.Scale )
		Smoke:SetEndSize( 40*self.Scale )
		Smoke:SetRoll( math.Rand(150, 360) )
		Smoke:SetRollDelta( math.Rand(-2, 2) )			
		Smoke:SetAirResistance( 300 ) 			 
		Smoke:SetGravity( Vector( math.Rand(-70, 70) * self.Scale, math.Rand(-70, 70) * self.Scale, math.Rand(0, -100) ) ) 			
		Smoke:SetColor( 100,100,100 )
		end
	end
	
		for i=0,3 do 
			local Flash = self.Emitter:Add( "effects/muzzleflash"..math.random(1,4), self.Origin )
			if (Flash) then
			Flash:SetVelocity( self.DirVec*100 )
			Flash:SetAirResistance( 200 )
			Flash:SetDieTime( 0.1 )
			Flash:SetStartAlpha( 255 )
			Flash:SetEndAlpha( 0 )
			Flash:SetStartSize( math.Rand( 20, 30 )*self.Scale^2 )
			Flash:SetEndSize( 0 )
			Flash:SetRoll( math.Rand(180,480) )
			Flash:SetRollDelta( math.Rand(-1,1) )
			Flash:SetColor(255,255,255)	
			end
		end

 	 
 		for i=0, 20*self.Scale do 
 			local particle = self.Emitter:Add( "effects/spark", self.Origin ) 
 			if (particle) then 
 			particle:SetVelocity( ((self.DirVec*0.75)+VectorRand()) * math.Rand(50, 300)*self.Scale ) 
 			particle:SetDieTime( math.Rand(0.3, 0.5) ) 				 
 			particle:SetStartAlpha( 255 )  				 
 			particle:SetStartSize( math.Rand(4, 6)*self.Scale ) 
 			particle:SetEndSize( 0 ) 				 
 			particle:SetRoll( math.Rand(0, 360) ) 
 			particle:SetRollDelta( math.Rand(-5, 5) ) 				 
 			particle:SetAirResistance( 20 ) 
 			particle:SetGravity( Vector( 0, 0, -600 ) ) 
 			end 
			
		end 

end


 function EFFECT:Smoke()
		sound.Play( "Bullet.Impact", self.Origin)
	self.Emitter = ParticleEmitter( self.Origin )
		
	for i=0, 15*self.Scale do
		local Smoke = self.Emitter:Add( "particle/smokestack", self.Origin )
		if (Smoke) then
		Smoke:SetVelocity( self.DirVec * math.random( 20,70*self.Scale) + VectorRand():GetNormalized()*150*self.Scale )
		Smoke:SetDieTime( math.Rand( 3 , 7 )*self.Scale )
		Smoke:SetStartAlpha( math.Rand( 50, 70 ) )
		Smoke:SetEndAlpha( 0 )
		Smoke:SetStartSize( 20*self.Scale )
		Smoke:SetEndSize( 50*self.Scale )
		Smoke:SetRoll( math.Rand(150, 360) )
		Smoke:SetRollDelta( math.Rand(-2, 2) )			
		Smoke:SetAirResistance( 200 ) 			 
		Smoke:SetGravity( Vector( math.Rand(-70, 70) * self.Scale, math.Rand(-70, 70) * self.Scale, math.Rand(-70, 70) ) ) 			
		Smoke:SetColor( 100,100,100 )
		end
	end

	for i=0, 15*self.Scale do
		local Debris = self.Emitter:Add( "effects/fleck_tile"..math.random(1,2), self.Origin )
		if (Debris) then
		Debris:SetVelocity ( self.DirVec * math.random(50,100*self.Scale) + VectorRand():GetNormalized() * 300*self.Scale )
		Debris:SetDieTime( math.random( 0.75, 1) )
		Debris:SetStartAlpha( 255 )
		Debris:SetEndAlpha( 0 )
		Debris:SetStartSize( math.random(1,3*self.Scale) )
		Debris:SetRoll( math.Rand(0, 360) )
		Debris:SetRollDelta( math.Rand(-5, 5) )			
		Debris:SetAirResistance( 50 ) 			 			
		Debris:SetColor( 90,85,75 )
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
			Flash:SetStartSize( math.Rand( 10, 20 )*self.Scale^2 )
			Flash:SetEndSize( 0 )
			Flash:SetRoll( math.Rand(180,480) )
			Flash:SetRollDelta( math.Rand(-1,1) )
			Flash:SetColor(255,255,255)	
			end
		end
 end

 function EFFECT:Wood()
		sound.Play( "Bullet.Impact", self.Origin)
	self.Emitter = ParticleEmitter( self.Origin )
		
	for i=0, 5*self.Scale do
		local Smoke = self.Emitter:Add( "particle/smokestack", self.Origin )
		if (Smoke) then
		Smoke:SetVelocity( self.DirVec * math.random( 20,70*self.Scale) + VectorRand():GetNormalized()*150*self.Scale )
		Smoke:SetDieTime( math.Rand( 3 , 7 )*self.Scale )
		Smoke:SetStartAlpha( math.Rand( 40, 60 ) )
		Smoke:SetEndAlpha( 0 )
		Smoke:SetStartSize( 20*self.Scale )
		Smoke:SetEndSize( 50*self.Scale )
		Smoke:SetRoll( math.Rand(150, 360) )
		Smoke:SetRollDelta( math.Rand(-2, 2) )			
		Smoke:SetAirResistance( 200 ) 			 
		Smoke:SetGravity( Vector( math.Rand(-70, 70) * self.Scale, math.Rand(-70, 70) * self.Scale, math.Rand(-70, 70) ) ) 			
		Smoke:SetColor( 100,100,100 )
		end
	end

	for i=0, 10*self.Scale do
		local Smoke = self.Emitter:Add( "particle/smokestack", self.Origin )
		if (Smoke) then
		Smoke:SetVelocity( self.DirVec * math.random( 20,70*self.Scale) + VectorRand():GetNormalized()*150*self.Scale )
		Smoke:SetDieTime( math.Rand( 3 , 7 )*self.Scale )
		Smoke:SetStartAlpha( math.Rand( 40, 60 ) )
		Smoke:SetEndAlpha( 0 )
		Smoke:SetStartSize( 20*self.Scale )
		Smoke:SetEndSize( 50*self.Scale )
		Smoke:SetRoll( math.Rand(150, 360) )
		Smoke:SetRollDelta( math.Rand(-2, 2) )			
		Smoke:SetAirResistance( 200 ) 			 
		Smoke:SetGravity( Vector( math.Rand(-70, 70) * self.Scale, math.Rand(-70, 70) * self.Scale, math.Rand(-70, 70) ) ) 			
		Smoke:SetColor( 90,85,75 )
		end
	end

	for i=0, 15*self.Scale do
		local Debris = self.Emitter:Add( "effects/fleck_wood"..math.random(1,2), self.Origin+self.DirVec )
		if (Debris) then
		Debris:SetVelocity ( self.DirVec * math.random(50,300*self.Scale) + VectorRand():GetNormalized() * 300*self.Scale )
		Debris:SetDieTime( math.random( 0.75, 1) )
		Debris:SetStartAlpha( 255 )
		Debris:SetEndAlpha( 0 )
		Debris:SetStartSize( math.random(3,6*self.Scale) )
		Debris:SetRoll( math.Rand(0, 360) )
		Debris:SetRollDelta( math.Rand(-5, 5) )			
		Debris:SetAirResistance( 50 ) 			 			
		Debris:SetColor( 90,85,75 )
		Debris:SetGravity( Vector( 0, 0, -600) ) 
		Debris:SetCollide( true )
		Debris:SetBounce( 0.5 )			
		end
	end

 end

 function EFFECT:Glass()

	
	for i=0, 10*self.Scale do
		local Debris = self.Emitter:Add( "effects/fleck_glass"..math.random(1,3), self.Origin+self.DirVec )
		if (Debris) then
		Debris:SetVelocity ( self.DirVec * math.random(50,200)*self.Scale + VectorRand():GetNormalized() * 60*self.Scale )
		Debris:SetDieTime( math.random( 1, 1.5) )
		Debris:SetStartAlpha( 255 )
		Debris:SetEndAlpha( 0 )
		Debris:SetStartSize( math.random(2,4*self.Scale) )
		Debris:SetRoll( math.Rand(0, 360) )
		Debris:SetRollDelta( math.Rand(-15, 15) )			
		Debris:SetAirResistance( 50 ) 			 			
		Debris:SetColor( 100,100,100 )
		Debris:SetGravity( Vector( 0, 0, -600) ) 
		Debris:SetCollide( true )
		Debris:SetBounce( 0.3 )			
		end
	end

	for i=0, 20*self.Scale do
		local Debris = self.Emitter:Add( "effects/fleck_glass"..math.random(1,3), self.Origin )
		if (Debris) then
		Debris:SetVelocity ( self.DirVec*-1 * math.random(50,300)*self.Scale + VectorRand():GetNormalized() * 60*self.Scale )
		Debris:SetDieTime( math.random( 0.5, 1) )
		Debris:SetStartAlpha( 255 )
		Debris:SetEndAlpha( 0 )
		Debris:SetStartSize( math.random(2,4*self.Scale) )
		Debris:SetRoll( math.Rand(0, 360) )
		Debris:SetRollDelta( math.Rand(-15, 15) )			
		Debris:SetAirResistance( 50 ) 			 			
		Debris:SetColor( 100,100,100 )
		Debris:SetGravity( Vector( 0, 0, -600) ) 	
		end
	end
 end

 function EFFECT:Blood()

	for i=0, 10*self.Scale do
		local Smoke = self.Emitter:Add( "particle/particle_composite", self.Origin )
		if (Smoke) then
		Smoke:SetVelocity( VectorRand():GetNormalized()*math.random(0,50)*self.Scale )
		Smoke:SetDieTime( math.Rand( 0.3 , 0.7 ) )
		Smoke:SetStartAlpha( 80 )
		Smoke:SetEndAlpha( 0 )
		Smoke:SetStartSize( 10*self.Scale )
		Smoke:SetEndSize( 30*self.Scale )
		Smoke:SetRoll( math.Rand(150, 360) )
		Smoke:SetRollDelta( math.Rand(-2, 2) )			
		Smoke:SetAirResistance( 400 ) 			 
		Smoke:SetGravity( Vector( math.Rand(-50, 50) * self.Scale, math.Rand(-50, 50) * self.Scale, math.Rand(0, -100) ) ) 			
		Smoke:SetColor( 70,35,35 )
		end
	end

 end

 function EFFECT:YellowBlood()

	for i=0, 10*self.Scale do
		local Smoke = self.Emitter:Add( "particle/particle_composite", self.Origin )
		if (Smoke) then
		Smoke:SetVelocity( VectorRand():GetNormalized()*math.random(0,70)*self.Scale )
		Smoke:SetDieTime( math.Rand( 0.3 , 0.7 ) )
		Smoke:SetStartAlpha( 80 )
		Smoke:SetEndAlpha( 0 )
		Smoke:SetStartSize( 10*self.Scale )
		Smoke:SetEndSize( 30*self.Scale )
		Smoke:SetRoll( math.Rand(150, 360) )
		Smoke:SetRollDelta( math.Rand(-2, 2) )			
		Smoke:SetAirResistance( 400 ) 			 
		Smoke:SetGravity( Vector( math.Rand(-50, 50) * self.Scale, math.Rand(-50, 50) * self.Scale, math.Rand(0, -100) ) ) 			
		Smoke:SetColor( 120,120,0 )
		end
	end
 end
 

function EFFECT:Think( )
return false
end

function EFFECT:Render()
end