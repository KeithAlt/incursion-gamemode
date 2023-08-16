
include("shared.lua")

function ENT:Initialize()
	self.MuzzleAttachment=self:LookupAttachment("muzzle")
	self.shootPos=self:GetDTEntity(1)
	
end
--[[
ENT.HiddenShooter=false
function ENT:Think()
	if not self.HiddenShooter and IsValid(self.shootPos) then
		self.shootPos:SetRenderMode(RENDERMODE_TRANSCOLOR)
		self.shootPos:SetColor(Color(255,255,255,1))
		self.HiddenShooter=true
	end
	
end]]

function ENT:Draw()
	
	self:DrawModel()
	
end