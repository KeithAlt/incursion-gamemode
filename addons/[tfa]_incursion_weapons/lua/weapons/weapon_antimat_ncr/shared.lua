SWEP.PrintName = "Anti Materiel Rifle"
SWEP.Author = "Lenny"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""

SWEP.Category = "Fallout SWEPs - Sniper Rifles"

--[[VIEWMODEL BLOWBACK]]--
SWEP.BlowbackEnabled = true --Enable Blowback?
SWEP.BlowbackVector = Vector(0,-2.5,0) --Vector to move bone <or root> relative to bone <or view> orientation.
SWEP.BlowbackCurrentRoot = 0 --Amount of blowback currently, for root
SWEP.BlowbackCurrent = 0 --Amount of blowback currently, for bones
SWEP.Blowback_Only_Iron = true --Only do blowback on ironsights
SWEP.Blowback_PistolMode = true --Do we recover from blowback when empty?
SWEP.Blowback_Shell_Enabled = true --Shoot shells through blowback animations
SWEP.Blowback_Shell_Effect = "RifleShellEject"--Which shell effect to use

SWEP.Spawnable= true
SWEP.AdminSpawnable= true
SWEP.AdminOnly = false
SWEP.CSMuzzleFlashes = true

SWEP.MuzzleAttachment           = "1"       -- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.ShellAttachment            = "2"       -- Should be "2" for CSS models or "shell" for hl2 models
SWEP.MuzzleFlashEnabled = true --Enable muzzle flash
SWEP.MuzzleAttachmentRaw = nil --This will override whatever string you gave.  This is the raw attachment number.  This is overridden or created when a gun makes a muzzle event.
SWEP.AutoDetectMuzzleAttachment = false --For multi-barrel weapons, detect the proper attachment?
SWEP.MuzzleFlashEffect = "tfa_doomssg_muzzle"
SWEP.SmokeParticle = nil --Smoke particle (ID within the PCF), defaults to something else based on holdtype; "" to disable
SWEP.EjectionSmokeEnabled = true --Disable automatic ejection smoke

SWEP.TracerName         = "AR2Tracer"   --Change to a string of your tracer name.  Can be custom. There is a nice example at https://github.com/garrynewman/garrysmod/blob/master/garrysmod/gamemodes/base/entities/effects/tooltracer.lua
SWEP.TracerCount        = 1     --0 disables, otherwise, 1 in X chance
--Impact Effects
SWEP.ImpactEffect = "TracerSound"--Impact Effect
SWEP.ImpactDecal = nil--Impact Decal


SWEP.MuzzleAttachment = 1
SWEP.ShellAttachment = 2

SWEP.HoldType = "ar2"
SWEP.ViewModelFOV = 45
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/antimaterielrifle/c_antimaterial_reworked_len.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false

