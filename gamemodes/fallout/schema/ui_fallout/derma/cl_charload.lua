local PANEL = {}
	function PANEL:Init()
		if (IsValid(nut.gui.charLoad)) then
			nut.gui.charLoad:Remove()
		end

		nut.gui.charLoad = self

		self:Dock(FILL)
		self:MakePopup()
		self:Center()
		self:ParentToHUD()

		characters = self:Add("UI_DFrame")
			characters:SetTitle("CHARACTERS")
			characters:SetPos(ScrW() * 0.2, ScrH() - (ScrH() * 0.2 + sH() * 0.45) - 24)
			characters:SetSize(256, (sH() * 0.45) + 24)

			characterScroll = characters:Add("DScrollPanel")
				characterScroll:Dock(FILL)
				characterScroll:DockMargin(0, 0, 0, 12)

			cancel = characters:Add("UI_DButton")
				cancel:Dock(BOTTOM)
				cancel:SetText("  RETURN")
				cancel.DoClick = function()
					if (IsValid(info)) then info:SetDisabled(true) end;
					characters:SetDisabled(true)
					fadeOut(function()
						vgui.Create("nutCharMenu"):open()
						self:Remove()
					end)
				end;

			active = LocalPlayer():getChar()
			if (active) then active = active:getID() else active = 0 end;

			for i, v in ipairs(nut.characters) do
				local character = nut.char.loaded[v]

				local button = characterScroll:Add("UI_DButton")
					button:Dock(TOP)
					button:DockMargin(0, 0, 0, 12)
					button:SetText("  "..character.vars.name:upper())
					if (character.id == active) then button:SetDisabled(true) end;
					button.DoClick = function()
						self:infoBoard(character)
					end;
			end;

		fadeIn()
	end;

	function PANEL:infoBoard(character)
		if (info) then info:Remove() end;

		local faction = nut.faction.teams[character.vars.faction] or {name = "unknown"}

		info = self:Add("UI_DFrame")
			local fX, fY = characters:GetPos()
			info:SetPos(fX + characters:GetWide() + 12, fY)
			info:SetSize(536, (sH() * 0.45) + 24)
			info:SetTitle(character.vars.name:upper().." ❱❱ "..faction.name:upper())

			texture = info:Add("UI_DTexture")
				texture:Dock(TOP)
				texture:SetTall(256)
				texture:SetTexture(faction.image or "fallout/ui/factions/default.png")
				texture:SetBordered(true)

			desc = info:Add("UI_DLabel")
				desc:Dock(FILL)
				desc:DockMargin(0, 6, 0, 0)
				desc:SetContentAlignment(7)
				desc:SetWrap(true)
				desc:SetText(character.vars.desc or "This character does not have a description.")

			delete = info:Add("UI_DButton")
				delete:Dock(BOTTOM)
				delete:DockMargin(0, 6, 0, 0)
				delete:SetContentAlignment(5)
				delete:SetText("DELETE CHARACTER")
				delete.DoClick = function()
					Derma_Query("Are you sure you want to delete this character?\n(this action cannot be undone)", "Are you sure?", "Yes", function()
						netstream.Start("charDel", character.id)
						info:SetDisabled(true)
						characters:SetDisabled(true)

						fadeOut(function()
							vgui.Create("nutCharLoad")
						end)
					end, "No", function() return end)
				end;

			pick = info:Add("UI_DButton")
				pick:Dock(BOTTOM)
				pick:DockMargin(0, 6, 0, 0)
				pick:SetContentAlignment(5)
				pick:SetText("LOAD CHARACTER")
				pick.DoClick = function()
					local status, result = hook.Run("CanPlayerUseChar", LocalPlayer(), character)

					if (status == false) then
						if (result:sub(1, 1) == "@") then
							Derma_Message("Error: "..result:sub(2), nil, "OK")
						else
							Derma_Message("Error: "..result, nil, "OK")
						end;

						return
					end;

					netstream.Hook("charLoaded", function()
						if (active != character.id) then
							hook.Run("CharacterLoaded", character)
						else
							Derma_Message("You are already using this character.", nil, "OK")
							return
						end
					end)

					info:SetDisabled(true)
					characters:SetDisabled(true)

					fadeOut(function()
						netstream.Start("charChoose", character.id)
						self:fadeMusic()
						self:Remove()
						fadeIn()
					end)
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

	function PANEL:Paint(w, h)
		surface.SetDrawColor(0, 0, 0, 235)
		surface.DrawRect(0, 0, w, h)
	end;

vgui.Register("nutCharLoad", PANEL, "EditablePanel")
