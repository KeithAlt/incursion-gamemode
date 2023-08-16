surface.CreateFont("WARFONT_SUPERTINY", {
    font = "Akbar",
    extended = false,
    size = 15,
    weight = 300,
    outline = true,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
})
surface.CreateFont("WARFONT_SMALL", {
    font = "Akbar",
    extended = false,
    size = ScreenScale(7.5),
    weight = 100,
    outline = true,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
})

surface.CreateFont("WARFONT_MEDIUM", {
    font = "Akbar",
    extended = false,
    size = ScreenScale(10),
    weight = 100,
    outline = true,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
})

surface.CreateFont("WARFONT_MASSIVE", {
    font = "Akbar",
    extended = false,
    size = ScreenScale(12.5),
    weight = 100,
    outline = true,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
})

local PANEL = {}
local typ

function PANEL:Init()
    if IsValid(WARDECLARATIONUI) then
        WARDECLARATIONUI:Remove()
    end

    self:SetAlpha(0)
    self:AlphaTo(255, 2, 0, function()
    end)
    WARDECLARATIONUI = self

    local w, h = ScrW(), ScrH()

    self.participants = {}
    self.factions = 0

    self:SetWide( w * .185 )
    self:SetTall( h )
    self:SetPos(w - (self:GetWide()))

    self:ShowCloseButton(false)
    self:SetTitle("")

    self.typetitle = self:Add("DLabel")
    self.typetitle:Dock(TOP)
    self.typetitle:SetText(string.upper( WARDECLARATION.Attacks.type or "RAID" ))
    self.typetitle:SetFont("WARFONT_MEDIUM")
    self.typetitle:SetContentAlignment(5)
    self.typetitle:SizeToContents()
    self.typetitle:SetTextColor(WARDECLARATION.BaseColor)
    
    self:CreateTimer(WARDECLARATION.Attacks.time)

    // container for all the new assisters
    timer.Simple(0, function()
        self.container = self:Add("DPanel")
        self.container:SetPos(0, self:GetTall() * .085)
        self.container:SetSize(self:GetWide(), self:GetTall() * .8)
        self.container.Paint = nil 
        self.container.Think = function()
            self.container:SetWide(self:GetWide())
        end
        
        self.announcer = self.container:Add("UI_DLabel")
        self.announcer:Dock(TOP)
        //self.announcer:SetText("A faction has joined the conflict")
        self.announcer:SetText("")
        self.announcer:SetFont("WARFONT_SMALL")
        self.announcer:SetContentAlignment(5)
        self.announcer:SetAutoStretchVertical(true)
        self.announcer:SetTextColor(WARDECLARATION.BaseColor)
        self.announcer:SetAlpha(0)

        
        typ = WARDECLARATION.Attacks.type
        if WARDECLARATION.Types[typ].soundeffect != nil then
            surface.PlaySound(WARDECLARATION.Types[typ].soundeffect)
        end

        
        timer.Simple(0.25, function()
            self:BuildItems()
        end)
    end)
end

function PANEL:BuildItems()
    local data = WARDECLARATION.Attacks
    if data == nil then return end
    
    data.participants = data.participants or {}

    for k, v in pairs(data.participants) do
        self:AddMainFaction(k)

        for fac, _ in pairs(data.participants[k]) do
            self:AddAssister(k, fac)
        end
    end
end

function PANEL:Paint()
end

function PANEL:OnRemove()
    if WARDECLARATION.Types[typ].attackendsound != nil then
        surface.PlaySound(WARDECLARATION.Types[typ].attackendsound)

        timer.Simple(1.5, function()
            local endNotice = {
                [0] = "The smell of ash & led drift through the air from a now concluded battle . . .",
                [1] = "The sounds of gunfire & explosions slowly come to an end . . .",
                [2] = "The cries of soldiers & the misfortunate fade into nothing . . .",
                [3] = "The echos of a violent battle fade into the heavy wasteland air . . .",
            }

            chat.AddText(Color(255, 150, 0), endNotice[math.random(0,3)])
        end)
    end

    WARDECLARATION.Attacks = {}
