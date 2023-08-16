ITEM.name = "Pip-Boy 3000"
ITEM.model = "models/llama/pipboy3000.mdl"
ITEM.desc = "A Pip-Boy 3000 that grants the wearer the ability to use VATS."

ITEM.functions.Equip = {
    name = "Equip",
    tip = "equipTip",
    icon = "icon16/tick.png",
    onRun = function(item)
        local client = item.player
        item:setData("equip", true)
        return false
    end,
    onCanRun = function(item)
        if (IsValid(item.entity) or item:getData("equip", nil)) then return false end
    end
}

ITEM.functions.EquipUn = {
	name = "Unequip",
	tip = "equipTip",
	icon = "icon16/cross.png",
	onRun = function(item)
        item:setData("equip", nil)
		
		return false
	end,
	onCanRun = function(item)
		return (!IsValid(item.entity) and item:getData("equip") == true)
	end
}

ITEM:hook("drop", function(item)
	if (item:getData("equip")) then
		item:setData("equip", nil)
	end
end)

function ITEM:onCanBeTransfered(oldInventory, newInventory)
	if (newInventory and self:getData("equip")) then
		return false
	end

	return true
end

if (CLIENT) then
	function ITEM:paintOver(item, w, h)
		if (item:getData("equip")) then
			surface.SetDrawColor(110, 255, 110, 100)
			surface.DrawRect(w - 14, h - 14, 8, 8)
		end
	end
end
