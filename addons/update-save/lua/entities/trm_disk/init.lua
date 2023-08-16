AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:SetupDisk()
	self.DiskText 		= ( self.DiskText or {} )
	self.DiskTitle 		= ( self.DiskTitle or {} )
	self.DiskPass 		= ( self.DiskPass or nil )
	self.DiskText[1] 	= ( self.DiskText[1] or "Empty Disk" )
	self.DiskTitle[1] 	= ( self.DiskTitle[1] or "Unnamed Disk" )
	self:SyncTitle()
end

function ENT:Initialize()
	self:SetModel( "models/unconid/pc_models/floppy_disk_3_5.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self.CooldownInsert = CurTime()
	self:SetupDisk()
end

function ENT:Use( ply, caller )
end

function ENT:SyncTitle()
	self:SetNWString( "Disk:NameLine1", ( self.DiskTitle[1] or "Unnamed Disk" ) )
	self:SetNWString( "Disk:NameLine2", ( self.DiskTitle[2] or "" ) )
	self:SetNWString( "Disk:NameLine3", ( self.DiskTitle[3] or "" ) )
	self:SetNWString( "Disk:NameLine4", ( self.DiskTitle[4] or "" ) )
	self:SetNWString( "Disk:NameLine5", ( self.DiskTitle[5] or "" ) )
	self:SetNWString( "Disk:NameLine6", ( self.DiskTitle[6] or "" ) )
end

function ENT:Think()
end
