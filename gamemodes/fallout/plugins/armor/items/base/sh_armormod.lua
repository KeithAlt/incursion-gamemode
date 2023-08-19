ITEM.name 				= "Armor Mod"
ITEM.desc 				= "If you have this then you shouldn't."
ITEM.model 				= "models/hunter/blocks/cube025x025x025.mdl"
ITEM.width 				= 1
ITEM.height 			= 1
ITEM.rarity				= 1

if (player) then
	function ITEM:paintOver(item, w, h)
		local rarity = item.rarity
		surface.SetDrawColor(wRarity.Config.Rarities[rarity].color)
		surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
	end
end
