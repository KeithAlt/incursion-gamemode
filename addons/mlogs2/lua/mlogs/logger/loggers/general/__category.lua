--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

mLogs.addCategory(
	mLogs.getLogTranslation("general"),
	"general", 
	Color(38, 166, 91),
	nil,
	nil,
	100
)

mLogs.addCategoryDefinitions("general", {
	connects = function(data) return mLogs.doLogReplace((mLogs.getLogTranslation(data.c and "connect_server" or "disconnect_server")),data) end,
	kd = function(data)
		return mLogs.doLogReplace(mLogs.getLogTranslation(
			type(data.attacker) == "string" and data.attacker =="suicide" and "kill_suicide" -- suicide
			or data.owner and "kill_owner"
			or data.inflictor and (data.attacker and "kill_inflictor" or "kill_no_player") -- has weapon
			or "kill"),data) -- simple kill no weapon
	end,
	dmg = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation(
			type(data.attacker) == "string" and data.attacker =="self" and (data.inflictor and "dmg_self_inflictor" or "dmg_self") 
			or data.owner and "dmg_owner"
			or data.inflictor and (data.attacker and "dmg_inflictor" or "dmg_no_player") 
			or "dmg"),data) 
	end,
	chat = function(data) return mLogs.doLogReplace({"^player1",":","^msg"},data) end,
	pickups = function(data) return mLogs.doLogReplace(mLogs.getLogTranslation("pickup"),data) end,
})