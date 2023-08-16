INSTITUTE = INSTITUTE or {}
INSTITUTE.Synths = INSTITUTE.Synths or {}

local cd = 0
local notifCD = 0
local instituteBase

hook.Add("InitPostEntity", "tekwsotopwtko", function()
    INSTITUTE.CreateBaseChecker()
end)

function INSTITUTE.CreateBaseChecker()
    local ply = LocalPlayer()

    timer.Create("INSTITUTE_BASE_CHECKER", 1, 0, function()
        if !ply:Alive() then return end
        if !instituteBase then
            for k, v in pairs(Areas.Instances) do
                local faction = v:GetFactionUID()

                if faction == "institute" then
                    instituteBase = v
                end
            end

            if !instituteBase then return end
        end

        if INSTITUTE.WhitelistedIDs[ply:SteamID()] then
            if instituteBase:IsPlayerInArea(ply) and notifCD < CurTime() then
                vgui.Create("nutFalloutNotice"):open("[INSTITUTE] Welcome home.", "common/wpn_hudoff.wav")
                notifCD = CurTime() + 600
            end
            return 
        end

        if ply:getNetVar("InstAbducted") then
            if instituteBase:IsPlayerInArea(ply) and notifCD < CurTime() then 
                vgui.Create("nutFalloutNotice"):open("You are not supposed to be here. . .", "blackhole/bh_end.wav")
                notifCD = CurTime() + 1200
            end
            return 
        end

        if instituteBase:IsPlayerInArea(ply) and cd < CurTime() then
            vgui.Create("nutFalloutNotice"):open("You are not allowed here...", "blackhole/bh_end.wav")

            net.Start("INSTITUTE_BASEHANDLER")
            net.SendToServer()

            cd = CurTime() + 1
        end
    end)
end

net.Receive("INSTITUTE_CREATEBINDS", function()
    jSettings.AddBinder("Binds", "Teleport Home", {"institute_home"})
    jSettings.AddBinder("Binds", "Abduct", {"institute_abduct"})
    jSettings.AddBinder("Binds", "Dash", {"institute_dash"})
    
    vgui.Create("nutFalloutNotice"):open("[INSTITUTE] Created binds.", "Sonic_Mania/Attack6_R.wav")
end)

net.Receive("INSTITUTE_RETRIEVESYNTH", function()
    local synthList = net.ReadTable()
    local ply = LocalPlayer()

    INSTITUTE.Synths = synthList
end)

local PANEL = {}
local instBaseCol = Color(255, 255, 255)
local instTextCol = Color(0, 0, 0)

local function paintBG(main, w, h)
    surface.SetDrawColor(ColorAlpha(instTextCol, 150))
    surface.DrawRect(0, 24, w, h)

    local tW, tH = main.lblTitle:GetContentSize() or 0, 0

    DisableClipping(true)

    surface.SetDrawColor(instBaseCol)
    surface.DrawRect(1, 23, 8, 2)
    surface.DrawRect(tW + 11, 23, w - (tW + 11), 2)
    surface.DrawRect(-1, 23, 2, 6)
    surface.DrawRect(w + 1, 23, 2, 6)
    surface.DrawRect(1, h + 2, w + 2, 1)
    surface.DrawRect(-1, h - 3, 2, 6)
    surface.DrawRect(w + 2, h - 3, 1, 6)

    surface.SetDrawColor(instBaseCol)
    surface.DrawRect(0, 22, 8, 2)
    surface.DrawRect(tW + 10, 22, w - (tW + 10), 2)
    surface.DrawRect(-2, 22, 2, 6)
    surface.DrawRect(w, 22, 2, 6)
    surface.DrawRect(0, h, w, 2)
    surface.DrawRect(-2, h - 4, 2, 6)
    surface.DrawRect(w, h - 4, 2, 6)

    DisableClipping(false)
end
local function buttonHover(panel, w, h)
    if (panel:GetPaintBackground()) then
        if (((panel:IsHovered() or panel:IsDown()) and !panel:GetDisabled()) or panel.active) then
            surface.SetDrawColor(Color(0, 0, 0))
            DisableClipping(true)
            surface.DrawRect(1, 1, w, h)
            DisableClipping(false)

            if (panel.active) then
                surface.SetDrawColor(nut.gui.palette.color_hover)
            else
                surface.SetDrawColor(instBaseCol)
            end

            surface.DrawRect(0, 0, w, h)
        end
    end
