FACTION.name = "Super Mutant"
FACTION.desc = "An abomination of the wasteland created through the genetic mutation."
FACTION.color = Color(31, 146, 0)
FACTION.isDefault = false
FACTION.Radio = false
FACTION.cannotBrand = true -- Restricts this faction from branding equipment
FACTION.NotAttackable = true -- Faction is not attackable via war declaration system
FACTION.weapons = {"weapon_rebarclub_len_m2", "weapon_r91_carb"}

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
	kill = {2, 2},
	passive = {15, 15},
}

FACTION_SUPERMUTANT = FACTION.index

function FACTION:onSpawn(client)
	client:SetMaxHealth(750)
	client:SetHealth(750)
end