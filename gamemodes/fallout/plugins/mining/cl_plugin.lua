local PLUGIN = PLUGIN

surface.CreateFont("RefineryMenu", {font = "Roboto", size = 20, weight = 500})

-- Refinery menu
local function activeMeltsMenu(menu, activeMelts, items, refinery)
    if IsValid(menu.activeMelts) then
        menu.activeMelts:Close()
    end

    if IsValid(menu.takeAll) then
        menu.takeAll:Remove()
    end

    if #activeMelts == 0 and PLUGIN:TableSum(items) == 0 then
        return
    end

    local frame = vgui.Create("UI_DFrame")
    frame:SetSize(300, 800)
    frame:Center()
    frame:MoveLeftOf(menu, 20)
    frame:SetTitle("Melting")
    frame:MakePopup()

    local scrollPanel = vgui.Create("DScrollPanel", frame)
    scrollPanel:Dock(FILL)

    local c = nut.gui.palette.color_primary
    local hoverColor = Color(c.r - (c.r/4), c.g - (c.g/4), c.b - (c.b/4))

    local scrollBar = scrollPanel:GetVBar()
    scrollBar:SetHideButtons(true)
    scrollBar.Paint = function() end
    scrollBar.btnGrip.Paint = function(s, w, h)
        if s.Depressed then
            surface.SetDrawColor(hoverColor)
        else
            surface.SetDrawColor(c)
        end
        surface.DrawRect(0, 0, w, h)
    end

    local i = 0
    for k, product in pairs(activeMelts) do
        local productItemTable = nut.item.list[product.item]

        local productPanel = vgui.Create("UI_DPanel_Bordered", scrollPanel)
        productPanel:SetSize(200, 75)
        productPanel:SetPos(((frame:GetWide() - 30) / 2) - (productPanel:GetWide() / 2), i * 95)
        productPanel.Paint = function(s, w, h)
            surface.SetDrawColor(nut.gui.palette.color_background)
            surface.DrawRect(0, 0, w, h)

            --DisableClipping(true)
            surface.SetDrawColor(Color(0, 0, 0))
            surface.DrawOutlinedRect(2, 2, w - 1, h - 1)

            surface.SetDrawColor(nut.gui.palette.color_primary)
            surface.DrawOutlinedRect(0, 0, w, h)
            surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
            --DisableClipping(false)
        end

        local productIcon = vgui.Create("nutSpawnIcon", productPanel)
        productIcon:SetModel(productItemTable.model)
        productIcon:SetSize(64, 64)
        productIcon:Dock(LEFT)

        if (productItemTable.skin) then
            productIcon.Entity:SetSkin(productItemTable.skin)
        end

        local productName = vgui.Create("UI_DLabel", productPanel)
        productName:SetText(productItemTable.name)
        productName:SetFont("RefineryMenu")
        productName:SizeToContents()
        productName:MoveRightOf(productIcon)

        local progressBar = vgui.Create("DPanel", productPanel)
        progressBar:SetSize(100, 12)
        progressBar.Paint = function(s, w, h)
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawOutlinedRect(0, 0, w, h)

            surface.SetDrawColor(100, 255, 100, 255)
            surface.DrawRect(1, 1, (w - 2) * math.min((CurTime() - product.startTime) / (product.endTime - product.startTime), 1), h - 2)
        end
        progressBar:MoveRightOf(productIcon)
        progressBar:MoveBelow(productName, 3)

        i = i + 1
    end

    for item, amt in pairs(items) do
        for j = 1, amt do
            local productItemTable = nut.item.list[item]

            local productPanel = vgui.Create("UI_DPanel_Bordered", scrollPanel)
            productPanel:SetSize(200, 75)
            productPanel:SetPos(((frame:GetWide() - 30) / 2) - (productPanel:GetWide() / 2), i * 95)
            productPanel.Paint = function(s, w, h)
                surface.SetDrawColor(nut.gui.palette.color_background)
                surface.DrawRect(0, 0, w, h)

                --DisableClipping(true)
                surface.SetDrawColor(Color(0, 0, 0))
                surface.DrawOutlinedRect(2, 2, w - 1, h - 1)

                surface.SetDrawColor(nut.gui.palette.color_primary)
                surface.DrawOutlinedRect(0, 0, w, h)
                surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
                --DisableClipping(false)
            end

            local productIcon = vgui.Create("nutSpawnIcon", productPanel)
            productIcon:SetModel(productItemTable.model)
            productIcon:SetSize(64, 64)
            productIcon:Dock(LEFT)

            if (productItemTable.skin) then
                productIcon.Entity:SetSkin(productItemTable.skin)
            end

            local productName = vgui.Create("UI_DLabel", productPanel)
            productName:SetText(productItemTable.name)
            productName:SetFont("RefineryMenu")
            productName:SizeToContents()
            productName:MoveRightOf(productIcon)

            local takeProduct = vgui.Create("UI_DButton", productPanel)
            takeProduct:SetSize(100, 18)
            takeProduct:MoveRightOf(productIcon)
            takeProduct:MoveBelow(productName, 3)
            takeProduct:SetText("Take")
            takeProduct:SetFont("RefineryMenu")
            takeProduct.DoClick = function(s)
                net.Start("RefineryTakeProduct")
                    net.WriteString(item)
                    net.WriteEntity(refinery)
                net.SendToServer()
            end

            i = i + 1
        end
    end

    local takePanel = vgui.Create("UI_DPanel_Horizontal")
    takePanel:SetSize(300, 30)
    takePanel:SetPos(frame:GetPos())
    takePanel:MoveBelow(frame, 20)
    takePanel:MakePopup()

    local takeAll = vgui.Create("UI_DButton", takePanel)
    takeAll.DoClick = function(s)
        net.Start("RefineryTakeAll")
            net.WriteEntity(refinery)
        net.SendToServer()
    end
    takeAll:SetText("Take All")
    takeAll:DockMargin(3, 3, 3, 3)
    takeAll:Dock(FILL)
    takeAll:SetContentAlignment(5)
    takeAll:SetFont("RefineryMenu")

    menu.activeMelts = frame
    menu.takeAll = takePanel
