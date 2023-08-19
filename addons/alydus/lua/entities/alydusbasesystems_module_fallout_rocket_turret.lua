--[[ 
	© Alydus.net
	Do not reupload lua to workshop without permission of the author
	Alydus Base Systems
	Alydus: (officialalydus@gmail.com | STEAM_0:1:57622640)
--]]

ENT.Type = "anim"
ENT.Base = "alydusbasesystems_module_base"

ENT.Spawnable = true
ENT.Category = "Alydus Base Systems"

ENT.PrintName = "Module - Rocket Turret"
ENT.Author = "Alydus"
ENT.Contact = "Alydus"
ENT.Purpose = ""
ENT.Instructions = ""

function ENT:Initialize()
	self.range = 2048 --attack range

	if SERVER then
		self:SetModel("models/weapons/keitho/turrets/rocketturret.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		--self.dmg = 5 --attack damage
		self.firingDelay = 3.5 --delay between firing
		self.nextFire = 0
		self.accuracy = Vector(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))

		self:SetNWInt("alydusBaseSystems.Ammo", 15)
		self:SetNWInt("alydusBaseSystems.Health", 300)

		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(1000000)
			phys:Wake()
		end

		self:SetNWEntity("alydusBaseSystems.Owner", nil)
		self:SetNWEntity("alydusBaseSystems.FiringTarget", nil)
		
		self:SetNWBool("alydusBaseSystems.IsShooting", false)
        
        if IsValid(self:Getowning_ent()) then
            self:SetNWEntity("alydusBaseSystems.Owner", self:Getowning_ent())
        end

		if WireAddon then
			self.Outputs = Wire_CreateOutputs(self, {
				"Module Health"
			})
			Wire_TriggerOutput(self, "Module Health", self:GetNWInt("alydusBaseSystems.Health", 0))
		end

        self:DropToFloor()
	end
end

function ENT:FireThink()
	local timeLeft = self.nextFire - CurTime()
	if timeLeft <= 0 then
		local firingTarget = self:GetNWEntity("alydusBaseSystems.FiringTarget", nil)
		if IsValid(firingTarget) and self:GetNWEntity("alydusBaseSystems.Health", 0) >= 1 and self:GetPos():DistToSqr(firingTarget:GetPos()) <= (self.range * self.range) and IsValid(self:GetNWEntity("alydusBaseSystems.Owner", nil)) then			
			if self:GetNWInt("alydusBaseSystems.Ammo") >= 1 then
				local firingSource = self:GetPos() + self:GetUp()
				local spread = Vector(math.random(-25, 25), math.random(-25, 25), math.random(-25, 25))
				local firingDirection = firingTarget:LocalToWorld(firingTarget:OBBCenter() + spread) - firingSource

				if not self.firingBlock then
					self.firingBlock = ents.Create("prop_physics")
					self.firingBlock:SetModel("models/hunter/blocks/cube025x025x025.mdl")
					self.firingBlock:SetPos(self:GetPos() + (self:GetAngles():Up() * 51.5) + (self:GetAngles():Right() * -9.3))
					self.firingBlock:SetParent(self)
					self.firingBlock:SetColor(Color(0, 0, 0, 0))
					self.firingBlock:SetRenderMode(RENDERMODE_TRANSALPHA)
				else
					self.firingBlock:SetPos(self:GetPos() + (firingDirection:Angle():Up() * 45.5) + (firingDirection:Angle():Forward() * 50) + (self:GetAngles():Right() * 10))
					self.firingBlock:SetAngles(firingDirection:Angle())
				end

				local canFire = true

				local tr = util.TraceLine({
					start = self.firingBlock:LocalToWorld(self.firingBlock:OBBCenter()),
					endpos = firingTarget:LocalToWorld(firingTarget:OBBCenter()),
					filter = {self, self.firingBlock}
				})

				if tr.HitWorld then
					canFire = false
				end

				if tr.HitSky then
					canFire = false
				end

				if not IsValid(tr.Entity) then
					canFire = false
				end

				local isEither = false

				--[[
				if tr.Entity:IsNPC() or tr.Entity:IsPlayer() then
					isEither = true
				end
				--]]

				if tr.Entity == firingTarget then
					isEither = true
				end

				if not isEither then
					canFire = false
				end

				if canFire then
					local rocket = ents.Create("rpg_missile")
					rocket:SetPos(self.firingBlock:GetPos())
					rocket:SetAngles(firingDirection:Angle() - Angle(-2, 0, 0))
					rocket:SetOwner(self)
					rocket:Spawn()
					rocket:SetVelocity(rocket:GetForward() * 1500)
					rocket:SetSaveValue("m_flDamage", GetConVar("sv_alydusbasesystems_config_samturret_damage"):GetInt())

					self:EmitSound("alydus/fo4rocketfire.wav", 60)

					timer.Simple(7.15, function()
						if IsValid(rocket) then
							rocket:Remove()
						end
					end)

					util.ScreenShake(self:GetPos() + Vector(0, 0, 30), 5, 5, 1.25, 200)

					self:SetNWInt("alydusBaseSystems.Ammo", self:GetNWInt("alydusBaseSystems.Ammo", 0) - 1)
					self:SetNWBool("alydusBaseSystems.IsShooting", true)
				else
					self:SetNWBool("alydusBaseSystems.IsShooting", false)
				end
			else
				self:SetNWBool("alydusBaseSystems.IsShooting", false)
			end
		else
			self:SetNWBool("alydusBaseSystems.IsShooting", false)
		end

		self.nextFire = CurTime() + self.firingDelay
	end
end

function ENT:Think()
	self:TurretThink()
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()

		local upAngle = 45
		local spinSpeed = 50
		local spinAngle = 0
		local disableRest = false

		if IsValid(self:GetNWEntity("alydusBaseSystems.Owner")) and self:GetNWInt("alydusBaseSystems.Health", 0) >= 1 and self:GetNWInt("alydusBaseSystems.Ammo") >= 1 then
			upAngle = 0

			local target = self:GetNWEntity("alydusBaseSystems.FiringTarget")
			if not IsValid(target) or (target:Health() < 1) or target:GetPos():DistToSqr(self:GetPos()) >= self.range*self.range then
				spinAngle = spinSpeed * CurTime()
			elseif IsValid(self:GetNWEntity("alydusBaseSystems.FiringTarget")) then
				local firingTarget = self:GetNWEntity("alydusBaseSystems.FiringTarget", nil)
				local firingSource = self:GetPos()
				local firingDirection = self:WorldToLocal(firingTarget:LocalToWorld(firingTarget:OBBCenter())):Angle() - Angle(-7.5, 0, 0)

				self:ManipulateBoneAngles(2, firingDirection)
				disableRest = true
			end
		end

		if not disableRest then
			self:ManipulateBoneAngles(2, Angle(upAngle, spinAngle, 0))
		end
	end
else
	AddCSLuaFile()
end