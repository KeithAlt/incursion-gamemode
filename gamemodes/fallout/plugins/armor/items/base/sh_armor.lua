ITEM.name 				= "Armor Base"
ITEM.desc 				= "If you have this then you shouldn't."
ITEM.model 				= "models/hunter/blocks/cube025x025x025.mdl"
ITEM.width 				= 2
ITEM.height 			= 2
ITEM.type 				= "combatMK1"
ITEM.group 				= nil
ITEM.bodygroups 	= nil
ITEM.isPA 				= nil
ITEM.noCore 			= nil
ITEM.isArmor 			= true
ITEM.playerModel 	= nil
ITEM.rarity				= 1

function ITEM:getDesc()
	local armor = nut.armor.armors[self.type]
	local desc = armor["desc"].."\n\n"

	local fallProtection = "No\n"
	if (!armor["fallDamage"]) then fallProtection = "Yes\n" end

	desc = desc .. " - Armor Set ◆\n"
	desc = desc.." - Damage Resistance: "..armor["resistance"].."%\n"
	desc = desc.." - Speed Boost: "..armor["speedBoost"].."%\n"
	desc = desc.." - Jump Boost: "..armor["jumpBoost"].."%\n"
	desc = desc.." - Fall Protection: "..fallProtection

	if (armor["powerArmor"]) then
		desc = desc.."\n\nFusion Core: "..self:getData("power", 0).."%\n(Power Armor Skill Required)"
 	end

	if (table.Count(self:getData("mods", {})) > 0) then
		desc = desc.."\n\n[ MODULATORS ]"
		for i, v in pairs(self:getData("mods", {})) do
			desc = desc.."\n - "..((nut.armor.mods[v] and nut.armor.mods[v].ArmorDesc()) or "")
		end
	end

	return desc
end

function ITEM:PATick()
	local ply = self.player or self:getOwner()

	if !IsValid(ply) then
		if self.timerID then
			timer.Remove(self.timerID)
		end
		return
	end

	local power = self:getData("power", 0)
	power = math.max(power - 1, 0)

	self:setData("power", power)

	if power <= 0 and ply:IsSprintEnabled() then
		ply.ArmorWasSprintEnabled = ply.ArmorWasSprintEnabled == nil and ply:IsSprintEnabled() or ply.ArmorWasSprintEnabled
		ply:SprintDisable()
	end
end

function ITEM:paintOver(item, w, h)
	if (item:getData("equipped")) then
		surface.SetDrawColor(110, 255, 110, 100)
	else
		surface.SetDrawColor(255, 110, 110, 100)
	end

	surface.DrawRect(w - 16, h - 16, 12, 12)

	local rarity = item.rarity
	surface.SetDrawColor(wRarity.Config.Rarities[rarity].color)
	surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
end


ITEM:hook("drop", function(item)
	if (item:getData("equipped")) then
		item.player:notifyLocalized("You must remove the armor first.")
		return false
	end
end)

function ITEM:onCanBeTransfered(oldInventory, newInventory)
	if (newInventory and self:getData("equipped")) then
		return false
	end
end

ITEM.functions.core = {
	name = "Replace Core",
	onRun = function(item)
		local player = item.player
		local character = player:getChar()

		local core = character:getInv():hasItem("fusion_core")

		if (core) then
			core:remove()
			item:setData("power", 125)
			player:falloutNotify("☑ Fusion Core replaced", "shelter/sfx/energycollect_sequence.ogg")
			if player.ArmorWasSprintEnabled != nil then
				player:SetSprintEnabled(player.ArmorWasSprintEnabled)
				player.ArmorWasSprintEnabled = nil
			end
		end

		return false
	end,
	onCanRun = function(item)
		return !IsValid(item.entity) and item.isPA and !item.noCore
	end
}

ITEM.functions.UnEquip = {
	name = "Unequip",
	tip = "equipTip",
	icon = "icon16/cross.png",
	onRun = function(item)
		local player = item.player or item:getOwner()
		local character = player:getChar()

		player:EmitSound("ui/ui_items_generic_up_0" .. math.random(1,4) .. ".mp3")

		if item.isPA then
			player:SetBloodColor(BLOOD_COLOR_RED) -- Resets blood color
			player.isImmune = player:RadImmunity(true) -- Affirm rad immunity state
			player.fearResist = nut.class.list[player:getChar():getFaction()].fearResist or nut.config.get("fearRPdefaultFearResist")
			player.fearPower = nut.class.list[player:getChar():getFaction()].fearPower or nut.config.get("fearRPdefaultFearPower")
			Armor.ValidateHeavyWeapons(player) -- Unequips heavy weapons if no skill
		end

		if (item.group or item.playerModel) and (character:getData("oldMdl")) then
			character:setModel(character:getData("oldMdl"))
			character:setData("oldMdl", nil)
		end

		if (item.bodygroups) then
			local old = character:getData("oldGroups", {})

			character:setData("oldGroups", nil)
			character:setData("groups", old)

			local t = item.player:GetBodyGroups()

			for i = 0, #t do -- Reset all bodygroups first incase one isn't reset properly.
				item.player:SetBodygroup(i, 0)
			end

			for i, v in pairs(old) do
				item.player:SetBodygroup(i, v)
			end
		end

		if (item.playerSkin) then
			local oldSkin = character:getData("oldSkin")
			character:setData("oldSkin", nil)
			character:setData("skin", oldSkin)
			item.player:SetSkin(oldSkin)
		end

		if item.isPA and player.ArmorWasSprintEnabled != nil then
			player:SetSprintEnabled(player.ArmorWasSprintEnabled)
			player.ArmorWasSprintEnabled = nil
		end

		if (SERVER) then
			nut.armor.remove(player)
		end

		item:setData("equipped", false)

		return false
	end,
	onCanRun = function(item)
		return !IsValid(item.entity) and item:getData("equipped") == true
	end
}

