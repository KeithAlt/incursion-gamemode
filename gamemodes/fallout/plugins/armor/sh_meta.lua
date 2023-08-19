local CHAR = nut.meta.character or {}

function CHAR:getArmor()
	local items = self:getInv():getItems()

	for _, v in pairs(items) do
		if (v:getData("equipped") and v.isArmor) then
			return v
		end
	end

	return nil
end

-- This one can return legacy armors and (moddalbe) j armors, created specifically for the modulator table to avoid legacy conflicts
function CHAR:getArmorJ()
	local items = self:getInv():getItems()

	for _, v in pairs(items) do
		if (v:getData("equipped") and (v.isArmor or v.isModdable)) then
			return v
		end
	end

	return nil
end
