// Copyright © 2020 VCMod (freemmaann). All Rights Reserved. if you have any complaints or ideas contact me: steam - steamcommunity.com/id/freemmaann/ or email - freemmaann@gmail.com.

AddCSLuaFile("cl_init.lua") AddCSLuaFile("shared.lua") include('shared.lua')

function ENT:Initialize() self:SetModel("models/gibs/airboat_broken_engine.mdl") self:PhysicsInit(SOLID_VPHYSICS) self:SetMoveType(MOVETYPE_VPHYSICS) self:SetSolid(SOLID_VPHYSICS) self:SetUseType(SIMPLE_USE) local phys = self:GetPhysicsObject() if phys:IsValid() then phys:SetMaterial("metal") phys:Wake() end self:SetCustomCollisionCheck(true) end

local ID = "Pickup_carpart"
function ENT:Use(...) if VC and VC.CodeEnt[ID] and VC.CodeEnt[ID].Use then return VC.CodeEnt[ID].Use(self, ...) end end
function ENT:Think(...) if VC and VC.CodeEnt[ID] and VC.CodeEnt[ID].Think then return VC.CodeEnt[ID].Think(self, ...) end end
function ENT:Touch(...) if VC and VC.CodeEnt[ID] and VC.CodeEnt[ID].Touch then return VC.CodeEnt[ID].Touch(self, ...) end end
function ENT:OnTakeDamage(...) if VC and VC.CodeEnt[ID] and VC.CodeEnt[ID].OnTakeDamage then return VC.CodeEnt[ID].OnTakeDamage(self, ...) end end