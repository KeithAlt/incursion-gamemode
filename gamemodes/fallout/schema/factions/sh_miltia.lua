FACTION.name = "Militia M.C."
FACTION.desc = "A normal wastelander."
FACTION.color = Color(95, 127, 255)
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
	kill = {3, 1},
	passive = {10, 20},
}

FACTION_MILITIA = FACTION.index
