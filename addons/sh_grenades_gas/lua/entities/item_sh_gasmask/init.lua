AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Items/BoxMRounds.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetUseType(SIMPLE_USE)
end

function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)
end

function ENT:Use(ply)
	if (!ply:GetNWBool("SH_GasMask")) then
		ply:SetNWBool("SH_GasMask", true)
		ply:ChatPrint("You can now breathe in toxic gas clouds!")
		ply:EmitSound("items/ammopickup.wav")

		self:Remove()
	else
		ply:ChatPrint("You already have a gas mask equipped.")
	end
end

hook.Add("PlayerSpawn", "MUSTARDGAS_PlayerSpawn", function(ply)
	ply:SetNWBool("SH_GasMask", false)
end)