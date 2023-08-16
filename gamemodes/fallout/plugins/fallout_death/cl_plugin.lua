local PLUGIN = PLUGIN
PLUGIN.deathHookCalled = PLUGIN.deathHookCalled

local function onDeath()
	surface.PlaySound("fallout/death/death_" .. math.random(1,3) .. ".wav")
end

-- Deathscreen
local DEAD_ICON = surface.GetTextureID("forp/ui/deathscreen_icon")
local DEAD_ICON_WIDTH = 152
local DEAD_ICON_HEIGHT = 152

surface.CreateFont("foDeathFont", {
	font = "Akbar",
	size = 60,
	weight = 650,
	antialias = true,
	additive = true
})

local owner, w, h, ceil, ft, clmp
ceil = math.ceil
clmp = math.Clamp
local aprg, aprg2 = 0, 0

function nut.hud.drawDeath()
	owner = LocalPlayer()
	ft = FrameTime()
	w, h = ScrW(), ScrH()

	if (owner:getChar()) then
		if (owner:Alive()) then
			if (aprg != 0) then
				aprg2 = clmp(aprg2 - ft*1.3, 0, 1)
				if (aprg2 == 0) then
					aprg = clmp(aprg - ft*.7, 0, 1)
				end
			end

			PLUGIN.deathHookCalled = false
		else
			if ( not PLUGIN.deathHookCalled ) then
				onDeath()
				PLUGIN.deathHookCalled = true
			end

			if (aprg2 != 1) then
				aprg = clmp(aprg + ft*.5, 0, 1)
				if (aprg == 1) then
					aprg2 = clmp(aprg2 + ft*.4, 0, 1)
				end
			end
		end
	end

	if owner:Alive() or (IsValid(nut.char.gui) and nut.gui.char:IsVisible() or !owner:getChar()) then
		return
	end

	local text = "You are dead"

	surface.SetDrawColor(0, 0, 0, ceil((aprg^.5) * 255))
	surface.DrawRect(-1, -1, w+2, h+2)
	--local tx, ty = nut.util.drawText(L"Shrek", w/2, h/2, ColorAlpha(color_white, aprg2 * 255), 1, 1, "nutDynFontMedium", aprg2 * 255)

	surface.SetTextColor(255, 178, 0, aprg2 * 255)
	surface.SetFont("foDeathFont")
	local textW, textH = surface.GetTextSize(text)
  surface.SetTextPos(ScrW() / 2 - textW / 2, ScrH() / 2 + (textH - 52 + DEAD_ICON_HEIGHT) / 2 - 30)
	surface.DrawText(text)

	surface.SetDrawColor(255, 255, 255, aprg2 * 255)
	surface.SetTexture(DEAD_ICON)
	surface.DrawTexturedRect(ScrW() / 2 - DEAD_ICON_WIDTH / 2, ScrH() / 2 - (textH - 52 + DEAD_ICON_HEIGHT) / 2 - 30, DEAD_ICON_WIDTH, DEAD_ICON_HEIGHT)
end
