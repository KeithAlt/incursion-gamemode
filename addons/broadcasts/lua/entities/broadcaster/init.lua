AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.WorldModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
	end
	self:SetUseType(SIMPLE_USE)
	self:DropToFloor()
	BROADCASTS.RegisterBroadcast(self) -- Register entity as a broadcasting entity
end

function ENT:Use(ply)
	net.Start("broadcasts_openMenu")
	net.WriteEntity(self)
	net.Send(ply)
end
