surface.CreateFont("ChemsMenu", {font = "Roboto", size = 20, weight = 500})
surface.CreateFont("Chems3D2D", {font = "Roboto", size = 64, weight = 500})

--Chem bench menu
function jChems.ActiveCraftsMenu(menu, activeCrafts, items, bench)
    if IsValid(menu.activeCrafts) then
        menu.activeCrafts:Close()
    end

    if IsValid(menu.takeAll) then
        menu.takeAll:Remove()
    end

    if #activeCrafts == 0 and jlib.TableSum(items) == 0 then
        return
    end

    local frame = vgui.Create("UI_DFrame")
    frame:SetSize(300, 800)
    frame:Center()
    frame:MoveLeftOf(menu, 20)
    frame:SetTitle("Crafting")
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
    for k, craft in pairs(activeCrafts) do
        local chem = jChems.Chems[craft.item]

        local chemPanel = vgui.Create("UI_DPanel_Bordered", scrollPanel)
        chemPanel:SetSize(200, 75)
        chemPanel:SetPos(((frame:GetWide() - 30) / 2) - (chemPanel:GetWide() / 2), i * 95)
        chemPanel.Paint = function(s, w, h)
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

        local chemIcon = vgui.Create("nutSpawnIcon", chemPanel)
        chemIcon:SetModel(chem.model)
        chemIcon:SetSize(64, 64)
        chemIcon:Dock(LEFT)

        local chemName = vgui.Create("UI_DLabel", chemPanel)
        chemName:SetText(chem.name)
        chemName:SetFont("ChemsMenu")
        chemName:SizeToContents()
        chemName:MoveRightOf(chemIcon)

        local progressBar = vgui.Create("DPanel", chemPanel)
        progressBar:SetSize(100, 12)
        progressBar.Paint = function(s, w, h)
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawOutlinedRect(0, 0, w, h)

            surface.SetDrawColor(100, 255, 100, 255)
            surface.DrawRect(1, 1, (w - 2) * math.min((CurTime() - craft.startTime) / (craft.endTime - craft.startTime), 1), h - 2)
        end
        progressBar:MoveRightOf(chemIcon)
        progressBar:MoveBelow(chemName, 3)

        i = i + 1
    end

    for item, amts in pairs(items) do
        for quality, amt in pairs(amts) do
            for j = 1, amt do
                local chem = jChems.Chems[item]

                local chemPanel = vgui.Create("UI_DPanel_Bordered", scrollPanel)
                chemPanel:SetSize(200, 75)
                chemPanel:SetPos(((frame:GetWide() - 30) / 2) - (chemPanel:GetWide() / 2), i * 95)
                chemPanel.Paint = function(s, w, h)
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

                local chemIcon = vgui.Create("nutSpawnIcon", chemPanel)
                chemIcon:SetModel(chem.model)
                chemIcon:SetSize(64, 64)
                chemIcon:Dock(LEFT)

                local chemName = vgui.Create("UI_DLabel", chemPanel)
                chemName:SetText(chem.name)
                chemName:SetFont("ChemsMenu")
                chemName:SizeToContents()
                chemName:MoveRightOf(chemIcon)

                local takeChem = vgui.Create("UI_DButton", chemPanel)
                takeChem:SetSize(100, 18)
                takeChem:MoveRightOf(chemIcon)
                takeChem:MoveBelow(chemName, 3)
                takeChem:SetText("Take")
                takeChem:SetFont("ChemsMenu")
                takeChem.DoClick = function(s)
                    net.Start("ChemsTakeChem")
                        net.WriteString(item)
                        net.WriteEntity(bench)
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
        net.Start("ChemsTakeAll")
            net.WriteEntity(bench)
        net.SendToServer()
    end
    takeAll:SetText("Take All")
    takeAll:DockMargin(3, 3, 3, 3)
    takeAll:Dock(FILL)
    takeAll:SetContentAlignment(5)
    takeAll:SetFont("ChemsMenu")

    menu.activeCrafts = frame
    menu.takeAll = takePanel
end

