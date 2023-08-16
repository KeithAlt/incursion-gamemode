CLASS.name = "Super Mutant - TT"
CLASS.faction = FACTION_THINKTANK
CLASS.isDefault = true
CLASS.IsMutant = true
CLASS.walkSpeedMultiplier = false
CLASS.runSpeedMultiplier = false
CLASS.bloodcolor = BLOOD_COLOR_GREEN
CLASS.Color = Color(31, 146, 0)

CLASS_THINKTANK_SUPERMUTANT = CLASS.index

function CLASS:onSpawn(ply)
	ply:SetHealth(750)
	ply:SetMaxHealth(750)
	ply.isImmune = true
end
