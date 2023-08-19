local PANEL = {}
	function PANEL:Init()
		if (IsValid(nut.gui.charCreate)) then
			nut.gui.charCreate:Remove()
		end

		nut.gui.charCreate = self

		self:Dock(FILL)
		self:MakePopup()
		self:Center()
		self:ParentToHUD()

		self:factionSelect()

		fadeIn()
	end

	function PANEL:factionSelect()
		factions = self:Add("UI_DFrame")
			factions:SetTitle("CHOOSE FACTION")
			factions:SetPos(ScrW() * 0.2, ScrH() - (ScrH() * 0.2 + sH() * 0.45) - 24)
			factions:SetSize(256, (sH() * 0.45) + 24)

			factionScroll = factions:Add("DScrollPanel")
				factionScroll:Dock(FILL)
				factionScroll:DockMargin(0, 0, 0, 12)

			cancel = factions:Add("UI_DButton")
				cancel:Dock(BOTTOM)
				cancel:SetText("  RETURN")
				cancel.DoClick = function()
					fadeOut(function()
						vgui.Create("nutCharMenu"):open()
						self:Remove()
					end)
				end

			for i, v in pairs(nut.faction.indices) do
				if (nut.faction.hasWhitelist(v.index)) then
					local button = factionScroll:Add("UI_DButton")
						button:Dock(TOP)
						button:DockMargin(0, 0, 0, 12)
						button:SetText("  "..v.name:upper())
						button.DoClick = function()
							self:infoBoard(i, v)
						end
				end
			end
	end

	function PANEL:infoBoard(faction, dat)
		if (info) then info:Remove() end;

		info = self:Add("UI_DFrame")
			local fX, fY = factions:GetPos()
			info:SetPos(fX + factions:GetWide() + 12, fY)
			info:SetSize(536, (sH() * 0.45) + 24)
			info:SetTitle(dat.name:upper())

			texture = info:Add("UI_DTexture")
				texture:Dock(TOP)
				texture:SetTall(256)
				texture:SetTexture(dat.image or "fallout/ui/factions/default.png")
				texture:SetBordered(true)

			desc = info:Add("UI_DLabel")
				desc:Dock(FILL)
				desc:DockMargin(0, 6, 0, 0)
				desc:SetContentAlignment(7)
				desc:SetWrap(true)
				desc:SetText(dat.desc or "This faction does not have a description.")

			pick = info:Add("UI_DButton")
				pick:Dock(BOTTOM)
				pick:DockMargin(0, 6, 0, 0)
				pick:SetContentAlignment(5)
				pick:SetText("CHOOSE FACTION")
				pick.DoClick = function()
					if !Armor or Armor.Config.UseOldCharCreation[dat.uniqueID] then
						fadeOut(function()
							vgui.Create("nutCharBuilder"):open(faction)
							self:Remove()
						end)
					else
						fadeOut(function()
							local p = vgui.Create("CharacterCustomization")
							p:MakePopup()
							p.NSData.faction = faction

							self:Remove()

							fadeIn()
						end)
					end

					surface.PlaySound("ui/ui_experienceup.mp3")
				end
	end

	function PANEL:Paint(w, h)
		surface.SetDrawColor(0, 0, 0, 235)
		surface.DrawRect(0, 0, w, h)
	end

vgui.Register("nutCharCreate", PANEL, "EditablePanel")
