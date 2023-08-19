FACTION.name = "Gold Rush Minutemen"
FACTION.desc = "Chem dealers and pillagers of the wasteland."
FACTION.color = Color(0, 87, 141)
FACTION.isDefault = false
FACTION.weapons = {"weapon_lasermusket"}

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

FACTION_MM = FACTION.index
