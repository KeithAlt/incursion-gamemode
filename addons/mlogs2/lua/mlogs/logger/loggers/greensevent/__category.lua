--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

mLogs.addCategory(
	"GreensEvents", -- Name
	"gevents", 
	Color(27, 163, 156), -- Color
	function() -- Check
		return GreensEvent and GreensEvent.Config and GreensEvent.Config.MLogs_Support
	end,
	true -- delayed
)

mLogs.addCategoryDefinitions("gevents", {
	gestarted = function(data) return mLogs.doLogReplace({"The Event","^event", "has started"},data) end,
	gefinish = function(data) return mLogs.doLogReplace({"The Event","^event", "has finished"},data) end,
	gewinner = function(data) return mLogs.doLogReplace({"^player1", "has won the event with a reward of","^reward"},data) end,
})