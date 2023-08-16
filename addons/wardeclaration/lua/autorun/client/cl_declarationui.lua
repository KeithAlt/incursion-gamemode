AddCSLuaFile()

surface.CreateFont("WARFONT", {
    font = "Akbar",
    extended = false,
    size = 25,
    weight = 900,
    outline = false,
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

surface.CreateFont("WARFONT_TINY", {
    font = "Akbar",
    extended = false,
    size = 22,
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

surface.CreateFont("WARFONT_MASSIVE", {
    font = "Akbar",
    extended = false,
    size = 60,
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

-- Called via timer due to 'nut' not being initalized till later
timer.Simple(0, function()
	WARDECLARATION.BaseColor = nut.config.get("color")
end)

PANEL = {}
local typ

function PANEL:Init()
    local x, y = ScrW(), ScrH()
    local alliestable = {}
    local enemytable = {}

    self:SetSize(x * .3, y - 100)
    self:SetPos(x * .7)
    typ = WARDECLARATION.Attacks.type
    if WARDECLARATION.Types[typ].soundeffect != nil then
        surface.PlaySound(WARDECLARATION.Types[typ].soundeffect)
    end

    WARDECLARATIONUI = self

    self.allies = self:Add("DPanel")
    self.allies:Dock(LEFT)
    self.allies:SetWide(x * .10)
    self.allies:DockMargin(20, 0, 0, 0)
    self.allies.Paint = function() end
    self.alliesTitle = self.allies:Add("UI_DLabel")
    self.alliesTitle:SetText("ATTACKERS")
    self.alliesTitle:SetTextColor(WARDECLARATION.BaseColor)
    self.alliesTitle:SetContentAlignment(8)
    self.alliesTitle:SetAutoStretchVertical(true)
    self.alliesTitle:SetFont("WARFONT")
    self.alliesTitle:Dock(TOP)
    self.alliesTitle:DockMargin(0, 5, 0, 0)

    self.enemies = self:Add("DPanel")
    self.enemies:Dock(RIGHT)
    self.enemies:SetWide(x * .10)
    self.enemies:DockMargin(0, 0, 20, 0)
    self.enemies.Paint = function() end
    self.enemiesTitle = self.enemies:Add("UI_DLabel")
    self.enemiesTitle:SetContentAlignment(8)
    self.enemiesTitle:SetText("DEFENDERS")
    self.enemiesTitle:SetFont("WARFONT")
    self.enemiesTitle:SetAutoStretchVertical(true)
    self.enemiesTitle:Dock(TOP)
    self.enemiesTitle:DockMargin(0, 5, 0, 0)
    self.enemiesTitle:SetTextColor(WARDECLARATION.BaseColor)

    self.timeContainer = self:Add("DPanel")
    self.timeContainer:Dock(FILL)
    self.timeContainer.Paint = function() end

    self.titleLabel = self.timeContainer:Add("UI_DLabel")
    self.titleLabel:Dock(TOP)
    self.titleLabel:SetContentAlignment(8)
    self.titleLabel:DockMargin(0, 30, 0, 0)
    self.titleLabel:SetText(string.upper( WARDECLARATION.Attacks.type ))
    self.titleLabel:SetTextColor(WARDECLARATION.BaseColor)
    self.titleLabel:SetAutoStretchVertical(true)
    self.titleLabel:SetFont("WARFONT")

    self.announcecontainer = self:Add("Panel")
    self.announcecontainer:SetPos(0, self.allies:GetTall() * 14)
    self.announcecontainer:SetSize(self:GetWide(), self:GetTall() * .1)

    self.announcer = self.announcecontainer:Add("UI_DLabel")
    self.announcer:Dock(FILL)
    self.announcer:SetFont("WARFONT")
    //self.announcer:SetText("A faction has joined the conflict")
    self.announcer:SetText("A " ..  WARDECLARATION.Attacks.type .. " has started in the wasteland . . .")
    self.announcer:SetContentAlignment(8)
    self.announcer:SetAutoStretchVertical(true)
    self.announcer:SetTextColor(WARDECLARATION.BaseColor)
    self.announcer:SetAlpha(255)

    if WARDECLARATION.Attacks.calling == nil then self:Remove() return end

    table.insert(alliestable, WARDECLARATION.Attacks.calling)
    for k, v in ipairs(WARDECLARATION.Attacks.assisters) do
        table.insert(alliestable, v)
    end

    table.insert(enemytable, WARDECLARATION.Attacks.enemy)
    for k, v in ipairs(WARDECLARATION.Attacks.enemies) do
        table.insert(enemytable, v)
    end

    self:BuildItems("Allies", alliestable)
    self:BuildItems("Enemies", enemytable)

    self.imageContainer = {
        Defenders = {},
        Attackers = {},
    }

    self:CreateTimer(WARDECLARATION.Attacks.time)

    if WARDECLARATION.Types[WARDECLARATION.Attacks.type].soundeffect != nil then
        surface.PlaySound(WARDECLARATION.Types[WARDECLARATION.Attacks.type].soundeffect) -- Play the sound effect
    end

    -- Fade in then out
    self:SetAlpha(0)
    self:AlphaTo(255, 2, 0, function()
        self.Showcase = true
        self.announcer:AlphaTo(0, 2, 1)
    end)
end

function PANEL:Announce(txt)
    if not IsValid(self.announcer) then return end
    local ann = self.announcer

    ann:SetText(txt)
    surface.PlaySound("wardeclaration/AnnounceSound.mp3")
    ann:AlphaTo(255, 2, 0, function()
        ann:AlphaTo(0, 2, 2, function() end)
    end)
end

function PANEL:Paint()
    return
end

function PANEL:AddAssister(side, icon)
    local item
    if side == "Allies" then
        item = self.allies:Add( "DPanel" )
    elseif side == "Enemies" then
        item = self.enemies:Add( "DPanel" )
    end

    item:Dock( TOP )
    item:DockMargin( 0, 5, 0, 0 )
    item:SetTall( self:GetTall( ) * .08 )
    item.Paint = function(self, w, h) end

    local x, y = item:GetWide(), item:GetWide()
    local imagecontainer = item:Add("DPanel")
    imagecontainer:Dock(FILL)
    imagecontainer.Paint = function(self, w, h)
		if(icon) then
			surface.SetDrawColor(Color(255, 255, 255))
			surface.SetMaterial(icon)
			surface.DrawTexturedRect(w * .1, w * .05, w * .8, h * .8)
		end
    end

    local leftbracket = item:Add("Panel")
    leftbracket:Dock(LEFT)
    leftbracket:SetWide(45)
    leftbracket.Paint = function(self, w, h)
        draw.SimpleText( "[", "WARFONT_MASSIVE", w * .65, h * .48, WARDECLARATION.BaseColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    local rightbracket = item:Add("Panel")
    rightbracket:Dock(RIGHT)
    rightbracket:SetWide(45)
    rightbracket.Paint = function(self, w, h)
        draw.SimpleText( "]", "WARFONT_MASSIVE", w * .35, h * .48, WARDECLARATION.BaseColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    if side == "Allies" then
        table.insert(self.imageContainer.Attackers, {image = icon, panel = item})
    else
        table.insert(self.imageContainer.Defenders, {image = icon, panel = item})
    end

	surface.PlaySound("vat_engage.mp3 ")

    self:Announce("A faction has joined the conflict . . .")
    --item:SetAlpha(0)
    --    self.announcer:AlphaTo(255, 2, 0, function()
    --        self.announcer:AlphaTo(0, 1, 2, function()
    --        end)
    --    end)
end

-- We loop through both sides and remove the one that matches the icon as there can only be one of each, right?
function PANEL:RemoveAssister(icon)
    local panel
    for k, v in ipairs(self.imageContainer.Attackers) do
        if v.image == icon then
            v.panel:Remove()
        end
    end

    for k, v in ipairs(self.imageContainer.Defenders) do
        if v.image == icon then
            v.panel:Remove()
        end
    end

    self:Announce("A faction has left the conflict . . .")

    //        v:Remove()
    //        self:Announce("A faction has stopped assisting the attackers.")
    //for k, v in ipairs(self.enemies:GetChildren()) do
    //    if v:GetClassName() == "Label" then continue end
    //    panel = v:GetChildren()[3] -- It will always be the third entry.
    //    if panel.Image == icon then
    //        v:Remove()
    //        self:Announce("A faction has stopped assisting the defenders.")
    //    end
    //end
end


function PANEL:Think()
    if WARDECLARATION.Attacks.calling == nil and not self.Fadingout then
        self:Remove()
    end
    if IsValid(nut.gui.scoreboard) then
        for k, v in ipairs(self.allies:GetChildren()) do
            v:SetAlpha(255)
        end

        for k, v in ipairs(self.enemies:GetChildren()) do
            v:SetAlpha(255)
        end
    else
        if self.Showcase then
            for k, v in ipairs(self.allies:GetChildren()) do
                if k == 1 or k == 2 then -- Enemies label and first entry
                    v:SetAlpha(255)
                else
                    v:SetAlpha(0)
                end
            end

            for k, v in ipairs(self.enemies:GetChildren()) do
                if k == 1 or k == 2 then -- Enemies label and first entry
                    v:SetAlpha(255)
                else
                    v:SetAlpha(0)
                end
            end
        end
    end
end

-- ITEMS ARE FACTION IDS TO REFERENCE
function PANEL:BuildItems( side, items, additive)
    for _, v in ipairs( items ) do
        local item

        if side == "Allies" then
            item = self.allies:Add( "DPanel" )
        elseif side == "Enemies" then
            item = self.enemies:Add( "DPanel" )
        end

        item:Dock( TOP )
        item:DockMargin( item:GetWide() * .4, 5, item:GetWide() * .4, 0 )
        item:SetTall( 80 )
        item.Paint = function(self, w, h) end

        local uuid = nut.faction.indices[v].uniqueID
        local imagecontainer = item:Add("DPanel")
        imagecontainer:Dock(FILL)
        imagecontainer.Paint = function(self, w, h)
			local material = FalloutScoreboard.GetFactionMaterial(uuid) or false

			if not material then return end

            surface.SetDrawColor(Color(255, 255, 255))
            surface.SetMaterial(material)
            surface.DrawTexturedRect(w * .1, w * .05, w * .8, h * .8)
        end
        --imagecontainer:DockMargin(10, 10, 10, 10)
        --imagecontainer:SetMaterial(FalloutScoreboard.GetFactionMaterial(uuid))

        local leftbracket = item:Add("Panel")
        leftbracket:Dock(LEFT)
        leftbracket:SetWide(10)
        leftbracket.Paint = function(self, w, h)
            draw.SimpleText( "[", "WARFONT_MASSIVE", w * .65, h * .48, WARDECLARATION.BaseColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end

        local rightbracket = item:Add("Panel")
        rightbracket:Dock(RIGHT)
        rightbracket:SetWide(10)
        rightbracket.Paint = function(self, w, h)
            draw.SimpleText( "]", "WARFONT_MASSIVE", w * .35, h * .48, WARDECLARATION.BaseColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
    end
end

function PANEL:CreateTimer(time)
    self.timebox = self.timeContainer:Add("Panel")
    self.timebox:Dock(TOP)
    self.timebox.Paint = function(self, w, h)
        surface.SetDrawColor(Color(255, 255, 255, 136))
        surface.DrawOutlinedRect(0, 0, w, h, 4)
    end

    self.bar = self.timebox:Add("DProgress")
    self.bar:Dock(FILL)
    self.bar:SetFraction(1)
    self.bar.CurrentTime = time
    self.bar:SetWide(190 * (time / self.bar.CurrentTime )) -- change this to scale properly
    self.bar.NextThink = CurTime()
    self.bar.Paint = function(self, w, h)
        surface.SetDrawColor(WARDECLARATION.BaseColor)
        surface.DrawRect(5, 6, w * (self.CurrentTime / time ) - 10, h - 12)
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
            self.bar:SetFraction(self.bar.CurrentTime / time )
            self.barLabel:SetText(self.bar.CurrentTime)

            self.bar.NextThink = CurTime() + 1

            if self.bar.CurrentTime <= -2 then
                self:Remove()
            end
        end
    end
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
end

function PANEL:SetTime(time)
    self.bar.CurrentTime = time
end

vgui.Register("WARDECLARATION_ATTACK", PANEL, "DPanel")
