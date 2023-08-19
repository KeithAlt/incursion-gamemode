--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

mLogs.addCategory(
	"My Category", -- Category Name
	"mycategory", -- Short key (this is what mLogs will use to identify your category, keep it short and lowercase) 
	Color(38, 166, 91), -- Color
	function()
		// Do your check here to see if your addon exists
		return true
	end,
)

mLogs.addCategoryDefinitions("mycategory", {
	mylogger = function(data) return mLogs.doLogReplace({"^player1", "connected"}),data) end,
})