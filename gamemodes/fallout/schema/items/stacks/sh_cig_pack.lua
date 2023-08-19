ITEM.name = "Cigarette Pack"
ITEM.desc = "A pack of pre-war Big Boss cigarettes | Contains 6 cigarettes"
ITEM.model = "models/clutter/cigarettepack.mdl"
ITEM.stackSize = 6
ITEM.stackItem = "cig"

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
				client:EmitSound("ui/loot_take" .. math.random(1,3) .. ".wav", 50)

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
