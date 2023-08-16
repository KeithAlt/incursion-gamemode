--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

mLogs.addCategory(
	"Pointshop2", -- Name
	"ps2", 
	Color(241, 169, 160), -- Color
	function() -- Check
		return Pointshop2 != nil
	end,
	true -- delayed
)

mLogs.addCategoryDefinitions("ps2", {
	ps2purchase = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation("purchase"),data) end,
	ps2equip = function(data) return mLogs.doLogReplace({"^player1","equipped","^item"},data) end,
})