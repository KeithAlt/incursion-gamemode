TerminalR.Programs["disk_read_f"] = {}

TerminalR.Programs["disk_read_f"].Init = function( self )
	local favoriteData = self:GetMemory("Favorite")

	if (!favoriteData) then
		self:LaunchProgram( "menu" )
		return
	end
	
	self:SetMemoryIfEmpty( "CharLine", 1 )
	self:SetMemoryIfEmpty( "LineDistance", ScrH()*0.05 )
	--self:SetMemoryIfEmpty( "DiskTextF", {} )
	self:SetMemory( "CamY", 0 )
	
	local SW, SH = TerminalRGetTextSize( "> " .. TerminalR.Lang.Cancel, "TrmR_Medium" )
	local MenuButton = self:CreateMenuButton( "WriteOnDisk", "> " .. TerminalR.Lang.Cancel )
	MenuButton:SetPos( ScrW()*0.01, ScrH()*0.925 )
	MenuButton:SetSize( SW + 40, SH + 10 )
	MenuButton.DoClick = function( selfB )
		self:RemoveParent()
		self:RemoveAllMemoryNamed( { "CharPosX", "CharLine", "LineDistance", "CamY" } )
		self:LaunchProgram( "menu" )
	end	
	
	--print disk
	local SW, SH = TerminalRGetTextSize("> Print", "TrmR_Medium")
	local MenuButton = self:CreateMenuButton("PrintDisk", "> Print")
	MenuButton:SetPos(ScrW()*0.24, ScrH()*0.925)
	MenuButton:SetSize(SW + 40, SH + 10)
	MenuButton.DoClick = function(selfB)
		self:RemoveParent()
		self:RemoveAllMemoryNamed({ "CharPosX", "CharLine", "LineDistance", "CamY" })
		self:LaunchProgram("menu")
		
		local info = favoriteData
		info.printer = LocalPlayer():Name()
		netstream.Start("foDiskPrint", self.EntIndex, info, true)
		--print a new disk item here
	end	
	
	local SW, SH = TerminalRGetTextSize("> Delete", "TrmR_Medium")
	local MenuButton = self:CreateMenuButton("Delete", "> Delete")
	MenuButton:SetPos(ScrW()*0.8, ScrH()*0.925)
	MenuButton:SetSize(SW + 40, SH + 10)
	MenuButton.DoClick = function(selfB)
		self:RemoveParent()
		self:RemoveAllMemoryNamed({ "CharPosX", "CharLine", "LineDistance", "CamY" })
		self:LaunchProgram("menu")
		
		local InfoID = self:GetMemory("FavoriteID")
		nut.plugin.list["terminals"]:favoriteRemove(InfoID)
		--remove disk from favorites
	end
	
	local ParentTable = self:GetParentTable()
	ParentTable["TE"] = vgui.Create( "DTextEntry", self )
	ParentTable["TE"]:SetText( "" )
	ParentTable["TE"]:SetSize( 1, 1 )
	ParentTable["TE"].NextTyping = CurTime()
	ParentTable["TE"].Paint = function( TE )
	end
	ParentTable["TE"].OnLoseFocus = function( TE )
		TE:RequestFocus()
	end
	
	ParentTable["TE"].Think = function( selfD )
		--prevents afk kicks
		if((self.nextAntiAFK or 0) < CurTime()) then
			self.nextAntiAFK = CurTime() + 60
			netstream.Start("terminalAFKRefresh")
		end
	
		if ( CurTime() > selfD.NextTyping ) then
			local Text = favoriteData.text--self:GetMemory("DiskTextF")[self:GetMemory("CharLine")]
			if ( input.IsMouseDown( MOUSE_LEFT ) ) then
				local NewCamY = self:GetMemory("CamY") + self:GetMemory("LineDistance")
				if ( #Text < 10 ) then return end
				if ( NewCamY > #Text * self:GetMemory( "LineDistance" ) ) then return end
				self:SetMemory( "CamY", NewCamY )
				selfD.NextTyping = CurTime() + 0.1	
			elseif ( input.IsMouseDown( MOUSE_RIGHT ) ) then
				local NewCamY = self:GetMemory("CamY") - self:GetMemory("LineDistance")
				if ( NewCamY < 0 ) then return end
				self:SetMemory( "CamY", NewCamY )
				selfD.NextTyping = CurTime() + 0.1	
			end
		end
	end
	ParentTable["TE"]:RequestFocus()
end

TerminalR.Programs["disk_read_f"].Paint = function( self, w, h )
	local favoriteData = self:GetMemory("Favorite")
	
	if(favoriteData) then
		local Text = favoriteData.text--[self:GetMemory("CharLine")]--self:GetMemory("DiskTextF")[self:GetMemory("CharLine")]
		local CharX = self:GetMemory( "CharPosX" )
		local CharLine = self:GetMemory( "CharLine" )
		-- draw.DrawText( Text, "TrmR_Medium", 200, 200, Color( 0, math.random(210,255), 0, 255 ), 0 )
		
		render.SetScissorRect( 0, 0, w, h*0.9, true )
		local posy = self:GetMemory( "LineDistance" )
		for k , v in pairs (Text) do
			local CamY = self:GetMemory( "CamY" )
			draw.DrawText( v, "TrmR_Medium", w*0.05, posy - CamY, Color( 0, math.random(210,255), 0, 255 ), 0 )
			posy = ( posy + self:GetMemory( "LineDistance" ) )
		end
		render.SetScissorRect( 0, 0, 0, 0, false )
		
		local AC = self:GetMemory( "CamY", 0 ) -- Actual Cam
		local MC = ( self:GetMemory("CamY") / self:GetMemory("LineDistance") ) -- Max Cam
		draw.DrawText( MC .. "/" .. #Text, "TrmR_Medium", w*0.5, h*0.94, Color( 0, math.random(210,255), 0, 255 ), 1, 1)
	end
end

TerminalR.Programs["disk_read_f"].OnRemove = function( self )
	self:RemoveAllMemoryNamed( { "CharPosX", "CharLine", "LineDistance", "CamY" } )
end

TerminalR.Programs["disk_read_f"].Launch = function( self )
	self:RemoveParent()
	self:RemoveAllMemoryNamed( { "CharPosX", "CharLine", "LineDistance", "CamY" } )
end