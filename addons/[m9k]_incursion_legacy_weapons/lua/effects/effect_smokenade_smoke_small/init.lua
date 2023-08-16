//Main function
function EFFECT:Init(data)

	//Create particle emitter
	local emitter = ParticleEmitter(data:GetOrigin())

		//Amount of particles to create
		for i=0, 64 do

			local Pos = (data:GetOrigin() + Vector( math.Rand(-32,32), math.Rand(-32,32), math.Rand(-32,32) ) + Vector(0,0,42))

			local particle = emitter:Add( "particle/particle_smokegrenade", Pos )
			if (particle) then

				particle:SetVelocity(VectorRand() * math.Rand(1920,2142))

				particle:SetLifeTime(0)
				particle:SetDieTime(math.Rand(12, 14))

				local rand = math.random(242,255)
				if math.random(1,12) == 12 then rand = math.random(210,232) end
				particle:SetColor(rand,rand,rand)

				particle:SetStartAlpha(math.Rand(192,255)) //Old values, 142, 162
				particle:SetEndAlpha(0)

				local Size = math.Rand(112,132)
				particle:SetStartSize(Size)
				particle:SetEndSize(Size)

				particle:SetRoll(math.Rand(-360, 360))
				particle:SetRollDelta(math.Rand(-0.21, 0.21))

				particle:SetAirResistance(math.Rand(520,620))

				particle:SetGravity( Vector(0, 0, math.Rand(-32, -64)) )

				particle:SetCollide(true)
				particle:SetBounce(0.42)

				particle:SetLighting(1)

			end

		end

	//We're done with this emitter
	emitter:Finish()

end

//Kill effect
function EFFECT:Think()
return false
end

//Not used
function EFFECT:Render()
end