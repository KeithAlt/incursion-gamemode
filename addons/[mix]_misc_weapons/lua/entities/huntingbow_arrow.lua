AddCSLuaFile()

ENT.Type      = "anim"
ENT.Spawnable = false

ENT.Model = "models/weapons/w_huntingbow_arrow.mdl"

local ARROW_MINS = Vector(-0.25, -0.25, 0.25)
local ARROW_MAXS = Vector(0.25, 0.25, 0.25)

function ENT:Initialize()
	if not SERVER then
		return
	end

	self:SetModel(self.Model)
	self:Ignite(10)

	self:PhysicsInit(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_FLYGRAVITY)
	self:DrawShadow(true)

	self:SetCollisionBounds(ARROW_MINS, ARROW_MAXS)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
	end
end

function ENT:Think()
	if not SERVER then
		return
	end

	if self:GetMoveType() == MOVETYPE_FLYGRAVITY then
		self:SetAngles(self:GetVelocity():Angle())
	end
end

function ENT:Use(activator, caller)
	return false
end

function ENT:OnRemove()
	return false
end

local StickSound = {
	"weapons/huntingbow/impact_arrow_stick_1.wav",
	"weapons/huntingbow/impact_arrow_stick_2.wav",
	"weapons/huntingbow/impact_arrow_stick_3.wav"
}

local FleshSound = {
	"weapons/huntingbow/impact_arrow_flesh_1.wav",
	"weapons/huntingbow/impact_arrow_flesh_2.wav",
	"weapons/huntingbow/impact_arrow_flesh_3.wav",
	"weapons/huntingbow/impact_arrow_flesh_4.wav"
}

function ENT:Touch(ent)
	local vel   = self:GetVelocity()
	local speed = vel:Length()

	local tr = self:GetTouchTrace()
	local tr2

	if not tr.Hit then
		return
	end

	local damage = math.floor(math.Clamp(speed / 25, 0, 60))

	self.Owner:FireBullets {
		Damage = damage,
		Attacker = self.Owner,
		Inflictor = self.Weapon,
		Callback = function(attacker, tr, damageinfo) tr2 = tr end,
		Force = damage * 0.1,
		Tracer = 0,
		Src = tr.StartPos,
		Dir = tr.Normal,
		AmmoType = "huntingbow_arrows"
	}

	if ent:IsWorld() then
		sound.Play(table.Random(StickSound), tr.HitPos)

		self:SetMoveType(MOVETYPE_NONE)
		self:PhysicsInit(SOLID_NONE)

		SafeRemoveEntityDelayed(self, 10)
		return
	end

	if ent:IsValid() then
		if ent:IsNPC() or ent:IsPlayer() then
			if tr2.Entity == ent then sound.Play(table.Random(FleshSound), tr.HitPos) end
			self:Remove()
			ent:Ignite(6)
		else
			self:SetParent(ent)
			sound.Play(table.Random(StickSound), tr.HitPos)

			self:SetMoveType(MOVETYPE_NONE)
			self:SetSolid(SOLID_NONE)

			SafeRemoveEntityDelayed(self, 10)
		end
	end
end

function ENT:PhysicsCollide(data, physobj)

end
