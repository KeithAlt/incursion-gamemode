--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "sandbox"
// Prop Logs
mLogs.addLogger("Props","props",category)
mLogs.addHook("PlayerSpawnedProp", category, function(ply,mdl,itm)
	if(not IsValid(ply))then return end
	mLogs.log("props", category, {player1=mLogs.logger.getPlayerData(ply),item=mLogs.logger.getEntityData(itm)})
end)

// NPC Logs
mLogs.addLogger("NPCs","npcs",category)
mLogs.addHook("PlayerSpawnedNPC", category, function(ply,itm)
	if(not IsValid(ply))then return end
	mLogs.log("npcs", category, {player1=mLogs.logger.getPlayerData(ply),item=mLogs.logger.getEntityData(itm)})
end)

// Ragdolls
mLogs.addLogger("Ragdolls","ragdolls",category)
mLogs.addHook("PlayerSpawnedRagdoll", category, function(ply,mdl,itm)
	if(not IsValid(ply))then return end
	mLogs.log("ragdolls", category, {player1=mLogs.logger.getPlayerData(ply),item=mLogs.logger.getEntityData(itm)})
end)

// SENTs
mLogs.addLogger("SENTs","sents",category)
mLogs.addHook("PlayerSpawnedSENT", category, function(ply,itm)
	if(not IsValid(ply))then return end
	mLogs.log("sents", category, {player1=mLogs.logger.getPlayerData(ply),item=mLogs.logger.getEntityData(itm)})
end)

// SWEPs
mLogs.addLogger("SWEPs","sweps",category)
mLogs.addHook("PlayerSpawnedSWEP", category, function(ply,itm)
	if(not IsValid(ply))then return end
	mLogs.log("sweps", category, {player1=mLogs.logger.getPlayerData(ply),item=mLogs.logger.getEntityData(itm)})
end)

// Vehicles
mLogs.addLogger("Vehicles","vehicles",category)
mLogs.addHook("PlayerSpawnedVehicle", category, function(ply,itm)
	if(not IsValid(ply))then return end
	mLogs.log("vehicles", category, {player1=mLogs.logger.getPlayerData(ply),item=mLogs.logger.getVehicleData(itm)})
end)

// Effects
mLogs.addLogger("Effects","effects",category)
mLogs.addHook("PlayerSpawnedEffect", category, function(ply,mdl,itm)
	if(not IsValid(ply))then return end
	mLogs.log("effects", category, {player1=mLogs.logger.getPlayerData(ply),item=mLogs.logger.getVehicleData(itm)})
end)