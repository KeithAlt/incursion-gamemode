local function OpenClassChoice(faction, ent, classes)
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Select Class(s)")
    frame:SetZPos(9999999999)
    frame:SetSize(400, 600)
    frame:Center()
    frame:MakePopup()

    local classesScroll = vgui.Create("DScrollPanel", frame)
    classesScroll:SetSize(200, 500)
    classesScroll:Center()

    local selectedClasses = {}

    local i = 0
    for k, v in pairs(classes) do
        local button = vgui.Create("DButton", classesScroll)
        button:SetText(v.name)
        button:SizeToContents()
        button:SetPos(classesScroll:GetWide()/2 - button:GetWide()/2, i * (button:GetTall() + 5))
        button:SetTextColor(Color(235, 235, 235, 255))
        button.DoClick = function(s)
            selectedClasses[v.index] = !selectedClasses[v.index]
            if selectedClasses[v.index] then
                s.Selected = vgui.Create("DImage", classesScroll)
                s.Selected:SetPos(s:GetPos())
                s.Selected:MoveRightOf(s, 3)
                s.Selected:SetImage("icon16/tick.png")
                s.Selected:SizeToContents()
            else
                if s.Selected then s.Selected:Remove() s.Selected = nil end
            end
        end

        i = i + 1
    end

    local apply = vgui.Create("DButton", frame)
    apply:SetText("Apply Changes")
    apply:SetTextColor(Color(235, 235, 235, 255))
    apply:SizeToContents()
    apply:Center()
    apply:MoveBelow(classesScroll)

    apply.DoClick = function()
        net.Start("factionstoreChange")
            net.WriteEntity(ent)
            net.WriteTable({["faction"] = faction, ["classes"] = selectedClasses})
        net.SendToServer()
        frame:Close()
    end
end

local function OpenFactionChoice(ent)
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Select Faction")
    frame:SetZPos(999999999)
    frame:SetSize(400, 600)
    frame:Center()
    frame:MakePopup()

    local factionsScroll = vgui.Create("DScrollPanel", frame)
    factionsScroll:SetSize(200, 500)
    factionsScroll:Center()

    local i = 0
    for k, v in pairs(nut.faction.indices) do
        local button = vgui.Create("DButton", factionsScroll)
        button:SetText(v.name)
        button:SizeToContents()
        button:SetPos(factionsScroll:GetWide()/2 - button:GetWide()/2, i * (button:GetTall() + 5))
        button:SetTextColor(Color(235, 235, 235, 255))
        button.DoClick = function(s)
            local classes = {}
            for _,j in pairs(nut.class.list) do
                if j.faction == v.index then
                    table.insert(classes, j)
                end
            end
            if #classes == 0 then
                net.Start("factionstoreChange")
                    net.WriteEntity(ent)
                    net.WriteTable({["faction"] = v.index, ["classes"] = selectedClasses})
                net.SendToServer()
                frame:Close()
                return
            end
            OpenClassChoice(v.index, ent, classes)
            frame:Close()
        end

        i = i + 1
    end
end

local function RequestLogs(id)
    net.Start("factionstoreRequestLogs")
        net.WriteInt(id, 32)
    net.SendToServer()
end

local function FillLogs(panel, logs)
    for _,log in pairs(logs) do
        panel:AddLine(log.name, log.itemName, log.action, log.steamID, os.date("%m/%d/%Y - %H:%M:%S", log.time))
    end
    panel:SortByColumn(5, true)
end

local function LogSearch(panel, logs, search)
    panel:Clear()
    if !search or search == "" then
        FillLogs(panel, logs)
        return
    end
    local results = {}
    for _,log in pairs(logs) do
        for _,entry in pairs(log) do
            if tostring(entry):lower():find(search:lower()) then
                table.insert(results, log)
                break
            end
        end
    end
    FillLogs(panel, results)
end

