include('shared.lua')

SWEP.PrintName			= "Mole Mining"					// 'Nice' Weapon name (Shown on HUD)	
SWEP.Slot				= 3							// Slot in the weapon selection menu
SWEP.SlotPos			= 1							// Position in the slot
SWEP.Instructions 		= "Press left click to start digging. You'll be put into 'Observer mode' which will allow you to fly to a desired location with pre-defined time."

// Override this in your SWEP to set the icon in the weapon selection
-- if (file.Exists("materials/weapons/weapon_mad_ak47.vmt","GAME")) then
	-- SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_mad_ak47")
-- end