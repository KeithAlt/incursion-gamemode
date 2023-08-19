local PANEL = {}

function PANEL:Init()
	self:SetExpensiveShadow(1, Color(0, 0, 0))
end;

function PANEL:OnMousePressed()
	if (!self:GetDisabled()) then
		self:DoClick()
		surface.PlaySound("fallout/ui/ui_select.wav")
	end;
end;

function PANEL:OnCursorEntered()
	self:SetTextColor(nut.fallout.color.hover)
	self:SetExpensiveShadow(0, Color(0, 0, 0))
	surface.PlaySound("fallout/ui/ui_focus.wav")
end;

function PANEL:OnCursorExited()
	self:SetTextColor(nut.fallout.color.main)
	self:SetExpensiveShadow(1, Color(0, 0, 0))
end;

vgui.Register("falloutButton", PANEL, "DButton")