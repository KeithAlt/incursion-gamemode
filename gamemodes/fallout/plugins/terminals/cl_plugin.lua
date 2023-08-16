--replaced with functions in item
local function refreshInv(item, index)
    local panel = item.invID and nut.gui["inv"..item.invID] or nut.gui.inv1

    if (panel and panel.panels) then
        local icon = panel.panels[index]

        if (icon) then
            local title = item.diskTitle or "Disk"
            local author = item.diskAuthor

            if ( author and LocalPlayer():IsAdmin() ) then
                icon:SetToolTip(Format(nut.config.itemFormat, "<color=255, 153, 51>"..title.."</color>", "Author: "..item.diskAuthor))
            else
                icon:SetToolTip(Format(nut.config.itemFormat, "<color=255, 153, 51>"..title.."</color>", ""))
            end
        end
    end
end

function PLUGIN:OverrideItemTooltip(panel, data, item)
	--[[
    local itemId = item.uniqueID

    if ( itemId == "disk" ) then
        local title = item.diskTitle or "Disk"
        local author = item.diskAuthor

        if ( author and LocalPlayer():IsAdmin() ) then
            return Format(nut.config.itemFormat, "<color=255, 153, 51>"..title.."</color>", "Author: "..item.diskAuthor)
        else
            return Format(nut.config.itemFormat, "<color=255, 153, 51>"..title.."</color>", "")
        end
    end
	--]]
end

netstream.Hook("foDiskData", function(index, title, author)
    local item = nut.item.instances[index]

    if (item) then
        item.diskTitle = title
        item.diskAuthor = author

        refreshInv(item, index)
    end
end)

--[[
netstream.Hook("foDiskTitle", function(index, title)
    local item = nut.item.instances[index]

    if (item) then
        item.diskTitle = title

        refreshInv(item, index)
    end
end)

netstream.Hook("foDiskRnm", function(index)
    local item = nut.item.instances[index]

    if (item)  then
        Derma_StringRequest("Rename disk", "What would you like the title to be?",(item.diskTitle and item.diskTitle) or "Disk", function(title)
            netstream.Start("foDiskRnm", index, title)
        end)
    end
end)
--]]