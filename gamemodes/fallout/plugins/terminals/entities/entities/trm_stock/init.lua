AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:SetupStock()
	self:SetNWInt( "Stock:InUse", CurTime() )
	self.Stock = ( self.Stock or {} )
end

function ENT:Initialize()
	self:SetModel( "models/props_lab/filecabinet02.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self:SetupStock()
end

function ENT:EndTouch( entity )
	if ( entity:GetClass() == "nut_item" ) then
		local item = nut.item.instances[entity.nutItemID]
		if (item.uniqueID != "disk") then return end

		if ( CurTime() > (entity.CooldownInsert or 0) ) then
			if ( #self.Stock >= 20 ) then return end
			local DiskInfo = {}

			local index = item:getID()
			DiskInfo.DiskTitle = (TerminalR.DiskData[index] and TerminalR.DiskData[index].title) or {"Disk"}
			DiskInfo.DiskAuthor = TerminalR.DiskData[index] and TerminalR.DiskData[index].author
			DiskInfo.DiskText =  (TerminalR.DiskData[index] and TerminalR.DiskData[index].text) or {"Empty Disk"}
			DiskInfo.DiskPass =  TerminalR.DiskData[index] and TerminalR.DiskData[index].pass

			table.insert( self.Stock, DiskInfo )
			item:remove()
		end
	end
end

function ENT:Use( ply, caller )
	if ( CurTime() > self:GetNWInt( "Stock:InUse" ) ) then
		net.Start( "Net_TerminalR:OpenStock" )
			net.WriteInt( self:EntIndex(), 32 )
			net.WriteTable( self.Stock )
		net.Send( ply )
		self:EmitSound( "terminalr/opencabinet_" .. math.random( 1, 2 ) .. ".wav" )
	end
end
function ENT:EjectDisk( StockIndex )
	local ang = self:GetAngles()
	local DiskInfo = self.Stock[StockIndex]
	if ( not DiskInfo ) then return end

	nut.item.spawn("disk", self:GetPos() + ang:Forward()*20 + ang:Up()*20, function(item, ent)
		ent.CooldownInsert = CurTime() + 5
		TerminalR.DiskData[item:getID()] = {
			title = DiskInfo.DiskTitle,
			author = DiskInfo.DiskAuthor, 
			text = DiskInfo.DiskText,
			pass = DiskInfo.DiskPass
		}
	end, Angle( 280, 0, ang.y ))

	table.remove( self.Stock, StockIndex )
	self:EmitSound( "terminalr/diskdrop_" .. math.random( 1, 2 ) .. ".wav" )
end

function ENT:Think()
end
