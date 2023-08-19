APK = APK or {}
APK.Config = APK.Config or {}

include("apkconfig.lua")

function APK.EnabledFor(ply)
	return false
end

function APK.Pickup(parent)
	for _, ent in pairs(constraint.GetAllConstrainedEntities(parent)) do
		if !IsValid(ent) then continue end

		timer.Remove("APKDrop" .. ent:EntIndex())
		APK.EndAlphaTo(ent)

		if ent.APKPickedUp or ent:IsPlayer() or ent:IsVehicle() or ent:IsNPC() then continue end

		local class = ent:GetClass()

		ent.APKPickedUp = true
		ent.APKOldCG  = ent:GetCollisionGroup()
		ent.APKOldRM  = ent:GetRenderMode()
		ent.APKOldCol = ent:GetColor()

		ent:SetCollisionGroup(APK.Config.CollisionClasses[class] or APK.Config.CollisionGroup)
		ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
		ent:SetColor(Color(0, 0, 0, 100))
	end
end

function APK.Drop(parent)
	for _, ent in pairs(constraint.GetAllConstrainedEntities(parent)) do
		if !IsValid(ent) or !ent.APKPickedUp then continue end

		ent.APKPickedUp = false
		ent:SetCollisionGroup(ent.APKOldCG)
		ent:SetRenderMode(ent.APKOldRM)
		ent:SetColor(ent.APKOldCol)
		ent.APKOldCol = nil
	end
end

function APK.AlphaTo(ent, alpha, time)
	local startAlpha = ent:GetColor().a
	local startTime = CurTime()
	local endTime = startTime + time
	local hookID = "APKAlphaTo" .. ent:EntIndex()

	hook.Add("Think", hookID, function()
		if !IsValid(ent) then
			hook.Remove("Think", hookID)
			return
		end

		local fraction = math.Clamp(math.TimeFraction(startTime, endTime, CurTime()), 0, 1)
		ent:SetColor(ColorAlpha(ent:GetColor(), Lerp(fraction, startAlpha, alpha)))

		if fraction == 1 then
			hook.Remove("Think", hookID)
		end
	end)
end

function APK.EndAlphaTo(ent)
	hook.Remove("Think", "APKAlphaTo" .. ent:EntIndex())
	if ent.APKPickedUp then
		ent:SetColor(Color(0, 0, 0, 100))
	end
end

hook.Add("OnPhysgunPickup", "AntiPropKill", function(ply, ent)
	if APK.EnabledFor(ply) then
		APK.Pickup(ent)
	end
end)

hook.Add("PhysgunDrop", "AntiPropKill", function(ply, ent)
	if APK.EnabledFor(ply) then
		if ent.FrozenThisTick then return end

		local physObj = ent:GetPhysicsObject()
		if IsValid(physObj) then
			physObj:EnableMotion(false)
		end

		for _, ent2 in pairs(constraint.GetAllConstrainedEntities(ent)) do
			APK.AlphaTo(ent2, 255, APK.Config.Timer)
		end
		timer.Create("APKDrop" .. ent:EntIndex(), APK.Config.Timer, 1, function()
			if IsValid(ent) then
				APK.Drop(ent)
				ent:EmitSound("physics/cardboard/cardboard_box_impact_soft3.wav")
				if IsValid(physObj) then
					physObj:EnableMotion(true)
					physObj:Wake()
				end
			end
		end)
	end
end)

hook.Add("OnPhysgunFreeze", "AntiPropKill", function(wep, physObj, ent, ply)
	if APK.EnabledFor(ply) then
		ent.FrozenThisTick = true

		APK.Drop(ent)

		timer.Simple(0, function()
			if IsValid(ent) then
				ent.FrozenThisTick = false
			end
		end)
	end
end)
