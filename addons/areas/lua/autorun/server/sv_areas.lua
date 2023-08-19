Areas = Areas or {}

util.AddNetworkString("AreasInstance")
util.AddNetworkString("AreasPlayerJoin")
util.AddNetworkString("AreasAddPlayer")
util.AddNetworkString("AreasRemovePlayer")
util.AddNetworkString("AreasSetName")
util.AddNetworkString("AreasSetBounds")
util.AddNetworkString("AreasRemove")
util.AddNetworkString("AreasSetFac")
util.AddNetworkString("AreasDrawCaptureBar")

--Data functions
function Areas.DataInit()
	if !file.IsDir("areas", "DATA") then
		file.CreateDir("areas")
	end
end

hook.Add("Initialize", "AreasDataInit", Areas.DataInit)

function Areas.SaveAreas()
	local map = game.GetMap()

	file.Write("areas/" .. map .. ".json", util.TableToJSON(Areas.Instances))
	Areas.Print("Saved areas for " .. map .. ".")
end

function Areas.LoadAreas()
	local map = game.GetMap()

	local areas = util.JSONToTable(file.Read("areas/" .. map .. ".json") or "[]")

	for k, area in pairs(areas) do
		setmetatable(area, Areas.Meta)
		area:Init()
	end

	Areas.Print("Loaded areas for " .. map .. ".")
end
hook.Add("Initialize", "AreasLoad", Areas.LoadAreas)

--Network area instances to a player when they join
hook.Add("PlayerInitialSpawn", "AreasNetwork", function(ply)
	net.Start("AreasPlayerJoin")
		jlib.WriteCompressedTable(Areas.Instances)
	net.Send(ply)
end)
