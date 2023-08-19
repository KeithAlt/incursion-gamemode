FACTION.name = "Creature"
FACTION.desc = "A creature of the wasteland whom of which is tameable."
FACTION.color = Color(255, 74, 74)
FACTION.isDefault = false
FACTION.Radio = false
FACTION.speedModifer = 2 -- Speed buff
FACTION.cannotBrand = true -- Restricts this faction from branding equipment
FACTION.NotAttackable = true -- Faction is not attackable via war declaration system
FACTION.weapons = {"swep_am_monster"}

FACTION.mdls = {
	["male"] = {
		"models/fallout/dogvicious.mdl",
		"models/fallout/coyote.mdl",
		"models/fallout/mongrel.mdl",
		"models/fallout/nightstalker.mdl",
		"models/fallout/molerat.mdl",
		"models/fallout/giantant.mdl",
		"models/fallout/giantrat.mdl",
		"models/fallout/mantis.mdl",
		"models/fallout/cazadore.mdl",
		"models/fallout/brahmin.mdl",
		"models/fallout/brahminpack.mdl",
		"models/fallout/gecko.mdl",
	},
}

FACTION.models = {}

for i, v in pairs(FACTION.mdls["male"]) do
	FACTION.models[#FACTION.models + 1] = v
end;

FACTION.karma = {
	kill = {2, 2},
	passive = {15, 15},
}

FACTION_CREATURE = FACTION.index

function FACTION:onSpawn(client)
	client:SetMaxHealth(400)
    client:SetHealth(400)
	client:falloutNotify("You are playing as an optional KOS Creature", "ui/notify.mp3")
	client:SetNoTarget(true)
end
