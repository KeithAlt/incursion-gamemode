BuyMenu.Favourites = BuyMenu.Favourites or {}
BuyMenu.FavouritesIcon = "78"
BuyMenu.FavouriteMaterial = Material("icon16/heart.png")

-- Buy menu
surface.CreateFont("BuyMenu", {font = "Roboto", size = 24, weight = 400})
surface.CreateFont("BuyMenuSmall", {font = "Roboto", size = 18, weight = 400, outline = true})
surface.CreateFont("BuyMenuLarge", {font = "Roboto", size = 40, weight = 400})

function BuyMenu.SaveFavourites()
	file.Write("buymenufavsv2.json", util.TableToJSON(BuyMenu.Favourites))
end

function BuyMenu.LoadFavourites()
	BuyMenu.Favourites = util.JSONToTable(file.Read("buymenufavsv2.json") or "[]")
end
hook.Add("Initialize", "BuyMenuFavs", BuyMenu.LoadFavourites)

function BuyMenu.Jiggle(pnl, right)
	pnl:MoveBy(right and 25 or -25, -15, 0.5, 0, -1, function()
		BuyMenu.Jiggle(pnl, !right)

		local _, y = pnl:GetPos()
		if y < -pnl:GetTall() then
			pnl:Remove()
		end
	end)
end

function BuyMenu.CapsSpentEffect(amt, parent, color)
	local label = vgui.Create("DLabel", parent)
	label:SetPos(parent:LocalCursorPos())
	label:SetFont("BuyMenu")
	label:SetTextColor(color)
	label:SetText(amt)
	label:SizeToContents()
	BuyMenu.Jiggle(label)
end

local PANEL = {}

function PANEL:Init()
	self:StretchToParent(0, 50, 0, 0)
	self:Center()

	self.Menus = {}
	self.Buttons = {}
	self.Categories = {}

	local class = BuyMenu.GetClass(LocalPlayer()) -- NOTE: Adds shop menu items to player VGUI
	for id, item in SortedPairsByMemberValue(BuyMenu.Items, "price") do
		if BuyMenu.IsClassSet(item.classes, BuyMenu.ClassToID[class]) then
			if !IsValid(self.Categories[item.category]) then
				self.Categories[item.category] = self:AddCategory(BuyMenu.Categories[item.category])
			end
			local categoryMenu = self.Categories[item.category]

			categoryMenu:AddNSItem(item)
		end
	end

	local favs = BuyMenu.Favourites
	local favsPnl = self:AddCategory({
		icon = BuyMenu.FavouritesIcon,
		name = "Favourites",
		id = "favs"
	})
	self.Categories["favs"] = favsPnl

	if next(favs) == nil then
		local lbl = favsPnl:Add("UI_DLabel")
		lbl:SetText("You have no favourites, to select some click the item's icon on the left in another shop category.")
		lbl:SizeToContents()
		lbl:SetContentAlignment(5)
		lbl:Dock(TOP)

		favsPnl.lbl = lbl
	else
		for id, _ in pairs(favs) do
			local item = BuyMenu.Items[id]

			if item and BuyMenu.IsClassSet(item.classes, BuyMenu.ClassToID[class]) then
				favsPnl:AddNSItem(item)
			end
		end
	end

	for i, btn in ipairs(self.Buttons) do
		local totalW = #self.Buttons * 48

		local center = (self:GetWide() / 2) - (totalW / 2)
		btn:SetPos(center + ((i - 1) * 48), 8)
	end

	self.Buttons[1]:DoClick()
end

function PANEL:SetCategory(cat)
	if IsValid(self.Category) then
		self.Category:Hide()
	end

	local pnl = self.Categories[cat.id]
	pnl:Show()
	self.Category = pnl
end

function PANEL:AddCategory(category)
	local btn = self:Add("DImageButton")
	btn:SetPos(-32, -32)
	btn:SetImage(BuyMenu.Config.IconsPath .. category.icon .. ".png")
	btn:SetColor(BuyMenu.Config.PrimaryColor)
	btn:SetSize(32, 32)
	btn:NoClipping(true)
	btn.PaintOver = function(s, w, h)
		if s:IsHovered() then
			local x, y = s:LocalCursorPos()
			surface.SetTextPos(x + 15, y + 12)
			surface.SetFont("BuyMenuSmall")
			surface.SetTextColor(BuyMenu.Config.TextColor)
			surface.DrawText(category.name)
		end
	end
	btn.DoClick = function(s)
		self:SetCategory(category)
		surface.PlaySound("fallout/ui/ui_select.wav")
	end
	btn.OnCursorEntered = function(s)
		surface.PlaySound("fallout/ui/ui_focus.wav")
		for _, pnl in pairs(self.Buttons) do
			if pnl == s then continue end

			s:MoveToBefore(pnl)
		end
	end

	table.insert(self.Buttons, btn)

	local buyMenu = self:Add("BuyMenu")
	buyMenu:SetPos(0, 48)
	buyMenu:CenterHorizontal()
	buyMenu:Hide()
	buyMenu.Btn = btn

	return buyMenu, btn
end

function PANEL:Paint(pnlW, h)
	if !self.Category then
		return
	end

	local x = ((pnlW - 612) / 2) - 5 -- 612 = w of an item's panel
	local y = 42
	local pad = 4
	local w = 2

	for i = 1, 2 do
		if i == 1 then
			surface.SetDrawColor(Color(0, 0, 0, 255))
			w = w + 1
		else
			surface.SetDrawColor(BuyMenu.Config.OutlineColor)
			w = w - 1
		end

		surface.DrawRect(x, y, self.Category.Btn:GetPos() - x - pad, w)
		surface.DrawRect(self.Category.Btn:GetPos() - pad - w, y - 39, w, 39 + w)
		surface.DrawRect(self.Category.Btn:GetPos() - pad - w, y - 39, 32 + (pad * 2) + w, w)
		surface.DrawRect(self.Category.Btn:GetPos() + 32 + pad, y - 39, w, 39 + w)
		surface.DrawRect(self.Category.Btn:GetPos() + 32 + pad, y, pnlW - x - self.Category.Btn:GetPos() - 32 - pad, w)

		surface.DrawRect(x, y, w, 6)
		surface.DrawRect(pnlW - x, y, w, 6)
	end
end

vgui.Register("BuyMenuCategories", PANEL, "DPanel")

PANEL = {}
PANEL.Spacing = 16

