arms_forced = "models/weapons/handsfb/c_arms_refugee.mdl"--specify here
--dont modify below
local cl_tfa_forcearms
hook.Add("PreDrawPlayerHands","TFAForceArms",function( hands, vm, ply, weapon )
	cl_tfa_forcearms = cl_tfa_forcearms or GetConVar("cl_tfa_forcearms")
	if weapon.Think2 and cl_tfa_forcearms:GetBool() then
		--if not hands.HasSetTFAForce then
			hands.OldHandsMDLTFA = hands:GetModel()
			hands:SetModel(arms_forced)
			hands:SetBodygroup(1,1)
			hands.HasSetTFAForce = true
		--end
	elseif hands.HasSetTFAForce then
		hands:SetModel(player_manager.TranslatePlayerHands(player_manager.TranslateToPlayerModelName(ply:GetModel()) or "").model or hands.OldHandsMDLTFA)
		hands.HasSetTFAForce = false
	end
end)