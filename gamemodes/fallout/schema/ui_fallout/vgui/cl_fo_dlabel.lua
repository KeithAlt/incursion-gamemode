local PANEL = {}

	function PANEL:Init()
		self:SetColor(nut.gui.palette.text_primary)
		self:SetExpensiveShadow(1, Color(0, 0, 0))
		self:SetFont("UI_Regular")
	end;

vgui.Register("UI_DLabel", PANEL, "DLabel")
