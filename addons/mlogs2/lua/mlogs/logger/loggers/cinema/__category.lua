--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

mLogs.addCategory(
	"Cinema", -- Name
	"cinema", 
	Color(210, 82, 127), -- Color
	function() -- Check
		return string.lower( gmod.GetGamemode( ).Name ) == "cinema"
	end,
	true -- delayed
)

mLogs.addCategoryDefinitions("cinema", {
    queue = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation("cinema_queue"),data) end,
	joins = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation(
		data.e and "cinema_enter" or "cinema_leave"
	),data) end,
})