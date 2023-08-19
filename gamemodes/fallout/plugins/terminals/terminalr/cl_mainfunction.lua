

function TerminalRGetTextSize( text, font )
	surface.SetFont( font )
	local width, height = surface.GetTextSize( text )
	return width, height
end

function TerminalROpenStock()
	local NInt = net.ReadInt( 32 )
	local NTable = net.ReadTable()
	local ent = ents.GetByIndex( NInt )
	ent:OpenStock( NTable )
end

function OpenTermimalR()
	local NTable = net.ReadTable()
	local Terminal = vgui.Create( "TerminalFrame" ) 
	Terminal:SetupTerminal( NTable.EntIndex, NTable.Key, NTable.Memory )
end

function TerminalRCheckVersion()
	local function Succes( body, size, headers, code )
		local IDVPos = string.find( body:lower(), "idversion" )
		if ( not IDVPos ) then print("error") return end
		local IDV = string.sub( body, IDVPos + 10, IDVPos + 14 )
		if ( IDV ~= TerminalR.Version ) then
			chat.AddText( Color( 255, 0, 0 ), "[TerminalR] New update available !" )
		end
	end
	http.Fetch( "http://steamcommunity.com/sharedfiles/filedetails/?id=1187927646", Succes, function() end, {} )
end
TerminalRCheckVersion()


hook.Add( "CalcView", "TerminalDiskCalcView", TerminalRDiskView )