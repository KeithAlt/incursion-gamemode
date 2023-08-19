FACTION.name = "House Industries"
FACTION.desc = "A normal wastelander."
FACTION.color = Color(0, 8, 134)
FACTION.isDefault = false
FACTION.weapons = {"weapon_45_sub", "weapon_switchblade"}

FACTION.Radio = {
	["Color"] = Color(255, 238, 0, 255), --The color that the message will appear in
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
	passive = {25, 5},
}

FACTION_HOUSE = FACTION.index
