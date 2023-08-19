-- Must be <= 100 chance of permanent ability will be 100 subtracted by this value
Psykers.Config.RegularEffectChance = 99.5

-- Potential locations for the random teleport effect
Psykers.Config.TeleportLocations = {
	["gm_flatgrass"] = {
		Vector(-702.207214, -29.565704, -12684.244141)
	}
}

-- Blackhole settings
Psykers.Config.BlackholeEntity = "psykersblackhole"
Psykers.Config.BlackholeDuration = 30
Psykers.Config.BlackholeOffset = Vector(0, 0, 350)

-- Potential pills for the random pill effect
Psykers.Config.Pills = {
	"bird_seagull",
	"bird_pigeon",
	"feral",
	"cazadore",
	"deathclaw",
	"cactus",
	"dorf",
	"melon",
	"landshark",
	"parakeet"
}

-- VJBase NPC for the transformation effect
Psykers.Config.VJBaseNPC = "npc_vj_fallout_supermutant_behemoth"

-- Duration of the effect that plays before transformation
Psykers.Config.TransformFXDuration = 4

-- Distance for the teleport ability
Psykers.Config.TeleportDist = 1600

-- The range of the blush flash effect when a player uses the teleport ability
Psykers.Config.TeleportFlashRange = 300
Psykers.Config.TeleportFlashRangeSqrd = Psykers.Config.TeleportFlashRange ^ 2

-- Forcefield settings
Psykers.Config.ForcefieldColor = Color(0, 255, 255) -- The color of the forcefield
Psykers.Config.ForcefieldRadius = 100 -- The radius of the forcefield sphere
Psykers.Config.ForcefieldRefract = false -- Should the forcefield refract light
Psykers.Config.ForcefieldRainbow = false -- Should the forcefield color be rainbowed
Psykers.Config.BulletModel = "models/bullets/w_pbullet1.mdl"
Psykers.Config.BulletLife = 15 -- Frozen bullets will be removed after this time
Psykers.Config.MaxBullets = 20 -- Maximum number of bullets that can exist, if this limit is reached the oldest one will be removed

-- Sound played to all players when an ability is granted
Psykers.Config.AnnounceSound = "fo_tracks/areas/scr/mus_scr_victorysinger.ogg"

-- Body crush settings
Psykers.Config.CrushRadius = 570

-- Cooldowns
Psykers.Config.Cooldowns.Mind = 10
Psykers.Config.Cooldowns.Body = 200
Psykers.Config.Cooldowns.Soul = 300
Psykers.Config.Cooldowns.SoulDuration = 50

-- Expiry
Psykers.Config.AbilityExpiry = 1814400
Psykers.Config.ExpiryPenalty = 432000

Psykers.Config.NoBullet = {
	["keith_tracer_laser"] = true,
	["keith_tracer1_acid1"] = true,
	["effect_fo3_atomizerbeam"] = true,
	["effect_fo3_laer"] = true,
	["effect_aliendisintegrator"] = true,
	["effect_mesmetron"] = true
}

Psykers.Config.ForcefieldEnts = {
	["halo_launched_ex25"] = true,
	["cgc_missile"] = true,
	["rpg_missile"] = true,
	["fswp_40mm"] = true,
	["tfa_exp_contact"] = true,
	["fswp_25mm"] = true,
	["minilauncher_proj"] = true,
	["proj_plasmagrenade"] = true,
	["proj_sh_electricgrenade"] = true,
	["ent_explosivegrenade"] = true,
	["halo_launched_ex40lb"] = true,
	["rj_molotov"] = true
}
