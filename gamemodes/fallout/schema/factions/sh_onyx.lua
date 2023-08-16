FACTION.name = "Universal Energy"
FACTION.desc = "A normal wastelander."
FACTION.color = Color(0, 183, 255)
FACTION.isDefault = false
FACTION.weapons = {"weapon_127pistol_len"}

FACTION.Radio = {
	["Color"] = Color(0, 183, 255), --The color that the message will appear in
	["Sounds"] = {
		"npc/metropolice/vo/off1.wav",
		"npc/metropolice/vo/off2.wav",
		"npc/metropolice/vo/off3.wav",
	},
	["Volume"] = {60, 70}, --The volume of the sound will be a random number between these two numbers
	["Pitch"] = {40, 60}, --The pitch of the sound will be a random number between these two numbers
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
	kill = {4, 0},
	passive = {20, 10},
}

FACTION_BOOMERS = FACTION.index
