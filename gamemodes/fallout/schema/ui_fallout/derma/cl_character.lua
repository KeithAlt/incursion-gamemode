local PANEL = {}
	function PANEL:Init()
		if (IsValid(nut.gui.loading)) then
			nut.gui.loading:Remove()
		end;

		if (IsValid(nut.gui.char) and (LocalPlayer().getChar and LocalPlayer():getChar())) and IsValid(LocalPlayer()) then
			nut.gui.char:Remove()
		end;

		if (!nut.localData.intro) then
			hook.Add("WorkshopDLPostInit", "FalloutIntro", function()
				vgui.Create("nutIntro")
			end)
		else
			if (!nut.menuSound) then self:playSound(nut.config.get("music", ""):lower()) end;
		end

		nut.gui.char = self

		self:Dock(FILL)
		self:MakePopup()
		self:Center()
		self:ParentToHUD()

		menu = self:Add("UI_DPanel_Horizontal")
			menu:SetPos(ScrW() * 0.2, ScrH() - (ScrH() * 0.2 + sH() * 0.45))
			menu:SetSize(212, sH() * 0.45)
			menu:DockPadding(12, 32, 12, 32)

		newChar = menu:Add("UI_DButton")
			newChar:Dock(TOP)
			newChar:DockMargin(0, 0, 0, 12)
			newChar:SetText("  NEW")
			newChar.DoClick = function()
				surface.PlaySound("fallout/ui/ui_char_new.wav")
				RunConsoleCommand("unsit")
				menu:SetDisabled(true)
				fadeOut(function()
					vgui.Create("nutCharCreate")
					self:Remove()
				end)
			end;

		loadChar = menu:Add("UI_DButton")
			loadChar:Dock(TOP)
			loadChar:DockMargin(0, 0, 0, 12)
			loadChar:SetText("  LOAD")
			loadChar.DoClick = function()
				surface.PlaySound("fallout/ui/ui_char_load.wav")
				RunConsoleCommand("unsit")

				if menu then
					menu:SetDisabled(true)
				end

				fadeOut(function()
					vgui.Create("nutCharLoad")
					self:Remove()
				end)
			end;
			if (#nut.characters == 0) then loadChar:SetDisabled(true) end;

			rule = menu:Add("UI_DButton")
			rule:Dock(TOP)
			rule:DockMargin(0, 0, 0, 12)
			rule:SetText("  RULES")
			rule.DoClick = function()
				gui.OpenURL( "https://claymoregaming.com/forums/index.php?/topic/64-fallout-incursion-rules/" )
			end

			content = menu:Add("UI_DButton")
			content:Dock(TOP)
			content:DockMargin(0, 0, 0, 12)
			content:SetText("  CONTENT")
			content.DoClick = function()
				gui.OpenURL( "https://steamcommunity.com/sharedfiles/filedetails/?id=948435070" )
			end

			forums = menu:Add("UI_DButton")
			forums:Dock(TOP)
			forums:DockMargin(0, 0, 0, 12)
			forums:SetText("  FORUMS")
			forums.DoClick = function()
				gui.OpenURL( "https://claymoregaming.com/forums/" )
			end

			discord = menu:Add("UI_DButton")
			discord:Dock(TOP)
			discord:DockMargin(0, 0, 0, 12)
			discord:SetText("  DISCORD")
			discord.DoClick = function()
				gui.OpenURL( "https://discordapp.com/invite/claymore" )
			end

			changes = menu:Add("UI_DButton")
			changes:Dock(TOP)
			changes:DockMargin(0, 0, 0, 12)
			changes:SetText("  CHANGES")
			changes.DoClick = function()
				gui.OpenURL( "https://claymoregaming.com/changes/" )
			end

			steam = menu:Add("UI_DButton")
			steam:Dock(TOP)
			steam:DockMargin(0, 0, 0, 12)
			steam:SetText("  STEAM")
			steam.DoClick = function()
				gui.OpenURL( "https://steamcommunity.com/groups/claymoregamingcommunity" )
			end

			shop = menu:Add("UI_DButton")
			shop:Dock(TOP)
			shop:DockMargin(0, 0, 0, 12)
			shop:SetText("  STORE")
			shop.DoClick = function()
				gui.OpenURL( "https://steamcommunity.com/openid/login?openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.mode=checkid_setup&openid.return_to=https%3A%2F%2Fstore.claymoregaming.com%2Fstore%2Findex.php&openid.realm=https%3A%2F%2Fstore.claymoregaming.com&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select" )
			end


		logo = self:Add("DHTML") -- Incorporate logo settings to configuration. (Width, Height & Link)
		if (ScrW() < 1600) then
							Derma_Message("Your screen resolution is below the recommend minimum,\nSome windows and UI elements may not work correctly.\nWe recommend a resolution of 1920x1080 or above.")
			return end

			local logoIcon = CGCUI.List[CGCUI.Theme].BannerIcon
			logo:SetSize(820, 300)
			logo:SetPos((ScrW() / 1.76) - (logo:GetWide() / 2), 75)
			logo:SetHTML([[<body style="margin: 0; padding: 0; overflow: hidden;"><img src="]]..logoIcon..[[" width="]]..logo:GetWide()..[[" height="]]..logo:GetTall()..[[" /></body>]])
	end;

	function PANEL:open()
		fadeIn(function()
			if (ScrW() < 1920) then
				if (!active) then
					Derma_Message("Your screen resolution is below the recommend minimum,\nSome windows and UI elements may not work correctly.\nWe recommend a resolution of 1920x1080 or above.")
				end;
			end;
		end)
	end;

	function PANEL:Paint(w, h)
		surface.SetDrawColor(0, 0, 0, 235)
		surface.DrawRect(0, 0, w, h)
	end;

	function PANEL:playSound(url)
		if (nut.menuSound) then
			nut.menuSound:Stop()
			nut.menuSound = nil
		end

		timer.Remove("nutSoundFader")

		local source = url

		if (source:find("%S")) then
			local function callback(sound, errorID, fault)
				if (sound) then
					sound:SetVolume(1)

					nut.menuSound = sound
					nut.menuSound:Play()
				else
					MsgC(Color(255, 50, 50), errorID.." ")
					MsgC(color_white, fault.."\n")
				end;
			end;

			if (source:find("http")) then
				sound.PlayURL(source, "noplay", callback)
			else
				sound.PlayFile("sound/"..source, "noplay", callback)
			end;
		end;
	end;

	function PANEL:fadeMusic()
		if (nut.menuSound) then
			local fraction = 1
			local start, finish = RealTime(), RealTime() + 10

			timer.Create("nutMusicFader", 0.1, 0, function()
				if (nut.menuSound) then
					fraction = 1 - math.TimeFraction(start, finish, RealTime())
					nut.menuSound:SetVolume(fraction * 0.5)

					if (fraction <= 0) then
						nut.menuSound:Stop()
						nut.menuSound = nil

						timer.Remove("nutMusicFader")
					end
				else
					timer.Remove("nutMusicFader")
				end
			end)
		end
	end;

vgui.Register("nutCharMenu", PANEL, "EditablePanel")

concommand.Add("dev_reloadmenu", function()
	if (IsValid(nut.gui.char)) then
		nut.gui.char:Remove()
		vgui.Create("nutCharMenu")
	else
		vgui.Create("nutCharMenu")
	end;

	if (IsValid(nut.gui.charCreate)) then
		nut.gui.charCreate:Remove()
	end;
	if(IsValid(nut.gui.charBuilder)) then
		nut.gui.charBuilder:Remove()
	end;
end)
