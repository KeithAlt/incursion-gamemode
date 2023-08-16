AddCSLuaFile()  -- just because i like that effect in overwatch, wanted to re-create it for GMod. plot twist: i main zarya lmao

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Misc: Graviton Surge"
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
        ParticleEffectAttach( "nr_graviton_surge", 1, self, 1 )

end
end
