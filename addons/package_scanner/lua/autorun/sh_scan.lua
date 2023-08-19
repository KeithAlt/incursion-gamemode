local packages = {
	["Incursion Bronze Membership"] = "bronze",
	["Incursion Silver Membership"] = "silver",
	["Incursion Gold Membership"] = "gold",
	["Incursion Diamond Membership"] = "diamond",
	["Incursion Legendary Membership"] = "legendary",
	["Incursion Silver Membership Upgrade"] = "silver",
	["Incursion Gold Membership Upgrade"] = "gold",
	["Incursion Diamond Membership Upgraade"] = "diamond",
	["Incursion Diamond Membership Upgrade"] = "diamond",
	["Incursion Legendary Membership Upgrade"] = "legendary",
}

hook.Add("InitPostEntity", "LoadPackageUtil", function()
	-- Initalize our package checker
	nut.command.add("package_check", {
		syntax = "<Look at player>",
		adminOnly = true,
		onRun = function(ply)
			if !ply:IsSuperAdmin() then
				ply:notify("Only B-Team+ can perform redemption scans")
				return
			end

			local target = ply:GetEyeTrace().Entity or false

			if IsValid(target) and target:IsPlayer() then
				Prometheus.DB.FetchPlayerBought(function(response)
					if istable(response) then
						jlib.Announce(ply, Color(0,255,0), "[PACKAGE HISTORY] ", Color(255,255,155), jlib.SteamIDName(target), Color(255,255,0), ":\n            Current Rank: ".. serverguard.player:GetRank(ply))
						local packageHistoryStr = ""

						for index, package in pairs(response) do
							packageHistoryStr = packageHistoryStr .. "\n 	|_ [" .. index .. "] " .. package.title
						end

						ply:ChatPrint(packageHistoryStr)
					end
				end, target)

				jlib.Announce(ply, Color(0,255,0), "[CHARACTER REPORT] ", Color(255,255,155), "Data Sheet:")

				net.Start("getCharacterData")
				net.Send(target)

				target.logReader = ply
			end
		end
	})

	-- Redeem a package
	nut.command.add("package_redeem", {
		syntax = "<Look at player>",
		adminOnly = true,
		onRun = function(ply, argument)
			if !ply:IsSuperAdmin() then
				ply:notify("Only B-Team+ can perform redmeptions")
				return
			end

			local target = ply:GetEyeTrace().Entity or false
			local arg = tonumber(argument[1]) or false

			if !arg or !isnumber(arg) or arg <= 0 then
				ply:notify("Please use a number argument for the package")
				jlib.Announce(ply, Color(255,255,0), "[HELP] ", Color(255,255,255), "Enter ", Color(255,255,155), "'/package_check'", Color(255,255,255), " while targeting a player to view the list of packages & their IDs")
				return
			end

			if IsValid(target) and target:IsPlayer() then
				Prometheus.DB.FetchPlayerBought(function(response)
					if istable(response) then
						for index, package in pairs(response) do
							if index == arg and packages[package.title] then
								jlib.RequestBool("Redeem players - " .. packages[package.title]:upper() .. "?", function(bool)
									if !bool then
										ply:notify("Cancelled redemption query")
										return
									end

									packageScanner.redeemRank(target, ply, packages[package.title]) -- Redeem our package
								end, ply)
								break
							end
						end
					end
				end, target)
			end
		end
	})
end)
