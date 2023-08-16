util.AddNetworkString("BuyMenuItems")
util.AddNetworkString("BuyMenuItemCreate")
util.AddNetworkString("BuyMenuItemRemove")
util.AddNetworkString("BuyMenuItemUpdate")
util.AddNetworkString("BuyMenuCategories")
util.AddNetworkString("BuyMenuCategoryCreate")
util.AddNetworkString("BuyMenuCategoryRemove")
util.AddNetworkString("BuyMenuCategoryUpdate")
util.AddNetworkString("BuyMenuClasses")
util.AddNetworkString("BuyMenuStockCreate")
util.AddNetworkString("BuyMenuStockUpdate")
util.AddNetworkString("BuyMenuStockRemove")
util.AddNetworkString("BuyMenuManualRestock")
util.AddNetworkString("BuyMenuPurchase")
util.AddNetworkString("BuyMenuSell")

-- Should be handled by WorkshopDL now
// for _, file in pairs(file.Find("materials/buymenu/icons/*.png", "GAME")) do
//     resource.AddSingleFile("materials/buymenu/icons/" .. file)
// end

// for _, f in pairs(file.Find("sound/buymenu/*", "GAME")) do
//     resource.AddSingleFile("sound/buymenu/" .. f)
// end

-- MySQL connection
function BuyMenu.ReadFromDB() -- Read all the data into memory from the database
	BuyMenu.Print("Reading data from database")

	BuyMenu.SQL:Query("SELECT * FROM `categories`; SELECT * FROM `items`; SELECT * FROM `stockPools`; SELECT * FROM `classes`;", function(categories, items, stockPools, classes)
		for i, category in ipairs(categories) do
			BuyMenu.Categories[category.id] = {id = category.id, name = category.name, icon = category.icon}
		end

		for i, item in ipairs(items) do
			BuyMenu.Items[item.id] = {id = item.id, item = item.uniqueID, price = item.cost, sellPrice = item.sale, classes = item.classes, category = item.category, pool = item.stockPool, rarity = item.rarity}
		end

		for i, pool in ipairs(stockPools) do
			BuyMenu.CreateStockPool(pool, false)
		end

		for i, class in ipairs(classes) do
			BuyMenu.IDToClass[class.id] = class.uniqueID
			BuyMenu.ClassToID[class.uniqueID] = class.id
		end

		BuyMenu.FullyInitialized = true

		BuyMenu.Print("Initialized")
	end)
end

