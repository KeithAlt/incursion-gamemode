--[[
	© Alydus.net
	Do not reupload lua to workshop without permission of the author

	Alydus Base Systems

	Alydus: (officialalydus@gmail.com | STEAM_0:1:57622640)
--]]

AddCSLuaFile()
AddCSLuaFile("cl_alydusbasesystems_tdui.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.Spawnable = true
ENT.Category = "Alydus Base Systems"

ENT.PrintName = "Base Controller"
ENT.Author = "Alydus"
ENT.Contact = "Alydus"
ENT.Purpose = ""
ENT.Instructions = ""

ENT.alydus = true

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/weapons/keitho/turrets/workshopterminal.mdl")
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
		self:SetNWBool("alydusBaseSystems.IsLoading", false)
		self:SetNWInt("alydusBaseSystems.Health", 500)

		self:SetNWBool("alydusBaseSystems.gunTurretsShootNPCs", true)
		self:SetNWBool("alydusBaseSystems.gunTurretsShootPlayers", true)

		if WireAddon then
			self.Outputs = Wire_CreateOutputs(self, {
				"Module Health"
			})
			Wire_TriggerOutput(self, "Module Health", self:GetNWInt("alydusBaseSystems.Health", 0))
		end

		self:DropToFloor()
	end
end

if SERVER then
	net.Receive("alydusBaseSystems.claimBaseController", function(len, ply)
		local baseController = net.ReadEntity()

		if IsValid(ply) and ply:IsPlayer() and IsValid(baseController) and baseController:GetClass() == "alydusbasesystems_basecontroller" and baseController:GetNWBool("alydusBaseSystems.IsLoading", false) == false and not IsValid(baseController:GetNWEntity("alydusBaseSystems.Owner")) then
			local playerAlreadyClaimed = false
			for _, otherBaseController in pairs(ents.FindByClass("alydusbasesystems_basecontroller")) do
				if IsValid(otherBaseController) and IsValid(otherBaseController:GetNWEntity("alydusBaseSystems.Owner")) and otherBaseController:GetNWEntity("alydusBaseSystems.Owner") == ply then
					playerAlreadyClaimed = true
				end
			end
			if playerAlreadyClaimed then
				alydusBaseSystems.sendMessage(ply, "You cannot claim/own more than one base controller at once.")
			else
				baseController:EmitSound("alydus/controllerclick.wav")

				baseController:SetNWBool("alydusBaseSystems.IsLoading", true)
				baseController:SetNWEntity("alydusBaseSystems.Owner", ply)
				ply.baseController = baseController

				timer.Simple(5, function()
					if IsValid(baseController) and IsValid(ply) and baseController:GetNWBool("alydusBaseSystems.IsLoading", false) == true and IsValid(baseController:GetNWEntity("alydusBaseSystems.Owner")) then
						baseController:SetNWBool("alydusBaseSystems.IsLoading", false)
						baseController:EmitSound("alydus/controllerclick.wav")
					end
				end)
			end
		end
	end)

	net.Receive("alydusBaseSystems.repairBaseController", function(len, ply)
		local baseController = net.ReadEntity()
		local repairSoundID = nil

		if IsValid(ply) and ply:IsPlayer() and IsValid(baseController) and baseController:GetClass() == "alydusbasesystems_basecontroller" and baseController:GetNWBool("alydusBaseSystems.IsLoading", false) == false and baseController:GetNWInt("alydusBaseSystems.Health") <= 0 then
			baseController:EmitSound("alydus/controllerclick.wav")

			baseController:SetNWBool("alydusBaseSystems.IsLoading", true)

			baseController:Extinguish()

			if GetConVar("sv_alydusbasesystems_enable_basecontroller_repairsound"):GetInt() == 1 then
				repairSoundID = baseController:StartLoopingSound("npc/combine_gunship/gunship_engine_loop3.wav")
			end
			timer.Simple(30, function()
				if IsValid(baseController) and IsValid(ply) and baseController:GetNWBool("alydusBaseSystems.IsLoading", false) == true and baseController:GetNWInt("alydusBaseSystems.Health") <= 0 then
					baseController:Extinguish()
					baseController:SetNWInt("alydusBaseSystems.Health", 500)
					baseController:SetNWBool("alydusBaseSystems.IsLoading", false)
					if repairSoundID != nil then
						baseController:StopLoopingSound(repairSoundID)
					end
					baseController:EmitSound("alydus/controllerclick.wav")

					if IsValid(baseController:GetNWEntity("alydusBaseSystems.Owner")) then
						baseController:SetNWBool("alydusBaseSystems.IsLoading", true)

						timer.Simple(5, function()
							if IsValid(baseController) and IsValid(ply) and baseController:GetNWBool("alydusBaseSystems.IsLoading", false) == true and IsValid(baseController:GetNWEntity("alydusBaseSystems.Owner")) then
								baseController:SetNWBool("alydusBaseSystems.IsLoading", false)
								baseController:EmitSound("alydus/controllerclick.wav")
							end
						end)
					end
				end
			end)
		end
	end)

	net.Receive("alydusBaseSystems.repairModules", function(len, ply)
		local baseController = net.ReadEntity()

		if IsValid(ply) and ply:IsPlayer() and IsValid(baseController) and baseController:GetClass() == "alydusbasesystems_basecontroller" and baseController:GetNWBool("alydusBaseSystems.IsLoading", false) == false and baseController:GetNWInt("alydusBaseSystems.Health") >= 1 and baseController:GetNWEntity("alydusBaseSystems.Owner", nil) == ply then
			local brokenModuleCount = 0

			for _, moduleEntity in pairs(ents.FindByClass("alydusbasesystems_module_*")) do
				if IsValid(moduleEntity) and IsValid(moduleEntity:GetNWEntity("alydusBaseSystems.Owner", nil)) and moduleEntity:GetNWEntity("alydusBaseSystems.Owner") == ply and moduleEntity:GetNWInt("alydusBaseSystems.Health", nil) != nil and moduleEntity:GetNWInt("alydusBaseSystems.Health", 0) < GetConVar("sv_alydusbasesystems_config_module_defaulthealth"):GetInt() then
					brokenModuleCount = brokenModuleCount + 1
				end
			end

			if brokenModuleCount >= 1 then
				baseController:EmitSound("alydus/controllerclick.wav")

				baseController:SetNWBool("alydusBaseSystems.IsRepairingModules", true)

				local repairSoundID = baseController:StartLoopingSound("npc/combine_gunship/gunship_engine_loop3.wav")

				for _, moduleEntity in pairs(ents.FindByClass("alydusbasesystems_module_*")) do
					if IsValid(moduleEntity) and IsValid(moduleEntity:GetNWEntity("alydusBaseSystems.Owner", nil)) and moduleEntity:GetNWEntity("alydusBaseSystems.Owner") == ply and moduleEntity:GetNWInt("alydusBaseSystems.Health", nil) != nil and moduleEntity:GetNWInt("alydusBaseSystems.Health", 0) < GetConVar("sv_alydusbasesystems_config_module_defaulthealth"):GetInt() then
						moduleEntity:Extinguish()
					end
				end

				timer.Simple(brokenModuleCount * 2 + 15, function()
					if IsValid(baseController) and IsValid(ply) and baseController:GetNWBool("alydusBaseSystems.IsRepairingModules", false) == true and baseController:GetNWInt("alydusBaseSystems.Health") >= 1 then
						for _, moduleEntity in pairs(ents.FindByClass("alydusbasesystems_module_*")) do
							if IsValid(moduleEntity) and IsValid(moduleEntity:GetNWEntity("alydusBaseSystems.Owner", nil)) and moduleEntity:GetNWEntity("alydusBaseSystems.Owner") == ply and moduleEntity:GetNWInt("alydusBaseSystems.Health", nil) != nil and moduleEntity:GetNWInt("alydusBaseSystems.Health", 0) < GetConVar("sv_alydusbasesystems_config_module_defaulthealth"):GetInt() then
								moduleEntity:Extinguish()
								moduleEntity:SetNWInt("alydusBaseSystems.Health", GetConVar("sv_alydusbasesystems_config_module_defaulthealth"):GetInt())
							end
						end

						baseController:SetNWBool("alydusBaseSystems.IsRepairingModules", false)
						baseController:StopLoopingSound(repairSoundID)
						baseController:EmitSound("alydus/controllerclick.wav")
					end
				end)
			end
		end
	end)

	net.Receive("alydusBaseSystems.joinCameraUplink", function(len, ply)
		local baseController = net.ReadEntity()

		if IsValid(ply) and ply:IsPlayer() and IsValid(baseController) and baseController:GetClass() == "alydusbasesystems_basecontroller" and baseController:GetNWBool("alydusBaseSystems.IsLoading", false) == false and baseController:GetNWInt("alydusBaseSystems.Health") >= 1 and baseController:GetNWEntity("alydusBaseSystems.Owner") == ply then
			local cameraList = {}
			local cameraCounter = 0

			for cameraNumber, cameraModule in pairs(ents.FindByClass("alydusbasesystems_module_camera")) do
				if IsValid(cameraModule) and cameraModule:GetNWEntity("alydusBaseSystems.Owner", nil) == ply then
					cameraCounter = cameraCounter + 1
					cameraList[cameraCounter] = cameraModule
				end
			end

			if cameraList[1] then
				ply:SetEyeAngles(Angle(0, 0, 0))
				ply:SetNWEntity("alydusBaseSystems.ViewingCameraEntity", cameraList[1])

				ply:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 255), 1.5, 0.5)
			end
		end
	end)

	net.Receive("alydusBaseSystems.controlDoorServos", function(len, ply)
		local baseController = net.ReadEntity()
		local action = net.ReadString()

		if IsValid(ply) and ply:IsPlayer() and IsValid(baseController) and baseController:GetClass() == "alydusbasesystems_basecontroller" and baseController:GetNWBool("alydusBaseSystems.IsLoading", false) == false and baseController:GetNWInt("alydusBaseSystems.Health") >= 1 and baseController:GetNWEntity("alydusBaseSystems.Owner") == ply then
			for _, doorServoModule in pairs(ents.FindByClass("alydusbasesystems_module_doorservo")) do
				if IsValid(doorServoModule) and doorServoModule:GetNWInt("alydusBaseSystems.Health", false) != false and doorServoModule:GetNWInt("alydusBaseSystems.Health") >= 1 and doorServoModule:GetNWEntity("alydusBaseSystems.Owner", nil) == ply then
					doorServoModule:DoorServoAction(action)
				end
			end

			baseController:EmitSound("alydus/controllerclick.wav")
		end
	end)


	local gunTurrets = {
		["alydusbasesystems_module_fallout_basic_turret"] = true,
		["alydusbasesystems_module_fallout_basic_turret_2"] = true,
	}
	net.Receive("alydusBaseSystems.toggleGunTurretProperty", function(len, ply)
		local baseController = net.ReadEntity()
		local property = net.ReadString()

		if IsValid(ply) and ply:IsPlayer() and IsValid(baseController) and baseController:GetClass() == "alydusbasesystems_basecontroller" and baseController:GetNWBool("alydusBaseSystems.IsLoading", false) == false and baseController:GetNWInt("alydusBaseSystems.Health") >= 1 and baseController:GetNWEntity("alydusBaseSystems.Owner") == ply and property and property != "" then
			local shootPlayers = not baseController:GetNWBool("alydusBaseSystems.gunTurretsShootPlayers", false)
			local shootNPCs = not baseController:GetNWBool("alydusBaseSystems.gunTurretsShootNPCs", false)

			if property == "Player" then
				baseController:SetNWBool("alydusBaseSystems.gunTurretsShootPlayers", shootPlayers)

				timer.Simple(1, function()
					for _, baseEntity in pairs(ents.GetAll()) do
						if IsValid(baseEntity) and gunTurrets[baseEntity:GetClass()] and baseEntity:GetNWEntity("alydusBaseSystems.Owner", nil) == ply then
							baseEntity:SetNWBool("alydusBaseSystems.IsShooting", false)
							baseEntity:SetNWEntity("alydusBaseSystems.FiringTarget", nil)
						end
					end
				end)

				baseController:EmitSound("alydus/controllerclick.wav")
			elseif property == "NPC" then
				baseController:SetNWBool("alydusBaseSystems.gunTurretsShootNPCs", shootNPCs)

				baseController:EmitSound("alydus/controllerclick.wav")
			end
		end
	end)

	--faction specific targets
	net.Receive("alydusBaseSystems.openFactionTarget", function(len, ply)
		local baseController = net.ReadEntity()
		local faction = net.ReadInt(32)
		local check = net.ReadBool()

		if IsValid(ply) and ply:IsPlayer() and IsValid(baseController) and baseController:GetClass() == "alydusbasesystems_basecontroller" and baseController:GetNWBool("alydusBaseSystems.IsLoading", false) == false and baseController:GetNWInt("alydusBaseSystems.Health") >= 1 and baseController:GetNWEntity("alydusBaseSystems.Owner") == ply then
			local factions = baseController:GetNWString("alydusBaseSystems.factionTargets")

			if(factions != "") then
				factions = util.JSONToTable(factions)
			else
				factions = {}
			end

			factions[faction] = check
			baseController:SetNWString("alydusBaseSystems.factionTargets", util.TableToJSON(factions))
		end
	end)

	net.Receive("alydusBaseSystems.toggleAlarm", function(len, ply)
		local baseController = net.ReadEntity()

		if
			IsValid(ply) and
			ply:IsPlayer() and
			IsValid(baseController) and
			baseController:GetClass() == "alydusbasesystems_basecontroller" and
			baseController:GetNWBool("alydusBaseSystems.IsLoading", false) == false and
			baseController:GetNWInt("alydusBaseSystems.Health") >= 1 and
			baseController:GetNWEntity("alydusBaseSystems.Owner") == ply
		then
			for _, alarmModule in pairs(ents.FindByClass("alydusbasesystems_module_fallout_siren")) do
				if IsValid(alarmModule) and alarmModule:GetNWInt("alydusBaseSystems.Health", false) != false and alarmModule:GetNWInt("alydusBaseSystems.Health") >= 1 and alarmModule:GetNWEntity("alydusBaseSystems.Owner", nil) == ply then
					alarmModule:ControlAlarm("toggle")
				end
			end

			baseController:EmitSound("alydus/controllerclick.wav")
		end
	end)

	net.Receive("alydusBaseSystems.resetAlarm", function(len, ply)
		local baseController = net.ReadEntity()

		if IsValid(ply) and ply:IsPlayer() and IsValid(baseController) and baseController:GetClass() == "alydusbasesystems_basecontroller" and baseController:GetNWBool("alydusBaseSystems.IsLoading", false) == false and baseController:GetNWInt("alydusBaseSystems.Health") >= 1 and baseController:GetNWEntity("alydusBaseSystems.Owner") == ply then
			for _, alarmModule in pairs(ents.FindByClass("alydusbasesystems_module_alarm")) do
				if IsValid(alarmModule) and alarmModule:GetNWInt("alydusBaseSystems.Health", false) != false and alarmModule:GetNWInt("alydusBaseSystems.Health") >= 1 and alarmModule:GetNWEntity("alydusBaseSystems.Owner", nil) == ply then
					alarmModule:ControlAlarm("off")
				end
			end

			baseController:EmitSound("alydus/controllerclick.wav")
		end
	end)

	net.Receive("alydusBaseSystems.toggleSystemView", function(len, ply)
		local baseController = net.ReadEntity()

		if IsValid(ply) and ply:IsPlayer() and IsValid(baseController) and baseController:GetClass() == "alydusbasesystems_basecontroller" and baseController:GetNWBool("alydusBaseSystems.IsLoading", false) == false and baseController:GetNWInt("alydusBaseSystems.Health") >= 1 and baseController:GetNWEntity("alydusBaseSystems.Owner") == ply then
			local moduleCount = 0

			for _, moduleEntity in pairs(ents.FindByClass("alydusbasesystems_module_*")) do
				if IsValid(moduleEntity) and IsValid(moduleEntity:GetNWEntity("alydusBaseSystems.Owner", nil)) and moduleEntity:GetNWEntity("alydusBaseSystems.Owner") == ply and moduleEntity:GetNWInt("alydusBaseSystems.Health", nil) != nil then
					moduleCount = moduleCount + 1
				end
			end

			if moduleCount >= 1 then
				local toggleStatus = not ply:GetNWBool("alydusBaseSystems.SystemView", false)

				ply:SetNWBool("alydusBaseSystems.SystemView", toggleStatus)

				if toggleStatus then
					alydusBaseSystems.sendMessage(ply, "Successfully enabled system view for yourself, disable it using the toggle button in mode 6 of your base controller.")
				else
					alydusBaseSystems.sendMessage(ply, "Successfully disabled system view for yourself.")
				end
				baseController:EmitSound("alydus/controllerclick.wav")
			end
		end
	end)
