-- Molotov
-- By Anya O'Quinn / Slade Xanthas

AddCSLuaFile()

/**if SERVER then
	resource.AddWorkshop("1470029857")
end**/

if CLIENT then
	language.Add("molotov_ammo", "Molotovs")
end

if not ConVarExists("vfire_molotov_enabled") and vFireInstalled then
	CreateConVar("vfire_molotov_enabled", "1", FCVAR_NOTIFY, "Should vFire be used for the Molotov Cocktails?  vFire must be installed for this to work!")
end

sound.Add({name = "Weapon_NMRiH_Molotov.Draw", 			channel = CHAN_ITEM, 	volume = 0.4, 	level = 75, 	pitch = {100,100}, 	sound = {"nmrih/player/weapon_draw_01.ogg","nmrih/player/weapon_draw_02.ogg","nmrih/player/weapon_draw_03.ogg","nmrih/player/weapon_draw_04.ogg","nmrih/player/weapon_draw_05.ogg"}})
sound.Add({name = "Weapon_NMRiH_Molotov.Shove", 		channel = CHAN_WEAPON, 	volume = 0.75, 	level = 100, 	pitch = {97,100}, 	sound = {"nmrih/player/shove_01.ogg","nmrih/player/shove_02.ogg","nmrih/player/shove_03.ogg","nmrih/player/shove_04.ogg","nmrih/player/shove_05.ogg" }})
sound.Add({name = "Weapon_NMRiH_Molotov.Ignite_Rag", 	channel = CHAN_WEAPON, 	volume = 1, 	level = 75, 	pitch = {100,100}, 	sound = "nmrih/weapons/firearms/exp_molotov/molotov_rag_ignite_01.ogg"})
sound.Add({name = "Weapon_NMRiH_Molotov.Rag_Loop", 		channel = CHAN_WEAPON, 	volume = 1, 	level = 75, 	pitch = {100,100}, 	sound = "nmrih/weapons/firearms/exp_molotov/molotov_rag_fire_loop_01.ogg"})
sound.Add({name = "Weapon_NMRiH_Molotov.Explode", 		channel = CHAN_WEAPON, 	volume = 1, 	level = 75, 	pitch = {100,100}, 	sound = "nmrih/weapons/firearms/exp_molotov/molotov_explode_01.ogg"})
sound.Add({name = "Weapon_NMRiH_Molotov.Fire_Loop", 	channel = CHAN_WEAPON, 	volume = 1, 	level = 75, 	pitch = {100,100}, 	sound = "nmrih/weapons/firearms/exp_molotov/molotov_fire_loop_01.ogg"})
sound.Add({name = "Weapon_NMRiH_Zippo.Open", 			channel = CHAN_AUTO, 	volume = 1, 	level = 75, 	pitch = {100,100}, 	sound = {"nmrih/weapons/tools/zippo/zippo_open_01.ogg","nmrih/weapons/tools/zippo/zippo_open_02.ogg" }})
sound.Add({name = "Weapon_NMRiH_Zippo.Close", 			channel = CHAN_AUTO, 	volume = 1, 	level = 75, 	pitch = {100,100}, 	sound = {"nmrih/weapons/tools/zippo/zippo_close_01.ogg", "nmrih/weapons/tools/zippo/zippo_close_02.ogg" }})
sound.Add({name = "Weapon_NMRiH_Zippo.Strike_Fail", 	channel = CHAN_AUTO, 	volume = 1, 	level = 75, 	pitch = {100,100}, 	sound = {"nmrih/weapons/tools/zippo/zippo_strike_fail_01.ogg", "nmrih/weapons/tools/zippo/zippo_strike_fail_02.ogg", "nmrih/weapons/tools/zippo/zippo_strike_fail_03.ogg"}})
sound.Add({name = "Weapon_NMRiH_Zippo.Strike_Success", 	channel = CHAN_AUTO, 	volume = 1, 	level = 75, 	pitch = {100,100}, 	sound = "nmrih/weapons/tools/zippo/zippo_strike_success_01.ogg"})

