
function EFFECT:Init( data )

	if ValidEntity( data:GetEntity() ) then
		self:SetPos( data:GetOrigin() )
		local weapon = data:GetEntity()
		local ply = weapon:GetOwner()
		local Dir = ply:EyeAngles()
		local Vm = ply:GetViewModel()
		
		local att
		self.Position = self:GetTracerShootPos(data:GetOrigin(), weapon, weapon.MuzzleAttachment)
		self.Emitter = ParticleEmitter(self.Position)
		
		att = Vm:GetAttachment(""..weapon.MuzzleAttachment.."")

		local Pos = att.Pos
		local Ang = att.Ang
		local Muzzle = data.MuzzleType
		local Vel = ply:GetVelocity()
		Ang:RotateAroundAxis(Ang:Right(), weapon.MuzzleAngleFix.x)
		Ang:RotateAroundAxis(Ang:Up(), weapon.MuzzleAngleFix.y )
		Ang:RotateAroundAxis(Ang:Forward(), weapon.MuzzleAngleFix.z)
		
		local FX
		
		if weapon:GetNetworkedBool( "Silenced" ) then
			FX = "muzzle_lee_silenced"
		else
			FX = weapon.MuzzleEffect
			
			if FX != "muzzle_lee_silenced" then
				local dlight = DynamicLight(0)
				if (dlight) then
					dlight.Pos 		= self.Position
					dlight.r 		= 70
					dlight.g 		= 50
					dlight.b 		= 0
					dlight.Brightness = 1
					dlight.size 	= 300
					dlight.Decay = 300
					dlight.DieTime 	= CurTime() + 0.01
				end
			end
		end
		
		ParticleEffect(FX, Pos, pet, att)
		self.DieTime = math.Rand( 0.5, 1 )
		for i = 1,6 do
			local particle = self.Emitter:Add( "sprites/heatwave", self.Position - ply:GetAimVector() * 4 )

			particle:SetVelocity( 80 * ply:GetAimVector() + 20 * VectorRand() + 1.05 * Vel )
			particle:SetGravity( Vector( 0, 0, 100 ) )
			particle:SetAirResistance( 160 )
			particle:SetDieTime( self.Dietime )
			particle:SetStartSize( math.random( 5, 10 ) )
			particle:SetEndSize( math.Rand( 15, 25 ) )
			particle:SetRoll( math.Rand( 180, 480 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
		end
		
	end
	
	self.Emitter:Finish()
end

function EFFECT:Think()
	if CurTime() > self.DieTime then
		return false
	else
		return true
	end
end

function EFFECT:Render()

end

