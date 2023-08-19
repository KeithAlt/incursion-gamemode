ITEM.name = "Disk"
ITEM.model = "models/unconid/pc_models/floppy_disk_3_5.mdl"
ITEM.desc = ""
ITEM.width = 1
ITEM.height = 1
ITEM.noBusiness = false
ITEM.price = 100

ITEM.functions.Rename = {
	text = "Rename",
	icon = "icon16/tag_blue_edit.png",
	menuOnly = true,
    onRun = function(item)
		netstream.Start(item.player, "foDiskRnm", item:getID())

		return false
    end,
    onCanRun = function(item)
        if (CLIENT) then
            return IsValid(nut.gui.menu)
        end

        return true
    end
}

local function refreshInv(item, index)
    local panel = item.invID and nut.gui["inv"..item.invID] or nut.gui.inv1

    if (panel and panel.panels) then
        local icon = panel.panels[index]

        if (icon) then
            local title = item.diskTitle or "Unnamed Disk"
            local author = item.diskAuthor

            if ( author ) then
                icon:SetToolTip(Format(nut.config.itemFormat, "<color=255, 153, 51>"..title.."</color>", "Author: "..item.diskAuthor))
            else
                icon:SetToolTip(Format(nut.config.itemFormat, "<color=255, 153, 51>"..title.."</color>", ""))
            end
        end
    end
end

function ITEM:onSendData()
    local receiver = self.player

    if (receiver:IsAdmin()) then
        local index = self:getID()
        local title = TerminalR.DiskData[index] and TerminalR.DiskData[index].title and TerminalR.DiskData[index].title[1]
        local author = TerminalR.DiskData[index] and TerminalR.DiskData[index].author

        netstream.Start(receiver, "foDiskData", index, title, author)
    end
end

if (SERVER) then
    netstream.Hook("foDiskRnm", function(client, index, title)
        local item = nut.item.instances[index]

        if (item and item:getOwner() == client)  then
            TerminalR.DiskData[index] = TerminalR.DiskData[index] or {}
            TerminalR.DiskData[index].title = {title}
            netstream.Start(client, "foDiskTitle", index, title)
        end
    end)
else
    netstream.Hook("foDiskData", function(index, title, author)
        local item = nut.item.instances[index]

        if (item) then
            item.diskTitle = title
            item.diskAuthor = author

            refreshInv(item, index)
        end
    end)

    netstream.Hook("foDiskTitle", function(index, title)
        local item = nut.item.instances[index]

        if (item) then
            item.diskTitle = title

            refreshInv(item, index)
        end
    end)

    netstream.Hook("foDiskAuthor", function(index, author)
        local item = nut.item.instances[index]

        if (item)  then
            -- Update item desc in the inventory
            local panel = item.invID and nut.gui["inv"..item.invID] or nut.gui.inv1

            if (panel and panel.panels) then
                local icon = panel.panels[index]

                if (icon) then
                    icon:SetToolTip(Format(nut.config.itemFormat, "<color=255, 153, 51>"..item:getData("title", "Unnamed Disk").."</color>", "Author: "..author))
                end
            end
        end
    end)

    netstream.Hook("foDiskRnm", function(index)
        local item = nut.item.instances[index]

        if (item)  then
            Derma_StringRequest("Rename disk", "What would you like the title to be?",(item.diskTitle and item.diskTitle) or "Unnamed disk", function(title)
                netstream.Start("foDiskRnm", index, title)
            end)
        end
    end)
end

function ITEM:onRemoved()
    TerminalR.DiskData[self:getID()] = nil
end

TerminalR = TerminalR or {}
TerminalR.DiskData = TerminalR.DiskData or {}

hook.Add("InitPostEntity", "terminal_disk_passwords", function()
    local path = "nutscript/"..SCHEMA.folder.."/disk_data.txt"
    local status, decoded = pcall(pon.decode, file.Read(path, "DATA"))

    local tbl

	if (status and decoded) then
		local value = decoded[1]

		if (value != nil) then
			tbl = value
		else
			tbl = {}
		end
	else
		tbl = {}
    end
    
    TerminalR.DiskData = tbl
end)

hook.Add("ShutDown", "terminal_disk_passwords2", function()
    local path = "nutscript/"..SCHEMA.folder.."/disk_data.txt"
	file.CreateDir("nutscript/"..SCHEMA.folder.."/")
    
    file.Write( path, pon.encode({TerminalR.DiskData}) )
end)

hook.Add("OverrideItemTooltip", "data_storages_tooltip", function(panel, data, item)
    local itemId = item.uniqueID

    if ( itemId == "disk" ) then
        local title = item.diskTitle or "Unnamed Disk"
        local author = item.diskAuthor

        if ( author ) then
            return Format(nut.config.itemFormat, "<color=255, 153, 51>"..title.."</color>", "Author: "..item.diskAuthor)
        else
            return Format(nut.config.itemFormat, "<color=255, 153, 51>"..title.."</color>", "")
        end
    end
end)