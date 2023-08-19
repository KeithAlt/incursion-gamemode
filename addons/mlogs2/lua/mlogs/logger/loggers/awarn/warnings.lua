--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "awarn2"
// Warning Logs
mLogs.addLogger("Warnings","aw2warns",category)
mLogs.addHook("AWarnPlayerWarned", category, function(target,admin,reason)
	if(type(admin) == "string")then admin = player.GetBySteamID64(admin) end
    if (not IsValid(admin) or not IsValid(target)) then return end
    mLogs.log("aw2warns",category,{admin=mLogs.logger.getPlayerData(admin),target=mLogs.logger.getPlayerData(target),reason=reason})
end)
mLogs.addHook("AWarnPlayerIDWarned", category, function(steamid,admin,reason)
	if(type(admin) == "string")then admin = player.GetBySteamID64(admin) end
    if (not IsValid(admin)) then return end
    mLogs.log("aw2warns",category,{admin=mLogs.logger.getPlayerData(admin),target=steamid,reason=reason})
end)