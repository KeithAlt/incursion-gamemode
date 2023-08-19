--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

mLogs.addCategory(
	"Cuffs", -- Name
	"cuffs", 
	Color(247, 202, 24), -- Color
	function() -- Check
		return ConVarExists("cuffs_autoarrest")
	end,
	true -- delayed
)

mLogs.addCategoryDefinitions("cuffs", {
    handcuffs = function(data) return mLogs.doLogReplace({"^player1", "handcuffed", "^target"},data) end,
    handcuffs_b = function(data) return mLogs.doLogReplace(
		data.f and {"^f", "broke", "^player1", "out of handcuffs"} or 
		{"^player1", "broke out of handcuffs"}
		,data) 
	end,
    gagcuffs = function(data) return mLogs.doLogReplace(
		data.u and {"^player1", "ungagged", "^target"} or 
		{"^player1", "gagged", "^target"}
		,data) 
	end,
    blindcuffs = function(data) return mLogs.doLogReplace(
		data.u and {"^player1", "blinded", "^target"} or 
		{"^player1", "unblinded", "^target"}
		,data)
	end,
    dragcuffs = function(data) return mLogs.doLogReplace(
		data.u and {"^player1", "started dragging", "^target"} or 
		{"^player1", "stopped dragging", "^target"}
		,data)
	end,
    tiescuffs = function(data) return mLogs.doLogReplace(
		data.u and {"^player1", "tied", "^target"} or 
		{"^player1", "untied", "^target"}
		,data)
	end,
})