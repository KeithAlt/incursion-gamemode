SWEP.Base = "dangumeleebase"

SWEP.AdminSpawnable = true

SWEP.AutoSwitchTo = false
SWEP.Slot = 0
SWEP.PrintName = "Pencil"
SWEP.Author = "danguyen"
SWEP.Spawnable = true
SWEP.AutoSwitchFrom = false
SWEP.Weight = 5
SWEP.Category = "Melee Arts 2"
SWEP.SlotPos = 1
 
SWEP.Purpose = "Wake the fuck up, samurai."

SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.UseHands = true

--STAT RATING (1-6)
SWEP.Type=1 --1: Blade, 2: Axe, 3:Bludgeon, 4: Spear
SWEP.Strength=1 -- 1-2: Small Weapons, 3-4: Medium Weapons (e.g crowbar), 5-6: Heavy Weapons (e.g Sledgehammers and Greatswords). Strength affects throwing distance and force
SWEP.Speed=6 -- 1-2: Slow, 3-4: Decent, 5-6: Fast
SWEP.Tier=1 -- General rating based on how good/doodoo the weapon is
SWEP.JokeWep=true

--SWEPs are dumb (or I am) so we must state the weapon name again
SWEP.WepName="meleearts_blade_pencil"

--Stamina Costs
SWEP.PriAtkStamina=5
SWEP.ThrowStamina=5
SWEP.BlockStamina=5
SWEP.ShoveStamina=5

--Primary Attack Charge Values
SWEP.Charge = 0
SWEP.ChargeSpeed = 0.2
SWEP.DmgMin = 1
SWEP.DmgMax = 5
SWEP.Delay = 0.1
SWEP.TimeToHit = 0.05
SWEP.AttackAnimRate = 1.5
SWEP.Range = 55
SWEP.Punch1 = Angle(-2, 0, 2)
SWEP.Punch2 = Angle(2, 0, 0)
SWEP.HitFX = ""
SWEP.IdleAfter = false
--Throwing Attack Charge Values
SWEP.Charge2 = 0
SWEP.ChargeSpeed2 = 0.2
SWEP.DmgMin2 = 2
SWEP.DmgMax2 = 6
SWEP.ThrowModel = "models/models/danguyen/pencil.mdl"
SWEP.ThrowMaterial = ""
SWEP.ThrowScale = 1
SWEP.ThrowForce = 1200

--HOLDTYPES
SWEP.AttackHoldType="knife"
SWEP.Attack2HoldType="melee"
SWEP.ChargeHoldType="fist"
SWEP.IdleHoldType="slam"
SWEP.BlockHoldType="camera"
SWEP.ShoveHoldType="fist"
SWEP.ThrowHoldType="grenade"

--SOUNDS
SWEP.SwingSound="weapons/iceaxe/iceaxe_swing1.wav"
SWEP.ThrowSound="weapons/iceaxe/iceaxe_swing1.wav"
SWEP.Hit1Sound="ambient/machines/slicer4.wav"
SWEP.Hit2Sound="ambient/machines/slicer4.wav"
SWEP.Hit3Sound="ambient/machines/slicer4.wav"

SWEP.Impact1Sound=""
SWEP.Impact2Sound=""

SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_L_Clavicle"] = { scale = Vector(1, 1, 1), pos = Vector(-12.898, 2.803, -0.561), angle = Angle(0, 0, 0) },
	["v_weapon.Knife_Handle"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

SWEP.NextFireShove = 0
SWEP.NextFireBlock = 0
SWEP.NextStun = 0

SWEP.DefSwayScale 	= 1.0
SWEP.DefBobScale 	= 1.0

SWEP.StunPos = Vector(12.838, -8.514, 5)
SWEP.StunAng = Vector(14.661, 15.607, 51.554)

SWEP.ShovePos = Vector(-1.486, -8.785, -3.109)
SWEP.ShoveAng = Vector(0, 70, -45.878)

SWEP.RollPos = Vector(0,0,0)
SWEP.RollAng = Vector(-33.065, 0, 0)

SWEP.WhipPos = Vector(-7.237, -14.07, 15.878)
SWEP.WhipAng = Vector(-70, 0.703, 53.466)

SWEP.ThrowPos = Vector(0, -6.351, 7.162)
SWEP.ThrowAng = Vector(6.149, -31.689, 44.931)

SWEP.FanPos = Vector(-8.514, -8.785, 1.485)
SWEP.FanAng = Vector(7.094, 0, -53.446)

SWEP.WallPos = Vector(-0.601, -11.056, -9.65)
SWEP.WallAng = Vector(42.915, 0, 0)

function SWEP:AttackAnimation()
self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
end
function SWEP:AttackAnimation2()
self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
end
function SWEP:AttackAnimation3()
self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
end


SWEP.VElements = {
	["kabar"] = { type = "Model", model = "models/models/danguyen/pencil.mdl", bone = "v_weapon.Knife_Handle", rel = "", pos = Vector(-0.101, -0.519, 2.596), angle = Angle(8.182, 3.506, -66.624), size = Vector(0.755, 0.755, 0.755), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["kabar"] = { type = "Model", model = "models/models/danguyen/pencil.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.635, 1.557, -1.558), angle = Angle(7.5, -90, 97.5), size = Vector(0.95, 0.95, 0.95), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