function PANEL:Init()
	self:StretchToParent(0, 48, 0, 0)
	self:Center()
	self.Items = {}
end

function PANEL:AddNSItem(item)
	local itemID = item.item

	if !nut.item.list[itemID] then
		BuyMenu.Print("WARNING: item with unique ID " .. itemID .. " does not exist.")
		return
	end

	local i = #self.Items

	local itemPanel = self:Add("BuyMenuItem")
	itemPanel:SetItem(item)
	itemPanel:SetPos((self:GetWide() / 2) - (itemPanel:GetWide() / 2), (itemPanel:GetTall() + self.Spacing) * i)

	itemPanel.ID = table.insert(self.Items, itemPanel)
end

function PANEL:RemoveNSItem(panelID)
	local pnl = self.Items[panelID]

	if IsValid(pnl) then
		table.remove(self.Items, panelID)
		pnl:Remove()

		for i = panelID, #self.Items do
			local movePnl = self.Items[i]
			movePnl:MoveBy(0, -(movePnl:GetTall() + self.Spacing), 0.5)
			movePnl.ID = i
		end
	end
end

function PANEL:GetPanelID(itemID)
	for i, pnl in ipairs(self.Items) do
		if pnl.ItemData.id == itemID then
			return pnl.ID
		end
	end
end

vgui.Register("BuyMenu", PANEL, "DScrollPanel")

PANEL = {}

PANEL.Modes = {
	Buy = 0,
	Sell = 1
}

PANEL.ModeIcons = {
	[0] = "icon16/basket_put.png",
	[1] = "icon16/basket_remove.png"
}

function PANEL:Init()
	self:SetSize(612, 128)

	local icon = self:Add("nutSpawnIcon")
	icon:SetSize(64, 64)
	icon:SetPos(6, 0)
	icon:CenterVertical()
	icon.DoClick = function(s)
		local id = self.ItemData.id
		local favsTab = self:GetParent():GetParent():GetParent().Categories.favs

		if BuyMenu.Favourites[id] == true then
			BuyMenu.Favourites[id] = nil

			favsTab:RemoveNSItem(favsTab:GetPanelID(id))

			BuyMenu.SaveFavourites()
		else
			BuyMenu.Favourites[id] = true
			favsTab:AddNSItem(self.ItemData)

			if IsValid(favsTab.lbl) then
				favsTab.lbl:Remove()
			end

			BuyMenu.SaveFavourites()
		end
	end
	icon.PaintOver = function(s, w, h)
		if BuyMenu.Favourites[self.ItemData.id] then
			surface.SetMaterial(BuyMenu.FavouriteMaterial)
			surface.SetDrawColor(Color(255, 255, 255, 255))
			surface.DrawTexturedRect(w - 16, h - 16, 16, 16)
		end
	end
	self.SpawnIcon = icon

	local name = self:Add("DLabel")
	name:SetText("Placeholder")
	name:SetFont("BuyMenu")
	name:MoveRightOf(icon, 10)
	name:MoveAbove(icon)
	name:SetTextColor(BuyMenu.Config.TextColor)
	self.NameLabel = name

	local desc = self:Add("DLabel")
	desc:SetText("Placeholder")
	desc:SetFont("BuyMenu")
	desc:SetSize(300, 80)
	desc:MoveRightOf(icon, 10)
	desc:MoveBelow(name)
	desc:SetTextColor(BuyMenu.Config.TextColor)
	desc:SetWrap(true)
	desc:SetContentAlignment(7)
	self.DescLabel = desc

	if self:GetParent():GetParent():GetParent().ModeTutorialShown == nil and cookie.GetNumber("BuyMenuSeenModeToggle", 0) != 1 then
		local tutorial = vgui.Create("DPanel")
		tutorial:SetSize(ScrW(), ScrH())
		tutorial:MakePopup()

		timer.Simple(0, function()
			if !IsValid(tutorial) then
				return
			end

			local tX, tY = self:LocalToScreen(self:GetWide() - 16 - 3, self:GetTall() - 16 - 3)
			local outlineThickness = 2

			tutorial.Paint = function(s, w, h)
				surface.SetDrawColor(0, 0, 0, 200)
				surface.DrawRect(0, 0, w, h)
			end

			local exampleIcon = tutorial:Add("DImage")
			exampleIcon:SetImage(self.ModeIcons[0])
			exampleIcon:SetSize(16, 16)
			exampleIcon:SetPos(tX, tY)
			exampleIcon:NoClipping(true)
			exampleIcon.PaintOver = function(s, w, h)
				surface.SetDrawColor(255, 0, 0, 255)
				surface.DrawOutlinedRect(-outlineThickness, -outlineThickness, w + (outlineThickness * 2), h + (outlineThickness * 2), outlineThickness)
			end

			local help = tutorial:Add("UI_DLabel")
			help:SetText("This icon may now appear on select items.\nWhen clicked it will change the item from buy to sell mode.\nThe price will then be changed to the price you are given for selling the item.\nYou can then use the same caps button to sell the item to the store!")
			help:SizeToContents()
			help:SetPos(tX + 16, tY + 16)

			local confirm = tutorial:Add("UI_DButton")
			confirm:SetPos(tX + 16, tY + 16)
			confirm:MoveBelow(help, 1)
			confirm:SetText("Got it!")
			confirm.DoClick = function()
				cookie.Set("BuyMenuSeenModeToggle", 1)
				tutorial:Remove()
			end
		end)

		self.ModeTutorial = tutorial
		self:GetParent():GetParent():GetParent().ModeTutorialShown = true
	end

	local modeToggle = self:Add("DImageButton")
	modeToggle:SetSize(16, 16)
	modeToggle:NoClipping(true)
	modeToggle.DoClick = function()
		if self.Mode == 1 then
			self:SetMode(0)
		elseif self.Mode == 0 then
			self:SetMode(1)
		end
	end
	modeToggle.PaintOver = function(s)
		if s:IsHovered() then
			local x, y = s:LocalCursorPos()
			surface.SetTextPos(x + 15, y + 12)
			surface.SetFont("BuyMenuSmall")
			surface.SetTextColor(BuyMenu.Config.TextColor)
			surface.DrawText(self.Mode == 0 and "Current Mode: Buy" or "Current Mode: Sell")
		end
	end
	modeToggle:SetPos(self:GetWide() - modeToggle:GetWide() - 3, self:GetTall() - modeToggle:GetTall() - 3)
	self.ModeToggle = modeToggle

	self:SetMode(0)

	local caps = self:Add("DButton")
	caps:SetText("")
	caps:SetSize(64, 64)
	caps:MoveRightOf(desc)
	caps:CenterVertical()
	caps.DoClick = function(s)
		if self.Mode == self.Modes.Buy then
			local pool = BuyMenu.StockPools[self.ItemData.pool or 0]

			if !pool or pool:GetStock() > 0 then
				if LocalPlayer():getChar():hasMoney(self.ActualPrice) then
					if LocalPlayer():getChar():getInv():findEmptySlot(self.Item.width, self.Item.height) then
						surface.PlaySound("buymenu/kaching.wav")
						BuyMenu.CapsSpentEffect("-" .. self.Price:GetText(), self, Color(230, 41, 41))

						net.Start("BuyMenuPurchase")
							net.WriteUInt(self.ItemData.id, 16)
						net.SendToServer()
					else
						nut.util.notify("Not enough inventory space.")
					end
				else
					nut.util.notifyLocalized("canNotAfford")
				end
			else
				nut.util.notify("Out of stock!")
			end
		elseif self.Mode == self.Modes.Sell then
			if LocalPlayer():getChar():getInv():hasItem(self.Item.uniqueID) then
				surface.PlaySound("shelter/sfx/nukacaps_collect_l1.ogg")

				BuyMenu.CapsSpentEffect(self.Price:GetText(), self, Color(41, 230, 41)) -- The label already has a + prepended, no need to concatenate

				net.Start("BuyMenuSell")
					net.WriteUInt(self.ItemData.id, 16)
				net.SendToServer()
			else
				nut.util.notify(string.format("You don't have any \"%s\" to sell!", self.Item.name:lower()))
			end
		end
	end
	caps.Paint = function(s, w, h)
		s.Material = s.Material or Material("buymenu/icons/caps.png")

		if s:GetDisabled() and self.Color == nil then
			self.Color = table.Copy(BuyMenu.Config.IconColor)
			for k,v in pairs(self.Color) do
				if k != "a" then
					self.Color[k] = self.Color[k] * 0.6
				end
			end
		end

		surface.SetDrawColor(s:GetDisabled() and self.Color or BuyMenu.Config.IconColor)
		surface.SetMaterial(s.Material)

		if s:IsHovered() and (input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT)) and !s:GetDisabled() then
			surface.DrawTexturedRect(2, 2, w - 4, h - 4)
		else
			surface.DrawTexturedRect(0, 0, w, h)
		end
	end
	self.CapsIcon = caps

	local amt = self:Add("DLabel")
	amt:SetText("Placeholder")
	amt:SetFont("BuyMenuLarge")
	amt:SetTextColor(BuyMenu.Config.IconColor)
	amt:MoveRightOf(caps)
	self.Price = amt

	local stock = self:Add("DLabel")
	stock:SetText("")
	stock:SetFont("BuyMenuSmall")
	stock:SetTextColor(BuyMenu.Config.IconColor)
	stock.Think = function()
		if !self.ItemData then return end

		local pool = BuyMenu.StockPools[self.ItemData.pool]

		if pool then
			local timeUntilStock = (pool:GetNextRestock() or 0) - jlib.GetServerTime()

			local restockText
			if timeUntilStock < BuyMenu.StockTimer then
				restockText = " - restock soon"
			else
				restockText = " - restock in " .. string.NiceTime(timeUntilStock)
			end

			if pool:GetStock() == 0 or pool:GetMaxStock() == 0 then
				self.Stock:SetText("Out of stock" .. restockText)
				if IsValid(self.CapsIcon) and !IsValid(self.ModeToggle) then self.CapsIcon:SetEnabled(false) end
			else
				self.Stock:SetText("Stock: " .. pool:GetStock() .. "/" .. pool:GetMaxStock() .. (pool:GetStock() < pool:GetMaxStock() and restockText or ""))
				if IsValid(self.CapsIcon) and !IsValid(self.ModeToggle) then self.CapsIcon:SetEnabled(true) end
			end

			self.Stock:SizeToContents()
			self.Stock:SetPos(self:GetWide() - self.Stock:GetWide() - 5, 5)
		end
	end
	self.Stock = stock
