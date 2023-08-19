util.AddNetworkString("wRaritySendBossSpawns")
util.AddNetworkString("wRarityTradeupMenu")
util.AddNetworkString("wRarityTradeup")

resource.AddSingleFile("sound/lootdropped.mp3")

function wRarity.TrialLooter(tbl, amtOfTrials) --Looter's accuracy was in question. This confirms the suspicion.
	local rarities = {}
	for i = 1, amtOfTrials do

		local _, rarity = nut.loot.pick(tbl)
		rarities[rarity] = (rarities[rarity] or 0) + 1
	end

	for rarityID, amt in pairs(rarities) do
		print("Total amount of " .. nut.loot.tables.master.rarities[rarityID][1] .." items: " .. amt .. ". Percentage: " .. (amt / amtOfTrials) * 100 .. "%")
	end
	print("----------------------------------")
end

--General weapon RNG
function wRarity.WeightedRandom(tbl, seed)
	seed = seed or math.Rand(0, 100)

	for i = 1, #tbl do
		local v = tbl[i]

		seed = seed - v.chance

		if seed < 0 then
			return v, i
		end
	end
end

function wRarity.GetRarity(ply) --Use a weighted random selection algorithm to return a rarity based on the rarities table
	wRarity.ConsoleLog("Starting rarity determination for " .. (IsValid(ply) and ply:Nick() or "unknown") .. ".")

	local luck = 0
	if IsValid(ply) then
		luck = ply:getSpecial("L")
	end
	wRarity.ConsoleLog("Current luck value: " .. luck)

	local seed = math.Rand(0, 100)
	local bonus = wRarity.Config.BonusPerLuck * luck
	local anyBonus = bonus > 0
	local rarities = wRarity.Config.Rarities
	local withoutLuckResult

	wRarity.ConsoleLog("Total luck bonus: " .. (bonus * 100) .. "%")

	-- Apply our luck bonus
	if anyBonus then
		_, withoutLuckResult = wRarity.WeightedRandom(rarities, seed)

		local totalBonus = 0
		rarities = table.Copy(wRarity.Config.Rarities)

		for i = 2, #rarities do
			local rBonus = rarities[i].chance * bonus
			rarities[i].chance = rarities[i].chance + rBonus
			totalBonus = totalBonus + rBonus
		end
		rarities[1].chance = rarities[1].chance - totalBonus
	end

	local result, rIndex = wRarity.WeightedRandom(rarities, seed)
	local name = string.lower(result.name)

	if anyBonus then
		local oldName = string.lower(rarities[withoutLuckResult].name)
		wRarity.ConsoleLog("Rarity without bonus: " .. oldName)
		if rIndex > withoutLuckResult then
			ply:ChatPrint("Thanks to your lucky nature your weapon's rarity has been upgraded from " .. oldName .. " to " .. name)
		end
	end

	wRarity.ConsoleLog("Rarity chosen: " .. name)

	return result, rIndex, withoutLuckResult
end

function wRarity.TrialRarities(amtOfTrials) --Do a trail run of x amount of choices
	local choices = {}
	for i = 1, amtOfTrials do
		local choice = wRarity.GetRarity()
		choices[choice.index] = (choices[choice.index] or 0) + 1
	end

	for k, amt in pairs(choices) do
		local choice = wRarity.Config.Rarities[k]
		print("Total " .. choice.name .. " items chosen: " .. amt)
		print((amt / amtOfTrials) * 100 .. "%")
	end
	print("----------------------------------")
end

--Ent/Item creation
function wRarity.SetRarity(item, rarity)
	item:setData("rarity", rarity.index)
	item:setData("name", rarity.name .. " " .. item.name)
end

function wRarity.CreateItem(inv, uniqueID, rarity) --Create a given item in a given inventory with a given rarity
	return inv:add(uniqueID, 1, {rarity = rarity.index, name = rarity.name .. " " .. (nut.item.list[uniqueID].name or "nil")})
end

function wRarity.CreateItemDrop(uniqueID, rarity, pos)
	if nut.item.list[uniqueID] == nil then return end

	local drop = ents.Create("wrarity_deathdrop")
	drop:SetPos(pos)
	drop:SetIsWep(nut.item.list[uniqueID].base == "base_firearm")
	drop:SetItem(uniqueID)
	drop:SetRarity(rarity)
	drop:Spawn()

	return drop
end

--NPC kill loot drops
function wRarity.GetDroppedItem()
	return nut.loot.pick("master")
end

function wRarity.CreateRandomDrop(pos, ply)
	local weapon, looterRarity = wRarity.GetDroppedItem()

	if nut.item.list[weapon].base == "base_firearm" then
		local rarity = wRarity.GetRarity(ply)

		wRarity.CreateItemDrop(weapon, rarity.index, pos + Vector(0, 0, 10))
	else
		wRarity.CreateItemDrop(weapon, looterRarity, pos + Vector(0, 0, 10))
	end
end

