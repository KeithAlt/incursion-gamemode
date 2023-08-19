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

					local particle = emitter:Add("effects/combinemuzzle"..math.random(1,2), self.Position + 8 * self.Forward)
				if !IsValid(self) or !IsValid(self.WeaponEnt:GetOwner()) then return end
			particle:SetVelocity(350 * self.Forward + 1.1 * self.WeaponEnt:GetOwner():GetVelocity())
			particle:SetAirResistance(160)

			particle:SetDieTime(math.Rand(0, 0.05))

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)

			particle:SetStartSize(0)
			particle:SetEndSize(25)

			particle:SetRoll(math.Rand(180, 480))
			particle:SetRollDelta(math.Rand(-1, 1))

			particle:SetColor(70, 255, 70)
--tracer
								local particle = emitter:Add("effects/combinemuzzle"..math.Rand(1,2), self.Position + 8 * self.Forward)
				if !IsValid(self) or !IsValid(self.WeaponEnt:GetOwner()) then return end
			particle:SetVelocity(15000 * self.Forward + 1.1 * self.WeaponEnt:GetOwner():GetVelocity() or 1700) -- "Or 1700" added by Keith
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

			particle:SetColor(70, 255, 70)

			particle:SetCollideCallback( function( part, hitpos ) --This is an in-line function
    local efdata = EffectData() --Grab base EffectData table
    efdata:SetOrigin( hitpos ) --Sets the origin of it to the hitpos of the particle
    util.Effect( "effect_fo3_plasmahit", efdata ) --Create the effect
end )

for i=1,3 do
			local particle = emitter:Add("effects/combinemuzzle"..math.random(1,2), self.Position)

			particle:SetVelocity(100 * self.Forward + 8 * VectorRand()) -- + AddVel)
			particle:SetAirResistance(100)
			particle:SetGravity(Vector(0, 0, math.Rand(-100, -25)))

			particle:SetDieTime(math.Rand(0, 4))

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)

			particle:SetStartSize(math.Rand(1, 3))
			particle:SetEndSize(0)

			particle:SetRoll(math.Rand(-25, 25))
			particle:SetRollDelta(math.Rand(-0.05, 0.05))

			particle:SetColor(70, 255, 70)
end
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

