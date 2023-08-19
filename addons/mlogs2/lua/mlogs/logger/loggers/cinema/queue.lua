--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "cinema"
// Queue Logs
mLogs.addLogger("Video Queue","queue",category)
mLogs.addHook("PostVideoQueued", category, function(_video,theater)
	if(not IsValid(_video:GetOwner()))then return end
    mLogs.log("queue", category, {player1=mLogs.logger.getPlayerData(_video:GetOwner()),title=_video:Title(),theater=theater:Name()})
end)