ITEM.name = "Healing Powder"
ITEM.category = "Medical"
ITEM.desc = "A small pouch of medical herbs used for healing."
ITEM.model = "models/maxib123/healingpowder.mdl"
ITEM.price = 60
ITEM.isChem = true

ITEM.functions.Use = {
	sound = "items/medshot4.wav",
	onRun = function(item)
		jlib.HealOverTime(item.player, "healingpowder", 50, 10)
	end
}
ITEM.factions = {FACTION_CP, FACTION_OW}
