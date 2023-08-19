ENT.Type = "anim"
ENT.Spawnable = false

if SERVER then
	function ENT:Initialize()
		self:SetModel("models/props_junk/sawblade001a.mdl")
		self:PhysicsInit(SOLID_NONE)
		self:SetMoveType(MOVETYPE_NONE)
		self:DrawShadow(false)
	end
else
	function ENT:Draw()
		if LocalPlayer():IsAdmin() and LocalPlayer():GetMoveType() == MOVETYPE_NOCLIP then
			self:DrawModel()
		end
	end
end