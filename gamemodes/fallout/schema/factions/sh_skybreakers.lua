FACTION.name = "Skybreakers"
FACTION.desc = "Warriors with technology that seems to suggest they're from the future."
FACTION.color = Color(35, 108, 255)
FACTION.isDefault = false
FACTION.weapons = {"weapon_plasmarifle_len", "weapon_skybreaker_relay"}

FACTION.Radio = {
	["Color"] = Color(25, 155, 255, 255), --The color that the message will appear in
	["Sounds"] = { --One of these sounds will be randomly chosen and played when a message is sent
		"npc/metropolice/vo/allunitscode2.wav",
		"npc/metropolice/vo/allunitscloseonsuspect.wav",
		"npc/overwatch/radiovoice/404zone.wav",
		"npc/metropolice/vo/clearandcode100.wav",
		"npc/metropolice/vo/finalverdictadministered.wav",
		"npc/metropolice/vo/gota10-107sendairwatch.wav",
		"npc/metropolice/vo/hardpointscanning.wav",
	},
	["Volume"] = {90, 100}, --The volume of the sound will be a random number between these two numbers
	["Pitch"] = {80, 90}, --The pitch of the sound will be a random number between these two numbers
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
	kill = {2, 2},
	passive = {14, 15},
}

FACTION_SKYBREAKERS = FACTION.index
