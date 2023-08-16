SWEP.Base = "dangumeleebase"

SWEP.AdminSpawnable = true

SWEP.AutoSwitchTo = false
SWEP.Slot = 0
SWEP.PrintName = "Fists"
SWEP.Author = "danguyen"
SWEP.Spawnable = true
SWEP.AutoSwitchFrom = false
SWEP.Weight = 5
SWEP.Category = "Melee Arts 2"
SWEP.SlotPos = 1
 
SWEP.Purpose = "Fight like men!"

SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/models/danguyen/c_smodpunch.mdl"
SWEP.WorldModel = ""
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.UseHands = true

--STAT RATING (1-6)
SWEP.Type=3 --1: Blade, 2: Axe, 3:Bludgeon, 4: Spear
SWEP.Strength=1 -- 1-2: Small Weapons, 3-4: Medium Weapons (e.g crowbar), 5-6: Heavy Weapons (e.g Sledgehammers and Greatswords). Strength affects throwing distance and force
SWEP.Speed=2 -- 1-2: Slow, 3-4: Decent, 5-6: Fast
SWEP.Tier=1 -- General rating based on how good/doodoo the weapon is

--SWEPs are dumb (or I am) so we must state the weapon name again
SWEP.WepName="meleearts_bludgeon_fists"

--Stamina Costs
SWEP.PriAtkStamina=5
SWEP.ThrowStamina=5
SWEP.BlockStamina=5
SWEP.ShoveStamina=5

--Primary Attack Charge Values
SWEP.Charge = 0
SWEP.ChargeSpeed = 0.2
SWEP.DmgMin = 3
SWEP.DmgMax = 10
SWEP.Delay = 0.65
SWEP.TimeToHit = 0.02
SWEP.AttackAnimRate = 1.1
SWEP.Range = 60
SWEP.Punch1 = Angle(-2, 0, 0)
SWEP.Punch2 = Angle(5, 0, -2)
SWEP.HitFX = ""
SWEP.HitFX2 = ""
SWEP.IdleAfter = true
--Throwing Attack Charge Values
SWEP.CanThrow = false
SWEP.Charge2 = 0
SWEP.ChargeSpeed2 = 0
SWEP.DmgMin2 = 0
SWEP.DmgMax2 = 0
SWEP.ThrowModel = ""
SWEP.ThrowMaterial = ""
SWEP.ThrowScale = 0
SWEP.ThrowForce = 0

--HOLDTYPES
SWEP.AttackHoldType="melee"
SWEP.Attack2HoldType="fist"
SWEP.ChargeHoldType="melee"
SWEP.IdleHoldType="fist"
SWEP.BlockHoldType="camera"
SWEP.ShoveHoldType="fist"
SWEP.ThrowHoldType="grenade"

--SOUNDS
SWEP.SwingSound="WeaponFrag.Throw"
SWEP.ThrowSound="weapons/iceaxe/iceaxe_swing1.wav"
SWEP.Hit1Sound="physics/body/body_medium_impact_hard1.wav"
SWEP.Hit2Sound="physics/body/body_medium_impact_hard2.wav"
SWEP.Hit3Sound="physics/body/body_medium_impact_hard3.wav"

SWEP.Impact1Sound="physics/body/body_medium_impact_hard5.wav"
SWEP.Impact2Sound="physics/body/body_medium_impact_hard6.wav"

SWEP.ViewModelBoneMods = {
["ValveBiped.Bip01_R_Clavicle"] = { scale = Vector(1, 1, 1), pos = Vector(0, -6.853, -2.037), angle = Angle(0, 0, 0) }
}


SWEP.NextFireShove = 0
SWEP.NextFireBlock = 0
SWEP.NextStun = 0

SWEP.DefSwayScale 	= 1.0
SWEP.DefBobScale 	= 1.0

SWEP.StunPos = Vector(0,0,0)
SWEP.StunAng = Vector(-14.07, 0, 2.111)

SWEP.ShovePos = Vector(-9.849, -4.02, -0.202)
SWEP.ShoveAng = Vector(34.472, 49.95, -32.362)

SWEP.RollPos = Vector(0,0,0)
SWEP.RollAng = Vector(-33.065, 0, 0)

SWEP.WhipPos = Vector(0, -8.242, 1.004)
SWEP.WhipAng = Vector(-10.554, -42.211, 14.774)

SWEP.FanPos = Vector(1.21, -10.051, 1.004)
SWEP.FanAng = Vector(38.693, -24.623, -3.518)

SWEP.WallPos = Vector(-0.601, -11.056, -9.65)
SWEP.WallAng = Vector(42.915, 0, 0)

function SWEP:AttackAnimation()
self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
return end
function SWEP:AttackAnimation2()
self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
end
function SWEP:AttackAnimation3()
self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
end


SWEP.VElements = {
}
SWEP.WElements = {
}
