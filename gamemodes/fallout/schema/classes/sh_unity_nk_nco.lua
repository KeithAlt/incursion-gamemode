CLASS.name = "Unity Nightkin - NCO"
CLASS.faction = FACTION_UNITY
CLASS.isDefault = false
CLASS.NCO = true
CLASS.IsMutant = true
CLASS.health = 500


function CLASS:onSpawn(ply) -- Unique loadout of this class
	ply:Give("weapon_stealthboy_nightkin")
	ply:Give("weapon_bumpersword_len_m2")
end

CLASS_UNITY_NCO_NIGHTKIN = CLASS.index
