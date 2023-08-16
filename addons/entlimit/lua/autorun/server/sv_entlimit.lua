--[[
	EntLimit
	Forces a map cleanup if the total number of entities exceeds a defined limit
	Author: jonjo
]]

EntLimit = EntLimit or {}
EntLimit.Limit = 7500
EntLimit.EntCount = EntLimit.EntCount or 0

function EntLimit.Announce(str)
	ServerLog(str .. "\n")
	jlib.Announce(player.GetAll(), Color(255, 0, 0, 255), "[Entity Limit] ", Color(255, 130, 0, 255), str)
end

function EntLimit.Cleanup()
	game.CleanUpMap()
	EntLimit.Announce("Map has been cleaned up due to the entity limit being reached.")
	EntLimit.SaveLog()
end

hook.Add("OnEntityCreated", "EntLimit", function()
	EntLimit.EntCount = EntLimit.EntCount + 1

	if EntLimit.EntCount > EntLimit.Limit then
		EntLimit.Cleanup()
	end
end)

hook.Add("EntityRemoved", "EntLimit", function()
	EntLimit.EntCount = EntLimit.EntCount - 1
end)

-- Entity creation logging
EntLimit.LogLimit = 100
EntLimit.LogPath = "entlogs"
EntLimit.Log = EntLimit.Log or {}

hook.Add("Initialize", "jEntLog", function()
	if !file.IsDir(EntLimit.LogPath, "DATA") then
		file.CreateDir(EntLimit.LogPath)
	end
end)

hook.Add("OnEntityCreated", "jEntLog", function(ent)
	local log = {IsValid(ent) and ent:GetClass() or tostring(ent), debug.traceback()}
	table.insert(EntLimit.Log, log)
	if #EntLimit.Log > EntLimit.LogLimit then
		table.remove(EntLimit.Log, 1)
	end
end)

-- Save the most recent entity creations to disk
function EntLimit.SaveLog()
	local filePath = EntLimit.LogPath .. "/" .. os.time() .. ".txt"
	local fileContents = ""

	for i, log in ipairs(EntLimit.Log) do
		fileContents = fileContents .. "Entity Class: " .. log[1] .. "\n" .. "Stack trace: " .. log[2] .. "\n\n"
	end

	file.Write(filePath, fileContents)

	EntLimit.Log = {}
end
