CGCUI = CGCUI or {}

CGCUI.Theme = "GREEN" -- NOTE: The UI that will be used in-game

CGCUI.List = {
    ["AUTUMN"] = {
        BannerIcon = "https://i.imgur.com/QSi2FaA.png",
        TextColor = Color(255, 199, 44), -- Orange UI color scheme
        IconColor = Color(255, 199, 44),
        PrimaryColor = Color(255, 199, 44),
        SecondaryColor = Color(98, 76, 16),
        BackgroundColor = Color(98, 76, 16, 102),
        OutlineColor = Color(255, 199, 44),
        SelectedColor = Color(3, 132, 252, 255),
        HoverColor = Color(0, 0, 0),
    },
    ["GREEN"] = {
        BannerIcon = "https://i.imgur.com/ftbWDQu.png",
        TextColor = Color(21, 255, 18),
        IconColor = Color(10, 255, 9),
        PrimaryColor = Color(21, 255, 18),
        SecondaryColor = Color(21, 63, 18),
        BackgroundColor = Color(21, 63, 18, 150),
        OutlineColor = Color(50, 255, 44, 255),
        HoverColor = Color(0, 0, 0),
        SelectedColor = Color(3, 132, 252, 255),
    },
}

hook.Add("InitPostEntity", "CGCUI_Update", function()
    local ui = CGCUI.List[CGCUI.Theme]

	timer.Simple(0.5, function() -- NOTE: Fixes the failed init. from nut.fallout
		nut.fallout.color.main  = ui.PrimaryColor
	    nut.fallout.color.secondary	= ui.SecondaryColor
	    nut.fallout.color.background = ui.BackgroundColor
	    nut.fallout.color.hover	= ui.HoverColor

	    BuyMenu.Config.TextColor = ui.TextColor
	    BuyMenu.Config.IconColor = ui.IconColor
	    BuyMenu.Config.PrimaryColor = ui.PrimaryColor
	    BuyMenu.Config.BackgroundColor = ui.BackgroundColor
	    BuyMenu.Config.OutlineColor = ui.OutlineColor
	    BuyMenu.Config.SelectedColor = ui.SelectedColor

		if CLIENT then
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

		    nut.fallout.gui.bars["hp"] = {
		        w = 256,
		        h = 14,
		        x = 32,
		        y = ScrH() - 46 - 24,
		        label = "HP",
		        font = "UI_Medium",
		        color = ui.PrimaryColor,
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
		        color = ui.PrimaryColor,
		        max = 100,
		        getPos = function() return LocalPlayer():getLocalVar("stm", 0) end,
		        getNeg = function() return 0 end,
		    }
		end
	    MsgC(ui.PrimaryColor, " Updated UI Theme to " .. CGCUI.Theme .. " and updated all color values.\n" )
	end)
end)
