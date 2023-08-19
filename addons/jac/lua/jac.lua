local JAC = JAC or {} -- Remember to have this global during development, local during deployment
-- JAC.Print = jlib.GetPrintFunction("[JAC]", Color(255, 0, 255))

-- Utils
function JAC.Lookupify(tbl)
	local lookup = {}
	for i, v in ipairs(tbl) do
		lookup[v] = true
	end
	return lookup
end

function JAC.Lookup(str, tbl)
	if not str then return false end

	for i, v in ipairs(tbl) do
		if string.find(str:lower(), v:lower(), nil, true) then
			return true
		end
	end

	return false
end

function JAC.DetourFunc(tbl, key, extra)
	local originalKey = key .. "Original"
	JAC[originalKey] = JAC[originalKey] or tbl[key]

	tbl[key] = function(...)
		extra(...)
		return JAC[originalKey](...)
	end
end

function JAC.IsC(func)
	return not pcall(jit.util.funck, func, 1)
end

-- Definitions
local SOURCE_MISMATCH = 1
local BAD_CVAR = 2
local BAD_CVAR_MANIP = 3
local BAD_FONT = 4
local BAD_FUNCTION = 5
local BAD_MODULE = 6
local BAD_GLOBAL = 7
local BAD_DETOUR = 8

JAC.BadDetours = {net.Start, net.SendToServer, pcall, error, debug.getinfo, jit.util.funcinfo, jit.util.funck, render.Capture, render.CapturePixels, render.ReadPixel}
JAC.BadGlobals = {"bSendPacket", "ValidNetString", "totalExploits", "addExploit", "AutoReload", "CircleStrafe", "toomanysploits", "Sploit", "R8", "ValidateESP", "ValidateAimbot"}
JAC.BadFunctionNames = {"smeg", "bypass", "aimbot", "antiaim", "hvh", "autostrafe", "fakelag", "snixzz", "ValidNetString", "addExploit", "cathack"}
JAC.BadSources = {"external", "smeg", "bypass", "aimbot", "aimware", "hvh", "snixzz", "antiaim", "memeware", "hlscripts", "exploitcity", "gmodhack", "scripthook", "ampris", "skidsmasher", "gdaap", "swag_hack", "pasteware", "unknowncheats", "mpgh", "defqon", "idiotbox", "ravehack", "murderhack", "cathack"}
JAC.BadCVars = {"lenny", "smeg", "wallhack", "nospread", "antiaim", "hvh", "autostrafe", "circlestrafe", "spinbot", "odium", "ragebot", "legitbot", "fakeangles", "anticac", "antiscreenshot", "fakeduck", "lagexploit", "exploits_open", "gmodhack", "cathack"}
JAC.BadFonts = {"ESP_Font_Main", "ESP_Font_Flag", "ESP_Font_Entity", "ESP_Font_Health"}
JAC.BadModules = {"dickwrap", "aaa", "enginepred", "bsendpacket", "fhook", "cvar3", "cv3", "nyx", "amplify", "hi", "mega", "pa4", "pspeed", "snixzz2", "spreadthebutter", "stringtables", "svm", "swag", "external"}
JAC.ReplicatedCVars = {"sv_allowcslua", "sv_cheats", "host_timescale"}
JAC.DetourNames = {{table, "Copy"}, {hook, "Add"}, {vgui, "Create"}}

function JAC.Ban(banCode, info)
	jBans.SetHWBanCookie()
	net.Start(JAC.BanMe)
		net.WriteUInt(banCode, 5)
		net.WriteString(info)
	net.SendToServer()
end

-- Global variable checks
function JAC.CheckGlobals()
	for i, name in ipairs(JAC.BadGlobals) do
		if _G[name] then
			JAC.Ban(BAD_GLOBAL, name)
		end
	end
end

function JAC.CheckDebugDiscrepancy()
	for k, v in pairs(_G) do
		if k == "_G" then continue end

		-- Checking all global functions
		if isfunction(v) then
			-- Checking for debug.getinfo/jit.util.funcinfo detours
			local jitInfo = jit.util.funcinfo(v)
			local debugInfo = debug.getinfo(v)

			if (jitInfo.source or "=[C]") ~= debugInfo.source then
				JAC.Ban(SOURCE_MISMATCH, debugInfo.short_src)
			end
		end
	end
end

-- Detour checks
function JAC.DetourCheck()
	for i, func in ipairs(JAC.BadDetours) do
		if not JAC.IsC(func) then
			JAC.Ban(BAD_DETOUR, tostring(i))
		end
	end
end