end

function ENT:Use(activator, caller)
	return false
end

function ENT:OnRemove()
	if SERVER then
		if IsValid(self:GetNWEntity("alydusBaseSystems.Owner", nil)) then
			if self:GetNWEntity("alydusBaseSystems.Owner", nil):GetNWBool("alydusBaseSystems.SystemView", false) == true then
				self:GetNWEntity("alydusBaseSystems.Owner", nil):SetNWBool("alydusBaseSystems.SystemView", false)

				alydusBaseSystems.sendMessage(self:GetNWEntity("alydusBaseSystems.Owner", nil), "Automatically disabled system view since your base controller was removed, re-enable it by placing another base controller and using the toggle button in mode 6 of your base controller.")
			end

			for _, moduleEntity in pairs(ents.FindByClass("alydusbasesystems_module_*")) do
				if IsValid(moduleEntity) and moduleEntity:GetNWEntity("alydusBaseSystems.Owner", nil) == self:GetNWEntity("alydusBaseSystems.Owner", nil) then
					moduleEntity:SetNWEntity("alydusBaseSystems.Owner", false)
				end
			end
		end
	end
end

function ENT:OnTakeDamage(dmg)
	--[[
	if SERVER then
		if dmg and dmg:GetDamage() >= 1 and self:GetNWInt("alydusBaseSystems.Health") >= 1 then
			self:SetNWInt("alydusBaseSystems.Health", self:GetNWInt("alydusBaseSystems.Health") - dmg:GetDamage())
			self:EmitSound("ambient/materials/metal_stress" .. math.random(1, 5) .. ".wav")

			if self:GetNWInt("alydusBaseSystems.Health") <= 0 then
				if GetConVar("sv_alydusbasesystems_enable_basecontroller_destructionexplosion"):GetInt() == 1 then
					local explode = ents.Create("env_explosion")
					explode:SetPos(self:GetPos() + Vector(0, 0, 30))
					explode:Spawn()
					explode:SetKeyValue("iMagnitude", "50")
					explode:SetKeyValue("spawnflags", 16)
					explode:Fire("Explode", 0, 0)
				end

				if GetConVar("sv_alydusbasesystems_enable_basecontroller_destructionignition"):GetInt() == 1 then
					local ignitionTime = GetConVar("sv_alydusbasesystems_enable_basecontroller_destructionignitionlength"):GetInt() or 15
					local ignitionLength = GetConVar("sv_alydusbasesystems_enable_basecontroller_destructionignitionradius"):GetInt() or 0
					self:Ignite(ignitionTime, ignitionLength)
				end

				if GetConVar("sv_alydusbasesystems_enable_basecontroller_destructionexplosionextra"):GetInt() == 1 then
					self:EmitSound("ambient/levels/labs/electric_explosion" .. math.random(1, 5) .. ".wav")
				end
				if GetConVar("sv_alydusbasesystems_enable_basecontroller_destructionscreenshake"):GetInt() == 1 then
					util.ScreenShake(self:GetPos() + Vector(0, 0, 30), 10, 10, 3.5, 150)
				end

				if IsValid(self:GetNWEntity("alydusBaseSystems.Owner", nil)) and self:GetNWEntity("alydusBaseSystems.Owner", nil):GetNWBool("alydusBaseSystems.SystemView", false) == true then
					self:GetNWEntity("alydusBaseSystems.Owner", nil):SetNWBool("alydusBaseSystems.SystemView", false)

					alydusBaseSystems.sendMessage(self:GetNWEntity("alydusBaseSystems.Owner", nil), "Automatically disabled system view since your base controller was destroyed, re-enable it by repairing your base controller and using the toggle button in mode 6 of your base controller.")
				end
			end
		end
	end
	--]]