function jChems.Menu()
    local bench = net.ReadEntity()

    local char = LocalPlayer():getChar()
    local inv = char:getInv()

    local frame = vgui.Create("UI_DFrame")
    frame:SetDraggable(false)
    frame:SetSize(450, 800)
    frame:SetTitle("Chems")
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

        if IsValid(frame.activeCrafts) then
            frame.activeCrafts:Close()
        end

        if IsValid(frame.takeAll) then
            frame.takeAll:Remove()
        end
    end
    closeButton:SetText("Close")
    closeButton:DockMargin(3, 3, 3, 3)
    closeButton:Dock(FILL)
    closeButton:SetContentAlignment(5)
    closeButton:SetFont("ChemsMenu")
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
    for k, chem in SortedPairsByMemberValue(jChems.Chems, "time") do
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
        itemIcon:SetModel(chem.model)
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
            rFrame:SetTitle("Recipe")

            local j = 1
            for componentID, amt in pairs(chem.recipe) do
                local componentLabel = vgui.Create("UI_DLabel", rFrame)
                componentLabel:SetText(jChems.Components[componentID].name .. " x" .. amt)
                componentLabel:SetFont("ChemsMenu")
                componentLabel:SizeToContents()
                componentLabel:SetPos(5, 30 * j)

                if #inv:getItemsByUniqueID(componentID) >= amt then
                    componentLabel:SetTextColor(Color(100, 255, 100, 255))
                else
                    componentLabel:SetTextColor(Color(255, 100, 100, 255))
                end

                j = j + 1
            end

            local craftButton = vgui.Create("UI_DButton", rFrame)
            craftButton:SetText("Start Crafting")
            craftButton:SetPos(5, 30 * j)
            craftButton:SetWide(rFrame:GetWide() - 8)
            craftButton:SetTall(22)
            craftButton.DoClick = function(self)
                net.Start("ChemsStartCraft")
                    net.WriteString(k)
                    net.WriteEntity(bench)
                net.SendToServer()
            end
            craftButton:SetFont("ChemsMenu")

            rFrame:SizeToChildren(false, true)
            local _, h = rFrame:GetSize()
            rFrame:SetSize(200, 20)

            rFrame:SetPaintedManually(false)

            rFrame:SizeTo(200, h, 0.6)
        end

        local itemName = vgui.Create("UI_DLabel", itemPanel)
        itemName:SetText(chem.name)
        itemName:SetFont("ChemsMenu")
        itemName:SizeToContents()
        itemName:MoveRightOf(itemIcon)

        local itemTime = vgui.Create("UI_DLabel", itemPanel)
        itemTime:SetText("Production Time: " .. (chem.time or 60) .. "s")
        itemTime:SetFont("ChemsMenu")
        itemTime:SizeToContents()
        itemTime:MoveBelow(itemName, 3)
        itemTime:MoveRightOf(itemIcon)

        i = i + 1
    end

    --Update craft panel whenever items/activeCrafts changes
    local activeCraftsOriginal = bench:getNetVar("activeCrafts", {})
    local itemsOriginal = bench:getNetVar("items", {})

    if #activeCraftsOriginal > 0 or jlib.TableSum(itemsOriginal) > 0 then
        jChems.ActiveCraftsMenu(frame, activeCraftsOriginal, itemsOriginal, bench)
    end

    frame.Think = function()
        local activeCrafts = bench:getNetVar("activeCrafts", {})
        local items = bench:getNetVar("items", {})

        if #activeCrafts != #activeCraftsOriginal or jlib.TableSum(items) != jlib.TableSum(itemsOriginal) then
            activeCraftsOriginal = activeCrafts
            itemsOriginal = items

            jChems.ActiveCraftsMenu(frame, activeCrafts, items, bench)
        end
    end
end
net.Receive("ChemsOpenMenu", jChems.Menu)

--Chem use
net.Receive("ChemsUse", function()
    local chemID = net.ReadString()
    local quality = net.ReadUInt(32)

    jChems.Chems[chemID].use(nil, LocalPlayer(), quality)
end)

--Effects
jChems.Effects = {}

function jChems.Effects.Blur()
    hook.Add("RenderScreenspaceEffects", "jChemsBlur", function()
        DrawMotionBlur(0.4, 0.8, 0.01)
    end)
end

function jChems.Effects.Sharpen()
    hook.Add("RenderScreenspaceEffects", "jChemsSharpen", function()
        DrawSharpen(0.8, 0.8)
    end)
end

function jChems.Effects.Sharpen()
    hook.Add("RenderScreenspaceEffects", "jChemsSharpen", function()
        DrawSharpen(0.8, 0.8)
    end)
end

function jChems.Effects.Sobel()
    hook.Add("RenderScreenspaceEffects", "jChemsSobel", function()
        DrawSobel(0.5)
    end)
end

function jChems.Effects.ColorModify(color)
    hook.Add("RenderScreenspaceEffects", "jChemsColorModify", function()
        DrawColorModify({
            ["$pp_colour_addr"] = (color.r/255)/10,
            ["$pp_colour_addg"] = (color.g/255)/10,
            ["$pp_colour_addb"] = (color.b/255)/10,
            ["$pp_colour_brightness"] = 0,
            ["$pp_colour_contrast"] = 1,
            ["$pp_colour_colour"] = 3,
            ["$pp_colour_mulr"] = (color.r/255)/10,
            ["$pp_colour_mulg"] = (color.g/255)/10,
            ["$pp_colour_mulb"] = (color.b/255)/10
        })
    end)
end

function jChems.Effects.ToyTown()
    hook.Add("RenderScreenspaceEffects", "jChemsToyTown", function()
        DrawToyTown(2, ScrH() / 2)
    end)
end

function jChems.Effects.Flash()
    LocalPlayer():ScreenFade(1, Color(255, 255, 255, 255), 2, 0)
end

function jChems.Effects.Inject()
    LocalPlayer():EmitSound("ambient/voices/m_scream1.wav")
    jChems.Effects.Flash()
end

function jChems.Effects.Swallow()
    LocalPlayer():EmitSound("npc/barnacle/barnacle_gulp"..math.random(1, 2)..".wav")
    jChems.Effects.Flash()
end

function jChems.Effects.Inhale()
    LocalPlayer():EmitSound("HL1/fvox/hiss.wav")
    jChems.Effects.Flash()
end

function jChems.Effects.Clear()
    hook.Remove("RenderScreenspaceEffects", "jChemsBlur")
    hook.Remove("RenderScreenspaceEffects", "jChemsSharpen")
    hook.Remove("RenderScreenspaceEffects", "jChemsSobel")
    hook.Remove("RenderScreenspaceEffects", "jChemsColorModify")
    hook.Remove("RenderScreenspaceEffects", "jChemsToyTown")
end

--Addiction
net.Receive("ChemsAddiction", function()
    local chemID = net.ReadString()
    local severity = net.ReadInt(32)

    jChems.Chems[chemID].addictionEffects[severity](LocalPlayer())
end)