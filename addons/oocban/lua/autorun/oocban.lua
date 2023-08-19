local bannedIDs = {}

local function SaveOOCBans()
	file.Write("oocbans.json", util.TableToJSON(bannedIDs))
end

local function LoadOOCBans()
	local json = file.Read("oocbans.json")

	if json then
		bannedIDs = util.JSONToTable(json)
	end
end

local function UnOOCBan(ply)
	ply.OOCBanned = nil
	ply.UnOOCBanTime = nil

	bannedIDs[ply:SteamID()] = nil
	SaveOOCBans()
end

local function OOCBan(ply, time)
	ply.OOCBanned = true
	ply.UnOOCBanTime = time

	bannedIDs[ply:SteamID()] = time
	SaveOOCBans()
end

if SERVER then
	timer.Create("OOCBan", 1, 0, function()
		for _, ply in pairs(player.GetAll()) do
			if ply.OOCBanned and ply.UnOOCBanTime > 0 and os.time() >= ply.UnOOCBanTime then
				UnOOCBan(ply)
			end
		end
	end)
end


local function SetupCommand()
	local command = {}

	command.help		  = "Bans a player from using OOC."
	command.command 	  = "oocban"
	command.arguments	  = {"player", "length"}
	command.permissions	  = {"OOCBan"}
	command.immunity 	  = SERVERGUARD.IMMUNITY.LESSOREQUAL
	command.bSingleTarget = true

	function command:OnPlayerExecute(caller, target, arguments)
		local time = tonumber(arguments[2]) or 30

		OOCBan(target, time > 0 and os.time() + time or 0)

		return true
	end

	function command:OnNotify(caller, targets, args)
		local time = tonumber(args[2])
		return SERVERGUARD.NOTIFY.GREEN, serverguard.player:GetName(caller), SERVERGUARD.NOTIFY.WHITE, " has banned ", SERVERGUARD.NOTIFY.RED, targets[1]:Nick(), SERVERGUARD.NOTIFY.WHITE, " from speaking in OOC ", time <= 0 and "indefinitely" or ("for " .. string.NiceTime(time)), "."
	end

	serverguard.command:Add(command)

	command = {}

	command.help		  = "Unbans a player from using OOC."
	command.command 	  = "unoocban"
	command.arguments	  = {"player"}
	command.permissions	  = {"OOCBan"}
	command.immunity 	  = SERVERGUARD.IMMUNITY.LESSOREQUAL
	command.bSingleTarget = true

	function command:OnPlayerExecute(caller, target, arguments)
		UnOOCBan(target)
		return true
	end

	function command:OnNotify(caller, targets, args)
		return SERVERGUARD.NOTIFY.GREEN, serverguard.player:GetName(caller), SERVERGUARD.NOTIFY.WHITE, " has unbanned ", SERVERGUARD.NOTIFY.RED, targets[1]:Nick(), SERVERGUARD.NOTIFY.WHITE, " from speaking in OOC."
	end

	serverguard.command:Add(command)

	timer.Simple(0, function()
		serverguard.permission:Add("OOCBan")
	end)

	if SERVER then
		LoadOOCBans()
	end
end
hook.Add("PostGamemodeLoaded", "OOCBan", SetupCommand)
if serverguard then
	SetupCommand()
end

hook.Add("InitializedConfig", "OOCBan", function()
	timer.Simple(0, function()
		nut.chat.classes.ooc.onCanSayOld = nut.chat.classes.ooc.onCanSayOld or nut.chat.classes.ooc.onCanSay

		function nut.chat.classes.ooc.onCanSay(speaker, text)
			if speaker.OOCBanned then
				if speaker.UnOOCBanTime <= 0 then
					speaker:ChatPrint("You are indefinitely banned from using OOC.")
				else
					speaker:ChatPrint("You are banned from using OOC for another " .. string.NiceTime(speaker.UnOOCBanTime - os.time()))
				end

				return false
			end

			return nut.chat.classes.ooc.onCanSayOld(speaker, text)
		end
	end)
end)

hook.Add("PlayerInitialSpawn", "OOCBan", function(ply)
	if bannedIDs[ply:SteamID()] then
		OOCBan(ply, bannedIDs[ply:SteamID()])
	end
end)
