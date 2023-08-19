--[[ 
	© Alydus.net
	Do not reupload lua to workshop without permission of the author

	Alydus Base Systems
	
	Alydus: (officialalydus@gmail.com | STEAM_0:1:57622640)
--]]

if CLIENT then
	function ENT:Draw()
		if LocalPlayer():GetNWEntity("alydusBaseSystems.ViewingCameraEntity", false) != self then
			self:DrawModel()

			local upAngle = 45
			local spinSpeed = 50
			local spinAngle = 0

			if IsValid(self:GetNWEntity("alydusBaseSystems.Owner")) and self:GetNWInt("alydusBaseSystems.Health", 0) >= 1 then
				upAngle = -15
				spinAngle = spinSpeed * CurTime() + (self:EntIndex() * 50)
			end

			if self:GetModel() != "models/bo/weapons/camera spike folded.mdl" then
				self:ManipulateBoneAngles(2, Angle(upAngle, spinAngle, 0))
			end
		end
	end
else
	AddCSLuaFile()
end

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/bo/weapons/camera spike.mdl")
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
        
        if IsValid(self:Getowning_ent()) then
            self:SetNWEntity("alydusBaseSystems.Owner", self:Getowning_ent())
        end

		if WireAddon then
			self.Outputs = Wire_CreateOutputs(self, {
				"Module Health"
			})
			Wire_TriggerOutput(self, "Module Health", self:GetNWInt("alydusBaseSystems.Health", 0))
		end

        self:SetPos(self:GetPos() + Vector(0, 0, 40))

        self:DropToFloor()
	end
end

if SERVER then
	hook.Add("EntityTakeDamage", "alydusBaseSystems.EntityTakeDamage.CameraManagement", function(target, dmg)
		if IsValid(target) and target:IsPlayer() and target:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", false) != false and dmg and dmg:GetDamage() >= 1 then
			alydusBaseSystems.sendMessage(target, "Aborted camera uplink as you took damage.")
			target:SetNWEntity("alydusBaseSystems.ViewingCameraEntity", false)
		end
	end)

	hook.Add("SetupPlayerVisibility", "alydusBaseSystems.SetupPlayerVisibility", function(ply, viewEntity)
		if IsValid(ply) and ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", false) != false then
			if IsValid(ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity")) then
				AddOriginToPVS(ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity"):GetPos())
			end
		end
	end)

	hook.Add("KeyPress", "alydusBaseSystems.KeyPress.CameraControlKeys", function(ply, key)
		if IsValid(ply) and ply:IsPlayer() and IsValid(ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", nil)) then
			local cameraList = {}
			local cameraCounter = 0

			for cameraNumber, cameraModule in pairs(ents.FindByClass("alydusbasesystems_module_camera")) do
				if IsValid(cameraModule) and cameraModule:GetNWEntity("alydusBaseSystems.Owner", nil) == ply then
					cameraCounter = cameraCounter + 1
					cameraList[cameraCounter] = cameraModule
				end
			end

			local currentCameraNumber = 0

			for cameraNumber, cameraEntity in pairs(cameraList) do
				if cameraEntity == ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", nil) then
					currentCameraNumber = cameraNumber
				end
			end

			if key == IN_USE then
				if cameraList[currentCameraNumber - 1] and ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", nil) != cameraList[currentCameraNumber - 1] then
					ply:SetNWEntity("alydusBaseSystems.ViewingCameraEntity", cameraList[currentCameraNumber - 1])
					cameraList[currentCameraNumber - 1]:EmitSound("alydus/controllerclick.wav")
					ply:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 255), 1.5, 0.5)
				elseif ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", nil) != cameraList[#cameraList] then
					ply:SetNWEntity("alydusBaseSystems.ViewingCameraEntity", cameraList[#cameraList])
					cameraList[#cameraList]:EmitSound("alydus/controllerclick.wav")
					ply:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 255), 1.5, 0.5)
				end
			elseif key == IN_RELOAD then
				if cameraList[currentCameraNumber + 1] and ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", nil) != cameraList[currentCameraNumber + 1] then
					ply:SetNWEntity("alydusBaseSystems.ViewingCameraEntity", cameraList[currentCameraNumber + 1])
					cameraList[currentCameraNumber + 1]:EmitSound("alydus/controllerclick.wav")
					ply:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 255), 1.5, 0.5)
				elseif ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", nil) != cameraList[1] then
					ply:SetNWEntity("alydusBaseSystems.ViewingCameraEntity", cameraList[1])
					cameraList[1]:EmitSound("alydus/controllerclick.wav")
					ply:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 255), 1.5, 0.5)
				end
			elseif key == IN_SPEED and ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", nil):GetNWInt("alydusBaseSystems.Health", 0) >= 1 then
				if ply:GetNWBool("alydusBaseSystems.ViewingCameraNightvision", false) == true then
					ply:SetNWBool("alydusBaseSystems.ViewingCameraNightvision", false)
				else
					if IsValid(ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", nil)) then
						ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity"):EmitSound("alydus/nightvisionon.wav")
					end
					ply:SetNWBool("alydusBaseSystems.ViewingCameraNightvision", true)
				end
			elseif key == IN_JUMP then
				ply:SetNWEntity("alydusBaseSystems.ViewingCameraEntity", false)
				ply:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 255), 1.5, 0.25)
			end
		end
	end)
end
ENT.Type = "anim"
ENT.Base = "alydusbasesystems_module_base"
ENT.Spawnable = true
ENT.Category = "Alydus Base Systems"
ENT.PrintName = "Module - Camera"
ENT.Author = "Alydus"
ENT.Contact = "Alydus"
ENT.Purpose = ""
ENT.Instructions = ""