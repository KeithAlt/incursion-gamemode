--[[ 
	© Alydus.net
	Do not reupload lua to workshop without permission of the author
	Alydus Base Systems
	Alydus: (officialalydus@gmail.com | STEAM_0:1:57622640)
--]]

if CLIENT then
	function ENT:Draw()
		self:DrawModel()		
		local upAngle = 45
		local spinSpeed = 50
		local spinAngle = 0
		local barrelSpinSpeed = 5000
		local barrelSpin = 0
		local disableRest = false
		if IsValid(self:GetNWEntity("alydusBaseSystems.Owner")) and self:GetNWInt("alydusBaseSystems.Health", 0) >= 1 and self:GetNWInt("alydusBaseSystems.Ammo") >= 1 then
			upAngle = 0
			if not IsValid(self:GetNWEntity("alydusBaseSystems.FiringTarget")) or self:GetNWEntity("alydusBaseSystems.FiringTarget"):GetPos():Distance(self:GetPos()) >= GetConVar("sv_alydusbasesystems_config_laserturret_range"):GetInt() then
				spinAngle = spinSpeed * CurTime()
			elseif IsValid(self:GetNWEntity("alydusBaseSystems.FiringTarget")) then
				local firingTarget = self:GetNWEntity("alydusBaseSystems.FiringTarget", nil)
				local firingSource = self:GetPos()
				local firingDirection = self:WorldToLocal(firingTarget:LocalToWorld(firingTarget:OBBCenter())):Angle() - Angle(-7.5, 0, 0)
				self:ManipulateBoneAngles(2, firingDirection)
				disableRest = true
			end			
			if self:GetNWBool("alydusBaseSystems.IsShooting", false) == true then
				barrelSpin = barrelSpinSpeed * CurTime()
			end
		end		
		if not disableRest then
			self:ManipulateBoneAngles(2, Angle(upAngle, spinAngle, 0))
		end
		self:ManipulateBoneAngles(4, Angle(0, 0, barrelSpin))
	end
else
	AddCSLuaFile()
end

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/weapons/alydus/turrets/laserturret.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(1000000)
			phys:Wake()
		end

		self:SetNWEntity("alydusBaseSystems.Owner", nil)
		self:SetNWEntity("alydusBaseSystems.FiringTarget", nil)
		self:SetNWInt("alydusBaseSystems.Health", GetConVar("sv_alydusbasesystems_config_module_defaulthealth"):GetInt())
		self:SetNWInt("alydusBaseSystems.Ammo", 0)
		self:SetNWBool("alydusBaseSystems.IsShooting", false)

		self.firingDelay = 0.0001
		self.nextFire = 0
        
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

