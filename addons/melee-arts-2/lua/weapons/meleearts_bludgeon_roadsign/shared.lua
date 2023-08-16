SWEP.Base = "dangumeleebase"

SWEP.AdminSpawnable = true

SWEP.AutoSwitchTo = false
SWEP.Slot = 0
SWEP.PrintName = "Roadsign"
SWEP.Author = "danguyen"
SWEP.Spawnable = true
SWEP.AutoSwitchFrom = false
SWEP.Weight = 5
SWEP.Category = "Melee Arts 2"
SWEP.SlotPos = 1
 
SWEP.Purpose = "Oh? You're approaching me?"

SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/models/danguyen/c_crovel.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.UseHands = true

--STAT RATING (1-6)
SWEP.Type=3 --1: Blade, 2: Axe, 3:Bludgeon, 4: Spear
SWEP.Strength=5 -- 1-2: Small Weapons, 3-4: Medium Weapons (e.g crowbar), 5-6: Heavy Weapons (e.g Sledgehammers and Greatswords). Strength affects throwing distance and force
SWEP.Speed=3 -- 1-2: Slow, 3-4: Decent, 5-6: Fast
SWEP.Tier=5 -- General rating based on how good/doodoo the weapon is

--SWEPs are dumb (or I am) so we must state the weapon name again
SWEP.WepName="meleearts_bludgeon_roadsign"

--Stamina Costs
SWEP.PriAtkStamina=5
SWEP.ThrowStamina=5
SWEP.BlockStamina=5
SWEP.ShoveStamina=5

--Primary Attack Charge Values
SWEP.Charge = 0
SWEP.ChargeSpeed = 0.6
SWEP.DmgMin = 20
SWEP.DmgMax = 50
SWEP.Delay = 1
SWEP.TimeToHit = 0.1
SWEP.AttackAnimRate = 0.8
SWEP.Range = 80
SWEP.Punch1 = Angle(-2, 0, 0)
SWEP.Punch2 = Angle(5, 0, -2)
SWEP.HitFX = "bloodsplat"
SWEP.IdleAfter = true
--Throwing Attack Charge Values
SWEP.Charge2 = 0
SWEP.ChargeSpeed2 = 0.4
SWEP.DmgMin2 = 15
SWEP.DmgMax2 = 40
SWEP.ThrowModel = "models/models/danguyen/diosign.mdl"
SWEP.ThrowMaterial = ""
SWEP.ThrowScale = 0.7
SWEP.ThrowForce = 1000
SWEP.FixedThrowAng = Angle(0,90,-90)
SWEP.SpinAng = Vector(0,0,150)

--HOLDTYPES
SWEP.AttackHoldType="grenade"
SWEP.Attack2HoldType="melee2"
SWEP.ChargeHoldType="melee"
SWEP.IdleHoldType="melee2"
SWEP.BlockHoldType="physgun"
SWEP.ShoveHoldType="fist"
SWEP.ThrowHoldType="grenade"

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

SWEP.FanPos = Vector(3.22, -6.633, -10.45)
SWEP.FanAng = Vector(49.95, 35.879, 35.175)

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
	["shovel"] = { type = "Model", model = "models/models/danguyen/diosign.mdl", bone = "RW_Weapon", rel = "", pos = Vector(0.619, -0.219, -26.494), angle = Angle(1.169, -66.624, 1.169), size = Vector(0.625, 0.625, 0.625), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["shovel1"] = { type = "Model", model = "models/models/danguyen/diosign.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.635, 0.518, 16.104), angle = Angle(-180, 87.662, 0), size = Vector(0.625, 0.625, 0.625), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}