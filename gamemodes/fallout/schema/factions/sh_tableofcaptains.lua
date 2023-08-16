FACTION.name = "Order of the Eternal Abyss"
FACTION.desc = "A shadow organization oriented toward the claim of technology."
FACTION.color = Color(67, 0, 255)
FACTION.isDefault = false
FACTION.weapons = {"weapon_laserrifle_le"}

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

FACTION_TABLEOFCAPTAINS = FACTION.index
