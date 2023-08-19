--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "cuffs"
// Handcuff Break Logs
mLogs.addLogger("Handcuff Break","handcuffs_b",category)
mLogs.addHook("OnHandcuffBreak", category, function(ply,cuffs,friend)
    if (not IsValid(ply)) then return end
	local log = {player1=mLogs.logger.getPlayerData(ply)}
	if(IsValid(friend))then
		log.f = mLogs.logger.getPlayerData(friend)
	end
    mLogs.log("handcuffs_b",category,log)
end)