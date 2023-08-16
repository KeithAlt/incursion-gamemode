--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "darkrp"
// Cheque Logs
mLogs.addLogger("Cheques","cheques",category)
mLogs.addHook("playerDroppedCheque", category, function(ply,target,amount)
	if(not IsValid(ply) or not IsValid(target))then return end
	mLogs.log("cheques", category, {player1=mLogs.logger.getPlayerData(ply),player2=mLogs.logger.getPlayerData(target),amt=mLogs.formatMoney(amount),d=true})
end)
mLogs.addHook("playerPickedUpCheque", category, function(ply,target,amount,success)
	if(not success or not IsValid(ply) or not IsValid(target))then return end
	mLogs.log("cheques", category, {player1=mLogs.logger.getPlayerData(target),player2=mLogs.logger.getPlayerData(ply),amt=mLogs.formatMoney(amount),p=true})
end)
mLogs.addHook("playerToreUpCheque", category, function(ply,target,amount)
	if(not IsValid(ply) or not IsValid(target))then return end
	mLogs.log("cheques", category, {player1=mLogs.logger.getPlayerData(ply),player2=mLogs.logger.getPlayerData(target),amt=mLogs.formatMoney(amount),t=true})
end)