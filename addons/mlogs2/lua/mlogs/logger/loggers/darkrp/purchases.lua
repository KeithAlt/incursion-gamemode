--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "darkrp"
// Purchases Logs
mLogs.addLogger("Purchases","purchases",category)
mLogs.addHook("playerBoughtVehicle", category, function(ply,ent,price)
	if(not IsValid(ply))then return end
	mLogs.log("purchases", category, {player1=mLogs.logger.getPlayerData(ply),item=mLogs.logger.getVehicleData(ent),price=mLogs.formatMoney(price)})
end)
mLogs.addHook("playerBoughtCustomVehicle", category, function(ply,tbl,ent,price)
	if(not IsValid(ply))then return end
	mLogs.log("purchases", category, {player1=mLogs.logger.getPlayerData(ply),item=mLogs.logger.getVehicleData(ent,{name=tbl and tbl.name}),price=mLogs.formatMoney(price)})
end)
local function buyEntityLog(ply,tbl,ent,price)
	if(not IsValid(ply))then return end
	mLogs.log("purchases", category, {player1=mLogs.logger.getPlayerData(ply),item=mLogs.logger.getEntityData(ent,{name=tbl and tbl.name}),price=mLogs.formatMoney(price)})
end
mLogs.addHook("playerBoughtCustomEntity", category, buyEntityLog)
mLogs.addHook("playerBoughtAmmo", category, buyEntityLog)
local function buyShipmentLog(ply,tbl,ent,price)
	if(not IsValid(ply))then return end
	mLogs.log("purchases", category, {
		player1=mLogs.logger.getPlayerData(ply),
		item=mLogs.logger.getEntityData(ent,{name=tbl.name}),
		price=mLogs.formatMoney(price),
		amt= "x" .. (tbl.amount or 1),
		s=true,
	})
end
mLogs.addHook("playerBoughtShipment", category, buyShipmentLog)
mLogs.addHook("playerBoughtPistol", category, buyShipmentLog)
mLogs.addHook("playerBoughtFood", category, buyShipmentLog)