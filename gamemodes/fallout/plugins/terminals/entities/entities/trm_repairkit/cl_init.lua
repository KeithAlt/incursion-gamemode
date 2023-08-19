include('shared.lua')

function ENT:Draw()
	self:DrawModel()
	local pos = self:GetPos()
	local ang = self:GetAngles()

	cam.Start3D2D( pos + ang:Up()*4.05, ang, 0.15)
		draw.SimpleText( "Terminal", "ChatFont", 0, -20, Color(255, 255, 255, 255), 1, 1)	
		draw.SimpleText( "RepairKit", "ChatFont", 0, 0, Color(255, 255, 255, 255), 1, 1)	
	cam.End3D2D()
end
  
function ENT:Initialize()
end
