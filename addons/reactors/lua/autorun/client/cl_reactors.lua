surface.CreateFont("reactorMenu", {font = "Arial", size = 16, weight = 600})
surface.CreateFont("reactorHUD", {font = "Arial", size = 32, weight = 400})

local function ShadowText(text, font, x, y, colortext, colorshadow, dist, xalign, yalign)
    draw.SimpleText(text, font, x + dist, y + dist, colorshadow, xalign, yalign)
    draw.SimpleText(text, font, x, y, colortext, xalign, yalign)
end

local contested = false

local dot = 1
local dots = {
    "",
    ".",
    "..",
    "..."
}
local nextDot = CurTime()

local function DrawProgressBar()
    if CurTime() >= nextDot then
        nextDot = CurTime() + 1
        dot = dot + 1
        if dot > 4 then dot = 1 end
    end

    local w = 800
    local h = 30
    local x = ScrW()/2 - w/2
    local y = 150

    local progress = math.Clamp(1 - (math.abs(timer.TimeLeft("ReactorProgress")) / fusionConfig.ClaimTime), 0, 1)

    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawOutlinedRect(x, y, w, h)
    surface.SetDrawColor(80, 80, 80, 240)
    surface.DrawRect(x + 1, y + 1, w - 2, h - 2)
    surface.SetDrawColor(contested and Color(250, 44, 44, 255) or Color(66, 134, 244, 255))
    surface.DrawRect(x + 1, y + 1, (progress * w) - 2, h - 2)

    ShadowText(contested and "CONTESTED" or ("Claiming" .. dots[dot]), "reactorHUD", x + (w/2), y, Color(255, 255, 255, 255), Color(0, 0, 0, 255), 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end


local enemies = {}
local alertMat = Material("reactorenemy.png")
local function DrawEnemy()
    local w = 160
    local h = 160
    for k,v in pairs(enemies) do
        local ply = k
        if !IsValid(ply) then
            enemies[ply] = nil
            continue
        end

        local eyeAng = EyeAngles()
        eyeAng.p = 0
        eyeAng.y = eyeAng.y - 90
        eyeAng.r = 90

        local bone = ply:LookupBone("ValveBiped.Bip01_Head1")
        local pos = bone and (ply:GetBonePosition(bone) + Vector(0, 0, 15)) or (ply:GetPos() + Vector(0, 0, (ply:OBBMaxs().z * ply:GetModelScale()) + 35))

        cam.Start3D2D(pos, eyeAng, 0.05)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(alertMat)
            surface.DrawTexturedRect(-w/2, (-h/2) - 10, w, h)
            ShadowText("ENEMY", "reactor3D2D", 0, 45, Color(250, 44, 44, 255), Color(0, 0, 0, 255), 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        cam.End3D2D()
    end
end
hook.Add("PostDrawOpaqueRenderables", "ReactorDrawEnemy", DrawEnemy)

net.Receive("StartReactorClaim", function()
    local owner = net.ReadEntity()
    enemies[owner] = true

    contested = false
    timer.Create("ReactorProgress", fusionConfig.ClaimTime, 1, function()
        hook.Remove("HUDPaint", "ReactorProgress")
    end)
    hook.Add("HUDPaint", "ReactorProgress", DrawProgressBar)
end)

net.Receive("HaltReactorClaim", function()
    local owner = net.ReadEntity()
    hook.Remove("HUDPaint", "ReactorProgress")
    enemies[owner] = nil
end)

net.Receive("ReactorClaimStarted", function()
    local attacker = net.ReadEntity()
    enemies[attacker] = true
end)

net.Receive("ReactorClaimHalted", function()
    local attacker = net.ReadEntity()
    enemies[attacker] = nil
end)

net.Receive("ReactorContest", function()
    contested = net.ReadBool()
    if contested then
        timer.Pause("ReactorProgress")
    else
        timer.UnPause("ReactorProgress")
    end
end)

local function ButtonPaint(s, w, h)
    surface.SetDrawColor(nut.gui.palette.color_background)
    surface.DrawRect(0, 0, w, h)

    DisableClipping(true)
    surface.SetDrawColor(Color(0, 0, 0))
    surface.DrawOutlinedRect(2, 2, w - 1, h - 1)

    surface.SetDrawColor(nut.gui.palette.color_primary)
    surface.DrawOutlinedRect(0, 0, w, h)
    surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
    DisableClipping(false)
end

local function ReactorMenu()
    local reactor = net.ReadEntity()
    local timeLeft = net.ReadInt(32)
    local readyTime

    if reactor:GetFuel() > 0 and timeLeft != -1 then
        readyTime = CurTime() + timeLeft
    end

    local frame = vgui.Create("UI_DFrame")
    frame:SetSize(450, 300)
    frame:Center()
    frame:SetTitle("Reactor")
    frame:MakePopup()

    local isFilled = false
    local material

    local materialFrame = vgui.Create("DPanel", frame)
    materialFrame:SetSize(100, 100)
    materialFrame:SetPos(10, 40)
    materialFrame.Paint = ButtonPaint
    materialFrame.Think = function(s)
        if reactor:GetFuel() > 0 and !isFilled then
            material = vgui.Create("nutSpawnIcon", materialFrame)
            material:SetModel(fusionConfig.MaterialModel)
            material:SetSize(92, 92)
            isFilled = true
        elseif reactor:GetFuel() < 1 and isFilled then
            material:Remove()
            material = nil
            isFilled = false
        end
    end

    local fuelBar = vgui.Create("DPanel", materialFrame)
    fuelBar:SetSize(6, 90)
    fuelBar:SetPos(89, 5)

    local fuelFill = vgui.Create("DPanel", fuelBar)
    fuelFill:SetSize(4, 88)
    fuelFill:SetPos(1, 1)
    fuelFill.Paint = function(s, w, h)
        local f = reactor:GetFuel()/fusionConfig.maxUses
        surface.SetDrawColor(HSVToColor(150 * (f - 1/4), 1, 1))
        surface.DrawRect(0, h * (1 - f), w, h * f)
    end

    local fuelAmt = reactor:GetFuel()
    local ieButton = vgui.Create("UI_DButton", frame)
    ieButton:SetText(fuelAmt > 1 and "Eject Fuel" or "Insert Fuel")
    ieButton:SizeToContents()
    ieButton:SetPos(0, 40)
    ieButton:MoveRightOf(materialFrame, 5)
    ieButton.Think = function(s)
        if reactor:GetFuel() > 0 then
            s:SetText("Eject Fuel")
            s:SizeToContents()
            s.DoClick = function(self)
                net.Start("ReactorEjectFuel")
                    net.WriteEntity(reactor)
                net.SendToServer()
            end
        else
            s:SetText("Insert Fuel")
            s:SizeToContents()
            s.DoClick = function(self)
                local hasFuel = false
                local items = LocalPlayer():getChar():getInv():getItems()

                for _,item in pairs(items) do
                    if item.uniqueID == "component_nuclear_material" and item:getData("uses", fusionConfig.maxUses) > 0 then
                        hasFuel = true
                    end
                end

                net.Start("ReactorInsertFuel")
                    net.WriteEntity(reactor)
                net.SendToServer()

                if hasFuel then
                    readyTime = CurTime() + fusionConfig.ProductionTime
                end
            end
        end
    end

    local progressBar = vgui.Create("DPanel", frame)
    progressBar:SetSize(200, 25)
    progressBar:SetPos(114, 75)

    local progressFill = vgui.Create("DPanel", progressBar)
    progressFill:SetSize(198, 23)
    progressFill:SetPos(1, 1)
    progressFill.Paint = function(s, w, h)
        if !readyTime or reactor:GetFuel() < 1 then return end

        local t = 1 - ((readyTime - CurTime()) / fusionConfig.ProductionTime)

        if t >= 1 then
            readyTime = CurTime() + fusionConfig.ProductionTime
        end

        surface.SetDrawColor(HSVToColor(120 * t, 1, 1))
        surface.DrawRect(0, 0, w * t, h)
    end

    local closeButton = vgui.Create("UI_DButton", frame)
    closeButton:Dock(BOTTOM)
    closeButton:SetText("Close")
    closeButton.DoClick = function(s)
        frame:Close()
    end

    local inventoryButton = vgui.Create("UI_DButton", frame)
    inventoryButton:Dock(BOTTOM)
    inventoryButton:SetText("Inventory")
    inventoryButton.DoClick = function(s)
        net.Start("ReactorRequestInv")
            net.WriteEntity(reactor)
        net.SendToServer()
    end

    if reactor:GetOwnership() == LocalPlayer() then
        local factionAccessLabel = vgui.Create("UI_DLabel", frame)
        factionAccessLabel:SetText("Allow Faction Access: ")
        factionAccessLabel:SizeToContents()
        factionAccessLabel:MoveBelow(materialFrame, 2)
        factionAccessLabel:MoveLeftOf(materialFrame, -factionAccessLabel:GetWide())

        local factionAccessCheck = vgui.Create("DButton", frame)
        factionAccessCheck:SetPos(factionAccessLabel:GetPos())
        factionAccessCheck:MoveRightOf(factionAccessLabel, 3)
        factionAccessCheck:SetSize(22, 22)
        factionAccessCheck:SetText("")
        factionAccessCheck.Paint = function(s, w, h)
            surface.SetDrawColor(s:IsHovered() and Color(0, 0, 0, 160) or Color(0, 0, 0, 100))
            surface.DrawRect(0, 0, w, h)

            if reactor:GetFactionAccess() then
                surface.SetDrawColor(nut.gui.palette.color_primary)
                surface.DrawLine(0, 0, w, h)
                surface.DrawLine(w, 0, 0, h)
            end
            surface.SetDrawColor(Color(0, 0, 0, 160))
            surface.DrawOutlinedRect(0, 0, w, h)
        end
        factionAccessCheck.DoClick = function(s)
            net.Start("ReactorFactionAccessToggle")
                net.WriteEntity(reactor)
            net.SendToServer()
        end
    end
end
net.Receive("ReactorOpenMenu", ReactorMenu)

local function OpenInv()
    local inventory = nut.item.inventories[net.ReadInt(32)]

    local panel = vgui.Create("nutInventory")
    panel:ShowCloseButton(true)
    panel:SetTitle("Reactor Inventory")
    panel:setInventory(inventory)

    local playerinv = vgui.Create("nutInventory")
    playerinv:ShowCloseButton(false)
    playerinv:setInventory(LocalPlayer():getChar():getInv())
    playerinv:viewOnly()
    playerinv:SetDraggable(false)
    playerinv.Think = function(s)
        s:MoveRightOf(panel)
        s:MoveBelow(panel, -s:GetTall())
    end

    panel.OnClose = function()
        playerinv:Close()
    end
end
net.Receive("ReactorOpenInv", OpenInv)

local function Ask()
    local ent = net.ReadEntity()

    local frame = vgui.Create("UI_DFrame")
    frame:SetSize(300, 220)
    frame:SetTitle("WARNING")
    frame:Center()
    frame:MakePopup()

    local cancel = vgui.Create("UI_DButton", frame)
    cancel:Dock(BOTTOM)
    cancel:SetText("CANCEL")
    cancel.DoClick = function()
        frame:Close()
    end

    local confirm = vgui.Create("UI_DButton", frame)
    confirm:Dock(BOTTOM)
    confirm:SetText("CONTINUE")
    confirm.DoClick = function()
        frame:Close()
        net.Start("ReactorConfirm")
            net.WriteEntity(ent)
        net.SendToServer()
    end

    local warning = vgui.Create("UI_DLabel", frame)
    warning:SetText("You are attempting to claim another person's reactor for your own. If you choose to continue the owner may kill you for attempting this.")
    warning:SetWrap(true)
    warning:SetSize(frame:GetSize())
    warning:SetPos(0, -20)
end
net.Receive("ReactorAsk", Ask)