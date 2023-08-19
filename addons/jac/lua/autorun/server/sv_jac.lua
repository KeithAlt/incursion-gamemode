JAC = JAC or {}
JAC.Config = JAC.Config or {}
include("jac_config.lua")

JAC.Print = jlib.GetPrintFunction("[JAC]", Color(255, 0, 255))

-- These should match with the violation codes in the client file
JAC.Reasons = {
	[1] = "Source mismatch on file: %s",
	[2] = "Bad console variable: %s",
	[3] = "Bad console variable manipulation: %s",
	[4] = "Bad font: %s",
	[5] = "Bad function: %s",
	[6] = "Bad module: %s",
	[7] = "Bad global variable: %s",
	[8] = "Bad detour: %s"
}

-- Reading and obfuscating the anti-cheat code
JAC.NetworkString = JAC.NetworkString or jlib.RandomString(16)
JAC.BanMe = JAC.BanMe or jlib.RandomString(16)

JAC.Code = file.Read("jac.lua", "LUA")

-- Inserting the BanMe network string
local newlinePos = string.find(JAC.Code, "\n")
JAC.Code = string.sub(JAC.Code, 1, newlinePos) .. string.format('JAC.BanMe = "%s"', JAC.BanMe) .. string.sub(JAC.Code, newlinePos)

JAC.ObfuscatedCode = jlib.Obfuscate(JAC.Code)
JAC.ByteCode = jlib.ToByteCode(JAC.ObfuscatedCode)

util.AddNetworkString(JAC.NetworkString)
util.AddNetworkString(JAC.BanMe)

-- Sending players the clientside anti-cheat code
function JAC.Send(ply)
	ply.SentJAC = CurTime()
	if ply:IsBot() then
		JAC.Validate(ply)
	else
		ply:SendLua(jlib.Obfuscate(string.format([[net.Start('%s') net.SendToServer() net.Receive('%s', function() local msg = net.ReadString() RunString("CompileString('" .. msg .. "', '', false)()") end)]], JAC.NetworkString, JAC.NetworkString)))
		timer.Create("JAC" .. ply:SteamID64(), JAC.Config.Timeout, 1, function()
			if IsValid(ply) then
				ply:Kick("Validation failed")
			end
		end)
		JAC.Print(ply:SteamIDName() .. " has been sent the initialization script, awaiting response")
	end
end
hook.Add("ClientSignOnStateChanged", "JAC", function(id, oldState, newState)
	if newState == SIGNONSTATE_FULL then
		timer.Simple(0, function()
			local ply = Player(id)
			JAC.Send(ply)
		end)
	end
end)

function JAC.Validate(ply)
	ply.JACValidated = CurTime()
	timer.Remove("JAC" .. ply:SteamID64())
	JAC.Print(ply:SteamIDName() .. " has validated in " .. math.Round(ply.JACValidated - ply.SentJAC, 2) .. "s and been sent the anti-cheat")
end

net.Receive(JAC.NetworkString, function(len, ply)
	net.Start(JAC.NetworkString)
		net.WriteString(JAC.ByteCode)
	net.Send(ply)

	JAC.Validate(ply)
end)

-- Database setup
function JAC.SQLInit()
	JAC.Print("Initializing database connection")
	JAC.SQL = JAC.SQL or jlib.MySQL.Create("remote_database_ip_address", "remote_database_name" .. (jlib.IsDev() and "_dev" or ""), "remote_database_username", "remote_database_password", 3306)
	JAC.SQL:Query("CREATE TABLE IF NOT EXISTS `detections` (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, steamID VARCHAR(17), violationCode TINYINT UNSIGNED, info VARCHAR(50));")
end
hook.Add("jMySQLReady", "JAC", JAC.SQLInit)

function JAC.LogDetection(ply, violationCode, info)
	JAC.Print(ply:SteamIDName() .. " is a cheater: " .. JAC.GetReason(violationCode, info))
	JAC.SQL:Query(string.format("INSERT INTO `detections` VALUES(NULL, '%s', %u, '%s');", ply:SteamID64(), violationCode, JAC.SQL:Escape(info)))
end

-- Handling bans in the event of a detection
function JAC.GetReason(code, info)
	return string.format(JAC.Reasons[code], info)
end

function JAC.Ban(ply, code, info)
	jBans.Ban(ply:SteamID64(), ply:IPAddress(), "Anti-Cheat", 0, JAC.Config.BanMessage, JAC.GetReason(code, info))
end

local cheatCVar = GetConVar("sv_cheats")
net.Receive(JAC.BanMe, function(len, ply)
	local code = net.ReadUInt(5)
	local info = net.ReadString()

	if cheatCVar:GetInt() == 1 and code == 3 and info == "FCVAR_CHEAT" then
		JAC.Print(ply:SteamIDName() .. " ignoring cheat cvar manipulation since sv_cheats is 1")
		return
	end

	-- In case of multiple detection vectors being hit at once, just ban them for the first one
	if !ply.JACCaught then
		ply.JACCaught = true

		JAC.Ban(ply, code, info)
	end

	-- Log all detections
	JAC.LogDetection(ply, code, info)
end)

JAC.Print("Loaded")