function ENT:Think()
	if SERVER then
		local foundPotentialTargetsNPC = foundPotentialTargetsNPC or {}
		local foundPotentialTargetsPlayers = foundPotentialTargetsPlayers or {}
		local firingNPC = firingNPC or false

		local timeLeft = self.nextFire - CurTime()
		if timeLeft <= 0 then
			local firingTarget = self:GetNWEntity("alydusBaseSystems.FiringTarget", nil)
			if IsValid(firingTarget) and self:GetNWEntity("alydusBaseSystems.Health", 0) >= 1 and self:GetPos():Distance(firingTarget:GetPos()) <= GetConVar("sv_alydusbasesystems_config_laserturret_range"):GetInt() and IsValid(self:GetNWEntity("alydusBaseSystems.Owner", nil)) then
				if self:GetNWInt("alydusBaseSystems.Ammo") >= 1 then
					local firingSource = self:GetPos()
					local firingDirection = firingTarget:LocalToWorld(firingTarget:OBBCenter()) - firingSource
					if not self.firingBlock then
						self.firingBlock = ents.Create("prop_physics")
						self.firingBlock:SetModel("models/hunter/blocks/cube025x025x025.mdl")
						self.firingBlock:SetPos(self:GetPos() + (firingDirection:Angle():Up() * 48.5) + (firingDirection:Angle():Forward() * 30))
						self.firingBlock:SetParent(self)
						self.firingBlock:SetColor(Color(0, 0, 0, 0))
						self.firingBlock:SetRenderMode(RENDERMODE_TRANSALPHA)
					else
						self.firingBlock:SetPos(self:GetPos() + (firingDirection:Angle():Up() * 48.5) + (firingDirection:Angle():Forward() * 45))
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
					if tr.Entity:IsNPC() or tr.Entity:IsPlayer() then
						isEither = true
					end
					if not isEither then
						canFire = false
					end
					if canFire then
						local bulletStructure = {}
						bulletStructure.Attacker = self:GetNWEntity("alydusBaseSystems.Owner")
						bulletStructure.Damage = GetConVar("sv_alydusbasesystems_config_laserturret_bulletdamage"):GetInt()
						bulletStructure.Force = GetConVar("sv_alydusbasesystems_config_laserturret_bulletforce"):GetInt()
						bulletStructure.Distance = GetConVar("sv_alydusbasesystems_config_laserturret_range"):GetInt()
						bulletStructure.HullSize = 0
						bulletStructure.Num = 1
						bulletStructure.Tracer = 0
						bulletStructure.TracerName = nil
						bulletStructure.Dir = firingDirection
						bulletStructure.Spread = Vector(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
						bulletStructure.Src = firingSource
						bulletStructure.IgnoreEntity = self
						bulletStructure.Callback = function(attacker, trace, dmgInfo)
							dmgInfo:SetDamageType(DMG_DISSOLVE)
							if trace.HitPos then
								sound.Play("alydus/laserimpact" .. math.random(1, 4) .. ".wav", trace.HitPos)
								if trace.Entity and (trace.Entity:IsNPC() or trace.Entity:IsPlayer()) then
									local effectData = EffectData()
									effectData:SetOrigin(trace.Entity:GetPos())
									effectData:SetEntity(trace.Entity)
									util.Effect("alydusbasesystems_module_laserturret_destruction", effectData)
								end
							end
						end						
						self.firingBlock:FireBullets(bulletStructure)
						local effectData = EffectData()
						effectData:SetOrigin(self.firingBlock:GetPos())
						effectData:SetNormal(self.firingBlock:GetPos():GetNormalized())
						effectData:SetMagnitude(1)
						effectData:SetScale(1)
						effectData:SetRadius(6)
						util.Effect("Sparks", effectData)
						local effectData = EffectData()
						effectData:SetOrigin(self.firingBlock:GetPos())
						util.Effect("MuzzleFlash", effectData, true, true)
						local effectData = EffectData()
						effectData:SetOrigin(tr.HitPos)
						effectData:SetStart(self.firingBlock:GetPos())
						effectData:SetEntity(self.firingBlock)
						util.Effect("alydusbasesystems_module_laserturret_tracer", effectData)
						self:EmitSound("alydus/laserfire" .. math.random(1, 3) .. ".wav")
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

		if (IsValid(self:GetNWEntity("alydusBaseSystems.FiringTarget", nil)) and self:GetNWEntity("alydusBaseSystems.FiringTarget", nil):GetPos():Distance(self:GetPos()) <= GetConVar("sv_alydusbasesystems_config_laserturret_range"):GetInt()) or self:GetNWInt("alydusBaseSystems.Health", 0) <= 0 or not IsValid(self:GetNWEntity("alydusBaseSystems.Owner", nil)) then return end

		foundPotentialTargetsPlayers = {}
		foundPotentialTargetsNPC = {}

		for potentialTargetKey, potentialTarget in pairs(ents.FindInSphere(self:GetPos() + Vector(0, 0, 30), GetConVar("sv_alydusbasesystems_config_laserturret_range"):GetInt())) do
			if IsValid(potentialTarget) and potentialTarget:Health() >= 1 then
				local canFire = true

				local firingSource = self:GetPos()
				local firingDirection = potentialTarget:LocalToWorld(potentialTarget:OBBCenter()) - firingSource

				local tr = util.TraceLine({
					start = firingSource + (firingDirection:Angle():Up() * 48.5) + (firingDirection:Angle():Forward() * 30),
					endpos = potentialTarget:LocalToWorld(potentialTarget:OBBCenter()),
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

				if tr.Entity:IsNPC() or tr.Entity:IsPlayer() then
					isEither = true
				end

				if not isEither then
					canFire = false
				end

				if canFire then
					if potentialTarget:IsNPC() and potentialTarget:Disposition(self:GetNWEntity("alydusBaseSystems.Owner", nil)) == D_HT then
						table.insert(foundPotentialTargetsNPC, potentialTarget)
					elseif potentialTarget:IsPlayer() and potentialTarget != self:GetNWEntity("alydusBaseSystems.Owner", nil) then
						if CPPI then
							local isBuddy = false
							local owner = self:GetNWEntity("alydusBaseSystems.Owner", nil)
							if IsValid(owner) and not isnumber(owner:CPPIGetFriends()) then
								for _, buddy in pairs(owner:CPPIGetFriends()) do
									if buddy == potentialTarget then
										isBuddy = true
									end
								end

								if not isBuddy then
									table.insert(foundPotentialTargetsPlayers, potentialTarget)
								end
							else
								table.insert(foundPotentialTargetsPlayers, potentialTarget)
							end
						else
							table.insert(foundPotentialTargetsPlayers, potentialTarget)
						end
					end
				end
			end
		end

		if #foundPotentialTargetsPlayers >= 1 then
			if GetConVar("sv_alydusbasesystems_config_laserturret_prioritisenearbytargets"):GetInt() == 1 and #foundPotentialTargetsPlayers > 1 then
				table.sort(foundPotentialTargetsPlayers, function(a, b) return self:GetPos():Distance(a:GetPos()) < self:GetPos():Distance(b:GetPos()) end)
			end
			self:SetNWEntity("alydusBaseSystems.FiringTarget", foundPotentialTargetsPlayers[1])
			self:EmitSound("alydus/controllerclick.wav")
			firingNPC = false
		elseif #foundPotentialTargetsNPC >= 1 then
			if GetConVar("sv_alydusbasesystems_config_laserturret_prioritisenearbytargets"):GetInt() == 1 and #foundPotentialTargetsNPC > 1  then
				table.sort(foundPotentialTargetsNPC, function(a, b) return self:GetPos():Distance(a:GetPos()) < self:GetPos():Distance(b:GetPos()) end)
			end
			self:SetNWEntity("alydusBaseSystems.FiringTarget", foundPotentialTargetsNPC[1])
			self:EmitSound("alydus/controllerclick.wav")
			firingNPC = true
		end

		self:NextThink(CurTime() + self.firingDelay)
		return true
	end
end
ENT.Type = "anim"
ENT.Base = "alydusbasesystems_module_base"
ENT.Spawnable = true
ENT.Category = "Alydus Base Systems"
ENT.PrintName = "Module - Laser Turret"
ENT.Author = "Alydus"
ENT.Contact = "Alydus"
ENT.Purpose = ""
ENT.Instructions = ""