FACTION.name = "NCP"
FACTION.desc = "A pre-war Russian faction."
FACTION.color = Color(100, 255, 73)
FACTION.isDefault = false
FACTION.weapons = {"weapon_assault_carbine_l"}

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
	kill = {1, 3},
	passive = {20, 10},
}

FACTION_OCCUPANTS = FACTION.index
