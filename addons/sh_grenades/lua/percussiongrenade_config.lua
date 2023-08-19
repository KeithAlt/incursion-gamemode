PERCUSSIONGRENADE_SETTINGS = {
	/******************
	* General Settings
	******************/

	-- How much damage should the explosion deal?
	Damage = 65,

	-- Radius of the explosion in units
	Radius = 128,

	-- Throw distance in units
	ThrowForce = 1250,

	-- Allow the player to have multiple percussion grenades on him?
	AllowAmmo = true,

	-- Play the default explosion sound instead of a custom one
	DefaultExplosionSound = false,

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
