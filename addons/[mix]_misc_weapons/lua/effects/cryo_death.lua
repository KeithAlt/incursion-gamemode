function EFFECT:Init(data)
	local ent = data:GetEntity()
	if (!IsValid(ent)) then
		return end

	local emitter = ParticleEmitter(ent:GetPos())
	emitter:SetNearClip(24, 32)

	for i = 0, 25 do
		local bone = ent:GetBoneMatrix(i)
		if (bone) then
			local pos = bone:GetTranslation()

			for i = 1, math.random(2, 7) do
				particle = emitter:Add("particle/snow", pos + VectorRand() * 4)
				particle:SetVelocity(VectorRand() * 25)
				particle:SetDieTime(math.Rand(4, 5))
				particle:SetStartAlpha(math.random(245, 255))
				particle:SetEndAlpha(0)
				particle:SetStartSize(math.Rand(2, 5))
				particle:SetEndSize(0)
				particle:SetRoll(math.Rand(0, 360))
				particle:SetGravity(Vector(math.random(-25, 0), math.random(-25, 0), math.random(-125, -200)))
				particle:SetBounce(0.25)
				particle:SetCollide(true)
			end
		end
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end