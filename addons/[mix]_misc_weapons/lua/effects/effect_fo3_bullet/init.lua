EFFECT.Mat = Material( "effects/spark" )

function EFFECT:Init( data )
	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin()

	local ent = data:GetEntity()
	local att = data:GetAttachment()

	if ( IsValid( ent ) && att > 0 ) then
	  if ent.IsCarriedByLocalPlayer and ent:IsCarriedByLocalPlayer() and !LocalPlayer():ShouldDrawLocalPlayer() then
	    local ViewModel = LocalPlayer().VMHands
		if IsValid(ViewModel) then
		  ent = ViewModel.VMWeapon
		else
		  return
		end
		local att = ent:GetAttachment( att )
		if ( att ) then
		    local ang = att.Ang
			self.StartPos = att.Pos + ang:Right()*11 + ang:Up()*11
		end
	  else
	    ent = ent:GetOwner().FalloutWep
		if IsValid(ent) then
		local att = ent:GetAttachment( att )
		  if ( att ) then
			self.StartPos = att.Pos
		  end	    
	    end
	  end
	end

	self.Dir = self.EndPos - self.StartPos

	self:SetRenderBoundsWS( self.StartPos, self.EndPos )

	self.TracerTime = math.min( 1, self.StartPos:Distance( self.EndPos ) / 10000 )
	self.Length = math.Rand( 0.1, 0.125 )

	-- Die when it reaches its target
	self.DieTime = CurTime() + self.TracerTime
end

function EFFECT:Think()

	if ( CurTime() > self.DieTime ) then

		-- Awesome End Sparks
		local effectdata = EffectData()
		effectdata:SetOrigin( self.EndPos + self.Dir:GetNormalized() * -2 )
		effectdata:SetNormal( self.Dir:GetNormalized() * -3 )
		effectdata:SetMagnitude( 1 )
		effectdata:SetScale( 1 )
		effectdata:SetRadius( 6 )
		util.Effect( "WheelDust", effectdata )

		return false
	end

	return true

end

function EFFECT:Render()

	local fDelta = ( self.DieTime - CurTime() ) / self.TracerTime
	fDelta = math.Clamp( fDelta, 0, 1 ) ^ 0.5

	render.SetMaterial( self.Mat )

	local sinWave = math.sin( fDelta * math.pi )

	render.DrawBeam( self.EndPos - self.Dir * ( fDelta - sinWave * self.Length ),
		self.EndPos - self.Dir * ( fDelta + sinWave * self.Length ),
		2 + sinWave * 7, 1, 0, Color( 255, 251, 175, 255 ) )

end