end

function PANEL:SetMode(mode)
	if isstring(mode) then
		mode = self.Modes[mode]
	end

	self.Mode = mode
	if IsValid(self.ModeToggle) then
		self.ModeToggle:SetImage(self.ModeIcons[mode])
	end

	if IsValid(self.Price) then
		self.Price:SetText(mode == 1 and "+" .. self.ItemData.sellPrice or self.ItemData.price)
		self.Price:SizeToContents()
	end
end

function PANEL:SetItem(dat)
	local uniqueID = dat.item
	local item = nut.item.list[uniqueID]

	self.Item = item
	self.ItemData = dat

	if self.Category == "Favourites" then
		self.IsFavourites = true
	end
	self.Category = dat.Category or self.Category

	if !item then
		BuyMenu.Print("WARNING: item with unique ID " .. uniqueID .. " does not exist.")
		return
	end

	if dat.rarity and BuyMenu.Config.DisplayRarity then
		self.NameLabel:SetText(wRarity.Config.Rarities[dat.rarity].name .. " " .. item.name)
	else
		self.NameLabel:SetText(item.name)
	end
	self.NameLabel:SizeToContents()

	self.DescLabel:SetText(item:getDesc())

	self.SpawnIcon:SetModel(item.model)

	self.Price:SetText(jlib.CommaNumber(dat.price))
	self.Price:SizeToContents()
	self.Price:CenterVertical()
	self.ActualPrice = dat.price

	self.CapsIcon:SetPos(((self.CapsIcon:GetPos() / 2) - ((self.Price:GetWide() + self.CapsIcon:GetWide() + 12) / 2)) + self.DescLabel:GetWide())
	self.CapsIcon:CenterVertical()
	if dat.sellPrice then
		self.CapsIcon:NoClipping(true)
		self.CapsIcon.PaintOver = function(s, w, h)
			if s:IsHovered() then
				local x, y = s:LocalCursorPos()
				surface.SetTextPos(x + 15, y + 12)
				surface.SetFont("BuyMenuSmall")
				surface.SetTextColor(BuyMenu.Config.TextColor)
				surface.DrawText(self.Mode == 0 and "Current Mode: Buy" or "Current Mode: Sell")
			end
		end
	else
		self.CapsIcon:NoClipping(false)
		self.CapsIcon.PaintOver = nil
	end
	self.Price:MoveRightOf(self.CapsIcon, 12)

	if !dat.sellPrice or dat.sellPrice == 0 then
		self.ModeToggle:Remove()
	end
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(BuyMenu.Config.BackgroundColor)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(Color(0, 0, 0))
	surface.DrawOutlinedRect(2, 2, w - 1, h - 1)

	surface.SetDrawColor(BuyMenu.Config.OutlineColor)
	surface.DrawOutlinedRect(0, 0, w, h)
	surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
