--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

mLogs.addCategory(
	"Murder", -- Name
	"murder", 
	Color(31, 58, 147), -- Color
	function() -- Check
		return string.lower( gmod.GetGamemode( ).Name ) == "murder"
	end,
	true -- delayed
)

mLogs.addCategoryDefinitions("murder", {
    loot = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation("loot"),data) end,
})