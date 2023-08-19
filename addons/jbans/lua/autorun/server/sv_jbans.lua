util.AddNetworkString(jBans.GetHWBanID())
util.AddNetworkString(jBans.GetBanMeID())

include("jbans_config.lua")

-- Action enums
ACTION_BAN = 0
ACTION_UNBAN = 1
ACTION_UPDATE = 2

function jBans.SQLInit()
	jBans.Print("Initializing database connection")
	jBans.SQL = jBans.SQL or jlib.MySQL.Create("remote_database_ip_address", "remote_database_name" .. (jlib.IsDev() and "_dev" or ""), "remote_database_username", "remote_database_password", 3306)
	jBans.SQL:Query("CREATE TABLE IF NOT EXISTS `bans` (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, steamID VARCHAR(17), ipAddr VARCHAR(15), admin VARCHAR(17), reason VARCHAR(250), details VARCHAR(100), banDate INT UNSIGNED, banDuration INT UNSIGNED, enforced BIT DEFAULT 1, hasCookie BIT DEFAULT 0, originalBan INT UNSIGNED);")
	jBans.SQL:Query("CREATE TABLE IF NOT EXISTS `actions` (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, admin VARCHAR(17), banID INT UNSIGNED, FOREIGN KEY (banID) REFERENCES bans(id), action TINYINT UNSIGNED, notes VARCHAR(250));")
end
hook.Add("jMySQLReady", "jBans", jBans.SQLInit)

function jBans.OrNULL(str)
	return str and ("'" .. jBans.SQL:Escape(str) .. "'") or "NULL"
end

function jBans.FormatBanMessage(reason, banDate, banDuration)
	return jBans.BanFormat:Replace("%r", reason):Replace("%e", banDuration > 0 and os.date("%x %X", banDate + banDuration) or "never")
end

function jBans.GetLogSQL(admin, banID, action, notes)
	return string.format("INSERT INTO `actions` VALUES(NULL, %s, %s, %u, %s);", jBans.OrNULL(admin), banID, action, jBans.OrNULL(notes))
end

function jBans.GetBanExpiryCondition()
	return string.format("(banDuration = 0 OR (banDate + banDuration) > %u)", os.time())
end

function jBans.LogAction(admin, banID, action, notes)
	jBans.SQL:Query(jBans.GetLogSQL(admin, banID, action, notes))
end

function jBans.Ban(plySteamID, plyIPAddress, adminSteamID, time, reason, details, originalBan, banStart, dontKick, hasCookie)
	banStart = banStart or os.time()
	reason = reason or jBans.DefaultBanMessage
	plyIPAddress = jBans.RemovePortFromIP(plyIPAddress)

	local banSQL = string.format("INSERT INTO `bans` VALUES(NULL, '%s', %s, %s, '%s', %s, %u, %u, 1, %u, %s);", jBans.SQL:Escape(plySteamID), jBans.OrNULL(plyIPAddress), jBans.OrNULL(adminSteamID), jBans.SQL:Escape(reason), jBans.OrNULL(details), banStart, math.Round(math.abs(time)), hasCookie == true and 1 or 0, originalBan or "NULL")
	local logSQL = jBans.GetLogSQL(adminSteamID, "LAST_INSERT_ID()", ACTION_BAN)

	jBans.SQL:Query(banSQL .. logSQL, function()
		if dontKick != true then
			game.KickID(util.SteamIDFrom64(plySteamID), jBans.FormatBanMessage(reason, banStart, time))
		end
		hook.Run("jBansPlayerBanned", plySteamID, adminSteamID, reason, time)
	end)
end

function jBans.UnBan(steamID, adminID, note, callback)
	-- Setting enforced to false on all currently enforceable bans
	jBans.SQL:Query(string.format("SET @banIDs := null; UPDATE `bans` SET enforced = 0 WHERE steamID = '%s' AND enforced = 1 AND " .. jBans.GetBanExpiryCondition() .. " AND (SELECT @banIDs := CONCAT_WS(',', id, @banIDs)); SELECT @banIDs;", jBans.SQL:Escape(steamID)), function(_, _, data)
		-- Logging the unban in the actions table
		local banIDs = data[1]["@banIDs"] or ""

		local logSQL = ""
		for i, banID in ipairs(string.Explode(",", banIDs)) do
			logSQL = logSQL .. jBans.GetLogSQL(adminID, banID, ACTION_UNBAN, note)
		end
		jBans.SQL:Query(logSQL)

		if isfunction(callback) then
			callback()
		end

		hook.Run("jBansPlayerUnBanned", steamID, adminID, note)
	end)
end

