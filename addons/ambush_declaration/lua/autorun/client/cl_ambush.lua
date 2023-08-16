-- Icon info
local DEAD_ICON = surface.GetTextureID("forp/ui/icon_ninja")
local DEAD_ICON_WIDTH = 152
local DEAD_ICON_HEIGHT = 152

-- Font info
surface.CreateFont("foAmbushFont", {
	font = "Akbar",
	size = 40,
	weight = 650,
	antialias = true,
	additive = true
})

-- HUD draw info
local owner, w, h, ceil, ft, clmp
ceil = math.ceil
clmp = math.Clamp
local aprg, aprg2 = 0, 0

-- Draw on HUD
local function DrawHUD()
	owner = LocalPlayer()
	ft = FrameTime()
	w, h = ScrW(), ScrH()

	aprg = clmp(aprg + ft * .5, 0, 1)
	aprg2 = clmp(aprg2 + ft * .4, 0, 1)

	local text = "Ambush Active"

	surface.SetDrawColor(0, 0, 0, ceil((aprg^.5) * 255))

	surface.SetTextColor(255, 178, 0, aprg2 * 255)
	surface.SetFont("foAmbushFont")
	local textW, textH = surface.GetTextSize(text)
	surface.SetTextPos(ScrW() / 1.17 - textW / 2, ScrH() / 11 + (textH  + DEAD_ICON_HEIGHT) / -15)
	surface.DrawText(text)

	surface.SetDrawColor(Color(255, 199, 44, aprg2 * 255))
	surface.SetTexture(DEAD_ICON)
	surface.DrawTexturedRect(ScrW() / 1.05 - DEAD_ICON_WIDTH / 2, ScrH() / 8 - (textH - 52 + DEAD_ICON_HEIGHT) / 2 - 30, DEAD_ICON_WIDTH, DEAD_ICON_HEIGHT)
end

-- Play sound effects
local function playSFX(bool)
	if bool then
		surface.PlaySound("vat_kill.mp3")
		return
	else
		surface.PlaySound("vat_exit.mp3")
	end
end

-- Play ambient battle sound effects
local function playBattleSFX()
	sound.Play("ambient/levels/streetwar/city_battle" .. math.random(1,10) .. ".wav", LocalPlayer():GetPos() + Vector(500,500,500), 75, 100, 1)
end

-- Setter to draw HUD
local function setDrawHUD(bool)
	LocalPlayer().DrawAmbushHUD = bool or false
	playSFX(bool or false)
end

-- Getter if HUD is being drawn
local function getDrawHUD()
	local bool = LocalPlayer().DrawAmbushHUD or false
	return bool
end

-- Ambush net message
net.Receive("AmbushDrawHUD", function()
	local bool = net.ReadBool() or false
	setDrawHUD(bool)
end)

-- Ambush notification messages
local ambushNotice = {
	[0] = "Distant gunfire can be heard . . .",
	[1] = "Sounds of war chime in the wind . . .",
	[2] = "Whizzing bullets & blasts echo in the air . . .",
	[3] = "Sounds of an on-going battle linger in the air . . .",
	[4] = "A firefight can be heard in the distance . . .",
	[5] = "Gunshots & explosions ring across the wasteland . . .",
	[6] = "Sounds of war echo in the air . . .",
}

-- Ambush ambient battle sound effects
net.Receive("AmbushPlayAmbience", function()

	for i = 3, 1, -1 do
		timer.Simple(i * 1.2, function()
			playBattleSFX()
		end)
	end

	chat.AddText(Color(255, 150, 0), ambushNotice[math.random(0,6)])
end)

-- Hook for hudpaint
hook.Add("HUDPaint", "HUDPaint_Ambush", function()
	if LocalPlayer().DrawAmbushHUD == true then
		DrawHUD()
	end
end)
