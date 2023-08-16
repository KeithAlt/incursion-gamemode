--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "darkrp"
// Lockpick Logs
mLogs.addLogger("Lockpick","lockpick",category)
mLogs.addHook("lockpickStarted", category, function(ply,ent)
	if(not IsValid(ply) or not IsValid(ent))then return end
	local log = {player1=mLogs.logger.getPlayerData(ply),t=true}
	if(ent:IsVehicle())then
		log.vehicle = mLogs.logger.getVehicleData(ent)
	end
	if(IsValid(ent:getDoorOwner()))then
		log.owner = mLogs.logger.getPlayerData(ent:getDoorOwner())
	end
	mLogs.log("lockpick", category, log)
end)
mLogs.addHook("onLockpickCompleted", category, function(ply,success,ent)
	if(not IsValid(ply) or not IsValid(ent))then return end
	local log = {player1=mLogs.logger.getPlayerData(ply),c=true}
	if(ent:IsVehicle())then
		log.vehicle = mLogs.logger.getVehicleData(ent)
	end
	if(IsValid(ent:getDoorOwner()))then
		log.owner = mLogs.logger.getPlayerData(ent:getDoorOwner())
	end
	log.s = success
	mLogs.log("lockpick", category, log)
end)