end

function PANEL:OnSizeChanged(w, h)
	local modeToggle = self.ModeToggle
	if IsValid(modeToggle) then
		modeToggle:SetPos(w - modeToggle:GetWide() - 3, h - modeToggle:GetTall() - 3)
	end
end

function PANEL:OnRemove()
	if IsValid(self.ModeTutorial) then
		self.ModeTutorial:Remove()
	end
end

vgui.Register("BuyMenuItem", PANEL, "DPanel")

-- Config menus
PANEL = {}

function PANEL:Init()
	self.Icon = self:Add("DImage")
	self.Title = self:Add("UI_DLabel")
end

function PANEL:SetCategory(category)
	self.Category = category

	local iconPath = BuyMenu.Config.IconsPath .. category.icon .. ".png"
	local icon = self.Icon
	icon:SetImage(iconPath)
	icon:SetImageColor(BuyMenu.Config.PrimaryColor)
	icon:SetSize(32, 32)
	icon:SetPos(16)
	icon:CenterVertical()

	local title = self.Title
	title:SetText(category.name)
	title:SizeToContents()
	title:SetPos(0, 2)
	title:CenterHorizontal()
end

function PANEL:GetCategory()
	return self.Category
end

vgui.Register("BuyMenuConfigCategory", PANEL, "DPanel")

local function ConfigCategory(p, existing)
	local frame = vgui.Create("DFrame", p)
	frame:SetSize(600, 400)
	frame:Center()
	frame:SetTitle(existing and "Category Editor" or "Category Maker")

	local name = frame:Add("DTextEntry")
	name:SetPlaceholderText("Name")
	name:SetSize(400, 24)
	name:SetPos(0, 30)
	name:CenterHorizontal()

	if existing then
		name:SetText(existing.name)
	end

	local iconLabel = frame:Add("DLabel")
	iconLabel:SetFont("BuyMenu")
	iconLabel:SetText("Choose an icon:")
	iconLabel:SizeToContents()
	iconLabel:MoveBelow(name, 12)
	iconLabel:CenterHorizontal()

	local scroll = frame:Add("DScrollPanel")
	scroll:SetSize(395, 200)
	scroll:MoveBelow(iconLabel, 12)
	scroll:CenterHorizontal()

	local i = 0
	local j = 0
	for _, f in ipairs(file.Find("materials/buymenu/icons/*.png", "GAME")) do
		if !tonumber(f:StripExtension()) then
			continue
		end

		local path = BuyMenu.Config.IconsPath .. f

		local btn = scroll:Add("DImageButton")
		btn:SetImage(path)
		btn:SetColor(BuyMenu.Config.PrimaryColor)
		btn.DoClick = function(s)
			frame.Icon = s
		end
		btn.PaintOver = function(s, w, h)
			if frame.Icon == s then
				surface.SetDrawColor(BuyMenu.Config.SelectedColor:Unpack())
				surface.DrawOutlinedRect(0, 0, w, h)
			end
		end
		btn:SetSize(32, 32)

		btn:SetPos(i * 38, j * 38)

		i = i + 1

		if i % 10 == 0 then
			i = 0
			j = j + 1
		end

		if existing and tonumber(path:GetFileFromFilename():StripExtension()) == existing.icon then
			frame.Icon = btn
		end
	end

	local save = frame:Add("DButton")
	save:SetText("Save")
	save:Dock(BOTTOM)
	save.DoClick = function(s)
		if existing then
			net.Start("BuyMenuCategoryUpdate")
			net.WriteUInt(existing.id, 8)
		else
			net.Start("BuyMenuCategoryCreate")
		end
		net.WriteString(name:GetText())
		net.WriteUInt(tonumber(frame.Icon:GetImage():GetFileFromFilename():StripExtension()), 32)
		net.SendToServer()

		frame:Close()
	end

	return frame
end

local function ConfigStock(p, existing)
	local frame = vgui.Create("DFrame", p)
	frame:SetSize(300, 150)
	frame:Center()
	frame:SetTitle(existing and "Stock Pool Editor" or "Stock Pool Maker")

	local stockMax = frame:Add("DTextEntry")
	stockMax:SetPlaceholderText("Maximum stock")
	stockMax:Dock(TOP)
	stockMax:SetWide(298)

	local restockTime = frame:Add("DPanel")
	restockTime:SetSize(298, 20)
	restockTime:Dock(TOP)
	restockTime:SetPaintBackground(false)

	local restockNumber = restockTime:Add("DTextEntry")
	restockNumber:SetPlaceholderText("Restock in")
	restockNumber:Dock(LEFT)
	restockNumber:SetWide(140)

	local restockUnits = restockTime:Add("DComboBox")
	restockUnits:AddChoice("Minutes", 60)
	restockUnits:AddChoice("Hours", 3600)
	restockUnits:AddChoice("Days", 86400)
	restockUnits:AddChoice("Weeks", 604800)
	restockUnits:ChooseOptionID(1)
	restockUnits:Dock(RIGHT)
	restockUnits:SetWide(140)
	restockUnits:SetSortItems(false)

	local restockAmt = frame:Add("DTextEntry")
	restockAmt:SetPlaceholderText("Restock by")
	restockAmt:Dock(TOP)
	restockAmt:SetWide(298)

	stockMax:DockMargin(0, 2, 2, 0)
	restockTime:DockMargin(0, 2, 2, 0)
	restockAmt:DockMargin(0, 2, 2, 0)
	stockMax:SetNumeric(true)
	restockNumber:SetNumeric(true)
	restockAmt:SetNumeric(true)

	if existing then
		stockMax:SetValue(existing:GetMaxStock())
		restockNumber:SetValue(existing:GetStockInterval() / 60)
		restockAmt:SetValue(existing:GetRestockAmt())
	end

	local saveBtn = frame:Add("DButton")
	saveBtn:SetText("Save")
	saveBtn:Dock(BOTTOM)
	saveBtn.DoClick = function()
		if existing then
			net.Start("BuyMenuStockUpdate")
			net.WriteUInt(existing:GetID(), 16)
		else
			net.Start("BuyMenuStockCreate")
		end

		local _, units = restockUnits:GetSelected()
		local maxStock = tonumber(stockMax:GetValue())
		local stockAmt = tonumber(restockAmt:GetValue())
		local stockTime = tonumber(restockNumber:GetValue()) * units

		if !maxStock then
			nut.util.notify("No max stock inputted!")
			return
		elseif !stockAmt then
			nut.util.notify("No restock amount inputted!")
			return
		elseif !stockTime then
			nut.util.notify("No stock interval inputted!")
			return
		end

		net.WriteUInt(maxStock, 32)
		net.WriteUInt(stockAmt, 32)
		net.WriteUInt(math.floor(stockTime), 32)
		net.SendToServer()

		frame:Close()
	end

	return frame
