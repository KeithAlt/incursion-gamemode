--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "darkrp"
// Arrests Logs
mLogs.addLogger("Arrests","arrests",category)
mLogs.addHook("playerArrested", category, function(target,time,arrestor)
	if(not IsValid(target) or not IsValid(arrestor))then return end
	mLogs.log("arrests", category, {player1=mLogs.logger.getPlayerData(arrestor),player2=mLogs.logger.getPlayerData(target),a=true})
end)
mLogs.addHook("playerUnArrested", category, function(target,arrestor)
	if(not IsValid(target) or not IsValid(arrestor))then return end
	mLogs.log("arrests", category, {player1=mLogs.logger.getPlayerData(arrestor),player2=mLogs.logger.getPlayerData(target)})
end)