-- Function checks
function JAC.CheckDebugInfo(info)
	if JAC.Lookup(info.short_src, JAC.BadSources) then
		JAC.Ban(BAD_FUNCTION, info.short_src)
	elseif JAC.Lookup(info.name, JAC.BadFunctionNames) then
		JAC.Ban(BAD_FUNCTION, info.name)
	end
end

function JAC.DetourFuncs()
	for i, names in ipairs(JAC.DetourNames) do
		JAC.DetourFunc(names[1], names[2], function()
			JAC.CheckDebugInfo(debug.getinfo(3))
		end)
	end
end

function JAC.CheckFunc(func)
	local info = jit.util.funcinfo(func)

	if JAC.Lookup(info.source, JAC.BadSources) then
		JAC.Ban(BAD_FUNCTION, info.source)
	end

	JAC.DetourCheck()
end
jit.attach(JAC.CheckFunc, "bc")

-- CVar checks
function JAC.CheckForCVars()
	for i, cvarName in ipairs(JAC.BadCVars) do
		if GetConVar_Internal(cvarName) ~= nil then
			JAC.Ban(BAD_CVAR, cvarName)
		end
	end
end

function JAC.CVarChanged(name, old, new)
	JAC.Ban(BAD_CVAR_MANIP, name)
end

function JAC.AddCVarCallbacks()
	for i, cvarName in ipairs(JAC.ReplicatedCVars) do
		cvars.AddChangeCallback(cvarName, old, new)
	end
end

JAC.CreateClientConVar = JAC.CreateClientConVar or CreateClientConVar
function CreateClientConVar(name, ...)
	if JAC.Lookup(name, JAC.BadCVars) then
		JAC.Ban(BAD_CVAR, name)
	end
	JAC.CheckDebugInfo(debug.getinfo(2))

	return JAC.CreateClientConVar(name, ...)
end

-- Font checks
JAC.CreateFont = JAC.CreateFont or surface.CreateFont
function surface.CreateFont(name, data)
	if JAC.Lookup(name, JAC.BadFonts) then
		JAC.Ban(BAD_FONT, name)
	end
	JAC.CheckDebugInfo(debug.getinfo(2))

	return JAC.CreateFont(name, data)
end

-- Module checks
JAC.Require = JAC.Require or require
function require(moduleName)
	if JAC.Lookup(moduleName, JAC.BadModules) then
		JAC.Ban(BAD_MODULE, moduleName)
	end
	JAC.CheckDebugInfo(debug.getinfo(2))

	return JAC.Require(moduleName)
end

-- FCVAR_CHEAT & FCVAR_REPLICATED bypass check
JAC.CheatCVarName = JAC.CheatCVarName or jlib.RandomString(16)
JAC.RepCVarName = JAC.RepCVarName or jlib.RandomString(16)
JAC.CheatCVar = CreateConVar(JAC.CheatCVarName, 0, FCVAR_CHEAT)
JAC.RepCVar = CreateConVar(JAC.RepCVarName, 0, FCVAR_REPLICATED)

function JAC.CheckCVarConstraints()
	-- local wasEnabled = GetConVar("con_filter_enable"):GetString()
	-- local oldFilter = GetConVar("con_filter_text"):GetString()

	-- RunConsoleCommand("con_filter_enable", "1")
	-- RunConsoleCommand("con_filter_text", "nil")

	jlib.CallAfterTicks(2, function()
		RunConsoleCommand(JAC.CheatCVarName, "1")
		RunConsoleCommand(JAC.RepCVarName, "1")

		if JAC.CheatCVar:GetString() == "1" then
			JAC.Ban(BAD_CVAR_MANIP, "FCVAR_CHEAT")
		elseif JAC.RepCVar:GetString() == "1" then
			JAC.Ban(BAD_CVAR_MANIP, "FCVAR_REPLICATED")
		end

		-- RunConsoleCommand("con_filter_enable", wasEnabled or "0")
		-- RunConsoleCommand("con_filter_text", oldFilter or "")
	end)
end

-- Heartbeat
function JAC.DoChecks()
	JAC.DetourCheck()
	JAC.CheckForCVars()
	JAC.CheckCVarConstraints()
	JAC.CheckGlobals()
	JAC.CheckDebugDiscrepancy() -- May want to remove this from heartbeat
end

function JAC.Heartbeat()
	JAC.DoChecks()
end

function JAC.StartHeartbeat()
	JAC.TimerID = JAC.TimerID or jlib.RandomString(16)
	timer.Create(JAC.TimerID, 300, 0, JAC.Heartbeat)
end

-- Init
function JAC.Init()
	JAC.AddCVarCallbacks()
	JAC.DetourFuncs()
	JAC.StartHeartbeat()
	JAC.DoChecks()
end
JAC.Init()

-- JAC.Print("Loaded")
