--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

mLogs.addCategory(
	"Sandbox", -- Name
	"sandbox", 
	Color(42, 187, 155), -- Color
	function() -- Check
		return GAMEMODE.IsSandboxDerived
	end,
	true -- delayed
)

mLogs.addCategoryDefinitions("sandbox", {
    toolgun = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation(
		data.ent and (data.owner and "toolgun" or "toolgun_no_owner") or "toolgun_world"
	),data) end,
	props = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation("spawns"),data) end,
	npcs = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation("spawns"),data) end,
	ragdolls = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation("spawns"),data) end,
	sents = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation("spawns"),data) end,
	sweps = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation("spawns"),data) end,
	vehicles = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation("spawns"),data) end,
	effects = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation("spawns"),data) end,
})