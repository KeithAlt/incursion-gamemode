-- Variables that are used on both client and server
SWEP.Gun = ("weapon_grenadepulse")
SWEP.Category				= "Fallout Sweps - Explosive Weapons"
SWEP.Author				= ""
SWEP.Contact				= ""
SWEP.Purpose				= ""
SWEP.Instructions				= ""
SWEP.MuzzleAttachment			= "1" 	-- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.ShellEjectAttachment			= "2" 	-- Should be "2" for CSS models or "1" for hl2 models
SWEP.PrintName				= "Pulse Grenade"		-- Weapon name (Shown on HUD)
SWEP.Slot				= 4				-- Slot in the weapon selection menu
SWEP.SlotPos				= 21			-- Position in the slot
SWEP.DrawAmmo				= true		-- Should draw the default HL2 ammo counter
SWEP.DrawWeaponInfoBox			= false		-- Should draw the weapon info box
SWEP.BounceWeaponIcon   		= 	false	-- Should the weapon icon bounce?
SWEP.DrawCrosshair			= false		-- set false if you want no crosshair
SWEP.Weight 				= 5		-- rank relative ot other weapons. bigger is better
SWEP.AutoSwitchTo			= true		-- Auto switch to if we pick it up
SWEP.AutoSwitchFrom			= true		-- Auto switch from if you pick up a better weapon
-- normal melee melee2 fist knife smg ar2 pistol rpg physgun grenade shotgun crossbow slam passive
-- you're mostly going to use ar2, smg, shotgun or pistol. rpg and ar2 make for good sniper rifles

SWEP.HoldType			 = "grenade"
SWEP.ViewModelFOV 		= 180
SWEP.ViewModelFlip 		= true
SWEP.ViewModel 			= "models/halokiller38/fallout/weapons/explosives/stungrenade.mdl"
SWEP.WorldModel 		= "models/halokiller38/fallout/weapons/explosives/stungrenade.mdl"
SWEP.ShowViewModel 		= true
SWEP.ShowWorldModel 	= false
SWEP.Base				= "boh_nade_base"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true
SWEP.FiresUnderwater 	= true

SWEP.Primary.Sound			= Sound("")		-- Script that calls the primary fire sound
SWEP.Primary.RPM				= 30		-- This is in Rounds Per Minute
SWEP.Primary.ClipSize			= 1		-- Size of a clip
SWEP.Primary.DefaultClip		= 1		-- Bullets you start with
SWEP.Primary.KickUp				= 0		-- Maximum up recoil (rise)
SWEP.Primary.KickDown			= 0		-- Maximum down recoil (skeet)
SWEP.Primary.KickHorizontal		= 0		-- Maximum up recoil (stock)
SWEP.Primary.Automatic			= false		-- Automatic = true; Semi Auto = false
SWEP.Primary.Ammo			= "PulseGrenade"
-- pistol, 357, smg1, ar2, buckshot, slam, SniperPenetratedRound, AirboatGun
-- Pistol, buckshot, and slam always ricochet. Use AirboatGun for a metal peircing shotgun slug

SWEP.Primary.Round 			= ("proj_sh_electricgrenade")	--NAME OF ENTITY GOES HERE

SWEP.Secondary.IronFOV		= 0		-- How much you 'zoom' in. Less is more!
SWEP.Primary.NumShots		= 0		-- How many bullets to shoot per trigger pull
SWEP.Primary.Damage			= 0	-- Base damage per bullet
SWEP.Primary.Spread			= 0	-- Define from-the-hip accuracy (1 is terrible, .0001 is exact)
SWEP.Primary.IronAccuracy 	= 0 -- Ironsight accuracy, should be the same for shotguns

SWEP.VElements = {
	["grenade"] = { type = "Model", model = "models/halokiller38/fallout/weapons/explosives/stungrenade.mdl", bone = "v_weapon.Flashbang_Parent", rel = "", pos = Vector(3.835, -4.486, 0), angle = Angle(0.228, -9.11, 90.253), size = Vector(0.786, 0.786, 0.786), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
	["grenade"] = { type = "Model", model = "models/halokiller38/fallout/weapons/explosives/stungrenade.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(8.305, 2.204, 5.156), angle = Angle(180, 180, 0), size = Vector(1.302, 1.302, 1.302), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.ViewModelBoneMods 	= {}
