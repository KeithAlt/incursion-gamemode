ITEM.name = "Nuclear Warhead Signal Strike"
ITEM.model = "models/llama/briefcasedhalfopen.mdl"
ITEM.desc = "A single-use nuclear strike that devestates the area of impact and covers the surrounding area in radiation fog | This item can be used any where at any time for any reason"

ITEM.functions.use = {
	name = "Use",
	tip = "useTip",
	icon = "icon16/pencil.png",
	onRun = function(item)
		item.player:Give("weapon_nuclearinit")
		item.player:notify("Nuclear strike detonator received")
		return true
	end,
}
