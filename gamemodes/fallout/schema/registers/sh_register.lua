function SCHEMA:registerItem(id, data, base)
	local ITEM = nut.item.register(base.."_"..id, "base_junk", nil, nil, true)
		ITEM.name		= data["name"]
		ITEM.desc 		= data["desc"]
		ITEM.category	= data["base"]
		ITEM.model 		= data["model"] or "models/fallout/components/box.mdl"
		ITEM.skin		= data["skin"] or 0
end;

function SCHEMA:registerAmmo(id, data)
	local ITEM = nut.item.register("ammo_"..id, "base_clip", nil, nil, true)
		ITEM.name		= data["name"]
		ITEM.desc 		= data["desc"]
		ITEM.ammo		= data["type"]
		ITEM.model 		= data["model"] or "models/fallout/components/box.mdl"
		ITEM.rounds		= data["rounds"]
end;

function SCHEMA:registerMelee(id, data, category)
	local ITEM = nut.item.register(id, "base_firearm", nil, nil, true)
	ITEM.name		= data["name"]
	ITEM.desc 		= data["desc"]
	ITEM.model 		= data["model"]
	ITEM.swep		= data["class"]
	ITEM.brand		= data["brand"]
	ITEM.PA			= data["powerArmor"] or nil
	ITEM.category	= "Weapons"
	ITEM.slot 		= category
	ITEM.width		= 2
	ITEM.height		= 2

	if (data["powerArmor"]) then
		ITEM.desc = ITEM.desc.."\n\n☢ Requires Power Armor ☢"
	end

	if knockoutConfig.weps[data.class] then
		ITEM.desc = ITEM.desc .. "\n- Can knockout"
	end
end

function SCHEMA:registerWeapon(id, data, category)
	local template = nut.fallout.templates[category][data["type"]]

	local ITEM = nut.item.register(id, "base_firearm", nil, nil, true)
	ITEM.name		= data["name"]
	ITEM.desc 		= data["desc"]
	ITEM.model 		= data["model"]
	ITEM.swep		= data["class"]
	ITEM.brand		= data["brand"]
	ITEM.PA			= data["powerArmor"] or nil
	ITEM.category	= "Weapons"
	ITEM.slot 		= category
	ITEM.width		= 2
	ITEM.height		= 2

	if data["powerArmor"] then
		ITEM.desc = ITEM.desc.."\n\n☢ Requires Power Armor ☢"
	end

	if (template) then
		local ITEM2 = nut.item.register("bp_"..id, "base_blueprint", nil, nil, true)
			ITEM2.name		= data["name"].." Blueprint"
			ITEM2.desc 		= "A blueprint for a "..data["name"].." "
			ITEM2.category	= "Information - Blueprints"
			ITEM2.model 	= "models/props_lab/clipboard.mdl"
			ITEM2.blueprint = id

		local ITEM3 = nut.item.register("frame_"..id, "base_junk", nil, nil, true)
			ITEM3.name		= data["name"].." Frame"
			ITEM3.desc 		= "A frame for a "..data["name"].." "
			ITEM3.category	= "Components - Frame"
			ITEM3.model 	= "models/fallout/components/box.mdl"


		if (SERVER) then
			local t = table.Copy(template)
			t["frame_"..id] = 1

			local recipe = {
				 ["name"]		  = data["name"],
				 ["model"] 		  = data["model"],
				 ["materials"] 	  = t,
				 ["results"] 	  = {[id] = 1},
				 ["blueprint"] 	  = id,
				 ["xp"] 		  = data["xp"] or 0,
				 ["intelligence"] = data["intelligence"] or 0,
				 ["skill"]        = data["skill"] or "weapcrafting",
			}

			if category == "laser" then
				recipe.skill = "lasercrafting"
			elseif category == "plasma" then
				recipe.skill = "plasmacrafting"
			end

			nut.crafting.addRecipe("weapons", id, recipe)
		end;
	end;
end;

function SCHEMA:registerEquipment(id, data)
	local ITEM = nut.item.register(id, "base_weapons", false, nil, true)

	ITEM.name = data.name
	ITEM.class = data.class
	ITEM.model = data.model
	ITEM.desc = data.desc
	ITEM.width = data.width or 1
	ITEM.height = data.height or 1

	ITEM.functions.Equip = {
		name = "Equip",
		tip = "equipTip",
		icon = "icon16/tick.png",
		onRun = function(item)
			local client = item.player

			client.carryWeapons = client.carryWeapons or {}

			if (client:HasWeapon(item.class)) then
				client:StripWeapon(item.class)
			end

			local weapon = client:Give(item.class)

			if (IsValid(weapon)) then
				client.carryWeapons[item.weaponCategory] = weapon
				client:SelectWeapon(weapon:GetClass())
				client:SetActiveWeapon(weapon)
				client:EmitSound("items/ammo_pickup.wav", 80)

				-- Remove default given ammo.
				if (client:GetAmmoCount(weapon:GetPrimaryAmmoType()) == weapon:Clip1() and item:getData("ammo", 0) == 0) then
					client:RemoveAmmo(weapon:Clip1(), weapon:GetPrimaryAmmoType())
				end
				item:setData("equip", true)

				weapon:SetClip1(item:getData("ammo", 0))

				if (item.onEquipWeapon) then
					item:onEquipWeapon(client, weapon)
				end
			else
				print(Format("[Nutscript] Weapon %s does not exist!", item.class))
			end

			return false
		end,
		onCanRun = function(item)
			if (IsValid(item.entity) or item:getData("equip", nil) or item.player:GetNWBool("StealthCamo") == true) then return false end;
		end
	}
end

function SCHEMA:InitializedPlugins()
	for i, v in pairs(nut.fallout.registry) do
		if (i == "primary" or i == "secondary" or i == "plasma" or i == "laser") then
			for x, y in pairs(v) do
				SCHEMA:registerWeapon(x, y, i)
			end;
		elseif (i == "melee") then
			for x, y in pairs(v) do
				SCHEMA:registerMelee(x, y, i)
			end;
		elseif (i == "ammo") then
			for x, y in pairs(v) do
				SCHEMA:registerAmmo(x, y)
			end;
		elseif (i == "equipment") then
			for x, y in pairs(v) do
				SCHEMA:registerEquipment(x, y)
			end
		else
			for x, y in pairs(v) do
				SCHEMA:registerItem(x, y, i)
			end;
		end;
	end;

	hook.Run("PostRegistry")
end
