--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "cinema"
// Join Logs
mLogs.addLogger("Join/Leave","joins",category)
mLogs.addHook("PostPlayerEnterTheater", category, function(ply,theater)
	if(not IsValid(ply) or not theater or not theater.Name)then return end
    ply.mLogs_lastTheater = theater
    mLogs.log("joins", category, {player1=mLogs.logger.getPlayerData(ply),theater=theater:Name(),e=true})
end)
mLogs.addHook("PrePlayerExitTheater", category, function(ply,theater)
	if(not IsValid(ply))then return end
    theater = theater or ply.mLogs_lastTheater
    mLogs.log("joins", category, {player1=mLogs.logger.getPlayerData(ply),theater=(theater and theater.Name and theater:Name() or "a theater")})
    ply.mLogs_lastTheater = nil
end)