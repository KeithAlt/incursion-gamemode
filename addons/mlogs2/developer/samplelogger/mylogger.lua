--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "mycategory"

// This adds a logger to the category mLogs.addLogger(name,logger_key,category)
mLogs.addLogger("My Logger","mylogger",category)

// This adds a hook but does all the naming stuff in the background, also is used for disabling the category. mLogs.addHook(HookName, category, function)
mLogs.addHook("PlayerAuthed", category, function(ply)
    if not IsValid(ply) then return end
	
	// mLogs.log(logger_key, category, data), you can then access all variables in data by using ^variablename
    mLogs.log("mylogger",category,{player1=mLogs.logger.getPlayerData(ply)})
end)