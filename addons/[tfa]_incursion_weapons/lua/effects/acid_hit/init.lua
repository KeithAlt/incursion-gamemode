function EFFECT:Init( data )

    local Pos = data:GetOrigin()
	local Norm = data:GetNormal()
	local vOffset = data:GetOrigin()
	local emitter = ParticleEmitter( vOffset )
	
	self.Dietime = math.Rand( 0.5, 1 )
	
	for i = 1,math.random(10,50) do 	
		local particle = emitter:Add( "sprites/flamelet"..math.random(1,5).."", Pos + Norm * 3 )
		particle:SetVelocity( math.Rand( 150, 200 ) * VectorRand() + 4 * VectorRand())
		particle:SetAirResistance( 400 )
		particle:SetGravity( Vector(0, 0, - math.Rand( 100, 200 )) )
		particle:SetDieTime( self.Dietime )
		particle:SetStartAlpha( math.Rand( 200, 255 ) )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( 1 )
		particle:SetEndSize( math.Rand( 10, 15 ) )
		particle:SetRoll( math.Rand( 180, 650 ) )
		particle:SetRollDelta( math.Rand( -1, 1 ) )
		particle:SetColor(0, math.random(50,200), 0 )
		particle:SetCollide(true)
		particle:SetBounce(0.45)
	end
	
	for i = 1,math.random(5,15) do 	
		local particle = emitter:Add( "Effects/fire_embers"..math.Rand( 1, 3 ).."", Pos + Norm * 3 )
		particle:SetVelocity( math.Rand( 250, 500 ) * VectorRand() + 4 * VectorRand())
		particle:SetAirResistance( 400 )
		particle:SetGravity( Vector(0, 0,- math.Rand( 150, 200 )) )
		particle:SetDieTime( math.Rand( 0.5, 1 ) )
		particle:SetStartAlpha( math.Rand( 200, 255 ) )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( 0 )
		particle:SetEndSize( math.random( 15, 20 ) )
		particle:SetRoll( math.Rand( 480, 650 ) )
		particle:SetRollDelta( math.Rand( -1, 1 ) )
		particle:SetColor(0, math.random(50,200), 0 )
		particle:SetCollide(true)
		particle:SetBounce(0.45)
	end
	
	for i = 1,math.random(10,20) do 	
	    local particle = emitter:Add( "sprites/heatwave", Pos + Norm * 3 )
		particle:SetVelocity( math.Rand( 50, 100 ) * VectorRand() + 4 * VectorRand())
		particle:SetAirResistance( 140 )
		particle:SetGravity( Vector(0, 0, 0) )
		particle:SetDieTime( math.Rand(0.2,0.9) )
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
	
	for i = 1,math.random(10,50) do
		local particle = emitter:Add("particle/particle_smokegrenade", Pos)
		particle:SetVelocity(math.Rand( 100, 200 ) * VectorRand() )
		particle:SetDieTime(math.Rand(0.5,1.5))
		particle:SetStartAlpha(math.Rand(150,200))
		particle:SetStartSize(math.random(1,5))
		particle:SetEndSize(math.Rand(20,50))
		particle:SetRoll(math.Rand(180,480))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetColor(0,math.random(150,255),0)
		particle:SetLighting(true)
		particle:SetAirResistance(150)
		particle:SetCollide(true)
    end
	/*
	local dlight = DynamicLight(0)
	if (dlight) then
		dlight.Pos 		= Pos
		dlight.r 		= 0
		dlight.g 		= math.random(150,255)
		dlight.b 		= 0
		dlight.Brightness = 6
		dlight.size 	= 120
		dlight.Decay 	= 100
		dlight.DieTime 	= CurTime() + self.Dietime
	end
	*/
	WorldSound( "ambient/levels/canals/toxic_slime_sizzle"..math.random( 1, 4 )..".wav", Pos, 75, math.random( 90, 110 ) )
	
	emitter:Finish()
end

function EFFECT:Think()
	return false
end


function EFFECT:Render()
end