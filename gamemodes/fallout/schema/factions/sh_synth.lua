FACTION.name = "Synth"
FACTION.desc = "A synthetic humanoid."
FACTION.color = Color(255, 73, 0)
FACTION.isDefault = false
FACTION.weapons = {"weapon_laser_tribeam"}

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

FACTION_SYNTH = FACTION.index

function FACTION:onSpawn(client)
	client:SetMaxHealth(350)
    client:SetHealth(350)
end