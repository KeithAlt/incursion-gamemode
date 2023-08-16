--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "darkrp"
// Door Logs
mLogs.addLogger("Doors","doors",category)
mLogs.addHook("playerSellDoor", category, function(ply)
	if(not IsValid(ply))then return end
    mLogs.log("doors", category, {player1=mLogs.logger.getPlayerData(ply),s=true})
end)
mLogs.addHook("playerBoughtDoor", category, function(ply)
	if(not IsValid(ply))then return end
    mLogs.log("doors", category, {player1=mLogs.logger.getPlayerData(ply),b=true})
end)