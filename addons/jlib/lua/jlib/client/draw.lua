--[[
	ShadowText
	Purpose: Draw a simple shadowed text
]]
function jlib.ShadowText(text, font, x, y, colortext, colorshadow, dist, xalign, yalign)
	surface.SetFont(font)
	local _, h = surface.GetTextSize(text)

	if (yalign == TEXT_ALIGN_CENTER) then
		y = y - h / 2
	elseif (yalign == TEXT_ALIGN_BOTTOM) then
		y = y - h
	end

	draw.DrawText(text, font, x + dist, y + dist, colorshadow, xalign)
	draw.DrawText(text, font, x, y, colortext, xalign)
end

--[[
	DrawTextOutlined
	Purpose: Same as draw.SimpleTextOutlined except we use DrawText instead of SimpleText to support line breaks
]]
function jlib.DrawTextOutlined(text, font, x, y, colour, xalign, outlinewidth, outlinecolour)
	local steps = (outlinewidth * 2) / 3
	if steps < 1 then steps = 1 end

	for _x = -outlinewidth, outlinewidth, steps do
		for _y = -outlinewidth, outlinewidth, steps do
			draw.DrawText(text, font, x + _x, y + _y, outlinecolour, xalign)
		end
	end

	return draw.DrawText(text, font, x, y, colour, xalign)
end

--[[
	DrawTip
	Purpose: Draws a rect with a triangle coming out of the bottom
]]
function jlib.DrawTip(x, y, w, h, text, font, textCol, outlineCol)
	draw.NoTexture()

	local rectH = 0.85
	local triW = 0.1

	local verts = {
		{x = x, y = y},
		{x = x + w, y = y},
		{x = x + w, y = y + (h * rectH)},
		{x = x + (w / 2) + (w * triW), y = y + (h * rectH)},
		{x = x + (w / 2), y = y + h},
		{x = x + (w / 2) - (w * triW), y = y + (h * rectH)},
		{x = x, y = y + (h * rectH)}
	}
	surface.DrawPoly(verts)

	if text and font then
		jlib.DrawTextOutlined(text, font, x + (w / 2), y, textCol or Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, 1, outlineCol or Color(0, 0, 0, 255))
	end
end

--[[
	DrawCircle
	Purpose: Draws a circle using surface.DrawPoly
	Credits: https://wiki.garrysmod.com/page/surface/DrawPoly
]]
function jlib.DrawCircle(x, y, radius, seg, percent)
	local cir = {}
	percent = percent or 1

	table.insert(cir,{ x = x, y = y, u = 0.5, v = 0.5})
	for i = 0, seg do
		local a = math.rad((i / seg) * (-360 * percent))
		table.insert(cir, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5})
	end

	local a = math.rad(-360 * percent)
	table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5})

	draw.NoTexture()
	surface.DrawPoly(cir)
end

--[[
	DrawOutlinedRect
	Purpose: Draw an outlined rect of a specified width
]]
function jlib.DrawOutlinedRect(x, y, w, h, bW)
	surface.DrawRect(x, y, bW, h)
	surface.DrawRect(w - bW, y, bW, h)

	surface.DrawRect(x, y, w, bW)
	surface.DrawRect(x, h - bW, w, bW)
end

--[[
	AddBackgroundBlur
	Purpose: Add background blur to a panel that doesn't natively support it
]]
function jlib.AddBackgroundBlur(pnl)
	local oldPaint = pnl.Paint

	pnl.Paint = function(s, w, h)
		Derma_DrawBackgroundBlur(s, s.m_fCreateTime)
		oldPaint(s, w, h)
	end
end

jlib.BlurMat = Material("pp/blurscreen")
function jlib.Blur(pnl, intensity)
	DisableClipping(true)

	local x, y = pnl:ScreenToLocal(0, 0)

	surface.SetMaterial(jlib.BlurMat)
	surface.SetDrawColor(255, 255, 255, 255)

	for i = 0.33, 1, 0.33 do
		jlib.BlurMat:SetFloat("$blur", intensity * 6 * i)
		jlib.BlurMat:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(x, y, ScrW(), ScrH())
	end

	surface.SetDrawColor(10, 10, 10, 254 * intensity)
	surface.DrawRect(x, y, ScrW(), ScrH())

	DisableClipping(false)
end

surface.CreateFont("jlibProgress", {font = "Arial", size = 32, weight = 400})

function jlib.DrawProgressBar(x, y, w, h, progress, text, drawDots, color, font)
	progress = math.Clamp(progress, 0, 1)

	if drawDots then
		text = jlib.DotDotDot(text)
	end

	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawOutlinedRect(x, y, w, h)
	surface.SetDrawColor(80, 80, 80, 240)
	surface.DrawRect(x + 1, y + 1, w - 2, h - 2)
	surface.SetDrawColor(color:Unpack())
	surface.DrawRect(x + 1, y + 1, (progress * w) - 2, h - 2)

	if text then
		jlib.ShadowText(text, font or "jlibProgress", x + (w / 2), y + (h / 2), Color(255, 255, 255, 255), Color(0, 0, 0, 255), 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end
