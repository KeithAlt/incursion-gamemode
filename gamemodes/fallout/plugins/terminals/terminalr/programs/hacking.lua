TerminalR.Programs["hacking"] = {}

TerminalR.Programs["hacking"].Init = function( self )
	local CT = { ["1"] = 0,	["37"] = 0, ["2"] = 1, ["38"] = 1 }
	self:SetMemory( "CodeTable", CT)
	self:SetMemory( "CodeTarget", 0 )
	self:SetMemory( "CodeError", 0 )
	self:SetMemory( "CodePosY", 0 )
	self:SetMemory( "CodeColR", 0 )
	self:SetMemory( "CodeColG", 255 )
	self:SetMemory( "CodeMax", TerminalR.Config.HackScoreNeed )
	self:SetMemory( "CodeTime", CurTime() + TerminalR.Config.HackTime )
	self:SetMemory( "CodeLimit", TerminalR.Config.HackErrorLimit )
	self:SetMemory( "Code", "" )
	
	local SW, SH = TerminalRGetTextSize( TerminalR.Lang.Cancel, "TrmR_Medium" )
	local Cancel = self:CreateMenuButton( "Cancel", TerminalR.Lang.Cancel )
	Cancel:SetPos( ScrW()*0.01, ScrH()*0.94 )
	Cancel:SetSize( SW + 40, SH + 10 )
	Cancel.DoClick = function( selfB )
		self:LaunchProgram( "menu" )
	end
	
end

TerminalR.Programs["hacking"].Paint = function( self, w, h )
	local PosY = h*0.38 + ( math.random( -h*0.03, h*0.03 ) * self:GetMemory( "CodePosY" ) )
	local ChatLeft = #self:GetMemory( "Code" ) .. "/" .. self:GetMemory( "CodeMax" )
	local TimeLeft = math.Round( self:GetMemory( "CodeTime" ) - CurTime() )
	
	
	draw.SimpleText( TerminalR.Lang.Errors .. " : " .. self:GetMemory( "CodeError" ) .. "/" .. self:GetMemory( "CodeLimit" ) , "TrmR_Large", w*0.02, h*0.05, Color( 255, 255, 255, 255 ), 0, 1 )	
	draw.SimpleText( TerminalR.Lang.HackScore .. " : " .. ChatLeft, "TrmR_Large", w*0.02, h*0.1, Color( 255, 255, 255, 255 ), 0, 1 )	
	draw.SimpleText( TerminalR.Lang.HackTimeLeft .. " : " .. TimeLeft, "TrmR_Large", w*0.02, h*0.15, Color( 255, 255, 255, 255 ), 0, 1 )	
	draw.SimpleText( "[" .. self:GetMemory( "Code" ) .. "]", "TrmR_Large", w*0.02, h*0.45, Color( 255, 255, 255, 255 ), 0, 1 )	
	draw.SimpleText( TerminalR.Lang.Press .. " : [" .. self:GetMemory( "CodeTarget" ) .. "]", "TrmR_Large", w*0.02, PosY, Color( self:GetMemory("CodeColR"), self:GetMemory("CodeColG"), 0, 255 ), 0, 1 )	
end

TerminalR.Programs["hacking"].OnKeyCodePressed = function( self, key )
	local CodeTable = self:GetMemory( "CodeTable" )
	if ( not CodeTable[tostring(key)] ) then return end
	if ( CodeTable[tostring(key)] == self:GetMemory( "CodeTarget" ) ) then
		self:SetMemory( "Code", self:GetMemory( "Code" ) .. self:GetMemory( "CodeTarget" ) )
		self:SetMemory( "CodeTarget", math.random( 0, 1 ) )
		if ( #self:GetMemory( "Code" ) >= self:GetMemory( "CodeMax" ) ) then
			if ( self:GetMemory( "DiskPass" ) ) then
				self:SetMemory( "DiskPass", nil )
				LocalPlayer():EmitSound( "terminalr/passgood.wav" )
				self:LaunchProgram( "menu" )
				self:SetMemory( "MenuMsg", TerminalR.Lang.HackSuccess )
				self:SetMemory( "MenuMsgAlpha", 255 )
			else
				self:LaunchProgram( "menu" )
				self:SetMemory( "MenuMsg", TerminalR.Lang.HackUseless )
				self:SetMemory( "MenuMsgAlpha", 255 )
			end
		end
	else
		self:SetMemory( "CodeError", self:GetMemory( "CodeError" ) + 1 )
		self:SetMemory( "CodeColG", 0 )
		self:SetMemory( "CodeColR", 255 )
		self:SetMemory( "CodePosY", 1 )
		self:SetMemory( "CodeTarget", math.random( 0, 1 ) )
		LocalPlayer():EmitSound( "terminalr/false.wav" )
		if ( self:GetMemory( "CodeError" ) >= self:GetMemory( "CodeLimit" ) ) then
			LocalPlayer():EmitSound( "terminalr/passbad.wav" )
			self:LaunchProgram( "menu" )
			self:SetMemory( "HackProtection", CurTime() + TerminalR.Config.HackProtectionTime )
			self:SetMemory( "MenuMsg", TerminalR.Lang.HackDenied )
			self:SetMemory( "MenuMsgAlpha", 255 )
		end
	end
	LocalPlayer():EmitSound( "terminalr/char/" .. math.random( 1, 5 ) .. ".wav" )
end

TerminalR.Programs["hacking"].OnRemove = function( self )
	self:RemoveAllMemoryNamed( { "CodeLimit", "CodeTable", "CodeTarget", "CodeError", "CodePosY", "CodeColR", "CodeColG", "CodeMax", "CodeTime", "Code" } )
end

TerminalR.Programs["hacking"].Think = function( self, dt )
	if ( self:GetMemory( "CodePosY" ) > 0 ) then
		self:SetMemory( "CodePosY", self:GetMemory( "CodePosY" ) - ( 1 * dt ) )
		if ( self:GetMemory( "CodePosY" ) < 0.1 ) then
			self:SetMemory( "CodePosY", 0 )
		end
	end
	if ( self:GetMemory( "CodeColR" ) > 0 ) then
		self:SetMemory( "CodeColR", self:GetMemory( "CodeColR" ) - ( 255 * dt ) )
	end
	if ( self:GetMemory( "CodeColG" ) < 255 ) then
		self:SetMemory( "CodeColG", self:GetMemory( "CodeColG" ) + ( 255 * dt ) )
	end
	if ( CurTime() > self:GetMemory( "CodeTime" ) ) then
		LocalPlayer():EmitSound( "terminalr/passbad.wav" )
		self:LaunchProgram( "menu" )
		self:SetMemory( "HackProtection", CurTime() + TerminalR.Config.HackProtectionTime )
		self:SetMemory( "MenuMsg", TerminalR.Lang.HackDenied )
		self:SetMemory( "MenuMsgAlpha", 255 )
	end
end


TerminalR.Programs["hacking"].Launch = function( self, dt )
	self:RemoveParent()
	self:RemoveAllMemoryNamed( { "CodeTable", "CodeLimit", "CodeTarget", "CodeError", "CodePosY", "CodeColR", "CodeColG", "CodeMax", "CodeTime", "Code" } )
end






