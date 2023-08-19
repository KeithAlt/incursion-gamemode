FACTION.name = "Robot"
FACTION.desc = "ATTENTION: This is a class selection role. You can request to be the following via '/OOC' chat from Staff: Protectron / Mister Gutsy / Eyebot"
FACTION.color = Color(0, 8, 134)
FACTION.isDefault = false
FACTION.CanClassChange = true -- Allows players to change classes within faction
FACTION.Radio = false
FACTION.NotAttackable = true -- Faction is not attackable via war declaration system
FACTION.cannotBrand = true -- Restricts this faction from branding equipment
FACTION.weapons = {"weapon_laser_tribeam"}

FACTION.mdls = {
	["male"] = {
		"models/fallout/protectron.mdl",
		"models/fallout/eyebot.mdl",
		"models/fallout/mistergutsy.mdl",
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

FACTION_ROBOT = FACTION.index

function FACTION:onSpawn(client)
	client:SetHealth(250)
	client:falloutNotify("You are playing as a Robot", "ui/notify.mp3")
end
