-- NOTE/FIXME: This faction should be merged into Robots in the future
FACTION.name = "Sentry"
FACTION.desc = "A highly advanced military defense robot."
FACTION.color = Color(0, 8, 134)
FACTION.isDefault = false
FACTION.Radio = false
FACTION.cannotBrand = true -- Restricts this faction from branding equipment
FACTION.NotAttackable = true -- Faction is not attackable via war declaration system
FACTION.weapons = {"weapon_smmg_len", "weapon_rpg"}

FACTION.mdls = {
	["male"] = {
		"models/fallout/sentrybot.mdl",
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

FACTION_SENTRY = FACTION.index

function FACTION:onSpawn(client)
	client:SetMaxHealth(850)
	client:SetHealth(850)
	client:falloutNotify("You are playing as a Robot", "ui/notify.mp3")
end