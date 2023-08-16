FACTION.name = "The Utah Chapter (BOS)"
FACTION.desc = "The Brotherhood of Steel is a military order located in the West and operating across the ruins of post-War North America with its roots stemming from the United States Armed Forces and the government-sponsored scientific community from former Mariposa Military Base before the Great War, dedicated to controlling and regulating technology in the wasteland."
FACTION.color = Color(9, 74, 143)
FACTION.isDefault = false
FACTION.weapons = {"weapon_laserrifle_le"}
FACTION.isCore = true -- Is the faction considered "core" and should have related immunities
FACTION.ConquestImmune = true -- Immune to conquest attack types
FACTION.pay = 3

FACTION.Radio = {
	["Color"] = Color(132, 132, 255), --The color that the message will appear in
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
	kill = {2, 2},
	passive = {15, 15},
}

FACTION_BOS = FACTION.index