game.AddParticles("particles/nmrih_explosion_tnt.pcf")
game.AddParticles("particles/nmrih_explosions.pcf")
game.AddParticles("particles/nmrih_gasoline.pcf")

game.AddAmmoType({
	name 		= "molotov",
	dmgtype 	= DMG_BURN,
	tracer 		= TRACER_NONE,
	plydmg 		= 5,
	npcdmg 		= 5,
	force 		= 0,
	minsplash 	= 10,
	maxsplash 	= 10,
	maxcarry 	= 8
})

SWEP.Base					= "weapon_base"

SWEP.PrintName				= "Molotov"
SWEP.ClassName				= "weapon_nmrih_molotov"
SWEP.Author					= "Anya O'Quinn"
SWEP.Instructions			= "Left click to throw and burn the infidels."

if vFireInstalled then
	SWEP.Category			= "vFire Weapons"
else
	SWEP.Category			= "Anya O'Quinn"
end

SWEP.Spawnable				= true
SWEP.AdminOnly				= false

SWEP.Slot					= 1
SWEP.SlotPos				= 1
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.ViewModel				= "models/nmrih/weapons/exp_molotov/v_exp_molotov.mdl"
SWEP.WorldModel				= "models/nmrih/weapons/exp_molotov/w_exp_molotov.mdl"
SWEP.ViewModelFOV			= 50
SWEP.ViewModelFlip			= false
SWEP.BobScale 				= 0
SWEP.SwayScale 				= 1

SWEP.DrawAmmo				= false
SWEP.DrawCrosshair			= true

SWEP.HoldType				= "grenade"

SWEP.Primary.Delay			= 0.75
SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 4
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "molotov"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Throwing 				= false
SWEP.StartThrow 			= false
SWEP.ResetThrow 			= false
SWEP.ThrowVel 				= 1000
SWEP.NextThrow 				= CurTime()
SWEP.NextAnimation 			= CurTime()

PrecacheParticleSystem("nmrih_molotov_explosion")

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:Deploy()

	self.Idle = true

	self.StartThrow = false
	self.Throwing = false
	self.ResetThrow = false

	if not self.Throwing then

		if IsValid(self.Weapon) and IsValid(self.Owner) then
			self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
			if IsValid(self.Owner:GetViewModel()) then
				self.Weapon:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
				self.Weapon:SetNextSecondaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
				self.NextThrow = CurTime() + self.Owner:GetViewModel():SequenceDuration()
				self.StartIdle = CurTime() + self.Owner:GetViewModel():SequenceDuration()
			end
			if self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 and self:Clip1() <= 0 then
				self.Owner:RemoveAmmo(1, self.Primary.Ammo)
				self:SetClip1(self:Clip1() + 1)
			end
		end

	end

	return true

end

function SWEP:Holster()
	self.StartThrow = false
	self.Throwing = false
	self.ResetThrow = false
	return true
end

function SWEP:CreateGrenade()

	if IsValid(self.Owner) and IsValid(self.Weapon) and SERVER then

		local ent = ents.Create("rj_molotov")
		if not ent then return end
		ent.Owner = self.Owner
		ent.Inflictor = self.Weapon
		ent:SetOwner(self.Owner)
		local eyeang = self.Owner:GetAimVector():Angle()
		local right = eyeang:Right()
		local up = eyeang:Up()
		ent:SetPos(self.Owner:GetShootPos() + right * 6 + up * -2)
		ent:SetAngles(self.Owner:GetAngles())
		ent:SetPhysicsAttacker(self.Owner)
		ent:Spawn()

		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(self.Owner:GetAimVector() * self.ThrowVel + (self.Owner:GetVelocity() * 0.5))
			phys:ApplyForceOffset(ent:GetUp() * math.random(-25,-50), ent:GetPos() + ent:GetRight() * math.random(-5,5))
		end

	end

