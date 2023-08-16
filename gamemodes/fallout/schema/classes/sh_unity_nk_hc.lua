CLASS.name = "Unity Nightkin - Officer"
CLASS.faction = FACTION_UNITY
CLASS.isDefault = false
CLASS.Officer = true
CLASS.IsMutant = true
CLASS.health = 500


function CLASS:onSpawn(ply) -- Unique loadout of this class
	ply:Give("weapon_stealthboy_nightkin")
	ply:Give("weapon_bumpersword_len_m2")
end

CLASS_MASTERS_NIGHTKIN = CLASS.index
