local PANEL = {}
local w, h = ScrW(), ScrH()

	function PANEL:Init()
		w, h = ScrW(), ScrH()
		self:SetSize(w * .4, h * .489)
		self:Center()
		self:MakePopup()

		if (IsValid(nut.gui.special)) then
			nut.gui.special:Remove()
		end;

		nut.gui.special = self

		scroll = self:Add("UI_DScrollPanel")
			scroll:Dock(FILL)

		self:reload()
	end;

	function PANEL:reload()
		scroll:Clear()
		self:SetDisabled(false)
        self.assigning = false

		local char = LocalPlayer():getChar()

		local specs = {["S"] = {"Strength", 1}, ["P"] = {"Perception", 2}, ["E"] = {"Endurance", 3}, ["C"] = {"Charisma", 4}, ["I"] = {"Intelligence", 5}, ["A"] = {"Agility", 6}, ["L"] = {"Luck", 7}}
		local data = char:getData("special", nut.skerk.special)
		local points = char:getData("skillPoints", 0)

		for i, v in SortedPairsByMemberValue(specs, 2) do
			data[i] = data[i] or 0

			local t = scroll:Add("UI_DPanel_Bordered")
				t:Dock(TOP)
				t:SetHeight(h * .0592)
				t:DockMargin(0, 0, 0, h * .01111)
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

				local letter = t:Add("UI_DLabel")
					letter:Dock(LEFT)
					letter:SetContentAlignment(5)
					letter:SetWidth(w * .0333)
					letter:SetFont("UI_Medium")
					letter:SetText(i)

				local title = t:Add("UI_DLabel")
					title:Dock(LEFT)
					title:SetContentAlignment(4)
					title:SetWidth(w * .0666)
					title:SetText(v[1])

				local stat = t:Add("UI_DLabel")
					stat:Dock(LEFT)
					stat:SetContentAlignment(5)
					stat:SetWidth(w * .0333)
					stat:SetText(data[i])
					stat:SetFont("UI_Medium")

				local assign = t:Add("UI_DButton")
					assign:DockMargin(w * .00625, h * .01111, w * .00625, h * .01111)
					assign:Dock(RIGHT)
					assign:SetContentAlignment(5)
					assign:SetText("Assign")
                    assign:SizeToContents()
                    assign.Think = function()
                        if self.assigning then
                            assign:SetDisabled(true)
                        end
                    end
					assign.DoClick = function()
                        if self.assigning then return end
                        self.assigning = true
						surface.PlaySound("shelter/jingle/emergency_succes.ogg")
						LocalPlayer():ScreenFade(SCREENFADE.IN, Color(255, 255, 255, 60), 0.5, 0)
						netstream.Start("nutSkerkUpgradeSpecial", i)
						timer.Simple(.5, function()
							if IsValid(self) then
								self:reload()
							end
						end)
					end;

					if (points < 1 or data[i] >= 25) then
						assign:SetDisabled(true)
					end;

					if (table.HasValue(nut.skerk.specialDis, i)) then
						assign:SetDisabled(true)
						stat:SetText("-")
					end;
		end;
	end;

vgui.Register("nutSpecial", PANEL, "DPanel")