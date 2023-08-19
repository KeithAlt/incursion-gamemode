FACTION.name = "Washington Brotherhood"
FACTION.desc = "A totalitarrian, corrupted Brotherhood chapter."
FACTION.color = Color(79, 0, 143)
FACTION.isDefault = false
FACTION.weapons = {"weapon_corder_protplasma"}

FACTION.Radio = {
	["Color"] = Color(173, 88, 252), --The color that the message will appear in
	["Sounds"] = { --One of these sounds will be randomly chosen and played when a message is sent
		"npc/metropolice/vo/off1.wav",
		"npc/metropolice/vo/off2.wav",
		"npc/metropolice/vo/off3.wav"
	},
	["Volume"] = {60, 70}, --The volume of the sound will be a random number between these two numbers
	["Pitch"] = {80, 120}, --The pitch of the sound will be a random number between these two numbers
	["Censor"] = false --Whether or not to censor the message for non-faction members
}

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
	passive = {30, 0},
}

FACTION_BOOMERS_R = FACTION.index
