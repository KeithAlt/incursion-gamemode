local PANEL = {}

function PANEL:Init()
	self:SetContentAlignment(4)
	self:SetFont("UI_Bold")
	self:SetHeight(32)
	self:SetTextColor(nut.gui.palette.text_hover)
	self:SetHighlightColor(nut.gui.palette.text_hover)
	self:SetCursorColor(nut.gui.palette.text_hover)
	self:SetPlaceholderColor(nut.gui.palette.text_disabled)
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(Color(0, 0, 0))
	DisableClipping(true)
	surface.DrawRect(1, 1, w, h)
	DisableClipping(false)

	surface.SetDrawColor(nut.gui.palette.color_primary)
	surface.DrawRect(0, 0, w, h)

	if (self.GetPlaceholderText and self.GetPlaceholderColor and self:GetPlaceholderText() and self:GetPlaceholderText():Trim() != "" and self:GetPlaceholderColor() and (!self:GetText() or self:GetText() == "")) then

		local oldText = self:GetText()

		local str = self:GetPlaceholderText()
		if (str:StartWith("#")) then str = str:sub(2) end
		str = language.GetPhrase(str)

		self:SetText(str)
		self:DrawTextEntryText(self:GetPlaceholderColor(), self:GetHighlightColor(), self:GetCursorColor())
		self:SetText(oldText)

		return
	end

	self:DrawTextEntryText(self:GetTextColor(), self:GetHighlightColor(), self:GetCursorColor())
end

vgui.Register("UI_DTextEntry", PANEL, "DTextEntry")
