local function refreshInv(item, index)
    local panel = item.invID and nut.gui["inv"..item.invID] or nut.gui.inv1

    if (panel and panel.panels) then
        local icon = panel.panels[index]

        if (icon) then
            local title = item:GetFormatTitle()
            local author = item:GetFormatAuthor()

            icon:SetToolTip(Format(nut.config.itemFormat, title, author))
        end
    end
end

function PLUGIN:OverrideItemTooltip(panel, data, item)
    local itemBase = item.base

    if ( itemBase == "base_documents" ) then
        local title = item:GetFormatTitle()
        local author = item:GetFormatAuthor()

        return Format(nut.config.itemFormat, title, author)
    end
end

netstream.Hook("foDocData", function(index, title, author)
    local item = nut.item.instances[index]

    if (item) then
        item.docTitle = title
        item.docAuthor = author

        refreshInv(item, index)
    end
end)

netstream.Hook("foDocTitle", function(index, title)
    local item = nut.item.instances[index]

    if (item) then
        item.docTitle = title

        refreshInv(item, index)
    end
end)

netstream.Hook("foDocAuthor", function(index)
    local item = nut.item.instances[index]
    local char = LocalPlayer():getChar()

    if (char && item) then
        item.docAuthor = char:getName()

        refreshInv(item, index)
    end
end)

netstream.Hook("foDocRnm", function(index)
    local item = nut.item.instances[index]

    if (item)  then
        Derma_StringRequest("Rename document", "What would you like the title to be?", item:GetTitle(), function(title)
            netstream.Start("foDocRnm", index, title)
        end)
    end
end)

netstream.Hook("foDocRead", function(index, canEdit, content)
    content = content or ""

    if (IsValid(nut.gui.menu)) then
        nut.gui.menu:Remove()
    end

    local panel = vgui.Create("forpDocPnl")

    local item = nut.item.instances[index]
    local title = item:GetTitle()

    panel:SetTitle(title)
    panel:SetContent(content)
    panel:SetCanEdit(canEdit)
    panel.itemId = index
end)