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
		self:SetModel("models/bo/weapons/acoustic motion sensor deployed.mdl")
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

		if WireAddon then
			self.Outputs = Wire_CreateOutputs(self, {
				"Module Health"
			})
			Wire_TriggerOutput(self, "Module Health", self:GetNWInt("alydusBaseSystems.Health", 0))
		end

		self:SetPos(self:GetPos() + Vector(0, 0, 20))

		self:DropToFloor()
	end
end

if SERVER then
	function ENT:Think()
        if self:GetNWEntity("alydusBaseSystems.Owner", nil) != nil and self:GetNWInt("alydusBaseSystems.Health", 0) >= 1 then
            for _, ent in pairs(ents.FindInSphere(self:GetPos(), GetConVar("sv_alydusbasesystems_config_proximitytrigger_range"):GetInt())) do
                if IsValid(ent) and (ent:IsNPC() or ent:IsPlayer()) then
                    local canTrigger = true

                    if self:GetNWEntity("alydusBaseSystems.Owner", nil) == ent then
                        canTrigger = false 
                    end

                    if CPPI then
                        local isBuddy = false
                        local owner = self:GetNWEntity("alydusBaseSystems.Owner", nil)
                        if IsValid(owner) and not isnumber(owner:CPPIGetFriends()) then
                            for _, buddy in pairs(owner:CPPIGetFriends()) do
                                if buddy == ent then
                                    isBuddy = true
                                end
                            end

                            if isBuddy then
                                canTrigger = false
                            end
                        end
                    end

                    if canTrigger == true then
                        local ply = self:GetNWEntity("alydusBaseSystems.Owner", nil)

                        for _, alarmModule in pairs(ents.FindByClass("alydusbasesystems_module_alarm")) do
                            if IsValid(alarmModule) and alarmModule:GetNWInt("alydusBaseSystems.Health", false) != false and alarmModule:GetNWInt("alydusBaseSystems.Health") >= 1 and alarmModule:GetNWEntity("alydusBaseSystems.Owner", nil) == ply then
                                alarmModule:ControlAlarm("on")
                            end
                        end 
                    end
                end
            end
        end
	end
end
ENT.Type = "anim"
ENT.Base = "alydusbasesystems_module_base"
ENT.Spawnable = true
ENT.Category = "Alydus Base Systems"
ENT.PrintName = "Module - Proximity Trigger"
ENT.Author = "Alydus"
ENT.Contact = "Alydus"
ENT.Purpose = ""
ENT.Instructions = ""