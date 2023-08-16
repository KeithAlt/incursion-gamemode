if (!nut.crafting.recipes) then nut.crafting.recipes = {} end;
nut.crafting.config = {XP = 3}

function nut.crafting.addRecipe(category, id, recipe)
	if (!nut.crafting.recipes[category]) then
		nut.crafting.recipes[category] = {}
	end;

	--print(table.ToString(recipe, '["'..id..'"]', true)..",")

	nut.crafting.recipes[category][id] = recipe
end;

nut.util.include("sv_recipes.lua")

function nut.crafting.open(player, category)
	local hunger = 100 --player:getChar():getData("hunger", nut.survival.config.hungerMax)
	local thirst = 100 --player:getChar():getData("thirst", nut.survival.config.thirstMax)

	--if (hunger < (nut.survival.config.hungerMax * 0.25) and thirst < (nut.survival.config.thirstMax * 0.25)) then
	if (hunger < (100 * 0.25) and thirst < (100 * 0.25)) then
		player:ChatPrint("You are too hungry and thirsty to try and build or make anything.")
		return
	end;

	local recipes, fault, faultID = nut.crafting.check(player, category)

	if (fault) then
		if (faultID == 1) then
			player:ChatPrint("The crafting category: '"..category.."' is not valid.")
		elseif (faultID == 2) then
			jlib.Announce(player,
				Color(0,255,0), "[CRAFTING] ", Color(155,255,155), "Information:",
				Color(255,255,255), "\n· You must unlock the ", Color(255,255,0), "Tinker Tim", Color(255,255,255), " skill to craft weapons" ..
				"\n· To craft weapons, you must obtain & learn a ", Color(255,255,0), "blueprint", Color(255,255,255), " for that weapon" ..
				"\n· To craft weapons, you must obtain a ", Color(255,255,0),"weapon frame", Color(255,255,255), " for that weapon"
			)
		else
			player:ChatPrint("An error happened when trying to open the crafting UI: '"..fault.."'")
		end;

		return
	end;

	netstream.Start(player, "craftingUI", recipes)
end;

function nut.crafting.check(player, category)
	if (nut.crafting.recipes[category]) then
		local character = player:getChar()
		local inventory = character:getInv()

		local knownBP = character:getData("recipes", {})

		local checked = {} -- Temp table to store the recipes after their blueprint/kit and materials has been checked.

		for i, v in pairs(nut.crafting.recipes[category]) do -- Keeps adding junk data to the recipes table every time it's run. Why?
			if (v["blueprint"] and table.HasValue(knownBP, v["blueprint"]) or !v["blueprint"]) then
				checked[i] = table.Copy(v)

				for x, y in pairs(v["materials"]) do
					local count = inventory:getItemsByUniqueID(x) -- Table containing all instances in the inventory of the given material.

					checked[i]["materials"][x] = {y, #count} -- Required amount, possessed amount.
				end;

				checked[i]["category"] = category;
			end;
		end;

		if (table.Count(checked) > 0) then -- TODO: Fix table count check.
			return checked
		else
			return false, "No Known Recipe", 2
		end;
	else
		return false, "Invalid Category", 1
	end;
end;

netstream.Hook("completeCraft", function(player, category, id)
	local sucsess, fault = nut.crafting.complete(player, category, id)

	if (!sucsess) then
		player:ChatPrint(fault)
	else
		player:falloutNotify("☑ Weapon Crafting Successful", "shelter/jingle/emergency_succes.ogg")
	end;

	nut.crafting.open(player, category)
end)

function nut.crafting.complete(player, category, id)
	if (nut.crafting.recipes[category][id]) then
		local character = player:getChar()
		local inventory = character:getInv()
		local intelligence = player:getSpecial("I")

		local recipe = nut.crafting.recipes[category][id]

		if recipe["intelligence"] and intelligence < recipe["intelligence"] then
			return false, "Lacking Intelligence", 4
		end

		if recipe["skill"] and !player:hasSkerk(recipe["skill"]) then
			return false, "Lacking Skill", 5;
		end

		for i, v in pairs(recipe["materials"]) do -- First materials loop is to double check if they actually have the materials.
			local t = inventory:getItemsByUniqueID(i)

			if (v > #t) then
				return false, "Missing Requirements", 2 -- Missing requirements.
			end;
		end;

		for i, v in pairs(recipe["results"]) do
			local inv = player:getChar():getInv()

			--Apply a random rarity to the weapon they've crafted
			local itemTable = nut.item.list[id]
			local x, y = inv:findEmptySlot(itemTable.width, itemTable.height, true)

			if (!x) then
				nut.log.addRaw("("..player:SteamID()..")"..player:GetName().." has failed craft '"..id.."' from category '"..category.."'")

				return false, "Not Enough Inventory Space", 3 -- Not enough inventory space.
			end

			local rarity = wRarity.GetRarity(player)

			if (player:getSpecial("L") > 0) and rarity.name != "Common" then
				jlib.Announce(player, Color(255, 255, 0, 255), "[LUCK] ", Color(255, 255, 155, 255), "You feel your luckful nature has helped you craft this weapon . . .")
				player:falloutNotify("You feel lucky . . .", "shelter/sfx/training_luck.ogg")
			end

			wRarity.ConsoleLog(player:Nick() .. " has crafted a weapon of rarity " .. rarity.name, true)

			local data = {
				["rarity"] = rarity.index,
				["name"] = rarity.name .. " " .. nut.item.list[i].name
			}

			nut.item.instance(inv:getID(), id, data, x, y, function(item)
				inv:add(item:getID(), 1, data, x, y)
			end)

			nut.log.addRaw("("..player:SteamID()..")"..player:GetName().." has crafted '"..id.."' from category '"..category.."'")

			player:notify("You crafted a "  .. rarity.name .. " " .. nut.item.list[id].name .. "!")
		end;

		for i, v in pairs(recipe["materials"]) do -- Second materials loop takes the requirements after they are verified by the first.
			for _, x in pairs(inventory:getItems()) do
				if (x.uniqueID == i and v > 0) then
					v = v - 1
					x:remove()
				end;
			end;
		end;

		if (recipe["xp"] > 0) then
			nut.leveling.giveXP(player, recipe["xp"])
		end;

		return true
	else
		return false, "Invalid Recipe", 1 -- Invalid recipe ID
	end;
end;
