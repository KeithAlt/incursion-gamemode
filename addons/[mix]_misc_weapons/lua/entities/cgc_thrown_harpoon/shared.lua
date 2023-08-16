ENT.Type 			= "anim"
ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions		= ""
ENT.Spawnable			= false
ENT.AdminOnly = true
ENT.DoNotDuplicate = true
ENT.DisableDuplicator = true
ENT.ImpactDamage = 25

ENT.Hit = {
	Sound("physics/metal/metal_grenade_impact_hard1.wav"),
	Sound("physics/metal/metal_grenade_impact_hard2.wav"),
	Sound("physics/metal/metal_grenade_impact_hard3.wav")
};

ENT.FleshHit = {
	Sound("physics/flesh/flesh_impact_bullet1.wav"),
	Sound("physics/flesh/flesh_impact_bullet2.wav"),
	Sound("physics/flesh/flesh_impact_bullet3.wav")
}

util.PrecacheSound("physics/metal/metal_grenade_impact_hard3.wav")
util.PrecacheSound("physics/metal/metal_grenade_impact_hard2.wav")
util.PrecacheSound("physics/metal/metal_grenade_impact_hard1.wav")
util.PrecacheSound("physics/flesh/flesh_impact_bullet1.wav")
util.PrecacheSound("physics/flesh/flesh_impact_bullet2.wav")
util.PrecacheSound("physics/flesh/flesh_impact_bullet3.wav")


if SERVER then
	AddCSLuaFile("shared.lua")

	function ENT:Initialize()
		self:SetModel("models/props_junk/harpoon002a.mdl")

		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
			phys:SetMass(0.001)
		end

		self.InFlight = true
		self.AirTime = CurTime()
		self:GetPhysicsObject():SetMass(2)
		self.Entity:SetUseType(SIMPLE_USE)

		self.CanTool = false
	end


	function ENT:Think()
		if !IsValid(self) then return end

		if self.InFlight and self.Entity:GetAngles().pitch <= 55 then
			self.Entity:GetPhysicsObject():AddAngleVelocity(Vector(0, 10, 0))
		end

		if (self.lifeTime and self.lifeTime < CurTime()) then
			SafeRemoveEntity(self)
		end

		if(self.hitEntity and !self.disabled) then
			self.disabled = true

			self:entityHit(self.hitEntity, self.hitData)
		end
	end

	function ENT:entityHit(entity, data)
		-- Don't collide with anything but world
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

		self:GetPhysicsObject():SetVelocity(data.OurOldVelocity / 20)

		if (data.Speed > 500) then
			-- Don't collide with anything at all (including world)
			self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

			self:EmitSound(Sound("weapons/blades/impact.mp3"))
			self:SetPos(data.HitPos - data.HitNormal * 10)
			self:SetAngles(self:GetAngles())
			self:GetPhysicsObject():EnableMotion(false)

			if(IsValid(entity)) then
				self:SetParent(entity)
			end
		else
			self:EmitSound(self.Hit[math.random(1, #self.Hit)])
		end

		if (entity.Health) then -- If it has health do things to it
			-- Checks if the hit entity bleeds
			if(entity.GetBloodColor and entity:GetBloodColor() ==
BLOOD_COLOR_RED) then
				-- Blood effect
				local effectdata = EffectData()
				effectdata:SetStart(data.HitPos)
				effectdata:SetOrigin(data.HitPos)
				effectdata:SetScale(1)
				util.Effect("BloodImpact", effectdata)

				-- Meaty Sounds
				self:EmitSound(self.FleshHit[math.random(1,#self.Hit)])
				self:EmitSound("physics/flesh/flesh_bloody_break.wav")
			end

			-- Damage
			entity:TakeDamage(self.ImpactDamage)

			-- Player specific
			if(entity:IsPlayer()) then
				entity:AddSpeed(-50, 10)
			end
		else
			util.Decal("ManhackCut", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal)
			self:EmitSound(self.Hit[math.random(1, #self.Hit)])
		end

		self.lifeTime = CurTime() + 30
	end

	function ENT:PhysicsCollide(data, phys)
		if(self.targetHit) then return end

		local entity = data.HitEntity

		if (!IsValid(entity) and !entity:IsWorld()) then return end

		-- Something has been hit, so no longer in flight
		self.InFight = false
		self.hitEntity = entity
		self.hitData = data

		self:NextThink(CurTime())
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end