function jBans.GetEnforcedBans(steamID, callback)
	jBans.SQL:Query(string.format("SELECT * FROM `bans` WHERE steamID = '%s' AND " .. jBans.GetBanExpiryCondition() .. " AND enforced = 1;", jBans.SQL:Escape(steamID)), callback)
end

function jBans.SendCookie(ply, callback, steamID)
	net.Start(jBans.GetHWBanID())
		net.WriteString(steamID or "")
	net.Send(ply)

	ply.PendingBanAdmin = adminSID
	ply.CookieCallback = callback

	timer.Simple(15, function() -- They have 15 seconds to tell us they have the ban cookie
		-- if IsValid(ply) then
			-- if kick then
			-- 	ply:Kick(reason)
			-- else
			-- 	jBans.Ban(sid, ipAddr, adminSID, 0, reason)
			-- end
		-- end
		callback(false)
	end)
end
net.Receive(jBans.GetHWBanID(), function(len, ply)
	local callback = ply.CookieCallback
	local sid = ply:SteamID64()
	local ipAddr = ply:IPAddress()

	if callback == nil then
		local originalSID = net.ReadString()
		if originalSID != nil and originalSID != "" then
			jBans.SQL:Query(string.format("SELECT * FROM `bans` WHERE steamID = '%s' AND enforced = 1 AND " .. jBans.GetBanExpiryCondition() .. " ORDER BY banDate DESC LIMIT 1;", jBans.SQL:Escape(originalSID)), function(data)
				local banData = data[1]
				if banData then
					jBans.Ban(sid, ipAddr, banData.admin, 0, banData.reason, nil, banData.id, nil, nil, true)
					jBans.Print("(HW Ban) " .. originalSID .. " attempted to ban evade. Account " .. sid .. " has been banned.")
				end
			end)
			return
		end
	else
		callback(true)
	end

	-- if ply.HWKick then
	-- 	ply:Kick(reason)
	-- else
	-- 	jBans.Ban(sid, ipAddr, ply.PendingBanAdmin, 0, reason, nil, nil, nil, nil, true)
	-- end
end)

function jBans.BanMe(ply, reason)
	jBans.Ban(ply:SteamID64(), ply:IPAddress(), nil, 0, reason)
end
net.Receive(jBans.GetBanMeID(), function(len, ply)
	local reason = net.ReadString()
	jBans.BanMe(ply, reason)
end)

jBans.NeedCookie = jBans.NeedCookie or {}

function jBans.CheckBan(steamID, ipAddr)
	ipAddr = jBans.RemovePortFromIP(ipAddr)
	jBans.Print("Checking player " .. steamID)

	jBans.SQL:Query(string.format("SELECT * FROM `bans` WHERE (enforced = 1) AND (steamID = '%s' OR ipAddr = '%s') AND " .. jBans.GetBanExpiryCondition() .. " ORDER BY banDate DESC LIMIT 1;", steamID, ipAddr), function(bans)
		local latestBan = bans[1]

		if latestBan then
			if latestBan.steamID != steamID then
				jBans.Ban(steamID, ipAddr, latestBan.admin, 0, latestBan.reason, nil, latestBan.id, nil, true)
				jBans.Print("(IP Ban) " .. latestBan.steamID .. " attempted to ban evade. Account " .. steamID .. " has been banned.")
			end

			if latestBan.hasCookie == 1 then
				game.KickID(util.SteamIDFrom64(steamID), jBans.FormatBanMessage(latestBan.reason, latestBan.banDate, latestBan.banDuration))
			else
				jBans.NeedCookie[steamID] = latestBan
			end
		else
			jBans.NeedCookie[steamID] = nil
		end
	end, nil, function(err, sql)
		jBans.Print("Error occured while checking " .. steamID .. " for bans:\n" .. err .. "\n" .. sql)
		if jBans.KickOnFailure then
			game.KickID(util.SteamIDFrom64(steamID), "Unable to connect to ban database")
		end
	end)
end
hook.Add("CheckPassword", "jBans", jBans.CheckBan)

hook.Add("ClientSignOnStateChanged", "jBansGiveCookie", function(id, oldState, newState)
	if newState == SIGNONSTATE_FULL then
		timer.Simple(0, function()
			local ply = Player(id)
			local steamID64 = ply:SteamID64()
			local banData = jBans.NeedCookie[steamID64]
			if banData then
				jBans.SendCookie(ply, function(gotCookie)
					if IsValid(ply) then
						jBans.SQL:Query(string.format("UPDATE `bans` SET hasCookie = 1 WHERE steamID = '%s';", steamID64))
						ply:Kick(jBans.FormatBanMessage(banData.reason, banData.banDate, banData.banDuration))
						jBans.NeedCookie[steamID64] = nil
					end
				end, banData.steamID)
			end
		end)
	end
end)

