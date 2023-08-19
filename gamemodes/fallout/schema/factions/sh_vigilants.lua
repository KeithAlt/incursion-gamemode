FACTION.name = "Midwestern BOS"
FACTION.desc = "Few true heroes remain in this wasteland."
FACTION.color = Color(52, 110, 255)
FACTION.isDefault = false

FACTION.Radio = {
	["Color"] = Color(255, 255, 255, 255), --The color that the message will appear in
	["Sounds"] = {
		"npc/metropolice/vo/off1.wav",
		"npc/metropolice/vo/off2.wav",
		"npc/metropolice/vo/off3.wav",
	},
	["Volume"] = {60, 70},
	["Pitch"] = {80, 120},
	["Censor"] = false,
}

FACTION.speedModifer = 1
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

FACTION.karma = {
	kill = {2, 2},
	passive = {15, 15},
}

FACTION_VIGILANTS = FACTION.index