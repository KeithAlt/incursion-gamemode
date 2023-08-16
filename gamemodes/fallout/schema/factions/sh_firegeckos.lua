FACTION.name = "Fire Geckos"
FACTION.desc = "BURN IT ALL TO THE GROUND!."
FACTION.color = Color(255, 74, 74)
FACTION.isDefault = false
FACTION.Radio = false
FACTION.NotAttackable = true -- Faction is not attackable via war declaration system
FACTION.weapons = {"swep_am_monster"} -- FIXME: Removed fire SWEP due to instability

FACTION.mdls = {
	["male"] = {
		"models/fallout/gecko.mdl"
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

FACTION_FIREGECKOS = FACTION.index

function FACTION:onSpawn(client)
	jlib.Announce(client, Color(255,0,0), "[WARNING] ", Color(255,155,155), "This class is currently under maintenance & has had it's fire SWEP removed temporarily") -- FIXME: Remove after fix
    client:SetHealth(400)
	client:falloutNotify("You are playing as a KOS Monster", "ui/notify.mp3")
	client:SetNoTarget(true)
end
