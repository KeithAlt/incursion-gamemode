
/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )

	local emitter = ParticleEmitter(data:GetOrigin())
	
		for i = 0, 100 do
		local Pos = (data:GetOrigin())
		local particle = emitter:Add("particle/particle_smokegrenade", Pos)
			if (particle) then
				particle:SetVelocity(VectorRand() * math.Rand(200, 400))
				particle:SetLifeTime(0)
				particle:SetDieTime(math.Rand(1.5, 3))
				particle:SetColor(190, 190, 190)			
				particle:SetStartAlpha(255)
				particle:SetEndAlpha(0)
				particle:SetStartSize(5)
				particle:SetEndSize(math.Rand(40, 80))
				particle:SetRoll(math.Rand(-360, 360))
				particle:SetRollDelta(math.Rand(-0.21, 0.21))
				particle:SetAirResistance(math.Rand(100, 200))
				particle:SetGravity(Vector(0, 0, -50))
				particle:SetCollide(true)
				particle:SetBounce(0.45)
			end
		end
		
	emitter:Finish()
	
	local dlight = DynamicLight(0)
		if (dlight) then
			dlight.Pos = data:GetOrigin()
			dlight.r = 255
			dlight.g = 255
			dlight.b = 255
			dlight.Brightness = 5
			dlight.Size = 800
			dlight.Decay = 1000
			dlight.DieTime = CurTime() + 0.5
		end
	
end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )

	return true

end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )
					 
end
