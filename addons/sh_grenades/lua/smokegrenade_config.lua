SMOKEGRENADE_SETTINGS = {
	/******************
	* General Settings
	******************/

	-- Should the grenade block line of sight? (Can't see the player's name when aiming them)
	-- This may not work for every gamemode!
	BlockLOS = true,

	-- RGB Color of the smoke cloud.
	SmokeColor = Color(70, 70, 70),

	-- Allow cooking? (if grenade is held unpinned for too long, explode in the player's face)
	-- This is always true in TTT.
	AllowCooking = true,

	-- Fuse time of the grenade (in seconds) before detonation
	CookTime = 4,

	-- Throw distance in units
	ThrowForce = 1250,

	-- Range of the grenade in units
	Range = 1200,

	-- How long does the smoke screen remain? (in seconds)
	LifeTime = 60,

	-- Allow the player to have multiple smoke grenades on him?
	AllowAmmo = true,

	/******************
	* TTT related
	******************/

	TTT = {
		-- Make the grenade available to traitors?
		-- Toggling this option on will disable grenades of this kind spawning around the map.
		TraitorsGet = true,

		-- Make the grenade available to detectives?
		-- Toggling this option on will disable grenades of this kind spawning around the map.
		DetectivesGet = false,

		-- Make the grenade stock limited? (purchase once)
		LimitedStock = false,
	},
}