end
function PANEL:Init()
    net.Start("INSTITUTE_RETRIEVESYNTH")
    net.SendToServer()

    self.lblTitle:SetTextColor(instBaseCol)
    self.lblTitle:SetExpensiveShadow(1, Color(0, 0, 0))
    self.lblTitle:SetFont("UI_Bold")

    self:DockPadding(12, 24 + 12, 12, 12)
    self:SetDraggable(false)

    local w, h = ScrW(), ScrH()
    self:SetSize( w * .5, h * .9 )
    self:Center()
    self:MakePopup()
    self:ShowCloseButton(true)
    self:SetTitle("Institute - Synth List")

    self.logo = self:Add("DPanel")
    self.logo:SetSize(64, 64)
    self.logo:SetPos( self:GetWide() * .5 - 32, self:GetTall() * .125 - 32)
    self.logo.Paint = function(s, w, h)
        surface.SetMaterial(FalloutScoreboard.FactionMaterials["institute"])
        surface.SetDrawColor(255, 255, 255)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    self.bringall = self:Add("UI_DButton")
    self.bringall:Dock(TOP)
    self.bringall:DockMargin(0, 0, 0, h * .1)
    self.bringall:SetText("Bring all Synths")
    self.bringall:SetContentAlignment(5)
    self.bringall:SetTextColor(instBaseCol)
    self.bringall.Paint = function(main, w, h)
        buttonHover(main, w, h)
    end

    self.bringall.OnCursorEntered = function()
        if (!self.bringall:GetDisabled() and !self.bringall.active) then
            self.bringall:SetTextColor(nut.gui.palette.text_hover)
            self.bringall:SetExpensiveShadow(0, Color(0, 0, 0))
            surface.PlaySound("fallout/ui/ui_focus.wav")
        end
    end

    self.bringall.OnCursorExited = function()
        if (!self.bringall:GetDisabled() and !self.bringall.active) then
            self.bringall:SetTextColor(instBaseCol)
            self.bringall:SetExpensiveShadow(1, Color(0, 0, 0))
        end
    end
    self.bringall.OnMousePressed = function()
        if (!self.bringall:GetDisabled() and !self.bringall.active) then
            self.bringall:DoClick()
            net.Start("INSTITUTE_BRINGALL")
            net.SendToServer()
            vgui.Create("nutFalloutNotice"):open("[INSTITUTE] Initializing teleporter...", "Sonic_Mania/Attack6_R.wav")
            surface.PlaySound("ui/char" .. math.random(1, 5) .. ".wav")
        end
    end

    self.scrollP = self:Add("UI_DScrollPanel")
    self.scrollP:Dock(FILL)

    timer.Simple(1, function()
        for k, v in ipairs(INSTITUTE.Synths or {}) do
            local charData = nut.char.loaded[v]
            if !charData then continue end
            
            local p = self.scrollP:Add("UI_DFrame")
            p:Dock(TOP)
            p:DockMargin(0, 0, w * .01, 5)
            p:SetTall( h * .1 )
            p:SetTitle(charData:getName())
            p.lblTitle:SetTextColor(instBaseCol)
            p.lblTitle:SetExpensiveShadow(1, Color(0, 0, 0))
            p.lblTitle:SetFont("UI_Bold")
            p.Paint = function(main, w, h)
                paintBG(main, w, h)
            end
            
            local bringB = p:Add("UI_DButton")
            bringB:SetText("BRING")
            bringB:SetContentAlignment(5)
            bringB:SetTextColor(instBaseCol)
            bringB:Dock(BOTTOM)
            bringB.Paint = function(main, w, h)
                buttonHover(main, w, h)
            end

            bringB.OnCursorEntered = function()
                if (!bringB:GetDisabled() and !bringB.active) then
                    bringB:SetTextColor(nut.gui.palette.text_hover)
                    bringB:SetExpensiveShadow(0, Color(0, 0, 0))
                    surface.PlaySound("fallout/ui/ui_focus.wav")
                end
            end
        
            bringB.OnCursorExited = function()
                if (!bringB:GetDisabled() and !bringB.active) then
                    bringB:SetTextColor(instBaseCol)
                    bringB:SetExpensiveShadow(1, Color(0, 0, 0))
                end
            end
            bringB.OnMousePressed = function()
                if (!bringB:GetDisabled() and !bringB.active) then
                    bringB:DoClick()
                    net.Start("INSTITUTE_BRINGPRESS")
                        net.WriteEntity(charData:getPlayer())
                    net.SendToServer()
                    vgui.Create("nutFalloutNotice"):open("[INSTITUTE] Initializing teleporter...", "Sonic_Mania/Attack6_R.wav")
                    surface.PlaySound("ui/char" .. math.random(1, 5) .. ".wav")
                end
            end
            
            local gotoB = p:Add("UI_DButton")
            gotoB:SetText("GOTO")
            gotoB:SetTextColor(instBaseCol)
            gotoB:SetContentAlignment(5)
            gotoB:Dock(BOTTOM)
            gotoB.Paint = function(main, w, h)
                buttonHover(main, w, h)
            end
            gotoB.OnCursorEntered = function()
                if (!gotoB:GetDisabled() and !gotoB.active) then
                    gotoB:SetTextColor(nut.gui.palette.text_hover)
                    gotoB:SetExpensiveShadow(0, Color(0, 0, 0))
                    surface.PlaySound("fallout/ui/ui_focus.wav")
                end
            end
            gotoB.OnCursorExited = function()
                if (!gotoB:GetDisabled() and !gotoB.active) then
                    gotoB:SetTextColor(instBaseCol)
                    gotoB:SetExpensiveShadow(1, Color(0, 0, 0))
                end
            end
            gotoB.OnMousePressed = function()
                if (!gotoB:GetDisabled() and !gotoB.active) then
                    gotoB:DoClick()
                    net.Start("INSTITUTE_GOTOPRESS")
                        net.WriteEntity(charData:getPlayer())
                    net.SendToServer()
                    vgui.Create("nutFalloutNotice"):open("[INSTITUTE] Initializing teleporter...", "Sonic_Mania/Attack6_R.wav")
                    surface.PlaySound("ui/char" .. math.random(1, 5) .. ".wav")
                end
            end
        end
    end)
end
function PANEL:Paint(w, h)
    paintBG(self, w, h)
end
vgui.Register("SYNTHLIST", PANEL, "UI_DFrame")

concommand.Add("SYNTHLIST", function()
    if INSTITUTE.WhitelistedIDs[LocalPlayer():SteamID()] then
        vgui.Create("nutFalloutNotice"):open("[INSTITUTE] Viewing Synth List", "common/wpn_hudoff.wav")
        vgui.Create("SYNTHLIST")
    end
end)