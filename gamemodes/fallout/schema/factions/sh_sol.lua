FACTION.name = "Sons of Liberty"
FACTION.desc = "Few true heroes remain in this wasteland."
FACTION.color = Color(255, 255, 255)
FACTION.isDefault = false
FACTION.weapons = {"weapon_marksmancarbine", "weapon_sh_cryogrenade", "fallout_lockpick"}

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
	passive = {18, 12},
}

FACTION_SOL = FACTION.index