function BuyMenu.SQLInit()
	if BuyMenu.Initialized then
		return
	end

	BuyMenu.Initialized = true

	BuyMenu.Print("Establishing connection to MySQL database")

	BuyMenu.SQL = BuyMenu.SQL or jlib.MySQL.Create("192.185.16.74", jlib.IsDev() and "claymore_buymenu_dev" or "claymore_buymenu", "claymore_admin", "tSQBG'AN+{-@G<8b", 3306)

	BuyMenu.Print("Creating tables")

	local classCreate = "CREATE TABLE IF NOT EXISTS `classes` (id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, uniqueID VARCHAR(32));"
	local categoryCreate = "CREATE TABLE IF NOT EXISTS `categories` (id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, name VARCHAR(32), icon SMALLINT UNSIGNED);"
	local stockPoolCreate = "CREATE TABLE IF NOT EXISTS `stockPools` (id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, curStock SMALLINT UNSIGNED NOT NULL, maxStock SMALLINT UNSIGNED NOT NULL, restockAmt SMALLINT UNSIGNED NOT NULL, stockInterval INT UNSIGNED NOT NULL, lastRestock INT UNSIGNED NOT NULL);"
	local itemCreate = string.format("CREATE TABLE IF NOT EXISTS `items` (id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, uniqueID VARCHAR(64) NOT NULL, cost INT UNSIGNED NOT NULL, sale INT UNSIGNED, classes VARCHAR(%u) NOT NULL, category SMALLINT UNSIGNED, FOREIGN KEY (category) REFERENCES categories(id), stockPool SMALLINT UNSIGNED, FOREIGN KEY (stockPool) REFERENCES stockPools(id), rarity TINYINT UNSIGNED);", BuyMenu.ClassStringLen)
	BuyMenu.SQL:Query(classCreate .. categoryCreate .. stockPoolCreate .. itemCreate, function()
		BuyMenu.Print("Assigning class IDs #", #nut.class.list)

		-- Get a list of all possible IDs
		local allIDs = {}
		for i = 1, BuyMenu.ClassStringLen do
			allIDs[i] = i
		end

		BuyMenu.SQL:Query("SELECT * FROM `classes`;", function(dat)
			dat = dat or {}
			-- Get a list of currently unused IDs
			local available = {}

			for _, id in ipairs(allIDs) do
				local isAvailable = true

				for _, column in ipairs(dat) do
					if id == column.id then
						isAvailable = false
						break
					end
				end

				if isAvailable then
					table.insert(available, id)
				end
			end

			-- Assign those IDs
			local dbClassLookup = {}
			local toRemove = {}
			local uidToClassID = {}

			for i, class in ipairs(nut.class.list) do
				uidToClassID[class.uniqueID] = i
			end

			for i, column in ipairs(dat) do
				dbClassLookup[column.uniqueID] = column.id

				-- Also check for any non-existent classes still in the database
				if nut.class.list[uidToClassID[column.uniqueID]] == nil then
					table.insert(toRemove, column.uniqueID)
					table.insert(available, column.id) -- Mark the ID as available
				end
			end

			-- Create the SQL query to remove any old classes
			local removeSQL = "DELETE FROM `classes` WHERE uniqueID IN ("

			for i, uid in ipairs(toRemove) do
				removeSQL = removeSQL .. "'" .. uid .. "'" .. ","
			end

			removeSQL = removeSQL:TrimRight(",") .. ");"

			-- Create the SQL query to insert any new classes
			local addSQL = "INSERT INTO `classes` VALUES"
			local j = 1

			for i, class in ipairs(nut.class.list) do
				local uid = class.uniqueID

				if dbClassLookup[uid] == nil then
					local id = available[j]
					addSQL = addSQL .. string.format("(%u, '%s'),", id, uid)
					j = j + 1
				end
			end

			addSQL = addSQL:TrimRight(",") .. ";"

			-- Set nth character to 0 for every item
			local itemSQL = ""
			for i, uid in ipairs(toRemove) do
				local id = dbClassLookup[uid]
				itemSQL = itemSQL .. string.format("UPDATE `items` SET classes = INSERT(classes, %u, 1, '0');", id)
			end

			local sql = ""
			sql = sql .. (#toRemove > 0 and removeSQL or "") .. itemSQL .. (!addSQL:EndsWith("VALUES;") and addSQL or "")

			if sql != "" then
				BuyMenu.SQL:Query(sql, BuyMenu.ReadFromDB)
			else
				BuyMenu.ReadFromDB()
			end
		end)
	end)
end
timer.Simple(0, BuyMenu.SQLInit)

-- Logs
function BuyMenu.LogsSetup()
	local result, err = jlib.logs.CreateLog("BuyMenu", {"Player Name", "SteamID", "Character ID", "Faction", "Item Name", "Item UniqueID"})
	BuyMenu.Print("Setting up logs for buy menu. ", result, " ", err)

	jlib.logs.AuthFuncs.BuyMenu = function(ply)
		return ply:IsSuperAdmin() or (hcWhitelist.isHC(ply) and ply:getChar())
	end

	jlib.logs.CondFuncs.BuyMenu = function(ply)
		if hcWhitelist.isHC(ply) and !ply:IsSuperAdmin() then
			local char = ply:getChar()
			local faction = nut.faction.indices[char:getFaction()].uniqueID
			return "`faction` = '" .. faction .. "'"
		end
	end
end
hook.Add("Initialize", "BuyMenuLogs", BuyMenu.LogsSetup)

-- Config networking
net.Receive("BuyMenuCategoryCreate", function(len, ply)
	if ply:IsSuperAdmin() then
		local name = net.ReadString()
		local icon = net.ReadUInt(32)

		BuyMenu.SQL:Query(string.format("INSERT INTO `categories` VALUES(NULL, '%s', %u); SELECT LAST_INSERT_ID();", BuyMenu.SQL:Escape(name), icon), function(_, dat)
			local id = dat[1]["LAST_INSERT_ID()"]
			BuyMenu.Categories[id] = {id = id, name = name, icon = icon}

			net.Start("BuyMenuCategoryCreate")
				net.WriteUInt(id, 8)
				net.WriteString(name)
				net.WriteUInt(icon, 32)
			net.Broadcast()

			ply:ChatPrint("Category Created")
		end)
	end
end)

net.Receive("BuyMenuCategoryUpdate", function(len, ply)
	if ply:IsSuperAdmin() then
		local id = net.ReadUInt(8)
		local name = net.ReadString()
		local icon = net.ReadUInt(32)

		BuyMenu.SQL:Query(string.format("UPDATE `categories` SET name = '%s', icon = %u WHERE id = %u;", BuyMenu.SQL:Escape(name), icon, id), function()
			BuyMenu.Categories[id] = {id = id, name = name, icon = icon}

			net.Start("BuyMenuCategoryCreate")
				net.WriteUInt(id, 8)
				net.WriteString(name)
				net.WriteUInt(icon, 32)
			net.Broadcast()

			ply:ChatPrint("Category Updated")
		end)
	end
end)

net.Receive("BuyMenuCategoryRemove", function(len, ply)
	if ply:IsSuperAdmin() then
		local id = net.ReadUInt(8)

		BuyMenu.SQL:Query(string.format("DELETE FROM `categories` WHERE id = %u;", id), function()
			net.Start("BuyMenuCategoryRemove")
				net.WriteUInt(id, 8)
			net.Broadcast()

			ply:ChatPrint("Category Removed")
		end)
	end
end)

net.Receive("BuyMenuItemCreate", function(len, ply)
	if ply:IsSuperAdmin() then
		local uniqueID = net.ReadString()
		local price = net.ReadUInt(32)
		local sellPrice = net.ReadUInt(32)
		local categoryID = net.ReadUInt(8)
		local classStr = jlib.ReadCompressedString()
		local poolID = net.ReadUInt(16)
		local rarity = net.ReadUInt(8)
		local pool = poolID != 0 and BuyMenu.StockPools[poolID] or nil
		rarity = rarity > 0 and rarity or "NULL"

		BuyMenu.SQL:Query(string.format("INSERT INTO `items` VALUES(NULL, '%s', %u, %s, '%s', %u, %s, %s); SELECT LAST_INSERT_ID();", BuyMenu.SQL:Escape(uniqueID), price, sellPrice != 0 and sellPrice or "NULL", BuyMenu.SQL:Escape(classStr), categoryID, pool and pool:GetID() or "NULL", rarity), function(_, dat)
			local id = dat[1]["LAST_INSERT_ID()"]
			BuyMenu.Items[id] = {id = id, item = uniqueID, price = price, sellPrice = sellPrice, category = categoryID, classes = classStr, pool = pool and pool:GetID() or nil, rarity = isnumber(rarity) and rarity or nil}

			net.Start("BuyMenuItemCreate")
				net.WriteUInt(id, 16)
				net.WriteString(uniqueID)
				net.WriteUInt(price, 32)
				net.WriteUInt(sellPrice, 32)
				net.WriteUInt(categoryID, 8)
				jlib.WriteCompressedString(classStr)
				net.WriteUInt(poolID, 16)
				net.WriteUInt(isnumber(rarity) and rarity or 0, 8)
			net.Broadcast()

			ply:ChatPrint("Item Created")
		end)
	end
end)

net.Receive("BuyMenuItemUpdate", function(len, ply)
	if ply:IsSuperAdmin() then
		local id = net.ReadUInt(16)
		local uniqueID = net.ReadString()
		local price = net.ReadUInt(32)
		local sellPrice = net.ReadUInt(32)
		local categoryID = net.ReadUInt(8)
		local classStr = jlib.ReadCompressedString()
		local poolID = net.ReadUInt(16)
		local rarity = net.ReadUInt(8)
		local pool = poolID != 0 and BuyMenu.StockPools[poolID] or nil
		rarity = rarity > 0 and rarity or "NULL"

		BuyMenu.SQL:Query(string.format("UPDATE `items` SET uniqueID = '%s', cost = %u, sale = %s, classes = '%s', category = %u, stockPool = %s, rarity = %s WHERE id = %u;", BuyMenu.SQL:Escape(uniqueID), price, sellPrice != 0 and sellPrice or "NULL", BuyMenu.SQL:Escape(classStr), categoryID, pool and pool:GetID() or "NULL", rarity, id), function()
			BuyMenu.Items[id] = {id = id, item = uniqueID, price = price, sellPrice = sellPrice, category = categoryID, classes = classStr, pool = pool and pool:GetID() or nil, rarity = isnumber(rarity) and rarity or nil}

			net.Start("BuyMenuItemCreate")
				net.WriteUInt(id, 16)
				net.WriteString(uniqueID)
				net.WriteUInt(price, 32)
				net.WriteUInt(sellPrice, 32)
				net.WriteUInt(categoryID, 8)
				jlib.WriteCompressedString(classStr)
				net.WriteUInt(poolID, 16)
				net.WriteUInt(isnumber(rarity) and rarity or 0, 8)
			net.Broadcast()

			ply:ChatPrint("Item Updated")
		end)
	end
end)

net.Receive("BuyMenuItemRemove", function(len, ply)
	if ply:IsSuperAdmin() then
		local id = net.ReadUInt(16)

		BuyMenu.SQL:Query(string.format("DELETE FROM `items` WHERE id = %u;", id), function()
			net.Start("BuyMenuItemRemove")
				net.WriteUInt(id, 16)
			net.Broadcast()

			ply:ChatPrint("Item Removed")
		end)
	end
end)

net.Receive("BuyMenuStockCreate", function(len, ply)
	if ply:IsSuperAdmin() then
		local dat = {}

		local maxStock = net.ReadUInt(32)
		dat.maxStock = maxStock
		dat.curStock = maxStock
		dat.restockAmt = net.ReadUInt(32)
		dat.stockInterval = net.ReadUInt(32)
		dat.lastRestock = os.time()

		BuyMenu.CreateStockPool(dat, true, function()
			net.Start("BuyMenuStockCreate")
				net.WriteUInt(dat.id, 16)
			net.Send(ply)

			ply:ChatPrint("Stock Pool Created")
		end)
	end
end)

net.Receive("BuyMenuStockUpdate", function(len, ply)
	if ply:IsSuperAdmin() then
		local id = net.ReadUInt(16)
		local maxStock = net.ReadUInt(32)
		local restockAmt = net.ReadUInt(32)
		local stockInterval = net.ReadUInt(32)

		local pool = BuyMenu.StockPools[id]

		BuyMenu.SQL:Query(string.format("UPDATE `stockPools` SET maxStock = %u, restockAmt = %u, stockInterval = %u WHERE id = %u", maxStock, restockAmt, stockInterval, id), function()
			pool:SetMaxStock(maxStock)
			pool:SetRestockAmt(restockAmt)
			pool:SetStockInterval(stockInterval)

			ply:ChatPrint("Stock Pool Updated")
		end)

		if maxStock < pool:GetStock() then
			pool:SetStock(maxStock)
		end
	end
end)

net.Receive("BuyMenuManualRestock", function(len, ply)
	if ply:IsSuperAdmin() then
		local id = net.ReadUInt(16)

		local pool = BuyMenu.StockPools[id]
		pool:Restock()

		ply:ChatPrint("Stock Pool Restocked")
	end
end)

net.Receive("BuyMenuStockRemove", function(len, ply)
	if ply:IsSuperAdmin() then
		local id = net.ReadUInt(16)

		local pool = BuyMenu.StockPools[id]
		pool:Remove()

		ply:ChatPrint("Stock Pool Removed")
	end
end)

net.Receive("BuyMenuPurchase", function(len, ply)
	local char = ply:getChar()
	if !char then return end

	local id = net.ReadUInt(16)
	local data = BuyMenu.Items[id]
	local uniqueID = data.item
	local item = nut.item.list[uniqueID]
	local classes = BuyMenu.GetClassTable(data.classes)
	local price = data.price
	local rarity

	local class = nut.class.list[char:getClass()].uniqueID
	if classes and !classes[class] then
		print(ply:SteamID() .. "attempted to purchase without having permission.")
		return 
	end

	if item.base == "base_firearm" and data.rarity then
		rarity = data.rarity
	end

	local stockPool = BuyMenu.StockPools[data.pool or 0]
	if istable(stockPool) and stockPool:GetStock() <= 0 then
		ply:notify("Item is out of stock.")
		return
	end
	
	local canAfford = char:hasMoney(price)
	local space = char:getInv():findEmptySlot(item.width, item.height)

	if canAfford and space then
		BuyMenu.verifyCanPurchase(id, function(res)
			if res then
				char:takeMoney(price)

				local inv = char:getInv()
				if rarity then
					wRarity.CreateItem(inv, uniqueID, wRarity.Config.Rarities[rarity])
				else
					char:getInv():add(uniqueID)
				end

				if istable(stockPool) then
					if stockPool:GetStock() == stockPool:GetMaxStock() then
						stockPool:SetLastRestock(os.time())
					end

					stockPool:TakeStock()
				end

				jlib.logs.Add("BuyMenu", {ply:Nick(), ply:SteamID(), char:getID(), nut.faction.indices[char:getFaction()].uniqueID, nut.item.list[uniqueID].name, uniqueID})
			else
				jlib.Announce(ply, Color(255,0,0), "[BUY MENU] ", Color(255,155,155), "Information:", Color(255,255,255), "\n· You were not charged for the purchase\n· This occurs when an item is purchased on another server\n· We have updated the stock with the updated amount")
				ply:notify("The item you are attempting to purchase is no longer in stock")
				stockPool:SetStock(0, true)
			end
		end)
	elseif !space then
		ply:notify("Not enough inventory space.")
	elseif !canAfford then
		ply:notifyLocalized("canNotAfford")
	else
		ply:notify("invalid")
	end
end)

net.Receive("BuyMenuSell", function(len, ply)
	local char = ply:getChar()
	if !char then return end

	local id = net.ReadUInt(16)
	local data = BuyMenu.Items[id]
	local uniqueID = data.item
	local price = data.sellPrice
	local classes = BuyMenu.GetClassTable(data.classes)

	local stockPool = BuyMenu.StockPools[data.pool or 0]
	local item, err

	local class = nut.class.list[char:getClass()].uniqueID
	if classes and !classes[class] then
		print(ply:SteamID() .. "attempted to sell without having permission.")
		return 
	end

	BuyMenu.verifyCanSell(id, function(res)
		if !res then return end

		if data.rarity then
			for _, searchItem in pairs(char:getInv():getItems()) do
				if searchItem.uniqueID == data.item and searchItem.data.rarity == data.rarity then
					item = searchItem
				end
			end

			if item == nil then
				item = false
				err = "No item of the correct rarity found"
			end
		else
			item = char:getInv():hasItem(uniqueID)
		end

		if item then
			item:remove()
			char:giveMoney(price)

			if istable(stockPool) and stockPool:GetStock() < stockPool:GetMaxStock() then
				stockPool:SetStock(stockPool:GetStock() + 1)
			end
		elseif err then
			ply:notifyLocalized(err)
		end

		return
	end)
end)

-- Networking to players
function BuyMenu.NetworkCategoriesTo(ply)
	net.Start("BuyMenuCategories")
		jlib.WriteCompressedTable(BuyMenu.Categories)
	net.Send(ply)
end
hook.Add("PlayerInitialSpawn", "BuyMenuCatNetwork", BuyMenu.NetworkCategoriesTo)

function BuyMenu.NetworkItemsTo(ply)
	net.Start("BuyMenuItems")
		jlib.WriteCompressedTable(BuyMenu.Items)
	net.Send(ply)
end
hook.Add("PlayerInitialSpawn", "BuyMenuItemNetwork", BuyMenu.NetworkItemsTo)

function BuyMenu.NetworkClassesTo(ply)
	net.Start("BuyMenuClasses")
		jlib.WriteCompressedTable(BuyMenu.IDToClass)
		jlib.WriteCompressedTable(BuyMenu.ClassToID)
	net.Send(ply)
end
hook.Add("PlayerInitialSpawn", "BuyMenuClassNetwork", BuyMenu.NetworkClassesTo)

-- Data import
function BuyMenu.ImportData()
	if !BuyMenu.FullyInitialized then
		BuyMenu.Print("Not yet fully initialized, try again after initialization")
		return
	end

	local gamemode = engine.ActiveGamemode()
	local categories = util.JSONToTable(file.Read("buymenu/" .. gamemode .. "/categories.txt", "DATA"))
	local items = util.JSONToTable(file.Read("buymenu/" .. gamemode .. "/items.txt", "DATA"))
	local stock = util.JSONToTable(file.Read("buymenu/" .. gamemode .. "/stock.json", "DATA"))

	-- Import categories
	local categoriesSQL = "INSERT INTO `categories` VALUES "
	local categoriesOldIDs = {}

	local i = 1
	for id, category in pairs(categories) do
		categoriesSQL = categoriesSQL .. string.format("(NULL, '%s', %u), ", category.name, tonumber(category.icon:GetFileFromFilename():StripExtension()))
		categoriesOldIDs[id] = i
		i = i + 1
	end

	categoriesSQL = string.sub(categoriesSQL, 1, -3) .. ";"

	-- Import items
	local itemsSQL = "INSERT INTO `items` VALUES "
	local valuesToInsert = {}

	for classUID, classCategories in pairs(items) do
		for categoryID, categoryItems in pairs(classCategories) do
			for itemUID, itemData in pairs(categoryItems) do
				if BuyMenu.ClassToID[classUID] != nil then
					local newCatID = categoriesOldIDs[categoryID]

					if !newCatID then continue end

					valuesToInsert[newCatID] = valuesToInsert[newCatID] or {}
					valuesToInsert[newCatID][itemUID] = valuesToInsert[newCatID][itemUID] or {}
					valuesToInsert[newCatID][itemUID][itemData.price] = (valuesToInsert[newCatID][itemUID][itemData.price] or BuyMenu.DefaultClasses):SetChar(BuyMenu.ClassToID[classUID], "1")
				end
			end
		end
	end

	for categoryID, categoryItems in pairs(valuesToInsert) do
		for itemUID, prices in pairs(categoryItems) do
			for price, classes in pairs(prices) do
				itemsSQL = itemsSQL .. string.format("(NULL, '%s', %u, NULL, '%s', %u, NULL, NULL), ", BuyMenu.SQL:Escape(itemUID), price, classes, categoryID)
			end
		end
	end

	itemsSQL = string.sub(itemsSQL, 1, -3) .. ";"

	-- Replace all the currently stored data with our import
	BuyMenu.SQL:Query("SET FOREIGN_KEY_CHECKS=0; TRUNCATE TABLE items; TRUNCATE TABLE categories; TRUNCATE TABLE stockPools; SET FOREIGN_KEY_CHECKS=1;" .. categoriesSQL .. itemsSQL, function()
		-- Import stock
		local stockSelectSQL = "SELECT id, uniqueID FROM `items` WHERE uniqueID IN ("

		for itemID, stockData in pairs(stock) do
			stockSelectSQL = stockSelectSQL .. string.format("'%s', ", itemID)
		end

		stockSelectSQL = string.sub(stockSelectSQL, 1, -3) .. ");"

		BuyMenu.SQL:Query(stockSelectSQL, function(data)
			local stockImportSQL = "INSERT INTO `stockPools` VALUES "
			local stockAssignmentSQL = ""

			for j, itemDat in ipairs(data) do
				local stockData = stock[itemDat.uniqueID]
				stockImportSQL = stockImportSQL .. string.format("(NULL, %u, %u, %u, %u, %u), ", stockData.curStock, stockData.maxStock, stockData.restockAmt or stockData.maxStock, stockData.stockInterval, stockData.nextStock and (stockData.nextStock - stockData.stockInterval) or os.time())
				stockAssignmentSQL = stockAssignmentSQL .. string.format("UPDATE `items` SET stockPool = %u WHERE uniqueID = '%s';", j, itemDat.uniqueID)
			end

			stockImportSQL = string.sub(stockImportSQL, 1, -3) .. ";"

			BuyMenu.SQL:Query(stockImportSQL .. stockAssignmentSQL, function()
				BuyMenu.Print("Import complete, you MUST now restart the server.")
			end)
		end)
	end)
end

-- 2022 addition to verify an items stock actually exists
function BuyMenu.verifyCanPurchase(itemID, callback)
	BuyMenu.SQL:Query(string.format("SELECT * FROM `items` WHERE id = %u;", itemID), function(itemsRes)
		if itemsRes then
			local hasStock = itemsRes[1] and itemsRes[1].stockPool
			if hasStock then
				BuyMenu.SQL:Query(string.format("SELECT * FROM `stockPools` WHERE id = %u;", itemsRes[1].stockPool), function(stockRes)
					local curStock = stockRes[1] and stockRes[1].curStock

					if curStock > 0 then
						callback(true)
					else
						callback(false)
					end
				end)
			else
				callback(true)
			end
		else
			ErrorNoHalt("Failed to verify existence of items[" .. itemID .. "] within buy menu database")
		end
	end)
end

-- 2022 addition to verify an items stock is sellable
function BuyMenu.verifyCanSell(itemID, callback)
	BuyMenu.SQL:Query(string.format("SELECT * FROM `items` WHERE id = %u;", itemID), function(itemsRes)
		if itemsRes then
			local hasStock = itemsRes[1] and itemsRes[1].stockPool
			if hasStock then
				BuyMenu.SQL:Query(string.format("SELECT * FROM `stockPools` WHERE id = %u;", itemsRes[1].stockPool), function(stockRes)
					local curStock = stockRes[1] and stockRes[1].curStock
					local maxStock =  stockRes[1] and stockRes[1].maxStock

					if curStock < maxStock then
						callback(true)
					else
						callback(false)
					end
				end)
			else
				callback(true)
			end
		else
			ErrorNoHalt("Failed to verify existence of items[" .. itemID .. "] within buy menu database")
		end
	end)
end

function BuyMenu.getClassItems(classID)
	local listOfItems = {}

	for itemIndex, itemData in pairs(BuyMenu.Items) do
		if BuyMenu.GetClassTable(itemData.classes)[classID] then
			table.insert(listOfItems, #listOfItems, itemData)
		end
	end

	return listOfItems
end

-- 2022 edition for cloning class configurations to another ideally new class
function BuyMenu.cloneClassItems(parentClassID, targetClassID)
	local parentClassData = BuyMenu.getClassItems(parentClassID)

	for classIndex, classData in pairs(parentClassData) do
		classTable = BuyMenu.GetClassTable(classData.classes)
		local insert = {[targetClassID] = true}
		table.Merge(classTable, insert)
		classData.classes = BuyMenu.GetClassString(classTable)
	end

	for bmIndex, bmData in pairs(BuyMenu.Items) do
		for classIndex, classData in pairs(parentClassData) do
			if classData.id == bmData.id then
				bmData.classes = classData.classes

				local sql = "UPDATE `items` SET classes = '" .. bmData.classes .. "' WHERE id = '" .. classData.id .. "';"

				BuyMenu.SQL:Query(sql, function()
					BuyMenu.Print("Updated " .. targetClassID .. " with access to: " .. classData.item)
				end)

				break
			end
		end
	end
end


-- For importing just the class data of old JSON data into existing MySQL items
function BuyMenu.ImportClasses()
	local items = util.JSONToTable(file.Read("buymenu/" .. engine.ActiveGamemode() .. "/items.txt", "DATA"))

	local sql = ""
	local valuesToUpdate = {}

	for classUID, classCategories in pairs(items) do
		for categoryID, categoryItems in pairs(classCategories) do
			for itemUID, itemData in pairs(categoryItems) do
				if BuyMenu.ClassToID[classUID] != nil then
					valuesToUpdate[itemUID] = (valuesToUpdate[itemUID] or BuyMenu.DefaultClasses):SetChar(BuyMenu.ClassToID[classUID], "1")
				end
			end
		end
	end

	for uid, classStr in pairs(valuesToUpdate) do
		sql = sql .. "UPDATE `items` SET classes = '" .. classStr .. "' WHERE uniqueID = '" .. BuyMenu.SQL:Escape(uid) .. "';"
	end

	BuyMenu.SQL:Query(sql, function()
		BuyMenu.Print("Class import complete.")
	end)
end
