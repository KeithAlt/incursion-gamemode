// Copyright © 2020 VCMod (freemmaann). All Rights Reserved. if you have any complaints or ideas contact me: steam - steamcommunity.com/id/freemmaann/ or email - freemmaann@gmail.com..

AddCSLuaFile("cl_init.lua") AddCSLuaFile("shared.lua") include('shared.lua')

function ENT:Initialize() self:SetModel("models/vcmod/vcmod_toolbox.mdl") self:PhysicsInit(SOLID_VPHYSICS) self:SetMoveType(MOVETYPE_VPHYSICS) self:SetSolid(SOLID_VPHYSICS) self:SetUseType(SIMPLE_USE) local phys = self:GetPhysicsObject() if phys:IsValid() then phys:Wake() end end

function ENT:Use(ply) if VCPopup then VCPopup(ply, "TouchCarWithThis", "info") end end

function ENT:Touch(ent)
	if ent.VC_IsJeep and ent.VC_Health and ent.VC_Health < ent.VC_MaxHealth and !self.VC_Used then
	VCEffect(self:GetPos())
	if VC.RepairHealth then VC.RepairHealth(ent, ent.VC_MaxHealth) end
	VC.EmitSound(ent, "items/smallmedkit1.wav", nil, 70)
	self:Remove() self.VC_Used = true
	end
end