/**
NOTE:
	Player.FeatherFall is a variable that can be used to give a player fall damage immunity
**/


nut.armor.config = {
	defaultFactions = {FACTION_BROTHEROFFICER, FACTION_ENCLAVEOFFICER, FACTION_NCROFFICER, FACTION_CENTURION, FACTION_ATOMCATSA},
}

function nut.armor.PATick(item)

end

netstream.Hook("nutInstallArmorMod", function(player, mod)
	local character = player:getChar()
	local inv = character:getInv()

	if (inv:hasItem("armormod_"..mod)) then
		nut.armor.InstallMod(player, character:getArmorJ(), mod)
	else
		netstream.Start(player, "nutArmorMsg", false, "You need that mod in your inventory!")
	end
end)

function nut.armor.InstallMod(player, armor, mod)
	if armor and nut.armor.mods[mod] then
		local character = player:getChar()
		local inv = character:getInv()

		local mods = armor:getData("mods", {})

		-- Prevents installation of two of the same mods (or prevents overwriting, which currently has no benefit)
		if(mods[nut.armor.mods[mod].slot]) then
			netstream.Start(player, "nutArmorMsg", false, "You already have a mod of that type!")
			return false
		end

		inv:hasItem("armormod_"..mod):remove()

		mods[nut.armor.mods[mod].slot] = mod

		armor:setData("mods", mods)

		if(!armor.isjArmor) then -- Legacy system
			nut.armor.update(player, armor.type)
		else -- Separate method for j armors to prevent issues
			for i, v in pairs(armor:getData("mods", {})) do
				if (nut.armor.mods[v]) then
					nut.armor.mods[v].OnRemove(player, armor)
					nut.armor.mods[v].OnEquip(player, armor)
				end
			end
		end

		netstream.Start(player, "nutArmorMsg", true, "Mod Installed!")
	end
end

function nut.armor.RemoveMod(player, armor, mod)
	if armor and nut.armor.mods[mod] then
		local mods = armor:getData("mods", {})

		if (mods[nut.armor.mods[mod].slot]) then
			mods[nut.armor.mods[mod].slot] = nil
		end

		armor:setData("mods", mods)

		if(!armor.isjArmor) then -- Legacy system
			nut.armor.update(player, armor.type)
		else -- Separate method for j armors to prevent issues
			for i, v in pairs(armor:getData("mods", {})) do
				if (nut.armor.mods[v]) then
					nut.armor.mods[v].OnRemove(player, armor)
				end
			end
		end
	end
end

function nut.armor.remove(player)
	local character = player:getChar()
	local item = character:getArmor()

	if (!item) then
		return false
	end

	if timer.Exists(player:SteamID64() .. "_PA") then
		timer.Remove(player:SteamID64() .. "_PA")
	end

	local armors = nut.armor.armors
	local armor = item.type

	if (!armors[armor]) then
		return false
	end

	if item.isPA and !item.noCore and item:getData("power", 0) == 0 then
		player:SetRunSpeed(nut.config.get("runSpeed"))
	else
		nut.handlers.modifyRun(player, 0 - (nut.config.get("runSpeed") * (armors[armor]["speedBoost"] / 100)))
	end
	nut.handlers.modifyWalk(player, 0 - (nut.config.get("walkSpeed") * (armors[armor]["speedBoost"] / 100)))
	nut.handlers.modifyJump(player, 0 - (160 * (armors[armor]["jumpBoost"] / 100)))

	for i, v in pairs(item:getData("mods", {})) do
		if (nut.armor.mods[v]) then
			nut.armor.mods[v].OnRemove(player, item)
		end
	end

	player:setNetVar("powerArmor", nil)
	character:setVar("armor", nil)
end

function nut.armor.update(player, armor)
	local character = player:getChar()
	local item = character:getArmor()

	//if (item) then
	//	nut.armor.remove(player)
	//end

	local armors = nut.armor.armors

	if (!armors[armor]) then
		return false
	end

	nut.handlers.modifyWalk(player, nut.config.get("walkSpeed") * (armors[armor]["speedBoost"] / 100))
	nut.handlers.modifyRun(player, nut.config.get("runSpeed") * (armors[armor]["speedBoost"] / 100))
	nut.handlers.modifyJump(player, 160 * (armors[armor]["jumpBoost"] / 100))

	if item.isPA and !item.noCore and item:getData("power", 0) == 0 then
		player:SetRunSpeed(player:GetWalkSpeed())
	end

	for i, v in pairs(item:getData("mods", {})) do
		if (nut.armor.mods[v]) then
			nut.armor.mods[v].OnRemove(player, item)
			nut.armor.mods[v].OnEquip(player, item)
		end
	end

	if (armors[armor].powerArmor) then
		player:setNetVar("powerArmor", true)
	end

	character:setVar("armor", armor)
end

function PLUGIN:PlayerLoadedChar(player, character)
	nut.armor.update(player)
end

function SCHEMA:PlayerFootstep(player, position, foot, soundName, volume)
	if (player:isRunning()) then
		local armor = player:getChar():getVar("armor", nil)
		if armor and nut.armor.armors[armor]["footstep"] then
			player:EmitSound(nut.armor.armors[armor]["footstep"](), volume * 130)
			return true
		end
	end
end

function PLUGIN:GetFallDamage(entity, dmg)
	local armor = entity:getChar():getVar("armor", nil)

	if armor and !nut.armor.armors[armor]["fallDamage"] or entity.FeatherFall then
		return 0
	end
end

function PLUGIN:EntityTakeDamage(entity, dmg)
	if !entity:IsPlayer() or !entity:getChar() then return end
	local armor = entity:getChar():getVar("armor", nil)

	if (armor) then
		dmg:ScaleDamage(1 - (nut.armor.armors[armor]["resistance"] / 100))
	end
end
