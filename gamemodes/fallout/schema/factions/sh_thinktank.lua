FACTION.name = "Big MT"
FACTION.desc = "A normal wastelander."
FACTION.color = Color(0, 255, 255)
FACTION.isDefault = false
FACTION.weapons = {"weapon_plasmarifle_len", "weapon_thinktankrelay"}

FACTION.Radio = {
	["Color"] = Color(25, 25, 255, 255), --The color that the message will appear in
	["Sounds"] = { --One of these sounds will be randomly chosen and played when a message is sent
		"buttons/combine_button1.wav",
		"buttons/combine_button2.wav",
		"buttons/combine_button3.wav",
		"buttons/combine_button5.wav",
		"buttons/combine_button7.wav",
	},
	["Volume"] = {90, 100}, --The volume of the sound will be a random number between these two numbers
	["Pitch"] = {80, 120}, --The pitch of the sound will be a random number between these two numbers
	["Censor"] = true --Whether or not to censor the message for non-faction members
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
	kill = {1, 3},
	passive = {20, 10},
}

FACTION_THINKTANK = FACTION.index