end

local function ConfigItem(p, existing)
	local frame = vgui.Create("DFrame", p)
	frame:SetSize(600, 650)
	frame:Center()
	frame:SetTitle(existing and "Item Editor" or "Item Maker")

	local gap = 5
	local selectedRarity = false

	local itemPicker = frame:Add("SearchableListView")
	itemPicker:AddColumn("Name")
	itemPicker:AddColumn("UniqueID")
	itemPicker:Dock(TOP)
	itemPicker:SetTall(100)
	itemPicker:SetMultiSelect(false)
	itemPicker:DockMargin(0, 0, 0, gap)

	itemPicker.OnRowSelected = function(self, index, pnl)
		local uid = pnl:GetColumnText(2)
		local itemData = nut.item.list[uid]
		if itemData.base == "base_firearm" then
			if !IsValid(frame.RarityPicker) then
				timer.Simple(0, function()
					local rarityPicker = frame:Add("DComboBox")
					rarityPicker:Dock(TOP)
					rarityPicker:DockMargin(0, 0, 0, gap)

					for i, rarity in ipairs(wRarity.Config.Rarities) do
						rarityPicker:AddChoice(rarity.name, i, i == 1)
					end

					if existing and existing.rarity and !selectedRarity then
						rarityPicker:ChooseOptionID(existing.rarity)
					end

					frame.RarityPicker = rarityPicker
				end)
			end
		elseif IsValid(frame.RarityPicker) then
			frame.RarityPicker:Remove()
		end
	end

	for k, item in pairs(nut.item.list) do
		local line = itemPicker:AddLine(item.name, item.uniqueID)
		if existing and existing.item == item.uniqueID then
			itemPicker:SelectItem(line)
		end
	end

	local categoryScroll = frame:Add("DScrollPanel")
	categoryScroll:Dock(TOP)
	categoryScroll:SetTall(100)
	categoryScroll:DockMargin(0, 0, 0, gap)

	local i = 1
	local selectedCategoryPnl
	for id, category in pairs(BuyMenu.Categories) do
		local pnl = categoryScroll:Add("BuyMenuConfigCategory")
		pnl:SetSize(450, 50)
		pnl:SetCategory(category)
		pnl:SetPos(frame:GetWide() / 2 - pnl:GetWide() / 2, ((i - 1) * 50) + (i * 5))

		local selectBtn = pnl:Add("DButton")
		selectBtn:SetText("Select")
		selectBtn:SetPos(0, pnl:GetTall() - selectBtn:GetTall() - 2)
		selectBtn:CenterHorizontal()
		selectBtn.DoClick = function(s)
			selectedCategoryPnl = pnl
		end

		pnl.PaintOver = function(s, w, h)
			if s == selectedCategoryPnl then
				surface.SetDrawColor(BuyMenu.Config.SelectedColor:Unpack())
				surface.DrawOutlinedRect(0, 0, w, h, 2)
			end
		end

		if existing and existing.category == category.id then
			selectedCategoryPnl = pnl
		end

		i = i + 1
	end

	local priceEntry = frame:Add("DTextEntry")
	priceEntry:SetNumeric(true)
	priceEntry:SetPlaceholderText("Price")
	priceEntry:Dock(TOP)
	priceEntry:DockMargin(0, 0, 0, gap)
	if existing then
		priceEntry:SetValue(existing.price)
	end

	local sellPriceEntry = frame:Add("DTextEntry")
	sellPriceEntry:SetNumeric(true)
	sellPriceEntry:SetPlaceholderText("Sell price")
	sellPriceEntry:Dock(TOP)
	sellPriceEntry:DockMargin(0, 0, 0, gap)
	if existing and existing.sellPrice then
		sellPriceEntry:SetValue(existing.sellPrice)
	end

	local classPicker = frame:Add("FactionSelect")
	classPicker:Dock(TOP)
	classPicker:SetTall(150)
	classPicker:DockMargin(0, 0, 0, gap)
	if existing then
		classPicker:SetClasses(BuyMenu.GetClassTable(existing.classes))
	end

	local stockPoolShortcut = frame:Add("DButton")
	stockPoolShortcut:Dock(TOP)
	stockPoolShortcut:DockMargin(0, 0, 0, gap)
	stockPoolShortcut:SetText("Create New Stock Pool")
	stockPoolShortcut.DoClick = function()
		ConfigStock(p)
	end

	local stockPoolPicker = frame:Add("DListView")
	stockPoolPicker:Dock(TOP)
	stockPoolPicker:SetTall(100)
	stockPoolPicker:AddColumn("ID")
	stockPoolPicker:AddColumn("Max Stock")
	stockPoolPicker:AddColumn("Current Stock")
	stockPoolPicker:AddColumn("Restock Amount")
	stockPoolPicker:AddColumn("Restock Interval")
	stockPoolPicker:SetMultiSelect(false)
	frame.StockPools = stockPoolPicker

	for _, pool in pairs(BuyMenu.StockPools) do
		local line = stockPoolPicker:AddLine(pool:GetID(), pool:GetMaxStock(), pool:GetStock(), pool:GetRestockAmt(), pool:GetStockInterval())
		if existing and existing.pool == pool:GetID() then
			line:SetSelected(true)
		end
	end

	local saveBtn = frame:Add("DButton")
	saveBtn:SetText("Save")
	saveBtn:Dock(BOTTOM)
	saveBtn.DoClick = function()
		local _, selectedLine = itemPicker:GetSelectedLine()
		if !IsValid(selectedLine) then
			nut.util.notify("No item selected!")
			return
		end
		local item = selectedLine:GetValue(2)

		local price = tonumber(priceEntry:GetValue())
		if !price then
			nut.util.notify("No price inputted!")
			return
		end

		local sellPrice = tonumber(sellPriceEntry:GetValue()) or 0

		if !IsValid(selectedCategoryPnl) then
			nut.util.notify("No category selected!")
			return
		end
		local category = selectedCategoryPnl:GetCategory()

		local classes = classPicker:GetClasses()
		if next(classes) == nil then
			nut.util.notify("No classes selected!")
			return
		end

		local classStr = BuyMenu.GetClassString(classes)

		_, selectedLine = stockPoolPicker:GetSelectedLine()
		local selectedPool = selectedLine and selectedLine:GetValue(1) or 0

		if existing then
			net.Start("BuyMenuItemUpdate")
			net.WriteUInt(existing.id, 16)
		else
			net.Start("BuyMenuItemCreate")
		end

		net.WriteString(item)
		net.WriteUInt(math.abs(price), 32)
		net.WriteUInt(math.abs(sellPrice), 32)
		net.WriteUInt(category.id, 8)
		jlib.WriteCompressedString(classStr)
		net.WriteUInt(selectedPool, 16)
		net.WriteUInt(IsValid(frame.RarityPicker) and frame.RarityPicker:GetOptionData(frame.RarityPicker:GetSelectedID()) or 0, 8)
		net.SendToServer()

		frame:Close()
	end

	return frame
