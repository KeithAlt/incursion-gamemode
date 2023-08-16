AddCSLuaFile()

ENT.Type      = "anim"
ENT.Base      = "base_gmodentity"

ENT.PrintName = "Marketplace"
ENT.Author    = "jonjo"
ENT.Category  = "Claymore Gaming"

ENT.Spawnable = true

if SERVER then
    function ENT:Initialize()
        self:SetModel(Marketplace.Config.MarketModel or "models/props_lab/servers.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
    end

	function ENT:Use(ply)
		net.Start("MarketplaceOpenMenu")
		net.Send(ply)
	end
end

if CLIENT then
	ENT.RenderDist = 500
	ENT.RenderDistSqrd = ENT.RenderDist ^ 2

    function ENT:Draw()
        self:DrawModel()

		if halo.RenderedEntity() == self then return end
		if self:GetPos():DistToSqr(LocalPlayer():GetPos()) < self.RenderDistSqrd then
			local ang = self:GetAngles()
			ang:RotateAroundAxis(ang:Up(), 90)
			ang:RotateAroundAxis(ang:Forward(), 90)

			cam.Start3D2D(self:GetPos() + (self:GetUp() * (self:OBBMaxs().z + 10)), ang, 0.05)
				draw.SimpleTextOutlined("Marketplace", "Marketplace3D2D", 0, 0, nut.gui.palette.color_primary, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color(0, 0, 0, 255))
			cam.End3D2D()
		end
    end
end
