
include('shared.lua')

function ENT:Initialize()
	
	self.Color = Color( 255, 255, 255, 255 )
	
end

function ENT:Draw()
	
	--self:DrawEntityOutline( 1 )
	self.Entity:DrawModel()

end