hook.Add("OnNPCKilled", "LootDrops", function(npc, attacker, inflictor)
	if IsValid(npc) and IsValid(attacker) then
		if npc.DropsEnabled then
			local seed = math.Rand(0, 100)

			if seed < wRarity.Config.NPCKillDropChance then
				wRarity.ConsoleLog("NPC loot dropped for " .. attacker:Nick())

				wRarity.CreateRandomDrop(npc:GetPos(), attacker)
			end
		elseif npc.wRarityBoss then
			wRarity.ConsoleLog("Boss killed by " .. attacker:Nick())

			for i = 1, npc.drops do
				local choice = wRarity.WeightedRandom(wRarity.Config.BossDrops)

				local item = choice.items[math.random(1, #choice.items)]
				wRarity.CreateItemDrop(item, wRarity.GetRarity(attacker).index, npc:GetPos() + Vector(0, 45 * i, 20))
			end
		end
	end
end)

--Scale damage based on weapon rarity
hook.Add("EntityTakeDamage", "wRarityDamageBuffs", function(target, dmg)
	local attacker = dmg:GetAttacker()

	if IsValid(attacker) and attacker:IsPlayer() and attacker:getChar() then
		local weapon = attacker:GetActiveWeapon()
		local rarity = weapon:GetNWInt("rarity", 1)

		dmg:ScaleDamage(1 + (wRarity.Config.Rarities[rarity].buff / 100))
	end
end)

--Boss spawning
wRarity.BossSpawns = wRarity.BossSpawns or {}

function wRarity.SpawnBoss(class, pos, drops)
	local boss = ents.Create(class)
	boss:SetPos(pos)
	boss:DropToFloor()
	boss:Spawn()
	boss:Activate()

	boss.wRarityBoss = true
	boss.drops = drops

	local bossName = scripted_ents.Get(class).PrintName
	if bossName then
		bossName = bossName:lower()
	else
		bossName = "boss"
	end
	//DiscordEmbed("A " .. bossName .. " has spawned in the wasteland!", "☠️ BOSS SPAWN ☠️", Color(255, 125, 0, 255), "IncursionChat")
end

//wRarity.SpawnBoss("npc_vj_fallout_coyote", Entity(1):GetPos(), 1)

function wRarity.StartBossTimer(bossSpawn, id)
	timer.Create("BossSpawnTimer" .. id, math.random(3600, 21600), 1, function()
		for k, ply in ipairs(player.GetAll()) do
			ply:notify("A boss has spawned in the wasteland!")
		end

		wRarity.SpawnBoss(bossSpawn.npc, bossSpawn.pos + Vector(0, 0, 10), bossSpawn.drops)
	end)
end

function wRarity.AddBossSpawn(dat)
	local id = #wRarity.BossSpawns + 1
	wRarity.BossSpawns[id] = dat

	wRarity.StartBossTimer(dat, id)

	wRarity.SaveBossSpawns()
end

function wRarity.FindNearestBossSpawn(pos)
	local nearestSpawn
	local nearestDist
	local nearestSpawnID

	for k, bossSpawn in ipairs(wRarity.BossSpawns) do
		local dist = pos:Distance(bossSpawn.pos)

		if !nearestDist or dist < nearestDist then
			nearestSpawn   = bossSpawn
			nearestDist    = dist
			nearestSpawnID = k
		end
	end

	return nearestSpawn, nearestDist, nearestSpawnID
end

function wRarity.RemoveBossSpawn(index)
	table.remove(wRarity.BossSpawns, index)

	wRarity.SaveBossSpawns()
end

function wRarity.SaveBossSpawns()
	file.Write("wraritybossspawns.txt", util.TableToJSON(wRarity.BossSpawns))

	wRarity.BroadcastBossSpawns()
end

function wRarity.LoadBossSpawns()
	local json = file.Read("wraritybossspawns.txt")

	if json then
		wRarity.BossSpawns = util.JSONToTable(json)
	end
end

function wRarity.StartBossTimers()
	for k, bossSpawn in ipairs(wRarity.BossSpawns) do
		wRarity.StartBossTimer(bossSpawn, k)
	end
end

function wRarity.BroadcastBossSpawns()
	net.Start("wRaritySendBossSpawns")
		net.WriteTable(wRarity.BossSpawns)
	net.Broadcast()
end

hook.Add("InitPostEntity", "wRarityBossSpawnInit", function()
	wRarity.LoadBossSpawns()
	wRarity.StartBossTimers()
end)

hook.Add("PlayerInitialSpawn", "wRaritySendBossSpawns", function(ply)
	net.Start("wRaritySendBossSpawns")
		net.WriteTable(wRarity.BossSpawns)
	net.Send(ply)
end)

--Trade ups
net.Receive("wRarityTradeup", function(len, ply)
	local items = net.ReadTable()
	local rarity = net.ReadInt(32)

	if rarity >= wRarity.Config.MaxTradeupRarity or rarity < 1 then
		ply:notify("Invalid rarity!")
		return
	end

	if #items < wRarity.Config.TradeupAmt then
		ply:notify("Not enough items! You need " .. wRarity.Config.TradeupAmt .. ".")
		return
	end

	local char = ply:getChar()
	if !char then return end

	local itemsToTake = {}
	for i, itemSearch in ipairs(items) do
		for _, item in pairs(char:getInv():getItems()) do
			if item.base == "base_firearm" and item.uniqueID == itemSearch and item:getData("rarity", 1) == rarity and !table.HasValue(itemsToTake, item) then
				table.insert(itemsToTake, item)
				break
			end
		end
	end

	if #itemsToTake < wRarity.Config.TradeupAmt then
		ply:notify("Could not find enough items! You need " .. wRarity.Config.TradeupAmt .. ".")
		return
	end

	for i, item in ipairs(itemsToTake) do
		item:remove()
	end

	local itemToGive = items[math.random(1, #items)]
	local rarityToGive = wRarity.Config.Rarities[rarity + 1]
	wRarity.CreateItem(ply:getChar():getInv(), itemToGive, rarityToGive)

	ply:notify("Success! You have traded up for a " .. rarityToGive.name .. " " .. nut.item.list[itemToGive].name .. "!")
end)
