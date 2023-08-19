FACTION.name = "Bunker Hill"
FACTION.desc = "Few true heroes remain in this wasteland."
FACTION.color = Color(68, 35, 0)
FACTION.isDefault = false
FACTION.weapons = {"weapon_laserrifle_le", "weapon_slam", "weapon_frag"}

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
	passive = {5, 25},
}

FACTION_GOODNEIGHBOR = FACTION.index
