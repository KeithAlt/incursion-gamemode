--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

mLogs.addCategory(
	"TTT", -- Name
	"ttt", 
	Color(154, 18, 179), -- Color
	function() -- Check
		return string.lower( gmod.GetGamemode( ).Name ) == "trouble in terrorist town"
	end,
	true -- delayed
)

mLogs.addCategoryDefinitions("ttt", {
    equipment = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation("equipment"),data) end,
    dna = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation(
        data.weapon and "dna_weapon" or "dna"
    ),data) end,
    karma = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation("karma"),data) end,
    body = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation("body"),data) end,
})