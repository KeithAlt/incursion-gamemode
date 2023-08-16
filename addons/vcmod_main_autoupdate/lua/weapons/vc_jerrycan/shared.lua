// Copyright © 2020 VCMod (freemmaann). All Rights Reserved. if you have any complaints or ideas contact me: steam - steamcommunity.com/id/freemmaann/ or email - freemmaann@gmail.com.

AddCSLuaFile("shared.lua")

SWEP.Category 		= "VCMod"
SWEP.PrintName		= "Jerry can"
SWEP.Author			= "freemmaann"
SWEP.Instructions	= "Aim at the fuel lid."

SWEP.ViewModel 		= Model("models/weapons/v_bugbait.mdl")
SWEP.WorldModel 	= Model("models/props_junk/gascan001a.mdl")
SWEP.ViewModelFOV	= 75

SWEP.Spawnable		= true
SWEP.AdminSpawnable	= true
SWEP.Slot 			= 5
SWEP.UseHands 		= true

SWEP.DrawAmmo		= true
SWEP.Primary.ClipSize		= 20
SWEP.Primary.DefaultClip	= 20
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

if CLIENT then SWEP.VC_WepSelectIcon= Material("materials/vcmod/gui/icons/fuel.png") end

SWEP.VC_Fuel = {}

if VC and !VC.CodeEnt then VC.CodeEnt = {} end

local ID = "Jerrycan_Wep"
function SWEP:Initialize(...) if VC and VC.CodeEnt[ID] and VC.CodeEnt[ID].Initialize then return VC.CodeEnt[ID].Initialize(self, ...) end end
function SWEP:Deploy(...) if VC and VC.CodeEnt[ID] and VC.CodeEnt[ID].Deploy then return VC.CodeEnt[ID].Deploy(self, ...) end return end
function SWEP:Holster(...) if VC and VC.CodeEnt[ID] and VC.CodeEnt[ID].Holster then return VC.CodeEnt[ID].Holster(self, ...) end return end
function SWEP:PrimaryAttack(...) if VC and VC.CodeEnt[ID] and VC.CodeEnt[ID].PrimaryAttack then return VC.CodeEnt[ID].PrimaryAttack(self, ...) end end
function SWEP:SecondaryAttack(...) if VC and VC.CodeEnt[ID] and VC.CodeEnt[ID].SecondaryAttack then return VC.CodeEnt[ID].SecondaryAttack(self, ...) end end
function SWEP:Think(...) if VC and VC.CodeEnt[ID] and VC.CodeEnt[ID].Think then return VC.CodeEnt[ID].Think(self, ...) end end

if CLIENT then
	function SWEP:GetViewModelPosition(...) if VC and VC.CodeEnt[ID] and VC.CodeEnt[ID].GetViewModelPosition then return VC.CodeEnt[ID].GetViewModelPosition(self, ...) end end
	function SWEP:DrawHUD(...) if VC and VC.CodeEnt[ID] and VC.CodeEnt[ID].DrawHUD then return VC.CodeEnt[ID].DrawHUD(self, ...) end end
	function SWEP:DrawWorldModel(...) if VC and VC.CodeEnt[ID] and VC.CodeEnt[ID].DrawWorldModel then return VC.CodeEnt[ID].DrawWorldModel(self, ...) end end
	function SWEP:ViewModelDrawn(...) if VC and VC.CodeEnt[ID] and VC.CodeEnt[ID].ViewModelDrawn then return VC.CodeEnt[ID].ViewModelDrawn(self, ...) end end
	function SWEP:DrawWeaponSelection(...) if VC and VC.CodeEnt.Wep_DrawSelection then return VC.CodeEnt.Wep_DrawSelection(self, ...) end end
end

if SERVER then
	function SWEP:VC_AddFuel(ftype, num) if VC and VC.CodeEnt.Jerrycan_Wep and VC.CodeEnt.Jerrycan_Wep.VC_AddFuel then return VC.CodeEnt.Jerrycan_Wep.VC_AddFuel(self, ftype, num) end end
end