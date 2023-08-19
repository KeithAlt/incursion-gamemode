nut.loot.tables = {}

nut.loot.rarityDefaults = {
	[1] = {"common", 53.19},
	[2] = {"uncommon", 32.55},
	[3] = {"rare", 11.40},
	[4] = {"epic", 1.8},
	[5] = {"exotic", 1},
	[6] = {"legendary", 0.05},
	[7] = {"mythic", 0.01},
	[8] = {"cosmic", 0.00},
	[9] = {"orbital", 0.00}, -- Unique loot from orbital drops
}

function nut.loot.tableRand(table) -- TO-DO: This works but could be much better..
	local repetitions = 1 -- The amount of times the table is shuffled.

	local shuffle = table

	for x = 0, repetitions do
		local numbers = {}

		for i = 1, #shuffle do -- We remove the index from this table once it's been shuffled to prevent repeat suffles of the same numbers.
			numbers[i] = i
		end;

		for i = 1, #shuffle do
			--local r1 = table.Random(numbers)
			--numbers[r1] = nil
			local i1 = math.random(#numbers)
			local r1 = numbers[i1]
			numbers[i1] = nil

			--local r2 = table.Random(numbers)
			--numbers[r2] = nil
			local i2 = math.random(#numbers)
			local r2 = numbers[i2]
			numbers[i2] = nil

			local v1, v2 = shuffle[r1], shuffle[r2]

			shuffle[i1] = v2
			shuffle[i2] = v1
		end;
	end;

	--return table.Random(shuffle)
	return shuffle[math.random(#shuffle)]
end;

function nut.loot.registerTable(table, rarities, items)
	if (nut.loot.tables[table]) then return end;

	local processed = {items = {}, rarities = {}}

	if (rarities) then
		local total = 0

		for i, v in pairs(rarities) do
			total = total + v[2]
		end;

		if (total > 100) then -- Verify that the total chance is less or equal to 100 and correct it if it's not.
			for i, v in pairs(rarities) do
				rarities[i][2] = rarities[i][2] / total
			end;
		end;

		processed["rarities"] = rarities
	else -- Use default chances if none are provided.
		processed["rarities"] = nut.loot.rarityDefaults
	end;

	--[[if (#items < #rarities) then -- Make sure there is a item table for every rarity level.
		for i, v in pairs(rarities) do
			if (!items[i]) then
				rarities[i] = nil
			elseif (#items[i] == 0) then
				rarities[i] = nil
				items[i] = nil
			end;
		end;
	end;]]--

	if (!items) then -- We provide an empty item table is one wasn't given.
		for i, v in pairs(processed["rarities"]) do
			processed["items"][i] = {}
		end;
	else
		for i, v in ipairs(items) do -- We index all the items in the drop table for easy ref later.
			processed["items"][i] = v
		end;

		if (#processed["items"] != #processed["rarities"]) then -- Here we add any missing tables for items.
			for i, v in pairs(processed["rarities"]) do
				if (!processed["items"][i]) then
					processed["items"][i] = {}
				end;
			end;
		end;
	end;

	nut.loot.tables[table] = processed
end;

function nut.loot.addItem(table, rarity, item)
	if (nut.loot.tables[table]) then
		if (table != "master") then master = nut.loot.tables["master"] end; -- Every item is also added to the master table.

		table = nut.loot.tables[table]

		if (!isnumber(rarity)) then
			for key, value in pairs(table["rarities"]) do
				if (value[1] == rarity) then rarity = tonumber(key) end;
			end;
		end;

		if (table["rarities"][rarity]) then
			table["items"][rarity][#table["items"][rarity] + 1] = item
			if (master) then master["items"][rarity][#master["items"][rarity] + 1] = item end; -- Every item is also added to the master table.
		else
			return false, "invalid rarity"
		end;
	else
		return false, "invalid item table"
	end;
end;

function nut.loot.WeightedRandom(tbl)
    local seed = math.Rand(0, 100)

    for i = 1, #tbl do
        local v = tbl[i]

        seed = seed - v[2]

        if seed < 0 then
            return i
        end
    end
end

function nut.loot.pick(table, excludes)
	if (nut.loot.tables[table]) then
		local tbl = nut.loot.tables[table]

		local rarity = nut.loot.WeightedRandom(tbl.rarities)

		local item = tbl.items[rarity][math.random(1, #tbl.items[rarity])]

		return item, rarity
	else
		return false, "invalid item table"
	end;
end;

nut.loot.registerTable("master")
