function EFFECT:Init( data )

    local Pos = data:GetOrigin()
	local Norm = data:GetNormal()
	local vOffset = data:GetOrigin()
	local emitter = ParticleEmitter( vOffset )
	
	for i = 1,math.random(10,25) do 	
		local particle = emitter:Add( "effects/fire_cloud1", Pos + Norm * 3 )
		particle:SetVelocity( math.Rand( 150, 200 ) * VectorRand() + 4 * VectorRand())
		particle:SetAirResistance( 400 )
		particle:SetGravity( Vector(0, 0, 0) )
		particle:SetDieTime( math.Rand( 0.3, 0.4 ) )
		particle:SetStartAlpha( math.Rand( 200, 255 ) )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( 0 )
		particle:SetEndSize( math.random( 10, 20 ) )
		particle:SetRoll( math.Rand( 180, 650 ) )
		particle:SetRollDelta( math.Rand( -5, 5 ) )
		particle:SetColor( math.Rand( 200, 255 ), 255, 255 )
		particle:SetCollide(true)
		particle:SetBounce(0.45)
	end
	
	for i = 1,math.random(5,10) do 	
		local particle = emitter:Add( "Effects/fire_embers"..math.Rand( 1, 3 ).."", Pos + Norm * 3 )
		particle:SetVelocity( math.Rand( 300, 350 ) * VectorRand() + 4 * VectorRand())
		particle:SetAirResistance( 400 )
		particle:SetGravity( Vector(0, 0, 0) )
		particle:SetDieTime( math.Rand( 0.3, 0.5 ) )
		particle:SetStartAlpha( math.Rand( 200, 255 ) )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( math.random( 15, 20 ) )
		particle:SetEndSize( 0 )
		particle:SetRoll( math.Rand( 180, 650 ) )
		particle:SetRollDelta( math.Rand( -1, 1 ) )
		particle:SetColor( math.Rand( 200, 255 ), 255, 255 )
		particle:SetCollide(true)
		particle:SetBounce(0.45)
	end
	
	for i = 1,math.random(1,5) do
		local particle = emitter:Add( "sprites/heatwave", Pos + Norm * 3 )
		particle:SetVelocity( 90 * data:GetNormal() + 8 * VectorRand() + 100 * VectorRand() )
		particle:SetAirResistance( 140 )
		particle:SetGravity( Vector(0, 0, 0) )
		particle:SetDieTime( math.Rand(0.2,0.4) )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( math.random( 50, 100 ) )
		particle:SetEndSize( 0 )
		particle:SetRoll( math.Rand( 180, 480 ) )
		particle:SetRollDelta( math.Rand( -1, 1 ) )
		particle:SetColor( 255, 255, 255 )
		particle:SetCollide(true)
		particle:SetBounce(0.45)
	end
	
	for i = 1,math.random(10,50) do
		local particle = emitter:Add("particle/particle_smokegrenade", Pos)
		particle:SetVelocity(math.Rand( 100, 200 ) * VectorRand() )
		particle:SetDieTime(math.Rand(0.5,1))
		particle:SetStartAlpha(math.Rand(150,200))
		particle:SetStartSize(math.random(10,15))
		particle:SetEndSize(math.Rand(30,100))
		particle:SetRoll(math.Rand(180,480))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetColor(100,100,100)
		particle:SetAirResistance(150)
		particle:SetCollide(true)
    end
	
	for i = 1,math.random(3,6) do
		local particle = emitter:Add( "particle/particle_smokegrenade", vOffset )
		particle:SetVelocity( math.Rand( 50, 150 ) * i * data:GetNormal() + 8 * VectorRand() )
		particle:SetAirResistance(400)
		particle:SetDieTime( math.Rand( 1.5, 3 ) )
		particle:SetStartAlpha( math.Rand( 200, 255 ) )
		particle:SetEndAlpha( math.Rand( 0, 5 ) )
		particle:SetStartSize( math.Rand( 8, 12 ) )
		particle:SetEndSize( math.Rand( 52, 76 ) )
		particle:SetRoll( math.Rand( -25, 25 ) )
		particle:SetRollDelta( math.Rand( -0.05, 0.05 ) )
		particle:SetColor( 100, 100, 100 )
		particle:SetCollide(true)
	end

	for i = 1, math.random(5,15) do
		local particle = emitter:Add("effects/fire_cloud1", Pos)
		particle:SetVelocity(math.Rand( 100, 200 ) * data:GetNormal() + VectorRand() * 500 )
		particle:SetDieTime(math.Rand(0.1, 0.2))
		particle:SetStartAlpha(255)
		particle:SetStartSize(math.random(5,10))
		particle:SetEndSize(0)
		particle:SetRoll(0)
		particle:SetGravity(Vector(0, 0, 0))
		particle:SetCollide(true)
		particle:SetBounce(0.8)
		particle:SetAirResistance(90)
		particle:SetStartLength(0)
		particle:SetEndLength(math.Rand(0.05, 0.1))
		particle:SetVelocityScale(true)
		particle:SetCollide(true)
	end
	
	local dlight = DynamicLight(0)
	if (dlight) then
		dlight.Pos 		= Pos
		dlight.r 		= 70
		dlight.g 		= 50
		dlight.b 		= 0
		dlight.Brightness = 1
		dlight.Decay = 500
		dlight.size 	= math.Rand(50, 150)
		dlight.DieTime 	= CurTime() + math.Rand(0.01, 0.1)
	end
	
	emitter:Finish()
end

function EFFECT:Think()
	return false
end


function EFFECT:Render()
end