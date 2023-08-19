nut.fallout.gui = nut.fallout.gui or {}

----------------------------
-- // UI SCALING TOOLS // --
----------------------------
function sW(width)
	if (width) then
		return width * (ScrW() / 1920)
	else
		return 1920
	end
end

function sH(height)
	if (height) then
		return height * (ScrH() / 1080)
	else
		return 1080
	end
end

--------------------
-- // UI FADER // --
--------------------
function fadeIn(callback)
	if (!IsValid(nut.gui.fade)) then
		nut.gui.fade = vgui.Create("DPanel")
		nut.gui.fade:SetZPos(9999)
		nut.gui.fade:SetSize(ScrW(), ScrH())
		nut.gui.fade.Paint = function(p, w, h)
			surface.SetDrawColor(Color(0, 0, 0))
			surface.DrawRect(0, 0, w, h)
		end
		nut.gui.fade.Think = function()
			nut.gui.fade:MakePopup()
		end
	end

	nut.gui.fade:AlphaTo(0, 1, 0.5, function() nut.gui.fade:Remove() if (callback) then callback() end end)
end

function fadeOut(callback)
	if (!IsValid(nut.gui.fade)) then
		nut.gui.fade = vgui.Create("DPanel")
		nut.gui.fade:SetZPos(9999)
		nut.gui.fade:SetAlpha(0)
		nut.gui.fade:SetSize(ScrW(), ScrH())
		nut.gui.fade.Paint = function(p, w, h)
			surface.SetDrawColor(Color(0, 0, 0))
			surface.DrawRect(0, 0, w, h)
		end
		nut.gui.fade.Think = function()
			nut.gui.fade:MakePopup()
		end
	end

	nut.gui.fade:AlphaTo(255, 1, 0, function() if (callback) then callback() end end)
end

-------------------------
-- // COLOR PALETTE // --
-------------------------
// Green color scheme //
/**nut.gui.palette = {
	color_primary 		= Color(21, 255, 18),
	color_background	= Color(21, 63, 18, 150),
	color_active			= Color(10, 127, 9),
	color_hover 			= Color(0, 0, 0),

	text_primary 	= Color(21, 255, 18),
	text_red 			= Color(100, 255, 100),
	text_disabled = Color(10, 127, 9),
	text_hover 		= Color(0, 0, 0),
}**/

// Orange color scheme //
local ui = CGCUI.List[CGCUI.Theme]
nut.gui.palette = {
	color_primary 		= ui.PrimaryColor,
	color_background	= ui.BackgroundColor,
	color_active			= ui.SecondaryColor,
	color_hover 			= ui.HoverColor,
	
	text_primary 	= ui.PrimaryColor,
	text_red 			= Color(255, 100, 100),
	text_disabled = ui.SecondaryColor,
	text_hover 		= ui.HoverColor,
}

-------------------------
-- // FALLOUT FONTS // --
-------------------------
local fonts = {
	regular	= "Roboto",
	bold    = "Roboto"
}

surface.CreateFont("UI_Regular",{
	font = fonts.regular,
	size = 20,
	antialias = true,
	weight = 400
})

surface.CreateFont("UI_Bold",{
	font = fonts.bold,
	size = 25,
	antialias = true,
	weight = 500
})

surface.CreateFont("UI_Medium",{
	font = fonts.bold,
	size = 30,
	antialias = true,
	weight = 600
})


surface.CreateFont("UI_Big",{
	font = fonts.bold,
	size = 35,
	antialias = true,
	weight = 600
})
