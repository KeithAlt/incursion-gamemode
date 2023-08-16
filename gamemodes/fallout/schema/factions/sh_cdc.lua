FACTION.name = "Van Graffs ©"
FACTION.desc = "A normal wastelander."
FACTION.color = Color(255, 255, 0)
FACTION.isDefault = false
FACTION.weapons = {"weapon_laserrifle_le"}
FACTION.isMerchant = true -- Is the faction a merchant and should have related immunities
FACTION.ConquestImmune = true -- Immune to conquest attack types


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

FACTION_CDC = FACTION.index
