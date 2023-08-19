function Derma_Message(text, title, button)
	local window = vgui.Create("UI_DFrame")
		window:MakePopup()
		window:SetSize(ScrW(), ScrH())
		window:SetTitle(" ")
		window.Paint = function(p, w, h)
			nut.util.drawBlur(p, 5)
			surface.SetDrawColor(0, 0, 0, 235)
			surface.DrawRect(0, 0, w, h)
		end;

		text = string.Split(text, "\n")

		local x = 0

		local t = window:Add("UI_DPanel_Bordered")
			t:DockPadding(0, 12, 0, 0)

			for i, v in pairs(text) do
				local txt = t:Add("UI_DLabel")
					txt:Dock(TOP)
					txt:DockMargin(12, 0, 12, 0)
					txt:SetContentAlignment(5)
					txt:SetFont("UI_Bold")
					txt:SetText(v or "Default Text")
					txt:SizeToContents()

					x = x + txt:GetTall()
			end;

			local bttn = t:Add("UI_DButton")
				bttn:Dock(BOTTOM)
				bttn:DockMargin(12, 12, 12, 12)
				bttn:SetContentAlignment(5)
				bttn:SetText(button or "OK")
				bttn.DoClick = function()
					window:Remove()
				end;

			t:SetSize(640, x + 72)
			t:SetPos((ScrW() * 0.5) - 320, (ScrH() * 0.5) - (t:GetTall() * 0.5))
end;

function Derma_Query(text, title, ...)
	local window = vgui.Create("UI_DFrame")
		window:MakePopup()
		window:SetSize(ScrW(), ScrH())
		window:SetTitle(" ")
		window.Paint = function(p, w, h)
			nut.util.drawBlur(p, 5)
			surface.SetDrawColor(0, 0, 0, 235)
			surface.DrawRect(0, 0, w, h)
		end;

		text = string.Split(text, "\n")

		local x = 0

		local t = window:Add("UI_DPanel_Bordered")
			t:DockPadding(0, 12, 0, 0)

			for i, v in pairs(text) do
				local txt = t:Add("UI_DLabel")
					txt:Dock(TOP)
					txt:DockMargin(12, 0, 12, 0)
					txt:SetContentAlignment(5)
					txt:SetFont("UI_Bold")
					txt:SetText(v or "Default Text")
					txt:SizeToContents()

					x = x + txt:GetTall()
			end;

			local buttns = t:Add("DPanel")
				buttns:Dock(BOTTOM)
				buttns:SetHeight(32)
				buttns:DockMargin(12, 12, 12, 12)
				buttns:SetPaintBackground(false)

			local total = 0

			for k = 1, 8, 2 do
				local Text = select(k, ...)
				if (Text == nil) then break end;

				local Func = select(k + 1, ...) or function() end;

				total = total + 1
			end;

			for k = 1, 8, 2 do
				local Text = select(k, ...)
				if (Text == nil) then break end;

				local Func = select(k + 1, ...) or function() end;

				local bttn = buttns:Add("UI_DButton")
					bttn:Dock(LEFT)
					bttn:SetWidth((640 - 24) / total)
					bttn:SetContentAlignment(5)
					bttn:SetText(Text)
					bttn.DoClick = function()
						window:Remove()
						Func()
					end;
			end;

			t:SetSize(640, x + 72)
			t:SetPos((ScrW() * 0.5) - 320, (ScrH() * 0.5) - (t:GetTall() * 0.5))
end;
