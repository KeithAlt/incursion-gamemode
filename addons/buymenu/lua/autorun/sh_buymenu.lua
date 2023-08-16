BuyMenu = BuyMenu or {}
BuyMenu.Config = BuyMenu.Config or {}
BuyMenu.Categories = BuyMenu.Categories or {}
BuyMenu.Items = BuyMenu.Items or {}
BuyMenu.IDToClass = BuyMenu.IDToClass or {}
BuyMenu.ClassToID = BuyMenu.ClassToID or {}
BuyMenu.StockTimer = 60
BuyMenu.Author = "jonjo"

BuyMenu.Print = jlib.GetPrintFunction("[BuyMenu]", Color(15, 145, 179))

AddCSLuaFile("stockpool.lua")
AddCSLuaFile("buymenu_config.lua")
include("stockpool.lua")
include("buymenu_config.lua")

-- Class uniqueID to ID caching
BuyMenu.ClassUIDCache = BuyMenu.ClassUIDCache or {}

hook.Add("InitPostEntity", "FalloutBMUIDCache", function()
	for id, class in pairs(nut.class.list) do
		BuyMenu.ClassUIDCache[class.uniqueID] = id
	end
end)

function BuyMenu.GetClass(ply)
	local classIndex = ply:getChar():getClass()
	if classIndex then
		local classTable = nut.class.list[classIndex]
		return classTable.uniqueID
	else
		local factionIndex = ply:getChar():getFaction()

		for _, class in ipairs(nut.class.list) do
			if class.faction == factionIndex and class.isDefault then
				return class.uniqueID
			end
		end
	end
end

-- Class strings
BuyMenu.ClassStringLen = 512
BuyMenu.DefaultClasses = string.rep("0", BuyMenu.ClassStringLen)

function BuyMenu.GetClassString(classes)
	local str = BuyMenu.DefaultClasses

	for class, _ in pairs(classes) do
		str = string.SetChar(str, BuyMenu.ClassToID[class], "1")
	end

	return str
end

function BuyMenu.GetClassTable(classStr)
	local classes = {}

	for i, char in ipairs(string.Explode("", classStr)) do
		if char == "1" then
			classes[BuyMenu.IDToClass[i]] = true
		end
	end

	return classes
end

function BuyMenu.IsClassSet(classStr, classID)
	return string.sub(classStr, classID, classID) == "1"
end

-- Menus
function BuyMenu.Sample(ply)
	if SERVER then
		net.Start("FalloutBMDemo")
		net.Send(ply)
	end

	if CLIENT then
		local frame = vgui.Create("DFrame")
		frame:SetSize(1000, 700)
		frame:Add("BuyMenuCategories")
		frame:MakePopup()
		frame:Center()
	end
end
if CLIENT then
	net.Receive("FalloutBMDemo", BuyMenu.Sample)
end

function BuyMenu.ConfigMenu(ply)
	if SERVER then
		net.Start("FalloutBMConfig")
		net.Send(ply)
	end

	if CLIENT then
		vgui.Create("BuyMenuConfig")
	end
end
if CLIENT then
	net.Receive("FalloutBMConfig", BuyMenu.ConfigMenu)
end

