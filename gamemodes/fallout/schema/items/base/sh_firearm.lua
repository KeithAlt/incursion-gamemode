ITEM.name = "Firearm Base"
ITEM.desc = "If you have this then you shouldn't."
ITEM.model = "models/hunter/blocks/cube025x025x025.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.swep = "weapon_pistol"
ITEM.slot = "primary"
ITEM.PA = nil
ITEM.isSwep = true

local brandCost = 12000
local brandStr = string.Comma(brandCost)

if (CLIENT) then
	function ITEM:paintOver(item, w, h)
		if (item:getData("equipped", nil)) then
			surface.SetDrawColor(110, 255, 110, 100)
		else
			surface.SetDrawColor(255, 110, 110, 100)
		end;

		surface.DrawRect(w - 16, h - 16, 12, 12)

		local rarity = item:getData("rarity", 1)
		surface.SetDrawColor(wRarity.Config.Rarities[rarity].color)
		surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
		--nut.util.drawText(math.Round((item:getData("health", 5000) / 50)).."%", 4, h - 3, color, 0, 4, "nutSmallFont")
	end;
end;

function ITEM:getName()
	return self:getData("name", wRarity.Config.Rarities[self:getData("rarity", 1)].name .. " " .. self.name)
end

function ITEM:getDesc()
	local brand = self:getData("brand") or self.brand

	local desc = self.desc ..
	"\n\n‣ Serial Number: " .. self:getID() ..
	((brand and "\n‣ Brand: The " .. brand) or "") ..
	((Dismemberment and Dismemberment.getHitgroupDesc(self.swep)) or "")

	return desc
end

ITEM:hook("drop", function(item)
	if (item:getData("equipped", nil)) then
		item.player:notifyLocalized("You must unequip the weapon first.")
		return false
	end;
end)

function ITEM:onCanBeTransfered(oldInventory, newInventory)
	if (self:getData("equipped")) then
		return false
	end;
end;

ITEM.functions.zRename = {
	name = "Rename",
	tip = "renameTip",
	icon = "icon16/page_white_edit.png",
	onRun = function(item)
		if item:getData("rarity", 1) != #wRarity.Config.Rarities then
			return false
		end

		local ply = item.player

		ply:requestString("Rename", "New Name", function(text)
			if #text <= 40 then
				item:setData("name", text)
			else
				ply:notify("The weapon's name must be at most 40 characters long.")
			end
		end, item:getName())

		return false
	end,
	onCanRun = function(item)
		return !IsValid(item.entity) and item:getData("rarity", 1) == #wRarity.Config.Rarities
	end
}

if SERVER then
	local function Brand(item)
		local ply = item.player or item:getOwner()

		if ply:getChar():getMoney() < brandCost then
			ply:falloutNotify("☒  You cannot afford Ⓒ " .. brandStr .. " to brand", "shelter/sfx/emergency_fail.ogg")
			return false
		end

		ply_faction = team.GetName(ply:Team())
		item:setData("brand", ply_faction)

		ply:getChar():takeMoney(brandCost)
		ply:notify("Ⓒ " .. brandStr .. " has covered the branding costs")
		ply:falloutNotify("☑  Successfully branded the weapon to your faction", "shelter/sfx/energycollect_sequence.ogg")
		DiscordEmbed(ply:Nick() .. " ( " .. ply:SteamID() .. " ) " .. "has branded a " .. item.name .. " with a SN of: " .. item:getID() .. " to the " .. team.GetName(ply:Team()) "🔥 Weapon Brand Log 🔥", Color(255, 0, 0), "Admin")
		return false
	end


	local function Deconstruct(item)
		local ply = item.player or item:getOwner()

		local recipe = nut.crafting.recipes["weapons"][item.uniqueID]

		if !istable(recipe) then
			ply:notify("This item doesn't have a crafting recipe!") --Would be nice to check this in onCanRun but the recipies don't exist on the client
			return false
		end

		item:remove()

		for part, amt in pairs(recipe.materials) do
			ply:getChar():getInv():add(part, math.Round(amt * (wRarity.Config.DeconstructValue / 100)))
		end

		ply:notify("Successfully deconstructed " .. item:getName())

		return false
	end

	util.AddNetworkString("AskDeconstruct") -- Destruction confirmation network string
	util.AddNetworkString("ConfirmDeconstruct")

	util.AddNetworkString("AskBrand") -- Branding confirmation network string
	util.AddNetworkString("ConfirmBrand")

	net.Receive("ConfirmDeconstruct", function(len, ply)
		local itemID = net.ReadInt(32)
		local item = nut.item.instances[itemID]
		if item:getOwner() == ply then
			Deconstruct(item)
		end
	end)

	net.Receive("ConfirmBrand", function(len, ply)
		local itemID = net.ReadInt(32)
		local item = nut.item.instances[itemID]
		if item:getOwner() == ply then
			Brand(item)
		end
	end)
end

