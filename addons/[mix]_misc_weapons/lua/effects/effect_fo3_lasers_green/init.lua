
EFFECT.Mat = Material( "pw_fallout/laserg.png" )

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

function EFFECT:Init( data )

	self.texcoord = math.Rand( 0, 20 )/3
	self.Position = data:GetStart()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	
    local pos = self:GetTracerPos( self.Position, self.WeaponEnt, self.Attachment )
	if !self.WeaponEnt:IsCarriedByLocalPlayer() or LocalPlayer():ShouldDrawLocalPlayer() then
	  local ang = self.WeaponEnt:GetAngles()
	  --pos = pos + ang:Forward() * 25 + ang:Up()*20 + ang:Right()*10
	end
	self.StartPos = pos
	self.EndPos = data:GetOrigin()

	self.Entity:SetCollisionBounds( self.StartPos -  self.EndPos, Vector( 110, 110, 110 ) )
	self.Entity:SetRenderBoundsWS( self.StartPos, self.EndPos, Vector()*8 )
	
	self.Alpha = 255
	self.FlashA = 255
	
end


function EFFECT:Think( )

	self.FlashA = self.FlashA - 2050 * FrameTime()
	if (self.FlashA < 0) then self.FlashA = 0 end

	self.Alpha = self.Alpha - 1650 * FrameTime()
	if (self.Alpha < 0) then return false end
	
	return true

end


function EFFECT:Render( )
	if !self.StartPos then return end
	self.Length = (self.StartPos - self.EndPos):Length()
	local texcoord = self.texcoord
	
		render.SetMaterial( self.Mat )
		render.DrawBeam( self.StartPos, 										// Start
					 self.EndPos,											// End
					 10,													// Width
					 texcoord,														// Start tex coord
					 texcoord + self.Length / 256,									// End tex coord
					 Color( 255, 255, 255, math.Clamp(self.Alpha, 0,255)) )		// Color (optional)'
					 
end
