CLASS.name = "SOL - Soldier"
CLASS.faction = FACTION_SOL
CLASS.isDefault = true
CLASS.Color = Color(255, 203, 73)

function CLASS:onSpawn(ply) -- Unique loadout of this class
	ply:Give( "weapon_sh_cryogrenade" )
	ply:Give( "ptp_weapon_flash" )
	ply:Give( "ptp_weapon_smoke" )
end

CLASS_SOL = CLASS.index
