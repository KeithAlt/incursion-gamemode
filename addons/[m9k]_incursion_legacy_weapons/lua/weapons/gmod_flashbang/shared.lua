
resource.AddFile( "materials/vgui/entities/gmod_flashbang.vmt" )
resource.AddFile( "materials/vgui/entities/gmod_flashbang.vtf" )

if (SERVER) then --the init.lua stuff goes in here
   AddCSLuaFile ("shared.lua")
end

if (CLIENT) then --the init.lua stuff goes in here


	SWEP.PrintName = "Flashbang"
	SWEP.SlotPos = 2
	SWEP.IconLetter			= "g"
	SWEP.NameOfSWEP			= "weapon_ttt_flashbang" --always make this the name of the folder the SWEP is in.
	
	SWEP.EquipMenuData = {
	   type = "item_weapon",
	   desc = "Flashbang against Player's / NPC's"
   };

end

SWEP.Grenade = "gmod_thrownflashbang"

local here = true
SWEP.Author = "Converted by Porter"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Base = "baseflashbang"

SWEP.ViewModel			= "models/weapons/v_eq_flashbang.mdl"
SWEP.WorldModel			= "models/weapons/w_eq_flashbang.mdl"
SWEP.ViewModelFlip		= true
SWEP.AutoSwitchFrom		= true

SWEP.DrawCrosshair		= false

SWEP.IsGrenade = true
SWEP.NoSights = true

SWEP.was_thrown = false

SWEP.LimitedStock = false

SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:GetGrenadeName()
   return "gmod_thrownflashbang"
end