if CLIENT then
	net.Receive("AskDeconstruct", function(len, ply)
		local itemID = net.ReadInt(32)
		Derma_Query("Are you sure you want to deconstruct this " .. nut.item.instances[itemID]:getName(), "Confirmation", "Yes", function()
			net.Start("ConfirmDeconstruct")
				net.WriteInt(itemID, 32)
			net.SendToServer()
		end, "No")
	end)

	net.Receive("AskBrand", function(len, ply)
		local itemID = net.ReadInt(32)
		Derma_Query("Branding permanently locks a weapon to a faction. Are you sure?", "Confirmation", "Yes (Ⓒ " .. brandStr .. ")", function()
			net.Start("ConfirmBrand")
				net.WriteInt(itemID, 32)
			net.SendToServer()
		end, "No")
	end)
end

ITEM.functions.zDeconstruct = {
	name = "Deconstruct",
	tip = "deconstructTip",
	icon = "icon16/bomb.png",
	onRun = function(item)
		net.Start("AskDeconstruct")
			net.WriteInt(item:getID(), 32)
		net.Send(item.player)

		return false
	end,
	onCanRun = function(item)
		return !IsValid(item.entity)
	end
}

ITEM.functions.zBrand = {
	name = "Brand to faction",
	tip = "brandTip",
	icon = "icon16/lock.png",
	onRun = function(item)
		if item:getData("brand") or nut.faction.indices[item.player:Team()].cannotBrand then
			item.player:falloutNotify("☒  You must be in a true faction to brand a weapon", "ui/notify.mp3")
			return false
		end

		net.Start("AskBrand")
			net.WriteInt(item:getID(), 32)
		net.Send(item.player)
		return false
	end,
	onCanRun = function(item)
		return !IsValid(item.entity) and !item:getData("brand")
	end
}

ITEM.functions.UnEquip = {
	name = "Unequip",
	tip = "equipTip",
	icon = "icon16/cross.png",
	onRun = function(item)
		local client = item.player

		local weapon = client:GetWeapon(item.swep)

		client:EmitSound("items/ammo_pickup.wav", 80)

		if IsValid(weapon) then
			item:setData("ammo", weapon:Clip1())
		end

		client:StripWeapon(item.swep)

		item:setData("equipped", nil)

		return false
	end,
	onCanRun = function(item)
		return (!IsValid(item.entity) and item:getData("equipped") == true)
	end;
}

ITEM.functions.Equip = {
	name = "Equip",
	tip = "equipTip",
	icon = "icon16/tick.png",
	onRun = function(item)
		local client = item.player
		local character = client:getChar()
		local inv = character:getInv()

		if (item.PA and !client:hasSkerk("heavyweapons")) then
			local armor = character:getVar("armor", nil)
			if (!armor or !nut.armor.armors[armor]["powerArmor"]) and !client:GetNW2Bool("WearingPA") then
				client:notifyLocalized("You need to be wearing Power Armor to equip this.")
				return false
			end
		end

		client.carryWeapons = client.carryWeapons or {}

		for i, v in pairs(inv:getItems()) do
			local itemTable = nut.item.instances[v.id]
			if (v.id != item.id) and istable(itemTable) then
				if (itemTable.isSwep and itemTable.slot == item.slot and itemTable:getData("equipped", nil)) then
					client:notifyLocalized("You already have a "..item.slot.." weapon equipped.")
					return false
				end
			end
		end

		//if (client:HasWeapon(item.swep)) then
		//	local wep = client:GetWeapon(item.swep)
		//	wep:SetNWInt("rarity", item:getData("rarity", 1))
		//end;

		local weapon
		if IsValid(client:GetWeapon(item.swep)) then
			weapon = client:GetWeapon(item.swep)
		else
			weapon = client:Give(item.swep)
		end

		if (IsValid(weapon)) then
			client:EmitSound("items/ammo_pickup.wav", 80)

			client.carryWeapons[item.slot] = weapon

			client:RemoveAmmo(weapon:Clip1(), weapon:GetPrimaryAmmoType())

			weapon:SetClip1(item:getData("ammo", 0))

			item:setData("equipped", true)

			weapon:SetNWInt("rarity", item:getData("rarity", 1))
		else
			client:notifyLocalized("This SWEP does not exist, please notify a member of staff.")
		end;

		return false
	end,
	onCanRun = function(item)
		return !IsValid(item.entity) and !item:getData("equipped", nil)
	end
}

function ITEM:onLoadout()
	if (self:getData("equipped")) then
		local client = self.player
		client.carryWeapons = client.carryWeapons or {}

		jlib.CallAfterTicks(9, function()
			if !self or !IsValid(client) then return end

			if self.PA and !client:WearingPA() and !client:hasSkerk("heavyweapons") then
				client:notifyLocalized("You need to be wearing power armor to equip this.")
				self:setData("equipped", false)
				client:StripWeapon(self.swep)
			end
		end)

		local weapon
		if IsValid(client:GetWeapon(self.swep)) then
			weapon = client:GetWeapon(self.swep)
		else
			weapon = client:Give(self.swep)
		end

		if (IsValid(weapon)) then
			client.carryWeapons[self.slot] = weapon

			client:RemoveAmmo(weapon:Clip1(), weapon:GetPrimaryAmmoType())

			weapon:SetClip1(self:getData("ammo", 0))

			weapon:SetNWInt("rarity", self:getData("rarity", 1))
		else
			client:notifyLocalized("This SWEP does not exist, please notify a member of staff.")
		end
	end
end
