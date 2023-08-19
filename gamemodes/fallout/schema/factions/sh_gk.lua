FACTION.name = "Great Khans ©"
FACTION.desc = "Chem dealers and pillagers of the wasteland."
FACTION.color = Color(255, 131, 0)
FACTION.isDefault = false
FACTION.weapons = {"weapon_assault_carbine_l"}
FACTION.isMerchant = true -- Is the faction a merchant and should have related immunities
FACTION.ConquestImmune = true -- Immune to conquest attack types
FACTION.pay = 5

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

FACTION_GK = FACTION.index
