AddCSLuaFile()

CRYOGRENADE_SETTINGS = {
	/******************
	* General Settings
	******************/

	-- Should the grenade blast check for line of sight?
	-- If false, it'll freeze players through walls.
	LineOfSight = true,

	-- Allow cooking? (if grenade is held unpinned for too long, explode in the player's face)
	-- This is always true in TTT.
	AllowCooking = true,

	-- Fuse time of the grenade (in seconds) before detonation
	CookTime = 4,

	-- Throw distance in units
	ThrowForce = 1250,

	-- Range of the grenade in units
	Range = 256,

	-- Maximum time a player can remain frozen (in seconds)
	MaxFreezeTime = 6,

	-- Should the freeze time scale with the distance player-grenade?
	-- In other words, the closer the player is to the blast, the longer they'll stay frozen
	ScaleFreezeTime = true,

	-- Allow players to suicide while frozen?
	AllowFreezeSuicide = false,

	-- Allow players to TEXT chat while frozen?
	AllowPlayerTextChat = false,

	-- Allow players to VOICE chat while frozen?
	AllowPlayerVoiceChat = false,

	-- Should a player who dies while frozen explode into tiny bits of ice?
	-- Always OFF on TTT!
	ExplodeOnDeath = true,

	-- How much damage can a frozen player take before the ice breaks?
	-- a value of 0 means "don't break when taking damage"
	-- a value of 1 means "break after taking any hit"
	-- etc..
	IceHealth = 1,

	-- Should the freeze-overlay draw when frozen?
	DrawOverlay = true,

	-- Allow the player to have multiple grenades on him?
	AllowAmmo = true,

	-- Use Steam Workshop instead of FastDL for content?
	UseWorkshop = false,

	/******************
	* TTT related
	******************/

	TTT = {
		-- Make the grenade available to traitors?
		-- Toggling this option will disable grenades of this kind spawning around the map.
		TraitorsGet = false,

		-- Make the grenade available to detectives?
		-- Toggling this option will disable grenades of this kind spawning around the map.
		DetectivesGet = false,

		-- Make the grenade stock limited? (purchase once)
		LimitedStock = false,
	},

	/******************
	* Message Settings
	******************/

	-- Should the player receive a message when they get frozen?
	PrintInChat = true,

	-- Color of the chat message in RGB
	ChatMessageColor = Color(75, 255, 255),

	-- Message to display when player is frozen
	FrozenChatMessageContents = "You have been frozen by a Cryo Grenade!",

	-- Message to display when frozen player tries to talk
	CantChatMessageContents = "You are frozen! You can't talk!",
}

/** if (SERVER) then
	if (CRYOGRENADE_SETTINGS.UseWorkshop) then
		resource.AddWorkshop("696136990")
	else
		-- don't need the spawnmenu icon if we're playing TTT
		if (engine.ActiveGamemode() ~= "terrortown") then
			resource.AddSingleFile("materials/entities/weapon_sh_cryogrenade.png")
			resource.AddSingleFile("materials/weapons/weapon_sh_cryogrenade.vmt")
			resource.AddSingleFile("materials/weapons/weapon_sh_cryogrenade.vtf")
		else -- TTT specific content
			resource.AddSingleFile("materials/vgui/ttt/icon_cryogrenade.vmt")
			resource.AddSingleFile("materials/vgui/ttt/icon_cryogrenade.vtf")
		end

		resource.AddSingleFile("materials/models/weapons/v_models/eq_cryogrenade/cryogrenade.vmt")
		resource.AddSingleFile("materials/models/weapons/v_models/eq_cryogrenade/cryogrenade.vtf")
		resource.AddSingleFile("materials/models/weapons/v_models/eq_cryogrenade/cryogrenade_ref.vtf")
		resource.AddSingleFile("materials/overlays/vignette_frozen.vmt")
		resource.AddSingleFile("materials/overlays/vignette_frozen.vtf")
	end
end **/
