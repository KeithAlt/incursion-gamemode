CLASS.name = "SOL - Officer"
CLASS.faction = FACTION_SOL
CLASS.isDefault = false
CLASS.Officer = true
CLASS.Color = Color(255, 203, 73)

function CLASS:onSpawn(ply) -- Unique loadout of this class
	ply:Give( "weapon_sh_cryogrenade" )
	ply:Give( "ptp_weapon_flash" )
	ply:Give( "ptp_weapon_smoke" )
end

CLASS_SOL_OFFICER = CLASS.index
