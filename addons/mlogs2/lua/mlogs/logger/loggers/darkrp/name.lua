--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "darkrp"
// Name Logs
mLogs.addLogger("Name Changes","name",category)
mLogs.addHook("onPlayerChangedName", category, function(ply,name1,name2)
	if(not IsValid(ply))then return end
	mLogs.log("name", category, {player1=mLogs.logger.getPlayerData(ply),name1=name1,name2=name2})
end)