include("shared.lua")

function ENT:Initialize()
	pos = self.Entity:GetPos()

	local emitter = ParticleEmitter(pos)
	for i = 1, 50 do 
		timer.Simple(i / 100, function()
			if not IsValid(self.Entity) then return end
			
			local smoke = emitter:Add("particle/particle_smokegrenade", pos)
			smoke:SetVelocity(VectorRand() * 400)
			smoke:SetGravity(Vector(0,0,0))
			smoke:SetDieTime(math.Rand(6,7))
			smoke:SetStartAlpha(255)
			smoke:SetEndAlpha(255)
			smoke:SetStartSize(100)
			smoke:SetEndSize(100)
			smoke:SetRoll(math.Rand(-180, 180))
			smoke:SetRollDelta(math.Rand(-0.4,0.4))
			smoke:SetColor(200,200,200)
			smoke:SetAirResistance(200)
			smoke:SetBounce(0.9)
			smoke:SetCollide(true)
			smoke:SetPos( pos )
			smoke:SetLighting(false)
			
			if i == 50 then
				emitter:Finish()
			end	
		end)
	end
end

function ENT:Draw()
end

function ENT:OnRemove()
end

function ENT:Think()
end