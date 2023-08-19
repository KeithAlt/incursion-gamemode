--[[
	A collection of simple, commonly used functions by jonjo
]]

jlib = jlib or {}

if SERVER then
	for _, fileName in pairs(file.Find("jlib/server/*.lua", "LUA")) do
		include("jlib/server/" .. fileName)
	end

	for _, fileName in pairs(file.Find("jlib/shared/*.lua", "LUA")) do
		AddCSLuaFile("jlib/shared/" .. fileName)
	end

	for _, fileName in pairs(file.Find("jlib/client/*.lua", "LUA")) do
		AddCSLuaFile("jlib/client/" .. fileName)
	end
end

if CLIENT then
	for _, fileName in pairs(file.Find("jlib/client/*.lua", "LUA")) do
		include("jlib/client/" .. fileName)
	end
end

for _, fileName in pairs(file.Find("jlib/shared/*.lua", "LUA")) do
	include("jlib/shared/" .. fileName)
end

jlib.Print("jlib loaded")
hook.Run("jlibLoaded")
