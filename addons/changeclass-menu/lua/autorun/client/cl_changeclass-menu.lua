---------------------
--[[ MENU BUTTON ]]--
---------------------
local BUTTON = {}
BUTTON.Base = "DButton"

function BUTTON:Init()
    self:SetTextColor(nut.gui.palette.text_primary)
    self:SetExpensiveShadow(1, Color(0, 0, 0))
    self:SetContentAlignment(4)
    self:SetFont("UI_Bold")
    self:SetHeight(32)
end;

function BUTTON:Paint(w, h)
    if (self:GetPaintBackground()) then
        if (((self:IsHovered() or self:IsDown()) and !self:GetDisabled()) or self.active) then
            surface.SetDrawColor(Color(0, 0, 0))
            DisableClipping(true)
            surface.DrawRect(1, 1, w, h)
            DisableClipping(false)

            if (self.active) then
                surface.SetDrawColor(nut.gui.palette.color_primary)
            else
                surface.SetDrawColor(nut.gui.palette.color_primary)
            end;

            surface.DrawRect(0, 0, w, h)
        end;
    end;
end;

function BUTTON:OnMousePressed()
    if (!self:GetDisabled() and !self.active) then
        self:DoClick()
        surface.PlaySound("fallout/ui/ui_select.wav")
    end;
end;

function BUTTON:OnCursorEntered()
    if (!self:GetDisabled() and !self.active) then
        self:SetTextColor(nut.gui.palette.text_hover)
        self:SetExpensiveShadow(0, Color(0, 0, 0))
        surface.PlaySound("fallout/ui/ui_focus.wav")
    end;
end;

function BUTTON:OnCursorExited()
    if (!self:GetDisabled() and !self.active) then
        self:SetTextColor(nut.gui.palette.text_primary)
        self:SetExpensiveShadow(1, Color(0, 0, 0))
    end;
end;

function BUTTON:SetDisabled(bDisabled)
    self.m_bDisabled = bDisabled
    self:InvalidateLayout()

    if (bDisabled) then
        self:SetTextColor(nut.gui.palette.text_disabled)
        self:SetExpensiveShadow(1, Color(0, 0, 0))
    else
        self:SetTextColor(nut.gui.palette.text_primary)
    end;
end;

function BUTTON:SetEnabled(bEnabled)
    self:SetDisabled(!bEnabled)
end;

function BUTTON:SetActive(bool)
    if (bool) then
        self.active = true
        self:SetTextColor(nut.gui.palette.text_hover)
    else
        self.active = false
        self:SetTextColor(nut.gui.palette.text_primary)
    end;
end;


----------------------------
--[[ CHANGE CLASS PANEL ]]--
----------------------------
local PANEL = {}

function PANEL:Init()
    -- Panel setup
    self:SetTitle("CHANGE CLASS")
    self:SetSize(607, 465)
    self:MakePopup()
    self:Center()

    -- Display class buttons
    self.scroll = self:Add("UI_DScrollPanel")
	self.scroll:Dock(FILL)

    self:BuildClasses()

    -- Bottom buttons
    self.confirm = self:Add(BUTTON)
    self.confirm:SetText("Confirm")
    self.confirm:SetContentAlignment( 5 )
    self.confirm:SetTall(30)
    self.confirm:SizeToContentsX()
    self.confirm:SetWide(self.confirm:GetWide() + 20)
    self.confirm:CenterHorizontal()
    self.confirm:AlignBottom(10)
    self.confirm:SetX(self.confirm:GetX() - 75)
    self.confirm:SetDisabled(true)
    self.confirm.DoClick = function(pnl)
        netstream.Start("ns_changeclass_menu_confirm", self.selectedClass)
        self:Remove()
    end

    self.close = self:Add(BUTTON)
    self.close:SetText("Cancel")
    self.close:SetContentAlignment( 5 )
    self.close:SetTall(30)
    self.close:SizeToContentsX()
    self.close:SetWide(self.close:GetWide() + 20)
    self.close:CenterHorizontal()
    self.close:AlignBottom(10)
    self.close:SetX(self.close:GetX() + 75)
    self.close.DoClick = function(pnl)
        self:Remove()
    end
end

function PANEL:BuildClasses()
    local localPlayerFaction = LocalPlayer():getChar():getFaction()
    local localPlayerClass = LocalPlayer():getChar():getClass()

    self.scroll.classButtons = {}
    local classButtons = self.scroll.classButtons

    for i, class in ipairs(nut.class.list) do
        if ( localPlayerClass != i && !nut.class.canBe(LocalPlayer(), i) ) then
            continue
        end

        classButtons[i] = self.scroll:Add(BUTTON)
        classButtons[i]:SetContentAlignment(8)
        classButtons[i]:Dock(TOP)
        classButtons[i].DoClick = function()
            classButtons[i]:SetActive(true)
            self.confirm:SetDisabled(false)
            self.selectedClass = i

            for k, v in pairs(classButtons) do
                if (k != i && k != localPlayerClass) then
                    v:SetActive(false)
                end
            end
        end

        if ( localPlayerClass == i ) then
            classButtons[i]:SetDisabled(true)
            classButtons[i]:SetText(class.name.." (Current)")
        else
            classButtons[i]:SetText(class.name)
        end
    end
end

vgui.Register("ns_changleclass_menu", PANEL, "UI_DFrame")