function EFFECT:GetTracerPos( Position, Ent, Attachment )

	self.ViewModelTracer = false
	if ( !IsValid( Ent ) ) then return Position end
	if ( !Ent:IsWeapon() ) then return Position end

	-- Shoot from the viewmodel
	if ( Ent:IsCarriedByLocalPlayer() && !LocalPlayer():ShouldDrawLocalPlayer() ) then
	
		local ViewModel = LocalPlayer().VMHands
		local Weapon = nil
		  if IsValid(ViewModel) then
		    Weapon = ViewModel.VMWeapon
		  end
		if ( IsValid(Weapon) ) then
			local att = Weapon:GetAttachment( Attachment )
			if ( att ) then
				Position = att.Pos
				self.ViewModelTracer = true
			end

		end

	-- Shoot from the world model
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
	
//	local AddVel 		= self.WeaponEnt:GetOwner():GetVelocity()
	--if !IsValid(self.WeaponEnt) then return end
	local emitter 		= ParticleEmitter(self.Position)
		if (true) then
			local particle = emitter:Add("effects/muzzleflash"..math.random(1, 4), self.Position + 8 * self.Forward)
				if IsValid(self.WeaponEnt) and not IsValid(self.WeaponEnt:GetOwner()) then 
				  self.WeaponEnt = data:GetEntity()
				end
				--
				local owner;
				local plus_vel;
				if IsValid(self.WeaponEnt) and IsValid(self.WeaponEnt:GetOwner()) then
					owner = self.WeaponEnt:GetOwner()
				elseif IsValid(self.WeaponEnt) then
				  owner = self.WeaponEnt
				end
				
				if IsValid(owner) then
					plus_vel = owner:GetVelocity()
				else
					plus_vel = Vector(0,0,0)
				end
				--
				particle:SetVelocity(350 * self.Forward + 1.1 * plus_vel)
				particle:SetAirResistance(160)

				particle:SetDieTime(0.1)

				particle:SetStartAlpha(255)
				particle:SetEndAlpha(0)

				particle:SetStartSize(8)
				particle:SetEndSize(16)

				particle:SetRoll(math.Rand(180, 480))
				particle:SetRollDelta(math.Rand(-1, 1))

				particle:SetColor(255, 255, 255)	
		end

		local particle = emitter:Add("sprites/heatwave", self.Position + 8 * self.Forward)
			if not IsValid(data:GetEntity()) or not IsValid(self.WeaponEnt:GetOwner()) then return end
			particle:SetVelocity(350 * self.Forward + 1.1 * self.WeaponEnt:GetOwner():GetVelocity())
			particle:SetAirResistance(160)

			particle:SetDieTime(0.1)

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)

			particle:SetStartSize(10)
			particle:SetEndSize(20)

			particle:SetRoll(math.Rand(180, 480))
			particle:SetRollDelta(math.Rand(-1, 1))

			particle:SetColor(255, 255, 255)	
			
		local particle = emitter:Add("particle/particle_smokegrenade", self.Position)
			if not IsValid(data:GetEntity()) or not IsValid(self.WeaponEnt:GetOwner()) then return end
			particle:SetVelocity(100 * self.Forward + 8 * VectorRand()) // + AddVel)
			particle:SetAirResistance(400)
			particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))

			particle:SetDieTime(math.Rand(1.0, 2.0))

			particle:SetStartAlpha(math.Rand(225, 255))
			particle:SetEndAlpha(0)

			particle:SetStartSize(math.Rand(2, 7))
			particle:SetEndSize(math.Rand(15, 25))

			particle:SetRoll(math.Rand(-25, 25))
			particle:SetRollDelta(math.Rand(-0.05, 0.05))

			particle:SetColor(120, 120, 120)
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
