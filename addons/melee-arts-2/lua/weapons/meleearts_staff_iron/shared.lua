SWEP.Base = "dangumeleebase"

SWEP.AdminSpawnable = true

SWEP.AutoSwitchTo = false
SWEP.Slot = 0
SWEP.PrintName = "Iron Staff"
SWEP.Author = "danguyen"
SWEP.Spawnable = true
SWEP.AutoSwitchFrom = false
SWEP.Weight = 5
SWEP.Category = "Melee Arts 2"
SWEP.SlotPos = 1
 
SWEP.Purpose = "Bōjutsu! (Now with extra strength)"

SWEP.ViewModelFOV = 95
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/models/danguyen/c_oren_katana.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.UseHands = true

--STAT RATING (1-6)
SWEP.Type=7 --1: Blade, 2: Axe, 3:Bludgeon, 4: Spear
SWEP.Strength=3 -- 1-2: Small Weapons, 3-4: Medium Weapons (e.g crowbar), 5-6: Heavy Weapons (e.g Sledgehammers and Greatswords). Strength affects throwing distance and force
SWEP.Speed=1 -- 1-2: Slow, 3-4: Decent, 5-6: Fast
SWEP.Tier=3 -- General rating based on how good/doodoo the weapon is

--SWEPs are dumb (or I am) so we must state the weapon name again
SWEP.WepName="meleearts_staff_iron"

--Stamina Costs
SWEP.PriAtkStamina=5
SWEP.ThrowStamina=5
SWEP.BlockStamina=5
SWEP.ShoveStamina=5

--Primary Attack Charge Values
SWEP.Charge = 0
SWEP.ChargeSpeed = 0.2
SWEP.DmgMin = 9
SWEP.DmgMax = 24
SWEP.Delay = 1
SWEP.TimeToHit = 0.05
SWEP.Range = 75
SWEP.Punch1 = Angle(-5, 10, 0)
SWEP.Punch2 = Angle(-5, 0, -3)
SWEP.HitFX = "bloodsplat"
SWEP.HitFX2 = ""
SWEP.IdleAfter = true
--Throwing Attack Charge Values
SWEP.Charge2 = 0
SWEP.ChargeSpeed2 = 0.2
SWEP.DmgMin2 = 6
SWEP.DmgMax2 = 18
SWEP.ThrowModel = "models/models/danguyen/staff.mdl"
SWEP.ThrowMaterial = "phoenix_storms/concrete0"
SWEP.ThrowScale = 1
SWEP.ThrowForce = 1300
SWEP.FixedThrowAng = Angle(0,90,0)
SWEP.SpinAng = Vector(0,90,0)

--HOLDTYPES
SWEP.AttackHoldType="knife"
SWEP.Attack2HoldType="melee2"
SWEP.ChargeHoldType="knife"
SWEP.IdleHoldType="melee2"
SWEP.BlockHoldType="slam"
SWEP.ShoveHoldType="fist"
SWEP.ThrowHoldType="grenade"

--SOUNDS
SWEP.SwingSound=""
SWEP.ThrowSound="spearthrow.mp3"
SWEP.Hit1Sound="physics/body/body_medium_impact_hard1.wav"
SWEP.Hit2Sound="physics/body/body_medium_impact_hard2.wav"
SWEP.Hit3Sound="physics/body/body_medium_impact_hard3.wav"

SWEP.Impact1Sound="physics/metal/metal_canister_impact_hard1.wav"
SWEP.Impact2Sound="physics/metal/metal_canister_impact_hard2.wav"

SWEP.ViewModelBoneMods = {
	["RW_Weapon"] = { scale = Vector(0.039, 0.039, 0.039), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

SWEP.NextFireShove = 0
SWEP.NextFireBlock = 0
SWEP.NextStun = 0

SWEP.DefSwayScale 	= 1.0
SWEP.DefBobScale 	= 1.0

SWEP.StunPos = Vector(0, 0, 0)
SWEP.StunAng = Vector(-16.181, 0, 47.136)

SWEP.ShovePos = Vector(-6.633, -0.403, -1.005)
SWEP.ShoveAng = Vector(-3.518, 70, -70)

SWEP.RollPos = Vector(0,0,0)
SWEP.RollAng = Vector(0, 0, 0)

SWEP.WhipPos = Vector(0, -10.252, 0)
SWEP.WhipAng = Vector(70, 0, 0)

SWEP.ThrowPos = Vector(-4.624, -3.217, -2.613)
SWEP.ThrowAng = Vector(0, -90, -90)

SWEP.FanPos = Vector(5.23, -10.051, -3.62)
SWEP.FanAng = Vector(80, 16.884, 90)

SWEP.WallPos = Vector(0,0,0)
SWEP.WallAng = Vector(0,0,0)

function SWEP:AttackAnimation()
	self.Weapon.AttackAnimRate = 1.1
	self.Owner:EmitSound("WeaponFrag.Throw")
	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
end
function SWEP:AttackAnimation2()
	self.Weapon.AttackAnimRate = 1.6
	self.Punch1 = Angle(0, -15, 0)
	self.Weapon:SendWeaponAnim( ACT_VM_HITRIGHT )
	self.Owner:EmitSound("WeaponFrag.Throw")
end
one=true
two=false
three=false
function SWEP:AttackAnimationCOMBO()
	self.Weapon.AttackAnimRate = 1.6
	if one==true then  
		self.Owner:EmitSound("WeaponFrag.Throw")
		self.Punch1 = Angle(0, -10, 0)
		self.Weapon:SendWeaponAnim( ACT_VM_PULLBACK )
		one=false
		two=true
		three=false
	elseif two==true then
		self.Owner:EmitSound("WeaponFrag.Throw")
		self.Punch1 = Angle(5, 10, 0)
		self.Weapon:SendWeaponAnim( ACT_VM_MISSLEFT )
		one=false
		two=false
		three=true
	elseif three==true then
		self.Owner:EmitSound("WeaponFrag.Throw")
		self.Punch1 = Angle(5, 10, 0)
		self.Weapon:SendWeaponAnim( ACT_VM_PULLBACK_HIGH )
		one=true
		two=false
		three=false
	end
end
function SWEP:AttackAnimation3()
	self.Weapon:SendWeaponAnim( ACT_VM_HITRIGHT )
end
function SWEP:AtkExtra()
	self.Owner:EmitSound("physics/metal/metal_canister_impact_hard1.wav")
end


SWEP.VElements = {
	["katana"] = { type = "Model", model = "models/models/danguyen/staff.mdl", bone = "RW_Weapon", rel = "", pos = Vector(-0.519, 0.518, 4.675), angle = Angle(0, -15.195, -82.987), size = Vector(1.014, 0.69, 1.014), color = Color(255, 255, 255, 255), surpresslightning = false, material = "phoenix_storms/concrete0", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["katana"] = { type = "Model", model = "models/models/danguyen/staff.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.596, 1.557, 1.557), angle = Angle(0, 0, -85.325), size = Vector(0.755, 0.755, 0.755), color = Color(255, 255, 255, 255), surpresslightning = false, material = "phoenix_storms/concrete0", skin = 0, bodygroup = {} }
}
