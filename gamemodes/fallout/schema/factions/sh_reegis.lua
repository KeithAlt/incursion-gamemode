FACTION.name = "Regiis"
FACTION.desc = "A normal wastelander."
FACTION.color = Color(202, 89, 89)
FACTION.isDefault = false
FACTION.weapons = {"weapon_plasmarifle_len", "meleearts_blade_sword"}

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
	passive = {10, 20},
}

FACTION_REEGIS = FACTION.index
