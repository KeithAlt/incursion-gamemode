FORTIFICATIONS = FORTIFICATIONS or {}



local PANEL = {}

function PANEL:Init()

    self:Center()
    self:ShowCloseButton(true)
    self:SetTitle("Artillery Controller")

    local w, h = ScrW(), ScrH()

    self:SetSize(w * .8, h * .25)
    self:SetPos(w * .5 - (self:GetWide() / 2), h - (h * .25) - 50 )
    self:MakePopup()

    self.rotationDock = self:Add("UI_DFrame")
    self.rotationDock:Dock(LEFT)
    self.rotationDock:SetWide(w * .25)
    self.rotationDock:SetTitle("ROTATION")

    self.rotationLeft = self.rotationDock:Add("UI_DButton")
    self.rotationLeft:SetText("LEFT")
    self.rotationLeft:Dock(LEFT)
    self.rotationLeft:SetWide(w * .06)
    self.rotationLeft:SetContentAlignment(5)
    self.rotationLeft.DoClick = function()
        if self.entity:GetDisabled() then return end

        net.Start("FORTIFICATIONS_ARTILLERYROTATELEFT")
            net.WriteEntity(self.entity)
        net.SendToServer()
    end

    self.rotationRight = self.rotationDock:Add("UI_DButton")
    self.rotationRight:SetText("RIGHT")
    self.rotationRight:Dock(LEFT)
    self.rotationRight:SetWide(w * .06)
    self.rotationRight:SetContentAlignment(5)
    self.rotationRight.DoClick = function()
        if self.entity:GetDisabled() then return end

        net.Start("FORTIFICATIONS_ARTILLERYROTATERIGHT")
            net.WriteEntity(self.entity)
        net.SendToServer()
    end

    self.rotationUP = self.rotationDock:Add("UI_DButton")
    self.rotationUP:SetText("UP")
    self.rotationUP:Dock(LEFT)
    self.rotationUP:SetWide(w * .06)
    self.rotationUP:SetContentAlignment(5)
    self.rotationUP.DoClick = function()
        if self.entity:GetDisabled() then return end

        net.Start("FORTIFICATIONS_ARTILLERYBARRELUP")
            net.WriteEntity(self.entity)
        net.SendToServer()
    end

    self.rotationDOWN = self.rotationDock:Add("UI_DButton")
    self.rotationDOWN:SetText("DOWN")
    self.rotationDOWN:Dock(LEFT)
    self.rotationDOWN:SetWide(w * .06)
    self.rotationDOWN:SetContentAlignment(5)
    self.rotationDOWN.DoClick = function()
        if self.entity:GetDisabled() then return end

        net.Start("FORTIFICATIONS_ARTILLERYBARRELDOWN")
            net.WriteEntity(self.entity)
        net.SendToServer()
    end

    self.movementDock = self:Add("UI_DFrame")
    self.movementDock:Dock(RIGHT)
    self.movementDock:SetWide(w * .25)
    self.movementDock:SetTitle("MOVEMENT")

    self.movementPull = self.movementDock:Add("UI_DButton")
    self.movementPull:SetText("PULL")
    self.movementPull:Dock(LEFT)
    self.movementPull:SetWide(w * .12)
    self.movementPull:SetContentAlignment(5)
    self.movementPull.DoClick = function()
        if self.entity:GetDisabled() then return end

        net.Start("FORTIFICATIONS_ARTILLERYROTATEPULL")
            net.WriteEntity(self.entity)
        net.SendToServer()
    end

    self.movementPush = self.movementDock:Add("UI_DButton")
    self.movementPush:SetText("PUSH")
    self.movementPush:Dock(LEFT)
    self.movementPush:SetWide(w * .12)
    self.movementPush:SetContentAlignment(5)
    self.movementPush.DoClick = function()
        if self.entity:GetDisabled() then return end

        net.Start("FORTIFICATIONS_ARTILLERYROTATEPUSH")
            net.WriteEntity(self.entity)
        net.SendToServer()
    end

    self.fireB = self:Add("UI_DButton")
    self.fireB:Dock(FILL)
    self.fireB:SetContentAlignment(5)
    self.fireB:DockMargin(10, 20, 10, 10)
    self.fireB:SetWide(w * .25)
    self.fireB:SetText("FIRE")
    self.fireB.Think = function()
        if !IsValid(self.entity) then return end

        if !self.entity:GetReloading() then
            self.fireB:SetDisabled(false)
            self.fireB:SetText( self.entity:GetLoaded() and "FIRE" or "LOAD" )
        else
            self.fireB:SetText( "Reloading" )
            self.fireB:SetDisabled(true)
        end
    end
    self.fireB.DoClick = function()
        if self.entity:GetReloading() or self.entity:GetDisabled() then return end

        net.Start("FORTIFICATIONS_ARTILLERYSHOOT")
            net.WriteEntity(self.entity)
        net.SendToServer()
    end