end

local function menu()
    local refinery = net.ReadEntity()

    local char = LocalPlayer():getChar()
    local inv = char:getInv()

    local frame = vgui.Create("UI_DFrame")
    frame:SetDraggable(false)
    frame:SetSize(450, 800)
    frame:SetTitle("Metal Bars")
    frame:Center()

    local closePanel = vgui.Create("UI_DPanel_Horizontal")
    closePanel:SetSize(450, 30)
    closePanel:MoveBelow(frame, 20)
    closePanel:CenterHorizontal()

    local closeButton = vgui.Create("UI_DButton", closePanel)
    closeButton.DoClick = function(s)
        frame:Close()
        closePanel:Remove()

        if IsValid(frame.recipeFrame) then
            frame.recipeFrame:Close()
        end

        if IsValid(frame.activeMelts) then
            frame.activeMelts:Close()
        end

        if IsValid(frame.takeAll) then
            frame.takeAll:Remove()
        end
    end
    closeButton:SetText("Close")
    closeButton:DockMargin(3, 3, 3, 3)
    closeButton:Dock(FILL)
    closeButton:SetContentAlignment(5)
    closeButton:SetFont("RefineryMenu")
    closePanel:MakePopup()
    frame:MakePopup()

    local paint = closePanel.Paint
    local startTime = SysTime()
    closePanel.Paint = function(s, w, h)
        Derma_DrawBackgroundBlur(s, startTime)
        paint(s, w, h)
    end

    local scrollPanel = vgui.Create("DScrollPanel", frame)
    scrollPanel:Dock(FILL)

    local c = nut.gui.palette.color_primary
    local hoverColor = Color(c.r - (c.r/4), c.g - (c.g/4), c.b - (c.b/4))

    local scrollBar = scrollPanel:GetVBar()
    scrollBar:SetHideButtons(true)
    scrollBar.Paint = function() end
    scrollBar.btnGrip.Paint = function(s, w, h)
        if s.Depressed then
            surface.SetDrawColor(hoverColor)
        else
            surface.SetDrawColor(c)
        end
        surface.DrawRect(0, 0, w, h)
    end

    local i = 0
    for k, product in SortedPairsByMemberValue(PLUGIN.Recipes, "time") do
        local time = product[1]
        local recipe = product[2]
        local productItemTable = nut.item.list[k]

        local itemPanel = vgui.Create("UI_DPanel_Bordered", scrollPanel)
        itemPanel:SetSize(300, 75)
        itemPanel:SetPos(((frame:GetWide() - 30) / 2) - (itemPanel:GetWide() / 2), i * 100)
        itemPanel.Paint = function(s, w, h)
            surface.SetDrawColor(nut.gui.palette.color_background)
            surface.DrawRect(0, 0, w, h)

            --DisableClipping(true)
            surface.SetDrawColor(Color(0, 0, 0))
            surface.DrawOutlinedRect(2, 2, w - 1, h - 1)

            surface.SetDrawColor(nut.gui.palette.color_primary)
            surface.DrawOutlinedRect(0, 0, w, h)
            surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
            --DisableClipping(false)
        end

        local itemIcon = vgui.Create("nutSpawnIcon", itemPanel)
        itemIcon:SetModel(productItemTable.model)
    
        if (productItemTable.skin) then
            itemIcon.Entity:SetSkin(productItemTable.skin)
        end

        itemIcon:SetSize(64, 64)
        itemIcon:Dock(LEFT)
        itemIcon.DoClick = function(s)
            if IsValid(frame.recipeFrame) then
                frame.recipeFrame:Close()
            end

            frame.recipeFrame = vgui.Create("UI_DFrame")

            local rFrame = frame.recipeFrame
            rFrame:SetPaintedManually(true)
            rFrame:SetSize(0, 800)
            rFrame:Center()
            rFrame:SetSize(200, 20)
            rFrame:MoveRightOf(frame, 20)
            rFrame:MakePopup()
            rFrame:SetTitle("Required")

            local ingredientLabels = {}

            local j = 1
            for ingredientID, amt in pairs(recipe) do
                local ingredientLabel = vgui.Create("UI_DLabel", rFrame)
                ingredientLabel:SetText(nut.item.list[ingredientID].name .. " x" .. amt)
                ingredientLabel:SetFont("RefineryMenu")
                ingredientLabel:SizeToContents()
                ingredientLabel:SetPos(5, 30 * j)

                if #inv:getItemsByUniqueID(ingredientID) >= amt then
                    ingredientLabel:SetTextColor(Color(100, 255, 100, 255))
                else
                    ingredientLabel:SetTextColor(Color(255, 100, 100, 255))
                end

                ingredientLabels[ingredientID] = {ingredientLabel, amt}

                j = j + 1
            end

            local meltButton = vgui.Create("UI_DButton", rFrame)
            meltButton:SetText("Start Melting")
            meltButton:SetPos(5, 30 * j)
            meltButton:SetWide(rFrame:GetWide() - 8)
            meltButton:SetTall(22)
            meltButton.DoClick = function(self)
                net.Start("RefineryStartMelt")
                    net.WriteString(k)
                    net.WriteEntity(refinery)
                net.SendToServer()

                for ingredientID, v in pairs(ingredientLabels) do
                    if #inv:getItemsByUniqueID(ingredientID) -1 >= v[2] then
                        v[1]:SetTextColor(Color(100, 255, 100, 255))
                    else
                        v[1]:SetTextColor(Color(255, 100, 100, 255))
                    end
                end
            end
            meltButton:SetFont("RefineryMenu")

            rFrame:SizeToChildren(false, true)
            local _, h = rFrame:GetSize()
            rFrame:SetSize(200, 20)

            rFrame:SetPaintedManually(false)

            rFrame:SizeTo(200, h, 0.6)
        end

        local itemName = vgui.Create("UI_DLabel", itemPanel)
        itemName:SetText(productItemTable.name)
        itemName:SetFont("RefineryMenu")
        itemName:SizeToContents()
        itemName:MoveRightOf(itemIcon)

        local itemTime = vgui.Create("UI_DLabel", itemPanel)
        itemTime:SetText("Melting Time: " .. (time or 60) .. "s")
        itemTime:SetFont("RefineryMenu")
        itemTime:SizeToContents()
        itemTime:MoveBelow(itemName, 3)
        itemTime:MoveRightOf(itemIcon)

        i = i + 1
    end

    --Update panel whenever items/activeMelts changes
    local activeMeltsOriginal = refinery:getNetVar("activeMelts", {})
    local itemsOriginal = refinery:getNetVar("items", {})

    if #activeMeltsOriginal > 0 or PLUGIN:TableSum(itemsOriginal) > 0 then
        activeMeltsMenu(frame, activeMeltsOriginal, itemsOriginal, refinery)
    end

    frame.Think = function()
        local activeMelts = refinery:getNetVar("activeMelts", {})
        local items = refinery:getNetVar("items", {})

        if #activeMelts != #activeMeltsOriginal or PLUGIN:TableSum(items) != PLUGIN:TableSum(itemsOriginal) then
            activeMeltsOriginal = activeMelts
            itemsOriginal = items

            activeMeltsMenu(frame, activeMelts, items, refinery)
        end
    end
end
net.Receive("RefineryOpenMenu", menu)