end

local bobtime 	= 10
local bobscale 	= 0.0125
local xoffset 	= 0
local yoffset 	= 0

function SWEP:Think()

	if not IsValid(self.Owner) then return end

	if (self.Owner:KeyDown(IN_FORWARD) or self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_MOVELEFT) or self.Owner:KeyDown(IN_MOVERIGHT) or self.Owner:KeyDown(IN_BACK)) and not self.Owner:KeyDown(IN_JUMP) and self.Owner:IsOnGround() and not self.StartIdle and not self.StartThrow and not self.Throwing then
		self.Idle = false
		if self.Owner:KeyDown(IN_SPEED) and not self.Owner:KeyDown(IN_DUCK) then
			self.Walk = false
			if not self.Run then
				self.Weapon:SendWeaponAnim(ACT_VM_IDLE_DEPLOYED_1)
				self.Run = true
			end
			bobtime = self.Owner:GetRunSpeed() / 20
		else
			self.Run = false
			if not self.Walk then
				self.Weapon:SendWeaponAnim(ACT_WALK)
				self.Walk = true
			end
			bobtime = self.Owner:GetWalkSpeed() / 15
		end
		local xoffset = math.sin(CurTime() * bobtime) * self.Owner:GetVelocity():Length() * bobscale / 100
		local yoffset = math.sin(2 * CurTime() * bobtime) * self.Owner:GetVelocity():Length() * bobscale / 400
		self.Owner:ViewPunch(Angle(xoffset,yoffset,0))
	elseif (not self.Idle or (self.StartIdle and self.StartIdle < CurTime())) and not self.StartThrow and not self.Throwing then
		self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
		self.Run = false
		self.Walk = false
		self.Idle = true
		self.StartIdle = nil
	end

	if not self.StartIdle and not self.Throwing and not self.StartThrow and not self.Owner:KeyDown(IN_SPEED) and self.Owner:KeyDown(IN_ATTACK) and not (self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 and self:Clip1() <= 0) then
		self.StartThrow = true
		self.Weapon:SendWeaponAnim(ACT_VM_PULLPIN)
		if IsValid(self.Owner:GetViewModel()) then
			self.NextThrow = CurTime() + self.Owner:GetViewModel():SequenceDuration()
			self.Weapon:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
			self.Weapon:SetNextSecondaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
		end
	end

	if self.StartThrow and not self.Owner:KeyDown(IN_ATTACK) and not self.Owner:KeyDown(IN_SPEED) and self.NextThrow < CurTime() then

		self.StartThrow = false
		self.Throwing = true
		self.Weapon:SendWeaponAnim(ACT_VM_THROW)
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		self:CreateGrenade(self.Owner, self.Weapon)
		self:TakePrimaryAmmo(1)
		self.NextAnimation = CurTime() + self.Primary.Delay
		self.ResetThrow = true

	elseif self.Owner:KeyDown(IN_SPEED) then

		self.StartThrow = false
		self.ResetThrow = false
		self.Throwing = false

	end

	if self.Throwing and self.ResetThrow and self.NextAnimation < CurTime() then

		if self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 and self:Clip1() <= 0 then

			self.Owner:RemoveAmmo(1, self.Primary.Ammo)
			self:SetClip1(self:Clip1() + 1)
			self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
			if IsValid(self.Owner:GetViewModel()) then
				self.NextThrow = CurTime() + self.Owner:GetViewModel():SequenceDuration()
				self.StartIdle = CurTime() + self.Owner:GetViewModel():SequenceDuration()
				self.Weapon:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
				self.Weapon:SetNextSecondaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
			end

		elseif self.Owner:GetAmmoCount(self.Primary.Ammo) == 0 and self:Clip1() == 0 then
			self.Owner:ConCommand("lastinv")
		end

		self.ResetThrow = false
		self.Throwing = false

	end

