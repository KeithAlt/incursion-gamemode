--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "sg"
// ServerGuard Logs
mLogs.addLogger("Commands","sgcommand",category)
mLogs.addHook("serverguard.RanCommand", category, function(ply,cmd, silent,args)
	if(not IsValid(ply) or slient)then return end
	mLogs.log("sgcommand", category, {player1=mLogs.logger.getPlayerData(ply),command=cmd and cmd.command or cmd,args=table.concat(args," ")})
end)