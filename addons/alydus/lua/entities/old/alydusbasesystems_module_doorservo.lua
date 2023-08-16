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
		self:SetModel("models/bo/weapons/signal jammer.mdl")
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
	local doorList = {}
	doorList["func_door"] = true
	doorList["func_door_rotating"] = true
	doorList["prop_door"] = true
	doorList["prop_door_rotating"] = true

	function ENT:DoorServoAction(action)
		local nearbyDoors = {}

		for _, door in pairs(ents.FindInSphere(self:GetPos(), 75)) do
			if IsValid(door) and doorList[door:GetClass()] then
				table.insert(nearbyDoors, door)
			end
		end

		if action == "lock" then
			for _, door in pairs(nearbyDoors) do
				door:Fire("Close", "", 0)
				door:Fire("Lock", "", 0)
			end
		elseif action == "unlock" then
			for _, door in pairs(nearbyDoors) do
				door:Fire("UnLock", "", 0)
				door:Fire("Open", "", 0)
			end
		end
	end
end
ENT.Type = "anim"
ENT.Base = "alydusbasesystems_module_base"
ENT.Spawnable = true
ENT.Category = "Alydus Base Systems"
ENT.PrintName = "Module - Door Servo"
ENT.Author = "Alydus"
ENT.Contact = "Alydus"
ENT.Purpose = ""
ENT.Instructions = ""