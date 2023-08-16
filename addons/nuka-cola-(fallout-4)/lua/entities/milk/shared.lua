ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Milk (BONUS)"
ENT.Author = "^6 Cuelho Mau"
ENT.Contact = "Steam"
ENT.Purpose = "Keep alive"
ENT.Instructions = "E"
ENT.Category = "Nuka-Cola"

ENT.Spawnable			= true
ENT.AdminSpawnable		= true

function ENT:SetupModel()

	self.Entity:SetModel("models/milk/milk.mdl")
	
end