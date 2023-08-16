include('shared.lua')

function ENT:Draw()
	self:DrawModel()
	local pos = self:GetPos()
	local ang = self:GetAngles()
	ang:RotateAroundAxis( ang:Up(), 90 )
	ang:RotateAroundAxis( ang:Forward(), 90 )
	
	cam.Start3D2D( pos + ang:Up()*0.1, ang, 0.02)
		draw.SimpleText( self:GetNWString( "Disk:NameLine1"), "ChatFont", -100, -240, Color(0, 0, 0, 255), 0, 1)	
		draw.SimpleText( self:GetNWString( "Disk:NameLine2"), "ChatFont", -100, -220, Color(0, 0, 0, 255), 0, 1)	
		draw.SimpleText( self:GetNWString( "Disk:NameLine3"), "ChatFont", -100, -200, Color(0, 0, 0, 255), 0, 1)	
		draw.SimpleText( self:GetNWString( "Disk:NameLine4"), "ChatFont", -100, -180, Color(0, 0, 0, 255), 0, 1)	
		draw.SimpleText( self:GetNWString( "Disk:NameLine5"), "ChatFont", -100, -160, Color(0, 0, 0, 255), 0, 1)	
		draw.SimpleText( self:GetNWString( "Disk:NameLine6"), "ChatFont", -100, -140, Color(0, 0, 0, 255), 0, 1)	
	cam.End3D2D()
end
  
function ENT:Initialize()
end

function ENT:OpenMenu()
	if ( self.RenameDiskFrame ) then return end
	local W, H = ScrW(), ScrH()
	self.RenameDiskFrame = vgui.Create( "DFrame" )
	self.RenameDiskFrame:SetSize( W*0.25, H*0.4 )
	self.RenameDiskFrame:SetTitle( "Disk Rename" )
	self.RenameDiskFrame:Center()
	self.RenameDiskFrame:MakePopup()
	self.RenameDiskFrame.ParentList = {}
	self.RenameDiskFrame.OnRemove = function( selfFrame )
		self.RenameDiskFrame = nil
	end
	
	self.RenameDiskFrame.ParentList["Valid"] = vgui.Create( "DButton", self.RenameDiskFrame )
	self.RenameDiskFrame.ParentList["Valid"]:SetText( "Valid" )
	self.RenameDiskFrame.ParentList["Valid"]:SetPos( W*0.025, H*0.35 )
	self.RenameDiskFrame.ParentList["Valid"]:SetSize( W*0.2, H*0.025 )
	self.RenameDiskFrame.ParentList["Valid"].DoClick = function()
		local P = self.RenameDiskFrame.ParentList
		local NTab = {
			[1] = P.TE1:GetValue(),
			[2] = P.TE2:GetValue(),
			[3] = P.TE3:GetValue(),
			[4] = P.TE4:GetValue(),
			[5] = P.TE5:GetValue(),
			[6] = P.TE6:GetValue()
		}
		net.Start( "Net_TerminalR:RenameDisk")
			net.WriteInt( self:EntIndex(), 32 )
			net.WriteTable( NTab )
		net.SendToServer()
		self.RenameDiskFrame:Remove()
		self.RenameDiskFrame = nil
	end
	
	local x, y = W*0.025, H*0.05
	for i = 1, 6 do
		self.RenameDiskFrame.ParentList["TE" .. i] = vgui.Create( "DTextEntry", self.RenameDiskFrame )
		self.RenameDiskFrame.ParentList["TE" .. i]:SetPos( x, y )
		self.RenameDiskFrame.ParentList["TE" .. i]:SetSize( W*0.2, H*0.025 )
		self.RenameDiskFrame.ParentList["TE" .. i]:SetText( "" )
		self.RenameDiskFrame.ParentList["TE" .. i]:SetUpdateOnType( true )
		self.RenameDiskFrame.ParentList["TE" .. i].OnValueChange = function( selfFrame )
			if ( #selfFrame:GetValue() > 19 ) then
				selfFrame:SetText( string.sub( selfFrame:GetValue(), 0, 19 ) )
				selfFrame:KillFocus()
			end
		end
		y = y + H *0.05
	end
end


