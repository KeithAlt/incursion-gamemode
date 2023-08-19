local PANEL = {}

function PANEL.DrawRect(pnl, w, h)
	if pnl.Depressed then
		surface.SetDrawColor(nut.gui.palette.color_active:Unpack())
	else
		surface.SetDrawColor(nut.gui.palette.color_primary:Unpack())
	end
	surface.DrawRect(0, 0, w, h)
end

function PANEL:Init()
	local scroll = self:GetVBar()
	function scroll:Paint(w, h)
		surface.SetDrawColor(nut.gui.palette.color_background:Unpack())
		surface.DrawRect(0, 0, w, h)
	end

	scroll.btnUp.Paint = self.DrawRect
	scroll.btnDown.Paint = self.DrawRect
	scroll.btnGrip.Paint = self.DrawRect
end

vgui.Register("UI_DScrollPanel", PANEL, "DScrollPanel")
