local PANEL = {}

function PANEL:Init()
    self:SetSize(380, 480)
	self:SetDraggable(false)
	self:ShowCloseButton(false)
	self:MakePopup()
	self:Center() 

    self.textEntry = self:Add("DTextEntry")
	self.textEntry:Dock( FILL )
	self.textEntry:SetMultiline(true)

	self.close = self:Add("DButton")
	self.close:SetText("Close")
	self.close:Dock( BOTTOM )
	self.close:DockMargin(0, 4, 0, 0)
	self.close:SetTextColor(color_white)
	self.close.DoClick = function(pnl)
		self:Remove()
	end
end

function PANEL:OnRemove()
	if ( self.canEdit && self.initialContent != self:GetContent() ) then
		netstream.Start("foDocWrite", self.itemId, self:GetContent())
	end
end

function PANEL:SetContent(content)
	if ( !self.initialContent ) then
		self.initialContent = content
	end

    self.textEntry:SetValue(content)
end

function PANEL:GetContent()
    return self.textEntry:GetValue()
end

function PANEL:SetCanEdit(state)
	self.canEdit = state
    self.textEntry:SetEditable(state)
end

vgui.Register("forpDocPnl", PANEL, "DFrame")