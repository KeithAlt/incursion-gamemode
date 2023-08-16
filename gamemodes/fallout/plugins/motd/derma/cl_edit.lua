local PLUGIN = PLUGIN
local PANEL = {}

function PANEL:Init()
    self:SetTitle("Edit Notification box")
    self:SetSize(570, 720)
    self:MakePopup()
    self:Center()

    self.titleOptionLabel = self:Add("DLabel")
    self.titleOptionLabel:SetText("Title:")
    self.titleOptionLabel:Dock(TOP)

    self.titleOptionEntry = self:Add("DTextEntry")
    self.titleOptionEntry:SetText(PLUGIN.boxTitle or "MOTD")
    self.titleOptionEntry:Dock(TOP)

    self.textOptionLabel = self:Add("DLabel")
    self.textOptionLabel:SetText("Text:")
    self.textOptionLabel:Dock(TOP)

    self.textOptionEntry = self:Add("DTextEntry")
    self.textOptionEntry:SetText(PLUGIN.boxText or "")
    self.textOptionEntry:SetMultiline(true)
    self.textOptionEntry:Dock(FILL)
    self.textOptionEntry:DockMargin(0, 0, 0, 4)

    self.submitButton = self:Add("DButton")
    self.submitButton:SetText("Update")
    self.submitButton.DoClick = function()
        netstream.Start("foMotdEdit", self.titleOptionEntry:GetValue(), self.textOptionEntry:GetValue())
    end

    self.submitButton:Dock(BOTTOM)
end

vgui.Register("forpNotificationBoxEdit", PANEL, "DFrame")