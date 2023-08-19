FACTION.name = "Wastelander"
FACTION.desc = "A survivor of the Nuclear Apocalypse. Man, Woman, Ghoul, whatever fate awaits for a Wastelander is up to no one but themself. Choose wisley when making such choices, as some factions & waste gangs will act upon you even for the smallest of things. This land is like none you know."
FACTION.color = Color(255, 203, 73)
FACTION.isDefault = true
FACTION.Radio = false
FACTION.canCustomize = true
FACTION.NotAttackable = true -- Faction is not attackable via war declaration system
FACTION.cannotBrand = true -- Restricts this faction from branding equipment

FACTION.mdls = {
	["male"] = {
		"models/Humans/Group02/male_09.mdl",
	},

	["female"] = {
		"models/Humans/Group01/Female_02.mdl",
	},
}

FACTION.models = {}

for i, v in pairs(FACTION.mdls["male"]) do
	FACTION.models[#FACTION.models + 1] = v[1] or v
end;

for i, v in pairs(FACTION.mdls["female"]) do
	FACTION.models[#FACTION.models + 1] = v[1] or v
end;

FACTION.karma = {
	kill = {2, 2},
	passive = {15, 15},
}

FACTION_WASTELANDER = FACTION.index
