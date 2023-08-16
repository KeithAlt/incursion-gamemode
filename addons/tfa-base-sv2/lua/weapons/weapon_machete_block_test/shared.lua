SWEP.Base = "tfa_melee_base"
SWEP.Category = "[HUB] TFA Fallout"
SWEP.PrintName = "Machete Gladius - Block"
SWEP.ViewModel = "models/weapons/base/c_oren_katana.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.ViewModelFOV = 80
SWEP.UseHands = true
SWEP.CameraOffset = Angle(0, 0, 0)
--SWEP.InspectPos = Vector(17.184, -4.891, -11.902) - SWEP.VMPos
--SWEP.InspectAng = Vector(70, 46.431, 70)
SWEP.WorldModel = "models/weapons/machetegladius/machetegladius.mdl"
SWEP.HoldType = "melee"
SWEP.Primary.Directional = true
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.DisableIdleAnimations = false
SWEP.VMPos = Vector(5, 5, -6)

SWEP.Primary.Attacks = {
	{
		["act"] = ACT_VM_PRIMARYATTACK, -- Animation; ACT_VM_THINGY, ideally something unique per-sequence
		["len"] = 14 * 4.5, -- Trace distance
		["dir"] = Vector(0, 20, -70), -- Trace arc cast
		["dmg"] = math.random(28,28), --Damage
		["dmgtype"] = DMG_SLASH, --DMG_SLASH,DMG_CRUSH, etc.
		["delay"] = 0.4, --Delay
		["spr"] = true, --Allow attack while sprinting?
		["snd"] = Sound("slash1.wav"), -- Sound ID
		["snd_delay"] = 0.26,
		["viewpunch"] = Angle(5, 0, 0), --viewpunch angle
		["end"] = 0.6, --time before next attack
		["hull"] = 42, --Hullsize
		["direction"] = "F", --Swing dir,
		["combotime"] = 0.3,
		["hitflesh"] = Sound("weapon_meleeknife_impact.mp3"),
		["hitworld"] = Sound("hit_other2.wav"),
	},
	{
		["act"] = ACT_VM_HITLEFT, -- Animation; ACT_VM_THINGY, ideally something unique per-sequence
		["len"] = 14 * 4.5, -- Trace distance
		["dir"] = Vector(75, 0, 0), -- Trace arc cast
		["dmg"] = math.random(28,28), --Damage
		["dmgtype"] = DMG_SLASH, --DMG_SLASH,DMG_CRUSH, etc.
		["delay"] = 0.4, --Delay
		["spr"] = true, --Allow attack while sprinting?
		["snd"] = Sound("slash1.wav"), -- Sound ID
		["snd_delay"] = 0.26,
		["viewpunch"] = Angle(1, -5, 0), --viewpunch angle
		["end"] = 0.6, --time before next attack
		["hull"] = 42, --Hullsize
		["direction"] = "R", --Swing dir,
		["combotime"] = 0.3,
		["hitflesh"] = Sound("weapon_meleeknife_impact.mp3"),
		["hitworld"] = Sound("hit_other2.wav"),
	},
	{
		["act"] = ACT_VM_HITRIGHT, -- Animation; ACT_VM_THINGY, ideally something unique per-sequence
		["len"] = 14 * 4.5, -- Trace distance
		["dir"] = Vector(-75, 0, 0), -- Trace arc cast
		["dmg"] = math.random(28,28), --Damage
		["dmgtype"] = DMG_SLASH, --DMG_SLASH,DMG_CRUSH, etc.
		["delay"] = 0.4, --Delay
		["spr"] = true, --Allow attack while sprinting?
		["snd"] = Sound("slash1.wav"), -- Sound ID
		["snd_delay"] = 0.26,
		["viewpunch"] = Angle(1, 5, 0), --viewpunch angle
		["end"] = 0.6, --time before next attack
		["hull"] = 42, --Hullsize
		["direction"] = "L", --Swing dir,
		["combotime"] = 0.3,
		["hitflesh"] = Sound("weapon_meleeknife_impact.mp3"),
		["hitworld"] = Sound("hit_other2.wav"),
	},
	{
		["act"] = ACT_VM_PULLBACK, -- Animation; ACT_VM_THINGY, ideally something unique per-sequence
		["len"] = 14 * 4.5, -- Trace distance
		["dir"] = Vector(0, 20, 70), -- Trace arc cast
		["dmg"] = math.random(28,28), --Damage
		["dmgtype"] = DMG_SLASH, --DMG_SLASH,DMG_CRUSH, etc.
		["delay"] = 0.4, --Delay
		["spr"] = true, --Allow attack while sprinting?
		["snd"] = Sound("slash1.wav"), -- Sound ID
		["snd_delay"] = 0.26,
		["viewpunch"] = Angle(-5, 0, 0), --viewpunch angle
		["end"] = 0.6, --time before next attack
		["hull"] = 42, --Hullsize
		["direction"] = "B", --Swing dir,
		["combotime"] = 0.3,
		["hitflesh"] = Sound("weapon_meleeknife_impact.mp3"),
		["hitworld"] = Sound("hit_other2.wav"),
	}
}

