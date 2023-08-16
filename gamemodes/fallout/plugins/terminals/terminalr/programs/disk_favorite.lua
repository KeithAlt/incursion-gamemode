TerminalR.Programs["disk_favorite"] = {}

TerminalR.Programs["disk_favorite"].Init = function( self )
	self:SetMemoryIfEmpty( "CharPosX", 0 )
	self:SetMemoryIfEmpty( "CharLine", 1 )
	self:SetMemoryIfEmpty( "LineDistance", ScrH()*0.05 )
	--self:SetMemoryIfEmpty( "DiskText", {} )
	self:SetMemory( "CamY", 0 )
	
	local SW, SH = TerminalRGetTextSize("> SAVE INSERTED DISK", "TrmR_Medium")
	local fav = self:CreateMenuButton("Save", "> SAVE INSERTED DISK")
	fav:SetPos(ScrW()*0.01, ScrH()*0.05)
	fav:SetSize(SW + 40, SH + 10)
	fav.DoClick = function(selfB)
		self:RemoveParent()
		self:LaunchProgram("menu")
	end	
	
	local disks = nut.plugin.list["terminals"]:getFavoriteDisk(LocalPlayer())
	
	local scrW = ScrW()
	local scrH = ScrH()
	
	local bottomH = scrH * 0.85
	
	for k, v in pairs(disks) do
		local name
	
		--no idea why titles can be tables
		if(istable(v.title)) then
			name = v.title[1]
		else
			name = v.title
		end
		
		if(!name) then
			name = "Disk"
		end
		
		local SW, SH = TerminalRGetTextSize(name, "TrmR_Medium")
		local fav = self:CreateMenuButton(string.lower(name..k), name)
		
		local yPos = scrH*(0.1 + 0.05*k)
		local xPos = scrW*0.01

		if(yPos < bottomH) then
			xPos = scrW*0.01
		elseif(yPos > bottomH) then
			xPos = scrW*0.41
			yPos = scrH*(0.1 + 0.05*(k - 15))
		end
		
		fav:SetPos(xPos, yPos)
		fav:SetSize(SW + 40, SH + 10)
		fav.DoClick = function(selfB)
			self:RemoveParent()
			
			self:SetMemory("DiskTextF", v.content)
			self:SetMemory("Favorite", v)
			self:SetMemory("FavoriteID", k)
			
			self:LaunchProgram("disk_read_f")
		end
	end
	
	local SW, SH = TerminalRGetTextSize("> BACK", "TrmR_Medium")
	local back = self:CreateMenuButton("Back", "> BACK")
	back:SetPos(ScrW()*0.01, ScrH()*0.925)
	back:SetSize(SW + 40, SH + 10)
	back.DoClick = function( selfB )
		self:RemoveParent()
		self:LaunchProgram("menu")
	end
		
	local ParentTable = self:GetParentTable()
	ParentTable["TE"] = vgui.Create("DTextEntry", self)
	ParentTable["TE"]:SetText("")
	ParentTable["TE"]:SetSize(1, 1)
	ParentTable["TE"].NextTyping = CurTime() + 1
	ParentTable["TE"].Paint = function(TE)
	end
	ParentTable["TE"].OnLoseFocus = function(TE)
		TE:RequestFocus()
	end
	ParentTable["TE"].AllowInput = function( selfD, stringValue )
		local Text = self:GetMemory("DiskText")[self:GetMemory("CharLine")] or ""
		local CharX = self:GetMemory( "CharPosX" )
		local NewText = string.sub(Text, 0, CharX) ..stringValue.. string.sub(Text, CharX + 2, 9000)
		
		surface.SetFont( "TrmR_Medium" )
		local Size = surface.GetTextSize( NewText )
		if ( Size > ScrW()*0.8 ) then
			return
		end
		self:GetMemory("DiskText")[self:GetMemory("CharLine")] = NewText
		self:SetMemory( "CharPosX", self:GetMemory( "CharPosX" ) + 1 )
		
		LocalPlayer():EmitSound("terminalr/char/" .. math.random( 1, 5 ) .. ".wav" )
		return false
	end
	
	ParentTable["TE"].Think = function( selfD )
		if ( CurTime() > selfD.NextTyping ) then
		--[[
			local Text = self:GetMemory("DiskText")[self:GetMemory("CharLine")]
			if ( input.IsKeyDown( 73 ) ) then -- Suppr
				LocalPlayer():EmitSound( "terminalr/enter" .. math.random( 1, 3 ) .. ".wav" )
				local CharX = self:GetMemory( "CharPosX" )
				if ( string.sub( Text, CharX + 1, CharX + 1 ) == "" and CharX == 0 ) then
					if ( #self:GetMemory("DiskText") < 2 ) then return end
					table.remove( self:GetMemory("DiskText"), self:GetMemory("CharLine") )
					if ( self:GetMemory("CharLine") <= 1 ) then
						self:SetMemory( "CharLine", 1)
					elseif ( self:GetMemory("CharLine") > #self:GetMemory("DiskText") ) then
						self:SetMemory( "CharLine", self:GetMemory( "CharLine" ) - 1 )
					end
					selfD.NextTyping = CurTime() + 0.1
					return
				end
				local NewText = string.sub( Text, 0, CharX ) .. string.sub( Text, CharX + 2, 9000  )
				self:GetMemory("DiskText")[self:GetMemory("CharLine")] = NewText
				LocalPlayer():EmitSound("terminalr/char/" .. math.random( 1, 5 ) .. ".wav" )
				selfD.NextTyping = CurTime() + 0.1
			elseif ( input.IsKeyDown( 64 ) ) then -- Enter
				LocalPlayer():EmitSound( "terminalr/enter" .. math.random( 1, 3 ) .. ".wav" )
				local NewLine = self:GetMemory( "CharLine" ) + 1
				self:SetMemory( "CharLine", NewLine )
				self:SetMemory( "CharPosX", 0 )
				if ( not self:GetMemory( "DiskText" )[NewLine] ) then
					self:GetMemory( "DiskText" )[NewLine] = "-"
				end
				selfD.NextTyping = CurTime() + 0.3
			elseif ( input.IsKeyDown( 91 ) ) then -- Go RIGHT
				if ( self:GetMemory( "CharPosX" ) >= #Text ) then return end
				self:SetMemory( "CharPosX", self:GetMemory( "CharPosX" ) + 1 )
				selfD.NextTyping = CurTime() + 0.1
			elseif ( input.IsKeyDown( 89 ) ) then -- Go LEFT
				if ( self:GetMemory( "CharPosX" ) <= 0 ) then return end
				self:SetMemory( "CharPosX", self:GetMemory( "CharPosX" ) - 1 )
				selfD.NextTyping = CurTime() + 0.1
			elseif ( input.IsKeyDown( 90 ) ) then -- Go DOWN
				local NewLine = self:GetMemory( "CharLine" ) + 1
				self:SetMemory( "CharLine", NewLine )
				self:SetMemory( "CharPosX", 0 )
				if ( not self:GetMemory( "DiskText" )[NewLine] ) then
					self:GetMemory( "DiskText" )[NewLine] = "-"
				end
				selfD.NextTyping = CurTime() + 0.2
			elseif ( input.IsKeyDown( 88 ) ) then -- Go UP
				local NewLine = self:GetMemory( "CharLine" ) - 1
				if ( NewLine <= 0 ) then return end
				self:SetMemory( "CharLine", NewLine )
				self:SetMemory( "CharPosX", 0 )
				selfD.NextTyping = CurTime() + 0.2
			elseif ( input.IsKeyDown( 66 ) ) then -- Delete
				LocalPlayer():EmitSound( "terminalr/enter" .. math.random( 1, 3 ) .. ".wav" )
				local CharX = self:GetMemory( "CharPosX" )
				if ( CharX <= 0 ) then return end
				local NewText = string.sub( Text, 0, CharX -1 ) .. string.sub( Text, CharX+1, 9000  )
				self:SetMemory( "CharPosX", CharX - 1 )
				self:GetMemory("DiskText")[self:GetMemory("CharLine")] = NewText
				LocalPlayer():EmitSound("terminalr/char/" .. math.random( 1, 5 ) .. ".wav" )
				selfD.NextTyping = CurTime() + 0.1	
			elseif ( input.IsMouseDown( MOUSE_LEFT ) ) then
				local NewCamY = self:GetMemory("CamY") + self:GetMemory("LineDistance")
				if ( #self:GetMemory( "DiskText" ) < 10 ) then return end
				if ( NewCamY > #self:GetMemory( "DiskText" ) * self:GetMemory( "LineDistance" ) ) then return end
				self:SetMemory( "CamY", NewCamY )
				selfD.NextTyping = CurTime() + 0.1	
			elseif ( input.IsMouseDown( MOUSE_RIGHT ) ) then
				local NewCamY = self:GetMemory("CamY") - self:GetMemory("LineDistance")
				if ( NewCamY < 0 ) then return end
				self:SetMemory( "CamY", NewCamY )
				selfD.NextTyping = CurTime() + 0.1	
			end
		--]]
		end
	end
	ParentTable["TE"]:RequestFocus()
end

TerminalR.Programs["disk_favorite"].OnRemove = function( self )
	self:RemoveAllMemoryNamed( { "CharPosX", "CharLine", "LineDistance", "CamY" } )
end

TerminalR.Programs["disk_favorite"].Paint = function( self, w, h )
	--[[
	local Text = self:GetMemory("DiskText")[self:GetMemory("CharLine")]
	local CharX = self:GetMemory( "CharPosX" )
	local CharLine = self:GetMemory( "CharLine" )
	
	render.SetScissorRect( 0, 0, w, h*0.9, true )
	local posy = self:GetMemory( "LineDistance" )
	for k , v in pairs ( self:GetMemory("DiskText") ) do
		local CamY = self:GetMemory( "CamY" )
		draw.DrawText( v, "TrmR_Medium", w*0.05, posy - CamY, Color( 0, math.random(210,255), 0, 255 ), 0 )
		posy = ( posy + self:GetMemory( "LineDistance" ) )
	end

	surface.SetFont( "TrmR_Medium" )
	local MC = ( self:GetMemory("CamY") / self:GetMemory("LineDistance") )
	local PDD = string.sub( Text, 0, CharX  )
	local PDDT = surface.GetTextSize( PDD )
	local CS = string.sub( Text, CharX + 1, CharX + 1 )
	local TX, TY = surface.GetTextSize( CS )
	-- local AVS = string.sub( Text, 0, CharX )
	-- local APS = string.sub( Text, CharX + 2, 9000  )
	
	-- DEBUG VALUE
	-- draw.RoundedBox( 0, 10,30, 125, 230, Color( 110, 110, 110, 100 ) )
	-- draw.DrawText( "TS : " .. #Text, "TrmR_Small", 20, 40, Color( 0, math.random(210,255), 0, 255 ), 0 )
	-- draw.DrawText( "CX : " .. CharX, "TrmR_Small", 20, 60, Color( 0, math.random(210,255), 0, 255 ), 0 )
	-- draw.DrawText( "CL : " .. CharLine, "TrmR_Small", 20, 80, Color( 0, math.random(210,255), 0, 255 ), 0 )
	-- draw.DrawText( "PDD : " .. PDD, "TrmR_Small", 20, 100, Color( 0, math.random(210,255), 0, 255 ), 0 )
	-- draw.DrawText( "PDDT : " .. PDDT, "TrmR_Small", 20, 120, Color( 0, math.random(210,255), 0, 255 ), 0 )
	-- draw.DrawText( "CS : " .. CS, "TrmR_Small", 20, 140, Color( 0, math.random(210,255), 0, 255 ), 0 )
	-- draw.DrawText( "AVS : " .. AVS, "TrmR_Small", 20, 160, Color( 0, math.random(210,255), 0, 255 ), 0 )
	-- draw.DrawText( "APS : " .. APS, "TrmR_Small", 20, 180, Color( 0, math.random(210,255), 0, 255 ), 0 )
	-- draw.DrawText( "TX : " .. TX, "TrmR_Small", 20, 200, Color( 0, math.random(210,255), 0, 255 ), 0 )
	-- draw.DrawText( "TY : " .. TY, "TrmR_Small", 20, 220, Color( 0, math.random(210,255), 0, 255 ), 0 )
	-- draw.DrawText( "Line :" .. #self:GetMemory( "DiskText" ), "TrmR_Small", 20, 240, Color( 0, math.random(210,255), 0, 255 ), 0 )
	
	if ( TX <= 0 ) then	TX = surface.GetTextSize( "X" ) end	
	draw.RoundedBox( 0, w*0.05 + PDDT, (h*0.05 + ( self:GetMemory("CharLine") - 1 ) * h*0.05) - self:GetMemory("CamY") , TX, TY, Color( 0, math.random(200,255), 0, 100 ) )
	render.SetScissorRect( 0, 0, 0, 0, false )
	draw.DrawText( MC .. "/" .. #self:GetMemory("DiskText"), "TrmR_Medium", w*0.5, h*0.94, Color( 0, math.random(210,255), 0, 255 ), 1, 1)
	--]]
end