FACTION.name = "The Shi"
FACTION.desc = "Few true heroes remain in this wasteland."
FACTION.color = Color(185, 0, 0)
FACTION.isDefault = false
FACTION.weapons = {"weapon_chinese_ar", "weapon_chinesepistol", "weapon_chineseofficersword"}

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
	kill = {2, 2},
	passive = {15, 15},
}

FACTION_SHI = FACTION.index