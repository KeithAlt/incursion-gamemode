ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName = "Hack Kit"
ENT.Category = "Terminal Mod 2"
ENT.Author = "Random guy with a keyboard"
ENT.Contact = ""
ENT.Purpose = ""
ENT.Instructions = ""
ENT.Spawnable = true
ENT.AdminSpawnable = false

function ENT:OnTakeDamage(dmginfo)
	self:SetHealth(self:Health() - dmginfo:GetDamage())
	if(self:Health() < 0) then
		self:Remove()
	end
end