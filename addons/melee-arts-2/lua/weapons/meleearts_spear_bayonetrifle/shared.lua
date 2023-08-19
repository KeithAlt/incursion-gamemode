SWEP.Base = "dangumeleebase"

SWEP.AdminSpawnable = true

SWEP.AutoSwitchTo = false
SWEP.Slot = 0
SWEP.PrintName = "Bayonet Rifle"
SWEP.Author = "danguyen"
SWEP.Spawnable = true
SWEP.AutoSwitchFrom = false
SWEP.Weight = 5
SWEP.Category = "Melee Arts 2"
SWEP.SlotPos = 1
 
SWEP.Purpose = "No ammo, but it's got a big knife at the end of it"

SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/models/danguyen/v_me_sledge.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.UseHands = true

--STAT RATING (1-6)
SWEP.Type=4 --1: Blade, 2: Axe, 3:Bludgeon, 4: Spear
SWEP.Strength=2 -- 1-2: Small Weapons, 3-4: Medium Weapons (e.g crowbar), 5-6: Heavy Weapons (e.g Sledgehammers and Greatswords). Strength affects throwing distance and force
SWEP.Speed=2 -- 1-2: Slow, 3-4: Decent, 5-6: Fast
SWEP.Tier=2 -- General rating based on how good/doodoo the weapon is

--SWEPs are dumb (or I am) so we must state the weapon name again
SWEP.WepName="meleearts_spear_bayonetrifle"

--Stamina Costs
SWEP.PriAtkStamina=5
SWEP.ThrowStamina=5
SWEP.BlockStamina=5
SWEP.ShoveStamina=5

--Primary Attack Charge Values
SWEP.Charge = 0
SWEP.ChargeSpeed = 0.3
SWEP.DmgMin = 9
SWEP.DmgMax = 20
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
SWEP.DmgMin2 = 7
SWEP.DmgMax2 = 22
SWEP.ThrowModel = "models/models/danguyen/kar98.mdl"
SWEP.ThrowMaterial = ""
SWEP.ThrowScale = 1
SWEP.ThrowForce = 1400
SWEP.FixedThrowAng = Angle(0,180,0)
SWEP.SpinAng = Vector(1500,0,0)


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

SWEP.Impact1Sound="physics/metal/weapon_impact_hard1.wav"
SWEP.Impact2Sound="physics/metal/weapon_impact_hard2.wav"
SWEP.ViewModelBoneMods = {
	["Index1"] = { scale = Vector(1, 1, 1), pos = Vector(0, -0.101, 0.851), angle = Angle(0, 0, 0) },
	["v_me_sledge"] = { scale = Vector(0.112, 0.112, 0.112), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Middle1"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0.851), angle = Angle(0, 0, 0) },
	["Ring1"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0.1, 0.925), angle = Angle(0, 0, 0) },
	["Pinky1"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0.187, 1), angle = Angle(0, 0, 0) },
	["Thumb2"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-10, 0, 0) },
	["Thumb1"] = { scale = Vector(1, 1, 1), pos = Vector(0, -1.193, 0), angle = Angle(5.556, 46.125, 1.023) }
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

SWEP.WhipPos = Vector(-19.341, -13.898, 3.569)
SWEP.WhipAng = Vector(-12.488, -80, 1.972)

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
self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
end


SWEP.VElements = {
	["spear"] = { type = "Model", model = "models/models/danguyen/kar98.mdl", bone = "v_me_sledge", rel = "", pos = Vector(3.635, 0, -5.715), angle = Angle(-90, 0, 180), size = Vector(0.755, 0.755, 0.755), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["spear"] = { type = "Model", model = "models/models/danguyen/kar98.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.381, 1, 1.429), angle = Angle(172.5, 0, 0), size = Vector(0.813, 0.813, 0.813), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}