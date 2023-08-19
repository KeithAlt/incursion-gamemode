surface.CreateFont("uiLarge", {
	font = "Segoe UI Light",
	size = ScreenScale(24),
	weight = 100
})
surface.CreateFont("uiMedium", {
	font = "Segoe UI Light",
	size = ScreenScale(14),
	weight = 100
})
surface.CreateFont("uiSmall", {
	font = "Segoe UI Light",
	size = ScreenScale(8),
	weight = 100
})

local SKIN = {}
	SKIN.fontFrame = "BudgetLabel"
	SKIN.fontTab = "nutSmallFont"
	SKIN.fontButton = "nutSmallFont"
	SKIN.Colours = table.Copy(derma.SkinList.Default.Colours)
	SKIN.Colours.Window.TitleActive = Color(255, 255, 255)
	SKIN.Colours.Window.TitleInactive = Color(255, 255, 255)
	
	SKIN.Colours.Label.Default = Color(255, 255, 255, 255)

	SKIN.Colours.Button.Normal = Color(255, 255, 255)
	SKIN.Colours.Button.Hover = Color(255, 255, 255)
	SKIN.Colours.Button.Down = Color(255, 255, 255)
	SKIN.Colours.Button.Disabled = Color(80, 80, 80, 255)
	
	SKIN.colTextEntryText = Color(255, 255, 255)

	function SKIN:PaintPanel(panel)
		if (panel:GetPaintBackground()) then
			local w, h = panel:GetWide(), panel:GetTall()

			surface.SetDrawColor(0, 0, 0, 100)
			surface.DrawRect(0, 0, w, h)
			--surface.DrawOutlinedRect(0, 0, w, h)
		end;
	end;
	
	function SKIN:PaintFrame(panel)
		nut.util.drawBlur(panel, 5)

		surface.SetDrawColor(10, 10, 10, 100)
		surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
		surface.DrawRect(0, 0, panel:GetWide(), 24)
	end;

	function SKIN:PaintButton(panel)
		if (panel:GetPaintBackground()) then
			local w, h = panel:GetWide(), panel:GetTall()
			local alpha = 0

			if (panel:GetDisabled()) then
				alpha = 0
			elseif (panel.Depressed) then
				alpha = 150
			elseif (panel.Hovered) then
				alpha = 100
			end;

			surface.SetDrawColor(10, 10, 10, alpha)
			surface.DrawRect(0, 0, w, h)
		end;
	end;
	
	function SKIN:PaintWindowCloseButton(panel, w, h)
		if (panel:GetDisabled()) then
			surface.SetTextColor(255, 255, 255, 0)
		else
			surface.SetTextColor(255, 255, 255, 255)
		end;
		
		surface.SetTextPos(10, 2)
		surface.SetFont("nutSmallFont")
		surface.DrawText("X")
	end;
	
	function SKIN:PaintWindowMinimizeButton(panel, w, h) end;
	function SKIN:PaintWindowMaximizeButton(panel, w, h) end;
	
	function SKIN:PaintVScrollBar(panel, w, h) 
		surface.SetDrawColor(10, 10, 10, 100)
		surface.DrawRect(6, 0, panel:GetWide() - 6, panel:GetTall())
	end;
	function SKIN:PaintScrollBarGrip(panel, w, h) 
		surface.SetDrawColor(10, 10, 10, 100)
		surface.DrawRect(6, 0, panel:GetWide() - 6, panel:GetTall())
	end;
	function SKIN:PaintButtonDown(panel, w, h) 
		surface.SetDrawColor(10, 10, 10, 150)
		surface.DrawRect(6, 6, panel:GetWide() - 6, panel:GetTall() - 6)
	end;
	function SKIN:PaintButtonUp(panel, w, h) 
		surface.SetDrawColor(10, 10, 10, 150)
		surface.DrawRect(6, 0, panel:GetWide() - 6, panel:GetTall() - 6)
	end;

derma.DefineSkin("uitwo", "The base skin for the NutScript framework.", SKIN)
derma.RefreshSkins()