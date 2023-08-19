SWEP.Base = "dangumeleebase"

SWEP.AdminSpawnable = true

SWEP.AutoSwitchTo = false
SWEP.Slot = 0
SWEP.PrintName = "Illumina"
SWEP.Author = "danguyen"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.AutoSwitchFrom = false
SWEP.Weight = 5
SWEP.Category = "Melee Arts 2"
SWEP.SlotPos = 1
 
SWEP.Purpose = "Guiding light."

SWEP.ViewModelFOV = 85
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/models/danguyen/c_oren_katana.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.UseHands = true

--STAT RATING (1-6)
SWEP.Type=1 --1: Blade, 2: Axe, 3:Bludgeon, 4: Spear
SWEP.Strength=1 -- 1-2: Small Weapons, 3-4: Medium Weapons (e.g crowbar), 5-6: Heavy Weapons (e.g Sledgehammers and Greatswords). Strength affects throwing distance and force
SWEP.Speed=6 -- 1-2: Slow, 3-4: Decent, 5-6: Fast
SWEP.Tier=5 -- General rating based on how good/doodoo the weapon is
SWEP.JokeWep=true

--SWEPs are dumb (or I am) so we must state the weapon name again
SWEP.WepName="meleearts_blade_illumina"

--Stamina Costs
SWEP.PriAtkStamina=5
SWEP.ThrowStamina=5
SWEP.BlockStamina=5
SWEP.ShoveStamina=5

--Primary Attack Charge Values
SWEP.Charge = 0
SWEP.ChargeSpeed = 1
SWEP.DmgMin = 15
SWEP.DmgMax = 50
SWEP.Delay = 0.65
SWEP.TimeToHit = 0.05
SWEP.Range = 65
SWEP.Punch1 = Angle(-5, 10, 0)
SWEP.Punch2 = Angle(-5, 0, -3)
SWEP.HitFX = "bloodsplat"
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
SWEP.AttackHoldType="knife"
SWEP.Attack2HoldType="none"
SWEP.ChargeHoldType="pistol"
SWEP.IdleHoldType="pistol"
SWEP.BlockHoldType="slam"
SWEP.ShoveHoldType="fist"
SWEP.ThrowHoldType="grenade"

--SOUNDS
SWEP.SwingSound=""
SWEP.ThrowSound="weapons/iceaxe/iceaxe_swing1.wav"
SWEP.Hit1Sound="ambient/machines/slicer4.wav"
SWEP.Hit2Sound="ambient/machines/slicer3.wav"
SWEP.Hit3Sound="ambient/machines/slicer4.wav"

SWEP.Impact1Sound="swordclash.mp3"
SWEP.Impact2Sound="swordclash.mp3"

SWEP.ViewModelBoneMods = {
	["TrueRoot"] = { scale = Vector(1, 1, 1), pos = Vector(0, 1.146, -1.147), angle = Angle(0, 0, 0) },
	["LeftArm_1stP"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 30, -30), angle = Angle(0, 0, 0) },
	["RW_Weapon"] = { scale = Vector(0.076, 0.076, 0.076), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["RightArm_1stP"] = { scale = Vector(1, 1, 1), pos = Vector(-1.668, 0, 0), angle = Angle(10, 0, 0) }
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

SWEP.ThrowPos = Vector(-2.241, -4.02, 5.9)
SWEP.ThrowAng = Vector(70, 17.587, 25.326)

SWEP.FanPos = Vector(3.42, -11.056, 0.8)
SWEP.FanAng = Vector(90, -18.996, 90)

SWEP.WallPos = Vector(0,0,0)
SWEP.WallAng = Vector(0,0,0)

function SWEP:AttackAnimation()
	self.Weapon.AttackAnimRate = 1.1
	self.Owner:EmitSound("linkedlunge.mp3")
	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
end
left=false
right=true
function SWEP:AttackAnimation2()
	self.Weapon.AttackAnimRate = 1.8
	if right==true then  
		self.Owner:EmitSound("linkedslash.mp3")
		self.Punch1 = Angle(0, -15, 0)
		self.Weapon:SendWeaponAnim( ACT_VM_HITRIGHT )
		right=false
		left=true
	elseif left==true then
		self.Owner:EmitSound("linkedslash.mp3")
		self.Punch1 = Angle(5, 10, 0)
		self.Weapon:SendWeaponAnim( ACT_VM_HITLEFT )
		left=false
		right=true
	end
end
function SWEP:AttackAnimation3()
	self.Weapon:SendWeaponAnim( ACT_VM_HITRIGHT )
end


SWEP.VElements = {
	["katana"] = { type = "Model", model = "models/models/danguyen/illumina.mdl", bone = "RW_Weapon", rel = "", pos = Vector(0, 0, 6.752), angle = Angle(92.337, 10.519, 4.831), size = Vector(0.497, 0.497, 0.497), color = Color(255, 217, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["katana1"] = { type = "Model", model = "models/models/danguyen/illumina.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.635, -0.519, -7.792), angle = Angle(-101.689, -104.027, -5.844), size = Vector(0.69, 0.69, 0.69), color = Color(255, 217, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}