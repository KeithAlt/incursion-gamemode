local TERMINAL = {}

-- Called when the panel is created
function TERMINAL:Init()
	if ( TerminalDFrame ) then 
		TerminalDFrame:Remove() 
	end
	TerminalDFrame = self
	self:SetPos( 0, 0 )
	self:SetSize( ScrW(), ScrH() )
	self:SetTitle( "" )
	-- self:ShowCloseButton( false )
	self:MakePopup()
	self.ParentTable = {}
	self.RefreshUse = CurTime()
	self.EntIndex = 0
	self.Memory = {}
	self.Key = ""
end

-- The draw function
function TERMINAL:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0 ) )	
	if ( TerminalR.Programs[self.Key].Paint ) then
		TerminalR.Programs[self.Key].Paint( self, w, h )
	end
	-- draw.DrawText( "[Key] : " .. self.Key .. " [EntIndex] : " .. self.EntIndex, "ChatFont", 5, 5, Color( 255, 255, 255, 255 ), 0 )
end

-- The draw over the draw function
function TERMINAL:PaintOver()
	if (TerminalR.Programs[self.Key] and TerminalR.Programs[self.Key].PaintOver ) then
		TerminalR.Programs[self.Key].PaintOver( self, w, h )
	end
end

-- The think function
function TERMINAL:Think()
	if ( CurTime() > self.RefreshUse ) then
		if ( ents.GetByIndex( self.EntIndex ):GetNWBool( "Terminal:Destroy" ) ) then self:Remove() end
		if ( ents.GetByIndex( self.EntIndex ) == NULL ) then self:Remove() end
		if ( self.EntIndex == 0 ) then
			print("CRITICAL ERROR")
			return
		end
		net.Start( "Net_TerminalR:RefreshUse")
			net.WriteInt( self.EntIndex, 32 )
		net.SendToServer()
		self.RefreshUse = CurTime() + 2
	end
	
	if ( TerminalR.Programs[self.Key].Think ) then
		TerminalR.Programs[self.Key].Think( self, FrameTime() )
	end
end

-- Launch a program to set the KEY and use the Init program
function TERMINAL:LaunchProgram( key )
	if ( self.Key ) then
		if ( TerminalR.Programs[self.Key] ) then
			if ( TerminalR.Programs[self.Key].Launch ) then
				TerminalR.Programs[self.Key].Launch( self ) 
			end
		end
	end
	
	self.Key = key
	TerminalR.Programs[self.Key].Init( self )
end

-- Sync the server data to the client panel
function TERMINAL:SetupTerminal( entIndex, key, memory )
	if ( not entIndex ) then return end
	if ( not key ) then return end
	
	self.EntIndex = entIndex
	self.Memory = ( memory or self.Memory )
	self:LaunchProgram( key )
end

-- Get a value from the panel memory
function TERMINAL:GetMemory(index)
	return self.Memory[index]
end

-- Set a value for the panel memory
function TERMINAL:SetMemory( index, value )
	self.Memory[index] = value
	return index
end

-- Remove a value from the panel memory
function TERMINAL:RemoveMemory( index )
	self.Memory[index] = nil
end

-- Remove all value from the panel memory
function TERMINAL:ResetMemory( index )
	self.Memory = {}
end

function TERMINAL:RemoveAllMemoryExpect( exception )
	for k , v in pairs ( self.Memory ) do
		if ( not table.HasValue( exception, k ) ) then
			self.Memory[k] = nil
		end
	end
end

function TERMINAL:RemoveAllMemoryNamed( exception )
	for k , v in pairs ( self.Memory ) do
		if ( table.HasValue( exception, k ) ) then
			self.Memory[k] = nil
		end
	end
end

-- Set a value for the panel memory ( if the value dosn't exist )
function TERMINAL:SetMemoryIfEmpty( index, value )
	if ( not self.Memory[index] ) then
		self.Memory[index] = value
		return index
	end
end

-- Get the parent table
function TERMINAL:GetParentTable()
	return self.ParentTable
end

-- Remove all Frame who are parent to the terminal frame
function TERMINAL:RemoveParent()
	for k , v in pairs ( self.ParentTable ) do
		v:Remove()
	end
end

-- Called when the frame is close
function TERMINAL:OnRemove()
	if ( TerminalR.Programs[self.Key].OnRemove ) then
		TerminalR.Programs[self.Key].OnRemove( self ) 
	end

	-- Sync with the server entity
	if ( self.EntIndex ~= 0 ) then
	local NTab = {
		Key = self.Key,
		Memory = self.Memory,
		EntIndex = self.EntIndex
	}
	net.Start("Net_TerminalR:RefreshTerminal")
		net.WriteTable( NTab )
	net.SendToServer()
	end
end

-- Create a button for the menu
function TERMINAL:CreateMenuButton( index, text )
	local W, H = ScrW(), ScrH()
	local DButton = self:CreateButton( index )
	DButton:SetText( "" )
	DButton.Alpha = 0
	DButton.Paint = function( selfB, w, h )
		draw.SimpleText( text, "TrmR_Medium", 20, 5 + math.random( -H*0.005, H*0.005 ), Color( 0, 255, 0, ( selfB.Alpha * 2 ) ), 0, 0 )
		draw.SimpleText( text, "TrmR_Medium", 20, 5, Color( 0, 255, 0 ), 0, 0 )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 255, 0, selfB.Alpha ) )
	end
	DButton.OnCursorEntered = function ( selfB )
		surface.PlaySound( "terminalr/hovered.wav" )
		selfB.Alpha = 25
	end
	DButton.OnCursorExited = function ( selfB )
		selfB.Alpha = 0
	end
	return DButton
end

-- Turn off the terminal ( Server side )
function TERMINAL:TurnOff()
	if ( self.EntIndex ~= 0 ) then
		net.Start("Net_TerminalR:TurnOff")
			net.WriteInt( self.EntIndex, 32 )
		net.SendToServer()
	end
end

function TERMINAL:CreateButton( name )
	if ( self.ParentTable[name] ) then
		self.ParentTable[name]:Remove()
	end
	self.ParentTable[name] = vgui.Create( "DButton", self )
	return self.ParentTable[name]
end

function TERMINAL:OnKeyCodePressed( key )
	if ( TerminalR.Programs[self.Key].OnKeyCodePressed ) then
		TerminalR.Programs[self.Key].OnKeyCodePressed( self, key )
	end
end

function TERMINAL:OnKeyCodeReleased( key )
	if ( TerminalR.Programs[self.Key].OnKeyCodeReleased ) then
		TerminalR.Programs[self.Key].OnKeyCodeReleased( self, key )
	end
end

--gets the current inserted disk's data
function TERMINAL:getDiskData()
	local data = {
		text = self.Memory.DiskText,
		title = self.Memory.DiskTitle,
		author = self.Memory.DiskAuthor,
		editor = self.Memory.DiskEditor,
		printer = self.Memory.DiskPrinter,
		pass = self.Memory.DiskPass,
		encrypt = self.Memory.Encrypt,
	}
	
	return data
end

function TERMINAL:OnMousePressed()
end
function TERMINAL:OnMouseReleased()
end
function TERMINAL:OnMouseWheeled()
end
function TERMINAL:OnChildAdded()
	
end

vgui.Register( "TerminalFrame", TERMINAL, "DFrame" )