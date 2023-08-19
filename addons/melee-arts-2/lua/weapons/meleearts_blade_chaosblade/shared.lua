SWEP.Base = "dangumeleebase"

SWEP.AdminSpawnable = true

SWEP.AutoSwitchTo = false
SWEP.Slot = 0
SWEP.PrintName = "Chaos Blade"
SWEP.Author = "danguyen"
SWEP.Spawnable = false
SWEP.AutoSwitchFrom = false
SWEP.Weight = 5
SWEP.Category = "Melee Arts 2"
SWEP.SlotPos = 1
 
SWEP.Purpose = "A divine blade obtained by a dark spirit. The blade wielder will erode alongside their opponents."

SWEP.ViewModelFOV = 95
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/models/danguyen/c_zweihander.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.UseHands = true

--STAT RATING (1-6)
SWEP.Type=1 --1: Blade, 2: Axe, 3:Bludgeon, 4: Spear
SWEP.Strength=6 -- 1-2: Small Weapons, 3-4: Medium Weapons (e.g crowbar), 5-6: Heavy Weapons (e.g Sledgehammers and Greatswords). Strength affects throwing distance and force
SWEP.Speed=3 -- 1-2: Slow, 3-4: Decent, 5-6: Fast
SWEP.Tier=5 -- General rating based on how good/doodoo the weapon is

--SWEPs are dumb (or I am) so we must state the weapon name again
SWEP.WepName="meleearts_blade_chaosblade"

--Stamina Costs
SWEP.PriAtkStamina=5
SWEP.ThrowStamina=5
SWEP.BlockStamina=5
SWEP.ShoveStamina=5

--Primary Attack Charge Values
SWEP.Charge = 0
SWEP.ChargeSpeed = 0.7
SWEP.DmgMin = 18
SWEP.DmgMax = 40
SWEP.Delay = 1
SWEP.TimeToHit = 0.1
SWEP.Range = 80
SWEP.Punch1 = Angle(-5, 10, 0)
SWEP.Punch2 = Angle(-5, 0, -3)
SWEP.HitFX = "bloodsplat"
SWEP.IdleAfter = true
--Throwing Attack Charge Values
SWEP.Charge2 = 0
SWEP.ChargeSpeed2 = 1.2
SWEP.DmgMin2 = 15
SWEP.DmgMax2 = 38
SWEP.ThrowModel = "models/models/danguyen/iaito.mdl"
SWEP.ThrowMaterial = ""
SWEP.ThrowScale = 1
SWEP.ThrowForce = 1300
SWEP.FixedThrowAng = Angle(-90,0,90)
SWEP.SpinAng = Vector(0,0,-1500)

--HOLDTYPES
SWEP.AttackHoldType="knife"
SWEP.Attack2HoldType="melee2"
SWEP.ChargeHoldType="melee"
SWEP.IdleHoldType="melee2"
SWEP.BlockHoldType="slam"
SWEP.ShoveHoldType="fist"
SWEP.ThrowHoldType="grenade"

--SOUNDS
SWEP.SwingSound="npc/combine_gunship/ping_search.wav"
SWEP.ThrowSound="axethrow.mp3"
SWEP.Hit1Sound="ambient/machines/slicer4.wav"
SWEP.Hit2Sound="ambient/machines/slicer3.wav"
SWEP.Hit3Sound="ambient/machines/slicer4.wav"

SWEP.Impact1Sound="npc/combine_gunship/gunship_ping_search.wav"
SWEP.Impact2Sound="npc/combine_gunship/gunship_ping_search.wav"

SWEP.ViewModelBoneMods = {
	["TrueRoot"] = { scale = Vector(1, 1, 1), pos = Vector(-2.037, 0, -4.259), angle = Angle(-12.223, 0, 0) },
	["LeftArm_1stP"] = { scale = Vector(1, 1, 1), pos = Vector(0.555, -0.926, 2.778), angle = Angle(0, 0, 0) },
	["RW_Weapon"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(3.332, 0, 0) },
	["Root"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-7.778, 0, 0) }
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

SWEP.FanPos = Vector(-1.211, -10.653, -1.81)
SWEP.FanAng = Vector(70, -2.112, 70)

SWEP.WallPos = Vector(0,0,0)
SWEP.WallAng = Vector(0,0,0)

function SWEP:AttackAnimation()
	self.Weapon.AttackAnimRate = 1.1
	self.Owner:EmitSound("katanaslash2.mp3")
	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
end
left=false
right=true
function SWEP:AttackAnimation2()
	self.Weapon.AttackAnimRate = 1.8
	if right==true then  
		self.Owner:EmitSound("katanaslash2.mp3")
		self.Punch1 = Angle(0, -15, 0)
		self.Weapon:SendWeaponAnim( ACT_VM_HITRIGHT )
		right=false
		left=true
	elseif left==true then
		self.Owner:EmitSound("katanaslash.mp3")
		self.Punch1 = Angle(5, 10, 0)
		self.Weapon:SendWeaponAnim( ACT_VM_HITLEFT )
		left=false
		right=true
	end
end
function SWEP:AttackAnimation3()
	self.Weapon:SendWeaponAnim( ACT_VM_HITRIGHT )
end

function SWEP:AtkExtra()
	self.Owner:TakeDamage(self.Owner:Health()*0.02)
	--self.Owner:EmitSound("ambient/levels/canals/windchime2.wav",50)
end



SWEP.VElements = {
	["harpoon+"] = { type = "Model", model = "models/models/danguyen/iaito.mdl", bone = "RW_Weapon", rel = "", pos = Vector(0, 0, 4.675), angle = Angle(-8.183, 160.13, -94.676), size = Vector(0.704, 0.704, 0.704), color = Color(255, 0, 0, 255), surpresslightning = false, material = "models/effects/comball_tape", skin = 0, bodygroup = {} },
	["harpoon"] = { type = "Model", model = "models/models/danguyen/iaito.mdl", bone = "RW_Weapon", rel = "", pos = Vector(0, 0, 4.675), angle = Angle(-8.183, 160.13, -94.676), size = Vector(0.699, 0.699, 0.699), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["harpoon"] = { type = "Model", model = "models/models/danguyen/iaito.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.635, 0.518, -0.519), angle = Angle(180, 0, -90), size = Vector(0.699, 0.699, 0.699), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["harpoon+"] = { type = "Model", model = "models/models/danguyen/iaito.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.635, 0.518, -0.519), angle = Angle(180, 0, -90), size = Vector(0.704, 0.704, 0.704), color = Color(255, 0, 0, 255), surpresslightning = false, material = "models/effects/comball_tape", skin = 0, bodygroup = {} }
}