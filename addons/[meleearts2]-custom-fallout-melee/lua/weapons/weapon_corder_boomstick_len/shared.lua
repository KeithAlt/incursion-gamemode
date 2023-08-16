SWEP.Base = "dangumeleebase"

SWEP.AdminSpawnable = true

SWEP.AutoSwitchTo = false
SWEP.Slot = 0
SWEP.PrintName = "Boom Stick"
SWEP.Author = "Lenny"
SWEP.Spawnable = true
SWEP.AutoSwitchFrom = false
SWEP.Weight = 5
SWEP.Category = "Fallout SWEPs - Custom Orders"
SWEP.SlotPos = 1

SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/models/danguyen/v_me_sledge.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.UseHands = true
SWEP.CanThrow = false


SWEP.WepName="weapon_corder_boomstick_len"


--STAT RATING (1-6)
SWEP.Type=4 --1: Blade, 2: Axe, 3:Bludgeon, 4: Spear
SWEP.Strength=10 -- 1-2: Small Weapons, 3-4: Medium Weapons (e.g crowbar), 5-6: Heavy Weapons (e.g Sledgehammers and Greatswords). Strength affects throwing distance and force
SWEP.Speed=1 -- 1-2: Slow, 3-4: Decent, 5-6: Fast
SWEP.Tier=5 -- General rating based on how good/doodoo the weapon is

--Stamina Costs
SWEP.PriAtkStamina=5
SWEP.ThrowStamina=5
SWEP.BlockStamina=5
SWEP.ShoveStamina=5

--Primary Attack Charge Values
SWEP.Charge = 0
SWEP.ChargeSpeed = 1
SWEP.DmgMin = 10
SWEP.DmgMax = 10
SWEP.Delay = 2
SWEP.TimeToHit = 0.05
SWEP.Range = 120
SWEP.Punch1 = Angle(-5, 10, 0)
SWEP.Punch2 = Angle(-5, 0, -3)
SWEP.HitFX = ""
SWEP.HitFX2 = ""
SWEP.IdleAfter = true
--Throwing Attack Charge Values
SWEP.Charge2 = 0
SWEP.ChargeSpeed2 = 0.2
SWEP.DmgMin2 = 25
SWEP.DmgMax2 = 70
SWEP.ThrowModel = "models/mosi/fallout4/props/weapons/melee/shishkebab.mdl"
SWEP.ThrowMaterial = ""
SWEP.ThrowScale = 1
SWEP.ThrowForce = 10000
SWEP.FixedThrowAng = Angle(90,0,0)
SWEP.SpinAng = Vector(0,0,0)

--HOLDTYPES
SWEP.AttackHoldType="shotgun"
SWEP.Attack2HoldType="knife"
SWEP.ChargeHoldType="shotgun"
SWEP.IdleHoldType="shotgun"
SWEP.BlockHoldType="fist"
SWEP.ShoveHoldType="fist"
SWEP.ThrowHoldType="grenade"

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

function SWEP:Deploy()
	self:GetOwner():SetRunSpeed( self:GetOwner():GetRunSpeed() + 20 )
end

function SWEP:Holster()
	if IsValid(self:GetOwner()) then
		self:GetOwner():SetRunSpeed( self:GetOwner():GetRunSpeed() - 20 )
	end
	return true
end

local ignore = {
	["sk_liberty_prime_pill"] = true,
	["fo3_frankhorrigan"] = true,
}
function SWEP:AtkExtra(tr)
	if not IsFirstTimePredicted() then return end

	if ( SERVER ) then
		if not IsValid(tr.Entity) and not tr.HitWorld then return end
		local ply = self:GetOwner()


		if (tr.Entity:IsPlayer()) then
			local target = tr.Entity
			local tdmg = DamageInfo()
			tdmg:SetAttacker(ply)
			tdmg:SetDamageType(DMG_BLAST)

			local ent = pk_pills.getMappedEnt(target)
			if IsValid(ent) and ignore[ent.formTable.name] then
				tdmg:SetDamage(100)
			else
				if target:WearingPA() then
					tdmg:SetDamage(target:GetMaxHealth() * 1.8) // 50 percent
				else
					tdmg:SetDamage(target:GetMaxHealth() * 1.5) // 30 percent
				end
			end

			target:TakeDamageInfo(tdmg)
		end

		util.BlastDamage(self:GetOwner(), self:GetOwner(), tr.HitPos, 200, 150)
		timer.Simple(0, function()
			ParticleEffect("vj_explosion3", tr.HitPos, Angle(0, 0, 0))
		end)
		hit = true
	end
end

function SWEP:SecondaryAttack()
	if not IsFirstTimePredicted() then return end
	if self:GetNextSecondaryFire() > CurTime() then return end
	local ply = self:GetOwner()

	--ply:EmitSound(sndClip)
	--ply:BuffStat("A", 10, 10)
	self:SetNextSecondaryFire(CurTime() + 15)
end

SWEP.VElements = {
	["lunge"] = { type = "Model", model = "models/weapons/cgc/boomstick.mdl", bone = "v_me_sledge", rel = "", pos = Vector(0, 0, 0), angle = Angle(0, 0, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["mine"] = { type = "Model", model = "models/weapons/cgc/boomstick.mdl", bone = "ValveBiped.Anim_Attachment_RH", rel = "", pos = Vector(-1.259, -1.903, -0.188), angle = Angle(3.96, 0, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