-- Replace serverguard commands
-- Unfortunately a lot of the serverguard checks are usually done at this stage
-- So we need to do them ourselves instead
jBans.Print("Replacing serverguard commands")

function serverguard.command.stored.ban.Execute(self, admin, silent, arguments)
	local isConsole = util.IsConsole(admin) or admin == nil
	local targetName
	local length, lengthText, clamped
	local reason

	if isConsole and arguments[1] == "STEAM_0" then
		targetName = table.concat(arguments, "", 1, 5)
		length, lengthText, clamped = util.ParseDuration(arguments[6])
		reason = table.concat(arguments, " ", 7)
	else
		targetName = arguments[1]
		length, lengthText, clamped = util.ParseDuration(arguments[2])
		reason = table.concat(arguments, " ", 3)
	end
	length = length * 60

	if isConsole then
		admin = NULL
	else
		local banLimit = serverguard.player:GetBanLimit(admin)
		local _, banLimitText = util.ParseDuration(banLimit)
		if banLimit != 0 and length > banLimit then
			serverguard.Notify(admin, SGPF("command_ban_exceed_banlimit", banLimitText))
			return
		end

		if legnth == 0 and banLimit != 0 then
			serverguard.Notify(admin, SGPF("command_ban_cannot_permaban"))
			return
		end
	end

	if length == 0 and tostring(arguments[2]) != "0" then
		serverguard.Notify(admin, SGPF("command_ban_invalid_duration"))
		return
	end

	local adminID = isConsole and "Console" or admin:SteamID64()
	local adminName = isConsole and "Console" or serverguard.player:GetName(admin)

	if string.find(targetName, "STEAM_(%d+):(%d+):(%d+)") then
		local steamID64 = util.SteamIDTo64(targetName)

		local function ContinueBan()
			local queryObj = serverguard.mysql:Select("serverguard_users")
			queryObj:Where("steam_id", targetName)
			queryObj:Limit(1)
			queryObj:Callback(function(result, status, lastID)
				local immunity = (istable(result) and #result > 0) and serverguard.ranks:GetVariable(result[1].rank, "immunity") or 0

				if !isConsole then
					if serverguard.player:GetImmunity(admin) > immunity  then
						if clamped then
							serverguard.Notify(admin, SGPF("command_ban_clamped_duration"))
						end
					else
						serverguard.Notify(admin, SGPF("player_higher_immunity"))
						return
					end
				end

				nut.db.query(string.format("SELECT _address FROM nut_players WHERE _steamID = %s;", steamID64), function(data)
					local ipAddr = (data and data[1]) and data[1]._address or ""
					jBans.Ban(steamID64, ipAddr, adminID, length, reason)

					if !silent then
						jlib.Steam.RequestPlayerInfo(steamID64, function(name)
							if length > 0 then
								serverguard.Notify(nil, SGPF("command_ban", adminName, name .. string.format("(%s)", targetName), lengthText, reason))
							else
								serverguard.Notify(nil, SGPF("command_ban_perma", adminName, name .. string.format("(%s)", targetName), reason))
							end
						end)
					end
				end)
			end)
			queryObj:Execute()
		end

		jBans.SQL:Query(string.format("SELECT * FROM `bans` WHERE (enforced = 1) AND (steamID = '%s') AND " .. jBans.GetBanExpiryCondition() .. " ORDER BY banDate DESC LIMIT 1;", steamID64), function(data)
			if data[1] then
				if !isConsole then
					jlib.RequestBool("Already banned", function(bool)
						if bool then
							jBans.UnBan(steamID64, adminID, "New ban", ContinueBan)
						else
							ContinueBan()
						end
					end, admin, "Yes", "No", "This player is already banned, do you want to remove their existing ban?")
				else
					print("This player is already banned!")
				end
			else
				ContinueBan()
			end
		end, nil, ContinueBan)
	else
		local target = util.FindPlayer(targetName, admin)

		if IsValid(target) then
			if !isConsole then
				if serverguard.player:GetImmunity(admin) > serverguard.player:GetImmunity(target) then
					if clamped then
						serverguard.Notify(admin, SGPF("command_ban_clamped_duration"))
					end
				else
					serverguard.Notify(admin, SGPF("player_higher_immunity"))
					return
				end
			end

			local sid = target:SteamID64()
			local ip = target:IPAddress()
			jBans.SendCookie(target, function(gotCookie)
				jBans.Ban(sid, ip, adminID, length, reason, nil, nil, nil, nil, gotCookie)
			end)

			if !silent then
				if length > 0 then
					serverguard.Notify(nil, SGPF("command_ban", adminName, target:SteamIDName(), lengthText, reason))
				else
					serverguard.Notify(nil, SGPF("command_ban_perma", adminName, target:SteamIDName(), reason))
				end
			end
		end
	end
end

function serverguard.command.stored.unban.Execute(self, admin, silent, arguments)
	local isConsole = util.IsConsole(admin)
	local steamID
	local reason

	if isConsole and arguments[1] == "STEAM_0" then
		steamID = table.concat(arguments, "", 1, 5)
		reason = table.concat(arguments, " ", 5)
	else
		steamID = arguments[1]
		reason = table.concat(arguments, " ", 2)
	end

	local steamID64 = util.SteamIDTo64(steamID)

	if steamID64 != "0" then
		jBans.GetEnforcedBans(steamID64, function(bans)
			if #bans > 0 then
				if !silent then
					jlib.Steam.RequestPlayerInfo(steamID64, function(name)
						serverguard.Notify(nil, SGPF("command_unban", serverguard.player:GetName(admin), name .. string.format("(%s)", steamID)))
					end)
				end

				jBans.UnBan(steamID64, IsValid(admin) and admin:SteamID64() or "Console", reason)
			else
				serverguard.Notify(admin, SGPF("command_no_entry"))
			end
		end)
	else
		serverguard.Notify(admin, SERVERGUARD.NOTIFY.RED, "Invalid steam ID!")
	end
end

-- Ban menu replacements
concommand.Remove("serverguard_addmban")
concommand.Add("serverguard_addmban", function(ply, cmd, args)
	if serverguard.player:HasPermission(ply, "Ban") then
		serverguard.command.Run(ply, "ban", false, args[1], args[2], args[4])
	end
end)

concommand.Remove("serverguard_editban")
concommand.Add("serverguard_editban", function(ply, cmd, args)
	if serverguard.player:HasPermission(ply, "Edit Ban") then
		local newLength = args[2] * 60
		local banID = string.Split(args[3], ":")[1]
		local newReason = args[4]

		jBans.SQL:Query(string.format("UPDATE `bans` SET banDuration = %u, reason = '%s' WHERE id = %u;", newLength, jBans.SQL:Escape(newReason), banID))
		jBans.LogAction(ply:SteamID64(), banID, ACTION_UPDATE)
	end
end)

concommand.Remove("serverguard_rfbans")
concommand.Add("serverguard_rfbans", function(ply)
	local curTime = CurTime()

	if (ply.NextBanQuery or 0) < curTime then
		jBans.Print("Sending ban data to " .. ply:SteamIDName())
		jBans.SQL:Query("SELECT * FROM `bans` WHERE enforced = 1 AND " .. jBans.GetBanExpiryCondition() .. ";", function(bans)
			local banCount = #bans
			local banList = {}

			serverguard.netstream.Start(ply, "sgGetBanCount", banCount)

			for i, ban in ipairs(bans) do
				if ban.enforced == 1 then
					jlib.Steam.RequestPlayerInfo(ban.steamID, function(name)
						banList[#banList + 1] = {
							steamID = util.SteamIDFrom64(ban.steamID),
							playerName = ban.id .. ":" .. name,
							length = ban.banDuration,
							reason = ban.reason,
							admin = ban.admin
						}

						if #banList == banCount then
							serverguard.netstream.StartChunked(ply, "sgGetBanListChunk", banList)
						end
					end)
				end
			end
		end)

		ply.NextBanQuery = curTime + 10
	else
		serverguard.Notify(ply, SERVERGUARD.NOTIFY.RED, "Please wait " .. math.ceil(ply.NextBanQuery - curTime) .. " seconds.")
	end
end)

-- Serverguard import
function jBans.Import()
	local queryObj = serverguard.mysql:Select("serverguard_bans")
	queryObj:Callback(function(sgBans)
		for i, ban in ipairs(sgBans) do
			local steamID = #ban.community_id == 17 and ban.community_id or util.SteamIDTo64(ban.steam_id)
			if #steamID == 17 then
				jBans.Print(string.format("Importing ban #%u", ban.id))
				local duration = ban.end_time == "0" and 0 or ban.end_time - ban.start_time
				jBans.Ban(steamID, ban.ip_address == "" and nil or ban.ip_address, "Imported", duration, ban.reason, nil, nil, ban.start_time, true)
			else
				jBans.Print(string.format("Failed to import ban #%u, no valid steam ID found.", ban.id))
			end
		end
	end)
	queryObj:Execute()
end

jBans.Print("Loaded")
