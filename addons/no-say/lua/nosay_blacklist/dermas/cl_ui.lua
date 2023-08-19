-- There's no way you're catching me comment all this derma code...

-- Function cache
local color = Color
local draw_simpletext = draw.SimpleText
local draw_notexture = draw.NoTexture
local draw_roundedboxex = draw.RoundedBoxEx
local draw_roundedbox = draw.RoundedBox
local surface_setdrawcolor = surface.SetDrawColor
local surface_setmaterial = surface.SetMaterial
local surface_drawtexturedrect = surface.DrawTexturedRect
-- Color cache
local mainWhite = color(245, 245, 245)
local bodyWhite = color(242, 242, 242)
local mainBlue = color(50, 125, 255)
local lineBreak = color(0, 0, 0, 20)
local scrollBackground = color(0, 0, 0, 100)
-- Material cache
local gradientDown = Material("gui/gradient_down")
local gradientMain = Material("gui/gradient")

function noSayBlacklist.UI.Panel(myStrikes)
	local frame = vgui.Create("DFrame")
	frame:SetSize(ScrW() * 0.6, ScrH() * 0.6)
	frame:SetTitle("")
	frame:Center()
	frame:MakePopup()
	frame:ShowCloseButton(false)
	frame:SetDraggable(false)
	frame:DockPadding(0, 0, 0, 0)
	frame.Paint = function(self, w, h)
		-- We drop the 40 to allow for rounded edges on the header
		draw_roundedbox(0, 0, 40, w, h-40, bodyWhite)
	end
	frame.fullScreen = false
	frame.centerX, frame.centerY = frame:GetPos()
	--timer.Simple(3, function() frame:Close() end)

	local header = vgui.Create("DPanel", frame)
	header:Dock(TOP)
	header:SetTall(40)
	header:DockMargin(0, 0, 0, 0)
	header.Paint = function(self, w, h)
		draw_roundedboxex(5, 0, 0, w, 40, mainWhite, true, true)
		draw_simpletext(noSayBlacklist.Translate.Title, "NoSay.Header.Static", 10, 20, mainBlue, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

		-- Header buttons
		local close = vgui.Create("DButton", header)
		close:Dock(RIGHT)
		close:SetSize(header:GetTall(), header:GetTall())
		close:SetText("")
		close.animationLerp = 0
		close.Paint = function(self, w, h)
			if self:IsHovered() then
				self.animationLerp = Lerp(0.1, self.animationLerp, 1)
			else
				self.animationLerp = Lerp(0.1, self.animationLerp, 0)
			end

			draw_notexture()
			surface_setdrawcolor(200 - (self.animationLerp*55), 0, 0, 255)
			noSayBlacklist.UI.DrawCircle(w*0.5, h*0.5, w*0.2, 1)
		end
		close.DoClick = function()
			frame:Close()
		end

		local scale = vgui.Create("DButton", header)
		scale:Dock(RIGHT)
		scale:SetSize(header:GetTall(), header:GetTall())
		scale:SetText("")
		scale.animationLerp = 0
		scale.Paint = function(self, w, h)
			if self:IsHovered() then
				self.animationLerp = Lerp(0.08, self.animationLerp, 1)
			else
				self.animationLerp = Lerp(0.08, self.animationLerp, 0)
			end

			draw_notexture()
			surface_setdrawcolor(255, 165 - (self.animationLerp*25), 0, 255)
			noSayBlacklist.UI.DrawCircle(w*0.5, h*0.5, w*0.2, 1)
		end
		scale.DoClick = function()
			if frame.fullScreen then
				frame:SizeTo(ScrW()*0.6, ScrH()*0.6, 0.5)
				frame:MoveTo(frame.centerX, frame.centerY, 0.5)
			else
				frame:SizeTo(ScrW(), ScrH(), 0.5)
				frame:MoveTo(0, 0, 0.5)
			end

			frame.fullScreen = not frame.fullScreen
		end

	-- Used to apply padding as DScrollPanel doesn't allow it
	local shellParent = vgui.Create("DPanel", frame)
	shellParent:Dock(FILL)
	shellParent:DockPadding(5, 5, 5, 5)
	shellParent.Paint = function(self, w, h)
		surface_setdrawcolor(0, 0, 0, 55)
		-- Header shadow
		surface_setmaterial(gradientDown)
		surface_drawtexturedrect(0, 0, w, 10)
		-- Navbar shadow
		surface_setmaterial(gradientMain)
		surface_drawtexturedrect(0, 0, 10, h)
	end
	local shell = vgui.Create("DScrollPanel", shellParent)
	shell:Dock(FILL)
	shell.Paint = function() end
	local sbar = shell:GetVBar()
	sbar:SetWide(sbar:GetWide()*0.5)
	sbar:SetHideButtons(true)
	function sbar:Paint(w, h)
		draw_roundedbox(10, 0, 0, w, h, scrollBackground)
	end
	function sbar.btnGrip:Paint(w, h)
		draw_roundedbox(10, 0, 0, w, h, mainBlue)
	end


	local navBar = vgui.Create("DScrollPanel", frame)
	navBar:Dock(LEFT)

	local buttonX, buttonY = 0, 0
	local barPos = 0
	navBar.Paint = function(self, w, h)
		draw_roundedbox(0, 0, 0, w, h, mainWhite)
		draw_roundedbox(0, 0, 0, w, 2, lineBreak)
		if self.currentFocus then
			buttonX, buttonY = self.currentFocus:GetPos()
		end
		barPos = Lerp(0.1, barPos, buttonY)

		draw_roundedbox(0, 0, barPos, 4, 40, mainBlue)
	end
	navBar:SetSize(frame:GetWide()*0.2)
	navBar:GetVBar():SetWide(0)
	navBar.open = true

	function navBar:AddTab(name, callback)
		local button = vgui.Create("DButton", self)
		button:Dock(TOP)
		button:SetTall(40)
		button:SetText("")

		button.Paint = function(me, w, h)
			draw_simpletext(name, "NoSay.Nav.Static", 12, h*0.5, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw_roundedbox(0, 5, h-2, w-10, 2, lineBreak)
		end

		button.DoClick = function()
			shell:Clear()
			self.currentFocus = button
			callback(shell, button, self)
		end

		if not self.currentFocus then
			timer.Simple(0.1, function()
				if not IsValid(button) then return end
				button.DoClick()
			end)
			self.currentFocus = button
		end
	end

--	navBar:AddTab("Collapse", function(shell, button, nav)
--		if nav.open then
--			nav:SizeTo(64, -1, 0.5)
--		else
--			nav:SizeTo(frame:GetWide()*0.2, -1, 0.5)
--		end
--
--		nav.open = not nav.open
--	end)
	navBar:AddTab(noSayBlacklist.Translate.MyStrikesButton, function(shell)
		local title = vgui.Create("DPanel", shell)
		title:Dock(TOP)
		title:SetTall(36)
		local strikeString = string.format(noSayBlacklist.Translate.MyStrikesTitle, #myStrikes)
		title.Paint = function(self, w, h)
			draw_simpletext(strikeString, "NoSay.Title.Static", 10, h*0.5, mainBlue, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		local tableHeaders = vgui.Create("DPanel", shell)
		tableHeaders:Dock(TOP)
		tableHeaders:SetTall(30)
		tableHeaders.Paint = function(self, w, h)
			draw_simpletext(noSayBlacklist.Translate.MyStrikesWordTitle, "NoSay.Main.Static", 10, h*0.5, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw_simpletext(noSayBlacklist.Translate.MyStrikesTimeTitle, "NoSay.Main.Static", w*0.5, h*0.5, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw_roundedbox(0, 5, h-2, w-10, 2, lineBreak)
			--draw_roundedbox(0, (w*0.5)-5, 0, 2, h-2, lineBreak)
		end
		for k, v in ipairs(table.Reverse(myStrikes)) do
			local strike = vgui.Create("DPanel", shell)
			strike:SetTall(30)
			strike:Dock(TOP)
			strike.Paint = function(self, w, h)
				if(k%2 == 0) then
					draw_roundedbox(0, 0, 0, w, h, lineBreak)
				end
				draw_simpletext(v.word, "NoSay.Main.Static", 10, h*0.5, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw_simpletext(os.date("%H:%M:%S on %d/%m/%Y", tonumber(v.date)), "NoSay.Main.Static", w*0.5, h*0.5, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
		end
	end)
	-- Only show if the user is an admin or the setting is enabled to allow global lookups
	if tobool(noSayBlacklist.Core.GetSetting("strike_lookup")) or noSayBlacklist.Core.CheckPrivilege(LocalPlayer()) then
		navBar:AddTab(noSayBlacklist.Translate.StrikeSearchButton, function(shell)
			local title = vgui.Create("DPanel", shell)
			title:Dock(TOP)
			title:SetTall(57.5)
			title.Paint = function(self, w, h)
				draw_simpletext(noSayBlacklist.Translate.SearchTitle, "NoSay.Title.Static", 10, 0, mainBlue, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				draw_simpletext(noSayBlacklist.Translate.SearchSubTitle, "NoSay.SubTitle.Static", 10, h, mainBlue, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
			end

			local searchBox = vgui.Create("DPanel", shell)
			searchBox:Dock(TOP)
			searchBox:DockMargin(5, 0, 5, 0)
			searchBox:SetTall(35)
			searchBox.Paint = function(self, w, h) end

			local searchInput = vgui.Create("NSEntry", searchBox)
			searchInput:Dock(FILL)
			searchInput.OnEnter = function()
				net.Start("nosay_admin_lookupid")
					net.WriteString(string.Trim(searchInput:GetValue()))
				net.SendToServer()
			end
			searchInput:SetDisplayText(noSayBlacklist.Translate.SearchSteamID)

			local tableHeaders = vgui.Create("DPanel", shell)
			tableHeaders:Dock(TOP)
			tableHeaders:SetTall(30)
			local perms = noSayBlacklist.Core.CheckPrivilege(LocalPlayer())
			tableHeaders.Paint = function(self, w, h)
				draw_simpletext(noSayBlacklist.Translate.MyStrikesWordTitle, "NoSay.Main.Static", 10, h*0.5, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw_simpletext(noSayBlacklist.Translate.MyStrikesTimeTitle, "NoSay.Main.Static", w*0.5, h*0.5, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw_roundedbox(0, 5, h-2, w-10, 2, lineBreak)
				if perms then
					draw_simpletext(noSayBlacklist.Translate.SearchAction, "NoSay.Main.Static", w-10, h*0.5, color_black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				end
				--draw_roundedbox(0, (w*0.5)-5, 0, 2, h-2, lineBreak)
			end

			local strikeCache = {}
			net.Receive("nosay_admin_lookupid_return", function()
				local strikes = net.ReadTable()
				for k, v in pairs(strikeCache) do
					v:Remove()
				end

				if strikes[1] and (not strikes[1].word) then
					local strike = vgui.Create("DPanel", shell)
					strike:SetTall(30)
					strike:Dock(TOP)
					strike.Paint = function(self, w, h)
						draw_simpletext(noSayBlacklist.Translate.SearchNoStrikes, "NoSay.Main.Static", 10, h*0.5, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					end

					table.insert(strikeCache, strike)
					return
				end

				for k, v in pairs(strikes) do
					local strike = vgui.Create("DPanel", shell)
					strike:SetTall(30)
					strike:Dock(TOP)
					strike.Paint = function(self, w, h)
						if(k%2 == 0) then
							draw_roundedbox(0, 0, 0, w, h, lineBreak)
						end
						draw_simpletext(v.word, "NoSay.Main.Static", 10, h*0.5, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
						draw_simpletext(os.date("%H:%M:%S on %d/%m/%Y", tonumber(v.date)), "NoSay.Main.Static", w*0.5, h*0.5, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					end

					if perms then
						local remove = vgui.Create("DButton", strike)
						remove:Dock(RIGHT)
						remove:SetSize(strike:GetTall(), strike:GetTall())
						remove:SetText("")
						remove.animationLerp = 0
						remove.Paint = function(self, w, h)
							if self:IsHovered() then
								self.animationLerp = Lerp(0.1, self.animationLerp, 1)
							else
								self.animationLerp = Lerp(0.1, self.animationLerp, 0)
							end

							draw_notexture()
							surface_setdrawcolor(200 - (self.animationLerp*55), 0, 0, 255)
							noSayBlacklist.UI.DrawCircle(w*0.5, h*0.5, w*0.2, 1)
						end
						remove.DoClick = function()
							net.Start("nosay_admin_lookupid_remove")
								net.WriteTable(v)
							net.SendToServer()
							strike:Remove()
						end
					end

					table.insert(strikeCache, strike)
				end
			end)
		end)
	end
	-- This is for the admin permissions
	if noSayBlacklist.Core.CheckPrivilege(LocalPlayer()) then
		navBar:AddTab(noSayBlacklist.Translate.SettingsButton, function(shell)
			local title = vgui.Create("DPanel", shell)
			title:Dock(TOP)
			title:DockMargin(0, 0, 0, 5)
			title:SetTall(57.5)
			title.Paint = function(self, w, h)
				draw_simpletext(noSayBlacklist.Translate.SettingsTitle, "NoSay.Title.Static", 10, 0, mainBlue, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				draw_simpletext(noSayBlacklist.Translate.SettingsSubTitle, "NoSay.SubTitle.Static", 10, h, mainBlue, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
			end

			local options = {}
			for k,v in pairs(noSayBlacklist.Core.Settings) do
				options[v.setting] = v.value

				local setting = vgui.Create("DPanel", shell)
				setting:SetTall(75)
				setting:Dock(TOP)
				setting.Paint = function(self, w, h)
					draw_simpletext(v.name, "NoSay.Main.Static", 10, 0, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
					draw_simpletext(v.desc, "NoSay.SubTitle.Static", 10, 25, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
					draw_roundedbox(0, 5, h-2, w-10, 2, lineBreak)
				end

				if v.switch then
					local toggle = vgui.Create("NSSwitch", setting)
					toggle:SetPos(10, setting:GetTall()-toggle:GetTall()-5)
					toggle:SetWide(40)
					toggle:SetToggle(v.value)
					toggle.DoClick = function()
						toggle:Toggle()
						options[v.setting] = toggle:GetToggle()
					end
				else
					local entry = vgui.Create("NSEntry", setting)
					entry:SetPos(10, setting:GetTall()-entry:GetTall()-5)
					entry:SetWide(shell:GetWide() - 20)
					entry.OnChange = function()
						options[v.setting] = entry:GetValue()
					end
					entry:SetText(v.value)
					entry:SetDisplayText(v.value)
					if v.numeric then
						entry:SetNumeric(true)
					end
				end
			end

			local submit = vgui.Create("DButton", shell)
			submit:SetText("")
			submit:Dock(TOP)
			submit:SetTall(40)
			submit:DockMargin(5, 5, 5, 5)
			submit.animationLerp = 0
			submit.Paint = function(self, w, h)
				if self:IsHovered() then
					self.animationLerp = Lerp(0.1, self.animationLerp, 1)
				else
					self.animationLerp = Lerp(0.1, self.animationLerp, 0)
				end
				-- (self.animationLerp*55)
				draw_roundedbox(0+(5*self.animationLerp), 0, 0, w, h-5, mainBlue)
				draw_simpletext(noSayBlacklist.Translate.SettingsSaveButton, "NoSay.Main.Static", w*0.5, (h*0.5)-5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			submit.DoClick = function()
				net.Start("nosay_admin_settings_update")
					net.WriteTable(options)
				net.SendToServer()
				frame:Close()
			end

		end)
		navBar:AddTab(noSayBlacklist.Translate.BlackistButton, function(shell)
			local shadeCounter = 1

			local title = vgui.Create("DPanel", shell)
			title:Dock(TOP)
			title:SetTall(57.5)
			title.Paint = function(self, w, h)
				draw_simpletext(noSayBlacklist.Translate.BlacklistTitle, "NoSay.Title.Static", 10, 0, mainBlue, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				draw_simpletext(noSayBlacklist.Translate.BlacklistSubTitle, "NoSay.SubTitle.Static", 10, h, mainBlue, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
			end

			local addWord = vgui.Create("DPanel", shell)
			addWord:SetTall(110)
			addWord:Dock(TOP)
			addWord.Paint = function(self, w, h)
				draw_simpletext(noSayBlacklist.Translate.BlacklistAddWordHeader, "NoSay.Main.Static", 10, 0, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				--draw_simpletext(v.desc, "NoSay.SubTitle.Static", 10, 20, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				draw_roundedbox(0, 5, h-2, w-10, 2, lineBreak)
			end

				local newWord = vgui.Create("NSEntry", addWord)
				newWord:SetPos(10, 30)
				newWord:SetWide(shell:GetWide() - 20)
				newWord:SetDisplayText(noSayBlacklist.Translate.BlacklistBlacklistedWord)

				local replacementWord = vgui.Create("NSEntry", addWord)
				replacementWord:SetPos(10, 55)
				replacementWord:SetWide(shell:GetWide() - 20)
				replacementWord:SetDisplayText(noSayBlacklist.Translate.BlacklistReplacementWord)

				local submit = vgui.Create("DButton", addWord)
				submit:SetText("")
				submit:Dock(BOTTOM)
				submit:SetTall(25)
				submit:DockMargin(10, 5, 10, 5)
				submit.animationLerp = 0
				submit.Paint = function(self, w, h)
					if self:IsHovered() then
						self.animationLerp = Lerp(0.1, self.animationLerp, 1)
					else
						self.animationLerp = Lerp(0.1, self.animationLerp, 0)
					end
					-- (self.animationLerp*55)
					draw_roundedbox(0+(5*self.animationLerp), 0, 0, w, h, mainBlue)
					draw_simpletext(noSayBlacklist.Translate.BlacklistAddButton, "NoSay.Main.Static", w*0.5, (h*0.5), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
				submit.DoClick = function()
					if string.Trim(newWord:GetValue(), " ") == "" then return end
					if (noSayBlacklist.Core.Words[newWord:GetValue()]) then
						noSayBlacklist.Core.Msg(noSayBlacklist.Translate.BlacklistAlreadyExists)
						return
					end
					if(newWord:GetValue() == replacementWord:GetValue()) then
						noSayBlacklist.Core.Msg(noSayBlacklist.Translate.BlacklistReplacementIsSame, ply)
						return
					end

					net.Start("nosay_admin_words_add")
						net.WriteString(newWord:GetValue())
						net.WriteString(replacementWord:GetValue())
					net.SendToServer()

					-- This sure is an ugly way of doing this :/
					local word = vgui.Create("DPanel", shell)
					word:SetTall(30)
					word:Dock(TOP)
					word.counter = shadeCounter
					word.word = newWord:GetValue()
					word.replace = replacementWord:GetValue()
					word.Paint = function(self, w, h)
						if self.counter%2 == 0 then
							draw_roundedbox(0, 0, 0, w, h, lineBreak)
						end
						draw_simpletext(self.word, "NoSay.Main.Static", 10, h*0.5, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
						draw_simpletext((isstring(self.replace) and self.replace) or noSayBlacklist.Translate.BlacklistNoReplacement, "NoSay.Main.Static", w*0.33, h*0.5, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					end
					shadeCounter = shadeCounter + 1
				end

			local tableHeaders = vgui.Create("DPanel", shell)
			tableHeaders:Dock(TOP)
			tableHeaders:SetTall(30)
			tableHeaders.Paint = function(self, w, h)
				draw_simpletext(noSayBlacklist.Translate.BlacklistWordTitle, "NoSay.Main.Static", 10, h*0.5, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw_simpletext(noSayBlacklist.Translate.BlacklistReplacementTitle, "NoSay.Main.Static", w*0.33, h*0.5, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw_simpletext(noSayBlacklist.Translate.BlacklistActionTitle, "NoSay.Main.Static", w*0.66, h*0.5, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw_roundedbox(0, 10, h-2, w-15, 2, lineBreak)
			end

			for k, v in pairs(noSayBlacklist.Core.Words) do
				local word = vgui.Create("DPanel", shell)
				word:SetTall(30)
				word:Dock(TOP)
				word.counter = shadeCounter
				word.Paint = function(self, w, h)
					if self.counter%2 == 0 then
						draw_roundedbox(0, 0, 0, w, h, lineBreak)
					end
					draw_simpletext(k, "NoSay.Main.Static", 10, h*0.5, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					draw_simpletext((isstring(v) and v) or noSayBlacklist.Translate.BlacklistNoReplacement, "NoSay.Main.Static", w*0.33, h*0.5, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end

				local remove = vgui.Create("DButton", word)
				remove:Dock(RIGHT)
				remove:SetSize(word:GetTall(), word:GetTall())
				remove:SetText("")
				remove.animationLerp = 0
				remove.Paint = function(self, w, h)
					if self:IsHovered() then
						self.animationLerp = Lerp(0.1, self.animationLerp, 1)
					else
						self.animationLerp = Lerp(0.1, self.animationLerp, 0)
					end

					draw_notexture()
					surface_setdrawcolor(200 - (self.animationLerp*55), 0, 0, 255)
					noSayBlacklist.UI.DrawCircle(w*0.5, h*0.5, w*0.2, 1)
				end
				remove.DoClick = function()
					net.Start("nosay_admin_words_remove")
						net.WriteString(k)
					net.SendToServer()
					word:Remove()
				end

				shadeCounter = shadeCounter + 1
			end
		end)
	end
end