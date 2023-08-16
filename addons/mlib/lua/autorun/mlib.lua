--[[
	mLib (M4D Library Core)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2021 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

--[[ 
	You do not need to edit anything in this addon (mLib).
	All files and configurations can be found the addon's folder that you have downloaded.
]]

mLib = mLib or {}
mLib.version = 2
mLib.Local = true
mLib.Hosts = {
	"https://api.m4dsolutions.com/mlib/",
	"https://std-ca-que-1.api.m4dsolutions.com/mlib/",
	"https://prx-api.m4dsolutions.com/mlib/",
	"https://prx2-api.m4dsolutions.com/mlib/",
}
mLib.Addons = {}
mLib.Lang = {
	a = "Registered mLib addons found: ",
	b = "No valid mLib addons found",
	c = "Unknown routing table found, error: ",
	d = "Unable to verify server destination.",
	e = "Unable to verify a secure connection, request denied.",
	f = "Connection to mLib service successful.",
	g = "mLib was unsuccessful contacting the API server, retrying route ",
	h = "mLib has failed to contact the API server, please make sure your addons are up to date, otherwise contact the developer of the addon.",
	i = "Service configuration queued, a player is required to start the process.",
	j = "Service configuration has started.",
	k = "Received code from server."
}

function mLib.Print(str) MsgC(Color(255,100,0), "[mLib] ", color_white, tostring(str) .. "\n") end
mLib.Print("Service starting now, auto-updater version: " .. mLib.version)
if CLIENT then include("mlib/core/client.lua") else AddCSLuaFile("mlib/core/client.lua") include("mlib/core/server.lua") end