include('shared.lua')

function ENT:Draw()
	self:DrawModel()
end
  
function ENT:Initialize()
end

function ENT:OpenStock( stock )
	local W, H = ScrW(), ScrH()
	self.Stock = ( stock or {} )
	self.PanelStock = vgui.Create( "DFrame" )
	self.PanelStock:SetSize( W*0.3, H*0.4 )
	self.PanelStock:Center()
	self.PanelStock:SetTitle( "" )
	self.PanelStock:SetDraggable( true )
	self.PanelStock:ShowCloseButton( false )
	self.PanelStock:MakePopup()
	self.PanelStock.NextUpdate = CurTime()
	self.PanelStock.SD = 1 -- Selected Disk
	self.PanelStock.Think = function( selfP )
		if ( CurTime() > selfP.NextUpdate ) then
			net.Start( "Net_TerminalR:RefreshUse" )
				net.WriteInt( self:EntIndex(), 32 )
			net.SendToServer()
			selfP.NextUpdate = CurTime() + 1.8
		end
	end
	self.PanelStock.Paint = function( selfP, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 50,50,50,255) )
		draw.RoundedBox( 0, 0, 0, w, h*0.15, Color( 140,40,40,255) )
		draw.RoundedBox( 0, 0, 0, w, h*0.13, Color( 150,50,50,255) )
		draw.DrawText( "Disk Stockage", "TrmR_Medium", w*0.01, h*0.01, Color( 255, 255, 255, 255 ), 0 )
		draw.DrawText( "Title", "TrmR_Medium", w*0.5, h*0.15, Color( 255, 255, 255, 255 ), 1 )
		draw.DrawText( selfP.SD .. "/" .. #self.Stock, "TrmR_Medium", w*0.05, h*0.15, Color( 255, 255, 255, 255 ), 0 )

		if ( #self.Stock > 0 ) then
			local y = h*0.3
			for k , v in pairs ( self.Stock[selfP.SD].DiskTitle ) do
				draw.DrawText( self.Stock[selfP.SD].DiskTitle[k], "TrmR_Small", w*0.5, y, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
				y = y + h*0.075
			end
		else
			draw.DrawText( "Empty", "TrmR_Large", w*0.5, h*0.35, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		end
		
	end
		
	local NextDisk = vgui.Create( "DButton", self.PanelStock )
	NextDisk:SetText( "" )
	NextDisk:SetPos( W*0.25, H*0.1 )
	NextDisk:SetSize( W*0.05, H*0.1 )
	NextDisk.Paint = function( selfP, w, h )
		draw.DrawText( ">", "TrmR_Medium", w*0.5, h*0.5, Color( 255, 255, 255, 255 ), 1, 1 )
	end
	NextDisk.DoClick = function( selfP )
		if ( not self.Stock[self.PanelStock.SD + 1] ) then return end
		self.PanelStock.SD = self.PanelStock.SD + 1
	end

	local PreviousDisk = vgui.Create( "DButton", self.PanelStock )
	PreviousDisk:SetText( "" )
	PreviousDisk:SetPos( 0, H*0.1 )
	PreviousDisk:SetSize( W*0.05, H*0.1 )
	PreviousDisk.Paint = function( selfP, w, h )
		draw.DrawText( "<", "TrmR_Medium", w*0.5, h*0.5, Color( 255, 255, 255, 255 ), 1, 1 )
	end
	PreviousDisk.DoClick = function( selfP )
		if ( not self.Stock[self.PanelStock.SD - 1] ) then return end
		self.PanelStock.SD = self.PanelStock.SD - 1
	end
	
	local Cancel = vgui.Create( "DButton", self.PanelStock )
	Cancel:SetText( "" )
	Cancel:SetPos( W*0.15, H*0.3 )
	Cancel:SetSize( W*0.15, H*0.1 )
	Cancel.Color = Color( 50,50,50,255 )
	Cancel.OnCursorEntered = function( selfP ) selfP.Color = Color( 150,50,50,255 ) end
	Cancel.OnCursorExited = function( selfP ) selfP.Color = Color( 50,50,50,255 ) end
	Cancel.Paint = function( selfP, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, selfP.Color)
		draw.DrawText( "Cancel", "TrmR_Medium", w*0.5, h*0.35, Color( 255, 255, 255, 255 ), 1 )
	end
	Cancel.DoClick = function( selfP )
		self.PanelStock:Remove()
	end

	local Valid = vgui.Create( "DButton", self.PanelStock )
	Valid:SetText( "" )
	Valid:SetPos( 0, H*0.3 )
	Valid:SetSize( W*0.15, H*0.1 )
	Valid.Color = Color( 50,50,50,255 )
	Valid.OnCursorEntered = function( selfP ) selfP.Color = Color( 50,150,50,255 ) end
	Valid.OnCursorExited = function( selfP ) selfP.Color = Color( 50,50,50,255 ) end
	Valid.Paint = function( selfP, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, selfP.Color )
		draw.DrawText( "Take", "TrmR_Medium", w*0.5, h*0.35, Color( 255, 255, 255, 255 ), 1 )
	end
	Valid.DoClick = function( selfP )
		if ( #self.Stock > 0 ) then
			local NTab = {
				EntIndex = self:EntIndex(),
				DiskIndex = self.PanelStock.SD
			}
			net.Start( "Net_TerminalR:EjectDiskStock" )
				net.WriteTable( NTab )
			net.SendToServer()
			self.PanelStock:Remove()
		else
			self.PanelStock:Remove()
		end
	end
	
end
