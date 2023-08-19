--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

mLogs.addCategory(
	"ServerGuard", -- Name
	"sg", 
	Color(68,108,179), -- Color
	function() -- Check
		return serverguard != nil
	end,
	true -- delayed
)

mLogs.addCategoryDefinitions("sg", {
	sgcommand = function(data) return mLogs.doLogReplace({"^player1","has ran the command:","^command","^args"},data) end,
})