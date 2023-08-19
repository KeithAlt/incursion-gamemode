function EFFECT:Init( data )

    local Pos = data:GetOrigin()
	local Norm = data:GetNormal()
	local vOffset = data:GetOrigin()
	local emitter = ParticleEmitter( vOffset )
	self.Dietime = math.Rand( 0.2, 0.6 )
	for i = 1,math.random(10,50) do 	
		local particle = emitter:Add( "Effects/combinemuzzle2_dark", Pos + Norm * 3 )
		particle:SetVelocity( math.Rand( 150, 200 ) * VectorRand() + 4 * VectorRand())
		particle:SetAirResistance( 400 )
		particle:SetGravity( Vector(0, 0, 0) )
		particle:SetDieTime( self.Dietime )
		particle:SetStartAlpha( math.Rand( 200, 255 ) )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( 1 )
		particle:SetEndSize( math.Rand( 10, 25 ) )
		particle:SetRoll( math.Rand( 180, 650 ) )
		particle:SetRollDelta( math.Rand( -1, 1 ) )
		particle:SetCollide(true)
		particle:SetBounce(0.45)
		
	end
	
	for i = 1,math.random(10,20) do 	
	    local particle = emitter:Add( "sprites/heatwave", Pos + Norm * 3 )
		particle:SetVelocity( math.Rand( 50, 100 ) * VectorRand() + 4 * VectorRand())
		particle:SetAirResistance( 140 )
		particle:SetGravity( Vector(0, 0, 0) )
		particle:SetDieTime( math.Rand(0.1,0.5) )
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
	
	for i = 1,math.random(5,25) do 	
		local particle = emitter:Add("Effects/yellowflare", Pos)
		particle:SetVelocity(math.Rand( 30, 90 ) * Norm + VectorRand() * 260)
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
	
	for i = 1,math.random(5,35) do 	
		local particle = emitter:Add("effects/bluespark", Pos)
		particle:SetVelocity(math.Rand( 60, 120 ) * Norm + VectorRand() * 120 * VectorRand())
		particle:SetDieTime(math.Rand(0.1, 0.5))
		particle:SetStartAlpha(255)
		particle:SetStartSize(3)
		particle:SetEndSize(0)
		particle:SetRoll(0)
		particle:SetGravity(Vector(0, 0, -math.Rand(100, 200)))
		particle:SetCollide(true)
		particle:SetBounce(0.8)
		particle:SetAirResistance(120)
		particle:SetStartLength(0)
		particle:SetEndLength(0.3)
		particle:SetVelocityScale(true)
		particle:SetCollide(true)
	end
	
	WorldSound( "ambient/energy/weld"..math.random( 1, 2 )..".wav", Pos, 75, math.random( 90, 110 ) )
	
	local dlight = DynamicLight(0)
	if (dlight) then
		dlight.Pos 		= Pos
		dlight.r 		= math.Rand( 10, 30 )
		dlight.g 		= math.Rand( 10, 30 )
		dlight.b 		= math.Rand( 200, 255 )
		dlight.Brightness = 6
		dlight.size 	= 120
		dlight.Decay 	= 200
		dlight.DieTime 	= CurTime() + self.Dietime
	end
	
	emitter:Finish()
end

function EFFECT:Think()
	return false
end


function EFFECT:Render()
end