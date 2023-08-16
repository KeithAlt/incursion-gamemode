nut.fallout.gui.bars = nut.fallout.gui.bars or {}

local function drawBar(x, y, w, h, pos, neg, max, right, label, font, color)
	color = {r = color.r + 24, g = color.g + 24, b = color.b + 24}

	if (pos > max) then pos = max end;

	max = max - 1

	if (label) then
		if (!right) then
			surface.SetFont(font)
			surface.SetTextColor(0, 0, 0)
			surface.SetTextPos(x + 1, y - 5)
			surface.DrawText(label)
			surface.SetTextColor(color.r, color.g, color.b)
			surface.SetTextPos(x, y - 6)
			surface.DrawText(label)

			x = x + 40 + 10
		else
			surface.SetFont(font)
			surface.SetTextColor(0, 0, 0)
			surface.SetTextPos(x + w + 13, y - 5)
			surface.DrawText(label)
			surface.SetTextColor(color.r, color.g, color.b)
			surface.SetTextPos(x + w + 12, y - 6)
			surface.DrawText(label)

			x = x - 10
		end;
	end;

	pos = math.max(((w - 2) / max) * pos, 0)
	neg = math.max(((w - 2) / max) * neg, 0)

	surface.SetDrawColor(0, 0, 0, 150)
	surface.DrawRect(x, y, w + 6, h)
	surface.SetDrawColor(0, 0, 0, 200)
	surface.DrawOutlinedRect(x, y, w + 6, h)

	surface.SetDrawColor(color.r, color.g, color.b)
	surface.DrawRect(x + 3, y + 3, pos, h - 6)

	surface.SetDrawColor(255, 100, 100)
	surface.DrawRect(x + 4 + (w - neg), y + 3, neg, h - 6)
end;

function nut.fallout.hud()
	for i, v in pairs(nut.fallout.gui.bars) do
		drawBar(v.x, v.y, v.w, v.h, v.getPos(), v.getNeg(), v.max or v.getMax(), v.right, v.label, v.font, v.color)
	end;

	local localPlayer = LocalPlayer()

	if (!localPlayer.getChar(localPlayer)) then
		return
	end

	local weapon = localPlayer.GetActiveWeapon(localPlayer)

	if (IsValid(weapon) and weapon.DrawAmmo != false) then
		local clip =  weapon.Clip1(weapon)
		local count = localPlayer.GetAmmoCount(localPlayer, weapon.GetPrimaryAmmoType(weapon))
		local secondary = localPlayer.GetAmmoCount(localPlayer, weapon.GetSecondaryAmmoType(weapon))

		local w, h = ScrW(), ScrH()
		local color = nut.gui.palette.color_primary

		if (secondary > 0) then
			local x, y = w - 52, h - 128
			draw.SimpleText(secondary, "UI_Medium", x - 29, y - 26, Color(0, 0, 0), 1, 0)
			draw.SimpleText(secondary, "UI_Medium", x - 30, y - 27, color, 1, 0)
		elseif (weapon.GetClass(weapon) != "weapon_slam") then
			local x, y = w - 52, h - 160

			draw.SimpleText(count, "UI_Medium", x - 29, y + 1, Color(0, 0, 0), 1, 0)
			draw.SimpleText(count, "UI_Medium", x - 30, y, color, 1, 0)

			surface.SetDrawColor(Color(0, 0, 0))
			surface.DrawRect(x - 65, y - 13, 70, 6)

			surface.SetDrawColor(color)
			surface.DrawRect(x - 66, y - 14, 70, 6)

			y = y - 48

			draw.SimpleText(clip, "UI_Medium", x - 29, y + 1, Color(0, 0, 0), 1, 0)
			draw.SimpleText(clip, "UI_Medium", x - 30, y, color, 1, 0)
		end
	end
end;

function SCHEMA:HUDPaint()
	if (!LocalPlayer() or !LocalPlayer().getChar(LocalPlayer())) then return end;

	nut.fallout.hud()
end;

nut.fallout.gui.bars["hp"] = {
	w = 256,
	h = 14,
	x = 32,
	y = ScrH() - 46 - 24,
	label = "HP",
	font = "UI_Medium",
	color = nut.gui.palette.color_primary,
	getMax = function() return LocalPlayer():GetMaxHealth() end,
	getPos = function() return LocalPlayer():Health() end,
	getNeg = function() return 0 end,
}

nut.fallout.gui.bars["ap"] = {
	right = true,
	w = 256,
	h = 14,
	x = ScrW() - 348,
	y = ScrH() - 46 - 24,
	label = "AP",
	font = "UI_Medium",
	color = nut.gui.palette.color_primary,
	max = 100,
	getPos = function() return LocalPlayer():getLocalVar("stm", 0) end,
	getNeg = function() return 0 end,
}

--[[nut.fallout.gui.bars["thirst"] = {
	right = true,
	w = 120,
	h = 13,
	x = ScrW() - 358,
	y = ScrH() - 66 - 24,
	label = nil,
	font = "UI_Medium",
	color = Color(100, 100, 255),
	max = 100,
	getPos = function() return LocalPlayer():getChar():getData("thirst", 100) or 100 end,
	getNeg = function() return 0 end,
}

nut.fallout.gui.bars["hunger"] = {
	right = true,
	w = 120,
	h = 13,
	x = ScrW() - 222,
	y = ScrH() - 66 - 24,
	label = nil,
	font = "UI_Medium",
	color = Color(100, 255, 100),
	max = 100,
	getPos = function() return LocalPlayer():getChar():getData("hunger", 100) or 100 end,
	getNeg = function() return 0 end,
}]]--

hook.Add("ShouldHideBars", "hideBars", function() return true end)
hook.Add("CanDrawAmmoHUD", "hideAmmo", function() return false end)
hook.Add("ShouldDrawCrosshair", "hideCrosshair", function() return false end)
