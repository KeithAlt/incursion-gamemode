--[[ 
	© Alydus.net
	Do not reupload lua to workshop without permission of the author
	Alydus Base Systems
	Alydus: (officialalydus@gmail.com | STEAM_0:1:57622640)
--]]
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Spawnable = false
ENT.Category = "Alydus Base Systems"
ENT.PrintName = "Module Base"
ENT.Author = "Alydus"
ENT.Contact = "Alydus"
ENT.Purpose = ""
ENT.Instructions = ""
ENT.alydus = true

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
else
	AddCSLuaFile()
end
function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "owning_ent")
end
function ENT:Use(activator, caller)
	if SERVER then
		if IsValid(caller) and caller:IsPlayer() and not IsValid(self:GetNWEntity("alydusBaseSystems.Owner")) then
			local playerClaimedController = false
			for _, otherBaseController in pairs(ents.FindByClass("alydusbasesystems_basecontroller")) do
				if IsValid(otherBaseController) and IsValid(otherBaseController:GetNWEntity("alydusBaseSystems.Owner")) and otherBaseController:GetNWEntity("alydusBaseSystems.Owner") == activator then
					playerClaimedController = otherBaseController
				end
			end
			if playerClaimedController == false then
				alydusBaseSystems.sendMessage(caller, "Failed to claim module, you do not own a base controller.")
			else
				local maximumClaimRadius = GetConVar("sv_alydusbasesystems_enable_module_maximumclaimradius"):GetInt() or 3500
								if caller:GetPos():Distance(playerClaimedController:GetPos()) >= maximumClaimRadius then
					alydusBaseSystems.sendMessage(caller, "Failed to claim module, you are too far away from your base controller.")
				else
					self:EmitSound("alydus/controllerclick.wav")
					self:SetNWEntity("alydusBaseSystems.Owner", activator)					
					if CPPI and GetConVar("sv_alydusbasesystems_enable_module_claimcppiset"):GetInt() == 1 then
						self:CPPISetOwner(activator)
					end
					
					self.baseController = playerClaimedController
				end
			end
		end
	end
end
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end
function ENT:OnRemove()
	if SERVER then
		if self:GetClass() == "alydusbasesystems_module_camera" then
			for _, ply in pairs(player.GetAll()) do
				if IsValid(ply) and ply:IsPlayer() and ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", nil) == self then
					ply:SetNWEntity("alydusBaseSystems.ViewingCameraEntity", false)
				end
			end
		elseif self:GetClass() == "alydusbasesystems_module_alarm" then
			if self:GetNWBool("alydusBaseSystems.Alarm", false) == true then
				if self.loopingAlarmID != nil then
					self.loopingAlarmID:Stop()
					self.loopingAlarmID = nil
				end
			end
		end
	end
end
function ENT:PhysicsCollide(data, phys)
	if data.Speed > 50 and not data.HitEntity:IsPlayer() and not data.HitEntity:IsNPC() and not string.Left(data.HitEntity:GetClass(), 18) == "alydusbasesystems_" then
		self:EmitSound(Sound("Flashbang.Bounce"))
		self:TakeDamage(1)
	end
