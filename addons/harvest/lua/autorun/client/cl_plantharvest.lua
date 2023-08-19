surface.CreateFont("PlantPlacer", {font = "Roboto", size = 24})

net.Receive("HarvestUpdateSpawns", function()
	Harvest.Spawns = jlib.ReadCompressedTable()
end)

net.Receive("HarvestPlantEffect", function()
	local id = net.ReadString()
	Harvest.Plants[id].Effect(LocalPlayer())
end)
