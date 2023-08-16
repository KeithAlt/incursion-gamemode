--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

mLogs.addCategory(
	"ULX", -- Name
	"ulx", 
	Color(31, 58, 147), -- Color
	function() -- Check
		return ULib != nil
	end,
	true -- delayed
)

mLogs.addCategoryDefinitions("ulx", {
	ulxcommand = function(data) return mLogs.doLogReplace({"^player1","ran the command:","^command","^args"},data) end,
})