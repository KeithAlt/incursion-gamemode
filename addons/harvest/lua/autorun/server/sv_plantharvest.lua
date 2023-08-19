--resource.AddWorkshop("1913338571")

util.AddNetworkString("HarvestUpdateSpawns")
util.AddNetworkString("HarvestPlantEffect")

function Harvest.Save()
	local tbl = {}

	for i, plant in ipairs(Harvest.Spawns) do
		tbl[i] = {pos = plant.pos, plantType = plant.plantType, rate = plant.rate}
	end

	file.CreateDir("harvest")
	file.CreateDir("harvest/" .. game.GetMap())
	file.Write("harvest/" .. game.GetMap() .. "/spawns.json", util.TableToJSON(tbl))
end

function Harvest.Load()
	Harvest.Spawns = util.JSONToTable(file.Read("harvest/" .. game.GetMap() .. "/spawns.json") or "[]")

	for i, plant in ipairs(Harvest.Spawns) do
		Harvest.SpawnPlant(plant)
	end
end

function Harvest.BroadcastSpawns()
	net.Start("HarvestUpdateSpawns")
		jlib.WriteCompressedTable(Harvest.Spawns)
	net.Broadcast()
end

function Harvest.AddPlant(pos, plantType, rate)
	local plant = {
		pos = pos,
		plantType = plantType,
		rate = rate
	}

	Harvest.Spawns[#Harvest.Spawns + 1] = plant
	Harvest.SpawnPlant(plant)

	Harvest.BroadcastSpawns()
	Harvest.Save()
end

function Harvest.SpawnPlant(plant)
	local ent = ents.Create("harvestableplant")
	ent.SpawnRate = plant.rate
	ent:SetPlantType(plant.plantType)
	ent:SetPos(plant.pos)
	ent:Spawn()
end

function Harvest.RemovePlant(index)
	if !index then return end

	if IsValid(Harvest.Spawns[index].Plant) then
		Harvest.Spawns[index].Plant:Remove()
	end

	table.remove(Harvest.Spawns, index)

	Harvest.BroadcastSpawns()
	Harvest.Save()
end

function Harvest.FindClosestPlant(pos)
	local dist
	local plant

	for i, p in ipairs(Harvest.Spawns) do
		local curDist = p.pos:Distance(pos)

		if !dist or curDist < dist then
			dist = curDist
			plant = i
		end
	end

	return plant, dist
end

function Harvest.RemoveClosestPlant(pos)
	local plant, dist = Harvest.FindClosestPlant(pos)

	if !plant then return end

	Harvest.RemovePlant(plant)
	return dist
end

hook.Add("PlayerInitialSpawn", "HarvestNetworkSpawns", function(ply)
	net.Start("HarvestUpdateSpawns")
		jlib.WriteCompressedTable(Harvest.Spawns)
	net.Send(ply)
end)

hook.Add("InitPostEntity", "HarvestLoad", Harvest.Load)
hook.Add("PostCleanupMap", "HarvestLoad", function()
	for i, plant in ipairs(Harvest.Spawns) do
		Harvest.SpawnPlant(plant)
	end
end)
