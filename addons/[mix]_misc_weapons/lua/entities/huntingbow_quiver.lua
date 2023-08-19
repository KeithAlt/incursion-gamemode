AddCSLuaFile()

ENT.PrintName = "Quiver of Arrows"

ENT.Type      = "anim"
ENT.Spawnable = true

function ENT:Initialize()
	self:SetModel("models/weapons/w_quiver.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self:DrawShadow(true)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end

	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end
end

function ENT:Use(activator, caller)
	if SERVER then
		activator:GiveAmmo(10, "huntingbow_arrows")
		self:Remove()
	end
end