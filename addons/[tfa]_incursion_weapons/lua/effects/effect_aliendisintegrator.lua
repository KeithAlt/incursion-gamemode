function EFFECT:Init(data)		
	local Startpos = data:GetOrigin()
			
		self.Emitter = ParticleEmitter(Startpos)
	
		for i = 4, 5 do
			local p = self.Emitter:Add("effects/strider_muzzle", Startpos)
			
			p:SetDieTime(math.Rand(0.1, 0.1))
			p:SetStartAlpha(255)
			p:SetEndAlpha(0)
			p:SetStartSize(math.Rand(6, 66))
			p:SetEndSize(.1)
			p:SetRoll(math.random(-120, 120))
			p:SetRollDelta(math.random(-120, 120))	
			p:SetVelocity(VectorRand() * 100)
			p:SetGravity(Vector(1, 1, math.random(-150, 0)))
			p:SetCollide(true)
		end
		
		self.Emitter:Finish()
end
		
function EFFECT:Think()
	return false
end

function EFFECT:Render()
end