ITEM.functions.Equip = {
	name = "Equip",
	tip = "equipTip",
	icon = "icon16/tick.png",
	onRun = function(item)
		local player = item.player
		local character = player:getChar()


		if (item.isPA and !character:getData("PATraining", false)) then
			player:falloutNotify("You don't have power armor training.")
			return false
		end

		if item.isPA and !item.noCore and item:getData("power", 0) <= 0 then
			player:falloutNotify("The fusion core in this armor is out of charge.")
			return false
		end

		local data = nut.armor.armors[item.type]

		if data["resistance"] > 75 and item.isPA then
			player:ClearChemEffects()
		end

		for _, v in pairs(character:getInv():getItems()) do
			local itemTable = nut.item.instances[v.id]
			if (itemTable and v.id != item.id) and (itemTable.isArmor and itemTable:getData("equipped")) then
				player:falloutNotify("You already have a set of armor equipped.")
				return false
			end
		end

		player:EmitSound("ui/ui_items_generic_up_0" .. math.random(1,4) .. ".mp3")

		if item.isPA then
			player:SetBloodColor(BLOOD_COLOR_MECH)
			player.isImmune = true -- Immune to radiation
			player.fearResist = 1.5 -- Increased fear resistance
			player.fearPower = 0.75 -- Increase fear power
			player:falloutNotify("You are now immune to radiation")
			player:falloutNotify("You now invoke & resist more fear")
		end

		if (item.group) then
			local t = string.Explode("/", item.player:GetModel())

			character:setData("oldMdl", item.player:GetModel())
			character:setModel(item.group..t[#t])
		elseif (item.playerModel) then
			character:setData("oldMdl", item.player:GetModel())
			character:setModel(item.playerModel)
		end

		if (item.bodygroups) then
			character:setData("oldGroups", character:getData("groups", {}))
			character:setData("groups", item.bodygroups)

			for i, v in pairs(item.bodygroups) do
				item.player:SetBodygroup(i, v)
			end
		end

		if (item.playerSkin) then
			character:setData("oldSkin", item.player:GetSkin())
			character:setData("skin", item.playerSkin)
			item.player:SetSkin(item.playerSkin)
		end

		item:setData("equipped", true)

		if item.isPA and !item.noCore then
			local timerID = player:SteamID64() .. "_PA"
			item.timerID = timerID
			timer.Create(timerID, 35, 0, function() item:PATick() end)
		end

		if (SERVER) then
			nut.armor.update(player, item.type)
		end

		return false
	end,
	onCanRun = function(item)
		local ply = item.player or item:getOwner()

		local hookResult = hook.Run("CanEquipArmor", item, ply)
		if hookResult != nil then return hookResult end

		if (ply.Accessories and table.Count(ply.Accessories) > 0) or ply.EquippedArmor then
			local str = "You cannot wear this while wearing other armor or accessories."

			if SERVER then
				ply:notify(str)
			else
				nut.util.notify(str)
			end

			return false
		end

		return (!ply.Accessories or table.Count(ply.Accessories) <= 0) and !ply.EquippedArmor and !ply:GetNW2Bool("EquippedArmor") and !IsValid(item.entity) and item:getData("equipped") != true and (item:getData("power", 0) > 0 or item.noCore)
	end
}

function ITEM:onLoadout()
	local ply = self.player
	if self:getData("equipped") and SERVER then
		nut.armor.update(ply, self.type)
	end

	if self.isPA and self:getData("equipped") then
		jlib.CallAfterTicks(10, function() -- NOTE/FIXME: Required to fix spaghet
			ply:SetBloodColor(BLOOD_COLOR_MECH)
			ply.isImmune = true -- Immune to radiation
			ply.fearResist = 1.5 -- Increased fear resistance
			ply.fearPower = 0.75 -- Increase fear power
			ply:falloutNotify("You are immune to radiation")
			ply:falloutNotify("You invoke & resist more fear")
		end)

		local timerID = ply:SteamID64() .. "_PA"

		if !self.noCore and !timer.Exists(timerID) then
			self.timerID = timerID
			timer.Create(timerID, 35, 0, function()
				if self and self:getData("equipped", false) then
					self:PATick()
				else
					timer.Remove(timerID)
				end
			end)
		end
	end
end
