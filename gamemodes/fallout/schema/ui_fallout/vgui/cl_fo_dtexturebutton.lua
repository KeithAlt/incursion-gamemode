local PANEL = {}

	function PANEL:Paint(w, h)
		if (self.texture) then
			--[[if (self:IsHovered() and !self:GetDisabled()) then
				surface.SetDrawColor(Color(0, 0, 0))
				DisableClipping(true)
				surface.DrawOutlinedRect(2, 2, w - 1, h - 1)
				DisableClipping(false)

				surface.SetDrawColor(nut.gui.palette.color_primary)
				surface.DrawOutlinedRect(0, 0, w, h)
				surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
			end;]]--

			surface.SetDrawColor(Color(0, 0, 0))
			surface.SetMaterial(self.texture)
			surface.DrawTexturedRect(2, 2, w, h)
			surface.SetDrawColor(nut.gui.palette.color_primary)
			surface.DrawTexturedRect(0, 0, w, h)
		end;
	end;

	function PANEL:SetTexture(text)
		self.texture = nut.util.getMaterial(text)
	end;

	function PANEL:OnCursorEntered()
		if (!self:GetDisabled()) then
			surface.PlaySound("fallout/ui/ui_focus.wav")
		end;
	end;

	function PANEL:OnMousePressed()
		if (!self:GetDisabled()) then
			self:DoClick()
			surface.PlaySound("fallout/ui/ui_select.wav")
		end;
	end;

	function PANEL:DoClick()

	end;

vgui.Register("UI_DTextureButton", PANEL, "DPanel")
