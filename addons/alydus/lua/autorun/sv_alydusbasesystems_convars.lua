local convarFlags = {FCVAR_NOTIFY}
local convarPrefix = "sv_alydusbasesystems_"
CreateConVar(convarPrefix .. "enable_basecontroller_repairsound", 1, convarFlags) -- Enable sound when repairing
CreateConVar(convarPrefix .. "enable_basecontroller_destructionexplosion", 1, convarFlags) -- Enable explosion
CreateConVar(convarPrefix .. "enable_basecontroller_destructionignition", 1, convarFlags)
CreateConVar(convarPrefix .. "enable_basecontroller_destructionignitionlength", 15, convarFlags) -- Time it lasts
CreateConVar(convarPrefix .. "enable_basecontroller_destructionignitionradius", 0, convarFlags) -- Radius it ignites around
CreateConVar(convarPrefix .. "enable_basecontroller_destructionexplosionextra", 1, convarFlags) -- Lab extra SFX
CreateConVar(convarPrefix .. "enable_basecontroller_destructionscreenshake", 1, convarFlags) -- Shake screen on destruction
CreateConVar(convarPrefix .. "enable_module_maximumclaimradius", 3500, convarFlags) -- Maximum claim radius when pressing E to base controller
CreateConVar(convarPrefix .. "enable_module_claimcppiset", 1, convarFlags) -- Set CPPI owner when claimed
CreateConVar(convarPrefix .. "enable_module_destructionexplosion", 1, convarFlags) -- Enable explosion
CreateConVar(convarPrefix .. "enable_module_destructionignition", 1, convarFlags)
CreateConVar(convarPrefix .. "enable_module_destructionignitionlength", 15, convarFlags) -- Time it lasts
CreateConVar(convarPrefix .. "enable_module_destructionignitionradius", 0, convarFlags) -- Radius it ignites around
CreateConVar(convarPrefix .. "enable_module_destructionexplosionextra", 1, convarFlags) -- Lab extra SFX
CreateConVar(convarPrefix .. "enable_module_destructionscreenshake", 1, convarFlags) -- Shake screen on destruction
CreateConVar(convarPrefix .. "config_module_defaulthealth", 150, convarFlags)
CreateConVar(convarPrefix .. "config_proximitytrigger_range", 150, convarFlags)
CreateConVar(convarPrefix .. "config_samturret_range", 2500, convarFlags)
CreateConVar(convarPrefix .. "config_samturret_prioritisenearbytargets", 1, convarFlags)
CreateConVar(convarPrefix .. "config_samturret_damage", 250, convarFlags)
CreateConVar(convarPrefix .. "config_gunturret_range", 2500, convarFlags)
CreateConVar(convarPrefix .. "config_gunturret_prioritisenearbytargets", 1, convarFlags)
CreateConVar(convarPrefix .. "config_gunturret_bulletdamage", 10, convarFlags)
CreateConVar(convarPrefix .. "config_gunturret_bulletforce", 15, convarFlags)
CreateConVar(convarPrefix .. "config_gunturret_turretstargetownerteam", 1, convarFlags)
CreateConVar(convarPrefix .. "config_laserturret_range", 3000, convarFlags)
CreateConVar(convarPrefix .. "config_laserturret_prioritisenearbytargets", 1, convarFlags)
CreateConVar(convarPrefix .. "config_laserturret_bulletdamage", 20, convarFlags)
CreateConVar(convarPrefix .. "config_laserturret_bulletforce", 100, convarFlags)
CreateConVar(convarPrefix .. "config_alarm_soundlevel", 65, convarFlags)
CreateConVar(convarPrefix .. "config_camera_identifyentities", 1, convarFlags)
CreateConVar(convarPrefix .. "config_gunturretammo_amount", 100, convarFlags)
CreateConVar(convarPrefix .. "config_samturretammo_amount", 10, convarFlags)
CreateConVar(convarPrefix .. "config_laserturretammo_amount", 100, convarFlags)
