

function TerminalR.EjectDisk()
	local NInt = net.ReadInt( 32 )
	local NTable = net.ReadTable()
	local ent = ents.GetByIndex( NInt )
	if ( ent:GetClass() == "trm_terminal" ) then
		ent:EjectDisk( NTable )
	end
end	

function TerminalR.RefreshUse()
	local NInt = net.ReadInt( 32 )
	local ent = ents.GetByIndex( NInt )
	if ( ent:GetClass() == "trm_terminal" ) then
		ent:SetNWInt( "Terminal:InUse", CurTime() + 2 )
	elseif ( ent:GetClass() == "trm_stock" ) then
		ent:SetNWInt( "Stock:InUse", CurTime() + 2 )
	end
end

function TerminalR.EjectDiskStock()
	local NTable = net.ReadTable()
	local ent = ents.GetByIndex( NTable.EntIndex )
	if ( ent:GetClass() == "trm_stock" ) then
		ent:EjectDisk( NTable.DiskIndex )
	end
end

function TerminalR.TurnOff()
	local NInt = net.ReadInt( 32 )
	local ent = ents.GetByIndex( NInt )
	if ( ent:GetClass() == "trm_terminal" ) then
		ent:SetNWBool( "Terminal:O/F", false )	
		ent:EmitSound( "terminalr/turn_off.wav" )
	end
end

function TerminalR.EjectHackModule()
	local NInt = net.ReadInt( 32 )
	local ent = ents.GetByIndex( NInt )
	if ( ent:GetClass() == "trm_terminal" ) then
		ent:EjectHackModule()
	end
end

function TerminalR.PreCleanupMap()
	if ( not TerminalR.Config.CleanUpSave ) then return end
	TerminalR.Save = {}
	TerminalR.Save.Terminal = {}
	TerminalR.Save.Disk = {}
	TerminalR.Save.Stock = {}
	
	--[[
	for k, ent in pairs( ents.FindByClass( "trm_terminal" ) ) do
		
		if ( not ent.PermaProps ) then
			local Info = {}
			Info.Pos = ent:GetPos()
			Info.Ang = ent:GetAngles()
			Info.Memory = ent.Memory
			Info.HP = ent.HP
			Info.NetworkValue = {}
			Info.NetworkValue["O/F"] 	= 	ent:GetNWBool( "Terminal:O/F" )
			Info.NetworkValue["Key"] 	=	ent:GetNWString( "Terminal:Key" )
			Info.NetworkValue["InUse"] 	=	ent:GetNWInt( "Terminal:InUse" )
			Info.NetworkValue["Destroy"] =	ent:GetNWBool( "Terminal:Destroy" )
			table.insert( TerminalR.Save.Terminal, Info )
		end
	end
	--]]
	for k, ent in pairs( ents.FindByClass( "trm_disk" ) ) do
		if ( not ent.PermaProps ) then
			local Info = {}
			Info.Pos = ent:GetPos()
			Info.Ang = ent:GetAngles()
			Info.DiskText = ent.DiskText
			Info.DiskTitle = ent.DiskTitle
			Info.DiskPass = ( ent.DiskPass or nil )
			table.insert( TerminalR.Save.Disk, Info )
		end
	end
	for k, ent in pairs( ents.FindByClass( "trm_stock" ) ) do
		if ( not ent.PermaProps ) then
			local Info = {}
			Info.Pos = ent:GetPos()
			Info.Ang = ent:GetAngles()
			Info.Stock = ent.Stock
			table.insert( TerminalR.Save.Stock, Info )
		end
	end
end

function TerminalR.ShutDown()
	if ( not TerminalR.Config.PermaSave ) then return end
	local Save = {}
	Save.Terminal = {}
	Save.Stock = {}
	for k, ent in pairs( ents.FindByClass( "trm_terminal" ) ) do
		if ( not ent.PermaProps ) then
			local Info = {}
			Info.Pos = ent:GetPos()
			Info.Ang = ent:GetAngles()
			Info.Memory = ent.Memory
			Info.HP = ent.HP
			Info.NetworkValue = {}
			Info.NetworkValue["Destroy"] =	ent:GetNWBool( "Terminal:Destroy" )
			table.insert( Save.Terminal, Info )
		end
	end
	for k, ent in pairs( ents.FindByClass( "trm_stock" ) ) do
		if ( not ent.PermaProps ) then
			local Info = {}
			Info.Pos = ent:GetPos()
			Info.Ang = ent:GetAngles()
			Info.Stock = ent.Stock
			table.insert( Save.Stock, Info )
		end
	end
	local TableToJSON = util.TableToJSON( Save )
	file.Write( "TerminalSave" .. game.GetMap() .. ".txt", TableToJSON )
end

