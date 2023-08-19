AddCSLuaFile()

ENT.Type      = "anim"
ENT.Base      = "base_gmodentity"

ENT.PrintName = "Trade up bench"
ENT.Author    = "jonjo"
ENT.Category  = "Claymore Gaming"

ENT.Spawnable = true

if SERVER then
	function ENT:Initialize()
		self:SetModel(wRarity.Config.BenchModel)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local physObj = self:GetPhysicsObject()
		if IsValid(physObj) then
			physObj:Wake()
			physObj:EnableMotion(false)
		end
	end

	function ENT:Use(ply)
		net.Start("wRarityTradeupMenu")
		net.Send(ply)
	end
end

if CLIENT then
	function ENT:Draw()
		if self:GetNoDraw() then return end

		self:DrawModel()
	end
end
