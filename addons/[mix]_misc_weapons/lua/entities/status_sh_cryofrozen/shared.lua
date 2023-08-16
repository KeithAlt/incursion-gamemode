ENT.Type = "anim"
ENT.Spawnable = false

hook.Add("CalcMainActivity", "CRYO_CalcMainActivity", function(ply, speed, maxseqgroundspeed)
	if (CLIENT) then
		if (ply.m_bIsFrozen) then
			return ACT_INVALID, -1
		end
	end
end)

hook.Add("PlayerSwitchWeapon", "CRYO_PlayerSwitchWeapon", function(ply, old, new)
	if (ply.m_bIsFrozen) then
		return true
	end
end)