end

function SWEP:CanPrimaryAttack()
	return false
end

function SWEP:PrimaryAttack()
	return false
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:Reload()
end

function SWEP:ShouldDropOnDie()
	return false
end

local ENT = {}

ENT.PrintName = "Molotov"
ENT.Type = "anim"
ENT.Base = "base_anim"

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end

if SERVER then

	function ENT:Initialize()

		self:SetModel("models/nmrih/weapons/exp_molotov/w_exp_molotov.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
			phys:EnableDrag(false)
			phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
			phys:SetBuoyancyRatio(0)
		end

		self.BurnSound = CreateSound(self, "Weapon_NMRiH_Molotov.Rag_Loop")
		self.BurnSound:Play()

		self:Fire("kill", 1, 10)

	end

	function ENT:Think()

		if self.HitData and not hull then

			if self.Dud then
				self:NextThink(CurTime() + 300)
				self:Remove()
				return false
			end

			local hull = ents.Create("rj_molotov_hull")
			if not hull then return end
			hull:SetPos(self.HitData.HitPos + self.HitData.HitNormal * 40)
			hull:SetAngles(self.HitData.HitNormal:Angle() + Angle(90,0,0))
			hull:SetOwner(self.Owner)
			hull.Owner = self.Owner
			hull.vFirePos = self.HitData.HitPos
			hull.vFireVel = self.HitData.Velocity or vector_origin
			hull.Inflictor = self.Weapon
			hull:Spawn()

			self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			self:SetMoveType(MOVETYPE_NONE)
			self:Remove()

		end

		self:NextThink(CurTime())

	end

	function ENT:OnRemove()
		if self.BurnSound then
			self.BurnSound:Stop()
		end
	end

	function ENT:PhysicsCollide(data, phys)

		if IsValid(self) and not self.Hit then

			self:SetNoDraw(true)

			local trdata = {}
			trdata.start = data.HitPos
			trdata.endpos = data.HitPos + data.HitNormal
			local tr = util.TraceLine(trdata)

			if tr.Hit then

				self.HitData = tr
				self.HitData.Velocity = self:GetVelocity()
				self.Hit = true

				if self:WaterLevel() > 0 then
					self.Dud = true
					self:EmitSound("physics/glass/glass_bottle_break"..math.random(1,2)..".wav", 90, 100)
					return false
				end

				if IsValid(self.Owner) then
					util.BlastDamage(self, self.Owner, self:GetPos(), 300, 60)
				else
					util.BlastDamage(self, self, self:GetPos(), 300, 60)
				end

				if not vFireInstalled or (vFireInstalled and GetConVar("vfire_molotov_enabled") and not GetConVar("vfire_molotov_enabled"):GetBool()) then -- emit the original particle effect if vFire is disabled/missing
					ParticleEffect("nmrih_molotov_explosion",tr.HitPos,tr.HitNormal:Angle() + Angle(90,0,0))
				end

				self:EmitSound("Weapon_NMRiH_Molotov.Explode")

			end

		end

	end

end

scripted_ents.Register(ENT, "rj_molotov", true)

local HULL = {}

HULL.PrintName = "Molotov Point Hurt"
HULL.Type = "anim"
HULL.Base = "base_anim"

if CLIENT then
	net.Receive("Molotov_vFireBall",function()
		if vFireInstalled then
			local rad = net.ReadFloat()
			local pos = net.ReadVector()
			local vel = net.ReadVector()
			molotov_vFireBall = CreateCSVFireBall(rad, pos, vel, 20, false)
		end
	end)
end

if SERVER then

	util.AddNetworkString("Molotov_vFireBall")

	function HULL:Initialize()

		self:SetModel("models/hunter/blocks/cube4x4x2.mdl")
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
		self:SetNoDraw(true)
		self:SetTrigger(true)

		self.NextHurt = CurTime()

		self.BurnSound = CreateSound(self, "ambient/fire/fire_small_loop1.wav")
		self.BurnSound:PlayEx(1,98)
		self.BurnSound:SetSoundLevel(80)

		self:Fire("kill", 1, 10)

		if vFireInstalled and GetConVar("vfire_molotov_enabled") and GetConVar("vfire_molotov_enabled"):GetBool() and self.vFirePos then --vFire is installed and enabled, make a vFire

			local rad = self:BoundingRadius()
			local vel = self:GetUp() * 10

			for i=1,8 do
				self.vFire = CreateVFire(self, self:GetPos() + (self:GetForward() * VectorRand() * rad / 2) + (self:GetRight() * VectorRand() * rad / 2) - self:GetUp() * 40, self:GetUp(), 40)
			end

			self.vFireBall = CreateVFireBall(rad, rad * 2, self.vFirePos, vel, self:GetOwner() or self.Owner or self)

			net.Start("Molotov_vFireBall")
				local filter = RecipientFilter()
				filter:AddAllPlayers()
				net.WriteFloat(rad)
				net.WriteVector(self.vFirePos)
				net.WriteVector(vel)
			net.Send(filter)

		end

	end

	function HULL:Touch(victim)

		if self.NextHurt < CurTime() then

			local attacker = self:GetOwner() or self.Owner or self
			local inflictor = self.Inflictor or self
			if not IsValid(attacker) then return end

			local dmg = DamageInfo()
			dmg:SetDamage(8)
			dmg:SetDamageType(DMG_BURN)
			dmg:SetDamagePosition(self:GetPos())
			dmg:SetDamageForce(Vector(0,0,0))
			dmg:SetAttacker(attacker)
			dmg:SetInflictor(inflictor)

			if IsValid(victim) then
				victim:TakeDamageInfo(dmg)
				victim:Ignite(1,10)
			end

			self.NextHurt = CurTime() + 0.25

		end

	end

	function HULL:Think()
		self:NextThink(CurTime())
	end

	function HULL:OnRemove()
		if self.BurnSound then
			self.BurnSound:Stop()
		end
	end

end

local function vFireSurfaceDamageFix(ent,dmginfo)
	local attacker = dmginfo:GetAttacker()
	local dmgtype = dmginfo:GetDamageType()
	if vFireInstalled and IsValid(ent) and IsValid(attacker) and dmgtype == DMG_BURN then
		local owner = attacker:GetOwner() or attacker.Owner
		if IsValid(owner) and owner:IsPlayer() then
			dmginfo:SetAttacker(owner)
		end
	end
end
hook.Add("EntityTakeDamage","vFireSurfaceDamageFix",vFireSurfaceDamageFix)

scripted_ents.Register(HULL, "rj_molotov_hull", true)

local AMMO = {}

AMMO.PrintName = "Molotov Bottle"
AMMO.Type = "anim"
AMMO.Base = "base_anim"
AMMO.Spawnable = true
AMMO.AdminOnly = false
AMMO.Category = "Anya O'Quinn"

if SERVER then

	function AMMO:Initialize()

		self:SetModel("models/nmrih/weapons/exp_molotov/w_exp_molotov.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:SetTrigger(true)

		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
			phys:EnableDrag(true)
			phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
			phys:SetBuoyancyRatio(0.5)
		end

	end

	function AMMO:SpawnFunction(ply,tr,class)

		if not tr.Hit then return end

		local pos = tr.HitPos + tr.HitNormal * 10

		local ent = ents.Create(class)
		if not ent then return end
		ent:SetPos(pos)
		ent:Spawn()
		ent:Activate()

		return ent

	end

	function AMMO:StartTouch(ply)
		if IsValid(self) and IsValid(ply) and ply:IsPlayer() then
			ply:GiveAmmo(5,"molotov")
			self:Remove()
		end
	end

end

scripted_ents.Register(AMMO, "rj_molotov_ammo", true)

-- 37062385
