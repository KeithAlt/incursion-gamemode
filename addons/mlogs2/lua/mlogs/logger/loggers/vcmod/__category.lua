--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

mLogs.addCategory(
	"VCMod", -- Name
	"vcmod", 
	Color(207, 0, 15), -- Color
	function() -- Check
		return VC != nil
	end,
	true -- delayed
)

mLogs.addCategoryDefinitions("vcmod", {
	vcpurchase = function(data) return mLogs.doLogReplace({"^player1","purchased a","^item"},data) end,
	vcspike = function(data) return mLogs.doLogReplace({"^player1","placed a spikestrip"},data) end,
	vcrepair = function(data) return mLogs.doLogReplace({"^player1","finished repairing a", "^vehicle", "^part"},data) end,
})