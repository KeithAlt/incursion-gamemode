ENT.Spawnable			= false
ENT.AdminSpawnable		= false

include("shared.lua")

/*---------------------------------------------------------
   Name: ENT:Initialize()
---------------------------------------------------------*/
function ENT:Initialize()
 
	self.TimeLeft = CurTime() + 3

	local vOffset 	= self.Entity:LocalToWorld(Vector(0, 0, self.Entity:OBBMins().z))
	local vNormal 	= (vOffset - self.Entity:GetPos()):GetNormalized()

	local emitter 	= ParticleEmitter(vOffset)

	// 150 particles per second during 30 seconds
	for i = 1, 4500 do 
		timer.Simple(i / 150, function()
			if not IsValid(self.Entity) then return end

			local vOffset 	= self.Entity:LocalToWorld(Vector(0, 0, self.Entity:OBBMins().z))
			local vNormal 	= (vOffset - self.Entity:GetPos()):GetNormalized()

			local particle = emitter:Add("particle/particle_smokegrenade", vOffset)
			particle:SetVelocity(vNormal * 5)
			particle:SetDieTime(10)
			particle:SetStartAlpha(255)
			particle:SetStartSize(5)
			particle:SetEndSize(25)
			particle:SetRoll(math.Rand(-5, 5))
			particle:SetColor(160, 160, 160)
			if i == 4500 then
				emitter:Finish()
			end			
		end)
	end
end