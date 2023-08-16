-- Fonts
surface.CreateFont("Marketplace3D2D", {font = "Roboto", size = 128})

-- Networking
function Marketplace.CreateListing(itemIDs, price)
	net.Start("MarketplaceCreateListing")
		jlib.WriteCompressedTable(itemIDs)
		net.WriteInt(math.floor(price), 32)
	net.SendToServer()
end

function Marketplace.BuyFromListing(listingID, amt)
	net.Start("MarketplaceBuy")
		net.WriteInt(listingID, 32)
		net.WriteInt(amt, 32)
	net.SendToServer()
end

function Marketplace.CancelListing(listingID)
	net.Start("MarketplaceCancel")
		net.WriteInt(listingID, 32)
	net.SendToServer()
end

function Marketplace.ClaimSale(itemID)
	net.Start("MarketplaceClaimSale")
		net.WriteInt(itemID, 32)
	net.SendToServer()
end

function Marketplace.ClaimAllSales()
	net.Start("MarketplaceClaimAllSales")
	net.SendToServer()
end

function Marketplace.ClaimItem(itemID)
	net.Start("MarketplaceClaimItem")
		net.WriteInt(itemID, 32)
	net.SendToServer()
end

--[[function Marketplace.ClaimAllItems()
	net.Start("MarketplaceClaimAllItems")
	net.SendToServer()
end]]

net.Receive("MarketplaceListingFinished", function()
	if IsValid(Marketplace.UI) and IsValid(Marketplace.UI.RightPanel) and Marketplace.UI.FilledWithListables == false then
		if IsValid(Marketplace.UI.RightPanel.Loading) then
			Marketplace.UI.RightPanel.Loading:Remove()
		end
		Marketplace.FillWithListables(Marketplace.UI.RightPanel.ScrollPnl)
		Marketplace.UI.LeftPanel.FillWithListings()
	end
end)

net.Receive("MarketplaceOpenMenu", function()
	if !IsValid(Marketplace.UI) then
		vgui.Create("Marketplace_Main")
	end
end)

-- UI Elements
--Marketplace.HaloEnts = {}

function Marketplace.GetMaxLen(pnlW, font)
	surface.SetFont(font)
	return math.floor(pnlW / surface.GetTextSize("_"))
end

function Marketplace.AddLoadingText(pnl)
	if !IsValid(pnl) then return end

	if IsValid(pnl.Loading) then
		pnl.Loading:Remove()
	end

	pnl.Loading = pnl:Add("UI_DLabel")
	pnl.Loading:SetText("Loading...")
	pnl.Loading:SizeToContents()
	pnl.Loading:Center()
	pnl.Loading.Think = function(s)
		s:SetText(jlib.DotDotDot("Loading"))
	end
end

function Marketplace.FillWithListables(pnl)
	local i = 0

	Marketplace.UI.ListableItems = {}

	pnl:Clear()

	for _, item in pairs(LocalPlayer():getChar():getInv():getItems()) do
		if Marketplace.IsItemBlacklisted(item.uniqueID) then
			Marketplace.Print("Skipping blacklisted item " .. item.uniqueID)
			continue
		end

		local shouldContinue = false

		for data, details in pairs(Marketplace.UI.ListableItems) do
			if item.uniqueID == details.uniqueID and Marketplace.CompareTables(item.data, data) then
				table.insert(details.items, item:getID())
				shouldContinue = true
			end
		end

		if shouldContinue then continue end

		local itemPnl = pnl:Add("Marketplace_InvItem")
		itemPnl:SetPos((pnl:GetWide() / 2) - (itemPnl:GetWide() / 2), (itemPnl:GetTall() * i) + (10 * (i + 1)))
		itemPnl:SetItem(item)

		Marketplace.UI.ListableItems[item.data] = {
			uniqueID = item.uniqueID,
			items = {}
		}
		table.insert(Marketplace.UI.ListableItems[item.data].items, item:getID())

		i = i + 1
	end

	Marketplace.UI.FilledWithListables = true
end

local PANEL = {}

PANEL.AnimSpeed = 0.7

