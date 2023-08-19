function EFFECT:GetTracerPos( Position, Ent, Attachment )

	self.ViewModelTracer = false
	if ( !IsValid( Ent ) ) then return Position end
	if ( !Ent:IsWeapon() ) then return Position end

	-- Shoot from the viewmodel
	if ( Ent:IsCarriedByLocalPlayer() && !LocalPlayer():ShouldDrawLocalPlayer() ) then
	    local ViewModel = LocalPlayer().VMHands
		if IsValid(ViewModel) then
		  ent = ViewModel.VMWeapon
		else
		  return Position
		end
		local att = ent:GetAttachment( Attachment )
		if ( att ) then
			Position = att.Pos
		end
	else
        local wep = Ent:GetOwner().FalloutWep
		
		if !IsValid(wep) then return Position end
		local att = wep:GetAttachment( Attachment )
		if ( att ) then
			Position = att.Pos
		end

	end

	return Position

end


/*---------------------------------------------------------
	EFFECT:Init(data)
---------------------------------------------------------*/
function EFFECT:Init(data)
	
	self.WeaponEnt 		= data:GetEntity()
	self.Attachment 		= data:GetAttachment()
	
	self.Position 		= self:GetTracerPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)
	self.Forward 		= data:GetNormal()
	self.Angle 			= self.Forward:Angle()
	self.Right 			= self.Angle:Right()
	self.Up 			= self.Angle:Up()
	

	
	local emitter 		= ParticleEmitter(self.Position)

					local particle = emitter:Add("sprites/ar2_muzzle"..math.random(3,4), self.Position + 8 * self.Forward)
					
if !IsValid(self) or !IsValid(self.WeaponEnt) or !IsValid(self.WeaponEnt:GetOwner()) then
if IsValid(self) then self:Remove() end
return
end
			particle:SetVelocity(350 * self.Forward + 1.1 * self.WeaponEnt:GetOwner():GetVelocity())
			particle:SetAirResistance(160)

			particle:SetDieTime(math.Rand(0, 0.05))

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)

			particle:SetStartSize(0)
			particle:SetEndSize(15)

			particle:SetRoll(math.Rand(180, 480))
			particle:SetRollDelta(math.Rand(-1, 1))

			particle:SetColor(79, 193, 255)

					local particle = emitter:Add("effects/blueflare1", self.Position + 8 * self.Forward)

			particle:SetVelocity(350 * self.Forward + 1.1 * self.WeaponEnt:GetOwner():GetVelocity())
			particle:SetAirResistance(160)

			particle:SetDieTime(0.04)

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)

			particle:SetStartSize(5)
			particle:SetEndSize(20)

			particle:SetRoll(math.Rand(180, 480))
			particle:SetRollDelta(math.Rand(-1, 1))

			particle:SetColor(79, 193, 255)
			
								local particle = emitter:Add("effects/blueflare1", self.Position + 8 * self.Forward)

			particle:SetVelocity(350 * self.Forward + 1.1 * self.WeaponEnt:GetOwner():GetVelocity())
			particle:SetAirResistance(160)

			particle:SetDieTime(0.04)

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)

			particle:SetStartSize(15)
			particle:SetEndSize(20)

			particle:SetRoll(math.Rand(180, 480))
			particle:SetRollDelta(math.Rand(-1, 1))

			particle:SetColor(79, 193, 255)
			
					local particle = emitter:Add("effects/blueflare1", self.Position)

			particle:SetVelocity(100 * self.Forward + 8 * VectorRand()) -- + AddVel)
			particle:SetAirResistance(400)
			particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))

			particle:SetDieTime(math.Rand(0, 1))

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)

			particle:SetStartSize(math.Rand(10, 13))
			particle:SetEndSize(0)

			particle:SetRoll(math.Rand(-25, 25))
			particle:SetRollDelta(math.Rand(-0.05, 0.05))

			particle:SetColor(79, 193, 255)

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
