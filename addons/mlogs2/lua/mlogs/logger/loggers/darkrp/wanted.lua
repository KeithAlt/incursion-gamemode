--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "darkrp"
// Wanted Logs
mLogs.addLogger("Wanted","wanted",category)
mLogs.addHook("playerWanted", category, function(target,cop,reason)
	if(not IsValid(target) or not IsValid(cop))then return end
	mLogs.log("wanted", category, {
        target = mLogs.logger.getPlayerData(target),
        cop = mLogs.logger.getPlayerData(cop),
        reason = reason,
        w=true,
    })
end)
mLogs.addHook("playerUnWanted", category, function(target,cop)
	if(not IsValid(target) or not IsValid(cop))then return end
	mLogs.log("wanted", category, {
        target = mLogs.logger.getPlayerData(target),
        cop = mLogs.logger.getPlayerData(cop),
    })
end)