--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "gevents"
// Event Winner Logs
mLogs.addLogger("Event Winner","gewinner",category)
mLogs.addHook("LogEventWinner", category, function(ply, RewardItem)
    if RewardItem == nil then return end
	if not IsValid(ply) then return end
    mLogs.log("gewinner",category,{player1=mLogs.logger.getPlayerData(ply),reward=RewardItem})
end)