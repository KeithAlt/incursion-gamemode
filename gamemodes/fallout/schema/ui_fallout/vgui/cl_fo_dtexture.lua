local PANEL = {}

	function PANEL:Paint(w, h)
		if (self.texture) then
			surface.SetDrawColor(Color(255, 255, 255))
			surface.SetMaterial(self.texture)
			surface.DrawTexturedRect(0, 0, w, h)
		end;

		if (self.border) then
			surface.SetDrawColor(Color(0, 0, 0))
			DisableClipping(true)
			surface.DrawOutlinedRect(2, 2, w - 1, h - 1)
			DisableClipping(false)

			surface.SetDrawColor(nut.gui.palette.color_primary)
			surface.DrawOutlinedRect(0, 0, w, h)
			surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
		end;
	end;

	function PANEL:SetTexture(texture)
		self.texture = nut.util.getMaterial(texture)
	end;

	function PANEL:SetBordered(bool)
		if (bool) then
			self.border = true
		else
			self.bordered = false
		end;
	end;

vgui.Register("UI_DTexture", PANEL, "DPanel")
