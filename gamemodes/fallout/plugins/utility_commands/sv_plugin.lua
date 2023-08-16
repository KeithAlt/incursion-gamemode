// SERVER-SIDE COMMAND : REMEMBER TO ALSO INCLUDE CL_PLUGIN.LUA //
nut.command.add("scan", {
    superAdminOnly = true,
    onRun = function(client)
		local target = client:GetEyeTrace().Entity

		if !IsValid(target) or !target:IsPlayer() then
			client:ChatPrint("[SCAN] You are not looking at a valid player")
			return
		end

		local str = ""

		str = str .. "\n[SCAN REPORT]"
		str = str .. "\nName - " .. target:GetName()
		str = str .. "\nSteamID - " .. target:SteamID()
		str = str .. "\nSteamID64 - " .. target:SteamID64()

		Prometheus.DB.FetchPlayerBought(function(response)
			str = str .. "\n"
			if istable(response) then
				str = str .. "VIP Packages - "

				for _, package in pairs(response) do
					str = str .. "'" .. package.title .. "' "
				end
			else
				str = str .. "VIP Packages - None owned"
			end

			client:ChatPrint(str)
		end, target)

		nut.plugin.list.report:SendReport(target, client)
		DiscordEmbed(client:Nick() .. " ( " .. client:SteamID() .. " ) " .. "has performed a character scan on " .. target:Nick() .. " ( " .. target:SteamID() .. " )", "Character Scan Log", Color(255,0,0), "Admin")
    end
})
