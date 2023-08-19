SWEP.Base = "dangumeleebase"

SWEP.AdminSpawnable = true

SWEP.AutoSwitchTo = false
SWEP.Slot = 0
SWEP.PrintName = "Yari"
SWEP.Author = "danguyen"
SWEP.Spawnable = true
SWEP.AutoSwitchFrom = false
SWEP.Weight = 5
SWEP.Category = "Melee Arts 2"
SWEP.SlotPos = 1
 
SWEP.Purpose = "Sōjutsu!"

SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/models/danguyen/v_me_sledge.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.UseHands = true

--STAT RATING (1-6)
SWEP.Type=4 --1: Blade, 2: Axe, 3:Bludgeon, 4: Spear
SWEP.Strength=3 -- 1-2: Small Weapons, 3-4: Medium Weapons (e.g crowbar), 5-6: Heavy Weapons (e.g Sledgehammers and Greatswords). Strength affects throwing distance and force
SWEP.Speed=3 -- 1-2: Slow, 3-4: Decent, 5-6: Fast
SWEP.Tier=3 -- General rating based on how good/doodoo the weapon is

--SWEPs are dumb (or I am) so we must state the weapon name again
SWEP.WepName="meleearts_spear_basic"

--Stamina Costs
SWEP.PriAtkStamina=5
SWEP.ThrowStamina=5
SWEP.BlockStamina=5
SWEP.ShoveStamina=5

--Primary Attack Charge Values
SWEP.Charge = 0
SWEP.ChargeSpeed = 0.4
SWEP.DmgMin = 10
SWEP.DmgMax = 27
SWEP.Delay = 1.1
SWEP.TimeToHit = 0.08
SWEP.AttackAnimRate = 1.5
SWEP.Range = 75
SWEP.Punch1 = Angle(-2, 0, 2)
SWEP.Punch2 = Angle(2, 0, 0)
SWEP.HitFX = "bloodsplat"
SWEP.IdleAfter = true
--Throwing Attack Charge Values
SWEP.Charge2 = 0
SWEP.ChargeSpeed2 = 0.5
SWEP.DmgMin2 = 8
SWEP.DmgMax2 = 30
SWEP.ThrowModel = "models/models/danguyen/silver_knight_spear.mdl"
SWEP.ThrowMaterial = ""
SWEP.ThrowScale = 0.7
SWEP.ThrowForce = 1200
SWEP.FixedThrowAng = Angle(0,90,0)
SWEP.SpinAng = Vector(0,0,0)

--HOLDTYPES
SWEP.AttackHoldType="shotgun"
SWEP.Attack2HoldType="knife"
SWEP.ChargeHoldType="shotgun"
SWEP.IdleHoldType="slam"
SWEP.BlockHoldType="fist"
SWEP.ShoveHoldType="fist"
SWEP.ThrowHoldType="grenade"

--SOUNDS
SWEP.SwingSound="WeaponFrag.Throw"
SWEP.ThrowSound="spearthrow.mp3"
SWEP.Hit1Sound="ambient/machines/slicer4.wav"
SWEP.Hit2Sound="ambient/machines/slicer2.wav"
SWEP.Hit3Sound="ambient/machines/slicer4.wav"

SWEP.Impact1Sound="physics/metal/metal_solid_impact_hard4.wav"
SWEP.Impact2Sound="physics/metal/metal_solid_impact_hard5.wav"

SWEP.ViewModelBoneMods = {
	["v_me_sledge"] = { scale = Vector(0.037, 0.037, 0.037), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}


SWEP.NextFireShove = 0
SWEP.NextFireBlock = 0
SWEP.NextStun = 0

SWEP.DefSwayScale 	= 1.0
SWEP.DefBobScale 	= 1.0

SWEP.StunPos = Vector(-6.835, -1.609, 4.421)
SWEP.StunAng = Vector(0, -34.473, -37.286)

SWEP.ShovePos = Vector(0, -5.829, 0)
SWEP.ShoveAng = Vector(28.141, 52.763, -0.704)

SWEP.RollPos = Vector(0,0,0)
SWEP.RollAng = Vector(-33.065, 0, 0)

SWEP.WhipPos = Vector(-20, -18.493, 7.236)
SWEP.WhipAng = Vector(0, -85, -19.698)

SWEP.ThrowPos = Vector(1.004, -15.879, 5.225)
SWEP.ThrowAng = Vector(70, -70, -90)

SWEP.FanPos = Vector(-1.81, -6.031, 0.4)
SWEP.FanAng = Vector(18.291, 0.703, -15.478)

SWEP.WallPos = Vector(-0.601, -11.056, -9.65)
SWEP.WallAng = Vector(42.915, 0, 0)

function SWEP:AttackAnimation()
self.AttackAnimRate = 1.3
self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
end
function SWEP:AttackAnimation2()
self.AttackAnimRate = 1.3
self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
end
function SWEP:AttackAnimation3()
self.Weapon:SendWeaponAnim( ACT_VM_HITRIGHT )
end


SWEP.VElements = {
	["spear"] = { type = "Model", model = "models/models/danguyen/silver_knight_spear.mdl", bone = "v_me_sledge", rel = "", pos = Vector(0.819, 0, -18.182), angle = Angle(0, -68.961, -87.663), size = Vector(0.625, 0.432, 0.625), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
	["harpoon"] = { type = "Model", model = "models/models/danguyen/silver_knight_spear.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(-6.753, 0, 1.557), angle = Angle(-160.131, 80.649, -12.858), size = Vector(0.625, 0.56, 0.625), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}