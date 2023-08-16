FACTION.name = "Monster"
FACTION.desc = "A normal wastelander."
FACTION.color = Color(255, 0, 0)
FACTION.isDefault = false
FACTION.Radio = false
FACTION.NotAttackable = true -- Faction is not attackable via war declaration system
FACTION.cannotBrand = true -- Restricts this faction from branding equipment
FACTION.speedModifer = 2 -- Speed buff
FACTION.weapons = {"swep_am_monster"}

FACTION.mdls = {
	["male"] = {
		"models/fallout/deathclaw.mdl",
		/**"models/fallout/deathclaw_alphamale.mdl",
		"models/fallout/mirelurk_hunter.mdl",
		"models/fallout/mirelurk.mdl",
		"models/fallout/mirelurkking.mdl",
		"models/fallout/cazadore.mdl",**/
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

FACTION_MONSTER = FACTION.index

function FACTION:onSpawn(client)
	client:SetMaxHealth(1000)
    client:SetHealth(1000)
	client:falloutNotify("You are playing as a KOS Monster", "ui/notify.mp3")
	client:SetNoTarget(true)
end