end

function BuyMenu.ConfigCategories()
	if IsValid(BuyMenu.CategoryConfigurator) then
		BuyMenu.CategoryConfigurator:Close()
	end

	local frame = vgui.Create("DFrame")
	frame:SetSize(800, 600)
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("Category Config")

	local scroll = frame:Add("UI_DScrollPanel")
	scroll:Dock(FILL)

	local lastPnl
	local btnW = 100
	for id, category in pairs(BuyMenu.Categories) do
		local pnl = scroll:Add("BuyMenuConfigCategory")
		pnl:SetSize(600, 50)
		pnl:SetCategory(category)

		local editBtn = pnl:Add("DButton")
		editBtn:SetText("Edit")
		editBtn:SetWide(btnW)
		editBtn:SetPos((pnl:GetWide() / 2) - (editBtn:GetWide() * 1.1), pnl:GetTall() - editBtn:GetTall() - 2)
		editBtn.DoClick = function()
			ConfigCategory(frame, category)
		end

		local removeBtn = pnl:Add("DButton")
		removeBtn:SetText("Remove")
		removeBtn:SetWide(btnW)
		removeBtn:SetPos((pnl:GetWide() / 2) + (removeBtn:GetWide() * 0.1), pnl:GetTall() - removeBtn:GetTall() - 2)
		removeBtn.DoClick = function()
			net.Start("BuyMenuCategoryRemove")
				net.WriteUInt(category.id, 8)
			net.SendToServer()
		end

		pnl:SetPos(frame:GetWide() / 2 - pnl:GetWide() / 2)
		if IsValid(lastPnl) then
			pnl:MoveBelow(lastPnl, 6)
		end

		lastPnl = pnl
	end

	local createNewBtn = frame:Add("DButton")
	createNewBtn:SetText("Create New")
	createNewBtn:Dock(BOTTOM)
	createNewBtn.DoClick = function()
		ConfigCategory(frame)
	end

	BuyMenu.CategoryConfigurator = frame
end

