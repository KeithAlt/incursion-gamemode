FACTION.name = "Follower of the Apocalypse"
FACTION.desc = "A normal wastelander."
FACTION.color = Color(255, 255, 255)
FACTION.isDefault = false
FACTION.weapons = {"weapon_medkit"}

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
	kill = {4, 0},
	passive = {0, 30},
}

FACTION_NECROSIS = FACTION.index
