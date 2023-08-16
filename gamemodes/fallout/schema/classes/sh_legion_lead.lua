CLASS.name = "Legion - Command"
CLASS.faction = FACTION_LEGION
CLASS.isDefault = false
CLASS.Officer = true
CLASS.Color = Color(255, 203, 73)


CLASS.specialBuffs = {	-- Special buffs on spawn
    ["A"] = 4,
    ["S"] = 4
}

function CLASS:onSpawn(client)
	if SERVER then
		client:Give("weapon_legionblade_len_m2")
		client:Give("weapon_core_cowboyrep")
	end
end

CLASS_CENTURION_LEAD = CLASS.index
