AddCSLuaFile() 

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Jets: Rocket Jetflame (Normal)"
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
        ParticleEffectAttach( "_ae_b_rocket_jet_a", 1, self, 1 )

end
end
