--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "darkrp"
// Hits Logs
mLogs.addLogger("Hits","hits",category)
mLogs.addHook("onHitAccepted", category, function(hitman,target,customer)
	if(not IsValid(hitman) or not IsValid(target) or not IsValid(customer))then return end
    mLogs.log("hits", category, {
        hitman=mLogs.logger.getPlayerData(hitman),
        target=mLogs.logger.getPlayerData(target),
        customer=mLogs.logger.getPlayerData(customer),
        a=true
    })
end)
mLogs.addHook("onHitCompleted", category, function(hitman,target,customer)
	if(not IsValid(hitman) or not IsValid(target) or not IsValid(customer))then return end
    mLogs.log("hits", category, {
        hitman=mLogs.logger.getPlayerData(hitman),
        target=mLogs.logger.getPlayerData(target),
        customer=mLogs.logger.getPlayerData(customer),
        c=true
    })
end)
mLogs.addHook("onHitFailed", category, function(hitman,target,reason)
	if(not IsValid(hitman) or not IsValid(target) )then return end
    mLogs.log("hits", category, {
        hitman=mLogs.logger.getPlayerData(hitman),
        target=mLogs.logger.getPlayerData(target),
		reason=reason,
        f=true
    })
end)
mLogs.addHook("canRequestHit", category, function(hitman,target,customer,price)
	if(not IsValid(hitman) or not IsValid(target) or not IsValid(customer))then return end
    mLogs.log("hits", category, {
        hitman=mLogs.logger.getPlayerData(hitman),
        target=mLogs.logger.getPlayerData(target),
        customer=mLogs.logger.getPlayerData(customer),
        price=mLogs.formatMoney(amt),
        r=true
    })
end)