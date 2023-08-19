SWEP.Base = "dangumeleebase"

SWEP.AdminSpawnable = true

SWEP.AutoSwitchTo = false
SWEP.Slot = 0
SWEP.PrintName = "Nunchucks"
SWEP.Author = "danguyen"
SWEP.Spawnable = true
SWEP.AutoSwitchFrom = false
SWEP.Weight = 5
SWEP.Category = "Melee Arts 2"
SWEP.SlotPos = 1
 
SWEP.Purpose = "This is most definitely not a staff, however I felt the mechanics would work well with it, so too bad."

SWEP.ViewModelFOV = 60
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/models/danguyen/c_nunchucks.mdl"
SWEP.WorldModel = "models/models/danguyen/w_nunchucks.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true 
SWEP.UseHands = true

--STAT RATING (1-6)
SWEP.Type=7 --1: Blade, 2: Axe, 3:Bludgeon, 4: Spear
SWEP.Strength=1 -- 1-2: Small Weapons, 3-4: Medium Weapons (e.g crowbar), 5-6: Heavy Weapons (e.g Sledgehammers and Greatswords). Strength affects throwing distance and force
SWEP.Speed=3 -- 1-2: Slow, 3-4: Decent, 5-6: Fast
SWEP.Tier=3 -- General rating based on how good/doodoo the weapon is

--SWEPs are dumb (or I am) so we must state the weapon name again
SWEP.WepName="meleearts_staff_nunchucks"

--Stamina Costs
SWEP.PriAtkStamina=5
SWEP.ThrowStamina=5
SWEP.BlockStamina=5
SWEP.ShoveStamina=5

--Primary Attack Charge Values
SWEP.Charge = 0
SWEP.ChargeSpeed = 0.2
SWEP.DmgMin = 4
SWEP.DmgMax = 14
SWEP.Delay = 1
SWEP.TimeToHit = 0.05
SWEP.Range = 75
SWEP.Punch1 = Angle(-5, 10, 0)
SWEP.Punch2 = Angle(-5, 0, -3)
SWEP.HitFX = ""
SWEP.HitFX2 = ""
SWEP.IdleAfter = true
--Throwing Attack Charge Values
SWEP.Charge2 = 0
SWEP.ChargeSpeed2 = 0.2
SWEP.DmgMin2 = 2
SWEP.DmgMax2 = 10
SWEP.ThrowModel = "models/models/danguyen/w_nunchucks.mdl"
SWEP.ThrowMaterial = ""
SWEP.ThrowScale = 1
SWEP.ThrowForce = 1300
SWEP.FixedThrowAng = Angle(90,0,0)
SWEP.SpinAng = Vector(0,900,0)

--HOLDTYPES
SWEP.AttackHoldType="melee"
SWEP.Attack2HoldType="knife"
SWEP.ChargeHoldType="melee"
SWEP.IdleHoldType="knife"
SWEP.BlockHoldType="magic"
SWEP.ShoveHoldType="fist"
SWEP.ThrowHoldType="grenade"

--SOUNDS
SWEP.SwingSound=""
SWEP.ThrowSound="spearthrow.mp3"
SWEP.Hit1Sound="physics/body/body_medium_impact_hard1.wav"
SWEP.Hit2Sound="physics/body/body_medium_impact_hard2.wav"
SWEP.Hit3Sound="physics/body/body_medium_impact_hard3.wav"

SWEP.Impact1Sound="physics/metal/metal_box_impact_soft3.wav"
SWEP.Impact2Sound="physics/metal/metal_box_impact_soft3.wav"

SWEP.ViewModelBoneMods = {
}

SWEP.NextFireShove = 0
SWEP.NextFireBlock = 0
SWEP.NextStun = 0

SWEP.DefSwayScale 	= 1.0
SWEP.DefBobScale 	= 1.0

SWEP.StunPos = Vector(-10.851, -2.814, 5.429)
SWEP.StunAng = Vector(-21.81, 4.925, -70)

SWEP.ShovePos = Vector(-10.851, -2.814, 5.429)
SWEP.ShoveAng = Vector(-1.407, 4.925, -70)

SWEP.RollPos = Vector(0,0,0)
SWEP.RollAng = Vector(0, 0, 0)

SWEP.WhipPos = Vector(0, -2.613, 3.015)
SWEP.WhipAng = Vector(-24.623, 5.627, -16.885)

SWEP.ThrowPos = Vector(2.21, -10.252, -3.016)
SWEP.ThrowAng = Vector(35.175, -29.549, 0)

SWEP.FanPos = Vector(5.03, -9.046, 0)
SWEP.FanAng = Vector(22.513, 60.502, 8.442)

SWEP.WallPos = Vector(0,0,0)
SWEP.WallAng = Vector(0,0,0)

function SWEP:AttackAnimation()
	self.Weapon.AttackAnimRate = 1.5
	self.Owner:EmitSound("weapons/iceaxe/iceaxe_swing1.wav")
	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
end
function SWEP:AttackAnimation2()
	self.Weapon.AttackAnimRate = 1.5
	self.Punch1 = Angle(-2, 0, 2)
	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER2 )
	self.Owner:EmitSound("weapons/iceaxe/iceaxe_swing1.wav")
end
function SWEP:AttackAnimationCOMBO()
	self.Weapon.AttackAnimRate = 1.8
	self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
	self.Owner:EmitSound("weapons/iceaxe/iceaxe_swing1.wav")
end
function SWEP:AttackAnimation3()
	self.Weapon:SendWeaponAnim( ACT_VM_HITRIGHT )
end
function SWEP:AtkExtra()
	self.Owner:EmitSound("physics/metal/metal_box_impact_soft3.wav")
end


SWEP.VElements = {
}
SWEP.WElements = {
}
