--[[ 
	© Alydus.net
	Do not reupload lua to workshop without permission of the author

	Alydus Base Systems
	
	Alydus: (officialalydus@gmail.com | STEAM_0:1:57622640)
--]]

if CLIENT then
	function ENT:Draw()
			self:DrawModel()
	end
else
	AddCSLuaFile()
end

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/bo/weapons/radio.mdl")
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
		self:SetNWInt("alydusBaseSystems.Health", GetConVar("sv_alydusbasesystems_config_module_defaulthealth"):GetInt())
		self:SetNWBool("alydusBaseSystems.Alarm", false)

		self.loopingAlarmID = nil
        
        if IsValid(self:Getowning_ent()) then
            self:SetNWEntity("alydusBaseSystems.Owner", self:Getowning_ent())
        end

		if WireAddon then
			self.Outputs = Wire_CreateOutputs(self, {
				"Alarm Status",
				"Module Health"
			})
			Wire_TriggerOutput(self, "Alarm Status", alydusBaseSystems.boolToInt(self:GetNWBool("alydusBaseSystems.Alarm", false)))
			Wire_TriggerOutput(self, "Module Health", self:GetNWInt("alydusBaseSystems.Health", 0))
		end

        self:SetPos(self:GetPos() + Vector(0, 0, 20))

        self:DropToFloor()
	end
end

if SERVER then
	function ENT:ControlAlarm(action)
		if action == "on" then
			self:SetNWBool("alydusBaseSystems.Alarm", true)
			if self.loopingAlarmID == nil then
				self.loopingAlarmID = CreateSound(self, "alydus/intruderalarm.wav")
				self.loopingAlarmID:SetSoundLevel(GetConVar("sv_alydusbasesystems_config_alarm_soundlevel"):GetInt())
				self.loopingAlarmID:Play()
			end
		elseif action == "off" then
			self:SetNWBool("alydusBaseSystems.Alarm", false)
			if self.loopingAlarmID != nil then
				self.loopingAlarmID:Stop()
				self.loopingAlarmID = nil
			end
		elseif action == "toggle" then
			if self:GetNWBool("alydusBaseSystems.Alarm", false) == true then
				self:SetNWBool("alydusBaseSystems.Alarm", false)
				if self.loopingAlarmID != nil then
					self.loopingAlarmID:Stop()
					self.loopingAlarmID = nil
				end
			else
				self:SetNWBool("alydusBaseSystems.Alarm", true)
				if self.loopingAlarmID == nil then
					self.loopingAlarmID = CreateSound(self, "alydus/intruderalarm.wav")
					self.loopingAlarmID:SetSoundLevel(GetConVar("sv_alydusbasesystems_config_alarm_soundlevel"):GetInt())
					self.loopingAlarmID:Play()
				end
			end
		end
		if WireAddon then
			Wire_TriggerOutput(self, "Alarm Status", alydusBaseSystems.boolToInt(self:GetNWBool("alydusBaseSystems.Alarm", false)))
		end
	end
end
ENT.Type = "anim"
ENT.Base = "alydusbasesystems_module_base"
ENT.Spawnable = true
ENT.Category = "Alydus Base Systems"
ENT.PrintName = "Module - Alarm"
ENT.Author = "Alydus"
ENT.Contact = "Alydus"
ENT.Purpose = ""
ENT.Instructions = ""