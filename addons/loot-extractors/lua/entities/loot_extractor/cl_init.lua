include("shared.lua")

surface.CreateFont("extractor3D2D", {font = "Arial", size = 52})
local function ShadowText(text, font, x, y, colortext, colorshadow, dist, xalign, yalign)
    draw.SimpleText(text, font, x + dist, y + dist, colorshadow, xalign, yalign)
    draw.SimpleText(text, font, x, y, colortext, xalign, yalign)
end

local function QuickShadow(text, x, y, alpha)
    local c = nut.gui.palette.color_primary
    ShadowText(text, "extractor3D2D", x, y, Color(c.r, c.g, c.b, alpha), Color(0, 0, 0, alpha), 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function ENT:Initialize()
    self.alpha = 0
end

function ENT:Draw()
    self:DrawModel()

    local ply = LocalPlayer()
    if ply:GetPos():DistToSqr(self:GetPos()) > 500*500 then return end

    if ply:GetEyeTrace().Entity == self then
        self.alpha = math.Clamp(self.alpha + 2, 0, 255)
    else
        self.alpha = math.Clamp(self.alpha - 2, 0, 255)
    end

    if self.alpha <= 0 then return end

    local owner = self:GetOwnership()

    local eyeAng = EyeAngles()
    eyeAng.p = 0
    eyeAng.y = eyeAng.y - 90
    eyeAng.r = 90

    cam.Start3D2D(self:GetPos() + Vector(0, 0, 75), eyeAng, 0.05)
        QuickShadow("Extractor", 0, -45, self.alpha)
        if owner == ply then
            QuickShadow("Currently Producing: " .. self:GetProduction(), 0, 0, self.alpha)
            QuickShadow("Use to open menu", 0, 45, self.alpha)
        elseif IsValid(owner) then
            QuickShadow("Owned By: " .. owner:Nick(), 0, 0, self.alpha)
            QuickShadow("Use to begin claiming", 0, 45, self.alpha)
        else
            QuickShadow("No Owner", 0, 0, self.alpha)
            QuickShadow("Use to claim", 0, 45, self.alpha)
        end
    cam.End3D2D()
end