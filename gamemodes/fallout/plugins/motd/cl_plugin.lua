local PLUGIN = PLUGIN

netstream.Hook("foMotdData", function(title, text)
    PLUGIN.boxTitle = title
    PLUGIN.boxText = text
end)

concommand.Add("dev_notifbox_edit", function()
    if (LocalPlayer():IsSuperAdmin()) then
        vgui.Create("forpNotificationBoxEdit")
    end
end)

concommand.Add("dev_notifbox", function()
    if (IsValid(PLUGIN.boxPanel)) then
        PLUGIN.boxPanel:Remove()
    end

    PLUGIN.boxPanel = vgui.Create("forpNotificationBox")
end)

function PLUGIN:CharacterLoaded(index)
    if (IsValid(self.boxPanel)) then
        self.boxPanel:Remove()
    end

    self.boxPanel = vgui.Create("forpNotificationBox")
end