function BuyMenu.ConfigItems()
	if IsValid(BuyMenu.ItemConfigurator) then
		BuyMenu.ItemConfigurator:Close()
	end

	local frame = vgui.Create("DFrame")
	frame:SetSize(800, 700)
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("Item Config")

	local scroll = frame:Add("DScrollPanel")
	scroll:Dock(FILL)

	function scroll:FillWithFactionPnls(search)
		-- -1 = all -2 = unassigned
		for factionID, fac in ipairs({-1, -2, unpack(nut.faction.indices)}) do
			local faction

			if fac == -1 then
				faction = {name = "All"}
			elseif fac == -2 then
				faction = {name = "Unassigned"}
			else
				faction = fac
			end

			factionID = factionID - 2

			if !faction.name:lower():find(search:lower(), 1, true) then
				continue
			end

			local factionPopup = scroll:Add("UI_DButton")
			factionPopup:Dock(TOP)
			factionPopup:SetText("➤ " .. faction.name)

			factionPopup.DoClick = function()
				local popup = frame:Add("DFrame")
				popup:SetTitle(faction.name)
				popup:SetSize(700, 600)
				popup:Center()

				local popupScroll = popup:Add("DScrollPanel")
				popupScroll:Dock(FILL)

				function popupScroll:FillWithCategories()
					for id, cat in pairs(BuyMenu.Categories) do
						local shouldKeep = false

						for _, item in pairs(BuyMenu.Items) do
							if item.category != cat.id then
								continue
							end

							for classID, _ in pairs(BuyMenu.GetClassTable(item.classes)) do
								local classTbl = nut.class.list[BuyMenu.ClassToID[classID]]

								if classTbl and classTbl.faction == factionID then
									shouldKeep = true
									break
								end
							end
						end

						if !shouldKeep then continue end

						local catBtn = popupScroll:Add("UI_DButton")
						catBtn:SetText("➤ " .. cat.name)
						catBtn:Dock(TOP)
						catBtn.DoClick = function(s)
							popupScroll:Clear()
							popupScroll:FillWithItems(cat.name)
						end
					end
				end

				function popupScroll:FillWithItems(srch)
					local i = 0
					for id, item in pairs(BuyMenu.Items) do
						local itemTbl = nut.item.list[item.item]

						if fac == -2 and item.classes != BuyMenu.DefaultClasses then
							continue
						end

						if !itemTbl or (!itemTbl.name:lower():find(srch:lower(), 1, true) and !BuyMenu.Categories[item.category].name:lower():find(srch:lower(), 1, true))  then
							continue
						end

						local shouldKeep = isnumber(fac)

						if !shouldKeep then -- NOTE: Fills admin "item editor" with listings
							for classID, _ in pairs(BuyMenu.GetClassTable(item.classes)) do
								for nutIndex, nutClass in pairs(nut.class.list) do
									if nutClass.uniqueID == classID and nutClass.faction == factionID then
										shouldKeep = true
										break
									end
								end
							end
						end

						if !shouldKeep then continue end

						local itemPanel = popupScroll:Add("BuyMenuItem")
						itemPanel:SetItem(item)
						itemPanel:Dock(TOP)
						itemPanel:DockMargin(5, 5, 5, 5)
						itemPanel.Price:Remove()
						itemPanel.CapsIcon:Remove()
						itemPanel.SpawnIcon.DoClick = nil

						if IsValid(itemPanel.ModeToggle) then
							itemPanel.ModeToggle:Remove()
						end

						local editBtn = itemPanel:Add("UI_DButton")
						editBtn:SetSize(itemPanel:GetWide() / 2, editBtn:GetTall())
						editBtn:SetPos(0, itemPanel:GetTall() - editBtn:GetTall())
						editBtn:SetText("Edit")
						editBtn:SetContentAlignment(5)
						editBtn.DoClick = function()
							ConfigItem(frame, item)
						end

						local removeBtn = itemPanel:Add("UI_DButton")
						removeBtn:SetSize(itemPanel:GetWide() / 2, removeBtn:GetTall())
						removeBtn:SetPos(itemPanel:GetWide() / 2, itemPanel:GetTall() - removeBtn:GetTall())
						removeBtn:SetText("Remove")
						removeBtn:SetContentAlignment(5)
						removeBtn.DoClick = function()
							net.Start("BuyMenuItemRemove")
								net.WriteUInt(item.id, 16)
							net.SendToServer()
							itemPanel:Remove()
						end

						i = i + 1
					end
				end

				popupScroll:FillWithCategories()
				popupScroll:FillWithItems("")

				local itemSearch = popup:Add("UI_DTextEntry")
				itemSearch:Dock(BOTTOM)
				itemSearch:SetPlaceholderText("Search...")
				itemSearch.OnEnter = function(s)
					popupScroll:Clear()
					popupScroll:FillWithItems(s:GetValue())
				end

				local resetBtn = popup:Add("UI_DButton")
				resetBtn:SetText("Reset Filter")
				resetBtn.DoClick = function()
					popupScroll:Clear()
					popupScroll:FillWithCategories()
					popupScroll:FillWithItems("")
				end
				resetBtn:Dock(TOP)
			end
		end
	end

	scroll:FillWithFactionPnls("")

	local createNewBtn = frame:Add("DButton")
	createNewBtn:SetText("Create New")
	createNewBtn:Dock(BOTTOM)
	createNewBtn.DoClick = function()
		frame.ItemConf = ConfigItem(frame)
	end

	local factionSearch = frame:Add("UI_DTextEntry")
	factionSearch:Dock(BOTTOM)
	factionSearch:SetPlaceholderText("Search...")
	factionSearch.OnEnter = function(s)
		scroll:Clear()
		scroll:FillWithFactionPnls(s:GetValue())
	end

	BuyMenu.ItemConfigurator = frame
end

local function FillWithPoolPanels(frame, scroll, factionID)
	local poolToItemsCache = {}
	for _, item in ipairs(BuyMenu.Items) do
		if item.pool then
			poolToItemsCache[item.pool] = poolToItemsCache[item.pool] or {}
			poolToItemsCache[item.pool][item.id] = item
		end
	end

	local lastPoolPnl
	for id, pool in pairs(BuyMenu.StockPools) do
		local poolPnl = scroll:Add("DPanel")
		poolPnl:SetSize(500, 100)
		poolPnl:SetPos(frame:GetWide() / 2 - poolPnl:GetWide() / 2, 0)

		local idDisplay = poolPnl:Add("DLabel")
		idDisplay:SetPos(5, 0)
		idDisplay:SetText(pool:GetID())

		local stockTrack = poolPnl:Add("DLabel")
		stockTrack:SetPos(5, 0)
		stockTrack:SetText("Stock:")
		stockTrack:SizeToContents()
		stockTrack:SetWide(poolPnl:GetWide())
		stockTrack:MoveBelow(idDisplay, 2)
		stockTrack.Think = function(s)
			s:SetText(string.format("Stock: %u / %u", pool:GetStock(), pool:GetMaxStock()))
		end

		local lastRestock = poolPnl:Add("DLabel")
		lastRestock:SetPos(5, 0)
		lastRestock:SetText("Last restock: " .. os.date("%B %d" .. STNDRD(os.date("%d", pool:GetLastRestock())) .. " %I:%M %p", pool:GetLastRestock()))
		lastRestock:SizeToContents()
		lastRestock:SetWide(poolPnl:GetWide())
		lastRestock:MoveBelow(stockTrack, 2)

		local stockTimeTrack = poolPnl:Add("DLabel")
		stockTimeTrack:SetPos(5, 0)
		stockTimeTrack:SetText("Restocks in:")
		stockTimeTrack:SizeToContents()
		stockTimeTrack:SetWide(poolPnl:GetWide())
		stockTimeTrack:MoveBelow(lastRestock, 2)
		stockTimeTrack.Think = function(s)
			local time = string.FormattedTime(pool:GetNextRestock() - jlib.GetServerTime())
			s:SetText(string.format("Restocks in: %02i:%02i:%02i:%02i", time.h, time.m, time.s, time.ms))
		end

		local editBtn = poolPnl:Add("DButton")
		editBtn:SetSize(poolPnl:GetWide() / 3, editBtn:GetTall())
		editBtn:SetText("Edit")
		editBtn:SetContentAlignment(5)
		editBtn.DoClick = function()
			ConfigStock(frame, pool)
		end

		local restockBtn = poolPnl:Add("DButton")
		restockBtn:SetSize(poolPnl:GetWide() / 3, restockBtn:GetTall())
		restockBtn:SetText("Restock")
		restockBtn:SetContentAlignment(5)
		restockBtn.DoClick = function()
			net.Start("BuyMenuManualRestock")
				net.WriteUInt(pool:GetID(), 16)
			net.SendToServer()
		end

		local removeBtn = poolPnl:Add("DButton")
		removeBtn:SetSize(poolPnl:GetWide() / 3, removeBtn:GetTall())
		removeBtn:SetText("Remove")
		removeBtn:SetContentAlignment(5)
		removeBtn.DoClick = function()
			net.Start("BuyMenuStockRemove")
				net.WriteUInt(pool:GetID(), 16)
			net.SendToServer()
		end

		local shouldKeep = factionID == nil

		local labels = 0
		local lastPanel
		for _, item in pairs(poolToItemsCache[pool:GetID()] or {}) do
			local itemData = nut.item.list[item.item]

			local itemLabel = poolPnl:Add("DLabel")
			itemLabel:SetText(itemData and itemData.name or "Item not found - " .. item.item)
			itemLabel:SetPos(10, 0)
			itemLabel:SetSize(0, 14)
			itemLabel:SizeToContentsX()
			itemLabel:MoveBelow(lastPanel or stockTimeTrack, lastPanel and 0 or 6)

			if factionID then
				for classID, _ in pairs(BuyMenu.GetClassTable(item.classes)) do
					local classTbl = nut.class.list[BuyMenu.ClassToID[classID]]

					if classTbl.faction == factionID then
						shouldKeep = true
						break
					end
				end
			end

			lastPanel = itemLabel
			labels = labels + 1
		end

		if !shouldKeep then
			poolPnl:Remove()
			continue
		end

		poolPnl:SetTall(poolPnl:GetTall() + (labels > 0 and 6 or 0) + (labels * 16))

		editBtn:SetPos(0, poolPnl:GetTall() - editBtn:GetTall())
		restockBtn:SetPos((poolPnl:GetWide() / 3) + 1, poolPnl:GetTall() - restockBtn:GetTall())
		removeBtn:SetPos(poolPnl:GetWide() - removeBtn:GetWide(), poolPnl:GetTall() - removeBtn:GetTall())

		if IsValid(lastPoolPnl) then
			poolPnl:MoveBelow(lastPoolPnl, 10)
		end

		lastPoolPnl = poolPnl
	end
