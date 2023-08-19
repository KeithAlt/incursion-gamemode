BROADCASTS = BROADCASTS or {}
BROADCASTS.Config = BROADCASTS.Config or {}

local ignoreFiles = {}
local handledFiles = {}
function BROADCASTS.MsgC(msg, isError)
	MsgC(not isError and Color(0, 255, 0) or Color(255,0,0), "[BROADCASTS] " .. msg .. "\n")
end

function BROADCASTS.LoadAllFiles(fileDir)
	local files, dirs = file.Find(fileDir .. "*", "LUA")

	for _, subFilePath in ipairs(files) do
		if (string.match(subFilePath, ".lua") and not ignoreFiles[subFilePath] and not handledFiles[fileDir .. subFilePath]) then

			local fileRealm = string.sub(subFilePath, 1, 2)
			if SERVER and fileRealm != "sv" then
				BROADCASTS.MsgC("Adding CSLuaFile File " .. fileDir .. subFilePath)
				AddCSLuaFile(fileDir .. subFilePath)
				handledFiles[fileDir .. subFilePath] = true
			end

			if CLIENT and fileRealm != "sv" then
				include(fileDir .. subFilePath)
				BROADCASTS.MsgC("Including File " .. fileDir .. subFilePath)
				handledFiles[fileDir .. subFilePath] = true
			elseif SERVER and fileRealm != "cl" then
				include(fileDir .. subFilePath)
				BROADCASTS.MsgC("Including File " .. fileDir .. subFilePath)
				handledFiles[fileDir .. subFilePath] = true
			end
		end
	end

	for _, dir in ipairs(dirs) do
		BROADCASTS.LoadAllFiles(fileDir .. dir .. "/")
	end
end

BROADCASTS.LoadAllFiles("broadcasts/sh/")
BROADCASTS.LoadAllFiles("broadcasts/")
