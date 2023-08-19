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

			if not IsValid(self:GetNWEntity("alydusBaseSystems.FiringTarget")) or self:GetNWEntity("alydusBaseSystems.FiringTarget"):GetPos():Distance(self:GetPos()) >= GetConVar("sv_alydusbasesystems_config_samturret_range"):GetInt() then
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
		self:SetModel("models/bo/weapons/sam turret.mdl")
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

		self.firingDelay = 3.5
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
		local foundPotentialTargetsVehicles = {}

		local timeLeft = self.nextFire - CurTime()
		if timeLeft <= 0 then
			local firingTarget = self:GetNWEntity("alydusBaseSystems.FiringTarget", nil)
			if IsValid(firingTarget) and self:GetNWEntity("alydusBaseSystems.Health", 0) >= 1 and self:GetPos():Distance(firingTarget:GetPos()) <= GetConVar("sv_alydusbasesystems_config_samturret_range"):GetInt() then
				if self:GetNWInt("alydusBaseSystems.Ammo") >= 1 then
					local firingSource = self:GetPos()
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
						start = self:LocalToWorld(self:OBBCenter()),
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

					if canFire then
						local rocket = ents.Create("rpg_missile")
						rocket:SetPos(self.firingBlock:GetPos())
						rocket:SetAngles(firingDirection:Angle() - Angle(-2, 0, 0))
						rocket:SetOwner(self)
						rocket:Spawn()
						rocket:SetVelocity(rocket:GetForward() * 1500)
						rocket:SetSaveValue("m_flDamage", GetConVar("sv_alydusbasesystems_config_samturret_damage"):GetInt())

						self:EmitSound("npc/env_headcrabcanister/launch.wav", 60)
						self:EmitSound("alydus/lockon.wav")

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

		if (IsValid(self:GetNWEntity("alydusBaseSystems.FiringTarget", nil)) and self:GetNWEntity("alydusBaseSystems.FiringTarget", nil):GetPos():Distance(self:GetPos()) <= GetConVar("sv_alydusbasesystems_config_samturret_range"):GetInt()) or self:GetNWInt("alydusBaseSystems.Health", 0) <= 0 or self:GetNWInt("alydusBaseSystems.Ammo", 0) <= 0 or not IsValid(self:GetNWEntity("alydusBaseSystems.Owner", nil)) then return end

		for potentialTargetKey, potentialTarget in pairs(ents.FindInSphere(self:GetPos() + Vector(0, 0, 30), GetConVar("sv_alydusbasesystems_config_samturret_range"):GetInt())) do
			if IsValid(potentialTarget) then
				if potentialTarget:IsVehicle() or potentialTarget.IsSWVehicle or potentialTarget.LFS or string.match(string.lower(potentialTarget:GetClass()), "lunasflightschool") != nil then
					if CPPI then
						local canFire = true
						local owner = self:GetNWEntity("alydusBaseSystems.Owner", nil)

						if potentialTarget:CPPIGetOwner() == owner then
							canFire = false
						end

						if not isnumber(owner:CPPIGetFriends()) then
							for _, buddy in pairs(owner:CPPIGetFriends()) do
								if buddy == potentialTarget:CPPIGetOwner() then
									isVehicleOwnedByBuddy = true
								end
							end

							if isVehicleOwnedByBuddy then
								canFire = false
							end
						end

						if canFire then
							table.insert(foundPotentialTargetsVehicles, potentialTarget)
						end
					end

					table.insert(foundPotentialTargetsVehicles, potentialTarget)
				elseif potentialTarget:GetClass() == "npc_helicopter" or potentialTarget:GetClass() == "npc_combinegunship" or potentialTarget:GetClass() == "npc_strider" then
					table.insert(foundPotentialTargetsVehicles, potentialTarget)
				elseif not potentialTarget:IsVehicle() then
					if string.match(string.lower(potentialTarget:GetClass()), "wac") != nil then
						table.insert(foundPotentialTargetsVehicles, potentialTarget)
					end
				end
			end
		end

		if #foundPotentialTargetsVehicles >= 1 then
			if GetConVar("sv_alydusbasesystems_config_samturret_prioritisenearbytargets"):GetInt() == 1 and #foundPotentialTargetsVehicles > 1 then
				table.sort(foundPotentialTargetsVehicles, function(a, b) return self:GetPos():Distance(a:GetPos()) < self:GetPos():Distance(b:GetPos()) end)
			end
			self:SetNWEntity("alydusBaseSystems.FiringTarget", foundPotentialTargetsVehicles[1])
			self:EmitSound("alydus/controllerclick.wav")
		end
	end
end
ENT.Type = "anim"
ENT.Base = "alydusbasesystems_module_base"
ENT.Spawnable = true
ENT.Category = "Alydus Base Systems"
ENT.PrintName = "Module - SAM Turret"
ENT.Author = "Alydus"
ENT.Contact = "Alydus"
ENT.Purpose = ""
ENT.Instructions = ""