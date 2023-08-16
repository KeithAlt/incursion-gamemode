
include("shared.lua")

function ENT:Initialize()
	self.MuzzleAttachment=self:LookupAttachment("muzzle")
	self.shootPos=self:GetDTEntity(1)
	
end

function ENT:Draw()
	
	self:DrawModel()
	
end