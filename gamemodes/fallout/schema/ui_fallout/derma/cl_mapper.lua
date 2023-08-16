local PANEL = {}
	function PANEL:Init()
		if (IsValid(nut.gui.mapper)) then
			nut.gui.mapper:Remove()
		end;

		nut.gui.mapper = self

		self:Dock(FILL)
		self:MakePopup()
		self:Center()

		vals = {a = {pitch = 0, yaw = 0, roll = 0}, o = {x = 0, y = 0, z = 0}}

		map = self:Add("DPanel")
			map:SetSize(ScrH(), ScrH())
			map.Paint = function(p, w, h)
				render.RenderView({
					origin = Vector(vals["o"]["x"], vals["o"]["y"], vals["o"]["z"]),
					angles = Angle(vals["a"]["pitch"], vals["a"]["yaw"], vals["a"]["roll"]),
					x = vals["x"], y = vals["y"],
					w = w, h = h,
					zfar = false, znear = false
				})
			end;

			values = self:Add("DPanel")
				values.Paint = function(p, w, h)
					surface.SetDrawColor(0, 0, 0, 230)
					surface.DrawRect(0, 0, w, h)
				end;
				values:DockPadding(24, 0, 0, 0)
				values:Dock(RIGHT)
				values:SetWidth(512)
				for i, v in pairs(vals["a"]) do
					local t = values:Add("DNumSlider")
						t:Dock(TOP)
						t:SetText("Angles: "..i)
						t:SetMax(360)
						t:SetDecimals(0)
						t.OnValueChanged = function(p, value)
							vals["a"][i] = value
						end;
				end;
				for i, v in pairs(vals["o"]) do
					local t = values:Add("DNumSlider")
						t:Dock(TOP)
						t:SetText("Origin: "..i)
						t:SetMax(100000)
						t:SetDecimals(0)
						t.OnValueChanged = function(p, value)
							vals["o"][i] = value
						end;
				end;
	end;

	function PANEL:Paint(w, h)
		surface.SetDrawColor(255, 255, 255)
		surface.DrawRect(0, 0, w, h)
	end;

	vgui.Register("nutDevMapper", PANEL, "EditablePanel")

concommand.Add("dev_mapper", function()
	if (IsValid(nut.gui.mapper)) then
		nut.gui.mapper:Remove()
	else
		vgui.Create("nutDevMapper")
	end;
end)
