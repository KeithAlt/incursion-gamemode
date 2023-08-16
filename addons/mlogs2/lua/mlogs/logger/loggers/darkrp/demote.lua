--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "darkrp"
// Demote Logs
mLogs.addLogger("Demotes","demotes",category)
mLogs.addHook("onPlayerDemoted", category, function(ply,target,reason)
	if(not IsValid(ply) or not IsValid(target))then return end
	reason = reason or ""
    mLogs.log("demotes", category, {player1=mLogs.logger.getPlayerData(ply),player2=mLogs.logger.getPlayerData(target),reason=reason})
end)
mLogs.addHook("playerAFKDemoted", category, function(ply)
	if(not IsValid(ply))then return end
    mLogs.log("demotes", category, {player1=mLogs.logger.getPlayerData(ply),afk=true})
end)