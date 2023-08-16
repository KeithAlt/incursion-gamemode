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

ENT.PrintName = "Module - Spotlight"
ENT.Author = "Alydus"
ENT.Contact = "Alydus"
ENT.Purpose = ""
ENT.Instructions = ""

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/weapons/keitho/turrets/spotlight.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		self.range = 2048 --attack range
		self.dmg = 5 --attack damage
		self.firingDelay = 0.25 --delay between firing
		self.nextFire = 0
		self.accuracy = Vector(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))

		self:SetNWInt("alydusBaseSystems.Health", GetConVar("sv_alydusbasesystems_config_module_defaulthealth"):GetInt())

		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(1000000)
			phys:Wake()
		end

		self:SetNWEntity("alydusBaseSystems.Owner", nil)
		self:SetNWEntity("alydusBaseSystems.FiringTarget", nil)
		self:SetNWInt("alydusBaseSystems.Ammo", 0)
		self:SetNWBool("alydusBaseSystems.IsShooting", false)

        self.lightEffect =  ents.Create("prop_physics")
        self.lightEffect:SetModel("models/effects/vol_light128x512.mdl")
        self.lightEffect:SetPos(self:GetPos() + self:GetUp() * 50)
        self.lightEffect:SetAngles(self:GetAngles() + Angle(-90, 0, 0))
        self.lightEffect:SetParent(self)
        self.lightEffect:DrawShadow(false)
        self.lightEffect:Spawn()
        self.lightEffect:SetNoDraw(true)

        self.lightMuzzle = ents.Create("env_sprite")
        self.lightMuzzle:SetPos(self:GetPos() + (self:GetUp() * 50))
        self.lightMuzzle:SetAngles(self:GetAngles())
		self.lightMuzzle:SetKeyValue("model", "sprites/light_glow01.vmt")
		self.lightMuzzle:SetKeyValue("scale", 5)
		self.lightMuzzle:SetKeyValue("rendermode", 5)
		self.lightMuzzle:SetKeyValue("renderfx", 7)
        self.lightMuzzle:SetParent(self)
        self.lightMuzzle:Spawn()
        self.lightMuzzle:SetNoDraw(true)
		
        self.lightTarget = nil

        self.randomOffset = math.random(1, 180)
		
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
				local firingSource = self:GetPos()
				local firingDirection = firingTarget:LocalToWorld(firingTarget:OBBCenter()) - firingSource

				if not self.firingBlock then
					self.firingBlock = ents.Create("prop_physics")
					self.firingBlock:SetModel("models/hunter/blocks/cube025x025x025.mdl")
					self.firingBlock:SetPos(self:GetPos() + (firingDirection:Angle():Up() * 35.5) + (firingDirection:Angle():Forward() * 40))
					self.firingBlock:SetParent(self)
					self.firingBlock:SetColor(Color(0, 0, 0, 0))
					self.firingBlock:SetRenderMode(RENDERMODE_TRANSALPHA)
				else
					self.firingBlock:SetPos(self:GetPos() + (firingDirection:Angle():Up() * 35.5) + (firingDirection:Angle():Forward() * 53.5))
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

function ENT:targetInRange()
	local range = GetConVar("sv_alydusbasesystems_config_gunturret_range"):GetInt()
	local target = self:GetNWEntity("alydusBaseSystems.FiringTarget", nil)
	
	if (
		IsValid(target) and 
		target:GetPos():DistToSqr(self:GetPos()) <= (range * range)) or 
		self:GetNWInt("alydusBaseSystems.Health", 0) <= 0 or not 
		IsValid(self:GetNWEntity("alydusBaseSystems.Owner", nil)) 
	then 
		return false
	else
		return true
	end
end

