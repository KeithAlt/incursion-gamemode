hook.Add("PlayerGiveSWEP", "SWEPRestrict", function(ply, class, swep)
	return ply:IsSuperAdmin()
end)
