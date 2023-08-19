local PANEL = {}

	function PANEL:Init()
		self:SetTextColor(nut.gui.palette.text_primary)
		self:SetExpensiveShadow(1, Color(0, 0, 0))
		self:SetContentAlignment(4)
		self:SetFont("UI_Bold")
		self:SetHeight(32)
	end;

	function PANEL:Paint(w, h)
		if (self:GetPaintBackground()) then
			if (((self:IsHovered() or self:IsDown()) and !self:GetDisabled()) or self.active) then
				surface.SetDrawColor(Color(0, 0, 0))
				DisableClipping(true)
				surface.DrawRect(1, 1, w, h)
				DisableClipping(false)

				if (self.active) then
					surface.SetDrawColor(nut.gui.palette.color_hover)
				else
					surface.SetDrawColor(nut.gui.palette.color_primary)
				end;

				surface.DrawRect(0, 0, w, h)
			end;
		end;
	end;

	function PANEL:OnMousePressed()
		if (!self:GetDisabled() and !self.active) then
			self:DoClick()
			surface.PlaySound("fallout/ui/ui_select.wav")
		end;
	end;

	function PANEL:OnCursorEntered()
		if (!self:GetDisabled() and !self.active) then
			self:SetTextColor(nut.gui.palette.text_hover)
			self:SetExpensiveShadow(0, Color(0, 0, 0))
			surface.PlaySound("fallout/ui/ui_focus.wav")
		end;
	end;

	function PANEL:OnCursorExited()
		if (!self:GetDisabled() and !self.active) then
			self:SetTextColor(nut.gui.palette.text_primary)
			self:SetExpensiveShadow(1, Color(0, 0, 0))
		end;
	end;

	function PANEL:SetDisabled(bDisabled)
		self.m_bDisabled = bDisabled
		self:InvalidateLayout()

		if (bDisabled) then
			self:SetTextColor(nut.gui.palette.text_disabled)
			self:SetExpensiveShadow(1, Color(0, 0, 0))
		else
			self:SetTextColor(nut.gui.palette.text_primary)
		end;
	end;

	function PANEL:SetEnabled(bEnabled)
		self:SetDisabled(!bEnabled)
	end;

	function PANEL:SetActive(bool)
		if (bool) then
			self.active = true
			self:SetTextColor(nut.gui.palette.text_hover)
		else
			self.active = false
			self:SetTextColor(nut.gui.palette.text_primary)
		end;
	end;

vgui.Register("UI_DButton", PANEL, "DButton")
