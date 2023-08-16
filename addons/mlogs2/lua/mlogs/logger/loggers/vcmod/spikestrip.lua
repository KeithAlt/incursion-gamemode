--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "vcmod"
// Spike Strip Logs
mLogs.addLogger("Spike Strip","vcspike",category)
mLogs.addHook("VC_spikeStripPlaced", category, function(ent,ply)
    if (not IsValid(ply)) then return end
    mLogs.log("vcspike",category,{player1=mLogs.logger.getPlayerData(ply)})
end)