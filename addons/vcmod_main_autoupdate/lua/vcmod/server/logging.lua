// Copyright © 2020 VCMod (freemmaann). All Rights Reserved. if you have any complaints or ideas contact me: steam - steamcommunity.com/id/freemmaann/ or email - freemmaann@gmail.com.

// All of this code might be overwritten by the Auto Updater. It is locally solely to log the initial messages.

// VCMod logging console command
CreateConVar("vc_logs", "1", FCVAR_ARCHIVE, "Should VCMod use logs")

/*
Initialize the different methods to log data
*/

local logSystems = {}

// VCMod (https://www.gmodstore.com/scripts/view/21 ; https://www.gmodstore.com/scripts/view/489)
local newSystem = {}
newSystem.name = "VCMod"
newSystem.isEnabled = function() return true end
newSystem.formatPlayer = function(ply) local ret = ply:Nick()..'('..(ply:SteamID64() or "")..')' return ret end
newSystem.formatHighlight = function(val, nType) return val end
newSystem.doRun = function(msg, dtype) VC.log_record(msg) end
logSystems[newSystem.name] = newSystem

// bLogs (https://www.gmodstore.com/scripts/view/1599/)
local newSystem = {}
newSystem.name = "bLogs"
newSystem.isEnabled = function() return bLogs end
newSystem.formatPlayer = function(ply) local ret = ply:Nick()..'('..(ply:SteamID64() or "")..')' if bLogs.FormatPlayer then ret = bLogs:FormatPlayer(ply) end return ret end
newSystem.formatHighlight = function(val, nType) local ret = val if bLogs.Highlight and ret then ret = bLogs:Highlight(val) end return ret end
newSystem.doRun = function(msg, dtype) if msg and type(msg) == "String" then hook.Run("bLogs_VCMod_"..dtype, {msg}) end end
logSystems[newSystem.name] = newSystem

// dLogs (https://www.gmodstore.com/scripts/view/4093/)
local newSystem = {}
newSystem.name = "dLogs"
newSystem.isEnabled = function() return dLogs end
newSystem.formatPlayer = function(ply) local ret = ply:Nick()..'('..(ply:SteamID64() or "")..')' if dLogs.printPlayer then ret = dLogs.printPlayer(ply) end return ret end
newSystem.formatHighlight = function(val, nType) local ret = val return ret end
newSystem.doRun = function(msg, dtype) if dLogs.log then dLogs.log("dLogs_VCMod_"..dtype, msg) end end
logSystems[newSystem.name] = newSystem


/*
Some logging code
*/

// Lets create the needed directory(ies)
file.CreateDir("vcmod/logs")

// Make it nice
local function getNiceTime(time) return os.date("%Y-%m-%d %H.%M.%S", time) end

// Prepare file name
local timeStart = os.time() local fileName = "vcmod/logs/"..getNiceTime(timeStart).." ("..timeStart..")"..".txt"

// VCMod recording to file, very basic, but useful
function VC.log_record(msg) file.Append(fileName, getNiceTime(os.time())..": "..msg.."\n") end

// The main log function
function VC.log(msg, dtype)
	if GetConVar("vc_logs"):GetInt() != 1 then return end

	// No time? Generalize it
	if !dtype then dtype = "General" end

	// No need to run it if we do not have a message
	if !msg then return end

	// Make damn sure its a string
	if type(msg) != "string" then msg = tostring(msg) end

	for k,curSys in pairs(logSystems) do
	local newMsg = msg
		if curSys.isEnabled() then
			local data_ply = string.Explode("__vc_ply__", newMsg)
			if #data_ply > 2 then newMsg = data_ply[1]..curSys.formatPlayer(ents.GetByIndex(data_ply[2]))..data_ply[3] end

			local data_hl = string.Explode("__vc_hls__", newMsg)
			if #data_hl > 1 then
				local namsg = data_hl[1]
				for k,v in pairs(data_hl) do
					if k > 1 then
						local data2 = string.Explode("__vc_hle__", v)
						namsg = namsg..curSys.formatHighlight(data2[1], dtype)
						if data2[2] then namsg = namsg..data2[2] end
					end
				end
				newMsg = namsg
			end

			curSys.doRun(newMsg, dtype)
		end
	end
end

// Highlight stuff, a rather simple solution
function VC.log_getPlayer(ply) local ret = "" if IsValid(ply) then ret = "__vc_ply__"..ply:EntIndex()..'__vc_ply__' end return ret end
function VC.log_highLight(str) if !str then str = "" end return "__vc_hls__"..str..'__vc_hle__' end

// Logging started
VC.log("<General> Logging started, map: "..VC.log_highLight(game.GetMap())..".")