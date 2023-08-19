surface.CreateFont("extractorMenu", {font = "Arial", size = 16, weight = 600})
surface.CreateFont("extractorHUD", {font = "Arial", size = 32, weight = 400})

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

    local progress = math.Clamp(1 - (math.abs(timer.TimeLeft("ExtractorProgress")) / extractorsConfig.ClaimTime), 0, 1)

    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawOutlinedRect(x, y, w, h)
    surface.SetDrawColor(80, 80, 80, 240)
    surface.DrawRect(x + 1, y + 1, w - 2, h - 2)
    surface.SetDrawColor(contested and Color(250, 44, 44, 255) or Color(66, 134, 244, 255))
    surface.DrawRect(x + 1, y + 1, (progress * w) - 2, h - 2)

    ShadowText(contested and "CONTESTED" or ("Claiming" .. dots[dot]), "extractorHUD", x + (w/2), y, Color(255, 255, 255, 255), Color(0, 0, 0, 255), 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end


local enemies = {}
local alertMat = Material("extractorenemy.png")
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
            ShadowText("ENEMY", "extractor3D2D", 0, 45, Color(250, 44, 44, 255), Color(0, 0, 0, 255), 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        cam.End3D2D()
    end
end
hook.Add("PostDrawOpaqueRenderables", "ExtractorDrawEnemy", DrawEnemy)

net.Receive("StartExtractorClaim", function()
    local owner = net.ReadEntity()
    enemies[owner] = true

    contested = false
    timer.Create("ExtractorProgress", extractorsConfig.ClaimTime, 1, function()
        hook.Remove("HUDPaint", "ExtractorProgress")
    end)
    hook.Add("HUDPaint", "ExtractorProgress", DrawProgressBar)
end)

net.Receive("HaltExtractorClaim", function()
    local owner = net.ReadEntity()
    hook.Remove("HUDPaint", "ExtractorProgress")
    enemies[owner] = nil
end)

net.Receive("ExtractorClaimStarted", function()
    local attacker = net.ReadEntity()
    enemies[attacker] = true
end)

net.Receive("ExtractorClaimHalted", function()
    local attacker = net.ReadEntity()
    enemies[attacker] = nil
end)

net.Receive("ExtractorContest", function()
    contested = net.ReadBool()
    if contested then
        timer.Pause("ExtractorProgress")
    else
        timer.UnPause("ExtractorProgress")
    end
end)

local function ButtonPaint(s, w, h)
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

local function SelectionMenu()
    local extractor = net.ReadEntity()
    local c = nut.gui.palette.color_primary
    local hoverColor = Color(c.r - (c.r/4), c.g - (c.g/4), c.b - (c.b/4))
    local curItem = nut.item.list[extractor:GetProductionID()]

    local background = vgui.Create("UI_DFrame")
    background:SetSize(ScrW(), ScrH())
    background:SetTitle("")
    background.Paint = function(s, w, h)
        nut.util.drawBlur(s, 5)
        surface.SetDrawColor(0, 0, 0, 235)
        surface.DrawRect(0, 0, w, h)
    end

    local frame = vgui.Create("UI_DFrame")
    frame:MakePopup()
    frame:SetDraggable(false)
    frame:SetSize(400, 800)
    frame:SetTitle("Production Menu")
    frame:Center()
    frame.OnClose = function()
        background:Close()
    end

    local currentItemFrame = vgui.Create("UI_DFrame")
    currentItemFrame:SetSize(250, 125)
    currentItemFrame:MoveRightOf(frame, 10)
    currentItemFrame:MoveAbove(frame, -currentItemFrame:GetTall())
    currentItemFrame:SetTitle("Currently Producing")

    local currentItem = vgui.Create("nutSpawnIcon", currentItemFrame)
    currentItem:SetModel(curItem and curItem.model or "models/props_c17/streetsign004e.mdl")
    currentItem:SetSize(75, 75)
    currentItem:SetPos(0, 25)

    local currentItemLabel = vgui.Create("UI_DLabel", currentItemFrame)
    currentItemLabel:SetText(curItem and curItem.name or "Nothing")
    currentItemLabel:SetPos(currentItem:GetPos())
    currentItemLabel:SizeToContents()
    currentItemLabel:MoveRightOf(currentItem, 5)

    local currentItemButton = vgui.Create("DButton", currentItemFrame)
    currentItemButton.Paint = ButtonPaint
    currentItemButton:SetPos(currentItemLabel:GetPos())
    currentItemButton:MoveBelow(currentItemLabel, 5)
    currentItemButton:SetText("Inventory")
    currentItemButton:SetSize(115, 75 - currentItemLabel:GetTall())
    currentItemButton:SetTextColor(nut.gui.palette.text_primary)
    currentItemButton:SetExpensiveShadow(1, Color(0, 0, 0))
    currentItemButton:SetFont("UI_Regular")
    currentItemButton.Paint = ButtonPaint
    currentItemButton.OnCursorEntered = function(self)
        self:SetTextColor(hoverColor)
        surface.PlaySound("fallout/ui/ui_focus.wav")
    end
    currentItemButton.OnCursorExited = function(self)
        self:SetTextColor(nut.gui.palette.text_primary)
    end
    currentItemButton.DoClick = function()
        net.Start("ExtractorRequestInv")
            net.WriteEntity(extractor)
        net.SendToServer()
    end

    local close = vgui.Create("UI_DButton", frame)
    close:Dock(BOTTOM)
    close:SetText("CONFIRM")
    close:SetContentAlignment(5)
    close.DoClick = function(self)
        frame:Close()
        currentItemFrame:Close()
    end

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:SetSize(400, 700)
    scroll:SetPos(0, 40)

    local scrollBar = scroll:GetVBar()
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
    local mW = 75
    local mH = 75
    for k,v in pairs(extractorsConfig.Items) do
        local item = nut.item.list[k]
        local time = v.time
        local model = item.model
        local name = item.name

        local modelPanel = vgui.Create("nutSpawnIcon", scroll)
        modelPanel:SetModel(model)
        modelPanel:SetSize(mW, mH)
        modelPanel:SetPos(0, (mH + 5) * i)

        local label = vgui.Create("UI_DLabel", scroll)
        label:SetText(name)
        label:SetPos(modelPanel:GetPos())
        label:SizeToContents()
        label:MoveRightOf(modelPanel, 5)

        local button = vgui.Create("DButton", scroll)
        button:SetPos(label:GetPos())
        button:MoveBelow(label, 5)
        button:SetText("Produce")
        button:SetSize(115, mH - label:GetTall())
        button:SetTextColor(nut.gui.palette.text_primary)
		button:SetExpensiveShadow(1, Color(0, 0, 0))
		button:SetFont("UI_Bold")
        button.Paint = ButtonPaint
        button.OnCursorEntered = function(self)
            self:SetTextColor(hoverColor)
			surface.PlaySound("fallout/ui/ui_focus.wav")
        end
        button.OnCursorExited = function(self)
            self:SetTextColor(nut.gui.palette.text_primary)
        end
        button.DoClick = function()
            net.Start("ExtractorChangeProduction")
                net.WriteEntity(extractor)
                net.WriteString(k)
                net.WriteString(name)
            net.SendToServer()

            currentItemLabel:SetText(name)
            currentItemLabel:SizeToContents()
            currentItem:SetModel(model)
        end

        i = i + 1

        local timeLabel = vgui.Create("UI_DLabel", scroll)
        timeLabel:SetText("Production Time: " .. time .. "s")
        timeLabel:SetPos(label:GetPos())
        timeLabel:MoveBelow(label)
        timeLabel:MoveRightOf(button, 5)
        timeLabel:SizeToContents()
    end
end
net.Receive("ExtractorOpenMenu", SelectionMenu)

local function OpenInv()
    local inventory = nut.item.inventories[net.ReadInt(32)]

    local panel = vgui.Create("nutInventory")
    panel:ShowCloseButton(true)
    panel:SetTitle("Extractor Inventory")
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
net.Receive("ExtractorOpenInv", OpenInv)

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
        net.Start("ExtractorConfirm")
            net.WriteEntity(ent)
        net.SendToServer()
    end

    local warning = vgui.Create("UI_DLabel", frame)
    warning:SetText("You are attempting to claim another person's extractor for your own. If you choose to continue the owner may kill you for attempting this.")
    warning:SetWrap(true)
    warning:SetSize(frame:GetSize())
    warning:SetPos(0, -20)
end
net.Receive("ExtractorAsk", Ask)