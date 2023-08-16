--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "general"
// Chat Logs
mLogs.addLogger("Chat", "chat", category)
mLogs.addHook("PlayerSay", category, function(ply,txt)
    if(not IsValid(ply))then return end
    if(string.Trim(txt) == "")then return end
    if(DarkRP and string.sub(txt,1,4) == "/ooc")then
        txt = "[OOC] " .. string.sub(txt,6)
    elseif(not mLogs.logger.getOptions(category,"chat")["show_commands"])then
        local t = string.sub(txt,1,1)
        if(t == "!" or t == "/")then return end
    end
    mLogs.log("chat", category, {player1=mLogs.logger.getPlayerData(ply),msg=txt})
end)
