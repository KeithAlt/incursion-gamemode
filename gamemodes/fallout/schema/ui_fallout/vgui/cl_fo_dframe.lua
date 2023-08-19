local PANEL = {}

	function PANEL:Init()
		self.lblTitle:SetTextColor(nut.gui.palette.text_primary)
		self.lblTitle:SetExpensiveShadow(1, Color(0, 0, 0))
		self.lblTitle:SetFont("UI_Bold")

		self:DockPadding(12, 24 + 12, 12, 12)

		self:SetDraggable(false)
		self:ShowCloseButton(false)
	end;

	function PANEL:Paint(w, h)
		-- Background
		surface.SetDrawColor(nut.gui.palette.color_background)
		surface.DrawRect(0, 24, w, h)

		local tW, tH = self.lblTitle:GetContentSize()

		DisableClipping(true)

		-- Shadow
		surface.SetDrawColor(Color(0, 0, 0))
		surface.DrawRect(1, 23, 8, 2) 										-- Top Part 1
		surface.DrawRect(tW + 11, 23, w - (tW + 11), 2) 	-- Top Part 2
		surface.DrawRect(-1, 23, 2, 6) 										-- Top Left
		surface.DrawRect(w + 1, 23, 2, 6) 								-- Top Right
		surface.DrawRect(1, h + 2, w + 2, 1) 							-- Bottom
		surface.DrawRect(-1, h - 3, 2, 6)									-- Bottom Left
		surface.DrawRect(w + 2, h - 3, 1, 6)							-- Bottom Right

		-- Top Lines
		surface.SetDrawColor(nut.gui.palette.color_primary)
		surface.DrawRect(0, 22, 8, 2) 									-- Top Part 1
		surface.DrawRect(tW + 10, 22, w - (tW + 10), 2)	-- Top Part 2
		surface.DrawRect(-2, 22, 2, 6) 									-- Top Left
		surface.DrawRect(w, 22, 2, 6) 									-- Top Right
		surface.DrawRect(0, h, w, 2) 										-- Bottom
		surface.DrawRect(-2, h - 4, 2, 6)								-- Bottom Left
		surface.DrawRect(w, h - 4, 2, 6)								-- Bottom Right

		DisableClipping(false)
	end;

	function PANEL:SetDisabled(bDisabled)
		self.m_bDisabled = bDisabled

		if (bDisabled) then
			self:SetMouseInputEnabled(false)
		else
			self:SetMouseInputEnabled(true)
		end;
	end;

vgui.Register("UI_DFrame", PANEL, "DFrame")