end

/*
    Displays assisting factions when tab menu is open, otherwise only main factions.
*/
function PANEL:Think()
    if not IsValid(nut.gui.scoreboard) and not self.tabbed then
        for k, v in pairs(self.participants) do
            if not IsValid(v) then continue end
            if v.main then continue end
            v:SetAlpha(0)
        end
    else
        for k, v in pairs(self.participants) do
            if not IsValid(v) then continue end
            v:SetAlpha(255)
        end
    end
end

/*
    Displays a text prompt under the raid timer, announcing entry or exit.
    @text : Text to display
*/
function PANEL:Announce(text)
    if self.factions == 3 then
        self.announcer:SetFont("WARFONT_MEDIUM")
        self.announcer:SizeToContents()
    else
        self.announcer:SetFont("WARFONT_SMALL")
        self.announcer:SizeToContents()
    end

    self.announcer:SetText(text)
    self.announcer:SetAlpha(0)
    self.announcer:AlphaTo(255, 1, 0, function()
        self.announcer:AlphaTo(0, 1, 1, function()
            self.announcer:SetText("")
        end)
    end)
end
/*
    Add a main container for a separate VS tab and add the icon.

    @faction : Faction to add
*/
function PANEL:AddMainFaction(faction)
    local vsthing

    local icon = FalloutScoreboard.GetFactionMaterial(nut.faction.indices[faction].uniqueID)
    if icon == nil then return end

    if self.factions > 0 then
        vsthing = self.container:Add("DLabel")
        vsthing:Dock(RIGHT)
        vsthing:SetWide(self:GetWide() * .1)
        vsthing:SetText("VS")
        vsthing:SetTextColor(Color(255, 255, 255, 200))
        vsthing:DockMargin(2, self.container:GetTall() * .01, 2, 0)
        vsthing:SetContentAlignment(8)
        vsthing:SetFont("WARFONT_MASSIVE")
        vsthing:SizeToContents()
    end
    self.factions = self.factions + 1

    if self.factions == 3 then
        self:SetWide( self:GetWide() + self:GetWide() * .5)
        self:SetPos(ScrW() - (self:GetWide()))
        self:Announce( nut.faction.indices[faction].name .. " has joined the battle.")
    end

    local main = self.container:Add("DPanel")
    main:Dock(RIGHT)
    main:SetWide(self.container:GetWide() * .45)
    main.Paint = nil
    main.main = true
    if vsthing != nil then
        function main:OnRemove()
            if IsValid(vsthing) then
                vsthing:Remove()
            end 
        end
    end

    local mainIcon = main:Add("DPanel")
    mainIcon:Dock(TOP)
    mainIcon:SetTall( self:GetTall() * .05)
    mainIcon:DockMargin(0, 0, 0, 5)
    mainIcon.Paint = function(s, wi, hi)
        if icon != nil then
            surface.SetDrawColor(255, 255, 255, 255)
            if isstring(icon) then
                surface.SetMaterial(Material(icon))
            else
                surface.SetMaterial(icon)
            end
            
            surface.DrawTexturedRect(wi * .5 - 32, hi * .5 - 32, 64, 64)
            
            draw.SimpleText("[", "WARFONT_MASSIVE", wi * .15, hi * .5, WARDECLARATION.BaseColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("]", "WARFONT_MASSIVE", wi - (wi * .15), hi * .5, WARDECLARATION.BaseColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    self.participants[faction] = main
end

/*
    Removes a faction, assister or main faction from the UI.
    @faction : Faction id to remove.
*/
function PANEL:RemoveFaction(faction)
    if not self.participants[faction] then return end

    local panel = self.participants[faction]

    if panel.main then
        for k, v in pairs(panel:GetChildren()) do
            if v.id == nil then continue end

            if self.participants[v.id] != nil then
                self.participants[v.id] = nil
                v:Remove()
            end
        end
    end

    panel:Remove()
    self.participants[faction] = nil
end

/*
    @main : main faction to assist
    @faction : faction to assist main
*/
function PANEL:AddAssister(main, faction)
    local w, h = ScrW(), ScrH()

    local panelparent = self.participants[main]
    if not IsValid(panelparent) or not panelparent.main then return end

    local icon = FalloutScoreboard.GetFactionMaterial(nut.faction.indices[faction].uniqueID)

    local assister = panelparent:Add("DPanel")
    assister:Dock(TOP)
    assister:SetTall( self:GetTall() * .05 )
    assister:DockMargin(0, 0, 0, 5)
    assister.Paint = function(s, wi, hi)
        if icon != nil then
            surface.SetDrawColor(255, 255, 255, 255)
            if isstring(icon) then
                surface.SetMaterial(Material(icon))
            else
                surface.SetMaterial(icon)
            end
            
            
            surface.DrawTexturedRect(wi * .5 - 32, hi * .5 - 32, 64, 64)
            
            draw.SimpleText("[", "WARFONT_MASSIVE", wi * .15, hi * .5, WARDECLARATION.BaseColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("]", "WARFONT_MASSIVE", wi - (wi * .15), hi * .5, WARDECLARATION.BaseColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    assister.id = faction

    self.participants[faction] = assister

    local facname = nut.faction.indices[faction].name
    self:Announce( facname .. " has joined the " .. (WARDECLARATION.Attacks.typ or "raid") .. " . . .")
end

function PANEL:RemoveAssister(faction)

    if self.participants[faction] == nil or not IsValid(self.participants[faction]) then return end
    
    if self.participants[faction].main then
        self:SetWide(ScrW() * .185)
        self:SetPos(ScrW() - (self:GetWide()))
        self.factions = self.factions - 1
    end

    self.participants[faction]:Remove()
    self.participants[faction] = nil

    self:Announce(nut.faction.indices[faction].name .. " has left the " .. (WARDECLARATION.Attacks.typ or "raid") .. " . . .")
end

function PANEL:CreateTimer(time)
    self.timebox = self:Add("Panel")
    self.timebox:SetSize(self:GetWide() * .5, 25)
    self.timebox:SetPos(self:GetWide() * .5 - (self.timebox:GetWide() / 2), self:GetTall() * .055)
    self.timebox.Think = function()
        self.timebox:SetSize(self:GetWide() * .5, 25)
        self.timebox:SetPos(self:GetWide() * .5 - (self.timebox:GetWide() / 2), self:GetTall() * .055)
    end
    self.timebox.Paint = function(self, w, h)
        surface.SetDrawColor(Color(255, 255, 255, 136))
        surface.DrawOutlinedRect(0, 0, w, h, 4)
    end

    self.bar = self.timebox:Add("DProgress")
    self.bar:Dock(FILL)
    self.bar:SetFraction(1)
    self.bar.CurrentTime = time
    self.bar.NextThink = CurTime()
    self.bar.Paint = function(self, w, h)
        surface.SetDrawColor(WARDECLARATION.BaseColor)
        surface.DrawRect(5, 6, (w * self:GetFraction()) - 10, h - 12)
    end

    self.barLabel = self.bar:Add("UI_DLabel")
    self.barLabel:SetContentAlignment(8)
    self.barLabel:Dock(FILL)
    self.barLabel:SetText(self.bar.CurrentTime)
    self.barLabel:SetFont("WARFONT_TINY")
    self.barLabel:SetTextColor(Color(255, 255, 255, 136))

    self.bar.Think = function()
        if self.bar.NextThink <= CurTime() then
            self.bar.CurrentTime = self.bar.CurrentTime - 1
            self.bar:SetFraction( self.bar.CurrentTime / time )
            self.barLabel:SetText(self.bar.CurrentTime)
            self.bar.NextThink = CurTime() + 1
            if self.bar.CurrentTime <= -2 then
                self:Remove()
            end
        end
    end

    return self.timebox
end

function PANEL:SetTime(time)
    self.bar.CurrentTime = time
end

vgui.Register("WARUI", PANEL, "DFrame")

local PANEL = {}

function PANEL:Init()
    REASONUI = self

    self:SetSize(ScrW() * .5, ScrH() - 10)
    self:Center()
    self:ShowCloseButton(false)
    self:MakePopup()

    self:SetTitle("War Reason Activator")

    net.Start("WARDECLARATION_REQUESTREASONS")
    net.SendToServer()

    self.information = self:Add("UI_DLabel")
    self.information:SetText("Here is a list of all your available war reasons. \nPressing 'ACTIVATE' will instantly approve your war request against the faction. \n> Ensure they are online and you can war them before activating, if you are unsure, contact staff.")
    self.information:Dock(TOP)
    self.information:SetWrap(true)
    self.information:SetTall(ScrH() * .07)
    self.close = self:Add("UI_DButton")
    self.close:SetText("Close")
    self.close:Dock(BOTTOM)
    self.close:SetContentAlignment(5)
    self.close:SetTall(ScrH() * .05)
    self.close.DoClick = function()    
        self:Remove()
    end

    self.scroller = self:Add("UI_DScrollPanel")
    self.scroller:Dock(FILL)

    self.OriginalPaintM = self.Paint
end

local og = baseclass.Get( "UI_DFrame" )
function PANEL:Paint(w, h)

    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(0, h * .025, w, h - h * .025)

    og.Paint(self, w, h)
end

function PANEL:Build(data)
    for facID, _ in pairs(data) do

        local increase = 0
        local faction = self.scroller:Add("UI_DFrame")
        faction:Dock(TOP)
        faction:SetTall(ScrH() * .05)
        faction:DockMargin(0, 0, ScrW() * .01, 5)
        faction:SetTitle(nut.faction.indices[facID].name)

        local scroll = faction:Add("UI_DScrollPanel")
        scroll:Dock(FILL)

        for i=1, #data[facID] do 
            if data[facID][i] == nil then continue end
            faction:SetTall( faction:GetTall() + ScrH() * .06)

            local p = scroll:Add("UI_DPanel")
            p:Dock(TOP)
            p:DockMargin(2, 2, 2, 2)
            p:SetTall(ScrH() * .05)
            

            local reasonText = p:Add("UI_DLabel")
            reasonText:Dock(LEFT)
            reasonText:SetText(data[facID][i])
            reasonText:DockMargin(5, 5, 5, 5)
            reasonText:SizeToContents()

            local useButton = p:Add("UI_DButton")
            useButton:Dock(RIGHT)
            useButton:SetText("ACTIVATE")
            useButton:SetContentAlignment(5)
            useButton:SizeToContents()
            useButton.DoClick = function()
                if LocalPlayer().warReady then
                    vgui.Create("nutFalloutNotice"):open("[WAR] You have already activated a war reason.", "ui/ui_hacking_bad.mp3")
                    return 
                end

                net.Start("WARDECLARATION_ACTIVATEWARREASON")
                    net.WriteInt(facID, 8)
                    net.WriteInt(i, 6)
                net.SendToServer()

                LocalPlayer().warReady = true

                p:Remove()
                data[facID][i] = nil

                if #data[facID] == 0 then
                    faction:Remove()
                end
            end
        end
    end
end
vgui.Register("WARReasonActivator", PANEL, "UI_DFrame")

net.Receive("WARDECLARATION_REQUESTREASONS", function()
    local data = jlib.ReadCompressedTable()

    timer.Simple(0, function()
        REASONUI:Build(data)
    end)
end)