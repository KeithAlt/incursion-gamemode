CLASS.name = "Legion - Officer"
CLASS.faction = FACTION_LEGION
CLASS.isDefault = false
CLASS.Officer = true
CLASS.Color = Color(255, 203, 73)


CLASS.specialBuffs = {	-- Special buffs on spawn
    ["A"] = 2,
    ["S"] = 2
}

CLASS_CENTURION = CLASS.index
function CLASS:onSpawn(client)
	if SERVER then
		client:Give("weapon_core_markrifle")
	end
end