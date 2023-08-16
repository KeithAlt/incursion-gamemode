CLASS.name = "UE - Alpha Droid Officer"
CLASS.faction = FACTION_BOOMERS
CLASS.isDefault = false
CLASS.Officer = true
CLASS.IsRobot = true
CLASS.health = 850
CLASS.noArmor = false -- Allow for equipment of their unique legacy armor item

CLASS_SENTRY_ONYX_OFFICER = CLASS.index

function CLASS:onSpawn(ply)
	ply:ChatPrint("✘ You have spawned with a Ghost Injector ✘")
	ply:ChatPrint("- Report any bugs associated with the Injector")
	ply:ChatPrint("- DO NOT SPAM IT RANDOMALLY")
	ply:Give( "weapon_ghostinjector" )
	ply:Give( "weapon_laser_rcw" )
	ply:Give( "weapon_smmg_len" )
end
