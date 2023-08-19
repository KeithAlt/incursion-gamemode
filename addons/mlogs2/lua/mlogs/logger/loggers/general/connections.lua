--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "general"
// Connection Logs
mLogs.addLogger("Connections","connects",category)
mLogs.addHook("PlayerAuthed", category, function(ply)
    if not IsValid(ply) then return end
    ply.mLogsIgnorePickup = true
    mLogs.log("connects",category,{player1=mLogs.logger.getPlayerData(ply),c=true})
end)
mLogs.addHook("PlayerDisconnected", category, function(ply)
    if not IsValid(ply) then return end
    mLogs.log("connects",category,{player1=mLogs.logger.getPlayerData(ply),c=false})
end)