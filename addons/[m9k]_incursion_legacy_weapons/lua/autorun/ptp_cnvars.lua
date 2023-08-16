if GetConVar("sv_ptp_dashing_disable") == nil then
	CreateConVar("sv_ptp_dashing_disable", "0", { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE })
end

if CLIENT then
	if GetConVar("cl_ptp_hl2crosshair_enable") == nil then
		CreateClientConVar("cl_ptp_hl2crosshair_enable", "0", false, true)
	end
	
	if GetConVar("cl_ptp_crosshair_disable") == nil then
		CreateClientConVar("cl_ptp_crosshair_disable", "0", false, true)
		print("If you can see this, then you are a faggot JohnsonLiveTV")
	end
	
	--if GetConVar("cl_ptp_viewmodel_lefty") == nil then
		--CreateClientConVar("cl_ptp_viewmodel_lefty", "0", true, true)
		--print("If you can see this you are a faggot")
	--end
end