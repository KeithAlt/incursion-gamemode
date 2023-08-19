ITEM.name = "Keycard"
ITEM.desc = "A security keycard containing encrypted passcodes."
ITEM.model = "models/maxib123/bluepasscard.mdl"
ITEM.category = "Security"

function ITEM:getDesc()
	if (self:getData("label")) then
		return "a security keycard containing encrypted passcodes.\nIt has been labeled: '"..self:getData("label").."'."
	else
		return "A security keycard containing encrypted passcodes."
	end;
end