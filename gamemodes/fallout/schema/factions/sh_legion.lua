FACTION.name = "Lion Cohort (Legion)"
FACTION.desc = "Caesar's Legion is an autocratic, traditionalist, imperialistic slaver society and totalitarian dictatorship. It has about 120,000 people living in its borders by the time of 2281."
FACTION.color = Color(155, 26, 26)
FACTION.isDefault = false
FACTION.weapons = {"weapon_10mm_sub", "weapon_machetegladius_len_m2"}
FACTION.isCore = true -- Is the faction considered "core" and should have related immunities
FACTION.ConquestImmune = true -- Immune to conquest attack types
FACTION.pay = 3

FACTION.Radio = {
	["Color"] = Color(255, 115, 115, 255), --The color that the message will appear in
	["Sounds"] = { --One of these sounds will be randomly chosen and played when a message is sent
		"npc/metropolice/vo/off1.wav",
		"npc/metropolice/vo/off2.wav",
		"npc/metropolice/vo/off3.wav"
	},
	["Volume"] = {60, 70}, --The volume of the sound will be a random number between these two numbers
	["Pitch"] = {60, 90}, --The pitch of the sound will be a random number between these two numbers
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
	kill = {1, 3},
	passive = {25, 5},
}

FACTION_LEGION = FACTION.index