end

function PANEL:OnRemove()
    net.Start("FORTIFICATIONS_ARTILLERYREMOVECONTROLLER")
        net.WriteEntity(self.entity)
    net.SendToServer()
end

function PANEL:Think()
    if self.entity and self.entity:GetDisabled() or self.entity:GetController() != LocalPlayer() then
        self:Remove()
    end
end


vgui.Register("ARTILLERY_CONTROLLER", PANEL, "UI_DFrame")

net.Receive("FORTIFICATIONS_ARTILLERYMENU", function()
    local artillery = net.ReadEntity()
    if IsValid(artillery) then
        vgui.Create("ARTILLERY_CONTROLLER").entity = artillery 
    end
end)

local PANEL = {}

function PANEL:Init()
    local w, h = ScrW() * .5, ScrH() * .8 

    self:SetSize( w, h )
    self:SetTitle("Fortifications")
    self:Center()
    self:MakePopup()

    local close = self:Add("UI_DButton")
    close:SetSize(w * .5, h * .05)
    close:SetPos(w * .5 - close:GetWide()/2, h * .9)
    close:SetText("CLOSE")
    close:SetContentAlignment(5)
    close.DoClick = function()
        self:Remove()
    end

    local scroller = self:Add("UI_DScrollPanel")
    scroller:SetSize(w, h * .8)
    scroller:SetPos(0, h * .01)

    for k, v in pairs(FORTIFICATIONS.Deployables) do
        local panel = scroller:Add("UI_DFrame")
        panel:SetTitle(k)
        panel:Dock(TOP)
        panel:DockMargin(w * .1,  h * .05, w * .1,  h * .05)
        panel:SetTall(h * .15)

        local amount = 0
        for _, item in pairs(LocalPlayer():getChar():getInv():getItems()) do
            if item.uniqueID == "fortification_material" then
                amount = amount + 1
            end
        end

        local infoText = panel:Add("UI_DLabel")
        infoText:SetText(v.desc .. "\nRequires: x" .. v.itemCost .. " Fortification Materials")
        infoText:SetPos(w * .01, h * .07)
        infoText:SetSize(w * .6, h * .05)

        local choose = panel:Add("UI_DButton")
        choose:SetText("BUILD")
        choose:Dock(RIGHT)
        choose:SetWide(w * .1)
        choose:SetContentAlignment(5)
        choose.DoClick = function()
            net.Start("FORTIFICATIONS_ARTILLERYBUILD")
                net.WriteString(k)
            net.SendToServer()
            self:Remove()
        end

        if amount < v.itemCost then
            local red = Color(255, 0, 0)
            panel.lblTitle:SetTextColor(red)
            choose:SetDisabled(true)
            infoText:SetTextColor(red)
        end
    end
end

vgui.Register("HAMMERMENU", PANEL, "UI_DFrame")

concommand.Add("hammermenu", function()
    vgui.Create("HAMMERMENU")
end)