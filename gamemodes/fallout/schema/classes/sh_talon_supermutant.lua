CLASS.name = "Super Mutant - Unknown"
CLASS.faction = FACTION_TALON
CLASS.isDefault = true
CLASS.IsMutant = true
CLASS.health = 750
CLASS.walkSpeedMultiplier = false
CLASS.runSpeedMultiplier = false
CLASS.bloodcolor = BLOOD_COLOR_GREEN
CLASS.Color = Color(31, 146, 0)

function CLASS:onSpawn(ply)
	ply:SetHealth(750)
	ply:SetMaxHealth(750)
end


CLASS_TALONSUPER = CLASS.index
