ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"

ENT.Author			= "Mack"
ENT.PrintName 		= "Flood Infection Vile"
ENT.Category		= "Flood Infection Entity"
ENT.Contact 		= ""
ENT.Purpose 		= ""
ENT.Information 	= ""

ENT.Spawnable		= true
ENT.AdminSpawnable	= true

ENT.WorldModel	 	= "models/player/h3_human_flood_player/h3_human_flood_player.mdl"

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "owning_ent")
end