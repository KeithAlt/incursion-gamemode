include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:DrawTranslucent()
	self:DrawModel()

	local d = EyePos():Distance(self:GetPos())
	if (d <= 1024) then

		local ang = self:GetAngles()
		ang:RotateAroundAxis(ang:Up(), 90)
		ang:RotateAroundAxis(ang:Forward(), 90)

		local tex, col, fnt = "Gas Mask", color_white, "DermaLarge"

		cam.Start3D2D(self:GetPos() + ang:Up() * 5.7 - ang:Right() * 7, ang, 0.14)
			draw.SimpleTextOutlined(tex, fnt, 0, 0, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
		cam.End3D2D()

		ang:RotateAroundAxis(ang:Right(), 180)

		cam.Start3D2D(self:GetPos() + ang:Up() * 5.7 - ang:Right() * 7, ang, 0.14)
			draw.SimpleTextOutlined(tex, fnt, 0, 0, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
		cam.End3D2D()
	end
end