end


if CLIENT then
	local tdui = include("cl_alydusbasesystems_tdui.lua")

	local function alarmString(input)
		if input >= 1 then
			return "Yes"
		else
			return "No"
		end
	end

	local function enabledString(input)
		if input == true then
			return "Yes"
		else
			return "No"
		end
	end


	local gunTurrets = {
		["alydusbasesystems_module_fallout_basic_turret"] = true,
		["alydusbasesystems_module_fallout_basic_turret_2"] = true,
		["alydusbasesystems_module_fallout_laser_turret_1"] = true,
		["alydusbasesystems_module_fallout_laser_turret_2"] = true,
		["alydusbasesystems_module_fallout_rocket_turret"] = true,
	}

	--[[
	local laserTurrets = {
		["alydusbasesystems_module_fallout_laser_turret_1"] = true,
		["alydusbasesystems_module_fallout_laser_turret_2"] = true,
	}

	local rocketTurrets = {
		["alydusbasesystems_module_fallout_rocket_turret"] = true,
	}
	--]]

	local siren = {
		["alydusbasesystems_module_fallout_siren"] = true,
	}

	function ENT:Draw()
		self:DrawModel()

		if IsValid(self) then
			if bDrawingDepth then return end
			if LocalPlayer():GetPos():Distance(self:GetPos()) >= 128 then return end

			self.p = self.p or tdui.Create()

			local fade = math.abs(math.sin(CurTime() * 3))

			if self:GetNWInt("alydusBaseSystems.Health", 0) <= 0 then
				self.p:Text("Base Controller", "alydusBaseSystems.Title", 0, 0, Color(255, 255, 255))
				if self:GetNWBool("alydusBaseSystems.IsLoading", false) == false then
					self.p:Text("Needs repair", "alydusBaseSystems.Subtitle", 0, 100, Color(150, 150, 150))

                    if self:GetNWEntity("alydusBaseSystems.Owner", nil) == LocalPlayer() then
                        if self.p:Button("Repair Controller", "alydusBaseSystems.Title", -350, 250, 700, 125, Color(191, 191, 191), Color(46, 204, 113), Color(46, 204, 113)) then
                            net.Start("alydusBaseSystems.repairBaseController")
                            net.WriteEntity(self)
                            net.SendToServer()
                        end
                    else
                       self.p:Text("You do not own this.", "alydusBaseSystems.Title", 0, 225, Color(150, 150, 150, 255))
                    end
				else
					self.p:Text("Repairing systems...", "alydusBaseSystems.Title", 0, 225, Color(46, 204, 113, fade * 255))
				end
			else
				if IsValid(self:GetNWEntity("alydusBaseSystems.Owner", nil)) then
					if self:GetNWEntity("alydusBaseSystems.Owner", nil) == LocalPlayer() then
						local ply = self:GetNWEntity("alydusBaseSystems.Owner")

						if self:GetNWBool("alydusBaseSystems.IsLoading", false) == true then
							self.p:Text("Base Controller", "alydusBaseSystems.Title", 0, 0, Color(255, 255, 255))

							self.p:Text("Welcome, " .. ply:Nick() .. ".", "alydusBaseSystems.Title", 0, 250, Color(150, 150, 150))

							self.p:Text("Booting up systems...", "alydusBaseSystems.Title", 0, 350, Color(46, 204, 113, fade * 255))
						else
							local moduleTable = {}
							local moduleCount = 0
							local cameraModuleCount = 0
							local gunTurretModuleCount = 0
							local samTurretModuleCount = 0
							local doorServoModuleCount = 0
							local laserTurretModuleCount = 0
							local alarmModuleCount = 0

							local operatingGunTurretModuleCount = 0
							local operatingSamTurretModuleCount = 0
							local operatingAlarmModuleCount = 0
							local operatingLaserTurretModuleCount = 0

							local enabledAlarmCount = 0

							local combinedHealth = 0

							controlMode = controlMode or 0

							for _, moduleEntity in pairs(ents.FindByClass("alydusbasesystems_module_*")) do
								if IsValid(moduleEntity) and IsValid(moduleEntity:GetNWEntity("alydusBaseSystems.Owner", nil)) and moduleEntity:GetNWEntity("alydusBaseSystems.Owner") == ply and moduleEntity:GetNWInt("alydusBaseSystems.Health", nil) != nil then
									if moduleEntity:GetClass() == "alydusbasesystems_module_camera" then
										cameraModuleCount = cameraModuleCount + 1
									elseif gunTurrets[moduleEntity:GetClass()] then
										gunTurretModuleCount = gunTurretModuleCount + 1

										if moduleEntity:GetNWInt("alydusBaseSystems.Health", 0) >= 1 then
											operatingGunTurretModuleCount = operatingGunTurretModuleCount + 1
										end
									elseif siren[moduleEntity:GetClass()] then
										alarmModuleCount = alarmModuleCount + 1

										if moduleEntity:GetNWInt("alydusBaseSystems.Health", 0) >= 1 then
											operatingAlarmModuleCount = operatingAlarmModuleCount + 1
										end

										if moduleEntity:GetNWBool("alydusBaseSystems.Alarm", false) == true then
											enabledAlarmCount = enabledAlarmCount + 1
										end
									--[[
									elseif laserTurrets[moduleEntity:GetClass()] then
										laserTurretModuleCount = laserTurretModuleCount + 1

										if moduleEntity:GetNWInt("alydusBaseSystems.Health", 0) >= 1 then
											operatingLaserTurretModuleCount = operatingLaserTurretModuleCount + 1
										end
									elseif rocketTurrets[moduleEntity:GetClass()] then
										samTurretModuleCount = samTurretModuleCount + 1

										if moduleEntity:GetNWInt("alydusBaseSystems.Health", 0) >= 1 then
											operatingSamTurretModuleCount = operatingSamTurretModuleCount + 1
										end
									elseif moduleEntity:GetClass() == "alydusbasesystems_module_doorservo" then
										doorServoModuleCount = doorServoModuleCount + 1
									--]]
									end

									table.insert(moduleTable, moduleEntity)
									moduleCount = moduleCount + 1
									combinedHealth = combinedHealth + moduleEntity:GetNWInt("alydusBaseSystems.Health", 0)
								end
							end

							if enabledAlarmCount <= 0 then
								self.p:Text("Base Controller", "alydusBaseSystems.Title", 0, 0, Color(255, 255, 255))
							else
								self.p:Text("Base Controller", "alydusBaseSystems.Title", 0, 0, Color(192, 57, 43, fade * 255))
							end

							local controlModes = {}
							controlModes[0] = 0
							controlModes[1] = 1
							controlModes[2] = 2
							controlModes[3] = 3
							controlModes[4] = 4
							--controlModes[5] = 5
							--controlModes[6] = 6
							--controlModes[7] = 7

							if controlMode == 0 then
								self.p:Text("Mode: Dashboard (0/" .. #controlModes .. ")", "alydusBaseSystems.Subtitle", 0, 100, Color(150, 150, 150))
								self.p:Text("Modules: " .. moduleCount .. " - Total HP: " .. math.Round(combinedHealth), "alydusBaseSystems.Body", 0, 200, Color(150, 150, 150))

								if self:GetNWBool("alydusBaseSystems.IsRepairingModules", false) != true then
									if moduleCount >= 1 then
										if self.p:Button("Repair Modules", "alydusBaseSystems.BodyButton", -250, 300, 500, 75, Color(191, 191, 191), Color(46, 204, 113), Color(46, 204, 113)) then
											net.Start("alydusBaseSystems.repairModules")
											net.WriteEntity(self)
											net.SendToServer()
										end
									else
										self.p:Text("You have no modules to repair.", "alydusBaseSystems.BodyButton", 0, 300, Color(150, 150, 150, 255))
									end
								else
									self.p:Text("Repairing modules...", "alydusBaseSystems.BodyButton", 0, 300, Color(46, 204, 113, fade * 255))
								end
							elseif controlMode == 1 then
								self.p:Text("Mode: Camera System (1/" .. #controlModes .. ")", "alydusBaseSystems.Subtitle", 0, 100, Color(150, 150, 150))
								if cameraModuleCount >= 1 then
									self.p:Text("Camera Modules: " .. cameraModuleCount, "alydusBaseSystems.Body", 0, 200, Color(150, 150, 150))

									if self.p:Button("Camera's Uplink", "alydusBaseSystems.BodyButton", -250, 300, 500, 75, Color(191, 191, 191), Color(46, 204, 113), Color(46, 204, 113)) then
										net.Start("alydusBaseSystems.joinCameraUplink")
										net.WriteEntity(self)
										net.SendToServer()
									end
								else
									self.p:Text("You have no camera modules.", "alydusBaseSystems.Body", 0, 200, Color(150, 150, 150))
								end
							elseif controlMode == 2 then
								self.p:Text("Mode: Alarm System (2/" .. #controlModes .. ")", "alydusBaseSystems.Subtitle", 0, 100, Color(150, 150, 150))
								if alarmModuleCount >= 1 then
									self.p:Text("Module: " .. alarmString(alarmModuleCount) .. " - Operational: " .. operatingAlarmModuleCount .. "/" .. alarmModuleCount, "alydusBaseSystems.Body", 0, 200, Color(150, 150, 150))

									if self.p:Button("Toggle", "alydusBaseSystems.BodyButton", -300, 300, 300, 75, Color(191, 191, 191), Color(46, 204, 113), Color(46, 204, 113)) then
										net.Start("alydusBaseSystems.toggleAlarm")
										net.WriteEntity(self)
										net.SendToServer()
									end

									if self.p:Button("Reset", "alydusBaseSystems.BodyButton", 50, 300, 300, 75, Color(191, 191, 191), Color(46, 204, 113), Color(46, 204, 113)) then
										net.Start("alydusBaseSystems.resetAlarm")
										net.WriteEntity(self)
										net.SendToServer()
									end
								else
									self.p:Text("You have no alarm modules.", "alydusBaseSystems.Body", 0, 200, Color(150, 150, 150))
								end
							elseif controlMode == 3 then
								self.p:Text("Mode: System View (3/" .. #controlModes .. ")", "alydusBaseSystems.Subtitle", 0, 100, Color(150, 150, 150))
								if moduleCount >= 1 then
									if self.p:Button("Toggle System View", "alydusBaseSystems.BodyButton", -350, 200, 700, 75, Color(191, 191, 191), Color(46, 204, 113), Color(46, 204, 113)) then
										net.Start("alydusBaseSystems.toggleSystemView")
										net.WriteEntity(self)
										net.SendToServer()
									end

									self.p:Text("Use to view connected modules", "alydusBaseSystems.Body", 0, 290, Color(150, 150, 150))
								else
									self.p:Text("You have no modules to view.", "alydusBaseSystems.Body", 0, 200, Color(150, 150, 150))
								end
							elseif controlMode == 4 then
								self.p:Text("Mode: Gun Turrets (4/" .. #controlModes .. ")", "alydusBaseSystems.Subtitle", 0, 100, Color(150, 150, 150))
								if gunTurretModuleCount >= 1 then
									self.p:Text("Gun Turret Modules: " .. gunTurretModuleCount, "alydusBaseSystems.Body", 0, 200, Color(150, 150, 150))

									local shootPlayers = self:GetNWBool("alydusBaseSystems.gunTurretsShootPlayers", false)
									local shootNPCs = self:GetNWBool("alydusBaseSystems.gunTurretsShootNPCs", false)

									if self.p:Button("NPC: " .. enabledString(shootNPCs), "alydusBaseSystems.BodyButton", 25, 310, 250, 75, Color(191, 191, 191), Color(46, 204, 113), Color(46, 204, 113)) then
										net.Start("alydusBaseSystems.toggleGunTurretProperty")
										net.WriteEntity(self)
										net.WriteString("NPC")
										net.SendToServer()

										surface.PlaySound("alydus/controllerclick.wav")
									end

									--[[
									if self.p:Button("Players: " .. enabledString(shootPlayers), "alydusBaseSystems.BodyButton", -325, 310, 300, 75, Color(191, 191, 191), Color(46, 204, 113), Color(46, 204, 113)) then
										net.Start("alydusBaseSystems.toggleGunTurretProperty")
										net.WriteEntity(self)
										net.WriteString("Player")
										net.SendToServer()
									end
									--]]

									if self.p:Button("Factions", "alydusBaseSystems.BodyButton", -325, 310, 300, 75, Color(191, 191, 191), Color(46, 204, 113), Color(46, 204, 113)) then
										local factions = self:GetNWString("alydusBaseSystems.factionTargets")
										if(factions != "") then
											factions = util.JSONToTable(factions)
										else
											factions = {}
										end

										local popup = vgui.Create("DFrame")
										popup:Center()
										popup:SetSize(200, 200)
										popup:SetTitle("Factions")
										popup:SetDraggable(true)
										popup:MakePopup()

										local scroll = popup:Add("DScrollPanel")
										scroll:Dock(FILL)

										for k, v in pairs(nut.faction.indices or {}) do
											local faction = scroll:Add("DCheckBoxLabel")
											faction:Dock(TOP)
											faction:SetText(v.name or "")
											faction:SetToolTip("Attack " ..v.name.. "?")

											if(istable(factions) and factions[k]) then
												faction:SetValue(true)
											else
												faction:SetValue(false)
											end

											local baseControl = self
											function faction:OnChange(val, self)
												net.Start("alydusBaseSystems.openFactionTarget")
												net.WriteEntity(baseControl)
												net.WriteInt(k, 32)
												net.WriteBool(val)
												net.SendToServer()
											end
										end
									end
								else
									self.p:Text("You have no gun turret modules.", "alydusBaseSystems.Body", 0, 200, Color(150, 150, 150))
								end

							--[[
								self.p:Text("Mode: SAM Turrets (3/" .. #controlModes .. ")", "alydusBaseSystems.Subtitle", 0, 100, Color(150, 150, 150))
								if samTurretModuleCount >= 1 then
									self.p:Text("SAM Turret Modules: " .. operatingSamTurretModuleCount .. "/" .. samTurretModuleCount, "alydusBaseSystems.Body", 0, 200, Color(150, 150, 150))
								else
									self.p:Text("You have no SAM turret modules.", "alydusBaseSystems.Body", 0, 200, Color(150, 150, 150))
								end
							elseif controlMode == 4 then
								self.p:Text("Mode: Door Servos (4/" .. #controlModes .. ")", "alydusBaseSystems.Subtitle", 0, 100, Color(150, 150, 150))
								if doorServoModuleCount >= 1 then
									self.p:Text("Door Servo Modules: " .. doorServoModuleCount, "alydusBaseSystems.Body", 0, 200, Color(150, 150, 150))

									if self.p:Button("Lock All", "alydusBaseSystems.BodyButton", -300, 300, 300, 75, Color(191, 191, 191), Color(46, 204, 113), Color(46, 204, 113)) then
										net.Start("alydusBaseSystems.controlDoorServos")
										net.WriteEntity(self)
										net.WriteString("lock")
										net.SendToServer()
									end

									if self.p:Button("Unlock All", "alydusBaseSystems.BodyButton", 50, 300, 300, 75, Color(191, 191, 191), Color(46, 204, 113), Color(46, 204, 113)) then
										net.Start("alydusBaseSystems.controlDoorServos")
										net.WriteEntity(self)
										net.WriteString("unlock")
										net.SendToServer()
									end
								else
									self.p:Text("You have no door servo modules.", "alydusBaseSystems.Body", 0, 200, Color(150, 150, 150))
								end
							elseif controlMode == 5 then
								self.p:Text("Mode: Alarm System (5/" .. #controlModes .. ")", "alydusBaseSystems.Subtitle", 0, 100, Color(150, 150, 150))
								if alarmModuleCount >= 1 then
									self.p:Text("Module: " .. alarmString(alarmModuleCount) .. " - Operational: " .. operatingAlarmModuleCount .. "/" .. alarmModuleCount, "alydusBaseSystems.Body", 0, 200, Color(150, 150, 150))

									if self.p:Button("Toggle", "alydusBaseSystems.BodyButton", -300, 300, 300, 75, Color(191, 191, 191), Color(46, 204, 113), Color(46, 204, 113)) then
										net.Start("alydusBaseSystems.toggleAlarm")
										net.WriteEntity(self)
										net.SendToServer()
									end

									if self.p:Button("Reset", "alydusBaseSystems.BodyButton", 50, 300, 300, 75, Color(191, 191, 191), Color(46, 204, 113), Color(46, 204, 113)) then
										net.Start("alydusBaseSystems.resetAlarm")
										net.WriteEntity(self)
										net.SendToServer()
									end
								else
									self.p:Text("You have no alarm modules.", "alydusBaseSystems.Body", 0, 200, Color(150, 150, 150))
								end
							elseif controlMode == 6 then
								self.p:Text("Mode: System View (6/" .. #controlModes .. ")", "alydusBaseSystems.Subtitle", 0, 100, Color(150, 150, 150))
								if moduleCount >= 1 then
									if self.p:Button("Toggle System View", "alydusBaseSystems.BodyButton", -350, 200, 700, 75, Color(191, 191, 191), Color(46, 204, 113), Color(46, 204, 113)) then
										net.Start("alydusBaseSystems.toggleSystemView")
										net.WriteEntity(self)
										net.SendToServer()
									end

									self.p:Text("Use to view connected modules", "alydusBaseSystems.Body", 0, 290, Color(150, 150, 150))
								else
									self.p:Text("You have no modules to view.", "alydusBaseSystems.Body", 0, 200, Color(150, 150, 150))
								end
							elseif controlMode == 7 then
								self.p:Text("Mode: Laser Turrets (7/" .. #controlModes .. ")", "alydusBaseSystems.Subtitle", 0, 100, Color(150, 150, 150))
								if laserTurretModuleCount >= 1 then
									self.p:Text("Laser Turret Modules: " .. operatingLaserTurretModuleCount .. "/" .. laserTurretModuleCount, "alydusBaseSystems.Body", 0, 200, Color(150, 150, 150))
								else
									self.p:Text("You have no laser turret modules.", "alydusBaseSystems.Body", 0, 200, Color(150, 150, 150))
								end
							--]]
							end

							if self.p:Button(">", "alydusBaseSystems.BodyButton", 400, 415, 75, 75, Color(191, 191, 191), Color(46, 204, 113), Color(46, 204, 113)) then
								if controlModes[controlMode + 1] then
									controlMode = controlMode + 1
								else
									controlMode = 0
								end

								surface.PlaySound("alydus/controllerclick.wav")
							end

							if self.p:Button("<", "alydusBaseSystems.BodyButton", -450, 415, 75, 75, Color(191, 191, 191), Color(46, 204, 113), Color(46, 204, 113)) then
								if controlModes[controlMode - 1] then
									controlMode = controlMode - 1
								else
									controlMode = #controlModes
								end

								surface.PlaySound("alydus/controllerclick.wav")
							end

							--self.p:Text("Owner: " .. ply:Nick(), "alydusBaseSystems.Footer", 0, 400, Color(150, 150, 150))
						end
					else
						self.p:Text("Base Controller", "alydusBaseSystems.Title", 0, 0, Color(255, 255, 255))

						self.p:Text("Control base modules", "alydusBaseSystems.Subtitle", 0, 100, Color(150, 150, 150))
						local ply = self:GetNWEntity("alydusBaseSystems.Owner")
						self.p:Text("You do not own this.", "alydusBaseSystems.Title", 0, 250, Color(150, 150, 150))

						self.p:Text("Owner: " .. ply:Nick(), "alydusBaseSystems.Footer", 0, 400, Color(150, 150, 150))
					end
				else
					self.p:Text("Base Controller", "alydusBaseSystems.Title", 0, 0, Color(255, 255, 255))

					if self.p:Button("Claim Controller", "alydusBaseSystems.Title", -350, 250, 700, 125, Color(191, 191, 191), Color(46, 204, 113), Color(46, 204, 113)) then
						net.Start("alydusBaseSystems.claimBaseController")
						net.WriteEntity(self)
						net.SendToServer()
					end

					self.p:Text("Owner: None", "alydusBaseSystems.Footer", 0, 400, Color(150, 150, 150))
				end
			end

			self.p:Render(self:GetPos() + (self:GetAngles():Up() * 63) + (self:GetAngles():Forward() * 12.5) + (self:GetRight() * -0.5), Angle(self:GetAngles().x, self:GetAngles().y + 90, 0) + Angle(0, 90, 0), 0.0125)
		end
	end
end
