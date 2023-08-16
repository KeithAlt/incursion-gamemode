--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

mLogs.config.ulxBlacklist = mLogs.config.ulxBlacklist or {
	"ulx noclip"
}

local category = "ulx"
// ULX Logs
mLogs.addLogger("Commands","ulxcommand",category)

mLogs.addHook("ULibCommandCalled", category, function(ply,cmd,args)
	if(not IsValid(ply) or slient)then return end
	if(table.HasValue(mLogs.config.ulxBlacklist, cmd))then return end
	mLogs.log("ulxcommand", category, {player1=mLogs.logger.getPlayerData(ply),command=cmd,args=table.concat(args," ")})
end)