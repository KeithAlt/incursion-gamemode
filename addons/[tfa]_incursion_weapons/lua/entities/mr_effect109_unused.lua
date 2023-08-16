AddCSLuaFile() 

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Misc: Energy Shield 1"
ENT.Author			= "Bombobux"
ENT.Information		= ""
ENT.Category		= "Placeable Effects"

ENT.Spawnable		= false -- This effect was just one big experiment,
ENT.AdminOnly		= false -- it turned out really bad both in looks and performance.
                            -- This file will likely be removed in a future release.
if SERVER then

function ENT:Initialize()
	self:SetModel("models/Items/AR2_Grenade.mdl")
	self:SetNoDraw(true)
	self:DrawShadow(false)
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
        ParticleEffectAttach( "_sai_energy_shield", 1, self, 1 )

end
end
