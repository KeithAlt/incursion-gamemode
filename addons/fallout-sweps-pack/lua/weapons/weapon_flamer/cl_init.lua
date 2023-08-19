include('shared.lua')

SWEP.PrintName			= "Flamer"	
SWEP.Slot			= 4
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true
SWEP.BounceWeaponIcon		= false

//This is how clients can adjust SFX performance rate
CreateClientConVar( "flamethrower_fx", 2, false, false )