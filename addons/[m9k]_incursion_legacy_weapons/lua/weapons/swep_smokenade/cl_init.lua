include('shared.lua')

SWEP.PrintName			= "Smoke Grenade"	
SWEP.Slot			= 4
SWEP.SlotPos			= 3
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false
SWEP.WepSelectIcon		= surface.GetTextureID("weapons/swep_smokenade")
SWEP.BounceWeaponIcon		= false

//Add a name for our grenade entity
language.Add( 'sent_smokenade', 'Smoke Grenade' )