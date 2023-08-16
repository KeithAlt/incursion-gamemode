local PANEL = {}
	function PANEL:Init()
		if (nut.gui.merchant) then
			nut.gui.merchant:Remove()
		end;

		nut.gui.merchant = self

		self:SetSize(sW(1024), sH(640))
		self:Center()
		self:MakePopup()
		self:SetSkin("flat")
		self:SetPaintBackground(false)

		template = {}

		instance = {}

		id = 0

		wallet = LocalPlayer():getChar():getMoney()

		inventory = LocalPlayer():getChar():getInv():getItems()

		itemList = nut.item.list

		active = 0
	end;

	function PANEL:message(text, err)
		PRight:SetDisabled(true)
		PLeft:SetDisabled(true)
		PSell:SetDisabled(true)

		if (!err) then
			wallet = LocalPlayer():getChar():getMoney()
			self:setActive(active)
			self:populateBuy()
		end;

		local t1 = self:Add("DPanel")
			t1:SetSize(self:GetWide(), self:GetTall())
			t1.Paint = function(p, w, h)
				nut.util.drawBlur(p, 1)
				surface.SetDrawColor(nut.gui.palette.background_transparent)
				surface.DrawRect(0, 0, w, h)
			end;
		local t2 = t1:Add("DPanel")
			t2:SetTall(96)
			t2:Dock(TOP)
			t2:DockMargin(0, (self:GetTall() * 0.5) - 48, 0, 0)
			t2.Paint = function(p, w, h)
				surface.SetDrawColor(nut.gui.palette.background_dark)
				surface.DrawRect(0, 0, w, h)
			end;
		local t2l = t2:Add("DLabel")
			t2l:Dock(FILL)
			t2l:SetContentAlignment(5)
			t2l:SetFont("UI_Big")
			t2l:SetText(text)
		local t2b = t2:Add("DButton")
			t2b:Dock(BOTTOM)
			t2b:DockMargin(6, 0, 6, 6)
			t2b:SetText("OK")
			t2b.DoClick = function()
				PRight:SetDisabled(false)
				PLeft:SetDisabled(false)
				PSell:SetDisabled(false)
				t1:Remove()
			end;
	end;

	function PANEL:open(t1, t2, t3)
		instance = t1
		template = t2
		id = t3

		PLeft = self:Add("DPanel")
			PLeft:Dock(LEFT)
			PLeft:SetWidth(self:GetWide() * 0.25)
			PLeft:DockMargin(0, 0, 6, 0)

		name = PLeft:Add("DLabel")
			name:Dock(TOP)
			name:SetFont("UI_Regular")
			name:DockMargin(6, 0, 0, 0)
			name:SetText(instance["name"])

		Close = PLeft:Add("DButton")
			Close:Dock(BOTTOM)
			Close:DockMargin(6, 0, 6, 6)
			Close:SetText("Close")
			Close.DoClick = function()
				self:Remove()
			end;

		npc = PLeft:Add("DModelPanel")
			npc:Dock(BOTTOM)
			npc:SetModel(instance.model or "models/breen.mdl")
			npc:SetHeight(self:GetTall())
			npc:DockMargin(6, 0, 6, 6)

		PRight = self:Add("DPanel")
			PRight:Dock(FILL)

		PSell = self:Add("DPanel")
			PSell:Dock(RIGHT)
			PSell:SetWidth(self:GetWide() * 0.25)
			PSell:DockMargin(6, 0, 0, 0)

		PSellItems = PSell:Add("DScrollPanel")
			PSellItems:Dock(FILL)
			PSellItems:DockMargin(6, 6, 6, 6)

		items = PRight:Add("DScrollPanel")
			items:Dock(FILL)
			items:DockMargin(6, 6, 6, 6)

		buy = PRight:Add("DButton")
			buy:Dock(BOTTOM)
			buy:DockMargin(6, 6, 6, 6)
			buy:SetText("Buy")
			buy.DoClick = function()
				netstream.Start("nutMerchantBuy", id, instance.template, active, desc_quantity:GetValue())
			end;

		desc = PRight:Add("DPanel")
			desc:Dock(BOTTOM)
			desc:DockMargin(6, 0, 6, 0)
			desc:SetTall(214)
			desc.Paint = function(p, w, h)
				surface.SetDrawColor(nut.gui.palette.background_light)
				surface.DrawRect(0, 0, w, h)
			end;

			local t = desc:Add("DPanel")
				t:Dock(TOP)
				t:DockMargin(6, 6, 6, 6)
				t:SetHeight(64)

				desc_icon = t:Add("nutSpawnIcon")
					desc_icon:SetSize(52, 52)
					desc_icon:Dock(LEFT)
					desc_icon:DockMargin(6, 6, 6, 6)
					desc_icon:SetModel("models/hunter/blocks/cube025x025x025.mdl")

				desc_name = t:Add("DLabel")
					desc_name:Dock(LEFT)
					desc_name:SetFont("UI_Regular")
					desc_name:SizeToContentsX()

			desc_price = t:Add("DLabel")
					desc_price:Dock(RIGHT)
					desc_price:DockMargin(0, 0, 12, 0)
					desc_price:SetFont("UI_Regular")

			desc_text = desc:Add("DLabel")
				desc_text:Dock(FILL)
				desc_text:SetTall(42)
				desc_text:SetFont("UI_Regular")
				desc_text:SetContentAlignment(7)
				desc_text:DockMargin(6, 0, 6, 0)
				desc_text:SetWrap(true)

			desc_quantity = desc:Add("DNumSlider")
				desc_quantity:Dock(BOTTOM)
				desc_quantity:DockMargin(6, 0, 6, 0)
				desc_quantity:SetText("Quantity:")
				desc_quantity:SetMin(1)
				desc_quantity:SetMax(25)
				desc_quantity:SetValue(1)
				desc_quantity.OnValueChanged = function(p, value)
					local cost = value * template.items[active].price

					if (cost <= wallet) then
						desc_price:SetText("$"..cost)
						desc_price:SetTextColor(nut.gui.palette.text_green)
						buy:SetDisabled(false)
					else
						desc_price:SetText("$"..cost.." (Missing $"..(cost - wallet)..")")
						desc_price:SetTextColor(nut.gui.palette.text_red)
						buy:SetDisabled(true)
					end;

					desc_price:SizeToContentsX()
				end;

		self:populate()
		self:populateBuy()
	end;

	function PANEL:setActive(item)
		active = item

		desc_name:SetText(itemList[active].name)
		desc_name:SizeToContentsX()
		desc_icon:SetModel(itemList[active].model)
		desc_text:SetText(itemList[active].desc)

		desc_quantity:SetValue(1)

		local stock = template.items[active].stock
		if (!stock) then
			desc_quantity:SetMax(25)
		else
			desc_quantity:SetMax(math.min(stock, 25))
		end;

		local cost = template.items[active].price

		if (cost <= wallet) then
			desc_price:SetText("$"..cost)
			desc_price:SetTextColor(nut.gui.palette.text_green)
			buy:SetDisabled(false)
		else
			desc_price:SetText("$"..cost.." (Missing $"..(cost - wallet)..")")
			desc_price:SetTextColor(nut.gui.palette.text_red)
			buy:SetDisabled(true)
		end;

		desc_price:SizeToContentsX()
	end;

	function PANEL:populateBuy()
		PSellItems:Clear()
		inventory = LocalPlayer():getChar():getInv():getItems()

		for i, v in pairs(inventory) do
			if (template.items[v.uniqueID]) then
				local iID = v.uniqueID
				if (template.items[iID].mode >= 2) then
					PSellItems.iID = PSellItems:Add("DPanel")
						PSellItems.iID:Dock(TOP)
						PSellItems.iID:DockMargin(0, 0, 0, 6)
						PSellItems.iID:SetHeight(64)
						PSellItems.iID:SetMouseInputEnabled(true)
						PSellItems.iID.Paint = function(p, w, h)
							if (p:IsHovered() or active == i) then
								surface.SetDrawColor(nut.gui.palette.header)
							else
								surface.SetDrawColor(nut.gui.palette.background_light)
							end;

							surface.DrawRect(0, 0, w, h)
						end;

						PSellItems.iID.OnMouseReleased = function(p, mousecode)
							if (mousecode == MOUSE_LEFT) then
								netstream.Start("nutMerchantSell", id, instance.template, iID)
							end;
						end;

						local icon = PSellItems.iID:Add("nutSpawnIcon")
							icon:SetSize(52, 52)
							icon:Dock(LEFT)
							icon:DockMargin(6, 6, 6, 6)
							icon:SetModel(itemList[iID].model)

						local label = PSellItems.iID:Add("DLabel")
							label:Dock(TOP)
							label:DockMargin(0, 12, 0, 0)
							label:SetFont("UI_Regular")
							label:SetText(itemList[iID].name)
							label:SizeToContentsX()

						local sellPrice = PSellItems.iID:Add("DLabel")
							sellPrice:Dock(BOTTOM)
							sellPrice:DockMargin(0, 0, 0, 12)
							sellPrice:SetFont("UI_Regular")
							sellPrice:SetTextColor(nut.gui.palette.text_orange)
							sellPrice:SetText("Sell For $"..(template.items[iID].price * (instance.buyScale or 0.5)))
				end;
			end;
		end;
	end;

	function PANEL:populate()
		items:Clear()

		for i, v in pairs(template.items) do
			if (items:ChildCount() == 2) then -- I have no idea why it returns 2 right after i've cleared it, but i'll just roll with it.
				self:setActive(i)
			end;

			items.i = items:Add("DPanel")
				items.i:Dock(TOP)
				items.i:DockMargin(0, 0, 0, 6)
				items.i:SetHeight(64)
				items.i:SetMouseInputEnabled(true)
				items.i.Paint = function(p, w, h)
					if (p:IsHovered() or active == i) then
						surface.SetDrawColor(nut.gui.palette.header)
					else
						surface.SetDrawColor(nut.gui.palette.background_light)
					end;

					surface.DrawRect(0, 0, w, h)
				end;
				items.i.OnMouseReleased = function(p, mousecode)
					if (mousecode == MOUSE_LEFT) then
						self:setActive(i)
					end;
				end;

				local icon = items.i:Add("nutSpawnIcon")
					icon:SetSize(52, 52)
					icon:Dock(LEFT)
					icon:DockMargin(6, 6, 6, 6)
					icon:SetModel(itemList[i].model)

				local price = items.i:Add("DLabel")
					price:Dock(RIGHT)
					price:DockMargin(0, 0, 12, 0)
					price:SetFont("UI_Regular")
					if (v.price == 0) then
						price:SetText("FREE")
					else
						price:SetText("$"..v.price)
					end;
					price:SetTextColor(nut.gui.palette.text_green)
					price:SizeToContentsX()

				local label = items.i:Add("DLabel")
					label:Dock(TOP)
					label:DockMargin(0, 12, 0, 0)
					label:SetFont("UI_Regular")
					label:SetText(itemList[i].name)
					label:SizeToContentsX()

				local stock = items.i:Add("DLabel")
					stock:Dock(BOTTOM)
					stock:DockMargin(0, 0, 0, 12)
					stock:SetFont("UI_Regular")
					stock:SetTextColor(nut.gui.palette.text_orange)
					stock:SetText("")

				if (!v.stock) then
					stock:SetText("Stock: ∞ / ∞")
				elseif (v.stockMax == 0) then
					stock:SetText("Stock: "..v.stock.." / ∞")
				else
					stock:SetText("Stock: "..v.stock.." / "..v.stockMax)
				end;
		end;
	end;

vgui.Register("nutMerchant", PANEL, "DPanel")
