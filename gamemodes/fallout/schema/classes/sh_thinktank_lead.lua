CLASS.name = "Think Tank - Officer"
CLASS.faction = FACTION_THINKTANK
CLASS.isDefault = false
CLASS.Officer = true
CLASS.Color = Color(255, 203, 73)

function CLASS:onSpawn(ply) -- Unique class loadout
	ply:Give("weapon_ghostinjector")
end

CLASS_THINKTANKLEAD = CLASS.index
