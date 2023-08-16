AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')
ENT.Model = "models/fallout/goopile.mdl"

function ENT:Pig_Ent_Init()
self:SetMoveType(MOVETYPE_NONE)
end

