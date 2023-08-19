--[[ 
	© Alydus.net	
	Do not reupload lua to workshop without permission of the author
	Alydus Base Systems
	Alydus: (officialalydus@gmail.com | STEAM_0:1:57622640)
--]]
function draw.Circle(x, y, radius, seg)
	local cir = {}
	table.insert(cir, {x = x, y = y, u = 0.5, v = 0.5})
	for i = 0, seg do
		local a = math.rad((i / seg) * -360)
		table.insert(cir, {x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5})
	end
	local a = math.rad(0)
	table.insert(cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 })
	surface.DrawPoly(cir)
endlocal tab = {	[ "$pp_colour_addr" ] = 0,	[ "$pp_colour_addg" ] = 0,	[ "$pp_colour_addb" ] = 0,	[ "$pp_colour_brightness" ] = 0.1,	[ "$pp_colour_contrast" ] = 0.85,	[ "$pp_colour_colour" ] = 1,	[ "$pp_colour_mulr" ] = 0,	[ "$pp_colour_mulg" ] = 0,	[ "$pp_colour_mulb" ] = 0}		
hook.Add("RenderScreenspaceEffects", "alydusBaseSystems.RenderScreenspaceEffects.CameraRenderEffects", function()
	local ply = LocalPlayer()
	if 		IsValid(ply) and 		ply:IsPlayer() and 		ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", false) and 		ply:GetNWBool("isInMenuScreen", false)	then
		if ply:GetNWBool("alydusBaseSystems.ViewingCameraNightvision", false) == true then
			tab["$pp_colour_mulg"] = 5
			tab["$pp_colour_contrast"] = 2.5		else			tab["$pp_colour_mulg"] = 0			tab["$pp_colour_contrast"] = 0.85
		end
		if ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", nil):GetNWInt("alydusBaseSystems.Health", 0) <= 0 then
			tab["$pp_colour_contrast"] = 0.1		else			tab["$pp_colour_contrast"] = 0.85
		end
		DrawColorModify(tab)
	end
end)
local brokenCameraMaterial = brokenCameraMaterial or Material("alydus/alydusbasesystems/brokencamera.png")
hook.Add("HUDPaint", "alydusBaseSystems.HUDPaint.DrawCameraHUD", function()
	local ply = LocalPlayer()
	if IsValid(ply) and ply:Alive() and ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", false) != false then
		local fade = math.abs(math.sin(CurTime() * 3))
		local cameraList = {}
		for cameraNumber, cameraModule in pairs(ents.FindByClass("alydusbasesystems_module_camera")) do
			if IsValid(cameraModule) and cameraModule:GetNWInt("alydusBaseSystems.Health", false) != false and cameraModule:GetNWEntity("alydusBaseSystems.Owner", nil) == ply then
				cameraList[cameraNumber] = cameraModule
			end
		end
		local currentCameraNumber = 0
		for cameraNumber, cameraEntity in pairs(cameraList) do
			if cameraEntity == ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", nil) then
				currentCameraNumber = cameraNumber
			end
		end
		local currentCamera = ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", nil)
		local maximumClaimRadius = GetConVar("sv_alydusbasesystems_enable_module_maximumclaimradius"):GetInt() or 3500
		local playerClaimedController = false
		for _, otherBaseController in pairs(ents.FindByClass("alydusbasesystems_basecontroller")) do
			if IsValid(otherBaseController) and IsValid(otherBaseController:GetNWEntity("alydusBaseSystems.Owner")) and otherBaseController:GetNWEntity("alydusBaseSystems.Owner") == ply then
				playerClaimedController = otherBaseController
			end
		end
		draw.SimpleText("Exit: Jump (SPACE)", "alydusBaseSystems.CameraHUDTitle", ScrW() / 2, ScrH() - 180, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		if currentCamera:GetNWInt("alydusBaseSystems.Health", 0) >= 1 then
			draw.SimpleText("Previous Camera: E (USE) | Next Camera: R (RELOAD) | Enable NV: SHIFT (SPRINT / SPEED)", "alydusBaseSystems.CameraHUDSubtitle", ScrW() / 2, ScrH() - 145, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText("Previous Camera: E (USE) | Next Camera: R (RELOAD)", "alydusBaseSystems.CameraHUDSubtitle", ScrW() / 2, ScrH() - 145, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		if IsValid(playerClaimedController) and playerClaimedController != false and IsValid(currentCamera) and currentCamera:GetNWInt("alydusBaseSystems.Health", 0) >= 1 and currentCamera:GetPos():Distance(playerClaimedController:GetPos()) < maximumClaimRadius then
			surface.SetDrawColor(150, 150, 150, 10)
			for i=1, 50 do
				surface.DrawRect(0, i * i * i * math.random(10, 50), ScrW(), ScrH() / 10 + math.random(10, 50))
			end
			draw.SimpleText("LIVE STREAMING", "alydusBaseSystems.CameraHUDRecording", 125, 115, Color(150, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
			if ply:GetNWBool("alydusBaseSystems.ViewingCameraNightvision", false) == true then
				draw.SimpleText("NIGHT VISION", "alydusBaseSystems.CameraTargetTitle", 128, 190, Color(150, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
			end
			surface.SetDrawColor(150, 150, 150, 150)
			surface.DrawLine(100, 100, ScrW() - 100, 100)
			surface.DrawLine(ScrW() - 100, ScrH() - 100, 100, ScrH() - 100)
			surface.DrawLine(100, ScrH() - 100, 100, 100)
			surface.DrawLine(ScrW() - 100, ScrH() - 100, ScrW() - 100, 100)
			surface.DrawLine(ScrW() - 100, ScrH() / 2, ScrW(), ScrH() / 2)
			surface.DrawLine(100, ScrH() / 2, 0, ScrH() / 2)
			local trace = ply:GetEyeTrace()
			local targetEntities = ents.FindInSphere(ply:GetPos(), 2500)
			if GetConVar("sv_alydusbasesystems_config_camera_identifyentities"):GetInt() == 1 then
				for _, ent in pairs(targetEntities) do
					if IsValid(ent) and ent != ply and ent != ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", nil) and (ent:IsNPC() or (ent:IsPlayer() and ent:GetNWInt("SW_Health", nil) == nil) or (ent:IsVehicle() or ent.IsSWVehicle) or string.Left(ent:GetClass(), 25) == "alydusbasesystems_module_" or ent:GetClass() == "alydusbasesystems_basecontroller") then
						local entPos = ent:LocalToWorld(ent:OBBCenter())
						local screenData = entPos:ToScreen()
						local targetText = "NPC"						
						if ent:IsPlayer() then
							if IsValid(ent:GetVehicle()) then
								targetText = ent:Nick() .. " Driving"
							else
								targetText = ent:Nick()
							end
						elseif ent:IsVehicle() then
							targetText = "Vehicle"
						elseif ent.IsSWVehicle then
							targetText = "Vehicle (" .. ent:GetNWInt("Health", 0) .. " HP)"
						elseif string.Left(ent:GetClass(), 25) == "alydusbasesystems_module_" or ent:GetClass() == "alydusbasesystems_basecontroller" then
							targetText = ent.PrintName
						end
						draw.SimpleText(targetText, "alydusBaseSystems.CameraTargetTitle", screenData.x, screenData.y, Color(225, 225, 225), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
						surface.SetDrawColor(Color(150, 150, 150, fade * 255))
						surface.DrawOutlinedRect(screenData.x - (Vector(0, 0, 0):Distance(ent:OBBMins()) * 2 / 2), screenData.y - (Vector(0, 0, 0):Distance(ent:OBBMaxs()) / 2), Vector(0, 0, 0):Distance(ent:OBBMins()) * 2, Vector(0, 0, 0):Distance(ent:OBBMaxs()))
						surface.DrawLine(ScrW() / 2, ScrH() / 2, screenData.x, screenData.y)
					end
				end
			end
		else
			if currentCamera:GetNWInt("alydusBaseSystems.Health", 0) <= 0 then
				surface.SetDrawColor(150, 150, 150, 1)
				for i=1, 150 do
					surface.DrawRect(0, i * i * i * math.random(10, 50), ScrW(), ScrH() / 10 + math.random(10, 50))
				end
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial(brokenCameraMaterial)
				surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
				surface.SetDrawColor(150, 150, 150, 150)
				surface.DrawLine(100, 100, ScrW() - 100, 100)
				surface.DrawLine(ScrW() - 100, ScrH() - 100, 100, ScrH() - 100)
				surface.DrawLine(100, ScrH() - 100, 100, 100)
				surface.DrawLine(ScrW() - 100, ScrH() - 100, ScrW() - 100, 100)
				surface.DrawLine(ScrW() - 100, ScrH() / 2, ScrW(), ScrH() / 2)
				surface.DrawLine(100, ScrH() / 2, 0, ScrH() / 2)
				draw.SimpleText("STREAM OFFLINE", "alydusBaseSystems.CameraHUDRecording", 125, 115, Color(150, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
				draw.SimpleText("SOURCE UNAVAILABLE", "alydusBaseSystems.CameraTargetTitle", 128, 190, Color(150, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
			else
				surface.SetDrawColor(150, 150, 150, 150)
				for i=1, 150 do
					surface.DrawRect(0, i * i * i * math.random(10, 50), ScrW(), ScrH() / 10 + math.random(10, 50))
				end
				if math.random(1, 5) == 2 then
					surface.SetDrawColor(150, 150, 150, 150)
					surface.DrawLine(100, 100, ScrW() - 100, 100)
					surface.DrawLine(ScrW() - 100, ScrH() - 100, 100, ScrH() - 100)
					surface.DrawLine(100, ScrH() - 100, 100, 100)
					surface.DrawLine(ScrW() - 100, ScrH() - 100, ScrW() - 100, 100)
					surface.DrawLine(ScrW() - 100, ScrH() / 2, ScrW(), ScrH() / 2)
					surface.DrawLine(100, ScrH() / 2, 0, ScrH() / 2)
				end
				draw.SimpleText("CAMERA TOO FAR", "alydusBaseSystems.CameraHUDRecording", ScrW() / 2, ScrH() / 2, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText("REDUCE DISTANCE FROM BASE CONTROLLER", "alydusBaseSystems.CameraTargetTitle", ScrW() / 2, ScrH() / 2 + 50, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText("STREAM OFFLINE", "alydusBaseSystems.CameraHUDRecording", 125, 115, Color(150, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
				draw.SimpleText("SOURCE UNAVAILABLE", "alydusBaseSystems.CameraTargetTitle", 128, 190, Color(150, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
			end
		end
	end
end)