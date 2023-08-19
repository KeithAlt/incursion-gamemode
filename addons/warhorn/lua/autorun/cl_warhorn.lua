if SERVER then return end

surface.CreateFont( "WARHORNFONT", {
	font = "Akbar",
	extended = true,
	size = ScreenScale(40),
	weight = 500,
} )

surface.CreateFont( "WARHORNFONT_BG", {
	font = "Akbar",
	extended = true,
	size = ScreenScale(45),
	weight = 500,
} )

local PANEL = {}
local drumSounds = 
{
    "warcry/drum1.ogg",
    "warcry/drum2.ogg",
    "warcry/drum3.ogg",
    "warcry/drum4.ogg",
    "warcry/drum5.ogg",
}
function PANEL:Init()
    WARHORN = self

    local x, y = ScrW(), ScrH()
    self:SetSize(x, y)

    timer.Create("WARHORN", 120, 1, function()
        self:AlphaTo(0, 2, 0, function()
            if IsValid(self) then
                self:Remove()
            end
        end)
    end)
end

function PANEL:OnRemove()
    timer.Remove("WARHORN")
end

function PANEL:Think()
    if not LocalPlayer():Alive() then
        self:Remove()
    end
end

local vig = Material("materials/nutscript/gui/vignette.png")
function PANEL:Paint(w, h)
    surface.SetDrawColor(175, 40, 40)
    surface.SetMaterial(vig)
    surface.DrawTexturedRect(0, 0, w, h)
    
    if timer.Exists("WARHORN") then
        local val = math.floor(timer.TimeLeft("WARHORN"))
        if val == -1 then return end
        draw.SimpleText(val, "WARHORNFONT", w * .5, h * .1, Color(179, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(val, "WARHORNFONT_BG", w * .5, h * .1, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

vgui.Register("WarhornUI", PANEL, "DPanel")
concommand.Add("WARHORNUIRESET", function()
    if IsValid(WARHORN) then
        WARHORN:Remove()
    end
end)
net.Receive("WARHORN_ShowUI", function()
    if IsValid(WARHORN) then
        WARHORN:Remove()
    end
    
    WARHORN = vgui.Create("WarhornUI")
end)