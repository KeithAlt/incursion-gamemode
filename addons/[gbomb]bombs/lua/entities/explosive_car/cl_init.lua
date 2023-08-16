
include('shared.lua')


/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()
	
	self.Color = Color( 255, 255, 255, 255 )
	
end


/*---------------------------------------------------------
   Name: DrawPre
---------------------------------------------------------*/
function ENT:Draw()
	
	--self:DrawEntityOutline( 1 )
	self.Entity:DrawModel()

end

