FACTION.name = "Staff"
FACTION.desc = "Fallout Incursion Staff Role."
FACTION.color = Color(50, 255, 0)
FACTION.isDefault = false
FACTION.Radio = false
FACTION.NotAttackable = true -- Faction is not attackable via war declaration system
FACTION.weapons = {"weapon_physgun", "gmod_tool", "weapon_vj_npccontroller"}

FACTION.mdls = {
	["staff"] = {
		"models/player/power_armor_admin/slow.mdl",
	}
}

FACTION.models = {}

for i, v in pairs(FACTION.mdls["staff"]) do
	FACTION.models[#FACTION.models + 1] = v
end;

FACTION_STAFF = FACTION.index

function FACTION:onSpawn(client)
	client:SetMaxHealth(9999999)
    client:SetHealth(999999)
end
