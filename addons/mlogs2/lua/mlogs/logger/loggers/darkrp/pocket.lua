--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "darkrp"
// Pocket Logs
mLogs.addLogger("Pocket","pocket",category)
mLogs.addHook("onPocketItemAdded", category, function(ply,ent)
	if(not IsValid(ply))then return end
	mLogs.log("pocket", category, {player1=mLogs.logger.getPlayerData(ply),item=mLogs.logger.getEntityData(ent)})
end)
mLogs.addHook("onPocketItemDropped", category, function(ply,ent)
	if(not IsValid(ply))then return end
	mLogs.log("pocket", category, {player1=mLogs.logger.getPlayerData(ply),item=mLogs.logger.getEntityData(ent),d=true})
end)