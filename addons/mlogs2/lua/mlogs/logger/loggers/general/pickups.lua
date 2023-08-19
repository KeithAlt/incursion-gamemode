--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "general"
// Pickup Logs
mLogs.addLogger("Pickups", "pickups", category)
mLogs.addHook("WeaponEquip",category,function(wep,ply)
    if(not IsValid(ply))then return end
    if(ply.mLogsIgnorePickup)then return end
    mLogs.log("pickups", category, {player1=mLogs.logger.getPlayerData(ply),item=mLogs.logger.getWeaponData(wep)})
end)
mLogs.addHook("PlayerCanPickupItem",category,function(ply,ent)
    if(not IsValid(ply))then return end
    if(ply.mLogsIgnorePickup)then return end
    mLogs.log("pickups", category, {player1=mLogs.logger.getPlayerData(ply),item=mLogs.logger.getEntityData(ent)})
end)
// Prevent Log Spam from spawn pickups
mLogs.addHook("PlayerSpawn", category, function(ply)
    timer.Simple(3,function()
        if(not IsValid(ply)) then return end
        ply.mLogsIgnorePickup = nil
    end)
end)