AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Trails: Green-Blue trail"
ENT.Author			= "Bombobux"
ENT.Information		= ""
ENT.Category		= "Placeable Effects"

ENT.Spawnable		= true
ENT.AdminOnly		= false

if SERVER then

function ENT:Initialize()
	
	self:SetModel("models/Items/AR2_Grenade.mdl")
	self:SetNoDraw(true)
	self:DrawShadow(false)
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
        ParticleEffectAttach( "mr_jet_trail_1_a", 1, self, 1 )

end
end
