util.AddNetworkString("MarketplaceCreateListing")
util.AddNetworkString("MarketplaceListingFinished")
util.AddNetworkString("MarketplaceBuy")
util.AddNetworkString("MarketplaceCancel")
util.AddNetworkString("MarketplaceClaimSale")
util.AddNetworkString("MarketplaceClaimAllSales")
util.AddNetworkString("MarketplaceClaimItem")
--util.AddNetworkString("MarketplaceClaimAllItems")
util.AddNetworkString("MarketplaceOpenMenu")

-- Remote databse setup
require("mysqloo")

Marketplace.Config.MySQL = {
	IP = "remote_db_address_here",
	User = "remote_db_username_here",
	Password = "remote_db_password_here",
	Database = "remote_db_name_here",
	Port = 3306,
	MaxRetries = 10
}

function Marketplace.InitDB()
	Marketplace.DB = mysqloo.connect(
		Marketplace.Config.MySQL.IP,
		Marketplace.Config.MySQL.User,
		Marketplace.Config.MySQL.Password,
		Marketplace.Config.MySQL.Database,
		Marketplace.Config.MySQL.Port
	)

	function Marketplace.DB:onConnected()
		Marketplace.Print("Successfully connected to the remote database!")
	end

	function Marketplace.DB:onConnectionFailed(err)
    	Marketplace.Print("Failed to connect to the remote database!")
    	Marketplace.Print("Error: ", err)
	end


	Marketplace.DB:connect()
end

function Marketplace.Query(sql, success, err)
	Marketplace.Print("Sending query to remote database")

	local q = Marketplace.DB:query(sql)
	local retries = 0

	function q:onSuccess(data)
		Marketplace.Print("Received response from remote database")

		if success then
			success(data, self)
		end
	end

	function q:onError(errStr, errSql)
		Marketplace.Print("Received error from remote database")

		if errStr == "Lost connection to MySQL server during query" then
			Marketplace.Print("Connection to MySQL server was lost, retrying query (" .. retries .. ")")
			if retries < Marketplace.Config.MySQL.MaxRetries then
				q:start()

				retries = retries + 1
			else
				Marketplace.Print("Aborting query after " .. retries .. " retries")
			end
		else
			Marketplace.Print("Error: ", errStr)
		end

		if err then
			err(errStr, errSql, self)
		end
	end

	q:start()
end

function Marketplace.Escape(str)
	return Marketplace.DB:escape(str)
end

function Marketplace.CreateTables()
	Marketplace.Query([[CREATE TABLE IF NOT EXISTS `listings` (
		id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
		sellerSID TEXT,
		sellerCID INT,
		pricePerUnit INT,
		itemID TEXT,
		itemName TEXT,
		units INT,
		unitsSold INT,
		category TEXT,
		itemData TEXT
	);]])

	Marketplace.Query([[CREATE TABLE IF NOT EXISTS `items` (
		id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
		ownerSID TEXT,
		ownerCID INT,
		price INT,
		itemData TEXT,
		uniqueID TEXT,
		sold BOOLEAN,
		sellerClaimed BOOLEAN,
		buyerClaimed BOOLEAN,
		itemDetails TEXT,
		listingID INT,
		buyerSID TEXT,
		buyerCID INT,
		listedTime INT UNSIGNED,
		purchasedTime INT UNSIGNED
	);]])

	Marketplace.Query([[CREATE TRIGGER insert_listing_count
	AFTER INSERT ON `items`
	FOR EACH ROW BEGIN
		UPDATE `listings` SET units = (SELECT COUNT(*) FROM `items` WHERE listingid = NEW.listingid) WHERE id = NEW.listingid;
		UPDATE `listings` SET unitsSold = (SELECT COUNT(*) FROM `items` WHERE listingid = NEW.listingid AND sold = true) WHERE id = NEW.listingid;
	END;]])

	Marketplace.Query([[CREATE TRIGGER update_listing_count
	AFTER UPDATE ON `items`
	FOR EACH ROW BEGIN
		UPDATE `listings` SET units = (SELECT COUNT(*) FROM `items` WHERE listingid = NEW.listingid) WHERE id = NEW.listingid;
		UPDATE `listings` SET unitsSold = (SELECT COUNT(*) FROM `items` WHERE listingid = NEW.listingid AND sold = true) WHERE id = NEW.listingid;
	END;]])
end

if !Marketplace.DB or !Marketplace.DB:ping() then
	Marketplace.InitDB()
	Marketplace.CreateTables()
