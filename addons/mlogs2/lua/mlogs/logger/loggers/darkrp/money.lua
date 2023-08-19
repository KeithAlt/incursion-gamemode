--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "darkrp"
// Money Logs
mLogs.addLogger("Money","money",category)
mLogs.addHook("playerDroppedMoney", category, function(ply,amt,ent)
	if(not IsValid(ply))then return end
    if(IsValid(ent))then
        ent.mLogs_Owner = ply
    end
	mLogs.log("money", category, {player1=mLogs.logger.getPlayerData(ply),amt=mLogs.formatMoney(amt),d=true})
end)
mLogs.addHook("playerPickedUpMoney", category, function(ply,amt,ent)
	if(not IsValid(ply))then return end
    if(IsValid(ent) and IsValid(ent.mLogs_Owner))then
	    mLogs.log("money", category, {player1=mLogs.logger.getPlayerData(ply),amt=mLogs.formatMoney(amt),owner=mLogs.logger.getPlayerData(ent.mLogs_Owner),p=true})
    else
	    mLogs.log("money", category, {player1=mLogs.logger.getPlayerData(ply),amt=mLogs.formatMoney(amt),p=true})
    end
end)
