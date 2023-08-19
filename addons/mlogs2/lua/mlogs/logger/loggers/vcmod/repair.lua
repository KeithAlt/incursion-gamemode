--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "vcmod"
// Repair Logs
mLogs.addLogger("Repairs","vcrepair",category)
mLogs.addHook("VC_playerRepairedPart", category, function(ply,ent,part)
    if (not IsValid(ply) or not IsValid(ent)) then return end
    mLogs.log("vcrepair",category,{player1=mLogs.logger.getPlayerData(ply),vehicle=ent.VC_getName and ent:VC_getName() or "vehicle",part=part})
end)