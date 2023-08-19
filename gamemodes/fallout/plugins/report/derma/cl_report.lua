local PANEL = {}
	function PANEL:Init()
		self:SetSize(790, 512)
		self:Center()
		self:MakePopup()

		t1Values = {faction, money}
		t1Data = {xp, f}
	end;

	function PANEL:populate(data)
		data = data

		self:SetTitle("Report Card")

		self:DockPadding(1, 24, 1, 1)

		sheet = self:Add("DPropertySheet")
			sheet:Dock(FILL)

		for i, v in pairs(data) do
			local panel = vgui.Create("DPanel")
				local p1 = panel:Add("DPanel")
					p1:Dock(LEFT)
					p1:SetWidth(512)
					p1:DockMargin(0, 0, 4, 0)
					t1 = p1:Add("DTextEntry")
						t1:Dock(FILL)
						t1:SetMultiline(true)
						for x, y in pairs(v.data) do
							if (!istable(y)) then
								t1:SetText(t1:GetText()..x..": "..tostring(y).."\n")
							end
						end
						for x, y in pairs(v.data.data) do
							if (istable(y)) then
								t1:SetText(t1:GetText()..x..": "..table.ToString(y).."\n")
							else
								t1:SetText(t1:GetText()..x..": "..tostring(y).."\n")
							end
						end
				local p2 = panel:Add("DPanel")
					p2:Dock(LEFT)
					p2:SetWidth(256)
					p2:DockMargin(0, 0, 4, 0)
					t2 = p2:Add("DTextEntry")
						t2:Dock(FILL)
						t2:SetMultiline(true)
						if (v.inv) then
							t2:SetText("Inventory:\n")
							for x, y in pairs(v.inv) do
								t2:SetText(t2:GetText()..y.."\n")
							end
						end
						if (v.stash) then
							t2:SetText(t2:GetText().."Stash:\n")
							for x, y in pairs(v.stash) do
								t2:SetText(t2:GetText()..y.."\n")
							end
						end

			local tab = sheet:AddSheet(v.data.name, panel, nil, false, false)
		end
	end;

vgui.Register("nutReport", PANEL, "DFrame")
