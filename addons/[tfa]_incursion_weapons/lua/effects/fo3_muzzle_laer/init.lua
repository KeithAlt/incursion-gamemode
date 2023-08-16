/*---------------------------------------------------------
	EFFECT:Init(data)
---------------------------------------------------------*/
function EFFECT:Init(data)
	
	self.WeaponEnt 		= data:GetEntity()
	self.Attachment 		= data:GetAttachment()
	
	self.Position 		= self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)
	self.Forward 		= data:GetNormal()
	self.Angle 			= self.Forward:Angle()
	self.Right 			= self.Angle:Right()
	self.Up 			= self.Angle:Up()
	

	
	local emitter 		= ParticleEmitter(self.Position)

					local particle = emitter:Add("effects/stunstick", self.Position + 8 * self.Forward)

			particle:SetVelocity(350 * self.Forward + 1.1 * self.WeaponEnt:GetOwner():GetVelocity())
			particle:SetAirResistance(160)

			particle:SetDieTime(math.Rand(0, 0.05))

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)

			particle:SetStartSize(0)
			particle:SetEndSize(15)

			particle:SetRoll(math.Rand(180, 480))
			particle:SetRollDelta(math.Rand(-1, 1))

			particle:SetColor(255, 255, 255)	

		
					local particle = emitter:Add("effects/combinemuzzle2_dark", self.Position + 8 * self.Forward)

			particle:SetVelocity(350 * self.Forward + 1.1 * self.WeaponEnt:GetOwner():GetVelocity())
			particle:SetAirResistance(160)

			particle:SetDieTime(0.04)

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)

			particle:SetStartSize(5)
			particle:SetEndSize(20)

			particle:SetRoll(math.Rand(180, 480))
			particle:SetRollDelta(math.Rand(-1, 1))

			particle:SetColor(165,234,255)
			
								local particle = emitter:Add("effects/stunstick", self.Position + 8 * self.Forward)

			particle:SetVelocity(350 * self.Forward + 1.1 * self.WeaponEnt:GetOwner():GetVelocity())
			particle:SetAirResistance(160)

			particle:SetDieTime(0.04)

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)

			particle:SetStartSize(5)
			particle:SetEndSize(10)

			particle:SetRoll(math.Rand(180, 480))
			particle:SetRollDelta(math.Rand(-1, 1))

			particle:SetColor(165,234,255)
			


	emitter:Finish()
end

/*---------------------------------------------------------
	EFFECT:Think()
---------------------------------------------------------*/
function EFFECT:Think()

	return false
end

/*---------------------------------------------------------
	EFFECT:Render()
---------------------------------------------------------*/
function EFFECT:Render()
end
