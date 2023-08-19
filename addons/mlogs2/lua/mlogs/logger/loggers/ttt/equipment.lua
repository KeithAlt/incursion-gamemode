--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "ttt"
// Equipment Logs
mLogs.addLogger("Equipment Purchases","equipment",category)
mLogs.addHook("TTTOrderedEquipment", category, function(ply,equipment,is_item)
	if(not IsValid(ply) or not ply.GetRole)then return end
    local log = {player1=mLogs.logger.getPlayerData(ply)}
    if(is_item)then
        local itemData = GetEquipmentItem(ply:GetRole(), equipment)
        if(not itemData)then return end
        log.item = itemData.name
    else
        log.item = mLogs.logger.getWeaponData(nil,{class=equipment})
    end
    mLogs.log("equipment", category, log)
end)