SWEP.WElements = {
	["antimat"] = { type = "Model", model = "models/weapons/antimaterielrifle/c_antimaterial_reworked_len.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(-5.965, 3.966, -5.634), angle = Angle(-4.805, 0, 180), size = Vector(0.787, 0.787, 0.787), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.Type = "Sniper Rifle"

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true

SWEP.Slot = 4
SWEP.SlotPos = 1

SWEP.UseHands = true

SWEP.FiresUnderwater = true

SWEP.DrawCrosshair = true

SWEP.DrawAmmo = true

SWEP.Base = "tfa_gun_base"

--Recoil Related
SWEP.Primary.KickUp = 0 -- This is the maximum upwards recoil (rise)
SWEP.Primary.KickHorizontal = 0
SWEP.Primary.StaticRecoilFactor = 0.5 --Amount of recoil to directly apply to EyeAngles.  Enter what fraction or percentage (in decimal form) you want.  This is also affected by a convar that defaults to 0.5.
--Firing Cone Related
SWEP.Primary.Spread = 0.1 --This is hip-fire acuracy.  Less is more (1 is horribly awful, .0001 is close to perfect)
SWEP.Primary.IronAccuracy = .0000001 -- Ironsight accuracy, should be the same for shotguns
--Unless you can do this manually, autodetect it.  If you decide to manually do these, uncomment this block and remove this line.
SWEP.Primary.SpreadMultiplierMax = 0 --How far the spread can expand when you shoot. Example val: 2.5
SWEP.Primary.SpreadIncrement = 0--What percentage of the modifier is added on, per shot.  Example val: 1/3.5
SWEP.Primary.SpreadRecovery = 0 --How much the spread recovers, per second. Example val: 3
--Range Related
SWEP.Primary.Range = (25000 * 32) -- The distance the bullet can travel in source units.  Set to -1 to autodetect based on damage/rpm.
SWEP.Primary.RangeFalloff = 1 -- The percentage of the range the bullet damage starts to fall off at.  Set to 0.8, for example, to start falling off after 80% of the range.
--Misc
SWEP.CrouchAccuracyMultiplier = 1 --Less is more.  Accuracy * 0.5 = Twice as accurate, Accuracy * 0.1 = Ten times as accurate
--Movespeed
SWEP.MoveSpeed = 1 --Multiply the player's movespeed by this.
SWEP.IronSightsMoveSpeed = 0.5 --Multiply the player's movespeed by this when sighting.

SWEP.IronSightTime = 0
SWEP.VMPos = Vector(0, 0, 0)
SWEP.VMAng = Vector(0,0,0)
SWEP.VMPos_Additive = false --Set to false for an easier time using VMPos. If true, VMPos will act as a constant delta ON TOP OF ironsights, run, whateverelse

SWEP.Primary.Sound = Sound("weapons/antimat/fire.wav")
SWEP.Primary.Damage = 140
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 5
SWEP.Primary.Ammo = "50MG"
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Recoil = 3
SWEP.Primary.RPM = 40
SWEP.Primary.RPM_Semi = 40
SWEP.Primary.Force = 1
SWEP.Primary.ReloadSound = Sound("weapons/antimat/reload.wav")
SWEP.PercentageDamage = .05
SWEP.Primary.DamageTypeHandled = true
SWEP.Primary.DamageType = DMG_BULLET

SWEP.Primary.HullSize = 3 -- Makes bullet hitscan bigger, usually good for snipers whom have hitreg issues - don't increase more than 3 - Lenny

SWEP.Primary.PenetrationMultiplier = 1 --Change the amount of something this gun can penetrate through
SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 5
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"


--[[INSPECTION]]--
SWEP.InspectPos = Vector(8.972, 7.366, -0.29)
SWEP.InspectAng = Vector(5.958, 22.461, 8.067)

SWEP.IronSightsPos = Vector(-3.05, 0, 1)
SWEP.IronSightsAng = Vector(-0.424, 0, 0)

SWEP.Scoped = true --Draw a scope overlay?
SWEP.ScopeOverlayThreshold = 0.875 --Percentage you have to be sighted in to see the scope.
SWEP.BoltTimerOffset = 0.25 --How long you stay sighted in after shooting, with a bolt action.
SWEP.ScopeScale = 0.6 --Scale of the scope overlay
SWEP.ReticleScale = 0.7 --Scale of the reticle overlay
--GDCW Overlay Options.  Only choose one.
SWEP.Secondary.UseACOG = false --Overlay option
SWEP.Secondary.UseMilDot = false --Overlay option
SWEP.Secondary.UseSVD = false --Overlay option
SWEP.Secondary.UseParabolic = true --Overlay option
SWEP.Secondary.UseElcan = false --Overlay option
SWEP.Secondary.UseGreenDuplex = false
SWEP.Secondary.IronFOV = 10


--[[SPRINTING]]--
SWEP.RunSightsPos = Vector(4, 0, 0)
SWEP.RunSightsAng = Vector(-7.914, 24.142, 0)
