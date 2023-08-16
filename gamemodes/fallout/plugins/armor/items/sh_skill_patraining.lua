ITEM.name = "Power Armor for Dummies"
ITEM.desc = "A yellow and black painted book titled 'Power armor for Dummies'."
ITEM.model = "models/clutter/book.mdl"
ITEM.blueprint = nil

ITEM.functions.use = {
	name = "Use",
	tip = "useTip",
	icon = "icon16/add.png",
	onRun = function(item)
		local character = item.player:getChar()
		
		local training = character:getData("PATraining", false)
		
		if (!training) then
			character:setData("PATraining", true)
			item.player:falloutNotify("You have learned how to operate Power Armor", "fallout/item/generic_pickup.wav")
		else
			item.player:falloutNotify("You already know how to use Power Armor")
			return false
		end;
	end,
}