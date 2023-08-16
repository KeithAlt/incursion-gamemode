FACTION.name = "3rd Company (NCR)"
FACTION.desc = "The New California Republic is a large, democratic federation of states with a population of well over 700,000 based in California, with holdings in Nevada, Mexico and along the Colorado River."
FACTION.color = Color(177, 131, 40)
FACTION.isDefault = false
FACTION.weapons = {"weapon_servicerifle_wscope"}
FACTION.isCore = true -- Is the faction considered "core" and should have related immunities
FACTION.ConquestImmune = true -- Immune to conquest attack types
FACTION.pay = 3

FACTION.Radio = {
	["Color"] = Color(200, 150, 80, 255), --The color that the message will appear in
	["Sounds"] = {
		"npc/metropolice/vo/off1.wav",
		"npc/metropolice/vo/off2.wav",
		"npc/metropolice/vo/off3.wav",
	},
	["Volume"] = {60, 70},
	["Pitch"] = {80, 120},
	["Censor"] = false,
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
	kill = {3, 1},
	passive = {5, 25},
}

FACTION_NCR = FACTION.index
