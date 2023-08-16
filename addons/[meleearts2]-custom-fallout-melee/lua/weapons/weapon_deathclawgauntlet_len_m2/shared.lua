SWEP.Base = "dangumeleebase"

SWEP.AdminSpawnable = true

SWEP.AutoSwitchTo = false
SWEP.Slot = 0
SWEP.PrintName = "Deathclaw Gauntlet"
SWEP.Author = "Lenny"
SWEP.Spawnable = true
SWEP.AutoSwitchFrom = false
SWEP.Weight = 5
SWEP.Category = "Fallout SWEPs - Melee Weapons"
SWEP.SlotPos = 1

SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/models/danguyen/c_smodpunch.mdl"
SWEP.WorldModel = "models/mosi/fallout4/props/weapons/melee/boxingglove.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.UseHands = true
SWEP.CanThrow = false

SWEP.WepName="weapon_deathclawgauntlet_len_m2"

--STAT RATING (1-6)
SWEP.Type=3 --1: Blade, 2: Axe, 3:Bludgeon, 4: Spear
SWEP.Strength=1 -- 1-2: Small Weapons, 3-4: Medium Weapons (e.g crowbar), 5-6: Heavy Weapons (e.g Sledgehammers and Greatswords). Strength affects throwing distance and force
SWEP.Speed=2 -- 1-2: Slow, 3-4: Decent, 5-6: Fast
SWEP.Tier=1 -- General rating based on how good/doodoo the weapon is


--Stamina Costs
SWEP.PriAtkStamina=5
SWEP.ThrowStamina=5

SWEP.BlockStamina=5
SWEP.ShoveStamina=5

--Primary Attack Charge Values
SWEP.Charge = 0
SWEP.ChargeSpeed = 1
SWEP.DmgMin = 65
SWEP.DmgMax = 100
SWEP.Delay = 0.4
SWEP.TimeToHit = 0.05
SWEP.Range = 105
SWEP.Punch1 = Angle(-5, 10, 0)
SWEP.Punch2 = Angle(-5, 0, -3)
SWEP.HitFX = "cball_bounce"
SWEP.HitFX2 = ""
SWEP.IdleAfter = true
--Throwing Attack Charge Values
SWEP.Charge2 = 0
SWEP.ChargeSpeed2 = 0.2
SWEP.DmgMin2 = 50
SWEP.DmgMax2 = 70

SWEP.ThrowModel = "models/mosi/fallout4/props/weapons/melee/deathclawgauntlet.mdl"
SWEP.ThrowMaterial = ""
SWEP.ThrowScale = 1
SWEP.ThrowForce = 500
SWEP.FixedThrowAng = Angle(90,0,0)
SWEP.SpinAng = Vector(0,0,0)

--HOLDTYPES
SWEP.AttackHoldType="fist"
SWEP.Attack2HoldType="fist"
SWEP.ChargeHoldType="fist"
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
	return
end
function SWEP:AttackAnimation2()
	self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
end
function SWEP:AttackAnimation3()
	self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
end


SWEP.VElements = {
	["gauntlet"] = { type = "Model", model = "models/mosi/fallout4/props/weapons/melee/deathclawgauntlet.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(0.037, 0.56, 0), angle = Angle(6.179, -97.834, -94.933), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
	["gauntlet"] = { type = "Model", model = "models/mosi/fallout4/props/weapons/melee/deathclawgauntlet.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(-1.333, 0, 0.254), angle = Angle(180, 82.768, 87.764), size = Vector(0.693, 0.693, 0.693), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
