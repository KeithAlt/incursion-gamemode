PLUGIN.name = "Armor 3.0"
PLUGIN.author = "Vex"
PLUGIN.desc = "With that all new modded taste!"

nut.armor = {}

nut.util.include("sh_meta.lua")
nut.util.include("sh_mods.lua")
nut.util.include("sh_armor.lua")
nut.util.include("sv_plugin.lua")

function PLUGIN:PluginLoaded()
	for i, v in pairs(nut.armor.armors) do
		local ITEM = nut.item.register("armor_"..i:lower(), "base_armor", nil, nil, true)
			ITEM.name 			 	= v["name"] .. " ◆"
			ITEM.model				= v["icon"] or "models/hunter/blocks/cube025x025x025.mdl"
			ITEM.playerModel	= v["model"] or nil
			ITEM.group 			 	= v["group"] or nil
			ITEM.bodygroups		= v["bodyGroups"] or nil
			ITEM.playerSkin   = v["skin"] or nil
			ITEM.isPA 			 	= v["powerArmor"]
			ITEM.type 			 	= i
			ITEM.noCore       = v.noCore
			ITEM.rarity				= v.rarity or 1
	end

	for i, v in pairs(nut.armor.mods) do
		local ITEM = nut.item.register("armormod_"..i:lower(), "base_armormod", nil, nil, true)
			ITEM.name 	= v["name"] .. " ◆"
			ITEM.model	= v["model"]
			ITEM.desc		= v["desc"] .. " | This item a will only work on Full Body Armor ◆"
			ITEM.rarity = v.rarity or 1
	end
end

if (CLIENT) then
		netstream.Hook("nutArmorModOpen", function(inv, armor)
			vgui.Create("nutArmorMod"):Open(inv)
		end)
		netstream.Hook("nutArmorMsg", function(installed, msg)
			if (nut.gui.armormod) then
				nut.gui.armormod:msg(installed, msg)
			end
		end)
end

nut.command.add("unequipall", {
	onRun = function(ply)
		local char = ply:getChar()
		if !char then return end
		local inv = char:getInv()

		--Forcefully unequip any weapons/armor
		for _, item in pairs(inv:getItems()) do
			if item.isSwep or item.isArmor then
				item:setData("equipped", false)

				if !IsValid(item.player) then
					item.player = ply
				end

				item.functions.UnEquip.onRun(item)
			end
		end

		if char:getData("oldMdl") then
			char:setModel(char:getData("oldMdl"))
			char:setData("oldMdl", nil)
		end
		char:setVar("armor", nil)
	end
})
