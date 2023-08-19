SWEP.Base = "dangumeleebase"

SWEP.AdminSpawnable = true

SWEP.AutoSwitchTo = false
SWEP.Slot = 0
SWEP.PrintName = "True Push Broom"
SWEP.Author = "danguyen"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.AutoSwitchFrom = false
SWEP.Weight = 5
SWEP.Category = "Melee Arts 2"
SWEP.SlotPos = 1
 
SWEP.Purpose = "A mythical weapon, forged in a forgotten land. Does little damage, but launches your enemy to the corners of the earth."

SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/models/danguyen/v_me_sledge.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.UseHands = true

--STAT RATING (1-6)
SWEP.Type=3 --1: Blade, 2: Axe, 3:Bludgeon, 4: Spear
SWEP.Strength=6 -- 1-2: Small Weapons, 3-4: Medium Weapons (e.g crowbar), 5-6: Heavy Weapons (e.g Sledgehammers and Greatswords). Strength affects throwing distance and force
SWEP.Speed=1 -- 1-2: Slow, 3-4: Decent, 5-6: Fast
SWEP.Tier=5 -- General rating based on how good/doodoo the weapon is
SWEP.JokeWep=true

--SWEPs are dumb (or I am) so we must state the weapon name again
SWEP.WepName="meleearts_spear_truepushbroom"

--Stamina Costs
SWEP.PriAtkStamina=5
SWEP.ThrowStamina=5
SWEP.BlockStamina=5
SWEP.ShoveStamina=5

--Primary Attack Charge Values
SWEP.Charge = 0
SWEP.ChargeSpeed = 0.3
SWEP.DmgMin = 0
SWEP.DmgMax = 4
SWEP.Delay = 1.2
SWEP.TimeToHit = 0.05
SWEP.AttackAnimRate = 0.8
SWEP.Range = 60
SWEP.Punch1 = Angle(-2, 0, 0)
SWEP.Punch2 = Angle(5, 0, -2)
SWEP.HitFX = "cball_explode"
SWEP.HitFX2 = "GlassImpact"
SWEP.IdleAfter = true
--Throwing Attack Charge Values
SWEP.Charge2 = 0
SWEP.ChargeSpeed2 = 0.2
SWEP.DmgMin2 = 2
SWEP.DmgMax2 = 4
SWEP.ThrowModel = "models/models/danguyen/escoba.mdl"
SWEP.ThrowMaterial = "models/props_pipes/Pipesystem01a_skin3"
SWEP.ThrowScale = 1
SWEP.ThrowForce = 1500

--HOLDTYPES
SWEP.AttackHoldType="melee2"
SWEP.Attack2HoldType="melee"
SWEP.ChargeHoldType="melee"
SWEP.IdleHoldType="melee2"
SWEP.BlockHoldType="slam"
SWEP.ShoveHoldType="fist"
SWEP.ThrowHoldType="grenade"

--SOUNDS
SWEP.SwingSound="WeaponFrag.Throw"
SWEP.ThrowSound="weapons/iceaxe/iceaxe_swing1.wav"
SWEP.Hit1Sound="physics/body/body_medium_impact_soft1.wav"
SWEP.Hit2Sound="physics/body/body_medium_impact_soft2.wav"
SWEP.Hit3Sound="physics/body/body_medium_impact_soft3.wav"

SWEP.Impact1Sound="physics/wood/wood_plank_impact_hard1.wav"
SWEP.Impact2Sound="physics/wood/wood_plank_impact_hard2.wav"

SWEP.ViewModelBoneMods = {
	["v_me_sledge"] = { scale = Vector(0.037, 0.037, 0.037), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}


SWEP.NextFireShove = 0
SWEP.NextFireBlock = 0
SWEP.NextStun = 0

SWEP.DefSwayScale 	= 1.0
SWEP.DefBobScale 	= 1.0

SWEP.StunPos = Vector(-6.835, -1.609, 4.421)
SWEP.StunAng = Vector(0, -34.473, -37.286)

SWEP.ShovePos = Vector(0, -5.829, 0)
SWEP.ShoveAng = Vector(28.141, 52.763, -0.704)

SWEP.RollPos = Vector(0,0,0)
SWEP.RollAng = Vector(-33.065, 0, 0)

SWEP.WhipPos = Vector(-20, -18.493, 7.236)
SWEP.WhipAng = Vector(0, -85, -19.698)

SWEP.ThrowPos = Vector(-2.211, -9.849, -0.805)
SWEP.ThrowAng = Vector(70, -34.473, -90)

SWEP.FanPos = Vector(-1.81, -6.031, 0.4)
SWEP.FanAng = Vector(18.291, 0.703, -15.478)

SWEP.WallPos = Vector(-0.601, -11.056, -9.65)
SWEP.WallAng = Vector(42.915, 0, 0)

function SWEP:AttackAnimation()
self.AttackAnimRate = 1.3
self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
end
function SWEP:AttackAnimation2()
self.AttackAnimRate = 1.3
self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
end
function SWEP:AttackAnimation3()
self.Weapon:SendWeaponAnim( ACT_VM_HITRIGHT )
end

function SWEP:AtkExtra()
	local tr = util.TraceLine( { --shamelessly copied from the fist weapon (i edited it tho so that's a dub)
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.Range,
		filter = self.Owner,
		mask = MASK_SHOT_HULL
	} )
	if ( !IsValid( tr.Entity ) ) then
		tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.Range,
			filter = self.Owner,
			mins = Vector( -1,-1,0 ),
			maxs = Vector( 1,1,0 ),
			mask = MASK_SHOT_HULL
		} )
	end
	local ply = self.Owner
	local hit = false
	local pos = ply:GetEyeTrace()
	if ( SERVER && IsValid( tr.Entity ) && ( tr.Entity:IsNPC() || tr.Entity:IsPlayer()) ) then
		local boom = 10000
		local shiftstraight = ply:GetAngles():Forward()*boom
		shiftstraight.z = 200
		tr.Entity:SetVelocity(shiftstraight) --back roll
		tr.Entity:EmitSound("weapons/mortar/mortar_explode1.wav")

		hit = true
	end
end


SWEP.VElements = {
	["spear"] = { type = "Model", model = "models/props_c17/pushbroom.mdl", bone = "v_me_sledge", rel = "", pos = Vector(-1.558, -1.558, -7.792), angle = Angle(68.96, 19.87, -47.923), size = Vector(0.625, 0.625, 0.625), color = Color(255, 0, 0, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
	["element_name"] = { type = "Model", model = "models/props_c17/pushbroom.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(-1.558, 1.557, 0.518), angle = Angle(174.156, 174.156, -50.26), size = Vector(0.711, 0.711, 0.711), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
