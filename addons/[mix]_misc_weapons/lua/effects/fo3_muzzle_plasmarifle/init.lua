
TRACER_FLAG_USEATTACHMENT	= 0x0002;
SOUND_FROM_WORLD			= 0;
CHAN_STATIC					= 6;

EFFECT.Speed				= 500;
EFFECT.Length				= 64;
//EFFECT.WhizSound			= Sound( "nomad/whiz.wav" );		-- by Robinhood76 (http:--www.freesound.org/people/Robinhood76/sounds/96556/)
EFFECT.WhizDistance			= 72;

local MaterialMain			= Material( "effects/combinemuzzle2_dark" );
local MaterialFront			= Material( "effects/combinemuzzle2_dark" );

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
	
	--
	if !IsValid(self.WeaponEnt) then return end
	--
	
	self.Position 		= self:GetTracerPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)
	self.Forward 		= data:GetNormal()
	self.Angle 			= self.Forward:Angle()
	self.Right 			= self.Angle:Right()
	self.Up 			= self.Angle:Up()
	

	
	local emitter 		= ParticleEmitter(self.Position)
	local owner = self.WeaponEnt:GetOwner()
	if !IsValid(owner) then
	  owner = self.WeaponEnt
	end
	

					local particle = emitter:Add("effects/combinemuzzle"..math.random(1,2), self.Position + 8 * self.Forward)

			particle:SetVelocity(350 * self.Forward + 1.1 * owner:GetVelocity())
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

