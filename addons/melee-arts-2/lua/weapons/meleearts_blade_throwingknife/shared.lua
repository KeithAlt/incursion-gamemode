SWEP.Base = "dangumeleebase"

SWEP.AdminSpawnable = true

SWEP.AutoSwitchTo = false
SWEP.Slot = 0
SWEP.PrintName = "Bowie Knife"
SWEP.Author = "danguyen"
SWEP.Spawnable = true
SWEP.AutoSwitchFrom = false
SWEP.Weight = 5
SWEP.Category = "Melee Arts 2"
SWEP.SlotPos = 1
 
SWEP.Purpose = "Named after the famous singer, it's big and will hurt a lot."

SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/models/danguyen/c_xiandagger.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.UseHands = true

--STAT RATING (1-6)
SWEP.Type=1 --1: Blade, 2: Axe, 3:Bludgeon, 4: Spear
SWEP.Strength=2 -- 1-2: Small Weapons, 3-4: Medium Weapons (e.g crowbar), 5-6: Heavy Weapons (e.g Sledgehammers and Greatswords). Strength affects throwing distance and force
SWEP.Speed=4 -- 1-2: Slow, 3-4: Decent, 5-6: Fast
SWEP.Tier=3 -- General rating based on how good/doodoo the weapon is

--SWEPs are dumb (or I am) so we must state the weapon name again
SWEP.WepName="meleearts_blade_throwingknife"

--Stamina Costs
SWEP.PriAtkStamina=5
SWEP.ThrowStamina=5
SWEP.BlockStamina=5
SWEP.ShoveStamina=5

--Primary Attack Charge Values
SWEP.Charge = 0
SWEP.ChargeSpeed = 0.35
SWEP.DmgMin = 7
SWEP.DmgMax = 22
SWEP.Delay = 0.65
SWEP.TimeToHit = 0.08
SWEP.AttackAnimRate = 1.2
SWEP.Range = 55
SWEP.Punch1 = Angle(0, 5, 0)
SWEP.Punch2 = Angle(0, -5, 5)
SWEP.HitFX = "bloodsplat"
SWEP.IdleAfter = true
--Throwing Attack Charge Values
SWEP.Charge2 = 0
SWEP.ChargeSpeed2 = 0.8
SWEP.DmgMin2 = 5
SWEP.DmgMax2 = 20
SWEP.ThrowModel = "models/models/danguyen/commandoknife.mdl"
SWEP.ThrowMaterial = ""
SWEP.ThrowScale = 1
SWEP.ThrowForce = 1200

--HOLDTYPES
SWEP.AttackHoldType="melee"
SWEP.Attack2HoldType="knife"
SWEP.ChargeHoldType="melee"
SWEP.IdleHoldType="knife"
SWEP.BlockHoldType="camera"
SWEP.ShoveHoldType="fist"
SWEP.ThrowHoldType="grenade"

--SOUNDS
SWEP.SwingSound="weapons/iceaxe/iceaxe_swing1.wav"
SWEP.ThrowSound="knifethrow.mp3"
SWEP.Hit1Sound="ambient/machines/slicer4.wav"
SWEP.Hit2Sound="ambient/machines/slicer4.wav"
SWEP.Hit3Sound="ambient/machines/slicer4.wav"

SWEP.Impact1Sound="physics/metal/weapon_impact_hard1.wav"
SWEP.Impact2Sound="physics/metal/weapon_impact_hard2.wav"
SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_L_Finger1"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-2.156, -6.468, 0) },
	["ValveBiped.Bip01_L_Forearm"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(6.467, -60.36, 25.868) },
	["ValveBiped.Bip01_L_UpperArm"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 0, 2.155) },
	["Weapon"] = { scale = Vector(0.018, 0.018, 0.018), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_L_Finger01"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 8.623, 6.467) },
	["ValveBiped.Bip01_L_Clavicle"] = { scale = Vector(1, 1, 1), pos = Vector(-6.468, -7.546, -11.856), angle = Angle(0, 38.801, -6.468) },
	["ValveBiped.Bip01_L_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(2.155, -15.091, -2.156) },
	["ValveBiped.Bip01_L_Finger0"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-6.468, 8.623, 10.777) }
}

SWEP.NextFireShove = 0
SWEP.NextFireBlock = 0
SWEP.NextStun = 0

SWEP.DefSwayScale 	= 1.0
SWEP.DefBobScale 	= 1.0

SWEP.StunPos = Vector(0,0,0)
SWEP.StunAng = Vector(-11.61, -3.415, 9.56)

SWEP.ShovePos = Vector(-1.951, -10.537, -3.708)
SWEP.ShoveAng = Vector(0, 47.805, -55.318)

SWEP.RollPos = Vector(0,0,0)
SWEP.RollAng = Vector(-33.065, 0, 0)

SWEP.WhipPos = Vector(0, -5.628, 0)
SWEP.WhipAng = Vector(33.769, 28.843, 31.658)

SWEP.ThrowPos = Vector(0,0,0)
SWEP.ThrowAng = Vector(40.101, -56.281, 19.697)

SWEP.FanPos = Vector(-11.461, -15.277, -3.02)
SWEP.FanAng = Vector(60.502, 8.442, -42.211)

SWEP.WallPos = Vector(-0.601, -11.056, -9.65)
SWEP.WallAng = Vector(42.915, 0, 0)

function SWEP:AttackAnimation()
self.Weapon:SendWeaponAnim( ACT_VM_HITLEFT )
end
function SWEP:AttackAnimation2()
self.Weapon:SendWeaponAnim( ACT_VM_HITRIGHT )
end
function SWEP:AttackAnimation3()
self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
end


SWEP.VElements = {
	["knife"] = { type = "Model", model = "models/models/danguyen/commandoknife.mdl", bone = "Weapon", rel = "", pos = Vector(7.791, -2.597, -1.558), angle = Angle(-8.183, 106.363, -82.987), size = Vector(1.534, 1.534, 1.534), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["knife"] = { type = "Model", model = "models/models/danguyen/commandoknife.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 1.557, 3.635), angle = Angle(176.494, 180, 0), size = Vector(1.21, 1.21, 1.21), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
