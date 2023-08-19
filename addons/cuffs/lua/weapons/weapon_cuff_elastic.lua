-------------------------------------
---------------- Cuffs --------------
-------------------------------------
-- Copyright (c) 2015 Nathan Healy --
-------- All rights reserved --------
-------------------------------------
-- weapon_cuff_elastic.lua  SHARED --
--                                 --
-- Elastic handcuffs.              --
-------------------------------------

AddCSLuaFile()

SWEP.Base = "weapon_cuff_base"

SWEP.Category = "Handcuffs"
SWEP.Author = "my_hat_stinks"
SWEP.Instructions = "Stretchable restraint."

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.AdminSpawnable = true

SWEP.Slot = 3
SWEP.PrintName = "Handcuffs"

//
// Handcuff Vars
SWEP.CuffTime = 3 // Seconds to handcuff
SWEP.CuffSound = Sound( "buttons/lever7.wav" )

SWEP.CuffMaterial = "models/props_foliage/tree_deciduous_01a_trunk"
SWEP.CuffRope = "cable/rope"
SWEP.CuffStrength = 3
SWEP.CuffRegen = 0.01
SWEP.RopeLength = 40

SWEP.CuffReusable = true
SWEP.CuffRecharge = 5

SWEP.CuffBlindfold = true
SWEP.CuffGag = true

--SWEP.CuffStrengthVariance = 0.1 // Randomise strength
--SWEP.CuffRegenVariance = 0.15 // Randomise regen
