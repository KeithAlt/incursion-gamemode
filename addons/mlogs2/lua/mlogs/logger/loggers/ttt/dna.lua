--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "ttt"
// DNA Logs
mLogs.addLogger("DNA","dna",category)
mLogs.addHook("TTTFoundDNA", category, function(ply,dna_ply,ent)
	if(not IsValid(ply) or not IsValid(ent))then return end
    local log = {player1=mLogs.logger.getPlayerData(ply),player2=mLogs.logger.getPlayerData(dna_ply)}
    if(ent:IsWeapon())then
        log.weapon = mLogs.logger.getWeaponData(ent)
    end
    mLogs.log("dna", category, log)
end)