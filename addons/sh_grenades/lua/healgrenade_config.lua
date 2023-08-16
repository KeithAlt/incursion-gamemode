HEALGRENADE_SETTINGS = {
	/******************
	* General Settings
	******************/

	-- How much health points to heal per tick?
	HealAmount = 4,

	-- Interval (in seconds) between 2 heal ticks.
	HealInterval = 0.5,

	-- Allow cooking? (if grenade is held unpinned for too long, explode in the player's face)
	-- This is always true in TTT.
	AllowCooking = true,

	-- Fuse time of the grenade (in seconds) before detonation
	CookTime = 4,

	-- Throw distance in units
	ThrowForce = 1250,

	-- Range of the grenade in units
	Range = 400,

	-- How long does the gas cloud remain? (in seconds)
	GasTime = 20,

	-- How long after leaving the gas cloud should a gassed player keep healing? (in seconds)
	-- Set this to 0 if you want players to only heal while in the cloud.
	AfterGasTime = 3,

	-- Allow the player to have multiple heal grenades on him?
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
