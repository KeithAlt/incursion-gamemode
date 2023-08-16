ITEM.name = "Food."
ITEM.desc = "A base for junk."
ITEM.model = "models/props_junk/popcan01a.mdl"
ITEM.restore = 250
ITEM.functions.use = {
	name = "Use",
	tip = "useTip",
	icon = "icon16/pencil.png",
	onRun = function(item)
		if (item.player) then
			local client = item.player
			local character = client:getChar()
			
			local hunger = character:getData("hunger", nut.survival.config.hungerMax)
			
			hunger = math.max(hunger + item.restore, nut.survival.config.thirstMax)
			
			character:setData("hunger", hunger)
			
			return true
		else
			return false
		end;
	end,
}