TerminalR.Programs["disk_eject"] = {}

TerminalR.Programs["disk_eject"].Init = function( self )
	self:SetMemory( "EjectPercent", 0 )
	self:SetMemory( "TimerMenu", 0 )
	self:SetMemory( "TimerEnabled", false )
	
	local LoadingText = { 
		[0] = "Prepare the disk ...",
		[1] = "Write on the disk ( 1/7 ) ...",
		[2] = "Write on the disk ( 2/7 ) ...",
		[3] = "Write on the disk ( 3/7 ) ...",
		[4] = "Write on the disk ( 4/7 ) ...",
		[5] = "Write on the disk ( 5/7 ) ...",
		[6] = "Write on the disk ( 6/7 ) ...",
		[7] = "Write on the disk ( 7/7 ) ...",
		[8] = "Check integrity of the disk ...",
		[9] = "Eject the disk ...",
		[10] = "Eject the disk ..."
	}
	self:SetMemoryIfEmpty( "TextEject", LoadingText )
	LocalPlayer():EmitSound( "terminalr/disk/eject/" .. math.random( 1, 3 ) .. ".wav" )
end

TerminalR.Programs["disk_eject"].Paint = function( self, w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0 ) )
	local Percent = math.Clamp( self:GetMemory( "EjectPercent" ), 0, 100 )
	draw.RoundedBox( 0, w*0.2, h*0.5, (Percent/100)*(w*0.6), h*0.05, Color(0,math.random(200,255),0) )

	local Text = self:GetMemory( "TextEject" )[ math.Round( Percent * 0.1  ) ]
	draw.DrawText( Text, "TrmR_Medium", ScrW() * 0.5, ScrH() * 0.45, Color( 0, math.random(210,255), 0, 255 ), 1 )
end

TerminalR.Programs["disk_eject"].Think = function( self, dt )
	if ( self:GetMemory( "EjectPercent" ) < 100 ) then
		local NewPercent
		if ( math.random( 0, 100 ) > 10 ) then
			NewPercent = self:GetMemory( "EjectPercent" ) + ( math.random( 0, 10 ) * dt )
		else
			NewPercent = self:GetMemory( "EjectPercent" ) + ( 400 * dt )
		end
		self:SetMemory( "EjectPercent", NewPercent)
	else
		if ( not self:GetMemory("TimerEnabled") )then
			self:SetMemory("TimerMenu", CurTime() + 1 )
			self:SetMemory("TimerEnabled", true)
		else
			if ( CurTime() > self:GetMemory("TimerMenu") ) then
				--[[
				local NTab = self:getDiskData()
				
				net.Start( "Net_TerminalR:EjectDisk" )
					net.WriteInt( self.EntIndex, 32 )
					net.WriteTable( NTab )
				net.SendToServer()
				--]]
				
				local info = self:getDiskData()
				netstream.Start("foDiskPrint", self.EntIndex, info)
			
				self:RemoveAllMemoryNamed( { "DiskPass", "DiskTitle", "DiskText", "EjectPercent", "TimerMenu", "TimerEnabled", "TextEject" } )
				self:LaunchProgram( "menu" )
			end
		end
	end
end

TerminalR.Programs["disk_eject"].OnRemove = function( self )
	self:RemoveAllMemoryNamed( { "EjectPercent", "TimerMenu", "TimerEnabled", "TextEject" } )
end