function TerminalR.Think()
	if ( not TerminalR.Config.PermaSave ) then return end
	if ( CurTime() > TerminalR.NextSave ) then
		local Save = {}
		Save.Terminal = {}
		Save.Stock = {}
		for k, ent in pairs( ents.FindByClass( "trm_terminal" ) ) do
			if ( not ent.PermaProps ) then
				local Info = {}
				Info.Pos = ent:GetPos()
				Info.Ang = ent:GetAngles()
				Info.Memory = ent.Memory
				Info.HP = ent.HP
				Info.NetworkValue = {}
				Info.NetworkValue["Destroy"] =	ent:GetNWBool( "Terminal:Destroy" )
				table.insert( Save.Terminal, Info )
			end
		end
		for k, ent in pairs( ents.FindByClass( "trm_stock" ) ) do
			if ( not ent.PermaProps ) then
				local Info = {}
				Info.Pos = ent:GetPos()
				Info.Ang = ent:GetAngles()
				Info.Stock = ent.Stock
				table.insert( Save.Stock, Info )
			end
		end
		local TableToJSON = util.TableToJSON( Save )
		file.Write( "TerminalSave" .. game.GetMap() .. ".txt", TableToJSON )
		TerminalR.NextSave = CurTime() + 60
	end
end

function TerminalR.InitPostEntity()
	if ( not TerminalR.Config.PermaSave ) then return end
	local Save = file.Read( "TerminalSave" .. game.GetMap() .. ".txt", "DATA" )
	local JSONToTable = util.JSONToTable( Save )
	for k, ent in pairs( JSONToTable.Terminal ) do
		local terminal = ents.Create( "trm_terminal" )
		terminal:SetPos( ent.Pos )
		terminal:SetAngles( ent.Ang )
		terminal:Spawn()
		terminal.Memory = ent.Memory
		terminal.HP = ent.HP
		terminal:SetNWBool( "Terminal:Destroy", ent.NetworkValue["Destroy"] )
		local phys = terminal:GetPhysicsObject()
		if ( phys:IsValid() ) then
			phys:Wake()
			phys:EnableMotion( false )
		end		
	end
	
	for k, ent in pairs( JSONToTable.Stock ) do
		local stock = ents.Create( "trm_stock" )
		stock:SetPos( ent.Pos )
		stock:SetAngles( ent.Ang )
		stock.Stock = ent.Stock
		stock:Spawn()
		local phys = stock:GetPhysicsObject()
		if ( phys:IsValid() ) then
			phys:Wake()
			phys:EnableMotion( false )
		end		
	end
end

function TerminalR.PostCleanupMap()
	if ( not TerminalR.Config.CleanUpSave ) then return end
	for k, ent in pairs( TerminalR.Save.Terminal ) do
		local terminal = ents.Create( "trm_terminal" )
		terminal:SetPos( ent.Pos )
		terminal:SetAngles( ent.Ang )
		terminal:Spawn()
		terminal.Memory = ent.Memory
		terminal.HP = ent.HP
		terminal:SetNWBool( "Terminal:O/F", ent.NetworkValue["O/F"] )
		terminal:SetNWString( "Terminal:Key", ent.NetworkValue["Key"] )
		terminal:SetNWInt( "Terminal:InUse", ent.NetworkValue["InUse"] )
		terminal:SetNWBool( "Terminal:Destroy", ent.NetworkValue["Destroy"] )
		local phys = terminal:GetPhysicsObject()
		if ( phys:IsValid() ) then
			phys:Wake()
			phys:EnableMotion( false )
		end		
	end
	for k, ent in pairs( TerminalR.Save.Disk ) do
		local disk = ents.Create( "trm_disk" )
		disk:SetPos( ent.Pos )
		disk:SetAngles( ent.Ang )
		disk.DiskText = ent.DiskText
		disk.DiskTitle = ent.DiskTitle
		disk.DiskPass = ( ent.DiskPass or nil )
		disk:Spawn()
	end
	for k, ent in pairs( TerminalR.Save.Stock ) do
		local stock = ents.Create( "trm_stock" )
		stock:SetPos( ent.Pos )
		stock:SetAngles( ent.Ang )
		stock.Stock = ent.Stock
		stock:Spawn()
		local phys = stock:GetPhysicsObject()
		if ( phys:IsValid() ) then
			phys:Wake()
			phys:EnableMotion( false )
		end		
	end
	TerminalR.Save = {}
end

function TerminalR.SyncServerTerminal(len, ply)
	local NTab = net.ReadTable()
	local TerminalENT = ents.GetByIndex( NTab.EntIndex )
	TerminalENT:SetNWString( "Terminal:Key", NTab.Key )
	TerminalENT.Memory = NTab.Memory
end

hook.Add( "PreCleanupMap", "TrmRPCM", TerminalR.PreCleanupMap )
hook.Add( "ShutDown", "TrmShutdown", TerminalR.ShutDown )
hook.Add( "InitPostEntity", "TrmIPE", TerminalR.InitPostEntity )
hook.Add( "Think", "TrmSecureStuff", TerminalR.Think )
hook.Add( "PostCleanupMap", "TrmRPCM", TerminalR.PostCleanupMap )