SWEP.AllowSprintAttack = true
SWEP.Sprint_Mode = TFA.Enum.LOCOMOTION_HYBRID-- ANI = mdl, Hybrid = ani + lua, Lua = lua only
SWEP.SprintAnimation = {
	["loop"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "sprint_loop", --Number for act, String/Number for sequence
		["is_idle"] = true
	},--looping animation
	["out"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "sprint_out", --Number for act, String/Number for sequence
		["transition"] = true
	} --Outward transition
}
SWEP.RunSightsPos = Vector(0, 0, 0)
SWEP.RunSightsAng = Vector(-10, -2.5, 2.5)

local att = {}
local lvec, ply, targ

lvec = Vector()

function SWEP:PrimaryAttack()
	if self:IsSafety() then return end
	if not self:VMIV() then return end
	if CurTime() <= self:GetNextPrimaryFire() then return end
	if not TFA.Enum.ReadyStatus[self:GetStatus()] then return end
	table.Empty(att)
	local founddir = false

	print("asdasda")

	if self.Primary.Directional then
		ply = self.Owner
		--lvec = WorldToLocal(ply:GetVelocity(), Angle(0, 0, 0), vector_origin, ply:EyeAngles()):GetNormalized()
		lvec.x = 0
		lvec.y = 0
		if ply:KeyDown(IN_MOVERIGHT) then lvec.y = lvec.y - 1 end
		if ply:KeyDown(IN_MOVELEFT) then lvec.y = lvec.y + 1 end
		if ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_JUMP) then lvec.x = lvec.x + 1 end
		if ply:KeyDown(IN_BACK) or ply:KeyDown(IN_DUCK) then lvec.x = lvec.x - 1 end
		lvec.z = 0
		--lvec:Normalize()

		if lvec.y > 0.3 then
			targ = "L"
		elseif lvec.y < -0.3 then
			targ = "R"
		elseif lvec.x > 0.5 then
			targ = "F"
		elseif lvec.x < -0.1 then
			targ = "B"
		else
			targ = ""
		end

		for k, v in pairs(self.Primary.Attacks) do
			if (not self:GetSprinting() or v.spr) and v.direction and string.find(v.direction, targ) then
				if string.find(v.direction, targ) then
					founddir = true
				end

				table.insert(att, #att + 1, k)
			end
		end
	end

	if not self.Primary.Directional or #att <= 0 or not founddir then
		for k, v in pairs(self.Primary.Attacks) do
			if (not self:GetSprinting() or v.spr) and v.dmg then
				table.insert(att, #att + 1, k)
			end
		end
	end

	if #att <= 0 then return end

	if SERVER then
		timer.Simple(0, function()
			if IsValid(self) then
				self.Seed = math.random(-99999, 99999)
				self:SetSeed(self.Seed)
			end
		end)
	elseif IsFirstTimePredicted() then
		self.Seed = self:GetSeed()
	end

	math.randomseed(CurTime() + self.Seed)
	ind = att[math.random(1, #att)]
	attack = self.Primary.Attacks[ind]
	vm = self.Owner:GetViewModel()
	--We have attack isolated, begin attack logic
	self:PlaySwing(attack.act)

	if not attack.snd_delay or attack.snd_delay <= 0 then
		if IsFirstTimePredicted() then
			self:EmitSound(attack.snd)

			if self.Owner.Vox then
				self.Owner:Vox("bash", 4)
			end
		end

		self.Owner:ViewPunch(attack.viewpunch)
	elseif attack.snd_delay then
		timer.Simple(attack.snd_delay, function()
			if IsValid(self) and self:IsValid() and SERVER then
				self:EmitSound(attack.snd)

				if self:OwnerIsValid() and self.Owner.Vox then
					self.Owner:Vox("bash", 4)
				end
			end
		end)

		self:SetVP(true)
		self:SetVPPitch(attack.viewpunch.p)
		self:SetVPYaw(attack.viewpunch.y)
		self:SetVPRoll(attack.viewpunch.r)
		self:SetVPTime(CurTime() + attack.snd_delay)
		self.Owner:ViewPunch(-Angle(attack.viewpunch.p / 2, attack.viewpunch.y / 2, attack.viewpunch.r / 2))
	end

	self.up_hat = false
	self:SetStatus(TFA.Enum.STATUS_SHOOTING)
	self:SetMelAttackID(ind)
	self:SetStatusEnd(CurTime() + attack.delay)
	self:SetNextPrimaryFire(CurTime() + attack["end"])
	self.Owner:SetAnimation(PLAYER_ATTACK1)
end


SWEP.CanBlock = true
SWEP.BlockKey = IN_USE
SWEP.BlockAnimation = {
	["in"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_DEPLOY, --Number for act, String/Number for sequence
		["transition"] = true
	}, --Inward transition
	["loop"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_IDLE_DEPLOYED, --Number for act, String/Number for sequence
		["is_idle"] = true
	},--looping animation
	["hit"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_RELOAD_DEPLOYED, --Number for act, String/Number for sequence
		["is_idle"] = true
	},--when you get hit and block it
	["out"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_UNDEPLOY, --Number for act, String/Number for sequence
		["transition"] = true
	} --Outward transition
}
SWEP.BlockDamageTypes = {DMG_SLASH, DMG_CLUB, DMG_BULLET}
SWEP.BlockCone = 135 --Think of the player's view direction as being the middle of a sector, with the sector's angle being this
SWEP.BlockDamageMaximum = 0.1 --Multiply damage by this for a maximumly effective block
SWEP.BlockDamageMinimum = 0.4 --Multiply damage by this for a minimumly effective block
SWEP.BlockTimeWindow = 100 --Time to absorb maximum damage
SWEP.BlockTimeFade = 1 --Time for blocking to do minimum damage.  Does not include block window
SWEP.NinjaMode = true --Can block bullets/everything
SWEP.BlockDamageCap = 100000
SWEP.BlockSound = "weapon_meleeknife_impact.mp3"
SWEP.BlockFadeOut = nil --Override the length of the ["out"] block animation easily
SWEP.BlockFadeOutEnd = 0.2 --In absense of BlockFadeOut, shave this length off of the animation time
SWEP.BlockHoldType = "magic"
SWEP.BlockCanDeflect = true --Can "bounce" bullets off a perfect parry?


SWEP.Secondary.CanBash = true
SWEP.Secondary.BashDamage = 60
SWEP.Secondary.BashDelay = 0.1
SWEP.Secondary.BashLength = 16 * 3

SWEP.SequenceLengthOverride = {
	[ACT_VM_HITCENTER] = 0.8
}

SWEP.ViewModelBoneMods = {
	["RW_Weapon"] = { scale = Vector(0.01, 0.01, 0.01), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
}

SWEP.VElements = {
	["element_name"] = { type = "Model", model = "models/weapons/machetegladius/machetegladius.mdl", bone = "RW_Weapon", rel = "", pos = Vector(0.3, -0.25, -6), angle = Angle(0, 180, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["element_name"] = { type = "Model", model = "models/weapons/machetegladius/machetegladius.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.48, 1.629, 5.618), angle = Angle(180, -90.003, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.InspectionActions = {ACT_VM_RECOIL1, ACT_VM_RECOIL2, ACT_VM_RECOIL3}
