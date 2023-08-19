FACTION.name = "Cyber Initiative"
FACTION.desc = "A shadow organization oriented toward the claim of technology."
FACTION.color = Color(0, 8, 134)
FACTION.isDefault = false
FACTION.weapons = {"weapon_laserrifle_le"}

FACTION.Radio = {
	["Color"] = Color(100, 100, 255, 255), --The color that the message will appear in
	["Sounds"] = { --One of these sounds will be randomly chosen and played when a message is sent
		"ambient/levels/prison/radio_random1.wav",
		"ambient/levels/prison/radio_random2.wav",
		"ambient/levels/prison/radio_random3.wav",
		"ambient/levels/prison/radio_random4.wav",
		"ambient/levels/prison/radio_random5.wav",
	},
	["Volume"] = {90, 100}, --The volume of the sound will be a random number between these two numbers
	["Pitch"] = {70, 90}, --The pitch of the sound will be a random number between these two numbers
	["Censor"] = true --Whether or not to censor the message for non-faction members
}

FACTION.mdls = {
	["male"] = {
		"models/nutscript/player/keitho/robotrace.mdl",
	},
}

FACTION.models = {}

for i, v in pairs(FACTION.mdls["male"]) do
	FACTION.models[#FACTION.models + 1] = v
end;

FACTION.karma = {
	kill = {1, 3},
	passive = {5, 25},
}

FACTION_CYBER_INITATIVE = FACTION.index