hook.Add("InitPostEntity", "BuyMenuInit", function()
	if BuyMenu.Config.Debug then
		nut.command.add("buymenudemo", {
			superAdminOnly = true,
			onRun = function(ply, args)
				BuyMenu.Sample(ply)
			end
		})
	end

	nut.command.add("buymenucategories", {
		superAdminOnly = true,
		onRunClient = function()
			BuyMenu.ConfigCategories()
		end
	})

	nut.command.add("buymenuitems", {
		superAdminOnly = true,
		onRunClient = function()
			BuyMenu.ConfigItems()
		end
	})

	nut.command.add("buymenustock", {
		superAdminOnly = true,
		onRunClient = function()
			BuyMenu.ConfigStockPools()
		end
	})

	nut.command.add("buymenulogs", {
		onRun = function(ply, args)
			local char = ply:getChar()

			if ply:IsSuperAdmin() then
				jlib.logs.SendLogs("BuyMenu", ply, 50)
			elseif char and hcWhitelist.isHC(ply) then
				jlib.logs.SendLogs("BuyMenu", ply, 50, 1, jlib.logs.CondFuncs.BuyMenu(ply))
			else
				ply:notify("No permission.")
			end
		end
	})

-- 2022 command for cloning class configurations to another ideally new class
	nut.command.add("cloneclass", {
		superAdminOnly = true,
		syntax = "<parentClass> <targetClass>",
		onRun = function(client, args)
			if !args[1] or !args[2] or (#args[1] < 1) or (#args[2] < 1) then
				client:notify("Your class arguments are not valid")

				jlib.Announce(
					client, Color(255,255,0,255), "[CLONE COMMAND] ",
					Color(155,255,155,255), "Information:",
					Color(255,255,255,255), "\n· The clone command requires that the 1st & 2nd argument are exactly the unique class IDs of both classes" ..
					"\n· Try the '/classnameviewer' command to view the class IDs of all the classes in the registry",
					Color(255,255,0,255), "\n\nEXAMPLE USE: ", Color(255,255,155,255), '/cloneclass "bos_officer" "bos_infiltrator"',
					Color(255,255,255,255), "\n· This will copy & paste all the Buy Menu data for the bos_officer class TO the bos_infiltrator class",
					Color(255,0,0,255), "\n\nWARNING: ", Color(255,150,150,255), "Don't mess with this command if you're not familiar with it's use!"
				)
				return
			end

			local parentClass
			local cloneClass

			for index, class in pairs(nut.class.list) do
				if nut.class.list[index].uniqueID == args[1] and !parentClass then
					parentClass = nut.class.list[index].uniqueID
				end

				if nut.class.list[index].uniqueID == args[2] and !cloneClass then
					cloneClass = nut.class.list[index].uniqueID
				end

				if parentClass and cloneClass then
					break
				end
			end

			if !parentClass or !cloneClass then
				client:notify("You provided an invalid class name argument")

				jlib.Announce(
					client, Color(255,255,0,255), "[CLONE COMMAND] ",
					Color(155,255,155,255), "Information:",
					Color(255,255,255,255), "\n· The clone command requires that the 1st & 2nd argument are exactly the unique class IDs of both classes" ..
					"\n· Try the '/classnameviewer' command to view the class IDs of all the classes in the registry",
					Color(255,255,0,255), "\n\nEXAMPLE USE: ", Color(255,255,155,255), '/cloneclass "bos_officer" "bos_infiltrator"',
					Color(255,255,255,255), "\n· This will copy & paste all the Buy Menu data for the bos_officer class TO the bos_infiltrator class",
					Color(255,0,0,255), "\n\nWARNING: ", Color(255,150,150,255), "Don't mess with this command if you're not familiar with it's use!"
				)
				return
			end

			jlib.RequestBool("Copy/Paste BM data?", function(bool)
				if !bool then
 					client:notify("Cancelled BM query")

					jlib.Announce(
						client, Color(255,255,0,255), "[CLONE COMMAND] ",
						Color(155,255,155,255), "Information:",
						Color(255,255,255,255), "\n· The clone command requires that the 1st & 2nd argument are exactly the unique class IDs of both classes" ..
						"\n· Try the '/classnameviewer' command to view the class IDs of all the classes in the registry",
						Color(255,255,0,255), "\n\nEXAMPLE USE: ", Color(255,255,155,255), '/cloneclass "bos_officer" "bos_infiltrator"',
						Color(255,255,255,255), "\n· This will copy & paste all the Buy Menu data for the bos_officer class TO the bos_infiltrator class",
						Color(255,0,0,255), "\n\nWARNING: ", Color(255,150,150,255), "Don't mess with this command if you're not familiar with it's use!"
					)
					return
				end

				BuyMenu.cloneClassItems(parentClass, cloneClass)
				client:notify("Successfully cloned BM data")

				DiscordEmbed(jlib.SteamIDName(client) .. " has cloned the buy menu data from the '" .. parentClass  .. "' class to the '" .. cloneClass .. "'", "🛒 Buy Menu Clone Log 🛒", Color(255, 0, 0), "BTeam")

			end, client, "Yes", "No")

		end
	})
	--BuyMenu.cloneClassItems(parentClassID, targetClassID)
end)
