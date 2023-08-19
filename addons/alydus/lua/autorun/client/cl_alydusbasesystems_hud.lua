--[[ 
	© Alydus.net
	Do not reupload lua to workshop without permission of the author
	Alydus Base Systems
	Alydus: (officialalydus@gmail.com | STEAM_0:1:57622640)
--]]
local doorList = {}
doorList["func_door"] = true
doorList["func_door_rotating"] = true
doorList["prop_door"] = true
doorList["prop_door_rotating"] = true
local function firingTargetString(target)
	if isstring(target) then return target end
	if not IsValid(target) then return "None" end	
	if target:IsNPC() then
		return "NPC w/ " .. math.Round(target:Health()) .. " HP"
	elseif target:IsPlayer() then
		return target:Nick()
	elseif target:IsVehicle() then
		return target:GetClass() or "Vehicle"
	else
		return "Vehicle"
	end
end
local function alarmStatusString(input)
	if input == true then
		return "Enabled"
	else
		return "Disabled"
	end
end
net.Receive("alydusBaseSystems.sendMessage", function(len)
	local text = net.ReadString()
	local ply = LocalPlayer()
	if IsValid(ply) and ply:IsPlayer() and ply:Alive() then
		chat.AddText(Color(211, 84, 0), "[Alydus Base Systems] ", Color(200, 200, 200), text)
	end
end)
hook.Add("HUDPaint", "alydusBaseSystems.HUDPaint.DrawHUD", function()
	local ply = LocalPlayer()
	if IsValid(ply) and ply:Alive() and ply:GetNWEntity("alydusBaseSystems.ViewingCameraEntity", false) == false then
		local tr = ply:GetEyeTrace()
		if tr and IsValid(tr.Entity) and tr.Entity:GetPos():DistToSqr(ply:GetPos()) <= 122500 then
			local ent = tr.Entity
			if(!ent.alydus) then return end
			--if(ent.Author != "Alydus") then return end
			
			if string.Left(ent:GetClass(), 25) == "alydusbasesystems_module_" then
				local ownerString = "None"
				local healthString = "Destroyed"
				local turretInfo = ""
				local doorServoInfo = ""
				local alarmInfo = ""
				if string.match(string.lower(ent:GetClass()), "turret") != nil then
					if math.Round(ent:GetNWInt("alydusBaseSystems.Ammo", 0)) <= 0 then
						turretInfo = " - Ammo: Depleted - Target: " .. firingTargetString(ent:GetNWEntity("alydusBaseSystems.FiringTarget", "None"))
					else
						turretInfo = " - Ammo: " .. math.Round(ent:GetNWInt("alydusBaseSystems.Ammo", 0)) .. "/350" .. " - Target: " .. firingTargetString(ent:GetNWEntity("alydusBaseSystems.FiringTarget", "None"))
					end
				end
				if ent:GetClass() == "alydusbasesystems_module_alarm" then
					alarmInfo = " - Alarm: " .. alarmStatusString(ent:GetNWBool("alydusBaseSystems.Alarm", false))
				end
				if ent:GetClass() == "alydusbasesystems_module_doorservo" then
					local doorsConnectedCount = 0
					for _, door in pairs(ents.FindInSphere(ent:GetPos(), 75)) do
						if IsValid(door) and doorList[door:GetClass()] then
							doorsConnectedCount = doorsConnectedCount + 1
						end
					end
					doorServoInfo = " - Doors Connected: " .. doorsConnectedCount
				end
				if ent:GetNWInt("alydusBaseSystems.Health", 0) >= 1 then
					healthString = math.Round(ent:GetNWInt("alydusBaseSystems.Health")) .. " HP"
				end
				if IsValid(ent:GetNWEntity("alydusBaseSystems.Owner")) then
					ownerString = ent:GetNWEntity("alydusBaseSystems.Owner"):Nick()
				end
				draw.SimpleText(ent.PrintName .. " (" .. healthString .. turretInfo .. doorServoInfo .. alarmInfo .. ")", "alydusBaseSystems.HUDTitle", ScrW() / 2, ScrH() / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				if ownerString == "None" then
					draw.SimpleText("USE (E) to claim", "alydusBaseSystems.HUDTitle", ScrW() / 2, ScrH() / 2 + 30, Color(191, 191, 191), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				else
					draw.SimpleText("Owner: " .. ownerString, "alydusBaseSystems.HUDTitle", ScrW() / 2, ScrH() / 2 + 30, Color(191, 191, 191), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			elseif string.Left(ent:GetClass(), 29) == "alydusbasesystems_consumable_" then
				draw.SimpleText(ent.PrintName, "alydusBaseSystems.HUDTitle", ScrW() / 2, ScrH() / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText("Drag onto a gun turret to replenish ammo", "alydusBaseSystems.HUDTitle", ScrW() / 2, ScrH() / 2 + 25, Color(191, 191, 191), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			elseif doorList[ent:GetClass()] then
				local servoCount = 0				
				for _, doorServos in pairs(ents.FindInSphere(ent:GetPos(), 100)) do
					if IsValid(doorServos) and doorServos:GetClass() == "alydusbasesystems_module_doorservo" then
						servoCount = servoCount + 1
					end
				end
				if servoCount >= 1 then
					draw.SimpleText("Connected to: " .. servoCount .. " Door Servo(s)", "alydusBaseSystems.HUDTitle", ScrW() / 2, ScrH() / 2, Color(191, 191, 191), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end
		end
	end
end)
hook.Add("PostDrawTranslucentRenderables", "alydusBaseSystems.PostDrawTranslucentRenderables.DrawSystemView", function()
	local ply = LocalPlayer()
	if (		IsValid(ply) and 		ply:Alive() and 		ply:GetNWBool("alydusBaseSystems.SystemView", false) == true 	)	then
		local fade = math.abs(math.sin(CurTime() * 3))
		local baseController = nil
		local baseControllerPos = nil
		for _, potentialBaseController in pairs(ents.FindByClass("alydusbasesystems_basecontroller")) do
			if IsValid(potentialBaseController) and potentialBaseController:GetClass() == "alydusbasesystems_basecontroller" and potentialBaseController:GetNWEntity("alydusBaseSystems.Owner", nil) == ply then
				baseController = potentialBaseController
				baseControllerPos = baseController:LocalToWorld(baseController:OBBCenter()) + (baseController:GetAngles():Up() * 25)
				break
			end
		end
		for _, moduleEntity in pairs(ents.FindByClass("alydusbasesystems_module_*")) do
			if IsValid(moduleEntity) and moduleEntity:GetNWEntity("alydusBaseSystems.Owner", nil) == ply and baseController != nil and baseControllerPos != nil then
				render.SetColorMaterialIgnoreZ()
				render.DrawLine(baseControllerPos, moduleEntity:LocalToWorld(moduleEntity:OBBCenter()), Color(150, 150, 150, 255 * fade))
				render.DrawSphere(moduleEntity:LocalToWorld(moduleEntity:OBBCenter()), 5, 50, 50, Color(150, 150, 150, 35 * fade))
				render.DrawSphere(baseControllerPos, 5, 50, 50, Color(150, 150, 150, 35 * fade))
				if moduleEntity:GetClass() == "alydusbasesystems_module_doorservo" then
					for _, door in pairs(ents.FindInSphere(moduleEntity:GetPos(), 75)) do
						if IsValid(door) and doorList[door:GetClass()] then
							render.DrawSphere(door:LocalToWorld(door:OBBCenter()), 5, 50, 50, Color(150, 150, 150, 35 * fade))
							render.DrawLine(door:LocalToWorld(door:OBBCenter()), moduleEntity:LocalToWorld(moduleEntity:OBBCenter()), Color(150, 150, 150, 255 * fade))
						end
					end
				end
			end
		end
	end
end)