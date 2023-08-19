TerminalR.Programs["password_check"] = {}

TerminalR.Programs["password_check"].Init = function( self )
	local W, H = ScrW(), ScrH()
	self:SetMemory( "Password", "" )
	self:SetMemory( "WrongAlpha", 0 )
	
	local ParentTable = self:GetParentTable()
	ParentTable["TE"] = vgui.Create( "DTextEntry", self )
	ParentTable["TE"]:SetText( "" )
	ParentTable["TE"].NextTyping = CurTime()
	ParentTable["TE"].Paint = function( TE )
	end
	ParentTable["TE"].OnLoseFocus = function( TE )
		TE:RequestFocus()
	end
	ParentTable["TE"].AllowInput = function( selfD, stringValue )
		local Password = self:GetMemory( "Password" ) .. stringValue
		if ( #Password > 16 ) then return end
		self:SetMemory( "Password", Password )
		LocalPlayer():EmitSound("terminalr/char/" .. math.random( 1, 5 ) .. ".wav" )
		return true
	end
	ParentTable["TE"].Think = function( selfD )
		if ( CurTime() > selfD.NextTyping ) then
			if ( input.IsKeyDown( 66 ) ) then
				local Password = self:GetMemory( "Password" )
				if ( #Password <= 0 ) then return end
				local NewText = string.sub( Password, 0, #Password -1 )
				self:SetMemory( "Password", NewText)
				LocalPlayer():EmitSound("terminalr/char/" .. math.random( 1, 5 ) .. ".wav" )
				selfD.NextTyping = CurTime() + 0.1
			elseif ( input.IsKeyDown( 64 ) ) then
				local Password = self:GetMemory( "Password" )
				if ( Password == self:GetMemory( "DiskPass" ) ) then
					local BP = self:GetMemory( "BlockedProgram" )
					self:RemoveAllMemoryNamed( { "Password", "BlockedProgram" } )
					LocalPlayer():EmitSound( "terminalr/passgood.wav" )
					self:LaunchProgram( BP )
				else
					self:SetMemory( "Password", "" )
					self:SetMemory("WrongAlpha", 255)
					LocalPlayer():EmitSound( "terminalr/passbad.wav" )
				end
				selfD.NextTyping = CurTime() + 0.5
			end
		end
	end
	ParentTable["TE"]:RequestFocus()
	
	
	local SW, SH = TerminalRGetTextSize( TerminalR.Lang.Cancel, "TrmR_Medium" )
	local Cancel = self:CreateMenuButton( "Cancel", TerminalR.Lang.Cancel )
	Cancel:SetPos( W*0.01, H*0.94 )
	Cancel:SetSize( SW + 40, SH + 10 )
	Cancel.DoClick = function( selfB )
		self:LaunchProgram( "menu" )
	end
	
	
end

TerminalR.Programs["password_check"].Paint = function( self, w, h )
	draw.SimpleText( "Insert the password", "TrmR_Large", w*0.5, h*0.35, Color( 0, math.random(210,255), 0 ), 1, 0 )
	local RNum = math.random(210,255)
	draw.SimpleText( "> " .. self:GetMemory("Password") .. " <", "TrmR_Large", w*0.5, h*0.45, Color( RNum, RNum, RNum, 255), 1, 0 )
	draw.SimpleText( "INVALID PASSWORD", "TrmR_Medium", w*0.5, h*0.3, Color( RNum, 0, 0, self:GetMemory("WrongAlpha") ), 1, 0 )
end

TerminalR.Programs["password_check"].Think = function( self, dt )

end

TerminalR.Programs["password_check"].Launch = function( self )
	self:RemoveAllMemoryNamed( { "WrongAlpha", "Password" } )
	self:RemoveParent()
end