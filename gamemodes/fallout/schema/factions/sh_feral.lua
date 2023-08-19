FACTION.name = "Feral Ghoul"
FACTION.desc = "Feral Monsters of the wastes that seek to consume the living."
FACTION.color = Color(255, 0, 0)
FACTION.isDefault = false
FACTION.Radio = false
FACTION.speedModifer = 2 -- Speed buff
FACTION.cannotBrand = true -- Restricts this faction from branding equipment
FACTION.NotAttackable = true -- Faction is not attackable via war declaration system

FACTION.mdls = {
	["male"] = {
		"models/fallout_3/ghoul.mdl"
	},
}

FACTION.models = {}

for i, v in pairs(FACTION.mdls["male"]) do
	FACTION.models[#FACTION.models + 1] = v
end;

FACTION.karma = {
	kill = {0, 5},
	passive = {50, 0},
}

FACTION_FERAL = FACTION.index

function FACTION:onSpawn(client)
	client:SetMaxHealth(300)
    client:SetHealth(300)
	client:falloutNotify("You are playing as a KOS Monster", "ui/notify.mp3")
	client:SetNoTarget(true)
end
