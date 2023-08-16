FACTION.name = "Nuclear Patriots"
FACTION.desc = "Remnants of a long gone spliter cell."
FACTION.color = Color(95, 95, 95)
FACTION.isDefault = false
FACTION.weapons = {"weapon_cowboyrepeater_len", "realistic_hook"}

FACTION.Radio = {
	["Color"] = Color(255, 25, 25, 255), --The color that the message will appear in
	["Sounds"] = { --One of these sounds will be randomly chosen and played when a message is sent
		"radio/umbra1.ogg",
		"radio/umbra2.ogg",
		"radio/umbra3.ogg",
		"radio/umbra4.ogg",
		"radio/umbra5.ogg",
	},
	["Volume"] = {90, 100}, --The volume of the sound will be a random number between these two numbers
	["Pitch"] = {70, 70}, --The pitch of the sound will be a random number between these two numbers
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
	kill = {0, 4},
	passive = {5, 25},
}

FACTION_EIU = FACTION.index