CLASS.name = "Unity - Centaur"
CLASS.faction = FACTION_UNITY
CLASS.isDefault = false
CLASS.noHunger = true -- Immune to hunger/thirst
CLASS.IsMutant = true
CLASS.pill = "unity_centaur"

CLASS.specialBuffs = {	-- Special buffs on spawn
	["E"] = 25,
}

function CLASS:onSpawn(ply)
	ply:AddEFlags(EFL_NO_DAMAGE_FORCES)
end

CLASS_UNITY_CENTAUR = CLASS.index
