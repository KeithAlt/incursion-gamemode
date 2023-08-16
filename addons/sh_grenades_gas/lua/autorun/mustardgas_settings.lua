AddCSLuaFile()

MUSTARDGAS_SETTINGS = {
	/******************
	* General Settings
	******************/

	-- How much damage to deal per tick?
	Damage = 10,

	-- Interval (in seconds) between 2 damage ticks.
	DamageInterval = 1,

	-- Allow cooking? (if grenade is held unpinned for too long, explode in the player's face)
	-- This is always true in TTT.
	AllowCooking = true,

	-- Fuse time of the grenade (in seconds) before detonation
	CookTime = 4,

	-- Throw distance in units
	ThrowForce = 1250,

	-- Range of the grenade in units
	Range = 768,

	-- How long does the gas cloud remain? (in seconds)
	GasTime = 20,

	-- How long after leaving the gas cloud should a gassed player keep taking damage? (in seconds)
	-- Set this to 0 if you want players to only take damage while in the cloud.
	AfterGasTime = 7,

	-- Allow the player to have multiple grenades on him?
	AllowAmmo = true,

	-- Use Steam Workshop instead of FastDL for content?
	UseWorkshop = false,

	/******************
	* Effect settings
	******************/

	-- How long does the effects of being gassed remain after leaving a gas cloud? (in seconds)
	GasRemainTime = 5,

	-- Should gassed players cough?
	EnableCoughing = true,

	-- Enable motion blur when gassed?
	MotionBlur = true,

	-- Enable bloom when gassed?
	Bloom = true,

	-- Enable color modification when gassed?
	ColorModify = true,

	-- Enable screen stagger (random movement) when gassed?
	Stagger = true,

	-- Enable breathing sound when wearing a gas mask + standing in a gas cloud?
	BreathingSound = true,

	/******************
	* TTT related
	******************/

	TTT = {
		-- Make the grenade available to traitors?
		-- Toggling this option will disable grenades of this kind spawning around the map.
		TraitorsGet = true,

		-- Make the grenade available to detectives?
		-- Toggling this option will disable grenades of this kind spawning around the map.
		DetectivesGet = false,

		-- Make the grenade stock limited? (purchase once)
		LimitedStock = false,

		-- Allow traitors/detectives to purchase the Gas Mask? (protects from gas damage)
		TraitorsGasMask = true,
		DetectivesGasMask = true,
	},
}

/** if (SERVER) then
	if (MUSTARDGAS_SETTINGS.UseWorkshop) then
		resource.AddWorkshop("699797420")
	else
		-- don't need the spawnmenu icon if we're playing TTT
		if (engine.ActiveGamemode() ~= "terrortown") then
			resource.AddSingleFile("materials/entities/item_sh_gasmask.png")
			resource.AddSingleFile("materials/entities/weapon_sh_mustardgas.png")
			resource.AddSingleFile("materials/weapons/weapon_sh_mustardgas.vmt")
			resource.AddSingleFile("materials/weapons/weapon_sh_mustardgas.vtf")
		else -- TTT specific content
			resource.AddSingleFile("materials/vgui/ttt/icon_gasmask.vmt")
			resource.AddSingleFile("materials/vgui/ttt/icon_gasmask.vtf")
			resource.AddSingleFile("materials/vgui/ttt/icon_mustardgas.vmt")
			resource.AddSingleFile("materials/vgui/ttt/icon_mustardgas.vtf")
		end

		resource.AddSingleFile("materials/models/weapons/v_models/eq_mustardgas/mustardgas.vmt")
		resource.AddSingleFile("materials/models/weapons/v_models/eq_mustardgas/mustardgas.vtf")
		resource.AddSingleFile("materials/models/weapons/v_models/eq_mustardgas/mustardgas_ref.vtf")
	end
end **/
