// Copyright © 2020 VCMod (freemmaann). All Rights Reserved. if you have any complaints or ideas contact me: steam - steamcommunity.com/id/freemmaann/ or email - freemmaann@gmail.com.

AddCSLuaFile("shared.lua") include('shared.lua')

function ENT:Initialize() self:SetModel("models/Items/AR2_Grenade.mdl") local size = Vector(10, 28, 1) self:PhysicsInitBox(size, -Vector(size.x, 0, size.z)) self:SetMoveType(MOVETYPE_VPHYSICS) self:SetSolid(SOLID_VPHYSICS) self:SetUseType(SIMPLE_USE) local phys = self:GetPhysicsObject() if phys:IsValid() then phys:SetMaterial("metal") phys:Wake() self:SetCustomCollisionCheck(true) end end

local ID = "Spikestrip_Pointy"
function ENT:Use(...) if VC and VC.CodeEnt[ID] and VC.CodeEnt[ID].Use then return VC.CodeEnt[ID].Use(self, ...) end end
function ENT:Think(...) if VC and VC.CodeEnt[ID] and VC.CodeEnt[ID].Think then return VC.CodeEnt[ID].Think(self, ...) end end
function ENT:Touch(...) if VC and VC.CodeEnt[ID] and VC.CodeEnt[ID].Touch then return VC.CodeEnt[ID].Touch(self, ...) end end
function ENT:OnTakeDamage(...) if VC and VC.CodeEnt[ID] and VC.CodeEnt[ID].OnTakeDamage then return VC.CodeEnt[ID].OnTakeDamage(self, ...) end end