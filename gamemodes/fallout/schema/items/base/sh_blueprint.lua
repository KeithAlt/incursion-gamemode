ITEM.name = "Blueprint Base"
ITEM.desc = "If you have this then you shouldn't."
ITEM.model = "models/clutter/book.mdl"
ITEM.blueprint = nil

ITEM.functions.use = {
	name = "Use",
	tip = "useTip",
	icon = "icon16/add.png",
	onRun = function(item)
		local character = item.player:getChar()
		
		local recipes = character:getData("recipes", {})
		
		if (table.HasValue(recipes, item.blueprint)) then
			item.player:falloutNotify("You have already learned the "..item.name)
			return false
		else
			recipes[#recipes + 1] = item.blueprint
			
			character:setData("recipes", recipes)
			
			item.player:falloutNotify("You have learned the "..item.name, "fallout/item/generic_pickup.wav")
		end;
	end,
}