ITEM.name = "Stacked Item"
ITEM.desc = "A base for stacked shit."
ITEM.model = "models/props_junk/popcan01a.mdl"
ITEM.stackSize = 6
ITEM.stackItem = "book"

ITEM.functions.remove = {
	name = "Open",
	tip = "Take an item from the stack.",
	icon = "icon16/pencil.png",
	onRun = function(item)
		if (item.player) then
			local client = item.player
			local character = client:getChar()
			local inv = character:getInv()
			local stack = item:getData("stack", item.stackSize)

			local itm, error = inv:add(item.stackItem, 1)

			if (itm) then
				if (stack <= 1) then
					return true
				end

				item:setData("stack", stack - 1)

				return false
			else
				client:ChatPrint("Could not create item: "..error)
				return false
			end
		else
			return false
		end
	end,
}