end

-- Item/Listing handling
Marketplace.IDsInUse = Marketplace.IDsInUse or {Items = {}, Listings = {}, NSItems = {}}
Marketplace.ListingAmt = Marketplace.ListingAmt or {}

function Marketplace.AddListing(items, uniqueID, price, seller)
	if !seller:getChar() then return end

	if Marketplace.IsItemBlacklisted(uniqueID) then
		Marketplace.Notify("This item cannot be listed on the market.", seller)
		Marketplace.ListingFinished(seller)
		Marketplace.Print(seller:Nick() .. " attempted to list blacklisted item " .. uniqueID)
		return
	end

	for i, item in ipairs(items) do
		if Marketplace.IDsInUse.NSItems[item:getID()] then
			Marketplace.Notify("Invalid items for listing.", seller)
			Marketplace.ListingFinished(seller)
			return
		end

		if item:getData("equipped", false) then
			Marketplace.Notify("You cannot list equipped items.", seller)
			Marketplace.ListingFinished(seller)
			return
		end

		-- The seller of the items must own them
		if item:getOwner() != seller then
			Marketplace.Notify("Attempt to list someone else's items.", seller)
			Marketplace.ListingFinished(seller)
			return
		end

		-- All of the items within a listing must have the same data and uniqueID
		if item.uniqueID != uniqueID or !Marketplace.CompareTables(items[1].data, item.data) then
			Marketplace.Notify("Invalid items for listing.", seller)
			Marketplace.ListingFinished(seller)
			return
		end

		-- Can't list the same item more than once
		for i2, item2 in ipairs(items) do
			if i2 != i and item2 == item then
				Marketplace.Notify("Invalid items for listing.", seller)
				Marketplace.ListingFinished(seller)
				return
			end
		end

		Marketplace.IDsInUse.NSItems[item:getID()] = true
	end

	local sid = seller:SteamID()
	local cid = seller:getChar():getID()
	local name = seller:Nick()

	Marketplace.Query("SELECT COUNT(*) FROM `listings` WHERE sellerSID = '" .. sid .. "' AND sellerCID = " .. cid .. " AND unitsSold < units;", function(dat)
		local count = dat[1]["COUNT(*)"]

		if count >= Marketplace.Config.Slots then
			for i, item in ipairs(items) do
				Marketplace.IDsInUse.NSItems[item:getID()] = nil
			end

			Marketplace.Notify("You have used all " .. Marketplace.Config.Slots .. " of your listing slots.", seller)

			Marketplace.ListingFinished(seller)

			return
		end

		local category = Marketplace.GetItemCategory(uniqueID)
		local data = util.TableToJSON(items[1].data)
		local iName = Marketplace.DB:escape(items[1].name)
		Marketplace.Query([[INSERT INTO `listings` (sellerSID, sellerCID, pricePerUnit, itemID, itemName, units, unitsSold, category, itemData)
		VALUES(']] .. sid .. "', " .. cid .. ", " .. price .. ", '" .. uniqueID .. "', '" .. iName .. "', " .. #items .. ", 0, " .. (category and ("'" .. category ..  "'") or "NULL") .. ", '" .. data .."'); SELECT LAST_INSERT_ID();", function(_, query)
			query:getNextResults()
			local insert = query:getData()[1]["LAST_INSERT_ID()"]

			Marketplace.IDsInUse.Listings[insert] = true
			Marketplace.ListingAmt[insert] = {done = 0, total = #items}

			for _, item in ipairs(items) do
				Marketplace.AddItem(item, seller, price, insert)
				item:remove()
			end

			Marketplace.ListingFinished(seller)
			local itemName = nut.item.list[uniqueID].name
			Marketplace.Log(insert, "Listing Created", name, sid, cid, itemName, uniqueID)
			itemName = (#items != 1 and !itemName:EndsWith("s")) and (itemName .. "s") or itemName
			DiscordEmbed(#items .. " " .. itemName .. " has been added to the marketplace", "💰 Marketplace Addition 💰", Color(0, 255, 0), "IncursionFeed")
			DiscordEmbed(name .. " (" .. sid .. ") added " .. #items .. " " .. itemName .. " to the marketplace for " .. price .. " caps", "💰 Marketplace Addition Log 💰", Color(0, 255, 0), "BTeam")  -- Added by Keith, for B-Team auditing
		end)
	end)
end

function Marketplace.ListingFinished(ply)
	net.Start("MarketplaceListingFinished")
	net.Send(ply)
end

function Marketplace.AddItem(item, owner, price, listingID)
	if !owner:getChar() then return end

	local itemID = item:getID()

	Marketplace.Query([[INSERT INTO `items` (ownerSID, ownerCID, price, itemData, uniqueID, sold, sellerClaimed, buyerClaimed, itemDetails, listingID, listedTime)
	VALUES(']] .. owner:SteamID() .. "', " .. owner:getChar():getID() .. ", " .. price .. ", '" .. util.TableToJSON(item.data or {}) .. "', '" .. item.uniqueID .. "', false, false, false, '" .. util.TableToJSON(Marketplace.GetItemDetails(item.uniqueID, item.data)) .. "', " .. listingID .. ", " .. os.time() .. ");", function()
		Marketplace.IDsInUse.NSItems[itemID] = nil

		local amt = Marketplace.ListingAmt[listingID]
		amt.done = amt.done + 1
		if amt.done >= amt.total then
			Marketplace.IDsInUse.Listings[listingID] = nil
		end
	end)
end

function Marketplace.BuyItem(itemID, buyer)
	if !buyer:getChar() then return end

	local sid = buyer:SteamID()
	local cid = buyer:getChar():getID()
	local name = buyer:Nick()

	Marketplace.Query("SELECT id, price, itemData, uniqueID, listingID FROM `items` WHERE id = " .. itemID .. " AND sold = false;", function(dat)
		dat = dat[1]

		-- Prevent a new buy request for the same item being processed
		-- before we are done with this one
		if !dat or Marketplace.IDsInUse.Items[itemID] then
			Marketplace.Notify("Unable to purchase item.", buyer)
			return
		end

		Marketplace.IDsInUse.Items[itemID] = true

		Marketplace.Print(buyer:Nick() .. " is buying item with ID " .. dat.id)

		if buyer:getChar():hasMoney(dat.price) then
			Marketplace.Query("UPDATE `items` SET sold = true, buyerSID = '" .. sid .. "', buyerCID = " .. cid .. ", purchasedTime =" .. os.time() .." WHERE id = " .. itemID .. " AND sold = false; SELECT ROW_COUNT();", function(_, query)
				query:getNextResults()
				local updated = query:getData()[1]["ROW_COUNT()"]

				Marketplace.IDsInUse.Items[itemID] = nil

				if updated > 0 then
					buyer:getChar():takeMoney(dat.price)
					Marketplace.Notify("Purchase successful.", buyer)
					Marketplace.Log(dat.id, "Item purchased", name, sid, cid, nut.item.list[dat.uniqueID].name, dat.uniqueID)
					DiscordEmbed(name .. " (" .. sid .. ") purchased " .. nut.item.list[dat.uniqueID].name .. " from the marketplace for " .. dat.price .. " caps", "💰 Marketplace Purchase Log 💰", Color(255, 255, 0), "BTeam") -- Added by Keith, for B-Team auditing
				else
					Marketplace.Notify("Something went wrong, try again later.", buyer)
				end
			end)
		else
			Marketplace.Notify("You cannot afford this purchase.", buyer)
			Marketplace.IDsInUse.Items[itemID] = nil
		end
	end)
end

function Marketplace.BuyFromListing(listingID, buyer, amount)
	if !buyer:getChar() then return end

	if Marketplace.IDsInUse.Listings[listingID] then
		Marketplace.Notify("Listing currently in use, try again later.", buyer)
		return
	end

	Marketplace.Query("SELECT id, price FROM `items` WHERE listingID = " .. listingID .. " AND sold = false LIMIT " .. amount .. ";", function(dat)
		if #dat == 0 then
			Marketplace.Notify("This listing is sold out.", buyer)
			return
		end

		local totalPrice = 0
		for i, item in ipairs(dat) do
			totalPrice = totalPrice + item.price
		end

		if !buyer:getChar():hasMoney(totalPrice) then
			Marketplace.Notify("You cannot afford this purchase.", buyer)
			return
		end

		for i, item in ipairs(dat) do
			Marketplace.BuyItem(item.id, buyer)
		end
	end)
end

function Marketplace.EndListing(listingID, requester)
	if !requester:getChar() then return end

	if Marketplace.IDsInUse.Listings[listingID] then
		Marketplace.Notify("This listing is currently in use. Try again later.", requester)
		return
	end

	Marketplace.IDsInUse.Listings[listingID] = true

	local sid = requester:SteamID()
	local cid = requester:getChar():getID()
	local name = requester:Nick()

	Marketplace.Query("SELECT sellerSID, sellerCID, itemID FROM `listings` WHERE id = " .. listingID .. " AND unitsSold < units;", function(dat, query)
		if dat[1] and dat[1].sellerSID == sid and tonumber(dat[1].sellerCID) == cid then
			-- To cancel the listing set unsold item(s) as sold, the buyer as
			-- the owner and set sellerClaimed to true
			Marketplace.Query("UPDATE `items` SET buyerSID = ownerSID, buyerCID = ownerCID, sold = true, sellerClaimed = true, purchasedTime = " .. os.time() .. " WHERE listingID = " .. listingID .. " AND sold = false;", function()
				Marketplace.IDsInUse.Listings[listingID] = nil
				Marketplace.Notify("Listing cancelled.", requester)
				Marketplace.Log(listingID, "Listing Cancelled", name, sid, cid, nut.item.list[dat[1].itemID].name, dat[1].itemID)
			end)
		else
			Marketplace.Notify("Invalid listing.", requester)
			Marketplace.IDsInUse.Listings[listingID] = nil
		end
	end)
end

function Marketplace.ClaimSale(itemID, requester)
	if !requester:getChar() then return end

	if Marketplace.IDsInUse.Items[itemID] then
		Marketplace.Notify("This item is currently in use. Try again later.", requester)
		return
	end

	Marketplace.IDsInUse.Items[itemID] = true

	local sid = requester:SteamID()
	local cid = requester:getChar():getID()
	local name = requester:Nick()

	Marketplace.Query("SELECT ownerSID, ownerCID, price FROM `items` WHERE id = " .. itemID .. " AND sold = true AND sellerClaimed = false;", function(dat)
		local item = dat[1]

		if !item or sid != item.ownerSID or cid != tonumber(item.ownerCID) then
			Marketplace.Notify("Invalid item.", requester)
			Marketplace.IDsInUse.Items[itemID] = nil
			return
		end

		Marketplace.Query("UPDATE `items` SET sellerClaimed = true WHERE id = " .. itemID .. " AND sold = true AND sellerClaimed = false; SELECT ROW_COUNT();", function(_, query)
			query:getNextResults()
			local updated = query:getData()

			if (updated[1]["ROW_COUNT()"] or 0) > 0 then
				local afterTax = Marketplace.Tax(item.price)
				requester:getChar():giveMoney(afterTax)
				Marketplace.Notify("Given " .. Marketplace.Config.CurrencyPrefix .. jlib.CommaNumber(afterTax) .. Marketplace.Config.CurrencySuffix, requester)
				Marketplace.IDsInUse.Items[itemID] = nil

				Marketplace.Log(item.id, "Sale Claimed", name, sid, cid, nut.item.list[item.uniqueID].name, item.uniqueID)
			else
				Marketplace.Notify("Something went wrong, try again later.", requester)
				Marketplace.IDsInUse.Items[itemID] = nil
			end
		end)
	end)
end

function Marketplace.ClaimAllSales(ply)
	if !ply:getChar() then return end

	local sid = ply:SteamID()
	local cid = ply:getChar():getID()
	local name = ply:Nick()
	Marketplace.Query("SELECT price, id, uniqueID FROM `items` WHERE ownerSID = '" .. sid .. "' AND ownerCID = " .. cid .. " AND sellerClaimed = false AND sold = true; UPDATE `items` SET sellerClaimed = true WHERE ownerSID = '" .. sid .. "' AND ownerCID = " .. cid .. " AND sold = true AND sellerClaimed = false;", function(dat)
		local total = 0

		for _, sale in ipairs(dat) do
			total = total + sale.price
			Marketplace.Log(sale.id, "Sale Claimed", name, sid, cid, nut.item.list[sale.uniqueID].name, sale.uniqueID)
		end

		if total > 0 then
			local afterTax = Marketplace.Tax(total)
			ply:getChar():giveMoney(afterTax)
			Marketplace.Notify("Claimed all sales for: " .. Marketplace.Config.CurrencyPrefix .. jlib.CommaNumber(afterTax) .. Marketplace.Config.CurrencySuffix, ply)
		else
			Marketplace.Notify("No sales to claim.", ply)
		end
	end)
end

function Marketplace.ClaimItem(itemID, requester)
	if !requester:getChar() then return end

	if Marketplace.IDsInUse.Items[itemID] then
		Marketplace.Notify("This item is currently in use. Try again later.", requester)
		return
	end

	Marketplace.IDsInUse.Items[itemID] = true

	local sid = requester:SteamID()
	local cid = requester:getChar():getID()
	local name = requester:Nick()

	Marketplace.Query("SELECT uniqueID, itemData FROM `items` WHERE id = " .. itemID .. " AND buyerSID = '" .. sid .. "' AND buyerCID = " .. cid .. " AND sold = true AND buyerClaimed = false;", function(dat)
		for _, item in ipairs(dat) do
			if requester:getChar():getInv():add(item.uniqueID, nil, util.JSONToTable(item.itemData)) then
				Marketplace.Query("UPDATE `items` SET buyerClaimed = true WHERE id = " .. itemID .. ";", function()
					Marketplace.IDsInUse.Items[itemID] = nil
					Marketplace.Log(itemID, "Item Claimed", name, sid, cid, nut.item.list[item.uniqueID].name, item.uniqueID)
				end)
			else
				Marketplace.IDsInUse.Items[itemID] = nil
				Marketplace.Notify("No space!", requester)
				break
			end
		end
	end)
end

--[[function Marketplace.ClaimAllItems(ply)

end]]

-- Networking
net.Receive("MarketplaceCreateListing", function(len, ply)
	local itemIDs = jlib.ReadCompressedTable()
	local price = net.ReadInt(32)

	if price < Marketplace.Config.MinimumPrice or price > Marketplace.Config.MaximumPrice then
		Marketplace.Notify("Price out of range.", ply)
		return
	end

	local items = {}

	for i, id in ipairs(itemIDs) do
		local item = nut.item.instances[id]

		if !item or item:getOwner() != ply then
			Marketplace.Notify("Invalid items.", ply)
			return
		end

		items[i] = item
	end

	Marketplace.AddListing(items, items[1].uniqueID, price, ply)
end)

net.Receive("MarketplaceBuy", function(len, ply)
	local listingID = net.ReadInt(32)
	local amt = net.ReadInt(32)

	Marketplace.BuyFromListing(listingID, ply, amt)
end)

net.Receive("MarketplaceCancel", function(len, ply)
	local listingID = net.ReadInt(32)
	Marketplace.EndListing(listingID, ply)
end)

net.Receive("MarketplaceClaimSale", function(len, ply)
	local itemID = net.ReadInt(32)
	Marketplace.ClaimSale(itemID, ply)
end)

net.Receive("MarketplaceClaimAllSales", function(len, ply)
	Marketplace.ClaimAllSales(ply)
end)

net.Receive("MarketplaceClaimItem", function(len, ply)
	local itemID = net.ReadInt(32)
	Marketplace.ClaimItem(itemID, ply)
end)

--[[net.Receive("MarketplaceClaimAllItems", function(len, ply)
	Marketplace.ClaimAllItems(ply)
end)]]

-- Importing data from the old F:I system
function Marketplace.ImportData()
	Marketplace.Print("Importing old marketplace data")

	local dat = sql.Query("SELECT * FROM `nut_marketplace`;")

	for i, item in ipairs(dat) do
		local cid = item._sellerID
		local price = item._itemPrice
		local itemName = item._itemName
		local uniqueID = item._itemID
		local itemData = item._itemData
		local sold = tostring(tonumber(item._itemSold) == 1)

		if itemData == "NULL" then
			itemData = "[]"
		end

		local priceNum = tonumber(price)

		local sid
		local charDat = sql.Query("SELECT * FROM `nut_characters` WHERE _id = " .. cid .. ";")

		if charDat and charDat[1] and charDat[1]._steamID then
			sid = util.SteamIDFrom64(charDat[1]._steamID)
		else
			Marketplace.Print("Skipping item because the seller no longer exists")
			continue
		end

		Marketplace.Print("Importing item " .. uniqueID .. " owned by (" .. sid .. ", " .. cid .. ")")

		local category = Marketplace.GetItemCategory(uniqueID)
		local details = util.TableToJSON(Marketplace.GetItemDetails(uniqueID, util.JSONToTable(itemData or "[]")))

		if priceNum < Marketplace.Config.MinimumPrice or priceNum > Marketplace.Config.MaximumPrice then
			Marketplace.Print("Adding item " .. uniqueID .. " to the char's unclaimed items as it's price is out of bounds")

			Marketplace.Query([[INSERT INTO `listings` (sellerSID, sellerCID, pricePerUnit, itemID, itemName, units, unitsSold, category, itemData)
			VALUES(']] .. sid .. "', " .. cid .. ",  0, '" .. uniqueID .. "', '" .. itemName .. "',  1, 1, " .. (category and ("'" .. category ..  "'") or "NULL") .. ", '" .. itemData .. "'); SELECT LAST_INSERT_ID();", function(_, query)
				query:getNextResults()
				local insert = query:getData()[1]["LAST_INSERT_ID()"]

				Marketplace.Query([[INSERT INTO `items` (ownerSID, ownerCID, price, itemData, uniqueID, sold, sellerClaimed, buyerClaimed, itemDetails, listingID, buyerSID, buyerCID)
				VALUES(']] .. sid .. "', " .. cid .. ", 0, '" .. (itemData or "[]") .. "', '" .. uniqueID .. "', true, true, false, '" .. "[]" .. "', " .. insert .. ", '" .. sid .. "', " .. cid .. ");")
			end)

			sql.Query("DELETE FROM `nut_marketplace` WHERE _id = " .. item._id .. ";")

			continue
		end

		if Marketplace.IsItemBlacklisted(uniqueID) then
			Marketplace.Print("Adding item " .. uniqueID .. " to the char's unclaimed items as it is blacklisted")

			Marketplace.Query([[INSERT INTO `listings` (sellerSID, sellerCID, pricePerUnit, itemID, itemName, units, unitsSold, category, itemData)
			VALUES(']] .. sid .. "', " .. cid .. ", 0, '" .. uniqueID .. "', '" .. itemName .. "',  1, 1, " .. (category and ("'" .. category ..  "'") or "NULL") .. ", '" .. itemData .. "'); SELECT LAST_INSERT_ID();", function(_, query)
				query:getNextResults()
				local insert = query:getData()[1]["LAST_INSERT_ID()"]

				Marketplace.Query([[INSERT INTO `items` (ownerSID, ownerCID, price, itemData, uniqueID, sold, sellerClaimed, buyerClaimed, itemDetails, listingID, buyerSID, buyerCID)
				VALUES(']] .. sid .. "', " .. cid .. ", 0, '" .. (itemData or "[]") .. "', '" .. uniqueID .. "', true, true, false, '" .. "[]" .. "', " .. insert .. ", '" .. sid .. "', " .. cid .. ");")
			end)

			sql.Query("DELETE FROM `nut_marketplace` WHERE _id = " .. item._id .. ";")

			continue
		end

		Marketplace.Query([[INSERT INTO `listings` (sellerSID, sellerCID, pricePerUnit, itemID, itemName, units, unitsSold, category, itemData)
		VALUES(']] .. sid .. "', " .. cid .. ", " .. price .. ", '" .. uniqueID .. "', '" .. itemName .. "',  1, 0, " .. (category and ("'" .. category ..  "'") or "NULL") .. ", '" .. itemData .. "'); SELECT LAST_INSERT_ID();", function(_, query)
			query:getNextResults()
			local insert = query:getData()[1]["LAST_INSERT_ID()"]

			Marketplace.Query([[INSERT INTO `items` (ownerSID, ownerCID, price, itemData, uniqueID, sold, sellerClaimed, buyerClaimed, itemDetails, listingID)
			VALUES(']] .. sid .. "', " .. cid .. ", " .. price .. ", '" .. (itemData or "[]") .. "', '" .. uniqueID .. "', " .. sold .. ", false, " .. sold .. ", '" .. details .. "', " .. insert .. ");")
		end)

		sql.Query("DELETE FROM `nut_marketplace` WHERE _id = " .. item._id .. ";")

		Marketplace.Print("Imported item " .. uniqueID)
	end

	Marketplace.Print("Import complete!")
end

-- Logs
function Marketplace.LogsSetup()
	Marketplace.Print("Setting up logs for marketplace")
	jlib.logs.CreateLog("Marketplace", {"Market ID", "Action", "Name", "SteamID", "CharacterID", "Item Name", "Item UniqueID"})

	jlib.logs.AuthFuncs.Marketplace = function(ply)
		return ply:IsSuperAdmin()
	end
end
hook.Add("Initialize", "MarketplaceLogsSetup", Marketplace.LogsSetup)

function Marketplace.Log(...)
	jlib.logs.Add("Marketplace", {...})
end
