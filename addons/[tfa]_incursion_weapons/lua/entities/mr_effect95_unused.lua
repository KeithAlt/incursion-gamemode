AddCSLuaFile() 

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Physics: Particle Collision and bouncing"
ENT.Author			= "Bombobux"
ENT.Information		= ""
ENT.Category		= "Placeable Effects"

ENT.Spawnable		= false -- too buggy
ENT.AdminOnly		= false

if SERVER then

function ENT:Initialize()
	self:SetModel("models/Items/AR2_Grenade.mdl")
	self:SetNoDraw(true)
	self:DrawShadow(false)
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
        ParticleEffectAttach( "_AdVaNcEd_PhYsIcS_sImULaTiOn_NaSaCOMpUtERrequired", 1, self, 1 )
		-- ADVANCED PHYSICS SIMULATIONS, NVIDIA SPACEX NASA (TM) QUANTUM SUPERCOMPUTER REQUIRED 

end
end
