-- Fists SWEP made by jonjo
-- Credits to the base Garry's Mod SWEP for the primary fire
-- https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/weapons/weapon_fists.lua

AddCSLuaFile()

SWEP.PrintName = "Hands"
SWEP.Author = "jonjo"
SWEP.Slot = 0
SWEP.SlotPos = 4
SWEP.Instructions = "Primary Fire: Attack\nSecondary Fire: Grab"

SWEP.Spawnable = true
SWEP.Category = "Claymore Gaming"

SWEP.ViewModel = Model("models/weapons/c_arms.mdl")
SWEP.WorldModel = ""
SWEP.ViewModelFOV = 54
SWEP.UseHands = false
SWEP.HoldType = "fist"

SWEP.Primary.Automatic  = true
SWEP.Primary.ClipSize  = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Ammo = "none"

SWEP.Secondary.Automatic = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.GrabRange = 100
SWEP.HitDistance = 48

SWEP.FireWhenLowered = true
SWEP.LowerAngles = Angle(0, 5, -14)
SWEP.LowerAngles2 = Angle(0, 5, -22)

SWEP.SwingSound = Sound("WeaponFrag.Throw")
SWEP.HitSound = Sound("Flesh.ImpactHard")

SWEP.IsjFists = true

function SWEP:Initialize()
    self:SetHoldType("fist")
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "NextMeleeAttack")
	self:NetworkVar("Float", 1, "NextIdle")
	self:NetworkVar("Int", 2, "Combo")
end

function SWEP:UpdateNextIdle()
	local vm = self.Owner:GetViewModel()
	self:SetNextIdle(CurTime() + vm:SequenceDuration() / vm:GetPlaybackRate())
end

function SWEP:PrimaryAttack()
	if hook.Run("CanPlayerThrowPunch", self.Owner) == false then
		return false
	end

	self.Owner:SetAnimation(PLAYER_ATTACK1)

	local anim
	if self:GetCombo() >= 2 then
		anim = "fists_uppercut"
	else
		if math.random() < 0.5 then
			anim = "fists_right"
		else
			anim = "fists_left"
		end
	end

	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))

	self:EmitSound(self.SwingSound)

	self:UpdateNextIdle()
	self:SetNextMeleeAttack(CurTime() + 0.2)

	self:SetNextPrimaryFire(CurTime() + 0.9)
	self:SetNextSecondaryFire(CurTime() + 0.9)
end

local phys_pushscale = GetConVar("phys_pushscale")

function SWEP:DealDamage()
	local anim = self:GetSequenceName(self.Owner:GetViewModel():GetSequence())

	self.Owner:LagCompensation(true)

	local tr = util.TraceLine({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
		filter = self.Owner,
		mask = MASK_SHOT_HULL
	})

	if !IsValid(tr.Entity) then
		tr = util.TraceHull({
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
			filter = self.Owner,
			mins = Vector(-10, -10, -8),
			maxs = Vector(10, 10, 8),
			mask = MASK_SHOT_HULL
		})
	end

	-- We need the second part for single player because SWEP:Think is ran shared in SP
	if tr.Hit and !(game.SinglePlayer() and CLIENT) then
		self:EmitSound(self.HitSound)
	end

	local hit = false
	local scale = phys_pushscale:GetFloat()

	if SERVER and IsValid(tr.Entity) and (tr.Entity:IsNPC() or tr.Entity:IsPlayer() or tr.Entity:Health() > 0) then
		local dmginfo = DamageInfo()

		local attacker = self.Owner
		if (!IsValid(attacker)) then attacker = self end
		dmginfo:SetAttacker(attacker)

		dmginfo:SetInflictor(self)
		dmginfo:SetDamage(math.random(5, 8))

		if (anim == "fists_left") then
			dmginfo:SetDamageForce(self.Owner:GetRight() * 4912 * scale + self.Owner:GetForward() * 9998 * scale) -- Yes we need those specific numbers
		elseif (anim == "fists_right") then
			dmginfo:SetDamageForce(self.Owner:GetRight() * -4912 * scale + self.Owner:GetForward() * 9989 * scale)
		elseif (anim == "fists_uppercut") then
			dmginfo:SetDamageForce(self.Owner:GetUp() * 5158 * scale + self.Owner:GetForward() * 10012 * scale)
			dmginfo:SetDamage(math.random(12, 24))
		end

		SuppressHostEvents(NULL) -- Let the breakable gibs spawn in multiplayer on client
		tr.Entity:TakeDamageInfo(dmginfo)
		SuppressHostEvents(self.Owner)

		hit = true
	end

	if IsValid(tr.Entity) then
		local phys = tr.Entity:GetPhysicsObject()
		if (IsValid(phys)) then
			phys:ApplyForceOffset(self.Owner:GetAimVector() * 80 * phys:GetMass() * scale, tr.HitPos)
		end
	end

	if SERVER then
		if (hit and anim != "fists_uppercut") then
			self:SetCombo(self:GetCombo() + 1)
		else
			self:SetCombo(0)
		end
	end

	self.Owner:LagCompensation(false)
