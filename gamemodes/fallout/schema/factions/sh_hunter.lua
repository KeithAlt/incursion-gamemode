FACTION.name = "The Hunters Guild"
FACTION.desc = "Bounty Hunters of the Wasteland."
FACTION.color = Color(255, 63, 0)
FACTION.isDefault = false
FACTION.NotAttackable = true -- Faction is not attackable via war declaration system
FACTION.IsBountyHunter = true

FACTION.mdls = {
	["male"] = {
		"models/player/keitho/manhunter.mdl"
	}
}

FACTION.models = {}

for i, v in pairs(FACTION.mdls["male"]) do
	FACTION.models[#FACTION.models + 1] = v
end;

FACTION.karma = {
	kill = {1, 3},
	passive = {20, 10},
}

FACTION_HUNTER = FACTION.index

function FACTION:onSpawn(client)
	client:SetMaxHealth(2000)
    client:SetHealth(2000)
end
