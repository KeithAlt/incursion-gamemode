FACTION.name = "Enclave"
FACTION.desc = "The Enclave is an organization that claims to be the legally-sanctioned continuity of the pre-War federal government of the United States and styles itself the United States of America as such."
FACTION.color = Color(130, 130, 130)
FACTION.pay = 3
FACTION.isDefault = false
FACTION.weapons = {"weapon_enclave_plasmarifle_len", "weapon_grenadeplasma"}
FACTION.isCore = true -- Is the faction considered "core" and should have related immunities
FACTION.ConquestImmune = false -- Immune to conquest attack types

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
	kill = {0, 15},
	passive = {50, 0},
}

FACTION_ENCLAVE = FACTION.index