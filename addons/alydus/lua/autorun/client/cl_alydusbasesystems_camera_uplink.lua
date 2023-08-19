--[[ 
	© Alydus.net
	Do not reupload lua to workshop without permission of the author

	Alydus Base Systems
	
	Alydus: (officialalydus@gmail.com | STEAM_0:1:57622640)
--]]

local x3, y3 = 0, 0

hook.Add("PreDrawViewModel", "alydusBaseSystems.PreDrawViewModel.CameraUplink", function(vm, ply, wep)
	if IsValid(ply) and ply:IsPlayer() and ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", false) != false and ply:GetNWBool("isInMenuScreen", false) == false then
		return true
	end
end)

hook.Add("ShouldDrawLocalPlayer", "alydusBaseSystems.PreDrawViewModel.CameraUplink", function(ply)
	if IsValid(ply) and ply:IsPlayer() and ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", false) != false and ply:GetNWBool("isInMenuScreen", false) == false then
		return false
	end
end)

hook.Add("PrePlayerDraw", "alydusBaseSystems.PreDrawViewModel.CameraUplink", function(ply)
	if IsValid(ply) and ply:IsPlayer() and LocalPlayer() == ply and ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", false) != false and ply:GetNWBool("isInMenuScreen", false) == false then
		return true
	end
end)

hook.Add("DrawPhysgunBeam", "alydusBaseSystems.PreDrawViewModel.CameraUplink", function(ply, physgun, enabled, target, physBone, hitPos)
	if IsValid(ply) and ply:IsPlayer() and LocalPlayer() == ply and ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", false) != false and ply:GetNWBool("isInMenuScreen", false) == false then
		return false
	end
end)

hook.Add("AdjustMouseSensitivity", "alydusBaseSystems.AdjustMouseSensitivity.CameraMouseSensitivity", function()
	local ply = LocalPlayer()

	if IsValid(ply) and ply:IsPlayer() and LocalPlayer() == ply and ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", false) != false and ply:GetNWBool("isInMenuScreen", false) == false then
		return 0.1
	end
end)

local previousY = previousY or 0

hook.Add("CalcView", "alydusBaseSystems.CalcView.CameraUplink", function(ply, pos, angles, fov)
	if IsValid(ply) and ply:IsPlayer() and IsValid(ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", nil)) and ply:GetNWBool("isInMenuScreen", false) == false then
		local baseCameras = ents.FindByClass("alydusbasesystems_module_camera")
		local baseCameraVector = Vector(0, 0, 0)
		local baseCameraAngles = Angle(0, 0, 0)
		local cameraEntity = false

		for cameraModuleKey, cameraModule in pairs(baseCameras) do
			if cameraModule:GetNWEntity("alydusBaseSystems.Owner", nil) == ply and ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", nil) == cameraModule then
				baseCameraVector = cameraModule:GetPos() + (cameraModule:GetAngles():Up() * 15)
				baseCameraAngles = cameraModule:GetAngles()
				cameraEntity = cameraModule
				break
			end
		end

		local view = {}
		view.origin = baseCameraVector
		if cameraEntity:GetNWInt("alydusBaseSystems.Health", 0) <= 0 then
			view.angles = Angle(45, 0, 0)
		else
			if previousY != angles.y then
				ply.cameraServoSound = ply:StartLoopingSound("alydus/servo.wav")
			else
				if ply.cameraServoSound then
					ply:StopLoopingSound(ply.cameraServoSound)
				end
			end

			previousY = angles.y

			view.angles = Angle(math.Clamp(angles.x, -45, 45), angles.y, 0)
		end
		view.fov = 90
		view.drawviewer = false

		return view
	else
		if ply.cameraServoSound then
			ply:StopLoopingSound(ply.cameraServoSound)
		end
	end
end)