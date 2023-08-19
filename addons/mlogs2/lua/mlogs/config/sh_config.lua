--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright � 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

// FILE VERSION: 1 - View lastest versions here: https://docs.m4dsolutions.com/#/category/1/article/4
mLogs.config.fileVersions = mLogs.config.fileVersions or {}
mLogs.config.fileVersions["config/sh_config.lua"] = 1

// Permissions
mLogs.config.root = {
	["superadmin"] = true,
	["owner"] = true,
} // The root user has the ability to add/remove usergroups, teams, and steamids 