function ENT:Think()
	if SERVER then
		if not IsValid(self:GetNWEntity("alydusBaseSystems.Owner", nil)) or self:GetNWInt("alydusBaseSystems.Health", 0) <= 0 then
			if not self.lightEffect:SetNoDraw() then
				self.lightEffect:SetNoDraw(true)
			end

			if not self.lightMuzzle:SetNoDraw() then
				self.lightMuzzle:SetNoDraw(true)
			end

			return
		end	
		
		local firingTarget = self:GetNWEntity("alydusBaseSystems.FiringTarget", nil)
		if(IsValid(firingTarget)) then
			if self.lightEffect:SetNoDraw() then
				self.lightEffect:SetNoDraw(false)
			end

			if self.lightMuzzle:SetNoDraw() then
				self.lightMuzzle:SetNoDraw(false)
			end
			
			self.lightMuzzle:PointAtEntity(firingTarget)
			self.lightEffect:PointAtEntity(firingTarget)
			self.lightEffect:SetAngles(self.lightEffect:GetAngles() + Angle(-95, 0, 0))
		else
			self.lightMuzzle:SetNoDraw(true)
			self.lightEffect:SetNoDraw(true)
		end
	
		local foundPotentialTargetsNPC = foundPotentialTargetsNPC or {}
		local foundPotentialTargetsPlayers = foundPotentialTargetsPlayers or {}
		local firingNPC = firingNPC or false

		--firing loop
		self:FireThink()

		--checks if target is in range
		local inRange = self:targetInRange()
		if(!inRange) then
			return
		end

		foundPotentialTargetsPlayers, foundPotentialTargetsNPC = self:scanForTargets()

		if #foundPotentialTargetsPlayers >= 1 then
			if GetConVar("sv_alydusbasesystems_config_gunturret_prioritisenearbytargets"):GetInt() == 1 and #foundPotentialTargetsPlayers > 1 then
				table.sort(foundPotentialTargetsPlayers, function(a, b) return self:GetPos():DistToSqr(a:GetPos()) < self:GetPos():DistToSqr(b:GetPos()) end)
			end
			self:SetNWEntity("alydusBaseSystems.FiringTarget", foundPotentialTargetsPlayers[1])
			self:EmitSound("alydus/fo4turretlockon.wav")
			firingNPC = false
		elseif #foundPotentialTargetsNPC >= 1 then
			if GetConVar("sv_alydusbasesystems_config_gunturret_prioritisenearbytargets"):GetInt() == 1 and #foundPotentialTargetsNPC > 1  then
				table.sort(foundPotentialTargetsNPC, function(a, b) return self:GetPos():DistToSqr(a:GetPos()) < self:GetPos():DistToSqr(b:GetPos()) end)
			end
			
			self:SetNWEntity("alydusBaseSystems.FiringTarget", foundPotentialTargetsNPC[1])
			self:EmitSound("alydus/fo4turretlockon.wav")
			firingNPC = true
		end

		self:NextThink(CurTime() + self.firingDelay)
		
		return true
	end
end


if CLIENT then
	function ENT:Draw()
		self:DrawModel()

		local upAngle = 45
		local spinSpeed = 50
		local spinAngle = 0
		local barrelSpinSpeed = 5000
		local barrelSpin = 0
		local disableRest = false

		if IsValid(self:GetNWEntity("alydusBaseSystems.Owner")) and self:GetNWInt("alydusBaseSystems.Health", 0) >= 1 then
			upAngle = 0

			if not IsValid(self:GetNWEntity("alydusBaseSystems.FiringTarget")) or self:GetNWEntity("alydusBaseSystems.FiringTarget"):GetPos():Distance(self:GetPos()) >= 1000 then
				spinAngle = spinSpeed * CurTime()
			elseif IsValid(self:GetNWEntity("alydusBaseSystems.FiringTarget")) then
				local firingTarget = self:GetNWEntity("alydusBaseSystems.FiringTarget", nil)
				local firingSource = self:GetPos()
				local firingDirection = self:WorldToLocal(firingTarget:LocalToWorld(firingTarget:OBBCenter())):Angle() - Angle(-7.5, 0, 0)

				self:ManipulateBoneAngles(2, firingDirection)
				disableRest = true
			end

			if self:GetNWBool("alydusBaseSystems.IsShooting", false) == true then
				--barrelSpin = barrelSpinSpeed * CurTime()
			end
		end

		if not disableRest then
			self:ManipulateBoneAngles(2, Angle(upAngle, spinAngle, 0))
		end
		self:ManipulateBoneAngles(3, Angle(0, 0, barrelSpin))
	end
else
	AddCSLuaFile()
end