end
function ENT:OnTakeDamage(dmg)
	if SERVER then
		local doorList = {}
		doorList["func_door"] = true
		doorList["func_door_rotating"] = true
		doorList["prop_door"] = true
		doorList["prop_door_rotating"] = true
		if dmg and dmg:GetDamage() >= 1 and self:GetNWInt("alydusBaseSystems.Health") >= 1 then
			local attacker = dmg:GetAttacker()
			if(attacker and attacker:IsPlayer() and self.baseController) then
				local attackers = self.baseController.baseAttackers or {}--self.baseController:GetNWString("alydusBaseSystems.baseAttackers")
				--[[
				if(attackers != "") then 
					attackers = util.JSONToTable(attackers)
				else
					attackers = {}
				end
				--]]
				
				local userID = attacker:UserID()
				attackers[userID] = userID
				
				--list of basecontrollers that are hostile with the attacker
				local attackerInfo = attacker.enemyControllers or {}
				attackerInfo[#attackerInfo + 1] = self.baseController
				attacker.enemyControllers = attackerInfo

				--self.baseController:SetNWString("alydusBaseSystems.baseAttackers", util.TableToJSON(attackers))
				self.baseController.baseAttackers = attackers
			end
		
			if self:GetNWInt("alydusBaseSystems.Health") - dmg:GetDamage() <= -1 then
				self:SetNWInt("alydusBaseSystems.Health", 0)
			else
				self:SetNWInt("alydusBaseSystems.Health", self:GetNWInt("alydusBaseSystems.Health") - dmg:GetDamage())
			end
			self:EmitSound("ambient/materials/metal_stress" .. math.random(1, 5) .. ".wav")

			if self:GetNWInt("alydusBaseSystems.Health") <= 0 then
				if IsValid(self:GetNWEntity("alydusBaseSystems.Owner", nil)) then
					if self:GetClass() == "alydusbasesystems_module_camera" then
						for _, ply in pairs(player.GetAll()) do
							if IsValid(ply) and ply:IsPlayer() and ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", nil) == self then
								ply:SetNWEntity("alydusBaseSystems.ViewingCameraEntity", false)
							end
						end
					elseif self:GetClass() == "alydusbasesystems_module_doorservo" then
						for _, door in pairs(ents.FindInSphere(self:GetPos(), 75)) do
							if IsValid(door) and doorList[door:GetClass()] then
								door:Fire("UnLock", "", 0)
								door:Fire("Open", "", 0)
							end
						end
					end
				end
				if self:GetClass() == "alydusbasesystems_module_alarm" then
					if self:GetNWBool("alydusBaseSystems.Alarm", false) == true then
						if self.loopingAlarmID then
							self:StopLoopingSound(self.loopingAlarmID)
							self:SetNWBool("alydusBaseSystems.Alarm", false)
						end
					end
				end
				if IsValid(self:GetNWEntity("alydusBaseSystems.Owner", nil)) then
					for _, ent in pairs(ents.FindByClass("alydusbasesystems_module_transmitter")) do
						if IsValid(ent) and ent:GetNWInt("alydusBaseSystems.Health", 0) >= 1 and IsValid(ent:GetNWEntity("alydusBaseSystems.Owner", nil)) and self:GetNWEntity("alydusBaseSystems.Owner", nil) == ent:GetNWEntity("alydusBaseSystems.Owner", nil) then
							alydusBaseSystems.sendMessage(ent:GetNWEntity("alydusBaseSystems.Owner"), "Warning! Your " .. self.PrintName .. " has been destroyed! Repair it using your base controller.")
							break
						end
					end
				end
				if GetConVar("sv_alydusbasesystems_enable_module_destructionexplosion"):GetInt() == 1 then
					local explode = ents.Create("env_explosion")
					explode:SetPos(self:GetPos() + Vector(0, 0, 30))
					explode:Spawn()
					explode:SetKeyValue("iMagnitude", "15")
					explode:SetKeyValue("spawnflags", 16)
					explode:Fire("Explode", 0, 0)
				end
				if GetConVar("sv_alydusbasesystems_enable_module_destructionignition"):GetInt() == 1 then
					local ignitionTime = GetConVar("sv_alydusbasesystems_enable_basecontroller_destructionignitionlength"):GetInt() or 15
					local ignitionLength = GetConVar("sv_alydusbasesystems_enable_basecontroller_destructionignitionradius"):GetInt() or 0
					self:Ignite(ignitionTime, ignitionLength)
				end
				if GetConVar("sv_alydusbasesystems_enable_module_destructionexplosionextra"):GetInt() == 1 then
					self:EmitSound("ambient/levels/labs/electric_explosion" .. math.random(1, 5) .. ".wav")
				end
				if GetConVar("sv_alydusbasesystems_enable_module_destructionscreenshake"):GetInt() == 1 then
					util.ScreenShake(self:GetPos() + Vector(0, 0, 30), 10, 10, 3.5, 150)
				end
			end
			if WireAddon then
				Wire_TriggerOutput(self, "Module Health", self:GetNWInt("alydusBaseSystems.Health", 0))
			end
		end
	end
end

function ENT:scanForTargets()
	local foundPotentialTargetsPlayers = {}
	local foundPotentialTargetsNPC = {}

	--find potential targets
	local potentials = ents.FindInSphere(self:GetPos() + Vector(0, 0, 30), GetConVar("sv_alydusbasesystems_config_gunturret_range"):GetInt())

	--gets the base controller for this module
	if(!self.baseController) then
		for _, potentialBaseController in pairs(ents.FindByClass("alydusbasesystems_basecontroller")) do
			if IsValid(potentialBaseController) and IsValid(potentialBaseController:GetNWEntity("alydusBaseSystems.Owner", nil)) and potentialBaseController:GetNWEntity("alydusBaseSystems.Owner", nil) == self:GetNWEntity("alydusBaseSystems.Owner", nil) then
				self.baseController = potentialBaseController
				break
			end
		end
	end
	
	local baseController = self.baseController

	local baseAttackers
	if(baseController) then
		--finds people who have attacked the base
		--baseAttackers = baseController:GetNWString("alydusBaseSystems.baseAttackers")
		baseAttackers = baseController.baseAttackers or {}--self.baseController:GetNWString("alydusBaseSystems.baseAttackers")
		
		--[[
		if(baseAttackers != "") then 
			baseAttackers = util.JSONToTable(baseAttackers)
		else
			baseAttackers = {}
		end
		--]]
	end

	for potentialTargetKey, potentialTarget in pairs(potentials) do
		--skips entities that aren't players/npcs
		if
			!IsValid(potentialTarget) or 
			(!potentialTarget:IsPlayer() and !potentialTarget:IsNPC())
		then 
			continue 
		end
	
		if potentialTarget:Health() >= 1 then
			local canFire = true

			local firingSource = self:GetPos() + self:GetUp()
			local firingDirection = potentialTarget:LocalToWorld(potentialTarget:OBBCenter()) - firingSource

			local tr = util.TraceLine({
				start = firingSource + (firingDirection:Angle():Up() * 48.5) + (firingDirection:Angle():Forward() * 30),
				endpos = potentialTarget:LocalToWorld(potentialTarget:OBBCenter()),
				filter = {self, self.firingBlock}
			})
			
			if not IsValid(tr.Entity) then
				--canFire = false
				continue
			end
			
			if tr.HitWorld then
				canFire = false
			end

			if tr.HitSky then
				canFire = false
			end

			local isEither = false

			if (tr.Entity:IsNPC() or tr.Entity:IsPlayer()) then
				isEither = true
			end

			if not isEither then
				canFire = false
			end

			if canFire and baseController then
				if potentialTarget:IsNPC() and baseController:GetNWBool("alydusBaseSystems.gunTurretsShootNPCs", false) == true then
					foundPotentialTargetsNPC[#foundPotentialTargetsNPC + 1] = potentialTarget
				elseif (potentialTarget:IsPlayer()) then --players
					if(potentialTarget != self:GetNWEntity("alydusBaseSystems.Owner", nil) and potentialTarget:getChar()) then 
						local char = potentialTarget:getChar()
						local faction = char:getFaction()
						
						--faction targetting
						local factions = baseController:GetNWString("alydusBaseSystems.factionTargets")
						if(factions != "") then
							factions = util.JSONToTable(factions)
							
							if(factions[faction]) then
								foundPotentialTargetsPlayers[#foundPotentialTargetsPlayers + 1] = potentialTarget
							end
						end
						
						if(baseAttackers[potentialTarget:UserID()]) then
							foundPotentialTargetsPlayers[#foundPotentialTargetsPlayers + 1] = potentialTarget
						end
					end
				end
			end
		end
	end
	
	return foundPotentialTargetsPlayers, foundPotentialTargetsNPC
end

function ENT:TurretThink()
	if SERVER then
		self.foundPotentialTargetsNPC = self.foundPotentialTargetsNPC or {}
		self.foundPotentialTargetsPlayers = self.foundPotentialTargetsPlayers or {}
		local firingNPC = firingNPC or false

		if((self.nextScan or 0) < CurTime()) then
			self.nextScan = CurTime() + 2
			self.foundPotentialTargetsPlayers, self.foundPotentialTargetsNPC = self:scanForTargets()
		end

		if #self.foundPotentialTargetsPlayers >= 1 then
			if GetConVar("sv_alydusbasesystems_config_gunturret_prioritisenearbytargets"):GetInt() == 1 and #self.foundPotentialTargetsPlayers > 1 then
				table.sort(self.foundPotentialTargetsPlayers, function(a, b) return self:GetPos():DistToSqr(a:GetPos()) < self:GetPos():DistToSqr(b:GetPos()) end)
			end
			self:SetNWEntity("alydusBaseSystems.FiringTarget", self.foundPotentialTargetsPlayers[1])
			
			if((self.nextLockOn or 0) < CurTime()) then
				self.nextLockOn = CurTime() + 5
				self:EmitSound("alydus/fo4turretlockon.wav")
			end
			
			firingNPC = false
			
			--firing loop
			self:FireThink()
			
			self:NextThink(CurTime() + self.firingDelay)
		elseif #self.foundPotentialTargetsNPC >= 1 then
			if GetConVar("sv_alydusbasesystems_config_gunturret_prioritisenearbytargets"):GetInt() == 1 and #self.foundPotentialTargetsNPC > 1  then
				table.sort(self.foundPotentialTargetsNPC, function(a, b) return self:GetPos():DistToSqr(a:GetPos()) < self:GetPos():DistToSqr(b:GetPos()) end)
			end
			
			self:SetNWEntity("alydusBaseSystems.FiringTarget", self.foundPotentialTargetsNPC[1])
			
			if((self.nextLockOn or 0) < CurTime()) then
				self.nextLockOn = CurTime() + 5
				self:EmitSound("alydus/fo4turretlockon.wav")
			end
			
			firingNPC = true
			
			--firing loop
			self:FireThink()
			
			self:NextThink(CurTime() + self.firingDelay)
		else
			self:SetNWBool("alydusBaseSystems.IsShooting", false)
			self:SetNWEntity("alydusBaseSystems.FiringTarget", nil)
			
			self:NextThink(CurTime() + 1)
		end

		return true
	else
		--this is a dumb thing i had to do because FiringTarget wouldn't update on clients always so the turret would point at people who aren't targets
		if(!self:GetNWBool("alydusBaseSystems.IsShooting", false)) then
			self:SetNWEntity("alydusBaseSystems.FiringTarget", nil)
		end
	end
end

function ENT:targetInRange(target)
	local range = self.range
	local target = target or self:GetNWEntity("alydusBaseSystems.FiringTarget", nil)
	
	if (
		IsValid(target) and 
		target:GetPos():DistToSqr(self:GetPos()) > (range * range)) or 
		self:GetNWInt("alydusBaseSystems.Health", 0) <= 0 or not 
		IsValid(self:GetNWEntity("alydusBaseSystems.Owner", nil)) 
	then 
		return false
	else
		return true
	end
end

--if a player gets attacked by a basecontroller owner, they are set as a target
--if a player gets attacked and they are a basecontroller owner, the attacker is set as a target
local function checkOwnerAttacker(target, dmginfo)
	if(IsValid(target) and target:IsPlayer()) then
		local attacker = dmginfo:GetInflictor() --the one who dealt the damage
		if(IsValid(attacker) and attacker:IsPlayer()) then
			if(attacker.baseController) then --attacker has a basecontroller
				--local attackers = attacker.baseController:GetNWString("alydusBaseSystems.baseAttackers")
				local attackers = attacker.baseController.baseAttackers or {}
				--[[
				if(attackers != "") then 
					attackers = util.JSONToTable(attackers)
				else
					attackers = {}
				end
				--]]
				
				--some cleanup of things that no longer exist
				for k, v in pairs(attackers) do
					if(!IsValid(Player(v))) then
						attackers[k] = nil
					end
				end
				
				local userID = target:UserID()
				attackers[userID] = userID

				--list of basecontrollers that are hostile with the attacker
				local attackerInfo = target.enemyControllers or {}
				attackerInfo[#attackerInfo + 1] = attacker.baseController
				target.enemyControllers = attackerInfo

				--attacker.baseController:SetNWString("alydusBaseSystems.baseAttackers", util.TableToJSON(attackers))
				attacker.baseController.baseAttackers = attackers
			end
			
			if(target.baseController) then --attacked has a basecontroller
				--local attackers = target.baseController:GetNWString("alydusBaseSystems.baseAttackers")
				local attackers = target.baseController.baseAttackers or {}
				
				if(attackers != "") then 
					attackers = util.JSONToTable(attackers)
				else
					attackers = {}
				end
				
				--some cleanup of things that no longer exist
				for k, v in pairs(attackers) do
					if(!IsValid(Player(v))) then
						attackers[k] = nil
					end
				end
				
				local userID = attacker:UserID()
				attackers[userID] = userID

				--list of basecontrollers that are hostile with the attacker
				local attackerInfo = attacker.enemyControllers or {}
				attackerInfo[#attackerInfo + 1] = target.baseController
				attacker.enemyControllers = attackerInfo

				--target.baseController:SetNWString("alydusBaseSystems.baseAttackers", util.TableToJSON(attackers))
				target.baseController.baseAttackers = attackers
			end
		end
	end
end
hook.Add("EntityTakeDamage", "alydusOwnerAttacker", checkOwnerAttacker)

--clears target from base controller target lists after they die
local function alydusDeathClear(victim)
	if(IsValid(victim)) then
		if(victim.enemyControllers) then
			for k, v in pairs(victim.enemyControllers) do
				if(IsValid(v)) then
					--local attackers = v:GetNWString("alydusBaseSystems.baseAttackers")
					local attackers = v.baseAttackers or {}
					
					--[[
					if(attackers != "") then 
						attackers = util.JSONToTable(attackers)
					else
						attackers = {}
					end
					--]]
					
					attackers[victim:UserID()] = nil
					
					--v:SetNWString("alydusBaseSystems.baseAttackers", util.TableToJSON(attackers))
					v.baseAttackers = attackers
				end
			end
			
			victim.enemyControllers = nil
		end
	end
end
hook.Add("PlayerDeath", "alydusDeathClear", alydusDeathClear) --clears turret targets on deaths
hook.Add("PlayerLoadedChar", "alydusDeathClear", alydusDeathClear) --clears turret targets on character swaps