ITEM.name = "Bitter Drink"
ITEM.category = "Medical"
ITEM.desc = "A natural drink that slowly heals over a 30 second period and energizes the body. This chem is not improved by having a better chemist."
ITEM.model = "models/fallout/antivenom.mdl"
ITEM.price = 90
ITEM.isChem = true

ITEM.functions.Use = {
	sound = "items/medshot4.wav",
	onRun = function(item)
		jlib.HealOverTime(item.player, "bitterdrink", 25, 30)
		item.player:AddDR(7, 60)
		item.player:AddDMG(7, 60)
		item.player:falloutNotify("You nearly vomit from the bitter flavor")
		item.player:EmitSound("npc/barnacle/barnacle_gulp1.wav")
		item.player:ChatPrint("[ ! ]  +7 DMG")
		item.player:ChatPrint("[ ! ]  +7 DR")
		item.player:ChatPrint("[ ! ]  +25 REST")
	end
}
