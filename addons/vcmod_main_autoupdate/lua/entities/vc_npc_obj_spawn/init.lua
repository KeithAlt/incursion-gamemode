// Copyright © 2020 VCMod (freemmaann). All Rights Reserved. if you have any complaints or ideas contact me: steam - steamcommunity.com/id/freemmaann/ or email - freemmaann@gmail.com.

AddCSLuaFile("shared.lua") AddCSLuaFile("cl_init.lua") include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/hunter/plates/plate3x6.mdl") self:SetMaterial("models/shiny") self:SetColor(Color(30,100,150,5))
	self:PhysicsInit(SOLID_VPHYSICS) self:SetMoveType(MOVETYPE_NONE) self:SetSolid(SOLID_VPHYSICS)
end

function ENT:Think() if !IsValid(self.VC_NPC) or !IsValid(self.VC_Owner) then self:Remove() end end