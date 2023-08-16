ELECTRICGRENADE_SETTINGS = {
	/******************
	* General Settings
	******************/

	-- How much damage to deal per tick?
	Damage = 4,

	-- Interval (in seconds) between 2 damage ticks.
	DamageInterval = 0.5,

	-- How long should the player stay stunned after being hit by one shock of the grenade?
	-- Ideally, should be lower than the damage interval so people aren't stun locked.
	-- Set to 0 for no stun.
	StunTime = 0.2,

	-- Should the player's screen flash when hit by one shock of the grenade?
	FlashScreen = true,

	-- Should the player do an arm flailing animation when hit by one shock of the grenade?
	FlailArms = true,

	-- Should the grenade emit sound?
	EmitSounds = true,

	-- Allow cooking? (if grenade is held unpinned for too long, explode in the player's face)
	-- This is always true in TTT.
	AllowCooking = true,

	-- Fuse time of the grenade (in seconds) before detonation
	CookTime = 4,

	-- Throw distance in units
	ThrowForce = 1250,

	-- Range of the grenade in units
	Range = 400,

	-- How long should the grenade stay active? (in seconds)
	LifeTime = 20,

	-- Allow the player to have multiple electric grenades on him?
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
