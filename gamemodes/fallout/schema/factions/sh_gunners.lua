FACTION.name = "Gunners"
FACTION.desc = "A normal wastelander."
FACTION.color = Color(33, 96, 0)
FACTION.isDefault = false
FACTION.weapons = {"weapon_assault_carbine_l", "weapon_grenadefrag", "weapon_nailboard"}

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
	passive = {25, 5},
}

FACTION_GUNNERS = FACTION.index