end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:Deploy()
	local vm = self.Owner:GetViewModel()
	vm:SetModel("models/weapons/c_arms_citizen.mdl")
	vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_draw"))

	self:SetNextPrimaryFire(CurTime() + vm:SequenceDuration())
	self:SetNextSecondaryFire(CurTime() + vm:SequenceDuration())
	self:UpdateNextIdle()

	if SERVER then
		self:SetCombo(0)
	end

	return true
end

function SWEP:Holster()
	self:SetNextMeleeAttack(0)

	return true
end

function SWEP:Think()
	local vm = self.Owner:GetViewModel()
	local idletime = self:GetNextIdle()

	if idletime > 0 and CurTime() > idletime then
		vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_idle_0" .. math.random(1, 2)))

		self:UpdateNextIdle()
	end

	local meleetime = self:GetNextMeleeAttack()

	if meleetime > 0 and CurTime() > meleetime then
		self:DealDamage()

		self:SetNextMeleeAttack(0)
	end

	if SERVER and CurTime() > self:GetNextPrimaryFire() + 0.1 then
		self:SetCombo(0)
	end
end

if SERVER then
	function SWEP:Grab()
		local ply = self:GetOwner()

		ply:LagCompensation(true)

		local trace = ply:GetEyeTraceNoCursor()
		local ent = trace.Entity
		local physObj = IsValid(ent) and ent:GetPhysicsObject() or NULL

		if self:CanPickup(ent, physObj) then
			ply:PickupObject(ent)
			ply.Grabbed = ent
		end

		ply:LagCompensation(false)

		self.ReadyToPickup = false
	end

	function SWEP:SecondaryAttack()
		local ply = self:GetOwner()

		if IsValid(ply:GetParent()) then return end

	    if IsValid(ply.Grabbed) then
			ply:DropObject(ply.Grabbed)
			ply.Grabbed = NULL
		else
			self.ReadyToPickup = true
		end
	end

	-- https://github.com/Facepunch/garrysmod-issues/issues/4572
	hook.Add("KeyRelease", "jFistsGrab", function(ply, key)
		if key == IN_ATTACK2 then
			local wep = ply:GetActiveWeapon()
			if IsValid(wep) and wep.IsjFists and wep.ReadyToPickup then
				wep:Grab()
			end
		end
	end)

	hook.Add("KeyPress", "jFistsDrop", function(ply, key)
		if key == IN_ATTACK2 and IsValid(ply.Grabbed) then
			ply:DropObject(ply.Grabbed)
			ply.Grabbed = NULL
		end
	end)
end

if CLIENT then
	function SWEP:SecondaryAttack()
		-- Do nothing
	end
end

function SWEP:CanPickup(ent, physObj)
	if !IsValid(ent) or !IsValid(physObj) then
		return false
	end

	return ent != game.GetWorld() and ent:GetPos():Distance(self.Owner:GetPos()) < self.GrabRange and physObj:IsMotionEnabled() and physObj:GetMass() < 200 and !ent:IsPlayerHolding() and hook.Run("PlayerCanPickupItem", self.Owner, ent)
end

local wep = SWEP
weapons.Register(wep, "nut_hands")
hook.Add("InitPostEntity", "jFistsOverwriteNSHands", function()
	print("Registering jFists as nut_hands")
	weapons.Register(wep, "nut_hands")
end)