end

function BuyMenu.ConfigStockPools()
	if IsValid(BuyMenu.StockPoolConfigurator) then
		BuyMenu.StockPoolConfigurator:Close()
	end

	local frame = vgui.Create("DFrame")
	frame:SetSize(800, 600)
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("Stock Pool Config")

	local scroll = frame:Add("DScrollPanel")
	scroll:Dock(FILL)

	FillWithPoolPanels(frame, scroll)

	local createNewBtn = frame:Add("DButton")
	createNewBtn:SetText("Create New")
	createNewBtn:Dock(BOTTOM)
	createNewBtn.DoClick = function()
		ConfigStock(frame)
	end

	local factionFilter = frame:Add("DComboBox")
	factionFilter:Dock(BOTTOM)

	for i, faction in ipairs(nut.faction.indices) do
		factionFilter:AddChoice(faction.name, i)
	end

	factionFilter.OnSelect = function(self, i, name, dat)
		scroll:Clear()
		FillWithPoolPanels(frame, scroll, i)
	end

	BuyMenu.StockPoolConfigurator = frame
end

-- Networking
net.Receive("BuyMenuCategories", function()
	BuyMenu.Categories = jlib.ReadCompressedTable()
end)

net.Receive("BuyMenuItems", function()
	BuyMenu.Items = jlib.ReadCompressedTable()
end)

net.Receive("BuyMenuStockPools", function()
	BuyMenu.StockPools = jlib.ReadCompressedTable()

	for _, pool in pairs(BuyMenu.StockPools) do
		setmetatable(pool, BuyMenu.StockPoolMeta)
	end
end)

net.Receive("BuyMenuClasses", function()
	BuyMenu.IDToClass = jlib.ReadCompressedTable()
	BuyMenu.ClassToID = jlib.ReadCompressedTable()
end)

net.Receive("BuyMenuCategoryCreate", function()
	local id = net.ReadUInt(8)
	local name = net.ReadString()
	local icon = net.ReadUInt(32)

	BuyMenu.Categories[id] = {id = id, name = name, icon = icon}

	if IsValid(BuyMenu.CategoryConfigurator) then
		BuyMenu.ConfigCategories()
	end
end)

net.Receive("BuyMenuCategoryRemove", function()
	local id = net.ReadUInt(8)

	BuyMenu.Categories[id] = nil

	if IsValid(BuyMenu.CategoryConfigurator) then
		BuyMenu.ConfigCategories()
	end
end)

net.Receive("BuyMenuItemCreate", function()
	local id = net.ReadUInt(16)
	local item = net.ReadString()
	local price = net.ReadUInt(32)
	local sellPrice = net.ReadUInt(32)
	local categoryID = net.ReadUInt(8)
	local classes = jlib.ReadCompressedString()
	local stockPoolID = net.ReadUInt(16)
	local rarity = net.ReadUInt(8)
	stockPoolID = stockPoolID != 0 and stockPoolID or nil
	rarity = rarity > 0 and rarity or nil

	BuyMenu.Items[id] = {id = id, item = item, price = price, sellPrice = sellPrice != 0 and sellPrice or nil, category = categoryID, classes = classes, pool = stockPoolID, rarity = rarity}

	// if IsValid(BuyMenu.ItemConfigurator) then
	// 	BuyMenu.ConfigItems()
	// end
end)

net.Receive("BuyMenuItemRemove", function()
	local id = net.ReadUInt(16)

	BuyMenu.Items[id] = nil

	// if IsValid(BuyMenu.ItemConfigurator) then
	// 	BuyMenu.ConfigItems()
	// end
end)

net.Receive("BuyMenuStockCreate", function()
	local id = net.ReadUInt(16)
	local pool = BuyMenu.StockPools[id]

	if IsValid(BuyMenu.StockPoolConfigurator) then
		BuyMenu.ConfigStockPools()
	end

	-- Automatically populate and select the newly created stock pool if the item configuration
	-- is in use.
	if IsValid(BuyMenu.ItemConfigurator) and IsValid(BuyMenu.ItemConfigurator.ItemConf) then
		local listview = BuyMenu.ItemConfigurator.ItemConf.StockPools
		listview:SelectItem(listview:AddLine(pool:GetID(), pool:GetMaxStock(), pool:GetStock(), pool:GetRestockAmt(), pool:GetStockInterval()))
		chat.AddText("New stock pool selected")
	end
end)

net.Receive("BuyMenuStockRemove", function()
	local id = net.ReadUInt(16)
	local pool = BuyMenu.StockPools[id]
	pool:Remove()

	if IsValid(BuyMenu.StockPoolConfigurator) then
		BuyMenu.ConfigStockPools()
	end
end)
