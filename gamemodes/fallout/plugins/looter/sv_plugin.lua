local config = {resetTimer = 700, itemMin = 3, itemMax = 4, xp = 12}
local compareDistSqr = 400*400

local function CheckDistance(ply, ent)
	local dist = ent:GetPos():DistToSqr(ply:GetPos())

	if dist > compareDistSqr then 
		ply:falloutNotify("You are too far away!", "ui/ui_hacking_bad.mp3")
		return false, dist
	end

	return true
end

function nut.looter.generate(player, entity, itemCount, table)
	local inRange, dist = CheckDistance(player, entity)
	
	if !inRange then 
		jlib.AlertStaff(jlib.SteamIDName(player) .. " attempted to open a loot box from " .. (dist or 0) .. "m away, potentially using networking exploits.")
		return 
	end

	local items = {}
	local luck = player:getSpecial("L")

	local rolls = math.random(config.itemMin, config.itemMax)
	local bonusRolls = math.random(0, math.Round((2 / 25) * luck, 0))

	if bonusRolls > 0 then
		jlib.Announce(player, Color(255, 255, 0, 255), "[LUCK] ", Color(255, 255, 155, 255), "You scavenge " .. bonusRolls .. " more items from the rubble due to your luckful nature . . .")
		player:falloutNotify("You feel lucky . . .", "shelter/sfx/training_luck.ogg")
	end

	rolls = rolls + bonusRolls

	if (itemCount) then rolls = itemCount end;

	for i = 1, rolls do
		local roll = nut.loot.pick(table or "master")

		if (nut.item.list[roll]) then
			items[i] = roll
		else
			print("WARNING: Loot item " .. roll .. " does not exist and has not been created.")
		end;
	end;

	entity:setNetVar("items", items)

	nut.leveling.giveXP(player, config.xp, false, true)

	netstream.Start(player, "looterUI", entity)
end;

netstream.Hook("looterTake", function(player, item, entity)
	local items = entity:getNetVar("items", {})

	if !CheckDistance(player, entity) then return end

	if (table.HasValue(items, item)) then

		local character = player:getChar()
		local inv = character:getInv()

		local data
		local itemTbl = nut.item.list[item]
		if itemTbl.base == "base_firearm" then
			local rarity = wRarity.GetRarity(player)

			data = {}
			data.rarity = rarity.index
			data.name = rarity.name .. " " .. itemTbl.name
		end

		local x, y = inv:add(item, 1, data)
		entity:EmitSound("ui/ui_items_generic_up_0" .. math.random(1, 4) .. ".mp3")

		if !x then
			if y == "noSpace" then
				player:notify("No inventory space")
				return
			else
				player:notify("Error: " .. y)
				return
			end
		end

		local p = table.KeyFromValue(items, item)
		table.remove(items, p)

		entity:setNetVar("items", items)
	end;
end)

function PLUGIN:InitializedPlugins()
	timer.Create("looterContainerReset", config.resetTimer, 0, function()
		for i, v in pairs(ents.FindByClass("nut_loot_container_dynamic")) do
			v:setNetVar("items", nil)
		end;
	end)
end;

function PLUGIN:SaveData()
	local data = {}

	for i, v in pairs(ents.FindByClass("nut_loot_container_dynamic")) do
		data[#data + 1] = {pos = v:GetPos(), ang = v:GetAngles(), model = v:GetModel()}
	end;

	self:setData(data)
end;

function PLUGIN:LoadData()
	for i, v in pairs(ents.FindByClass("nut_loot_container_dynamic")) do
		v:Remove()
	end;

	for i, v in pairs(self:getData() or {}) do
		local ent = ents.Create("nut_loot_container_dynamic")
			ent:SetPos(v.pos)
			ent:SetAngles(v.ang)
			ent:Spawn()
			ent:SetModel(v.model)
			ent:SetSolid(SOLID_VPHYSICS)
			ent:PhysicsInit(SOLID_VPHYSICS)

			local physObj = ent:GetPhysicsObject()

			if (IsValid(physObj)) then
				physObj:Wake()
				physObj:EnableMotion(false)
			end;
	end;
end;
