
EFFECT.Mat = Material( "pw_fallout/laserr.png" )

function EFFECT:Init( data )
	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin()
	--
	if not self.StartPos or not self.EndPos then return end
		
	self.Alpha = 255
	self.FlashA = 255
	self.texcoord = math.Rand( 0, 20 )/3
	self.Position = data:GetStart()

	self.Entity:SetCollisionBounds( self.StartPos -  self.EndPos, Vector( 110, 110, 110 ) )
	self.Entity:SetRenderBoundsWS( self.StartPos, self.EndPos, Vector()*8 )
	
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
