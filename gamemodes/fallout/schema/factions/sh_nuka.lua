FACTION.name = "Boomers"
FACTION.desc = "A normal wastelander."
FACTION.color = Color(168, 160, 0)
FACTION.isDefault = false
FACTION.weapons = {"weapon_grenaderifle_len"}

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
	FACTION.models[#FACTION.models + 1] = v
end;

for i, v in pairs(FACTION.mdls["female"]) do
	FACTION.models[#FACTION.models + 1] = v
end;

FACTION.karma = {
	kill = {2, 2},
	passive = {15, 15},
}

FACTION_NUKA = FACTION.index
