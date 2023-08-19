--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "ttt"
// Body Logs
mLogs.addLogger("Body","body",category)
mLogs.addHook("TTTBodyFound", category, function(ply,ply2)
	if(not IsValid(ply) or not IsValid(ply2))then return end
    mLogs.log("body", category, {player1=mLogs.logger.getPlayerData(ply),player2=mLogs.logger.getPlayerData(ply2)})
end)