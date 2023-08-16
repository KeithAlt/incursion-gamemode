--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "sandbox"
// Tool Logs
mLogs.addLogger("Toolgun","toolgun",category)
mLogs.addHook("CanTool", category, function(ply,tr,tool)
	if(not IsValid(ply))then return end
	local log = {player1=mLogs.logger.getPlayerData(ply),tool=tool}
	if(IsValid(tr.Entity))then
    	log.ent=mLogs.logger.getEntityData(tr.Entity)
		log.owner=mLogs.getEntOwner(tr.Entity) and mLogs.logger.getPlayerData(mLogs.getEntOwner(tr.Entity))
	end
	mLogs.log("toolgun", category, log)
end)