local function OpenLogs()
    local len = net.ReadInt(32)
    local data = net.ReadData(len)
    local json = util.Decompress(data)
    local logs = util.JSONToTable(json)

    local frame = vgui.Create("DFrame")
    frame:SetSize(620, 800)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("Transfer Logs")

    local logPanel = vgui.Create("DListView", frame)
    logPanel:SetSize(frame:GetSize())
    logPanel:Center()
    logPanel:Dock(FILL)
    logPanel:AddColumn("Name")
    logPanel:AddColumn("Item")
    logPanel:AddColumn("Action")
    logPanel:AddColumn("SteamID")
    logPanel:AddColumn("Time")
    FillLogs(logPanel, logs)

    local searchBox = vgui.Create("DTextEntry", frame)
    searchBox:Dock(BOTTOM)
    searchBox:SetPlaceholderText("Search...")
    searchBox.OnEnter = function(s)
        LogSearch(logPanel, logs, s:GetText())
    end
end
net.Receive("factionstoreSendLogs", OpenLogs)

local function OpenInv()
    local index = net.ReadInt(32)
    local inventory = nut.item.inventories[index]
    local ent = net.ReadEntity()

    local panel = vgui.Create("nutInventory")
    panel:ShowCloseButton(true)
    panel:SetTitle("Faction Inventory")
    panel:setInventory(inventory)

    local playerinv = vgui.Create("nutInventory")
    playerinv:ShowCloseButton(false)
    playerinv:setInventory(LocalPlayer():getChar():getInv())
    playerinv:SetDraggable(false)
    playerinv.Think = function(s)
		if panel:IsValid() then
	        s:MoveRightOf(panel)
	        s:MoveBelow(panel, -s:GetTall())
		end
    end

    panel.OnClose = function()
        playerinv:Close()
        net.Start("facionstoreInvClosed")
        net.SendToServer()
    end
    panel.Think = function(self)
        if !LocalPlayer():Alive() then
            self:Close()
        end
    end

    local logsButton = vgui.Create("DImageButton", panel)
    logsButton:SetImage("icon16/book.png")
    logsButton:SizeToContents()
    logsButton:SetPos(panel:GetWide() - 60, 4)
    logsButton.DoClick = function()
        RequestLogs(inventory.id)
    end

    if LocalPlayer():IsSuperAdmin() and IsStaffFaction(LocalPlayer()) then
        local adminButton = vgui.Create("DImageButton", playerinv)
        adminButton:SetImage("icon16/cog.png")
        adminButton:SizeToContents()
        adminButton:SetPos(playerinv:GetWide() - 44, 4)
        adminButton.DoClick = function()
            OpenFactionChoice(ent)
        end

        local deleteButton = vgui.Create("DImageButton", playerinv)
        deleteButton:SetImage("icon16/cross.png")
        deleteButton:SizeToContents()
        deleteButton:SetPos(playerinv:GetWide() - 20, 4)
        deleteButton.DoClick = function()
            Derma_Query("Are you sure you want to delete this faction storage?", "", "OK", function()
                net.Start("factionstoreDelete")
                    net.WriteEntity(ent)
                net.SendToServer()
                panel:Close()
            end, "CANCEL", nil)
        end
    end
end

net.Receive("openFSConfigMenu", function(len, ply)
	if LocalPlayer():IsSuperAdmin() and IsStaffFaction(LocalPlayer()) then
		OpenFactionChoice(net.ReadEntity())
	end
end)

net.Receive("factionstoreOpenInv", OpenInv)

local function LogTransfer(item, deposit, factionInv)
    net.Start("factionstoreLog")
        net.WriteBool(deposit)
        net.WriteString(item:getName())
        net.WriteInt(factionInv.id, 32)
    net.SendToServer()
end

local function TransferLogger(item, oldInv, newInv)
    if newInv.vars.isBag == "factionstore" and oldInv.vars.isBag != "factionstore" then
        LogTransfer(item, true, newInv)
    elseif oldInv.vars.isBag == "factionstore" and newInv.vars.isBag != "factionstore" then
        LogTransfer(item, false, oldInv)
    end
end
hook.Add("CanItemBeTransfered", "TransferLogger", TransferLogger)
