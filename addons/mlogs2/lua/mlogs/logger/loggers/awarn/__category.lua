--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

mLogs.addCategory(
	"AWarn2", -- Name
	"awarn2", 
	Color(1,50,67), -- Color
	function() -- Check
		return AWarn != nil
	end,
	true -- delayed
)

mLogs.addCategoryDefinitions("awarn2", {
    aw2warns = function(data) return mLogs.doLogReplace({"^admin", "warned", "^target", "for", "^reason"},data) end,
    aw2kicks = function(data) return mLogs.doLogReplace({"^player1", "was kicked for reaching the warning limit"},data) end,
    aw2bans = function(data) return mLogs.doLogReplace({"^player1", "was banned for reaching the warning limit"},data) end,
})