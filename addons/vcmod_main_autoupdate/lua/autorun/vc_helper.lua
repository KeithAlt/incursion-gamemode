// Copyright © 2020 VCMod (freemmaann). All Rights Reserved. if you have any complaints or ideas contact me: steam - steamcommunity.com/id/freemmaann/ or email - freemmaann@gmail.com.

// Adds a few quick helper functions for developers
// This is a seperate file to avoid potential load priority issues


// Does very rudimentary detour check and outputs some useful data. Does not check everything, only the basic methods. These quick methods themselves can be detoured!
function VC_getDetours_ManualCheck()
	local ret = {}

	// init the function
	local v_debug = debug.getinfo

	// debug.getinfo (a bit silly checking this, but why not?)
	local data = v_debug(v_debug) local source = "=[C]"
	if !data or !data.source or data.source != source then
		ret["debug.getinfo"] = {original = source, current = data.source}
	end

	// RunString
	local data = v_debug(RunString) local source = "=[C]"
	if !data or !data.source or data.source != source then
		ret["RunString"] = {original = source, current = data.source}
	end

	-- // file.Write
	-- local data = v_debug(file.Write) local source = "=[C]"
	-- if !data or !data.source or data.source != source then
	-- 	ret["file.Write"] = {original = source, current = data.source}
	-- end

	// HTTP Module
	local data = v_debug(HTTP) local source = "=[C]"
	if !data or !data.source or data.source != source then
		ret["HTTP Module"] = {original = source, current = data.source}
	end

	// http.Fetch Module
	local data = v_debug(http.Fetch) local source = "@lua/includes/modules/http.lua"
	if !data or !data.source or data.source != source then
		ret["http.Fetch"] = {original = source, current = data.source}
	end

	// HTTP Module
	local source = "@lua/includes/modules/http.lua"
	module("http", package.seeall)
	if Fetch then
		local data = v_debug(Fetch)
		if !data or !data.source or data.source != source then
			ret["HTTP Module Fetch"] = {original = source, current = data.source}
		end
	end

	return ret
end

concommand.Add("vc_detourCheck", function(ply)

	// Let's limit this to console command use only
	if IsValid(ply) and !ply:IsAdmin() then
		VCPrint("ERROR: this command is only accessible by administrators!")
		return
	end

	VCPrint_noPrefix("")
	VCPrint("Detour check started:")

	local detours = {}
	// Check if jit is installed or not, if not, most likely a 64bit branch
	if jit then
		detours = VC_getDetours_ManualCheck()
	else
		VCPrint("ERROR: jit is not installed!")
		return
	end

	// Checking the outputs
	if table.Count(detours) > 0 then
		VCPrint("WARNING! Found "..table.Count(detours).." detour(s)!")

		VCPrint_noPrefix("")
		for k,v in pairs(detours) do
			VCPrint(k..' is "'..v.current..'", should be "'..v.original..'"!')
		end
		VCPrint_noPrefix("")

		VCPrint("Remove the source of detours and restart the map!")
	else
		VCPrint("No detours found! If there still are issues, contact support.")
	end

	VCPrint_noPrefix("")
end)