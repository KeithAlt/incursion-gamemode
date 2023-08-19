FACTION.name = "Talon Company"
FACTION.desc = "A normal wastelander."
FACTION.color = Color(127, 0, 255)
FACTION.isDefault = false

FACTION.Radio = {
	["Color"] = Color(228, 61, 234, 255), --The color that the message will appear in
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
FACTION.weapons = {"weapon_chinese_ar"}

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
	kill = {0, 4},
	passive = {25, 5},
}

FACTION_TALON = FACTION.index