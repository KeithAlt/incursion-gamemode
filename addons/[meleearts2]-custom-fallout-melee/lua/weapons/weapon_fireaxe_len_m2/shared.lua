SWEP.Base = "dangumeleebase"

SWEP.AdminSpawnable = true

SWEP.AutoSwitchTo = false
SWEP.Slot = 0
SWEP.PrintName = "Fire Axe"
SWEP.Author = "Lenny"
SWEP.Spawnable = true
SWEP.AutoSwitchFrom = false
SWEP.Weight = 5
SWEP.Category = "Fallout SWEPs - Melee Weapons"
SWEP.SlotPos = 1

SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/models/danguyen/c_crovel.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.UseHands = true
SWEP.CanThrow = false


SWEP.WepName="weapon_fireaxe_len_m2"
SWEP.CanDecapitate = true

--STAT RATING (1-6)
SWEP.Type=1 --1: Blade, 2: Axe, 3:Bludgeon, 4: Spear
SWEP.Strength=3 -- 1-2: Small Weapons, 3-4: Medium Weapons (e.g crowbar), 5-6: Heavy Weapons (e.g Sledgehammers and Greatswords). Strength affects throwing distance and force
SWEP.Speed=6 -- 1-2: Slow, 3-4: Decent, 5-6: Fast
SWEP.Tier=5 -- General rating based on how good/doodoo the weapon is

--SWEPs are dumb (or I am) so we must state the weapon name again

--Stamina Costs
SWEP.PriAtkStamina=5
SWEP.ThrowStamina=5
SWEP.BlockStamina=5
SWEP.ShoveStamina=5

--Primary Attack Charge Values
SWEP.Charge = 0
SWEP.ChargeSpeed = 0.5
SWEP.DmgMin = 50
SWEP.DmgMax = 100
SWEP.Delay = 1
SWEP.TimeToHit = 0.05
SWEP.Range = 150
SWEP.Punch1 = Angle(-5, 10, 0)
SWEP.Punch2 = Angle(-5, 0, -3)
SWEP.HitFX = "cball_bounce"
SWEP.HitFX2 = ""
SWEP.IdleAfter = true
--Throwing Attack Charge Values
SWEP.Charge2 = 2
SWEP.ChargeSpeed2 = 0.5
SWEP.DmgMin2 = 50
SWEP.DmgMax2 = 70

SWEP.ThrowModel = "models/weapons/fireaxe/fireaxe.mdl"
SWEP.ThrowMaterial = ""
SWEP.ThrowScale = 1
SWEP.ThrowForce = 5000
SWEP.FixedThrowAng = Angle(0,0,90)
SWEP.SpinAng = Vector(0,5,0)

--HOLDTYPES
SWEP.AttackHoldType="grenade"
SWEP.Attack2HoldType="melee2"
SWEP.ChargeHoldType="melee"
SWEP.IdleHoldType="melee2"
SWEP.BlockHoldType="physgun"
SWEP.ShoveHoldType="fist"
SWEP.ThrowHoldType="grenade"

--SOUNDS
--SOUNDS
SWEP.SwingSound="WeaponFrag.Throw"
SWEP.ThrowSound="axethrow.mp3"
SWEP.Hit1Sound="ambient/machines/slicer2.wav"
SWEP.Hit2Sound="ambient/machines/slicer2.wav"
SWEP.Hit3Sound="ambient/machines/slicer2.wav"

SWEP.Impact1Sound="physics/metal/metal_canister_impact_hard1.wav"
SWEP.Impact2Sound="physics/metal/metal_canister_impact_hard2.wav"

SWEP.ViewModelBoneMods = {
	["LeftForeArm_1stP"] = { scale = Vector(1, 1, 1), pos = Vector(-3.052, -2.712, 1.355), angle = Angle(0, 0, 0) },
	["LeftHandRing1_1stP"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, -1.017), angle = Angle(0, 0, 0) },
	["LeftHandThumb1_1stP"] = { scale = Vector(1, 1, 1), pos = Vector(-0.926, 0, -0.556), angle = Angle(-5.557, 0, 0) },
	["RightHandMiddle1_1stP"] = { scale = Vector(1, 1, 1), pos = Vector(0.555, 0, 0.555), angle = Angle(0, 0, 0) },
	["LeftHandPinky1_1stP"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, -0.678), angle = Angle(0, 0, 0) },
	["RightHandRing1_1stP"] = { scale = Vector(1, 1, 1), pos = Vector(0.555, 0, 0.555), angle = Angle(0, 0, 0) },
	["LeftHandMiddle1_1stP"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, -1.017), angle = Angle(0, 0, 0) },
	["RightHandPinky1_1stP"] = { scale = Vector(1, 1, 1), pos = Vector(0.555, 0, 0.185), angle = Angle(0, 0, 0) },
	["RightHandIndex1_1stP"] = { scale = Vector(1, 1, 1), pos = Vector(0.925, 0, 0.185), angle = Angle(0, 0, 0) },
	["RW_Weapon"] = { scale = Vector(0.052, 0.052, 0.052), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["LeftHandIndex1_1stP"] = { scale = Vector(1, 1, 1), pos = Vector(-0.339, 0, -1.017), angle = Angle(0, 0, 0) }
}

SWEP.NextFireShove = 0
SWEP.NextFireBlock = 0
SWEP.NextStun = 0

SWEP.DefSwayScale 	= 1.0
SWEP.DefBobScale 	= 1.0

SWEP.StunPos = Vector(0,0,0)
SWEP.StunAng = Vector(-20.403, -7.035, 3.517)

SWEP.ShovePos = Vector(-5.64, -3.524, 0)
SWEP.ShoveAng = Vector(28.37, 62.907, -38.238)

SWEP.RollPos = Vector(0,0,0)
SWEP.RollAng = Vector(-33.065, 0, 0)

SWEP.ThrowPos = Vector(-3.451, -7.437, 3.42)
SWEP.ThrowAng = Vector(70, 1.406, -30.251)

SWEP.WhipPos = Vector(-3.451, -7.437, 3.42)
SWEP.WhipAng = Vector(70, 1.406, -30.251)

SWEP.FanPos = Vector(2.612, -5.628, -2.412)
SWEP.FanAng = Vector(36.583, 22.513, 28.141)

SWEP.WallPos = Vector(-0.601, -11.056, -9.65)
SWEP.WallAng = Vector(42.915, 0, 0)

function SWEP:AttackAnimation()
	self.Weapon.AttackAnimRate = 2
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
end
left=false
right=true
function SWEP:AttackAnimation2()
	self.Weapon.AttackAnimRate = 1.5
	if right==true then
		self.Punch1 = Angle(0, -15, 0)
		self.Weapon:SendWeaponAnim( ACT_VM_HITRIGHT )
		right=false
		left=true
	elseif left==true then
		self.Punch1 = Angle(5, 10, 0)
		self.Weapon:SendWeaponAnim( ACT_VM_HITLEFT )
		left=false
		right=true
	end
end
function SWEP:AttackAnimation3()
self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
end


SWEP.VElements = {
	["fireaxe"] = { type = "Model", model = "models/weapons/fireaxe/fireaxe.mdl", bone = "RW_Weapon", rel = "", pos = Vector(0.600, 0.172, -27.673), angle = Angle(0, 105.13, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["element_name"] = { type = "Model", model = "models/weapons/fireaxe/fireaxe.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.48, 0.629, 20), angle = Angle(180, -90.003, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
