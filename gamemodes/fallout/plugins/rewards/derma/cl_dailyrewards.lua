
local PANEL = {}
function PANEL:Init()
	if (nut.gui.dailyrewards) then
		nut.gui.dailyrewards:Remove()
	end;

	nut.gui.dailyrewards = self
	
	local w, h = ScrW(), ScrH()

	self:Dock(FILL)
	self:MakePopup()
	self:Center()
	self:ParentToHUD()

	exit = self:Add("UI_DButton")
		exit:SetText("Exit")
		exit:SetContentAlignment(5)
		exit:SetWide(w * 0.389)
		exit.DoClick = function() self:Remove() end;

	rewards = self:Add("UI_DPanel_Bordered")
		rewards:SetSize(w * 0.389, h * 0.825)
		rewards:DockPadding(w * .025, h * .0444, w * .025, h * .0444)
		rewards:SetPos((ScrW() * 0.5) - rewards:GetWide() / 2, (ScrH() * 0.5) - rewards:GetTall() / 2)

		prizes = nut.rewards

		local c = 0
		local day = LocalPlayer():getNutData("rewardDay", 1)

		for z = 1, 6 do
			local i = rewards:Add("DPanel")
				i:Dock(TOP)
				i:DockMargin(0, 0, 0, w * .025)
				i:SetHeight(h * .0851)
				i:SetPaintBackground(false)

				for n = 1, 5 do
					c = c + 1
					local m = c

					local x = i:Add("UI_DPanel_Bordered")
						if (z % 2 == 0) then
							x:Dock(RIGHT)
							x:DockMargin(w * .025, 0, 0, 0)
						else
							x:Dock(LEFT)
							x:DockMargin(0, 0, h * .0444, 0)
						end;

						x:SetSize(w * .0479, h * .0851)
						x.Paint = function(p, w, h)
							surface.SetDrawColor(nut.gui.palette.color_background)
							surface.DrawRect(0, 0, w, h)

							DisableClipping(true)
							if (m == day) then
								-- Shadow
								surface.SetDrawColor(Color(0, 0, 0))
								surface.DrawRect(1, 1, 2, h) 					-- Left
								surface.DrawRect(1, 1, 6, 2) 					-- Left Upper
								surface.DrawRect(1, h - 1, 6, 2) 			-- Left Lower
								surface.DrawRect(w - 1, 1, 2, h) 			-- Right
								surface.DrawRect(w - 5, 1, 6, 2) 			-- Right Upper
								surface.DrawRect(w - 5, h - 1, 6, 2) 	-- Right Lower

								-- Top Lines
								surface.SetDrawColor(nut.gui.palette.color_primary)
								surface.DrawRect(0, 0, 2, h) 					-- Left
								surface.DrawRect(0, 0, 6, 2) 					-- Left Upper
								surface.DrawRect(0, h - 2, 6, 2) 			-- Left Lower
								surface.DrawRect(w - 2, 0, 2, h) 			-- Right
								surface.DrawRect(w - 6, 0, 6, 2) 			-- Right Upper
								surface.DrawRect(w - 6, h - 2, 6, 2) 	-- Right Lower
							else
								surface.SetDrawColor(Color(0, 0, 0))
								surface.DrawOutlinedRect(2, 2, w - 1, h - 1)

								surface.SetDrawColor(nut.gui.palette.color_primary)
								surface.DrawOutlinedRect(0, 0, w, h)
								surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
							end;

							if (n != 5) then
								if (z % 2 == 0) then
									surface.SetDrawColor(Color(0, 0, 0))
									surface.DrawRect(0, (h / 2), -48, 2)
									surface.SetDrawColor(nut.gui.palette.color_primary)
									surface.DrawRect(0, (h / 2) - 1, -48, 2)
								else
									surface.SetDrawColor(Color(0, 0, 0))
									surface.DrawRect(w, (h / 2), 48, 2)
									surface.SetDrawColor(nut.gui.palette.color_primary)
									surface.DrawRect(w, (h / 2) - 1, 48, 2)
								end;
							end;

							if (n == 5 and z != 6) then
								surface.SetDrawColor(Color(0, 0, 0))
								surface.DrawRect((w / 2), h, 2, 48)
								surface.SetDrawColor(nut.gui.palette.color_primary)
								surface.DrawRect((w / 2) - 1, h, 2, 48)
							end;

							draw.SimpleText(m, "UI_Regular", w - 5, h - 23, Color(0, 0, 0), 2, 0)
							draw.SimpleText(m, "UI_Regular", w - 6, h - 24, nut.gui.palette.color_primary, 2, 0)
							DisableClipping(false)
						end;

					local r = x:Add("nutSpawnIcon")
						r:Dock(FILL)
						r:DockMargin(4, 4, 4, 4)
						if (prizes[m].type == 1) then
							if (nut.item.list[prizes[m].item]) then
								r:SetModel(nut.item.list[prizes[m].item].model)
							else
								r:SetModel("models/Lamarr.mdl")
							end
						else
							r:SetModel("models/props_junk/cardboard_box004a.mdl")
						end;

						if (m == day) then
							r.DoClick = function()
								netstream.Start("nutUnlockReward")
								self:Remove()
							end;
						end;
				end;
		end;

	local x, y = rewards:GetPos()
	exit:SetPos((ScrW() * 0.5) - exit:GetWide() / 2, rewards:GetTall() + y + 12)
end;

function PANEL:Paint(w, h)
	nut.util.drawBlur(self, 5)
	surface.SetDrawColor(0, 0, 0, 150)
	surface.DrawRect(0, 0, w, h)
end;

vgui.Register("nutDailyRewards", PANEL, "EditablePanel")
