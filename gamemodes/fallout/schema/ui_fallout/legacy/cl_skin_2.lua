surface.CreateFont("falloutRegular",{
	font = "roboto-condensed_regular",
	size = 20,
	antialias = true,
	--shadow = true,
	weight = 600,
})
surface.CreateFont("falloutBold",{
	font = "roboto-condensed_bold",
	size = 25,
	antialias = true,
	--shadow = true,
	weight = 500,
})
surface.CreateFont("falloutBig",{
	font = "roboto-condensed_bold",
	size = 35,
	antialias = true,
	--shadow = true,
	weight = 1000,
})
surface.CreateFont("falloutTitle",{
	font = "roboto-condensed_bold",
	size = 35,
	antialias = true,
	shadow = true,
	weight = 1000,
})
surface.CreateFont("falloutHuge",{
	font = "roboto-condensed_bold",
	size = 80,
	antialias = true,
	--shadow = true,
	weight = 1000,
})
surface.CreateFont("falloutHugeItalic",{
	font = "roboto-condensed_bold",
	size = 80,
	antialias = true,
	italic = true,
	--shadow = true,
	weight = 1000,
})
surface.CreateFont("falloutSubTitle",{
	font = "roboto-condensed_bold",
	size = 20,
	antialias = true,
	shadow = true,
	weight = 600,
})

local SKIN = {}
	SKIN.fontFrame = "falloutRegular"
	SKIN.fontTab = "falloutRegular"
	SKIN.fontButton = "FalloutBold"

	SKIN.Colours = table.Copy(derma.SkinList.Default.Colours)

	SKIN.Colours.Window.TitleActive 	= nut.gui.palette.color_primary
	SKIN.Colours.Window.TitleInactive 	= nut.gui.palette.color_primary

	SKIN.Colours.Label.Default 			= nut.gui.palette.color_primary

	SKIN.Colours.Button.Normal 			= nut.gui.palette.color_primary
	SKIN.Colours.Button.Hover 			= nut.gui.palette.color_hover
	SKIN.Colours.Button.Down 			= nut.gui.palette.color_primary
	SKIN.Colours.Button.Disabled 		= nut.gui.palette.color_background

	function SKIN:PaintFrame(panel)
		if (panel:GetPaintBackground()) then
			--nut.util.drawBlur(panel, 10)

			-- Background
			surface.SetDrawColor(nut.fallout.color.background)
			surface.DrawRect(0, 24, panel:GetWide(), panel:GetTall())

			DisableClipping(true)

			-- Shadow
			surface.SetDrawColor(Color(0, 0, 0))
			surface.DrawRect(1, 0, panel:GetWide() + 2, 1) 						-- Top
			surface.DrawRect(-1, -1, 2, 6) 										-- Top Left
			surface.DrawRect(panel:GetWide() + 1, -1, 2, 6) 					-- Top Right
			surface.DrawRect(1, panel:GetTall() + 2, panel:GetWide() + 2, 1) 	-- Bottom
			surface.DrawRect(-1, panel:GetTall() - 3, 2, 6)						-- Bottom Left
			surface.DrawRect(panel:GetWide() + 2, panel:GetTall() - 3, 1, 6)	-- Bottom Right

			-- Top Lines
			surface.SetDrawColor(nut.fallout.color.main)
			surface.DrawRect(0, -2, panel:GetWide(), 2) 						-- Top
			surface.DrawRect(-2, -2, 2, 6) 										-- Top Left
			surface.DrawRect(panel:GetWide(), -2, 2, 6) 						-- Top Right
			surface.DrawRect(0, panel:GetTall(), panel:GetWide(), 2) 			-- Bottom
			surface.DrawRect(-2, panel:GetTall() - 4, 2, 6)						-- Bottom Left
			surface.DrawRect(panel:GetWide(), panel:GetTall() - 4, 2, 6)		-- Bottom Right

			DisableClipping(false)
		end;
	end;

	function SKIN:PaintPanel(panel)
		if (panel:GetPaintBackground()) then
			-- Background
			surface.SetDrawColor(panel.BackgroundColor or nut.fallout.color.background)
			surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())

			DisableClipping(true)

			-- Shadow
			surface.SetDrawColor(Color(0, 0, 0))
			surface.DrawRect(1, 0, panel:GetWide() + 2, 1) 						-- Top
			surface.DrawRect(-1, -1, 2, 6) 										-- Top Left
			surface.DrawRect(panel:GetWide() + 1, -1, 2, 6) 					-- Top Right
			surface.DrawRect(1, panel:GetTall() + 2, panel:GetWide() + 2, 1) 	-- Bottom
			surface.DrawRect(-1, panel:GetTall() - 3, 2, 6)						-- Bottom Left
			surface.DrawRect(panel:GetWide() + 2, panel:GetTall() - 3, 1, 6)	-- Bottom Right

			-- Top Lines
			surface.SetDrawColor(panel.LineColor or nut.fallout.color.main)
			surface.DrawRect(0, -2, panel:GetWide(), 2) 						-- Top
			surface.DrawRect(-2, -2, 2, 6) 										-- Top Left
			surface.DrawRect(panel:GetWide(), -2, 2, 6) 						-- Top Right
			surface.DrawRect(0, panel:GetTall(), panel:GetWide(), 2) 			-- Bottom
			surface.DrawRect(-2, panel:GetTall() - 4, 2, 6)						-- Bottom Left
			surface.DrawRect(panel:GetWide(), panel:GetTall() - 4, 2, 6)		-- Bottom Right

			DisableClipping(false)
		end;
	end;

	function SKIN:PaintButton(panel)
		if (panel:GetPaintBackground()) then
			local w, h = panel:GetWide(), panel:GetTall()

			if (panel.Hovered or panel.Depressed) then
				DisableClipping(true)
				surface.SetDrawColor(nut.fallout.color.hover)
				surface.DrawRect(1, 1, w, h)
				DisableClipping(false)

				surface.SetDrawColor(nut.fallout.color.main)
			else
				surface.SetDrawColor(Color(0, 0, 0, 0))
			end;

			surface.DrawRect(0, 0, w, h)
		end;
	end;

	function SKIN:PaintTextEntry(panel, w, h)
		DisableClipping(true)
		surface.SetDrawColor(nut.fallout.color.hover)
		surface.DrawRect(1, 1, w, h)
		DisableClipping(false)

		surface.SetDrawColor(nut.fallout.color.main)
		surface.DrawRect(0, 0, w, h)

		panel:DrawTextEntryText(Color(0, 0, 0), panel.m_colHighlight, panel.m_colCursor)
	end;

	function SKIN:SchemeTextEntry(panel)
		panel:SetTextColor(nut.fallout.color.hover)
		panel:SetHighlightColor(Color(0, 0, 0, 255))
		panel:SetCursorColor(self.colTextEntryTextCursor)
	end;

	function SKIN:PaintWindowMinimizeButton(panel, w, h) end;

	function SKIN:PaintWindowMaximizeButton(panel, w, h) end;

	function SKIN:PaintWindowCloseButton(panel, w, h)
		surface.SetTextColor(nut.fallout.color.main)
		surface.SetTextPos(11, -2)
		surface.SetFont("falloutBold")
		surface.DrawText("x")
	end;

derma.DefineSkin("fallout", "The base skin for the NutScript framework.", SKIN)
derma.RefreshSkins()
