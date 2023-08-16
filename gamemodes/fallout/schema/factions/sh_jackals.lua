FACTION.name = "Black Sand Empire"
FACTION.desc = "A normal wastelander."
FACTION.color = Color(175, 81, 81)
FACTION.isDefault = false
FACTION.weapons = {"weapon_r91_carb",}

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
	kill = {0, 4},
	passive = {30, 0},
}

FACTION_JACKALS = FACTION.index