AddCSLuaFile("marketplace_config.lua")

Marketplace = Marketplace or {}
Marketplace.Config = Marketplace.Config or {}

include("marketplace_config.lua")

Marketplace.Print = Marketplace.Print or jlib.GetPrintFunction("[Marketplace]", Color(50, 255, 50, 255))

-- Item details feature
Marketplace.Details = Marketplace.Details or {}

function Marketplace.SetupWeaponsDetails(type)
	for uniqueID, dat in pairs(nut.fallout.registry[type]) do
		Marketplace.Details[uniqueID] = {
			["rarity"] = {
				["Name"] = "Rarity",
				["Default"] = 1,
				["Format"] = function(data)
					return wRarity.Config.Rarities[data].name
				end
			},
			["name"] = {
				["Name"] = "Name",
				["Default"] = "No custom name",
				["Format"] = function(data)
					return data
				end
			},
			["brand"] = {
				["Name"] = "Brand",
				["Default"] = "No brand",
				["Format"] = function(data)
					return data
				end
			}
		}
	end
end

function Marketplace.SetupDetails()
	Marketplace.Print("Setting up weapon details")

	Marketplace.SetupWeaponsDetails("primary")
	Marketplace.SetupWeaponsDetails("secondary")
	Marketplace.SetupWeaponsDetails("melee")
	Marketplace.SetupWeaponsDetails("laser")
	Marketplace.SetupWeaponsDetails("plasma")

	for uniqueID, dat in pairs(jChems.Chems) do
		Marketplace.Details[uniqueID] = {
			["quality"] = {
				["Name"] = "Quality",
				["Default"] = 0,
				["Format"] = function(data)
					return jChems.Config.SkillLevels[data]
				end
			}
		}
	end
end

gameevent.Listen("player_spawn")
hook.Add("player_spawn", "MarketplaceWeaponSetup", function(dat)
	Marketplace.SetupDetails()
	hook.Remove("player_spawn", "MarketplaceWeaponSetup")
end)

function Marketplace.GetItemDetails(uniqueID, itemData)
	local details = {}

	for dataID, data in pairs(Marketplace.Details[uniqueID] or {}) do
		details[data.Name] = data.Format(itemData[dataID] or data.Default)
	end

	return details
end

-- Item categories
Marketplace.CategoryItemPrefixes = {
	["armor_"] = "Armor",
	["drink_"] = "Drink",
	["food_"] = "Food",
	["weapon_"] = "Weapon"
}

function Marketplace.SetupCategories()
	for uniqueID, item in pairs(nut.item.list) do
		for prefix, cat in pairs(Marketplace.CategoryItemPrefixes) do
			if uniqueID:StartWith(prefix) then
				Marketplace.Print("Adding '" .. uniqueID .. "' to '" .. cat:lower() .. "' category.")
				Marketplace.Config.Categories[uniqueID] = cat
			end
		end
	end

	for uniqueID, _ in pairs(Armor.Config.Bodies) do
		Marketplace.Print("Adding '" .. uniqueID .. "' to 'armor' category.")
		Marketplace.Config.Categories[uniqueID] = "Armor"
	end

	for uniqueID, _ in pairs(Armor.Config.Accessories) do
		Marketplace.Print("Adding '" .. uniqueID .. "' to 'armor' category.")
		Marketplace.Config.Categories[uniqueID] = "Armor"
	end

	for uniqueID, _ in pairs(jChems.Chems) do
		Marketplace.Print("Adding '" .. uniqueID .. "' to 'chems' category.")
		Marketplace.Config.Categories[uniqueID] = "Chems"
	end

	Marketplace.CategoryList = {}
	local alreadyInserted = {}

	for _, cat in pairs(Marketplace.Config.Categories) do
		if !alreadyInserted[cat] then
			table.insert(Marketplace.CategoryList, cat)
			alreadyInserted[cat] = true
		end
	end
end
hook.Add("InitializedPlugins", "MarketplaceCategories", Marketplace.SetupCategories)

function Marketplace.GetItemCategory(uniqueID)
	return Marketplace.Config.Categories[uniqueID]
end

-- Item blacklist
function Marketplace.IsItemBlacklisted(uniqueID)
	return Marketplace.Config.Blacklist[uniqueID] or false
end

-- Remote PHP script interaction
function Marketplace.CharToHex(c)
  return string.format("%%%02X", string.byte(c))
end

function Marketplace.EncodeURL(url)
	if !url then return end
	url = url:gsub("\n", "\r\n")
	url = url:gsub("([^%w_%-.~])", Marketplace.CharToHex)
	return url
