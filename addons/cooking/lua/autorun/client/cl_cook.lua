surface.CreateFont("CookMenu", {font = "Roboto", size = 20, weight = 500})
surface.CreateFont("Cook3D2D", {font = "Roboto", size = 64, weight = 500})

--Cook station menu
function foCook.ActiveCooksMenu(menu, activeCooks, items, station)
    if IsValid(menu.activeCooks) then
        menu.activeCooks:Close()
    end

    if IsValid(menu.takeAll) then
        menu.takeAll:Remove()
    end

    if #activeCooks == 0 and jlib.TableSum(items) == 0 then
        return
    end

    local frame = vgui.Create("UI_DFrame")
    frame:SetSize(300, 800)
    frame:Center()
    frame:MoveLeftOf(menu, 20)
    frame:SetTitle("Cooking")
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
    for k, cook in pairs(activeCooks) do
        local food = foCook.Foods[cook.item]

        local cookPanel = vgui.Create("UI_DPanel_Bordered", scrollPanel)
        cookPanel:SetSize(200, 75)
        cookPanel:SetPos(((frame:GetWide() - 30) / 2) - (cookPanel:GetWide() / 2), i * 95)
        cookPanel.Paint = function(s, w, h)
            surface.SetDrawColor(nut.gui.palette.color_background)
            surface.DrawRect(0, 0, w, h)

            //DisableClipping(true)
            surface.SetDrawColor(Color(0, 0, 0))
            surface.DrawOutlinedRect(2, 2, w - 1, h - 1)

            surface.SetDrawColor(nut.gui.palette.color_primary)
            surface.DrawOutlinedRect(0, 0, w, h)
            surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
            //DisableClipping(false)
        end

        local cookIcon = vgui.Create("nutSpawnIcon", cookPanel)
        cookIcon:SetModel(food.model)
        cookIcon:SetSize(64, 64)
        cookIcon:Dock(LEFT)

        local cookName = vgui.Create("UI_DLabel", cookPanel)
        cookName:SetText(food.name)
        cookName:SetFont("CookMenu")
        cookName:SizeToContents()
        cookName:MoveRightOf(cookIcon)

        local progressBar = vgui.Create("DPanel", cookPanel)
        progressBar:SetSize(100, 12)
        progressBar.Paint = function(s, w, h)
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawOutlinedRect(0, 0, w, h)

            surface.SetDrawColor(100, 255, 100, 255)
            surface.DrawRect(1, 1, (w - 2) * math.min((CurTime() - cook.startTime) / (cook.endTime - cook.startTime), 1), h - 2)
        end
        progressBar:MoveRightOf(cookIcon)
        progressBar:MoveBelow(cookName, 3)

        i = i + 1
    end

    for item, amts in pairs(items) do
        for quality, amt in pairs(amts) do
            for j = 1, amt do
                local food = foCook.Foods[item]

                local cookPanel = vgui.Create("UI_DPanel_Bordered", scrollPanel)
                cookPanel:SetSize(200, 75)
                cookPanel:SetPos(((frame:GetWide() - 30) / 2) - (cookPanel:GetWide() / 2), i * 95)
                cookPanel.Paint = function(s, w, h)
                    surface.SetDrawColor(nut.gui.palette.color_background)
                    surface.DrawRect(0, 0, w, h)

                    //DisableClipping(true)
                    surface.SetDrawColor(Color(0, 0, 0))
                    surface.DrawOutlinedRect(2, 2, w - 1, h - 1)

                    surface.SetDrawColor(nut.gui.palette.color_primary)
                    surface.DrawOutlinedRect(0, 0, w, h)
                    surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
                    //DisableClipping(false)
                end

                local cookIcon = vgui.Create("nutSpawnIcon", cookPanel)
                cookIcon:SetModel(food.model)
                cookIcon:SetSize(64, 64)
                cookIcon:Dock(LEFT)

                local cookName = vgui.Create("UI_DLabel", cookPanel)
                cookName:SetText(food.name)
                cookName:SetFont("CookMenu")
                cookName:SizeToContents()
                cookName:MoveRightOf(cookIcon)

                local takeFood = vgui.Create("UI_DButton", cookPanel)
                takeFood:SetSize(100, 18)
                takeFood:MoveRightOf(cookIcon)
                takeFood:MoveBelow(cookName, 3)
                takeFood:SetText("Take")
                takeFood:SetFont("CookMenu")
                takeFood.DoClick = function(s)
                    net.Start("CookTakeFood")
                        net.WriteString(item)
                        net.WriteEntity(station)
                    net.SendToServer()
                end

                i = i + 1
            end
        end
    end

    local takePanel = vgui.Create("UI_DPanel_Horizontal")
    takePanel:SetSize(300, 30)
    takePanel:SetPos(frame:GetPos())
    takePanel:MoveBelow(frame, 20)
    takePanel:MakePopup()

    local takeAll = vgui.Create("UI_DButton", takePanel)
    takeAll.DoClick = function(s)
        net.Start("CookTakeAll")
            net.WriteEntity(station)
        net.SendToServer()
    end
    takeAll:SetText("Take All")
    takeAll:DockMargin(3, 3, 3, 3)
    takeAll:Dock(FILL)
    takeAll:SetContentAlignment(5)
    takeAll:SetFont("CookMenu")

    menu.activeCooks = frame
    menu.takeAll = takePanel
