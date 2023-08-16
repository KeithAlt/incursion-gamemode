-- Function Cache
local color = Color
local draw_roundedbox = draw.RoundedBox
local draw_simpletext = draw.SimpleText
local draw_notexture = draw.NoTexture
local surface_setdrawcolor = surface.SetDrawColor
-- Color cache
local inputBlack = color(100, 100, 100)
local mainBlue = color(50, 125, 255)

-- Text Entry
local PANEL = {}
function PANEL:Init()
	self:DockMargin(5, 5, 5, 5)
	self:SetFont("NoSay.Textbox.Static")
	self:SetText("")
	self:SetDisplayText("Search")
end

function PANEL:SetDisplayText(text)
	self.placeholder = text
end

function PANEL:Paint(w, h)
	draw_roundedbox(3, 0, 0, w, h, mainBlue)
	draw_roundedbox(3, 1, 1, w - 2, h - 2, color_white)

	self:DrawTextEntryText(color_black, mainBlue, mainBlue)

	if(self:GetText() == "") and not self:HasFocus() then
		draw_simpletext(self.placeholder, "NoSay.Textbox.Static", 5, h/2, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
end
vgui.Register('NSEntry', PANEL, 'DTextEntry')

-- Switch
-- Created by Livaco, edited by Owain.
local PANEL = {}
function PANEL:Init()
	self:SetText("")
	self.toggle = true

	self.lerp = 0.2
end
function PANEL:DoClick()
	self:Toggle()
end
function PANEL:Toggle()
	self:SetToggle(not self:GetToggle())
end
function PANEL:GetToggle()
	return self.toggle
end
function PANEL:SetToggle(value)
	self.toggle = value
end
function PANEL:Paint(w, h)
	draw_roundedbox(3, w*0.05, h*0.3, w*0.9, h*0.4, inputBlack)

	if self:GetToggle() then
		self.lerp = Lerp(0.1, self.lerp, 0.8)
	else
		self.lerp = Lerp(0.1, self.lerp, 0.2)
	end

	draw_notexture()
	surface_setdrawcolor(200-(200*self.lerp), 0+(200*self.lerp), 0, 255)
	noSayBlacklist.UI.DrawCircle(w*self.lerp, h*0.5, h*0.4, 1)
end
vgui.Register('NSSwitch', PANEL, 'DButton')


-- Circle Function
-- Created by Ben.
local sinCache = {}
local cosCache = {}
for i = 0, 360 do
	sinCache[i] = math.sin(math.rad(i))
	cosCache[i] = math.cos(math.rad(i))
end
function noSayBlacklist.UI.DrawCircle(x, y, r, step)
    local positions = {}

    for i = 0, 360, step do
        table.insert(positions, {
            x = x + cosCache[i] * r,
            y = y + sinCache[i] * r
        })
    end

    return surface.DrawPoly(positions)
end