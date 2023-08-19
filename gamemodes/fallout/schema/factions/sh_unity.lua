FACTION.name = "Unity"
FACTION.desc = "A normal wastelander."
FACTION.color = Color(20, 174, 0)
FACTION.isDefault = false
FACTION.weapons = {"weapon_rebarclub_len_m2", "weapon_laserrifle_le"}

FACTION.mdls = {
	["male"] = {
		"models/player/keitho/supermutant.mdl",
		"models/player/keitho/supermutant_nightkin.mdl"
	},
}

FACTION.models = {}

for i, v in pairs(FACTION.mdls["male"]) do
	FACTION.models[#FACTION.models + 1] = v
end;

FACTION.karma = {
	kill = {0, 4},
	passive = {25, 5},
}

FACTION_UNITY = FACTION.index

function FACTION:onSpawn(client)
	client:SetMaxHealth(750)
    client:SetHealth(750)
end
