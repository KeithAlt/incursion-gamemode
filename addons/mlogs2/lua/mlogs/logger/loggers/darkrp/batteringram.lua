--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "darkrp"
// Battering Ram Logs
mLogs.addLogger("Battering Ram","batteringram",category)
mLogs.addHook("onDoorRamUsed", category, function(success,ply,trace)
	if(not IsValid(ply))then return end
	local door = trace.Entity
	if(not IsValid(door)) then return end
	local log = {player1=mLogs.logger.getPlayerData(ply)}
	if(IsValid(door:getDoorOwner()))then
		log.owner = mLogs.logger.getPlayerData(door:getDoorOwner())
	end
	if(door:IsVehicle())then
		log.vehicle = mLogs.logger.getVehicleData(door)
	end
	log.s = success
	mLogs.log("batteringram", category, log)
end)