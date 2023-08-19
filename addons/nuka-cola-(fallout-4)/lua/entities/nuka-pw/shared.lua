ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "pre-War Nuka-Cola"
ENT.Author = "^6 Cuelho Mau"
ENT.Contact = "Steam"
ENT.Purpose = "Keep alive"
ENT.Instructions = "E"
ENT.Category = "Nuka-Cola"

ENT.Spawnable			= true
ENT.AdminSpawnable		= true

function ENT:SetupModel()

	self.Entity:SetModel("models/nuka/nuka-pw.mdl")
	
end