local PLUGIN = PLUGIN
local PANEL = {}

surface.CreateFont("forpMotd",{
	font = "condensed_bold",
	size = 28,
	antialias = true,
	weight = 600,
})

function PANEL:Init()
    self:SetTitle(PLUGIN.boxTitle or "MOTD")
    self:SetText(PLUGIN.boxText or "")
    self:SetSize(607, 465)
    self:MakePopup()
    self:Center()

    self.close = self:Add("UI_DButton")
    self.close:SetText("Close")
    self.close:SetContentAlignment( 5 )
    self.close:SetSize(150, 30)
    self.close:CenterHorizontal()
    self.close:AlignBottom(10)
    self.close.DoClick = function(pnl)
        self:Remove()
    end
end

function PANEL:SetText(text)
    self.boxText = text

    surface.SetFont("forpMotd")
    local width, height = surface.GetTextSize( text )
    self.textWidth = width
    self.textHeight = height
end

function PANEL:PaintOver(w, h)
    draw.DrawText( self.boxText, "forpMotd", w/2, h/2 - self.textHeight/2, nut.gui.palette.text_primary, TEXT_ALIGN_CENTER )
end

vgui.Register("forpNotificationBox", PANEL, "UI_DFrame")