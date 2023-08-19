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
	if ( entity:GetClass() == "trm_disk" ) then
		if ( CurTime() > entity.CooldownInsert ) then
			if ( #self.Stock >= 20 ) then return end
			local DiskInfo = {}
			DiskInfo.DiskText = entity.DiskText
			DiskInfo.DiskTitle = entity.DiskTitle
			DiskInfo.DiskPass = ( entity.DiskPass or nil )
			table.insert( self.Stock, DiskInfo )
			entity:Remove()
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
	local disk = ents.Create( "trm_disk" )
	disk:SetPos( self:GetPos() + ang:Forward()*20 + ang:Up()*20 )
	disk:SetAngles( Angle( 280, 0, ang.y ) )	
	disk:Spawn()
	disk.CooldownInsert = CurTime() + 5
	disk.DiskText = DiskInfo.DiskText
	disk.DiskTitle = DiskInfo.DiskTitle
	disk.DiskPass = ( DiskInfo.DiskPass or nil )
	disk:SyncTitle()
	table.remove( self.Stock, StockIndex )
	self:EmitSound( "terminalr/diskdrop_" .. math.random( 1, 2 ) .. ".wav" )
end

function ENT:Think()
end
