ITEM.name = "Warhorn"
ITEM.model = "models/fallout/brahminskullmask.mdl"
ITEM.desc = "A single-use war banner that buffs your entire faction with speed & damage resistance for brief time | This item can be used any where at any time for any reason"

ITEM.functions.use = {
	name = "Use",
	tip = "useTip",
	icon = "icon16/pencil.png",
	onRun = function(item)
		item.player:Give("weapon_warhorn")
		item.player:notify("Warhorn equipped")
		return true
	end,
}
