local PANEL = {}
	function PANEL:Init()
		if (IsValid(nut.gui.stash)) then
			nut.gui.stash:Remove()
		end

		nut.gui.stash = self

		self:SetSize(ScrW() * 0.5, 680)
		self:MakePopup()
		self:Center()

		local noticeBar = self:Add("nutNoticeBar")
		noticeBar:Dock(TOP)
		noticeBar:setType(4)
		noticeBar:setText(L("A safe universal storage container only you can access"))
		noticeBar:DockMargin(3, 0, 3, 5)

		self.stash = self:Add("nutStashItemList")
		self.stash:Dock(LEFT)
		self.stash:SetWide(self:GetWide() * 0.5 - 7)
		self.stash:SetDrawBackground(true)
		self.stash:DockMargin(0, 0, 5, 0)
		self.stash.action:SetText(L"Take out")

		self.inv = self:Add("nutStashItemList")
		self.inv:Dock(RIGHT)
		self.inv:SetWide(self:GetWide() * 0.5 - 7)
		self.inv:SetDrawBackground(true)
		self.inv.title:SetText(LocalPlayer():Name())
		self.inv.action:SetText(L"Put in")

		self.stash.action.DoClick = function()
			local selectedItem = nut.gui.stash.activeItem

			if (IsValid(selectedItem)) then
				-- transfer items.
				netstream.Start("stashOut", selectedItem.indexID)
			end
		end

		self.inv.action.DoClick = function()
			local selectedItem = nut.gui.stash.activeItem

			if (IsValid(selectedItem)) then
				netstream.Start("stashIn", selectedItem.indexID, true)
			end
		end
	end

	function PANEL:setStash()
		local char = LocalPlayer():getChar()

		self.stash.title:SetText("Storage ("..char:getStashCount().."/"..char:getStashMax()..")")

		self.stash.items:Clear()
		self.inv.items:Clear()

		self:SetTitle(L("stashMenu"))


        local items = char:getInv():getItems()
        local stashItems = char:getStash()
        
        local itemsSorted = {}
        for k, v in pairs(items) do
            if v.base == "base_bags" then continue end
            itemsSorted[#itemsSorted + 1 ] = { name = v.name, id = v.uniqueID, object = v, worn = v:getData("equipped"), rarity = v:getData("rarity")}
        end

        local stashSorted = {}
        for k, v in pairs(stashItems) do
            local item = nut.item.instances[k]
            if item then
                if item.base == "base_bags" then continue end

                local data = {
                    name = item.name, 
                    id = item.uniqueID, 
                    object = item,
                    rarity = item:getData("rarity")
                }

                stashSorted[#stashSorted + 1 ] = data
            end
        end

        table.SortByMember(itemsSorted, "name", true)
        table.SortByMember(stashSorted, "name", true)

		for k, v in pairs(itemsSorted) do
			self.inv:addItem(v.id, v.object, nil, v.worn)
		end

		for k, v in pairs(stashSorted) do
			self.stash:addItem(v.id, v.object, true, nil, v.rarity)
		end
	end

	function PANEL:OnRemove()
		--netstream.Start("vendorExit")
	end
vgui.Register("nutStash", PANEL, "DFrame")

    PANEL = {}
	function PANEL:Init()
		self.title = self:Add("DLabel")
		self.title:SetTextColor(color_white)
		self.title:SetExpensiveShadow(1, Color(0, 0, 0, 150))
		self.title:Dock(TOP)
		self.title:SetFont("nutBigFont")
		self.title:SizeToContentsY()
		self.title:SetContentAlignment(7)
		self.title:SetTextInset(10, 5)
		self.title.Paint = function(this, w, h)
			surface.SetDrawColor(0, 0, 0, 150)
			surface.DrawRect(0, 0, w, h)
		end
		self.title:SetTall(self.title:GetTall() + 10)

		self.items = self:Add("DScrollPanel")
		self.items:Dock(FILL)
		self.items:SetDrawBackground(true)
		self.items:DockMargin(5, 5, 5, 5)

		self.action = self:Add("DButton")
		self.action:Dock(BOTTOM)
		self.action:SetTall(32)
		self.action:SetFont("nutMediumFont")
		self.action:SetExpensiveShadow(1, Color(0, 0, 0, 150))

		self.itemPanels = {}
	end

	function PANEL:addItem(uniqueID, itemObject, stash, equipStatus, rarity)
		local itemTable = nut.item.list[uniqueID]

		if (!itemTable) then
			return
		end

		local oldPanel = self.itemPanels[uniqueID]

		local color_dark = Color(0, 0, 0, 80)

		local panel = self.items:Add("DPanel")
		panel:SetTall(36)
		panel:Dock(TOP)
		panel:DockMargin(5, 5, 5, 0)
		panel.Paint = function(this, w, h)
			surface.SetDrawColor(nut.gui.stash.activeItem == this and nut.config.get("color") or color_dark)
			surface.DrawRect(0, 0, w, h)
		end
		panel.indexID = itemObject:getID()
		panel.count = count

		panel.icon = panel:Add("SpawnIcon")
		panel.icon:SetPos(2, 2)
		panel.icon:SetSize(32, 32)
		panel.icon:SetModel(itemTable.model, itemTable.skin)

        panel.icon.PaintOver = function(self, w, h) 
            if itemObject:getData("rarity") or itemTable.rarity or rarity then
                local rardata = wRarity.Config.Rarities[itemObject:getData("rarity") or itemTable.rarity or rarity or 1]
                surface.SetDrawColor(rardata.color)
                surface.DrawOutlinedRect(0, 0, w, h, 1)
            end

            if equipStatus then
                surface.SetDrawColor(110, 255, 110, 100)
                surface.DrawRect(w - 5, h - 5, 8, 8)
            end
        end

		panel.name = panel:Add("DLabel")
		panel.name:DockMargin(40, 2, 2, 2)
		panel.name:Dock(FILL)
		panel.name:SetFont("nutChatFont")
		panel.name:SetTextColor(color_white)
		panel.name:SetText(L(itemTable.name)..(count and " ("..count..")" or ""))
		panel.name:SetExpensiveShadow(1, Color(0, 0, 0, 150))

		panel.overlay = panel:Add("DButton")
		panel.overlay:SetPos(0, 0)
		panel.overlay:SetSize(ScrW() * 0.25, 36)
		panel.overlay:SetText("")
		panel.overlay.Paint = function() end
		panel.overlay.DoClick = function(this)
			nut.gui.stash.activeItem = panel

			if (input.IsKeyDown(KEY_LCONTROL) or input.IsKeyDown(KEY_RCONTROL)) then
				if (stash) then
					netstream.Start("stashOut", panel.indexID)
				else
					netstream.Start("stashIn", panel.indexID, true)
				end
			end
		end

		//panel.overlay:SetToolTip(L("itemPriceInfo", nut.currency.get(price), nut.currency.get(price2)))
		self.itemPanels[uniqueID] = panel

		return panel
	end
vgui.Register("nutStashItemList", PANEL, "DPanel")