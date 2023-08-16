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
	
--	local AddVel 		= self.WeaponEnt:GetOwner():GetVelocity()
	
	local emitter 		= ParticleEmitter(self.Position)

--[[		if math.random(1, 2) == 1 then
			local particle = emitter:Add("effects/muzzleflash"..math.random(1, 4), self.Position + 8 * self.Forward)

				particle:SetVelocity(350 * self.Forward + 1.1 * self.WeaponEnt:GetOwner():GetVelocity())
				particle:SetAirResistance(160)

				particle:SetDieTime(0.1)

				particle:SetStartAlpha(255)
				particle:SetEndAlpha(0)

				particle:SetStartSize(16)
				particle:SetEndSize(32)

				particle:SetRoll(math.Rand(180, 480))
				particle:SetRollDelta(math.Rand(-1, 1))

				particle:SetColor(255, 255, 255)
			
		end
		
		local particle = emitter:Add("sprites/heatwave", self.Position + 8 * self.Forward)

			particle:SetVelocity(350 * self.Forward + 1.1 * self.WeaponEnt:GetOwner():GetVelocity())
			particle:SetAirResistance(160)

			particle:SetDieTime(0.1)

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)

			particle:SetStartSize(16)
			particle:SetEndSize(32)

			particle:SetRoll(math.Rand(180, 480))
			particle:SetRollDelta(math.Rand(-1, 1))

			particle:SetColor(255, 255, 255)
			]]
					local particle = emitter:Add("effects/strider_bulge_dudv", self.Position + 8 * self.Forward)

			particle:SetVelocity(350 * self.Forward + 1.1 * self.WeaponEnt:GetOwner():GetVelocity())
			particle:SetAirResistance(160)

			particle:SetDieTime(math.Rand(0, 0.05))

			particle:SetStartAlpha(150)
			particle:SetEndAlpha(0)

			particle:SetStartSize(0)
			particle:SetEndSize(35)

			particle:SetRoll(math.Rand(180, 480))
			particle:SetRollDelta(math.Rand(-1, 1))

			particle:SetColor(255, 255, 255)	

					local particle = emitter:Add("effects/muzzleflashX", self.Position + 8 * self.Forward)

			particle:SetVelocity(350 * self.Forward + 1.1 * self.WeaponEnt:GetOwner():GetVelocity())
			particle:SetAirResistance(160)

			particle:SetDieTime(0.04)

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(200)

			particle:SetStartSize(5)
			particle:SetEndSize(50)

			particle:SetRoll(math.Rand(180, 480))
			particle:SetRollDelta(math.Rand(-1, 1))

			particle:SetColor(255, 255, 255)
			
								local particle = emitter:Add("sprites/rico1", self.Position + 8 * self.Forward)

			particle:SetVelocity(350 * self.Forward + 1.1 * self.WeaponEnt:GetOwner():GetVelocity())
			particle:SetAirResistance(160)

			particle:SetDieTime(0.04)

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(200)

			particle:SetStartSize(15)
			particle:SetEndSize(20)

			particle:SetRoll(math.Rand(180, 480))
			particle:SetRollDelta(math.Rand(-1, 1))

			particle:SetColor(255, 255, 255)
			--[[
								local particle = emitter:Add("sprites/ar2_muzzle1", self.Position + 8 * self.Forward)

			particle:SetVelocity(350 * self.Forward + 1.1 * self.WeaponEnt:GetOwner():GetVelocity())
			particle:SetAirResistance(160)

			particle:SetDieTime(0.1)

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)

			particle:SetStartSize(55)
			particle:SetEndSize(60)

			particle:SetRoll(math.Rand(180, 480))
			particle:SetRollDelta(math.Rand(-1, 1))

			particle:SetColor(255, 255, 255)	
]]
--		local particle = emitter:Add("particle/particle_smokegrenade", self.Position)
		local particle = emitter:Add("particles/Dirt", self.Position)

			particle:SetVelocity(100 * self.Forward + 8 * VectorRand()) -- + AddVel)
			particle:SetAirResistance(400)
			particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))

			particle:SetDieTime(math.Rand(0, 2.0))

			particle:SetStartAlpha(math.Rand(0, 100))
			particle:SetEndAlpha(0)

			particle:SetStartSize(math.Rand(5, 10))
			particle:SetEndSize(math.Rand(10, 15))

			particle:SetRoll(math.Rand(-25, 25))
			particle:SetRollDelta(math.Rand(-0.05, 0.05))

			particle:SetColor(120, 120, 120)
--[[		local AddVel 		= self.WeaponEnt:GetOwner():GetVelocity()
					for i = 0, 10 do
	
			local particle = emitter:Add("effects/yellowflare", self.Position)
		
				particle:SetVelocity(((self.Forward + VectorRand() * 0.5) * math.Rand(362, 363)))
				particle:SetDieTime(math.Rand(0.2, 1.33))
				particle:SetStartAlpha(255)
				particle:SetStartSize(2.01)
				particle:SetEndSize(0)
				particle:SetRoll(0)
				particle:SetGravity(Vector(0, 0, -50)) 
				particle:SetCollide(true)
				particle:SetBounce(0.48)
				particle:SetAirResistance(5)
				particle:SetStartLength(27.71)
				particle:SetEndLength(0)
				particle:SetVelocityScale(true)
				particle:SetCollide(true)
		end
		]]
--[[
		local particle = emitter:Add("effects/yellowflare", self.Position + 8 * self.Forward)

			particle:SetVelocity(self.Forward + 1.1 * AddVel)
			particle:SetAirResistance(160)

			particle:SetDieTime(0.25)

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)

			particle:SetStartSize(30)
			particle:SetEndSize(40)

			particle:SetRoll(math.Rand(180, 480))
			particle:SetRollDelta(math.Rand(-1, 1))

			particle:SetColor(255, 255, 255)	
]]
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
