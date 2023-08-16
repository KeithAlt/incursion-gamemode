function EFFECT:Init( data )

    self.Pos = data:GetOrigin()
	self.Norm = data:GetNormal()
	self.CreateTime = CurTime()
	self.Size = math.Rand( 25, 100 )
	local emitter = ParticleEmitter( self.Pos )

	for i = 1,math.random(5,50) do 	
		local particle = emitter:Add("Effects/spark", self.Pos)
		particle:SetVelocity(math.Rand( 60, 220 ) * self.Norm + VectorRand() * 120 * VectorRand())
		particle:SetDieTime(math.Rand(0.1, 0.5))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(math.Rand(3, 10))
		particle:SetEndSize(0)
		particle:SetRoll(0)
		particle:SetGravity(Vector(0, 0, 0))
		particle:SetCollide(true)
		particle:SetBounce(0.8)
		particle:SetAirResistance(120)
		particle:SetColor(math.random(30,50), math.random(30,50), math.random(50,200) )
		particle:SetRoll( math.Rand( 280, 680 ) )
		particle:SetRollDelta( math.Rand( -1, 1 ) )
		particle:SetCollide(true)
	end
	
	for i = 1,math.random(10,20) do 	
	    local particle = emitter:Add( "sprites/heatwave", self.Pos + self.Norm * 3 )
		particle:SetVelocity( math.Rand( 100, 260 ) * VectorRand() + 4 * VectorRand())
		particle:SetAirResistance( 140 )
		particle:SetGravity( Vector(0, 0, 0) )
		particle:SetDieTime( math.Rand(0.2,0.5) )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( math.random( 20, 35 ) )
		particle:SetEndSize( math.random( 5, 10 ) )
		particle:SetRoll( math.Rand( 180, 480 ) )
		particle:SetRollDelta( math.Rand( -1, 1 ) )
		particle:SetColor( 255, 255, 255 )
		particle:SetCollide(true)
		particle:SetBounce(0.45)
	end
	
	for i = 1,math.random(5,50) do 	
		local particle = emitter:Add("Effects/spark", self.Pos)
		particle:SetVelocity(math.Rand( 60, 120 ) * self.Norm + VectorRand() * 320 * VectorRand())
		particle:SetDieTime(math.Rand(0.1, 5))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(math.Rand(3, 5))
		particle:SetEndSize(0)
		particle:SetRoll(0)
		particle:SetGravity(Vector(0, 0, 0))
		particle:SetCollide(true)
		particle:SetBounce(0.8)
		particle:SetAirResistance(120)
		particle:SetColor(math.random(30,50), math.random(60,100), math.random(50,200) )
		particle:SetRoll( math.Rand( 60, 120 ) )
		particle:SetRollDelta( math.Rand( -20, 20 ) )
		particle:SetCollide(true)
	end
	
	for i = 1,math.random(5,25) do 	
		local particle = emitter:Add("Effects/yellowflare", self.Pos)
		particle:SetVelocity(math.Rand( 30, 90 ) * self.Norm + VectorRand() * 260)
		particle:SetDieTime(math.Rand(0.1, 0.5))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(math.Rand(3, 10))
		particle:SetEndSize(0)
		particle:SetRoll(0)
		particle:SetGravity(Vector(0, 0, 0))
		particle:SetCollide(true)
		particle:SetBounce(0.8)
		particle:SetAirResistance(120)
		particle:SetColor(math.random(30,50), math.random(60,100), math.random(50,200) )
		particle:SetRoll( math.Rand( 280, 680 ) )
		particle:SetRollDelta( math.Rand( -1, 1 ) )
		particle:SetCollide(true)
	end
	
	for i = 1,math.random(5,50) do 	
		local particle = emitter:Add("Effects/strider_muzzle", self.Pos)
		particle:SetVelocity(math.Rand( 20, 100 ) * self.Norm + VectorRand() * 120 * VectorRand())
		particle:SetDieTime(math.Rand(0.1, 0.5))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(math.Rand(3, 10))
		particle:SetEndSize(0)
		particle:SetRoll(0)
		particle:SetGravity(Vector(0, 0, 0))
		particle:SetCollide(true)
		particle:SetBounce(0.8)
		particle:SetAirResistance(120)
		particle:SetRoll( math.Rand( 280, 680 ) )
		particle:SetRollDelta( math.Rand( -1, 1 ) )
		particle:SetCollide(true)
	end
	
	WorldSound( "ambient/levels/labs/electric_explosion"..math.random( 1, 5 )..".wav", self.Pos, 75, math.random( 90, 120 ) )
	
	self.Alpha = 255
	
	emitter:Finish()
end

function EFFECT:Think()
	self.Alpha = self.Alpha - FrameTime() * 2048
	return true
end


function EFFECT:Render()
	
	if ( self.Alpha < 1 ) then return end
	
	local sc = self.Alpha / 255 
	self.Size = sc * 100
	render.SetMaterial(  Material("Effects/strider_muzzle") )
	render.DrawQuadEasy( self.Pos, self.Norm, self.Size, self.Size, Color( 255, 255, 255, 255 ) )
	
end