function PANEL:Init()
	Marketplace.UI = self

	self:SetSize(700, 800)
	self:ScaleToRes(1920, 1080)
	self:Center()
	self:MakePopup()
	self:SetTitle("")
	self:ShowCloseButton(false)
	self:SetDraggable(false)

	self.RemoveOnCloseTbl = {}

	self.ScrollPnl = self:Add("UI_DScrollPanel")
	self.ScrollPnl:SetSize(self:GetSize())
	self.ScrollPnl:SetTall(self.ScrollPnl:GetTall() - 80)

	local sX, sY = self:GetPos()

	self.LogoPnl = vgui.Create("jRemoteImage")
	self.LogoPnl:SetURL(Marketplace.Config.LogoURL, function(succ, mat)
		if succ and IsValid(self.LogoPnl) then
			local w, h = mat:Width(), mat:Height()
			self.LogoPnl:SetSize(w, h)
			self.LogoPnl:ScaleToRes(1920, 1080)
			self.LogoPnl:SetPos(sX + ((self:GetWide() / 2) - (self.LogoPnl:GetWide() / 2)), sY - self.LogoPnl:GetTall() - 5)
		end
	end)
	self.LogoPnl:SetColor(nut.gui.palette.color_primary)
	self:RemoveOnClose(self.LogoPnl)

	self.LeftPanel = vgui.Create("UI_DPanel_Bordered")
	self.LeftPanel:SetSize(340, 800)
	self.LeftPanel:ScaleToRes(1920, 1080)
	self.LeftPanel:SetPos(self:GetPos())
	self.LeftPanel:MoveLeftOf(self, 5)
	self:RemoveOnClose(self.LeftPanel)

	self.LeftPanel.ScrollPnl = self.LeftPanel:Add("UI_DScrollPanel")
	self.LeftPanel.ScrollPnl:SetSize(self.LeftPanel:GetSize())
	self.LeftPanel.ScrollPnl:SetTall(self.LeftPanel.ScrollPnl:GetTall() - 160)
	self.LeftPanel.ScrollPnl:SetPos(0, 40)

	self.LeftPanel.Title = self.LeftPanel:Add("UI_DLabel")
	self.LeftPanel.Title:SetText("Active Listings")
	self.LeftPanel.Title:SizeToContents()
	self.LeftPanel.Title:SetPos(0, 20)
	self.LeftPanel.Title:CenterHorizontal()

	self.CloseBtn = self.LeftPanel:Add("UI_DButton")
	self.CloseBtn:SetText("Close")
	self.CloseBtn:Dock(BOTTOM)
	self.CloseBtn:DockMargin(10, 0, 10, 10)
	self.CloseBtn.DoClick = function(s)
		self:Close()
	end

	self.CategoryBtn = self.LeftPanel:Add("UI_DButton")
	self.CategoryBtn:SetText("Browse Category")
	self.CategoryBtn:Dock(BOTTOM)
	self.CategoryBtn:DockMargin(10, 0, 10, 2)
	self.CategoryBtn.DoClick = function(s)
		local menu = vgui.Create("UI_DMenu")
		menu:Open()

		for i, cat in ipairs(Marketplace.CategoryList or {}) do
			menu:AddOption(cat, function()
				self:CategorySearch(cat)
			end)
		end
		local children = menu:GetChildren()
		for i, child in ipairs(children) do
			child:ScaleToRes(ScrW(), 1080)
		end
		menu:SetTall((#children * (children[1]:GetTall() + menu:GetPadding())) + menu:GetPadding())

		self:RemoveOnClose(menu)
	end

	self.SearchBtn = self.LeftPanel:Add("UI_DButton")
	self.SearchBtn:SetText("Search")
	self.SearchBtn:Dock(BOTTOM)
	self.SearchBtn:DockMargin(10, 0, 10, 2)
	self.SearchBtn.DoClick = function(s)
		local searchPnl = self:Add("UI_DPanel_Bordered")
		searchPnl:SetSize(600, 200)
		searchPnl:ScaleToRes(1920, 1080)
		searchPnl:Center()

		local searchLabel = searchPnl:Add("UI_DLabel")
		searchLabel:SetPos(0, searchPnl:GetTall() / (6 + (2 / 3)))
		searchLabel:SetFont("UI_Bold")
		searchLabel:SetText("Market Search")
		searchLabel:SizeToContents()
		searchLabel:CenterHorizontal()

		local searchEntry = searchPnl:Add("UI_DTextEntry")
		searchEntry:SetWide(searchPnl:GetWide() / 2)
		searchEntry:Center()
		searchEntry.OnEnter = function()
			self:Search(searchEntry:GetText())
			searchPnl:Remove()
		end
		searchEntry:RequestFocus()

		local marginTop = searchPnl:GetWide() / 4
		local marginSideBottom = searchPnl:GetTall() / 20

		local confirm = searchPnl:Add("UI_DButton")
		confirm:SetText("Search")
		confirm:Dock(LEFT)
		confirm:DockMargin(marginSideBottom, marginTop, 0, marginSideBottom)
		confirm.DoClick = function()
			if IsValid(self.LoadMore) and !self.Searching then
				if searchEntry:GetText() != "" then
					self:Search(searchEntry:GetText())
					self.LoadMore:SetDisabled(true)
				else
					self:ResetToFirstPage()
					self.LoadMore:SetDisabled(false)
				end
				searchPnl:Remove()
			elseif self.Searching then
				Marketplace.Notify("A search is already ongoing, please wait.")
			end
		end
		confirm:SetWide(searchPnl:GetWide() / 3)
		confirm:SetContentAlignment(5)

		local cancel = searchPnl:Add("UI_DButton")
		cancel:SetText("Cancel")
		cancel:Dock(RIGHT)
		cancel:DockMargin(0, marginTop, marginSideBottom, marginSideBottom)
		cancel.DoClick = function()
			searchPnl:Remove()
		end
		cancel:SetWide(searchPnl:GetWide() / 3)
		cancel:SetContentAlignment(5)

		jlib.AddBackgroundBlur(searchPnl)
	end

	self.LeftPanel.FillWithListings = function()
		self.LeftPanel.ScrollPnl:Clear()

		Marketplace.AddLoadingText(self.LeftPanel)

		Marketplace.GetActiveListings(LocalPlayer():SteamID(), LocalPlayer():getChar():getID(), function(listings)
			if !IsValid(self) then return end
			if listings == nil then return end

			self.LeftPanel.Loading:Remove()

			local space = 10
			local listingPnls = {}
			local continued = 0

			for i, listing in ipairs(listings) do
				if !nut.item.list[listing.itemID] then continued = continued + 1 continue end

				i = i - continued

				local listingPnl = self.LeftPanel.ScrollPnl:Add("Marketplace_Listing")
				listingPnl:SetWide(275)
				listingPnl:ScaleToRes(1920, ScrH())
				listingPnl:SetListing(listing)
				listingPnl:SetPos(0, (listingPnl:GetTall() * (i - 1)) + (i * space))
				listingPnl:CenterHorizontal()
				listingPnl.PriceLabel:Remove()
				listingPnl.OtherBtn:Remove()
				listingPnl.DetailsBtn.DoClick = function()
					local itemPnl = Marketplace.UI:Add("Marketplace_ListingDetails")
					itemPnl:Center()
					itemPnl:SetListing(listing)
					itemPnl:SetTall(250)

					local margin = {itemPnl.CloseBtn:GetDockMargin()}
					margin[4] = 0

					local cancelBtn = itemPnl:Add("UI_DButton")
					cancelBtn:SetText("Cancel Listing")
					cancelBtn:Dock(BOTTOM)
					cancelBtn:DockMargin(unpack(margin))
					cancelBtn:SetContentAlignment(5)

					cancelBtn.DoClick = function()
						listingPnl.DetailsBtn:SetDisabled(true)

						local _, y = listingPnl:GetPos()
						local id = table.RemoveByValue(listingPnls, listingPnl)

						listingPnl:MoveTo(self.LeftPanel.ScrollPnl:GetWide(), y, 0.7, 0, -1, function()
							for j = id, #listingPnls do
								local pnl = listingPnls[j]
								local x = pnl:GetPos()
								pnl:MoveTo(x, (listingPnl:GetTall() * (j - 1)) + (j * space), 0.7)
							end

							listingPnl:Remove()
						end)
						Marketplace.CancelListing(listing.id)
						itemPnl:Remove()
					end
				end
				table.insert(listingPnls, listingPnl)
			end
		end)
	end
	self.LeftPanel.FillWithListings()

	self.RightPanel = vgui.Create("UI_DPanel_Bordered")
	self.RightPanel:SetSize(340, 800)
	self.RightPanel:ScaleToRes(1920, 1080)
	self.RightPanel:SetPos(self:GetPos())
	self.RightPanel:MoveRightOf(self, 5)
	self:RemoveOnClose(self.RightPanel)

	self.RightPanel.ScrollPnl = self.RightPanel:Add("UI_DScrollPanel")
	self.RightPanel.ScrollPnl:SetSize(self.RightPanel:GetSize())
	self.RightPanel.ScrollPnl:SetTall(self.RightPanel.ScrollPnl:GetTall() - 80)

	Marketplace.FillWithListables(self.RightPanel.ScrollPnl)

	self.RightPanel.UnclaimedSales = self.RightPanel:Add("UI_DButton")
	self.RightPanel.UnclaimedSales:SetText("Unclaimed Sales")
	self.RightPanel.UnclaimedSales:Dock(BOTTOM)
	self.RightPanel.UnclaimedSales:DockMargin(10, 0, 10, 10)
	self.RightPanel.UnclaimedSales:SetContentAlignment(6)
	self.RightPanel.UnclaimedSales.DoClick = function()
		local salePnls = {}

		local ucSalesPnl = self:Add("UI_DPanel_Bordered")
		ucSalesPnl:SetSize(500, 500)
		ucSalesPnl:ScaleToRes(1920, 1080)
		ucSalesPnl:Center()
		Marketplace.AddLoadingText(ucSalesPnl)

		local scrollPnl = ucSalesPnl:Add("UI_DScrollPanel")
		scrollPnl:SetSize(ucSalesPnl:GetWide(), ucSalesPnl:GetTall() - 80)

		Marketplace.GetUnclaimedSales(LocalPlayer():SteamID(), LocalPlayer():getChar():getID(), function(ucSales)
			local space = 10

			if IsValid(self) and IsValid(ucSalesPnl) then
				ucSalesPnl.Loading:Remove()

				local i = 1
				for _, sale in ipairs(ucSales) do
					local nsItem = nut.item.list[sale.uniqueID]

					if !nsItem then continue end

					local salePnl = scrollPnl:Add("UI_DPanel_Bordered")
					salePnl:SetSize(350, 130)
					salePnl:ScaleToRes(1920, 1080)
					salePnl.Paint = function(s, w, h)
						surface.SetDrawColor(nut.gui.palette.color_background:Unpack())
						surface.DrawRect(0, 0, w, h)

						surface.SetDrawColor(0, 0, 0)
						surface.DrawOutlinedRect(2, 2, w - 1, h - 1)

						surface.SetDrawColor(nut.gui.palette.color_primary:Unpack())
						surface.DrawOutlinedRect(0, 0, w, h)
						surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
					end

					salePnl:SetPos(0, (salePnl:GetTall() * (i - 1)) + (space * i))
					salePnl:CenterHorizontal()

					local iconSize = salePnl:GetTall() * 0.9
					local icon = salePnl:Add("nutSpawnIcon")
					icon:SetModel(nsItem.model)
					icon:SetSize(iconSize, iconSize)
					icon:CenterVertical()

					local title = salePnl:Add("UI_DLabel")
					title:SetText(nsItem.name)
					title:SizeToContents()
					title:SetPos(0, 10)
					title:CenterHorizontal()

					local salePrice = salePnl:Add("UI_DLabel")
					salePrice:SetText("Sale price: " .. sale.price)
					salePrice:SizeToContents()
					salePrice:MoveBelow(title, 4)
					salePrice:CenterHorizontal()

					local profits = salePnl:Add("UI_DLabel")
					profits:SetText("Profit after tax: " .. Marketplace.Tax(sale.price))
					profits:SizeToContents()
					profits:MoveBelow(salePrice, 4)
					profits:CenterHorizontal()

					local claimBtn = salePnl:Add("UI_DButton")
					claimBtn:SetText("Claim")
					claimBtn:Dock(BOTTOM)
					claimBtn:DockMargin(100, 0, 100, 10)
					claimBtn:SetContentAlignment(5)
					claimBtn.DoClick = function()
						claimBtn:SetDisabled(true)

						local _, y = salePnl:GetPos()
						local id = table.RemoveByValue(salePnls, salePnl)

						salePnl:MoveTo(scrollPnl:GetWide(), y, 0.7, 0, -1, function()
							for j = id, #salePnls do
								local pnl = salePnls[j]
								local x = pnl:GetPos()
								pnl:MoveTo(x, (salePnl:GetTall() * (j - 1)) + (space * j), 0.7)
							end

							salePnl:Remove()
						end)

						Marketplace.ClaimSale(sale.id)
					end
					salePnl.claimBtn = claimBtn

					table.insert(salePnls, salePnl)

					i = i + 1
				end
			end
		end)

		local closeBtn = ucSalesPnl:Add("UI_DButton")
		closeBtn:SetText("Close")
		closeBtn:Dock(BOTTOM)
		closeBtn.DoClick = function()
			ucSalesPnl:Remove()
		end
		closeBtn:DockMargin(10, 0, 10, 10)

		local claimAllBtn = ucSalesPnl:Add("UI_DButton")
		claimAllBtn:SetText("Claim All")
		claimAllBtn:Dock(BOTTOM)
		claimAllBtn.DoClick = function()
			for i, pnl in ipairs(salePnls) do
				pnl.claimBtn:SetDisabled(true)

				local _, y = pnl:GetPos()

				pnl:MoveTo(scrollPnl:GetWide(), y, 0.7, 0, -1, function()
					table.RemoveByValue(salePnls, pnl)
					pnl:Remove()
				end)
			end

			if #salePnls > 0 then
				Marketplace.ClaimAllSales()
				surface.PlaySound("buymenu/kaching.wav")
			else
				Marketplace.Notify("No sales to claim.")
			end
		end
		claimAllBtn:DockMargin(10, 0, 10, 2)


		jlib.AddBackgroundBlur(ucSalesPnl)
	end

	self.RightPanel.UnclaimedItems = self.RightPanel:Add("UI_DButton")
	self.RightPanel.UnclaimedItems:SetText("Unclaimed Items")
	self.RightPanel.UnclaimedItems:Dock(BOTTOM)
	self.RightPanel.UnclaimedItems:DockMargin(10, 0, 10, 2)
	self.RightPanel.UnclaimedItems:SetContentAlignment(6)
	self.RightPanel.UnclaimedItems.DoClick = function()
		local itemPnls = {}

		local ucItemsPnl = self:Add("UI_DPanel_Bordered")
		ucItemsPnl:SetSize(500, 500)
		ucItemsPnl:ScaleToRes(1920, 1080)
		ucItemsPnl:Center()
		Marketplace.AddLoadingText(ucItemsPnl)

		local scrollPnl = ucItemsPnl:Add("UI_DScrollPanel")
		scrollPnl:SetSize(ucItemsPnl:GetWide(), ucItemsPnl:GetTall() - 40)

		Marketplace.GetUnclaimedPurchases(LocalPlayer():SteamID(), LocalPlayer():getChar():getID(), function(ucItems)
			local space = 10

			if IsValid(self) and IsValid(ucItemsPnl) then
				ucItemsPnl.Loading:Remove()

				for i, item in ipairs(ucItems) do
					local nsItem = nut.item.list[item.uniqueID]

					if !nsItem then Marketplace.Print("Item " ..  item.uniqueID .. " no longer exists and cannot be claimed!") continue end

					local itemPnl = scrollPnl:Add("UI_DPanel_Bordered")
					itemPnl:SetSize(350, 100)
					itemPnl:ScaleToRes(1920, 1080)
					itemPnl.Paint = function(s, w, h)
						surface.SetDrawColor(nut.gui.palette.color_background:Unpack())
						surface.DrawRect(0, 0, w, h)

						surface.SetDrawColor(0, 0, 0)
						surface.DrawOutlinedRect(2, 2, w - 1, h - 1)

						surface.SetDrawColor(nut.gui.palette.color_primary:Unpack())
						surface.DrawOutlinedRect(0, 0, w, h)
						surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
					end

					itemPnl:SetPos(0, (itemPnl:GetTall() * (i - 1)) + (space * i))
					itemPnl:CenterHorizontal()

					local iconSize = itemPnl:GetTall() * 0.9
					local icon = itemPnl:Add("nutSpawnIcon")
					icon:SetModel(nsItem.model)
					icon:SetSize(iconSize, iconSize)
					icon:CenterVertical()

					local title = itemPnl:Add("UI_DLabel")
					title:SetText(nsItem.name)
					title:SizeToContents()
					title:SetPos(0, 10)
					title:CenterHorizontal()

					local claimBtn = itemPnl:Add("UI_DButton")
					claimBtn:SetText("Claim")
					claimBtn:Dock(BOTTOM)
					claimBtn:DockMargin(100, 0, 100, 10)
					claimBtn:SetContentAlignment(5)
					claimBtn.DoClick = function()
						claimBtn:SetDisabled(true)

						local _, y = itemPnl:GetPos()
						local id = table.RemoveByValue(itemPnls, itemPnl)

						itemPnl:MoveTo(scrollPnl:GetWide(), y, 0.7, 0, -1, function()
							for j = id, #itemPnls do
								local pnl = itemPnls[j]
								local x = pnl:GetPos()
								pnl:MoveTo(x, (itemPnl:GetTall() * (j - 1)) + (space * j), 0.7)
							end

							itemPnl:Remove()
						end)

						Marketplace.ClaimItem(item.id)
					end
					itemPnl.claimBtn = claimBtn

					table.insert(itemPnls, itemPnl)
				end
			end
		end)

		local closeBtn = ucItemsPnl:Add("UI_DButton")
		closeBtn:SetText("Close")
		closeBtn:Dock(BOTTOM)
		closeBtn.DoClick = function()
			ucItemsPnl:Remove()
		end
		closeBtn:DockMargin(10, 0, 10, 10)

		--[[local claimAllBtn = ucItemsPnl:Add("UI_DButton")
		claimAllBtn:SetText("Claim All")
		claimAllBtn:Dock(BOTTOM)
		claimAllBtn.DoClick = function()
			for i, pnl in ipairs(itemPnls) do
				pnl.claimBtn:SetDisabled(true)

				local _, y = pnl:GetPos()

				pnl:MoveTo(scrollPnl:GetWide(), y, 0.7, 0, -1, function()
					table.RemoveByValue(itemPnls, pnl)
					pnl:Remove()
				end)
			end

			Marketplace.ClaimAllItems()
		end
		claimAllBtn:DockMargin(10, 0, 10, 2)]]


		jlib.AddBackgroundBlur(ucItemsPnl)
	end

	Marketplace.AddLoadingText(self)

	self.Listings = {}
	self.Page = 1

	Marketplace.GetPageCount(function(pageCount)
		if !IsValid(self) then return end

		Marketplace.GetPage(self.Page, function(listings)
			if !IsValid(self) then return end

			self.Loading:Remove()

			self:AddListings(listings)

			self.LoadMore = self:Add("UI_DButton")
			self.LoadMore:Dock(BOTTOM)
			self.LoadMore:SetText("Load More")
			self.LoadMore:SetContentAlignment(5)
			self.LoadMore.DoClick = function(s)
				if s.Loading then
					Marketplace.Notify("Loading, please wait.")
					return
				end

				s.Loading = true

				if !self.CurrentCategory then
					self.Page = self.Page + 1
					Marketplace.GetPage(self.Page, function(newListings)
						if #newListings <= 0 then
							Marketplace.Notify("No more listings to load.")
						else
							self:AddListings(newListings)
						end

						s.Loading = false
					end)
				else
					self.CategoryPage = self.CategoryPage + 1
					Marketplace.CategorySearch(self.CurrentCategory, self.CategoryPage, function(newListings)
						if #newListings <= 0 then
							Marketplace.Notify("No more listings to load in this category.")
						else
							self:AddListings(newListings)
						end

						s.Loading = false
					end)
				end
			end
			self.LoadMore.Think = function(s)
				if s.Loading then
					s:SetText(jlib.DotDotDot("Loading"))
				else
					s:SetText("Load More")
				end
			end

			self.ClearCat = self:Add("UI_DButton")
			self.ClearCat:SetText("Clear Category")
			self.ClearCat:Dock(BOTTOM)
			self.ClearCat:SetContentAlignment(5)
			self.ClearCat.DoClick = function(s)
				self:ResetToFirstPage()
			end
			self.ClearCat.Think = function(s)
				local disabled = self.CurrentCategory == nil or #self.Listings <= 0 or self.Clearing
				if s:GetDisabled() != disabled then
					s:SetDisabled(disabled)
				end
			end
		end)
	end)

	jlib.AddBackgroundBlur(self.LogoPnl)
end

function PANEL:AddListings(listings)
	local space = 10
	local continued = 0

	for i, listing in ipairs(listings) do
		if !nut.item.list[listing.itemID] then continued = continued + 1 continue end

		i = i - continued

		local listingPnl = self.ScrollPnl:Add("Marketplace_Listing")
		listingPnl:SetWide(600)
		listingPnl:ScaleToRes(1920, ScrH())
		listingPnl:SetListing(listing)
		listingPnl:Center()
		listingPnl:SetPos(-listingPnl:GetWide(), space)
		if #self.Listings > 0 then
			listingPnl:MoveBelow(self.Listings[#self.Listings], space)
		end

		listingPnl.OtherBtn:SetText("Buy")
		listingPnl.OtherBtn.DoClick = function(s)
			local maxBuy = listing.units - listing.unitsSold

			local amtRequest = self:Add("UI_DPanel_Bordered")
			amtRequest:SetSize(350, 200)
			amtRequest:ScaleToRes(1920, 1080)
			amtRequest:Center()

			local entry = amtRequest:Add("UI_DTextEntry")
			entry:SetNumeric(true)
			entry:SetWide(200)
			entry:SetValue(1)
			entry:Center()

			local amtLabel = amtRequest:Add("UI_DLabel")
			amtLabel:SetText("How many? (1 - " .. maxBuy .. ")")
			amtLabel:SizeToContents()
			amtLabel:SetPos(0, 10)
			amtLabel:CenterHorizontal()

			local totalCost = amtRequest:Add("UI_DLabel")
			totalCost:SizeToContents()
			totalCost:MoveBelow(amtLabel, 2)
			totalCost:CenterHorizontal()
			totalCost.Think = function(t)
				t:SetText("Total Cost: " .. Marketplace.Config.CurrencyPrefix .. jlib.CommaNumber(listing.pricePerUnit * (tonumber(entry:GetValue()) or 1)) .. Marketplace.Config.CurrencySuffix)
				t:SizeToContents()
				t:CenterHorizontal()
			end

			local confirm = amtRequest:Add("UI_DButton")
			confirm:SetText("OK")
			confirm:Dock(LEFT)
			confirm:DockMargin(10, (amtRequest:GetWide() - 50) / 2, 0, 10)
			confirm.DoClick = function()
				local amt = tonumber(entry:GetValue())
				local char = LocalPlayer():getChar()

				if !char then
					Marketplace.Notify("Invalid character.")
					return
				end

				if !amt or amt < 1 or amt > maxBuy then
					Marketplace.Notify("Invalid amount.")
					return
				end

				if !char:hasMoney(amt * listing.pricePerUnit) then
					Marketplace.Notify("You can't afford that many.")
					return
				end

				Marketplace.BuyFromListing(listing.id, amt)

				self.PredictedUnitsSold = (self.PredictedUnitsSold or listing.unitsSold) + amt
				if self.PredictedUnitsSold >= tonumber(listing.units) then
					listingPnl:Sold()
				end

				amtRequest:Remove()
			end

			local cancel = amtRequest:Add("UI_DButton")
			cancel:SetText("Cancel")
			cancel:Dock(RIGHT)
			cancel:DockMargin(0, (amtRequest:GetWide() - 50) / 2, 10, 10)
			cancel.DoClick = function()
				amtRequest:Remove()
			end

			jlib.AddBackgroundBlur(amtRequest)
		end

		table.insert(self.Listings, listingPnl)

		local _, y = listingPnl:GetPos()
		listingPnl:MoveTo((self.ScrollPnl:GetWide() / 2) - (listingPnl:GetWide() / 2), y, self.AnimSpeed, (self.AnimSpeed / 10) * (i - 1))
	end

	surface.PlaySound("ui/buttonrollover.wav")
end

function PANEL:ClearListings(callback)
	self.Clearing = true

	if #self.Listings > 0 then
		timer.Simple(self.AnimSpeed + 0.05, function()
			callback()
			self.Clearing = false
		end)
	else
		callback()
	end

	for i, pnl in ipairs(self.Listings) do
		local _, y = pnl:GetPos()
		pnl:MoveTo(-pnl:GetWide(), y, self.AnimSpeed, 0, -1, function()
			pnl:Remove()
			self.Listings[i] = nil
		end)
	end
end

function PANEL:Search(term)
	self.Searching = true
	self:ClearCategory()

	self:ClearListings(function()
		if !IsValid(self) then return end
		Marketplace.AddLoadingText(self)
		Marketplace.SearchForListings(term, function(results)
			if !IsValid(self) then return end
			self.Loading:Remove()
			self:AddListings(results)

			if #results <= 0 then
				Marketplace.Notify("No results for '" .. term .. "'.")
			end
			self.Searching = false
		end)
	end)
end

function PANEL:CategorySearch(category)
	Marketplace.CategorySearch(category, 1, function(results)
		if !IsValid(self) then return end

		if #results <= 0 then
			Marketplace.Notify("No items in '" .. category:lower() .. "' category.")
			self:ClearCategory()
		else
			self:ClearListings(function()
				if !IsValid(self) then return end
				self:AddListings(results)
			end)
		end
	end)

	self.CurrentCategory = category
	self.CategoryPage = 1
end

function PANEL:ClearCategory()
	self.CurrentCategory = nil
	self.CategoryPage = nil
end

function PANEL:ResetToFirstPage()
	self:ClearCategory()
	self.Page = 1
	self.LoadMore.Loading = true

	self:ClearListings(function()
		if !IsValid(self) then return end
		Marketplace.AddLoadingText(self)
		Marketplace.GetPage(self.Page, function(newListings)
			if !IsValid(self) then return end
			self.Loading:Remove()
			self:AddListings(newListings)
			self.LoadMore.Loading = false
		end)
	end)
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(nut.gui.palette.color_background:Unpack())
	surface.DrawRect(0, 0, w, h)

	DisableClipping(true)
	surface.SetDrawColor(0, 0, 0)
	surface.DrawOutlinedRect(2, 2, w - 1, h - 1)

	surface.SetDrawColor(nut.gui.palette.color_primary:Unpack())
	surface.DrawOutlinedRect(0, 0, w, h)
	surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
	DisableClipping(false)
end

function PANEL:OnClose()
	for _, pnl in pairs(self.RemoveOnCloseTbl) do
		pnl:Remove()
	end
end

function PANEL:RemoveOnClose(pnl)
	table.insert(self.RemoveOnCloseTbl, pnl)
end

vgui.Register("Marketplace_Main", PANEL, "DFrame")

PANEL = {}

function PANEL:Init()
	self:SetSize(450, 100)
	self:ScaleToRes(1920, 1080)
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(nut.gui.palette.color_background:Unpack())
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(0, 0, 0)
	surface.DrawOutlinedRect(2, 2, w - 1, h - 1)

	surface.SetDrawColor(nut.gui.palette.color_primary:Unpack())
	surface.DrawOutlinedRect(0, 0, w, h)
	surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
end

function PANEL:SetListing(listing)
	local item = nut.item.list[listing.itemID]
	local maxLen = Marketplace.GetMaxLen(self:GetWide(), "UI_Regular")

	local data = util.JSONToTable(listing.itemData:Replace("\n", ""))
	if Armor.Config.Accessories[item.uniqueID] then
		data.rarity = Armor.Config.Accessories[item.uniqueID].rarity
	elseif Armor.Config.Bodies[item.uniqueID] then
		data.rarity = Armor.Config.Bodies[item.uniqueID].rarity
	end

	local icon = self:Add("nutSpawnIcon")
	icon:SetSize(90, 90)
	icon:ScaleToRes(1920, 1080)
	icon:SetModel(item.model)
	icon:CenterVertical()
	--[[table.insert(Marketplace.HaloEnts, icon.Entity)
	icon.OnRemove = function(s)
		table.RemoveByValue(Marketplace.HaloEnts, s.Entity)
	end]]
	self.Icon = icon

	local name = self:Add("UI_DLabel")
	if #item.name > maxLen then
		name:SetText(string.sub(item.name, 1, maxLen - 3):Trim() .. "...")
	else
		name:SetText(item.name)
	end
	name:SizeToContents()
	name:SetPos(0, 10)
	name:CenterHorizontal()
	name:SetTextColor(data.rarity and wRarity.Config.Rarities[data.rarity].color or name:GetTextColor())
	self.NameLabel = name

	local amount = self:Add("UI_DLabel")
	amount:SetText("Price: " .. Marketplace.Config.CurrencyPrefix .. jlib.CommaNumber(listing.pricePerUnit) .. Marketplace.Config.CurrencySuffix)
	amount:SizeToContents()
	amount:SetPos(self:GetWide() - amount:GetWide() - 10, 10)
	self.PriceLabel = amount

	local detailsBtn = self:Add("UI_DButton")
	detailsBtn:SetSize(150, 30)
	detailsBtn:ScaleToRes(1920, 1080)
	surface.SetFont(detailsBtn:GetFont())
	detailsBtn:SetText("Listing Details")
	detailsBtn:SetWide(math.max(detailsBtn:GetWide(), surface.GetTextSize(detailsBtn:GetText())))
	detailsBtn:SetPos(0, self:GetTall() - detailsBtn:GetTall() - 10)
	detailsBtn:CenterHorizontal()
	detailsBtn:SetContentAlignment(5)
	detailsBtn.DoClick = function()
		local itemPnl = Marketplace.UI:Add("Marketplace_ListingDetails")
		itemPnl.ListingPnl = self
		itemPnl:Center()
		itemPnl:SetListing(listing)
	end
	self.DetailsBtn = detailsBtn

	local otherBtn = self:Add("UI_DButton")
	otherBtn:SetText("Yep")
	otherBtn:SetSize(60, 30)
	otherBtn:ScaleToRes(1920, 1080)
	otherBtn:SetPos(self:GetWide() - otherBtn:GetWide() - 10, self:GetTall() - otherBtn:GetTall() - 10)
	otherBtn:SetContentAlignment(5)
	self.OtherBtn = otherBtn
end

function PANEL:Sold()
	local _, y = self:GetPos()

	if IsValid(self.DetailsBtn) then
		self.DetailsBtn:SetDisabled(true)
	end

	if IsValid(self.OtherBtn) then
		self.OtherBtn:SetDisabled(true)
	end

	local listings = self:GetParent():GetParent():GetParent().Listings
	local id = table.RemoveByValue(listings, self)

	self:MoveTo(self:GetParent():GetWide(), y, 0.5, 0, -1, function()
		for i = id, #listings do
			if listings[i] then
				listings[i]:MoveTo(listings[i]:GetPos(), (self:GetTall() * (i - 1)) + (10 * i), 0.5)
			end
		end

		self:Remove()
	end)
end

vgui.Register("Marketplace_Listing", PANEL, "DPanel")

PANEL = {}

function PANEL:Init()
	self:SetSize(600, 250)
	self:ScaleToRes(1920, 1080)

	self.CloseBtn = self:Add("UI_DButton")
	self.CloseBtn:SetText("Close")
	self.CloseBtn:Dock(BOTTOM)
	self.CloseBtn.DoClick = function(s)
		self:Remove()
	end
	self.CloseBtn:SetContentAlignment(5)
	self.CloseBtn:DockMargin(130, 0, 130, 10)

	Marketplace.AddLoadingText(self)
	jlib.AddBackgroundBlur(self)
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(nut.gui.palette.color_background:Unpack())
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(0, 0, 0)
	surface.DrawOutlinedRect(2, 2, w - 1, h - 1)

	surface.SetDrawColor(nut.gui.palette.color_primary:Unpack())
	surface.DrawOutlinedRect(0, 0, w, h)
	surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
end

function PANEL:SetListing(listing)
	local listingPnl = self.ListingPnl

	Marketplace.GetItems(listing.id, function(items)
		local item = items[1]

		if IsValid(self.Loading) then
			self.Loading:Remove()
		end

		if !item then
			if IsValid(self) then
				local err = self:Add("UI_DLabel")
				err:SetText("Listing no longer exists!")
				err:SizeToContents()
				err:Center()
			end

			timer.Simple(0.3, function()
				if IsValid(listingPnl) then
					listingPnl:Sold()
				end

				if IsValid(self) then
					self:Remove()
				end
			end)

			return
		end

		if !IsValid(self) then return end

		local nsItem = nut.item.list[listing.itemID]
		local details = util.JSONToTable(item.itemDetails)

		local icon = self:Add("nutSpawnIcon")
		icon:SetSize(135, 135)
		icon:ScaleToRes(1920, 1080)
		icon:SetModel(nsItem.model)
		icon:CenterVertical()

		local name = self:Add("UI_DLabel")
		name:SetText(nsItem.name)
		name:SizeToContents()
		name:SetPos(10, 10)
		name:CenterHorizontal()

		local sold = self:Add("UI_DLabel")
		sold:SetText("Sold out: " .. (listing.unitsSold >= listing.units and "Yes" or "No"))
		sold:SizeToContents()
		sold:SetPos(0, 30)
		sold:MoveRightOf(icon, 2)

		local price = self:Add("UI_DLabel")
		price:SetText("Price per unit: " .. Marketplace.Config.CurrencyPrefix .. listing.pricePerUnit .. Marketplace.Config.CurrencySuffix)
		price:SizeToContents()
		price:SetPos(0, 50)
		price:MoveRightOf(icon, 2)

		local amount = self:Add("UI_DLabel")
		amount:SetText("Units left: " .. (listing.units - listing.unitsSold))
		amount:SizeToContents()
		amount:SetPos(0, 70)
		amount:MoveRightOf(icon, 2)

		if table.Count(details) > 0 then
			local detailsLabel = self:Add("UI_DLabel")
			detailsLabel:SetText("Details:")
			detailsLabel:SizeToContents()
			detailsLabel:SetPos(0, 90)
			detailsLabel:MoveRightOf(icon, 2)

			local i = 1
			for k, v in pairs(details) do
				local detailLabel = self:Add("UI_DLabel")
				detailLabel:SetText(k .. ": " .. v)
				detailLabel:SizeToContents()
				detailLabel:SetPos(0, 90 + (i * 20))
				detailLabel:MoveRightOf(icon, 22)

				i = i + 1
			end
		end
	end)
end

vgui.Register("Marketplace_ListingDetails", PANEL, "DPanel")

PANEL = {}

function PANEL:Init()
	self:SetSize(250, 70)
	self:ScaleToRes(1920, ScrH())
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(nut.gui.palette.color_background:Unpack())
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(0, 0, 0)
	surface.DrawOutlinedRect(2, 2, w - 1, h - 1)

	surface.SetDrawColor(nut.gui.palette.color_primary:Unpack())
	surface.DrawOutlinedRect(0, 0, w, h)
	surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
end

function PANEL:SetItem(item)
	local maxLen = Marketplace.GetMaxLen(self:GetWide(), "UI_Regular")

	local icon = self:Add("nutSpawnIcon")
	icon:SetSize(64, 64)
	icon:ScaleToRes(1920, 1080)
	icon:SetModel(item.model)
	icon:CenterVertical()

	local name = self:Add("UI_DLabel")
	if #item.name > maxLen then
		name:SetText(string.sub(item.name, 1, maxLen - 3):Trim() .. "...")
	else
		name:SetText(item.name)
	end
	name:SizeToContents()
	name:SetPos(10, 10)
	name:CenterHorizontal()

	local listBtn = self:Add("UI_DButton")
	listBtn:Dock(BOTTOM)
	listBtn:SetText("List")
	listBtn:DockMargin(60, 0, 60, 10)
	listBtn:SetContentAlignment(5)
	listBtn:SetFont("UI_Regular")
	listBtn:SetTall(25)
	listBtn.DoClick = function(s)
		local listables = Marketplace.UI.ListableItems[item.data]
		local details = Marketplace.GetItemDetails(item.uniqueID, item.data or {})

		local listPnl = Marketplace.UI:Add("UI_DPanel_Bordered")
		listPnl:SetSize(600, 300)
		listPnl:ScaleToRes(1920, 1080)
		listPnl:Center()

		local searchLabel = listPnl:Add("UI_DLabel")
		searchLabel:SetPos(0, listPnl:GetTall() / 15)
		searchLabel:SetFont("UI_Bold")
		searchLabel:SetText(item.name .. " Listing")
		searchLabel:SizeToContents()
		searchLabel:CenterHorizontal()

		local amtEntry = listPnl:Add("UI_DTextEntry")
		amtEntry:SetWide(listPnl:GetWide() / 3)
		amtEntry:SetPos(0, listPnl:GetTall() / 3.75)
		amtEntry:CenterHorizontal()
		amtEntry:SetPlaceholderText("Amount (1 - " .. #listables.items .. ")")
		amtEntry:SetNumeric(true)
		amtEntry.OldGetValue = amtEntry.GetValue
		amtEntry.GetValue = function(this)
			return math.floor(tonumber(this:OldGetValue()) or 0)
		end
		amtEntry.AllowInput = function(this, char)
			return !tonumber(char)
		end

		local function PriceEntryCheck(pnl)
			local val = math.floor(tonumber(pnl:GetValue()) or 0)
			if val < Marketplace.Config.MinimumPrice then
				pnl:SetText(Marketplace.Config.MinimumPrice)
			elseif val > Marketplace.Config.MaximumPrice then
				pnl:SetText(Marketplace.Config.MaximumPrice)
			end
		end

		local priceEntry = listPnl:Add("UI_DTextEntry")
		priceEntry:SetWide(listPnl:GetWide() / 3)
		priceEntry:MoveBelow(amtEntry, listPnl:GetTall() / 30)
		priceEntry:CenterHorizontal()
		priceEntry:SetPlaceholderText("Price per unit")
		priceEntry:SetNumeric(true)
		priceEntry.OnValueChange = PriceEntryCheck
		priceEntry.OnLoseFocus = PriceEntryCheck
		priceEntry.OldGetValue = priceEntry.GetValue
		priceEntry.GetValue = function(this)
			return math.floor(tonumber(this:OldGetValue()) or 0)
		end
		priceEntry.AllowInput = function(this, char)
			return !tonumber(char)
		end

		local taxViewer = listPnl:Add("UI_DLabel")
		taxViewer:MoveBelow(priceEntry, listPnl:GetTall() / 60)
		taxViewer.Think = function(t)
			t:SetText("Profit per unit after tax: " .. Marketplace.Config.CurrencyPrefix .. jlib.CommaNumber(Marketplace.Tax(tonumber(priceEntry:GetValue()) or 0)) .. Marketplace.Config.CurrencySuffix)
			t:SizeToContents()
			t:CenterHorizontal()
		end

		if table.Count(details) > 0 then
			local getDetails = listPnl:Add("UI_DButton")
			getDetails:SetSize(priceEntry:GetSize())
			getDetails:SetText("Item Details")
			getDetails:CenterHorizontal()
			getDetails:MoveBelow(taxViewer, 5)
			getDetails:SetContentAlignment(5)
			getDetails.DoClick = function()
				local detailsPnl = Marketplace.UI:Add("UI_DPanel_Bordered")
				detailsPnl:SetSize(500, 400)
				detailsPnl:ScaleToRes(1920, 1080)
				detailsPnl:Center()

				local detailsLabel = detailsPnl:Add("UI_DLabel")
				detailsLabel:SetText("Details:")
				detailsLabel:SizeToContents()
				detailsLabel:SetPos(10, 50)

				local closeBtn = detailsPnl:Add("UI_DButton")
				closeBtn:SetText("Close")
				closeBtn:Dock(BOTTOM)
				closeBtn:DockMargin(10, 10, 10, 10)
				closeBtn.DoClick = function()
					detailsPnl:Remove()
				end

				local i = 1
				for k, v in pairs(details) do
					local detailLabel = detailsPnl:Add("UI_DLabel")
					detailLabel:SetText(k .. ": " .. v)
					detailLabel:SizeToContents()
					detailLabel:SetPos(30, 50 + (i * 20))

					i = i + 1
				end

				jlib.AddBackgroundBlur(detailsPnl)
			end
		end

		local marginTop = listPnl:GetTall() / 1.2
		local marginSideBottom = listPnl:GetWide() / 60

		local confirm = listPnl:Add("UI_DButton")
		confirm:SetText("Confirm")
		confirm:Dock(LEFT)
		confirm:DockMargin(marginSideBottom, marginTop, 0, marginSideBottom)
		confirm.DoClick = function()
			local amt = tonumber(amtEntry:GetValue())
			local price = tonumber(priceEntry:GetValue())

			if !amt or amt < 1 or amt > #listables.items then
				Marketplace.Notify("Invalid amount.")
				return
			end

			if !price or price < Marketplace.Config.MinimumPrice or price > Marketplace.Config.MaximumPrice then
				Marketplace.Notify("Invalid price.")
				return
			end

			local items = {}

			for i = 1, amt do
				items[i] = listables.items[i]
			end

			Marketplace.CreateListing(items, price)

			Marketplace.UI.RightPanel.ScrollPnl:Clear()
			Marketplace.UI.LeftPanel.ScrollPnl:Clear()

			Marketplace.UI.FilledWithListables = false
			Marketplace.AddLoadingText(Marketplace.UI.RightPanel)
			Marketplace.AddLoadingText(Marketplace.UI.LeftPanel)

			listPnl:Remove()
		end
		confirm:SetWide(listPnl:GetWide() / 5)
		confirm:SetContentAlignment(5)

		local cancel = listPnl:Add("UI_DButton")
		cancel:SetText("Cancel")
		cancel:Dock(RIGHT)
		cancel:DockMargin(0, marginTop, marginSideBottom, marginSideBottom)
		cancel.DoClick = function()
			listPnl:Remove()
		end
		cancel:SetWide(listPnl:GetWide() / 5)
		cancel:SetContentAlignment(5)

		jlib.AddBackgroundBlur(listPnl)
	end
end

vgui.Register("Marketplace_InvItem", PANEL, "DPanel")

-- Halos
--[[hook.Add("PreDrawHalos", "MarketplaceHalos", function()
	halo.Add(Marketplace.HaloEnts, Color(255, 0, 0, 255), 5, 5, 2, true, true)
end)]]
