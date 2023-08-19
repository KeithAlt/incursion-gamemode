local PANEL = {}
	function PANEL:Init()
		if (IsValid(nut.gui.intro)) then
			nut.gui.intro:Remove()
		end

		if (IsValid(nut.gui.char)) then
			nut.gui.char:Hide()
		end;

		if (nut.menuSound) then
			nut.menuSound:Stop()
			nut.menuSound = nil
		end;

		self:SetSkin("uitwo")

		slide = 0
		music = "https://www.dropbox.com/s/dgsu0dyd7qtmnl7/Fallout%204%20Trailer%20Theme%20Orchestral%20Remix.mp3?dl=1"

		nut.gui.intro = self

		self:SetSize(ScrW(), ScrH())
		self:SetZPos(9999)

		black = self:Add("DPanel")
			black:Dock(FILL)
			black:SetPaintBackground(false)
			black.Paint = function(this)
				surface.SetDrawColor(0, 0, 0, this:GetAlpha())
				surface.DrawRect(0, 0, this:GetWide(), this:GetTall())
			end;

		wait = black:Add("DLabel")
			wait:Dock(BOTTOM)
			wait:SetTall(42)
			wait:DockMargin(0, 0, 0, 32)
			wait:SetText("press space to continue...")
			wait:SetFont("falloutBold")
			wait:SetContentAlignment(2)
			wait:SetAlpha(0)

			wait:AlphaTo(255, 1, 0, function()
				wait.Paint = function(this)
					this:SetAlpha(math.abs(math.cos(RealTime() * 0.8) * 255))
				end
			end)

			wait:SetExpensiveShadow(1, color_black)

		slides = {
			[1] = function()
				local logo = self:Add("DHTML")
					logo:SetSize(1024, 256)
					logo:SetPos((ScrW() / 2) - (logo:GetWide() / 2), (ScrH() / 2) - (logo:GetTall() / 2))
					logo:SetHTML([[<body style="margin: 0; padding: 0; overflow: hidden;"><img src="https://i.imgur.com/DaCNrsV.png" width="]]..logo:GetWide()..[[" height="]]..logo:GetTall()..[[" /></body>]])

				timer.Simple(5, function()
					logo:Remove()
					self:nextSlide()
				end)
			end,

			[2] = function()
				local logo = self:Add("DHTML")
					logo:SetSize(1026, 199)
					logo:SetPos((ScrW() / 2) - (logo:GetWide() / 2), (ScrH() / 2) - (logo:GetTall() / 2))
					logo:SetHTML([[<body style="margin: 0; padding: 0; overflow: hidden;"><img src="https://i.imgur.com/q5zfBud.png" width="]]..logo:GetWide()..[[" height="]]..logo:GetTall()..[[" /></body>]])

				timer.Simple(5, function()
					logo:Remove()
					self:nextSlide()
				end)
			end,

			[3] = function()
				local logo = self:Add("DHTML")
					logo:SetSize(1024, 256)
					logo:SetPos((ScrW() / 2) - (logo:GetWide() / 2), (ScrH() / 2) - (logo:GetTall() / 2))
					logo:SetHTML([[<body style="margin: 0; padding: 0; overflow: hidden;"><img src="https://i.imgur.com/FnyAf3T.png" width="]]..logo:GetWide()..[[" height="]]..logo:GetTall()..[[" /></body>]])

				timer.Simple(5, function()
					logo:Remove()
					self:nextSlide()
				end)
			end,

			[4] = function()
				black:AlphaTo(0, 2, 3)

				local title = self:Add("DLabel")
					title:SetPos(ScrW() * 0.1, ScrH() * 0.5)
					title:SetSize(ScrW(), 42)
					title:SetText("CLAYMORE GAMING PRESENTS")
					title:SetFont("falloutBig")
					title:SetExpensiveShadow(1, Color(0, 0, 0))
					title:SetAlpha(0)
					title:AlphaTo(255, 3)
					title:AlphaTo(0, 3, 7, function()
						title:Remove()

						timer.Simple(0, function()
							logo:Remove()
							self:nextSlide()
						end)
					end)

				--timer.Simple(16, function() self:fadeMusic() end)
			end,

			[5] = function()
				local logo = self:Add("DHTML")
					logo:SetSize(820, 300)
					logo:SetAlpha(0)
					logo:AlphaTo(255, 3)
					logo:SetPos((ScrW() / 2) - (logo:GetWide() / 2), (ScrH() / 2) - (logo:GetTall() / 2))
					logo:SetHTML([[<body style="margin: 0; padding: 0; overflow: hidden;"><img src="https://i.imgur.com/QSi2FaA.png" width="]]..logo:GetWide()..[[" height="]]..logo:GetTall()..[[" /></body>]])

				timer.Simple(5, function()
					logo:Remove()
					self:nextSlide()
				end)
			end,



		}
	end;

	function PANEL:nextSlide()
		slide = slide + 1

		if (slide > #slides) then
			if (IsValid(nut.gui.char)) then
				nut.gui.char:SetAlpha(0)
				nut.gui.char:Show()
				nut.gui.char:AlphaTo(255, 3, 0, function()
					self:Remove()
				end)
			end;
		else
			slides[slide]()
		end;
	end;

	function PANEL:Think()
		if (IsValid(wait) and input.IsKeyDown(KEY_SPACE) and !self.playing) then
			wait:AlphaTo(0, 1, 0, function()

				timer.Simple(0, function() -- Added to prevent a think func multi-call bug, by Keith
					if self.playing then return end
					self.playing = true
					wait:Remove()
					self:playSound(music)
					self:nextSlide()
				end)
			end)
		end;
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

	function PANEL:OnRemove()
		if (IsValid(nut.gui.char)) then
			--nut.gui.char:playMusic()
		end;
	end;

vgui.Register("nutIntro", PANEL, "EditablePanel")
