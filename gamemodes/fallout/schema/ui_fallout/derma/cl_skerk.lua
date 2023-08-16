local PANEL = {}
	local w, h = ScrW(), ScrH()

	function PANEL:Init()
		w, h = ScrW(), ScrH()
		self:SetSize(w * .4, h * .544)
		self:Center()
		self:MakePopup()

		if (IsValid(nut.gui.skerk)) then
			nut.gui.skerk:Remove()
		end;

		nut.gui.skerk = self

		scroll = self:Add("UI_DScrollPanel")
			scroll:Dock(FILL)

		self:reload()
	end;

	function PANEL:reload()
		scroll:Clear()
		self:SetDisabled(false)

		local char = LocalPlayer():getChar()

		local skerks = char:getData("skerks", {})
		local level = char:getData("level", 0)
		local points = char:getData("skillPoints", 0)
		local specs = {["S"] = {"Strength", 1}, ["P"] = {"Perception", 2}, ["E"] = {"Endurance", 3}, ["C"] = {"Carisma", 4}, ["I"] = {"Intelligence", 5}, ["A"] = {"Agility", 6}, ["L"] = {"Luck", 7}}
		local special = char:getData("special", nut.skerk.special)
		--PrintTable(skerks)
		local tooltips = {}

		local sixW = w * .003125
		local sixH = h * .0055

		local curW = w * .00625
		local curH = h * .011
		for i, v in pairs(nut.skerk.skerks) do
			local nextTier = skerks[i] or 0
			nextTier = nextTier + 1

			local t = scroll:Add("UI_DPanel_Bordered")
				t:Dock(TOP)
				t:SetHeight(h * .1)
				t:DockMargin(0, 0, w * .0104, h * .0111 ) //h * .0111)
				t.Paint = function(p, w, h)
					surface.SetDrawColor(nut.gui.palette.color_background)
					surface.DrawRect(0, 0, w, h)

					--DisableClipping(true)
					surface.SetDrawColor(Color(0, 0, 0))
					surface.DrawOutlinedRect(2, 2, w - 1, h - 1)

					surface.SetDrawColor(nut.gui.palette.color_primary)
					surface.DrawOutlinedRect(0, 0, w, h)
					surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
					--DisableClipping(false)
				end;

				local top = t:Add("DPanel")
					top:Dock(TOP)
					top:SetHeight(h * .0592)
					top:SetPaintBackground(false)
					local icon = top:Add("nutSpawnIcon")
						icon:Dock(LEFT)
						icon:SetSize(w * .028, h * .05)
						icon:DockMargin(sixW, sixH, sixW, sixH)
						icon:SetModel(v["model"] or "models/hunter/blocks/cube025x025x025.mdl")
						tooltips[i] = vgui.Create("UI_DPanel_Bordered")
							tooltips[i]:SetSize(w * 0.2666, h * 0.355)
							tooltips[i]:DockPadding(sixW, sixH, sixW, sixH)
							tooltips[i].Think = function() if (!IsValid(nut.gui.skerk)) then tooltips[i]:Remove() end; end;
							tooltips[i].Paint = function(p, w, h)
								surface.SetDrawColor(ColorAlpha(nut.gui.palette.color_background, 255))
								surface.DrawRect(0, 0, w, h)

								DisableClipping(true)
								surface.SetDrawColor(Color(0, 0, 0))
								surface.DrawOutlinedRect(2, 2, w - 1, h - 1)

								surface.SetDrawColor(nut.gui.palette.color_primary)
								surface.DrawOutlinedRect(0, 0, w, h)
								surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
								DisableClipping(false)
							end;
							tooltips[i].text = tooltips[i]:Add("UI_DLabel")
								tooltips[i].text:Dock(FILL)
								tooltips[i].text:SetContentAlignment(7)
								tooltips[i].text:SetWrap(true)
								tooltips[i].text:SetText(v["desc"].."\n" or "unknown".."\n")
						icon.Think = function()
							if (icon:IsHovered()) then
								local cX, cY = input.GetCursorPos()
								tooltips[i]:SetPos(cX + curW, cY + curH)
								tooltips[i]:SetVisible(true)
							else
								tooltips[i]:SetVisible(false)
							end;
						end;
					local info = top:Add("DPanel")
						info:Dock(FILL)
						info:DockMargin(0, sixH, sixW, sixH)
						info:SetPaintBackground(false)
						local title = info:Add("UI_DLabel")
							title:Dock(TOP)
							title:SetText(v["title"].." [Level "..(skerks[i] or 0).."]" or "unknown")
							title:SizeToContentsY()
						local desc = info:Add("UI_DLabel")
							desc:Dock(BOTTOM)
							desc:SetText(v["desc"] or "unknown")
							desc:SizeToContentsY()
				local bottom = t:Add("DPanel")
					bottom:Dock(BOTTOM)
					bottom:SetHeight(h * .0407)
					bottom:DockPadding(sixW, sixH, sixW, sixH)
					bottom:SetPaintBackground(false)
					local unlock = bottom:Add("UI_DButton")
						unlock:Dock(BOTTOM)
						unlock:SetContentAlignment(5)

						local failed = false

						for x, y in ipairs(v["tiers"]) do
							tooltips[i].text:SetText(tooltips[i].text:GetText().."\nLevel "..x.." Benefit:\n"..(v["tiers"][x]["desc"] or "NoDesc").."\n")
						end;

						if (nextTier <= #v["tiers"]) then
							if (!skerks[i]) then
								unlock:SetText("Unlock Skill" .." ["..v["tiers"][nextTier]["points"] .. " Point Cost]")
							else
								unlock:SetText("Upgrade Skill" .." ["..v["tiers"][nextTier]["points"] .. " Point Cost]")
							end;

							unlock.Think = function()
								if (unlock:IsHovered()) then
									local cX, cY = input.GetCursorPos()
									tooltips[i]:SetPos(cX + curW, cY + curH)
									tooltips[i]:SetVisible(true)
								else
									tooltips[i]:SetVisible(false)
								end;
							end;

							tooltips[i].text:SetText(tooltips[i].text:GetText().."\nRequirements For Upgrade:\n  - "..v["tiers"][nextTier]["points"].." Skill Points\n")
							if (points < v["tiers"][nextTier]["points"]) then
								unlock:SetText(unlock:GetText().." ["..v["tiers"][nextTier]["points"] - points.." More Points Required]")
								failed = true
							end;

							tooltips[i].text:SetText(tooltips[i].text:GetText().."  - Character Level "..v["tiers"][nextTier]["level"].."\n")
							if (level < v["tiers"][nextTier]["level"]) then
								unlock:SetText(unlock:GetText().." [Level "..v["tiers"][nextTier]["level"].." Required]")
								failed = true
							end;

							if (v["tiers"][nextTier]["prerequisite"]) then
								local missing = false

								for x, y in pairs(v["tiers"][nextTier]["prerequisite"]) do
									tooltips[i].text:SetText(tooltips[i].text:GetText().."  - "..nut.skerk.skerks[x]["title"].." [Level "..y.."]\n")
									if (!skerks[x]) then
										missing = true
									end;
								end;

								if (missing) then
									unlock:SetText(unlock:GetText().." [Missing Skill]")
									failed = true
								end;
							end;

							if (v["tiers"][nextTier]["special"]) then
								tooltips[i].text:SetText(tooltips[i].text:GetText().."\n")
								for x, y in pairs(v["tiers"][nextTier]["special"]) do
									special[x] = special[x] or 0
									tooltips[i].text:SetText(tooltips[i].text:GetText().."  - "..specs[x][1]..": "..y.."\n")
									if (special[x] < y) then
										failed = true
									end;
								end;
							end;
						else
							unlock:SetText("Maxed Out")
							failed = true
						end;

						if (failed) then
							unlock:SetDisabled(true)
						else
							unlock.DoClick = function()
								local succ, error = netstream.Start("nutSkerkUpgrade", i)
								self:SetDisabled(true)
								--if (error) then
								--	Derma_Message("Skill Purchased Failed: "..error, "Error", "OK")
								--elseif (succ) then
									Derma_Message((v["title"] or "unknown").." Has been upgrade to Level "..nextTier.."!", "Complete", "OK")
									surface.PlaySound("ui/levelup.mp3")
								--else
								--	Derma_Message("Skill Purchase Could Not Be Processed", "Error", "OK")
								--end;
								timer.Simple(1, function() self:reload() end)
							end;
						end;
		end;
	end;

vgui.Register("nutSkerk", PANEL, "DPanel")
