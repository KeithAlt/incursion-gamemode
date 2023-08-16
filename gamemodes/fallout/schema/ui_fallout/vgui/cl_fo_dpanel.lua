---------------------------------------
-- // DPANEL WITH NOTHING SPECIAL // --
---------------------------------------
local PANEL = {}

function PANEL:Paint(w, h)
	if (self:GetPaintBackground()) then
		surface.SetDrawColor(nut.gui.palette.color_background)
		surface.DrawRect(0, 0, w, h)
	end;
end;

function PANEL:SetDisabled(bDisabled)
	self.m_bDisabled = bDisabled

	if (bDisabled) then
		self:SetMouseInputEnabled(false)
	else
		self:SetMouseInputEnabled(true)
	end;
end;

vgui.Register("UI_DPanel", PANEL, "DPanel")

-----------------------------------
-- // DPANEL WITH FULL BORDER // --
-----------------------------------
local PANEL = {}

function PANEL:Paint(w, h)
	if (self:GetPaintBackground()) then
		surface.SetDrawColor(nut.gui.palette.color_background)
		surface.DrawRect(0, 0, w, h)

		DisableClipping(true)
		surface.SetDrawColor(Color(0, 0, 0))
		surface.DrawOutlinedRect(2, 2, w - 1, h - 1)

		surface.SetDrawColor(nut.gui.palette.color_primary)
		surface.DrawOutlinedRect(0, 0, w, h)
		surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
		DisableClipping(false)
	end;
end;

function PANEL:SetDisabled(bDisabled)
	self.m_bDisabled = bDisabled

	if (bDisabled) then
		self:SetMouseInputEnabled(false)
	else
		self:SetMouseInputEnabled(true)
	end;
end;

vgui.Register("UI_DPanel_Bordered", PANEL, "DPanel")

-------------------------------------------
-- // DPANEL WITH HORIZONTAL BRACKETS // --
-------------------------------------------
local PANEL = {}

function PANEL:Paint(w, h)
	if (self:GetPaintBackground()) then
		-- Background
		surface.SetDrawColor(nut.gui.palette.color_background)
		surface.DrawRect(0, 0, w, h)

		DisableClipping(true)

		-- Shadow
		surface.SetDrawColor(Color(0, 0, 0))
		surface.DrawRect(1, 0, w + 2, 1) 			-- Top
		surface.DrawRect(-1, -1, 2, 6) 				-- Top Left
		surface.DrawRect(w + 1, -1, 2, 6) 		-- Top Right
		surface.DrawRect(1, h + 2, w + 2, 1) 	-- Bottom
		surface.DrawRect(-1, h - 3, 2, 6)			-- Bottom Left
		surface.DrawRect(w + 2, h - 3, 1, 6)	-- Bottom Right

		-- Top Lines
		surface.SetDrawColor(nut.gui.palette.color_primary)
		surface.DrawRect(0, -2, w, 2) 		-- Top
		surface.DrawRect(-2, -2, 2, 6) 		-- Top Left
		surface.DrawRect(w, -2, 2, 6) 		-- Top Right
		surface.DrawRect(0, h, w, 2) 			-- Bottom
		surface.DrawRect(-2, h - 4, 2, 6)	-- Bottom Left
		surface.DrawRect(w, h - 4, 2, 6)	-- Bottom Right

		DisableClipping(false)
	end;
end;

function PANEL:SetDisabled(bDisabled)
	self.m_bDisabled = bDisabled

	if (bDisabled) then
		self:SetMouseInputEnabled(false)
	else
		self:SetMouseInputEnabled(true)
	end;
end;

vgui.Register("UI_DPanel_Horizontal", PANEL, "DPanel")

-----------------------------------------
-- // DPANEL WITH VERTICAL BRACKETS // --
-----------------------------------------
local PANEL = {}

	function PANEL:Paint(w, h)
		if (self:GetPaintBackground()) then
			-- Background
			surface.SetDrawColor(nut.gui.palette.color_background)
			surface.DrawRect(0, 0, w, h)

			DisableClipping(true)

			-- Shadow
			surface.SetDrawColor(Color(0, 0, 0))
			surface.DrawRect(1, 0, w + 2, 1) 			-- Top
			surface.DrawRect(-1, -1, 2, 6) 				-- Top Left
			surface.DrawRect(w + 1, -1, 2, 6) 		-- Top Right
			surface.DrawRect(1, h + 2, w + 2, 1) 	-- Bottom
			surface.DrawRect(-1, h - 3, 2, 6)			-- Bottom Left
			surface.DrawRect(w + 2, h - 3, 1, 6)	-- Bottom Right

			-- Top Lines
			surface.SetDrawColor(nut.gui.palette.color_primary)
			surface.DrawRect(0, -2, w, 2) 		-- Top
			surface.DrawRect(-2, -2, 2, 6) 		-- Top Left
			surface.DrawRect(w, -2, 2, 6) 		-- Top Right
			surface.DrawRect(0, h, w, 2) 			-- Bottom
			surface.DrawRect(-2, h - 4, 2, 6)	-- Bottom Left
			surface.DrawRect(w, h - 4, 2, 6)	-- Bottom Right

			DisableClipping(false)
		end;
	end;

	function PANEL:SetDisabled(bDisabled)
		self.m_bDisabled = bDisabled

		if (bDisabled) then
			self:SetMouseInputEnabled(false)
		else
			self:SetMouseInputEnabled(true)
		end;
	end;

vgui.Register("UI_DPanel_Vertical", PANEL, "DPanel")
