TerminalR.Programs["loading"] = {}

TerminalR.Programs["loading"].Init = function( self )
	self:SetMemoryIfEmpty( "LoadingPercent", 0 )
	self:SetMemoryIfEmpty( "LoadingAmount", 1 )
	self:SetMemoryIfEmpty( "NextThink", 0 )
	self:SetMemoryIfEmpty( "BlackScreenAlpha", 0 )
	self:SetMemoryIfEmpty( "TitleScreenAlpha", 0 )
	self:SetMemoryIfEmpty( "TitleScreenPosX", 0 )
	self:SetMemoryIfEmpty( "TitleScreenPosY", 0 )
	
	local LoadingText = { 
		[0] = "...",
		[1] = "Loading OS ...",
		[2] = "Reading the OS Disk ...",
		[3] = "Prepare for the installation ...",
		[4] = "Installing the OS ...",
		[5] = "Writing on the HardWare (1/3) ...",
		[6] = "Writing on the HardWare (2/3) ...",
		[7] = "Writing on the HardWare (3/3) ...",
		[8] = "Loading Hardware ...",
		[9] = "Finishing Installing ...",
		[10] = "Lauching ..."
	}
	self:SetMemoryIfEmpty( "Text", LoadingText )
end

TerminalR.Programs["loading"].Paint = function( self, w, h )
	local Percent = math.Clamp( self:GetMemory( "LoadingPercent" ), 0, 100 )
	draw.RoundedBox( 0, 0, 0, w, h, Color( 0, math.random(0,15), 0 ) )
	draw.RoundedBox( 0, w*0.2, h*0.5, w*0.6, h*0.05, Color(30,30,30) )
	draw.RoundedBox( 0, w*0.2, h*0.5, (Percent/100)*(w*0.6), h*0.05, Color(0,math.random(200,255),0) )

	local Text = self:GetMemory( "Text" )[ math.Round( Percent * 0.1  ) ]
	draw.DrawText( Text, "TrmR_Medium", ScrW() * 0.5, ScrH() * 0.45, Color( 0, math.random(210,255), 0, 255 ), 1 )
	draw.DrawText( "(" .. Percent .. ") %", "TrmR_Medium", ScrW() * 0.5, ScrH() * 0.575, Color( 0, math.random(210,255), 0, 255 ), 1 )
	draw.DrawText( "Terminal Installation", "TrmR_Title", ScrW() * 0.5, ScrH() * 0.2, Color( 0, math.random(210,255), 0, 255 ), 1 )
	
	local BAplha = self:GetMemory( "BlackScreenAlpha" )
	local TAplha = self:GetMemory( "TitleScreenAlpha" )
	
	local PosX = Lerp( self:GetMemory( "TitleScreenPosX" ), w ,w*0.05 )
	local PosY = Lerp( self:GetMemory( "TitleScreenPosY" ), h*0.025 ,h*0.025 )
	
	draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, BAplha ) )
	draw.DrawText( "Terminal Menu", "TrmR_Title", PosX, PosY, Color( 0, math.random(210,255), 0, TAplha ), 0, 0 )
end

TerminalR.Programs["loading"].Think = function( self, dt )
	if ( self:GetMemory("LoadingPercent") < 100 ) then
		if ( CurTime() > self:GetMemory( "NextThink" ) ) then
			self:SetMemory( "LoadingPercent", self:GetMemory("LoadingPercent") + self:GetMemory( "LoadingAmount" ) )
			self:SetMemory( "LoadingAmount", math.random(1, 10) )
			if ( math.random( 1, 100 ) > 80 ) then
				self:SetMemory( "NextThink", CurTime() + math.random( 5, 15 ) / 10 )
			else
				self:SetMemory( "NextThink", CurTime() + 0.08 )
			end
		end
	else
		self:SetMemory( "BlackScreenAlpha", self:GetMemory("BlackScreenAlpha") + ( dt * 125 ) )
		if ( self:GetMemory("BlackScreenAlpha") > 255 ) then
			self:SetMemory( "TitleScreenAlpha", self:GetMemory("TitleScreenAlpha") + ( dt * 255 ) )
			self:SetMemory( "TitleScreenPosX", self:GetMemory("TitleScreenPosX") + ( dt * 0.3 ) )
			self:SetMemory( "TitleScreenPosY", self:GetMemory("TitleScreenPosY") + ( dt * 0.3 ) )
			if ( self:GetMemory("BlackScreenAlpha") > 750 ) then
				self:RemoveAllMemoryNamed( {"TitleScreenAlpha", "TitleScreenPosX", "TitleScreenPosY", "BlackScreenAlpha", "LoadingPercent", "LoadingAmount", "NextThink", "Text"} )
				self:LaunchProgram( "menu" )
			end
		end
	end
end

TerminalR.Programs["loading"].OnRemove = function( self )
	self:RemoveMemory( "Text" )
end