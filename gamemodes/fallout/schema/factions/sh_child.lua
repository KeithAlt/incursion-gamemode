FACTION.name = "The Forged"
FACTION.desc = "A raider group obsessed with fire and metal."
FACTION.color = Color(255, 115, 0)
FACTION.isDefault = false
FACTION.weapons = {"weapon_nmrih_molotov", "weapon_handmadear"}

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

FACTION_CHILD = FACTION.index
