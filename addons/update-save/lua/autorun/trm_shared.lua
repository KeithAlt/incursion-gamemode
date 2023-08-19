TerminalR = {}

if ( CLIENT ) then
	TerminalR.Version = "00002"
	TerminalR.Programs = {}
end

if ( SERVER ) then
	TerminalR.Save = {}
	TerminalR.NextSave = CurTime() + 240
end

local files, directories = file.Find( "terminalr/*", "LUA" )
for k , v in pairs ( files ) do
	if ( SERVER ) then
		if ( string.sub( v, 1, 3 ) == "cl_" ) then
			AddCSLuaFile( "terminalr/" .. v )
		elseif ( string.sub( v, 1, 3 ) == "sv_" ) then
			include( "terminalr/" .. v )
		elseif ( string.sub( v, 1, 3 ) == "sh_" ) then
			AddCSLuaFile( "terminalr/" .. v )
			include( "terminalr/" .. v )
		end
	end
	if ( CLIENT ) then
		include( "terminalr/" .. v  )
	end
end

local files, directories = file.Find( "terminalr/programs/*", "LUA" )
for k , v in pairs ( files ) do
	MsgC( Color( 0, 255, 0 ), "[Terminal] Program added : " .. v .."\n" )
	if ( SERVER ) then
		AddCSLuaFile( "terminalr/programs/" .. v )
	end
	if ( CLIENT ) then
		include( "terminalr/programs/" .. v  )
	end
end


















