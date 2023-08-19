include('shared.lua')

SWEP.PrintName			= "Fire Breath"	
SWEP.Slot			= 0
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= true
SWEP.DrawCrosshair		= false
SWEP.WepSelectIcon		= surface.GetTextureID("weapons/swep_flamethrower_d2k")
SWEP.BounceWeaponIcon		= false

//This is how clients can adjust SFX performance rate
CreateClientConVar( "flamethrower_fx", 2, false, false )