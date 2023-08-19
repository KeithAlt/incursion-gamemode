function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local normal = Vector(0, 0, 1)
	local range = CRYOGRENADE_SETTINGS.Range * 2

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

		local particle = emitter:Add("particle/snow", pos)
		particle:SetDieTime(math.Rand(0.5, 1))
		particle:SetStartAlpha(math.Rand(100, 120))
		particle:SetEndAlpha(0)
		particle:SetStartSize(8)
		particle:SetEndSize(math.Rand(16, 20))
		particle:SetRoll(math.Rand(-0.2, 0.2))
		particle:SetColor(255, 255, 255)

		for x = 1, math.random(4, 6) do
			local vel = VectorRand()
			vel.z = math.max(vel.z, 1) * 2.5
			vel = vel * 200
		
			local particle = emitter:Add("particle/snow", pos)
			particle:SetGravity(normal * 5000)
			particle:SetVelocity(vel)
			particle:SetDieTime(math.Rand(2.5, 2.7))
			particle:SetStartAlpha(math.random(150, 200))
			particle:SetEndAlpha(32)
			particle:SetStartSize(1)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 359))
			particle:SetCollide(true)
			particle:SetBounce(0)
			particle:SetAirResistance(40)
			particle:SetCollideCallback(function(particle, hitpos, hitnormal)
				util.Decal("paintsplatblue", hitpos + hitnormal, hitpos - hitnormal)
			end)
		end

		for i=1, 3 do
			local vBaseAng = Angle(math.random(1, 90), math.random(1, 90), math.random(1, 90))
			for x=0, 360, 15 do
				local vVec = Vector(range * math.cos(x), range * math.sin(x), 0)
				vVec:Rotate(vBaseAng, 180)

				local particle = emitter:Add("particle/snow", pos)
				particle:SetVelocity(vVec)
				particle:SetDieTime(math.Rand(2.5, 2.7))
				particle:SetStartAlpha(math.random(150, 200))
				particle:SetEndAlpha(32)
				particle:SetStartSize(64)
				particle:SetEndSize(4)
				particle:SetRoll(math.Rand(0, 359))
				particle:SetCollide(true)
				particle:SetBounce(0.2)
				particle:SetAirResistance(math.random(130, 260))
			end
		end

	emitter:Finish()
	
	sound.Play("ambient/explosions/explode_8.wav", pos, nil, math.random(125, 150))
	
	local trs = util.TraceLine({start = pos + Vector(0, 0, 64), endpos = pos + Vector(0, 0, -128), filter = ents.GetAll()})
	util.Decal("bulletproof", trs.HitPos + trs.HitNormal, trs.HitPos - trs.HitNormal)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end