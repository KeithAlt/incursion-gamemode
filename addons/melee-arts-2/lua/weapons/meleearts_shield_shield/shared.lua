SWEP.Base = "dangumeleebase"

SWEP.AdminSpawnable = true

SWEP.AutoSwitchTo = false
SWEP.Slot = 0
SWEP.PrintName = "Shield"
SWEP.Author = "danguyen"
SWEP.Spawnable = false
SWEP.AutoSwitchFrom = false
SWEP.Weight = 5
SWEP.Category = "Melee Arts 2"
SWEP.SlotPos = 1
 
SWEP.Purpose = "Block all melee attacks and cannot be shoved, but will break easily against spears and guns. Also has a weak attack."

SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = true
SWEP.ViewModel = "models/models/danguyen/c_smodpunch.mdl"
SWEP.WorldModel = "models/weapons/c_crowbar.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.UseHands = true

--STAT RATING (1-6)
SWEP.Type=5 --1: Blade, 2: Axe, 3:Bludgeon, 4: Spear
SWEP.Strength=1 -- 1-2: Small Weapons, 3-4: Medium Weapons (e.g crowbar), 5-6: Heavy Weapons (e.g Sledgehammers and Greatswords). Strength affects throwing distance and force
SWEP.Speed=1 -- 1-2: Slow, 3-4: Decent, 5-6: Fast
SWEP.Tier=2 -- General rating based on how good/doodoo the weapon is

--SWEPs are dumb (or I am) so we must state the weapon name again
SWEP.WepName="meleearts_shield_shield"

--Stamina Costs
SWEP.PriAtkStamina=5
SWEP.ThrowStamina=5
SWEP.BlockStamina=5
SWEP.ShoveStamina=5

--Shield Only
SWEP.ShieldHealth=100

--Primary Attack Charge Values
SWEP.Charge = 0
SWEP.ChargeSpeed = 0.2
SWEP.DmgMin = 5
SWEP.DmgMax = 8
SWEP.Delay = 0.9
SWEP.TimeToHit = 0.08
SWEP.AttackAnimRate = 1
SWEP.Range = 50
SWEP.Punch1 = Angle(-2, 0, 2)
SWEP.Punch2 = Angle(2, 0, 0)
SWEP.HitFX = ""
SWEP.HitFX2 = ""
SWEP.IdleAfter = true
--Throwing Attack Charge Values
SWEP.Charge2 = 0
SWEP.ChargeSpeed2 = 0.5
SWEP.DmgMin2 = 3
SWEP.DmgMax2 = 6
SWEP.ThrowModel = "models/maxofs2d/gm_painting.mdl"
SWEP.ThrowMaterial = ""
SWEP.ThrowScale = 0.7
SWEP.ThrowForce = 5200

--HOLDTYPES
SWEP.AttackHoldType="slam"
SWEP.Attack2HoldType="slam"
SWEP.ChargeHoldType="slam"
SWEP.IdleHoldType="physgun"
SWEP.BlockHoldType="physgun"
SWEP.ShoveHoldType="fist"
SWEP.ThrowHoldType="grenade"

--SOUNDS
SWEP.SwingSound="WeaponFrag.Throw"
SWEP.ThrowSound="weapons/iceaxe/iceaxe_swing1.wav"
SWEP.Hit1Sound="physics/wood/wood_box_impact_hard1.wav"
SWEP.Hit2Sound="physics/wood/wood_box_impact_hard2.wav"
SWEP.Hit3Sound="physics/wood/wood_box_impact_hard3.wav"

SWEP.Impact1Sound="physics/wood/wood_box_impact_hard1.wav"
SWEP.Impact2Sound="physics/wood/wood_box_impact_hard2.wav"

SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_R_Clavicle"] = { scale = Vector(1, 1, 1), pos = Vector(-30, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_L_Clavicle"] = { scale = Vector(1, 1, 1), pos = Vector(-6.481, 0, 0), angle = Angle(0, 0, 0) }
}


SWEP.NextFireShove = 0
SWEP.NextFireBlock = 0
SWEP.NextStun = 0

SWEP.DefSwayScale 	= 1.0
SWEP.DefBobScale 	= 1.0

SWEP.StunPos = Vector(0,0,0)
SWEP.StunAng = Vector(0.703, -0.704, 48.542)

SWEP.ShovePos = Vector(-14.271, 1.004, 0)
SWEP.ShoveAng = Vector(28.141, 70, -35.176)

SWEP.RollPos = Vector(0,0,0)
SWEP.RollAng = Vector(-33.065, 0, 0)

SWEP.WhipPos = Vector(0,0,0)
SWEP.WhipAng = Vector(-11.256, 0.703, 20.402)

SWEP.ThrowPos = Vector(0,0,0)
SWEP.ThrowAng = Vector(31.658, 14.774, 26.733)

SWEP.FanPos = Vector(0.402, -12.865, 2.813)
SWEP.FanAng = Vector(70, 40.804, 70)

SWEP.WallPos = Vector(-0.601, -11.056, -9.65)
SWEP.WallAng = Vector(42.915, 0, 0)

function SWEP:AttackAnimation()
self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
end
function SWEP:AttackAnimation2()
self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
end
function SWEP:AttackAnimation3()
self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
end


SWEP.VElements = {
	["shield"] = { type = "Model", model = "models/maxofs2d/gm_painting.mdl", bone = "ValveBiped.Bip01_L_Hand", rel = "", pos = Vector(-1.558, -1.558, -2.597), angle = Angle(-92.338, 45.583, 8.182), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["handle"] = { type = "Model", model = "models/props_canal/mattpipe.mdl", bone = "ValveBiped.Bip01_L_Hand", rel = "shield", pos = Vector(-3.636, 3, 3.299), angle = Angle(80.649, 0, 0), size = Vector(0.497, 0.497, 0.172), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
	["shield"] = { type = "Model", model = "models/maxofs2d/gm_painting.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(7.791, 1.557, 0), angle = Angle(3.506, 38.57, -73.637), size = Vector(0.625, 0.625, 0.625), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}