end

function Marketplace.GetPage(pageNumber, callback) -- Get a page of listings
	http.Fetch(Marketplace.Config.RemoteMarketplaceURL .. "?action=getpage&page=" .. pageNumber .. "&steamid=" .. Marketplace.EncodeURL(LocalPlayer():SteamID()), function(body)
		callback(util.JSONToTable(body))
	end)
end

function Marketplace.GetItems(listingID, callback) -- Get all items within a listing
	http.Fetch(Marketplace.Config.RemoteMarketplaceURL .. "?action=getitems&listingid=" .. listingID, function(body)
		callback(util.JSONToTable(body))
	end)
end

function Marketplace.GetUnclaimedSales(steamID, charID, callback) -- Get all sold, but unclaimed items for a user
	http.Fetch(Marketplace.Config.RemoteMarketplaceURL .. "?action=getunclaimedsales&sid=" .. steamID .. "&cid=" .. charID, function(body)
		callback(util.JSONToTable(body))
	end)
end

function Marketplace.GetUnclaimedPurchases(steamID, charID, callback) -- Get all sold, but unclaimed items for a user
	http.Fetch(Marketplace.Config.RemoteMarketplaceURL .. "?action=getunclaimedpurchases&sid=" .. steamID .. "&cid=" .. charID, function(body)
		callback(util.JSONToTable(body))
	end)
end

function Marketplace.GetActiveListings(steamID, charID, callback) -- Get all listings that are not sold out for a user
	http.Fetch(Marketplace.Config.RemoteMarketplaceURL .. "?action=getactivelistings&sid=" .. steamID .. "&cid=" .. charID, function(body)
		callback(util.JSONToTable(body))
	end)
end

function Marketplace.GetActiveItems(listingID, callback) -- Get all unsold, unclaimed items for a listing
	http.Fetch(Marketplace.Config.RemoteMarketplaceURL .. "?action=getactiveitems&listingid=" .. listingID, function(body)
		callback(util.JSONToTable(body))
	end)
end

function Marketplace.GetPageCount(callback) -- Get the number of pages
	http.Fetch(Marketplace.Config.RemoteMarketplaceURL .. "?action=getpagecount", function(body)
		callback(tonumber(body))
	end)
end

function Marketplace.SearchForListings(searchTerm, callback) -- Find listings with items that match the search
	http.Fetch(Marketplace.Config.RemoteMarketplaceURL .. "?action=search&term=" .. Marketplace.EncodeURL(searchTerm) .. "&steamid=" .. Marketplace.EncodeURL(LocalPlayer():SteamID()), function(body)
		callback(util.JSONToTable(body))
	end)
end

function Marketplace.CategorySearch(category, page, callback)
	http.Fetch(Marketplace.Config.RemoteMarketplaceURL .. "?action=catsearch&cat=" .. Marketplace.EncodeURL(category) .. "&page=" .. page .. "&steamid=" .. Marketplace.EncodeURL(LocalPlayer():SteamID()), function(body)
		callback(util.JSONToTable(body))
	end)
end

-- Notification function
function Marketplace.Notify(msg, ply)
	if SERVER then
		ply:falloutNotify(msg)
	else
		nut.fallout.notify(msg)
	end
end

-- Other
function Marketplace.CompareTables(tbl1, tbl2)
	local alreadyChecked = {}

	for k, v in pairs(tbl1) do
		if istable(v) then
			if istable(tbl2[k]) then
				if !Marketplace.CompareTables(v, tbl2[k]) then
					return false
				else
					continue
				end
			else
				return false
			end
		end

		if tbl2[k] != v then return false end

		alreadyChecked[k] = true
	end

	for k, v in pairs(tbl2) do
		if alreadyChecked[k] then continue end

		if istable(v) then
			if istable(tbl1[k]) then
				if !Marketplace.CompareTables(v, tbl1[k]) then
					return false
				else
					continue
				end
			else
				return false
			end
		end

		if tbl1[k] != v then return false end
	end

	return true
end

function Marketplace.Tax(num)
	return math.floor(num * (1 - (Marketplace.Config.Tax / 100)))
end

-- Logs command
hook.Add("InitPostEntity", "MarketplaceCommands", function()
	nut.command.add("marketlogs", {
		onRun = function(ply, args)
			if jlib.logs.AuthFuncs.Marketplace(ply) then
				jlib.logs.SendLogs("Marketplace", ply, 50)
			else
				ply:notify("No permission.")
			end
		end
	})
end)