end

function foCook.Menu()
    local station = net.ReadEntity()

    local char = LocalPlayer():getChar()
    local inv = char:getInv()

    local frame = vgui.Create("UI_DFrame")
    frame:SetDraggable(false)
    frame:SetSize(450, 800)
    frame:SetTitle("Foods")
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

        if IsValid(frame.activeCooks) then
            frame.activeCooks:Close()
        end

        if IsValid(frame.takeAll) then
            frame.takeAll:Remove()
        end
    end
    closeButton:SetText("Close")
    closeButton:DockMargin(3, 3, 3, 3)
    closeButton:Dock(FILL)
    closeButton:SetContentAlignment(5)
    closeButton:SetFont("CookMenu")
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
    for k, food in SortedPairsByMemberValue(foCook.Foods, "time") do
        local itemPanel = vgui.Create("UI_DPanel_Bordered", scrollPanel)
        itemPanel:SetSize(300, 75)
        itemPanel:SetPos(((frame:GetWide() - 30) / 2) - (itemPanel:GetWide() / 2), i * 100)
        itemPanel.Paint = function(s, w, h)
            surface.SetDrawColor(nut.gui.palette.color_background)
            surface.DrawRect(0, 0, w, h)

            //DisableClipping(true)
            surface.SetDrawColor(Color(0, 0, 0))
            surface.DrawOutlinedRect(2, 2, w - 1, h - 1)

            surface.SetDrawColor(nut.gui.palette.color_primary)
            surface.DrawOutlinedRect(0, 0, w, h)
            surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
            //DisableClipping(false)
        end

        local itemIcon = vgui.Create("nutSpawnIcon", itemPanel)
        itemIcon:SetModel(food.model)
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
            rFrame:SetTitle("Ingredients")

            local j = 1
            for ingredientID, amt in pairs(food.recipe) do
                local ingredientLabel = vgui.Create("UI_DLabel", rFrame)
                ingredientLabel:SetText(foCook.Ingredients[ingredientID].name .. " x" .. amt)
                ingredientLabel:SetFont("CookMenu")
                ingredientLabel:SizeToContents()
                ingredientLabel:SetPos(5, 30 * j)

                if #inv:getItemsByUniqueID(ingredientID) >= amt then
                    ingredientLabel:SetTextColor(Color(100, 255, 100, 255))
                else
                    ingredientLabel:SetTextColor(Color(255, 100, 100, 255))
                end

                j = j + 1
            end

            local cookButton = vgui.Create("UI_DButton", rFrame)
            cookButton:SetText("Start Cooking")
            cookButton:SetPos(5, 30 * j)
            cookButton:SetWide(rFrame:GetWide() - 8)
            cookButton:SetTall(22)
            cookButton.DoClick = function(self)
                net.Start("CookStartCook")
                    net.WriteString(k)
                    net.WriteEntity(station)
                net.SendToServer()
            end
            cookButton:SetFont("CookMenu")

            rFrame:SizeToChildren(false, true)
            local _, h = rFrame:GetSize()
            rFrame:SetSize(200, 20)

            rFrame:SetPaintedManually(false)

            rFrame:SizeTo(200, h, 0.6)
        end

        local itemName = vgui.Create("UI_DLabel", itemPanel)
        itemName:SetText(food.name)
        itemName:SetFont("CookMenu")
        itemName:SizeToContents()
        itemName:MoveRightOf(itemIcon)

        local itemTime = vgui.Create("UI_DLabel", itemPanel)
        itemTime:SetText("Cooking Time: " .. (food.time or 60) .. "s")
        itemTime:SetFont("CookMenu")
        itemTime:SizeToContents()
        itemTime:MoveBelow(itemName, 3)
        itemTime:MoveRightOf(itemIcon)

        i = i + 1
    end

    --Update cook panel whenever items/activeCooks changes
    local activeCooksOriginal = station:getNetVar("activeCooks", {})
    local itemsOriginal = station:getNetVar("items", {})

    if #activeCooksOriginal > 0 or jlib.TableSum(itemsOriginal) > 0 then
        foCook.ActiveCooksMenu(frame, activeCooksOriginal, itemsOriginal, station)
    end

    frame.Think = function()
        local activeCooks = station:getNetVar("activeCooks", {})
        local items = station:getNetVar("items", {})

        if #activeCooks != #activeCooksOriginal or jlib.TableSum(items) != jlib.TableSum(itemsOriginal) then
            activeCooksOriginal = activeCooks
            itemsOriginal = items

            foCook.ActiveCooksMenu(frame, activeCooks, items, station)
        end
    end
end
net.Receive("CookOpenMenu", foCook.Menu)

--Food use
net.Receive("CookUse", function()
    local foodId = net.ReadString()

    foCook.Foods[foodId].onUse(nil, LocalPlayer())
end)