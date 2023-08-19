function OnSlaveOwnerDeath(ply)
	if ply.Slaves then
		for k, v in pairs(ply.Slaves) do
			v.slavecollar:Remove()
		end
		table.Empty( ply.Slaves )
	end
end
hook.Add("DoPlayerDeath","OnSlaveOwnerDeath",OnSlaveOwnerDeath)hook.Add("PlayerSpawn","Initialize Slave Table",function(ply)	timer.Simple(1,function()		if ply and ply:IsValid() then			if ply.Slaves == nil then				ply.Slaves = {}			end		end	end)end)