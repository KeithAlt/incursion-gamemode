

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

function TerminalROpenDiskMenu( index )
	if ( RenameDiskFrame ) then return end
	local W, H = ScrW(), ScrH()
	RenameDiskFrame = vgui.Create( "DFrame" )
	RenameDiskFrame:SetSize( W*0.25, H*0.4 )
	RenameDiskFrame:Center()
	RenameDiskFrame:MakePopup()
	RenameDiskFrame.ParentList = {}
	RenameDiskFrame.OnRemove = function( self )
		local P = self.ParentList
		local NTab = {
			[1] = P.TE1:GetValue(),
			[2] = P.TE2:GetValue(),
			[3] = P.TE3:GetValue(),
			[4] = P.TE4:GetValue(),
			[5] = P.TE5:GetValue(),
			[6] = P.TE6:GetValue()
		}
		net.Start( "Net_TerminalR:RenameDisk")
			net.WriteInt( index, 32 )
			net.WriteTable( NTab )
		net.SendToServer()
		RenameDiskFrame = nil
	end

	local x, y = W*0.025, H*0.05
	for i = 1, 6 do
		RenameDiskFrame.ParentList["TE" .. i] = vgui.Create( "DTextEntry", RenameDiskFrame )
		RenameDiskFrame.ParentList["TE" .. i]:SetPos( x, y )
		RenameDiskFrame.ParentList["TE" .. i]:SetSize( W*0.2, H*0.025 )
		RenameDiskFrame.ParentList["TE" .. i]:SetText( "" )

		y = y + H *0.05
	end
end


function TerminalRDiskView( ply, pos, angles, fov )
	if ( input.IsKeyDown( KEY_E ) and input.IsKeyDown( KEY_R ) ) then
		if ( IsValid(ply:GetEyeTraceNoCursor().Entity) and ply:GetEyeTraceNoCursor().Entity:GetClass() == "trm_disk" ) then
			local Entity = ply:GetEyeTraceNoCursor().Entity
			Entity:OpenMenu()
		end
	elseif ( input.IsKeyDown( KEY_E ) ) then
		if ( IsValid(ply:GetEyeTraceNoCursor().Entity) and ply:GetEyeTraceNoCursor().Entity:GetClass() == "trm_disk" ) then
			local Entity = ply:GetEyeTraceNoCursor().Entity
			if ( Entity.RenameDiskFrame ) then return end
			if ( Entity:GetPos():Distance( ply:GetPos() + Vector( 0, 0, 50 ) ) > 90 ) then return end
			local Ang = Entity:GetAngles()
			Ang:RotateAroundAxis( Ang:Up(), 180 )
			local Pos = Entity:GetPos() + Entity:GetAngles():Forward() * 10 + Entity:GetAngles():Up() * 4
			local view = {}
			view.origin = Pos
			view.angles = Ang
			view.fov = fov
			view.drawviewer = true
			return view
		end
	end
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
