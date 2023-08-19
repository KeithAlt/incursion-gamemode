local function ResetBones(ply)
	if not ply:GetBoneCount() then return end

	for i = 0, ply:GetBoneCount() do
		ply:ManipulateBonePosition(i, Vector(0, 0, 0))
		ply:ManipulateBoneAngles(i, Angle(0, 0, 0))
	end
end

local manipulations = {
	["ValveBiped.Bip01_R_UpperArm"] = Angle(30, 0, 90),
	["ValveBiped.Bip01_L_UpperArm"] = Angle(-30, 0, -90),
	["ValveBiped.Bip01_R_ForeArm"] = Angle(0, -130, 0),
	["ValveBiped.Bip01_L_ForeArm"] = Angle(0, -120, 20)
}

local function Surrender(ply)
	local char = ply:getChar()

	if not char or ply:GetMoveType() == MOVETYPE_NOCLIP or (pk_pills and IsValid(pk_pills.getMappedEnt(ply))) or (ply:IsHandcuffed() or ply:getNetVar("restricted")) then
		return
	end

	ply.IsSurrendered = true

	ply:SetNWBool("StealthCamo", false)
	ply:SetNoDraw(false)
	ply:SetNoTarget(false)

	for k, v in pairs(manipulations) do
		local boneid = ply:LookupBone(k)

		if boneid then
			ply:ManipulateBoneAngles(boneid, v)
		end
	end

	ply.SurrenderWasSprintEnabled = ply:IsSprintEnabled()
	ply:SprintDisable()
	ply:falloutNotify("You are surrendering", "ui/notify.mp3")

	local activeWep = ply:GetActiveWeapon()
	if activeWep.Holster then
		activeWep:Holster()
	end

	ply:SetActiveWeapon(ply:GetWeapon("nut_keys"))

	hook.Add("PlayerSwitchWeapon", "jSurrender" .. ply:SteamID64(), function(p)
		if p == ply then
			return true
		end
	end)
end

local function UnSurrender(ply)
	ply.IsSurrendered = false

	ResetBones(ply)
	ply:SetSprintEnabled(ply.SurrenderWasSprintEnabled)
	ply.SurrenderWasSprintEnabled = nil
	ply:falloutNotify("You are no longer surrendering", "ui/notify.mp3")

	hook.Remove("PlayerSwitchWeapon", "jSurrender" .. ply:SteamID64())
end

concommand.Add("surrender", function(ply)
	if !ply.IsSurrendered then
		Surrender(ply)
	else
		UnSurrender(ply)
	end
end)
