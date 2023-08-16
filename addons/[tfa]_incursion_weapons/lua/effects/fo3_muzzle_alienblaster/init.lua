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

					local particle = emitter:Add("effects/combinemuzzle1_dark", self.Position + 8 * self.Forward)

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

			particle:SetColor(255, 255, 255)
			
								local particle = emitter:Add("sprites/ar2_muzzle4", self.Position + 8 * self.Forward)

			particle:SetVelocity(350 * self.Forward + 1.1 * self.WeaponEnt:GetOwner():GetVelocity())
			particle:SetAirResistance(160)

			particle:SetDieTime(0.04)

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)

			particle:SetStartSize(5)
			particle:SetEndSize(10)

			particle:SetRoll(math.Rand(180, 480))
			particle:SetRollDelta(math.Rand(-1, 1))

			particle:SetColor(255, 255, 255)
			
			
			--tracer

								local particle = emitter:Add("effects/energyball", self.Position + 8 * self.Forward)

			particle:SetVelocity(15000 * self.Forward + 1.1 * self.WeaponEnt:GetOwner():GetVelocity())
			particle:SetAirResistance(0)

			particle:SetDieTime(math.Rand(1, 2))

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)

			particle:SetStartSize(35)
			particle:SetEndSize(0)
			particle:SetCollide( true );
			particle:SetBounce( 0 ); 
			particle:SetRoll(math.Rand(180, 480))
			particle:SetRollDelta(math.Rand(-1, 1))

			particle:SetColor(255, 255, 255)	
			particle:SetCollideCallback( function( part, hitpos ) --This is an in-line function
    local efdata = EffectData() --Grab base EffectData table
    efdata:SetOrigin( hitpos ) --Sets the origin of it to the hitpos of the particle
    util.Effect( "effect_fo3_alienatomizerhit", efdata ) --Create the effect
end )
			


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
