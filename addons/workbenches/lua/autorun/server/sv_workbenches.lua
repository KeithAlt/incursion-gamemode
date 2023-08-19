AddCSLuaFile("workbenches_config.lua")

util.AddNetworkString("WBOpenConfig")
util.AddNetworkString("WBSavePreset")
util.AddNetworkString("WBRequestPresets")
util.AddNetworkString("WBSendPresets")
util.AddNetworkString("WBDeletePreset")
util.AddNetworkString("WBConfig")
util.AddNetworkString("WBFactionAccessToggle")
util.AddNetworkString("WBRequestInv")
util.AddNetworkString("WBOpenInv")
util.AddNetworkString("WBAskClaim")
util.AddNetworkString("WBConfirmClaim")
util.AddNetworkString("StartWBClaim")
util.AddNetworkString("WBClaimStarted")
util.AddNetworkString("WBClaimHalted")
util.AddNetworkString("HaltWBClaim")
util.AddNetworkString("WBContest")
util.AddNetworkString("WBOpenRecipeMaker")
util.AddNetworkString("WBOpenRecipeManager")
util.AddNetworkString("WBAddRecipe")
util.AddNetworkString("WBDeleteRecipe")
util.AddNetworkString("WBUpdateRecipes")
util.AddNetworkString("WBSetLockpickLevel")
util.AddNetworkString("WBPlayerJoined")
util.AddNetworkString("WBTakeItem")
util.AddNetworkString("WBTakeAllItems")
util.AddNetworkString("WBSoundStart")
util.AddNetworkString("WBSoundStop")

resource.AddSingleFile("materials/enemyalert.png")

local path = "sound/workbenches/"
for i, f in ipairs(file.Find(path .. "*.wav", "GAME")) do
	resource.AddSingleFile(path .. f)
end

if !file.Exists("workbenches", "DATA") then
	file.CreateDir("workbenches")
end

/**
-- Allow players to handle workbench without 'Remove' properties access
hook.Add("PhysgunPickup", "AllowWorkbenchPickup", function(ply, ent)
	if ent:GetClass() == "workbench" and ent:getNetVar("faction") and ent:getNetVar("faction") == nut.faction.indices[ply:Team()].uniqueID and hcWhitelist.isHC(ply) then
		return true
	end

	print("AllowWorkbenchPickup")
end)
**/

function Workbenches.log(msg)
	MsgC(Color(0,255,0), "[WORKBENCH LOG] ", Color(255,255,255), msg .. "\n")
end

--Data handling
function Workbenches.LoadPresets()
	Workbenches.Presets = util.JSONToTable(file.Read("workbenches/presets.json") or "[]")
end

function Workbenches.LoadBenches()
	Workbenches.Benches = util.JSONToTable(file.Read("workbenches/benches.json") or "[]")
	print("Loading " .. #Workbenches.Benches .. " workbenches.")

	for k, options in pairs(Workbenches.Benches) do
		if !options.benchID then -- If an index lacks a unique ID
			options.benchID = #Workbenches.Benches
		end

		-- This condition exists for a wipe day utility that allows us to relocate
		-- Pre-existing workbenches to a different position for setup purposes.
		if WIPEDAY then
			options.pos = WIPEDAYPOS_WORKBENCH
		end

		if options.spawn == false then
			Workbenches.SpawnBench(options, Workbenches.Cores[options.coreID], k)
		else
			Workbenches.log("Prevented spawning of workbench[" .. (options.benchID or "NULL") .. "] due to spawn[true]")
		end
	end
end

function Workbenches.GetByID(benchID)
	Workbenches.Benches = util.JSONToTable(file.Read("workbenches/benches.json") or "[]")

	for k, data in pairs(Workbenches.Benches) do
		if k == benchID then
			table.Merge(data, {["benchID"] = k}) -- Add the ID number of the table to the data table
			return data
		end
	end

	return false
end

function Workbenches.CheckForBenchByID(benchID)
	for index, entity in pairs(ents.FindByClass("workbench")) do
		if entity.benchID == benchID then
			return true
		end
	end

	return false
end

function Workbenches.SpawnByID(ply, benchID, posOverride)
	local bench = Workbenches.GetByID(benchID) or false

	if !bench then
		ErrorNoHalt("Failed to retrieve workbench due to invalid ID arg")
		return
	end

	if !bench.spawn then
		ErrorNoHalt(jlib.SteamIDName(ply) .. " attempted to spawn workbench[" .. benchID .. "] with false set data; halting spawn")
		return false
	end

	local trace = {}
	local start = ply:EyePos()
	trace.start = start
	trace.endpos = posOverride or (start + (ply:GetAimVector() * 100)) -- NOTE: Pepega but efficient
	trace.filter = ply

	spawnPos = trace.endpos

	local effectdata = EffectData()
	effectdata:SetOrigin( trace.endpos )
	util.Effect( "flash_smoke", effectdata )

	jlib.Announce(ply, Color(255,0,0), "[REMINDER] ", Color(255,155,155), "Remember to save the position of the workbench!")
	Workbenches.SpawnBench(bench, Workbenches.Cores[bench.coreID], bench.benchID, trace.endpos, ply)
end

function Workbenches.GetFactionByID(benchID)
	local bench = Workbenches.GetByID(benchID)

	if !bench then return end
	return bench.faction or false
end

function Workbenches.GetBenchesByFaction(factionID)
	Workbenches.Benches = Workbenches.Benches or util.JSONToTable(file.Read("workbenches/benches.json") or "[]")
	local benches = {}

	for k, options in pairs(Workbenches.Benches) do
		if options.faction == factionID then
			table.Merge(options, {["benchID"] = k})
			table.insert(benches, options)
		end
	end

	return benches or false
end

function Workbenches.ChangeSpawnStateByID(benchID, boolean)
	if !isnumber(benchID) or !isbool(boolean) then return end

	for k, options in pairs(Workbenches.Benches) do
		if k == benchID then
			options.spawn = false
			Workbenches.log("CHANGED spawn state of workbench[" .. benchID .. "] to " .. tostring(boolean) .. " (manually)")
			Workbenches.SaveBenches()
			break
		end
	end
end

function Workbenches.LoadRecipes()
	Workbenches.Recipes = util.JSONToTable(file.Read("workbenches/recipes.json") or "[]")
	Workbenches.ConvertRecipeStruct()
end

function Workbenches.Load()
	Workbenches.LoadPresets()
	Workbenches.LoadBenches()
	Workbenches.LoadRecipes()
end

hook.Add("InitPostEntity", "WBLoad", Workbenches.Load)
hook.Add("PostCleanupMap", "WBLoad", Workbenches.LoadBenches)

function Workbenches.SavePresets()
	file.Write("workbenches/presets.json", util.TableToJSON(Workbenches.Presets))
	Workbenches.log("Saving presets . . .")
end

function Workbenches.SaveBenches()
	file.Write("workbenches/benches.json", util.TableToJSON(Workbenches.Benches))
	Workbenches.log("Saving benches . . .")
end

function Workbenches.SaveRecipes()
	file.Write("workbenches/recipes.json", util.TableToJSON(Workbenches.Recipes))

	net.Start("WBUpdateRecipes")
		jlib.WriteCompressedTable(Workbenches.Recipes)
	net.Broadcast()

	Workbenches.log("Saving recipes . . .")
end

--Bench setup
function Workbenches.SpawnBench(options, core, index, posOverride, ply)
	local bench = ents.Create("workbench")

	bench.benchID = index
	bench.core    = core
	bench.model   = options.model
	bench.Sound = options.sound
	bench.spawn = options.spawn

	bench:SetConfigured(true)
	bench:SetDisplay3D2D(options.display3D2D)
	bench:Set3D2DColor(options.color)
	bench:SetBenchName(options.name)
	bench:SetLockpickable(options.lockpickable)
	bench:SetCapturable(options.capturable)
	bench:setNetVar("faction", options.faction)
	bench:setNetVar("classes", options.classes)

	if options.lockpickable and options.LockpickLevel then
		bench:SetLockpickLevel(options.LockpickLevel)
	end

	core.setup(bench, options)

	bench:SetPos(posOverride or options.pos)
	bench:SetAngles(options.angles)
	//bench:DropToFloor()

	bench:Spawn()

	if IsValid(ply) then
		hook.Run("AllowWorkbenchPickup", ply, ent)
	end

	local physObj = bench:GetPhysicsObject()
	if IsValid(physObj) then
		physObj:EnableMotion(false)
	end

	return bench
end

function Workbenches.AddBench(options)
	local index = table.insert(Workbenches.Benches, options)
	Workbenches.SaveBenches()
	return index
end

function Workbenches.RemoveBench(index)
	Workbenches.Benches[index] = nil
	Workbenches.SaveBenches()
end

function Workbenches.ApplySpawnVAR() -- TODO: Remove from codebase being ran initially
	Workbenches.Benches = util.JSONToTable(file.Read("workbenches/benches.json") or "[]")
	print("Loading " .. #Workbenches.Benches .. " workbenches.")

	for k, options in pairs(Workbenches.Benches) do
		--Workbenches.SpawnBench(options, Workbenches.Cores[options.coreID], k)
		print("[WORKBENCHES] Applied spawn var to workbench[" .. k .. "]")
		options.spawn = false
	end

	Workbenches.SaveBenches()
end

net.Receive("WBConfig", function(_, ply)
	if !ply:IsSuperAdmin() then return end

	local options = jlib.ReadCompressedTable()
	local bench   = net.ReadEntity()

	local core = Workbenches.Cores[options.coreID]

	options.pos    = bench:GetPos()
	options.angles = bench:GetAngles()
	bench:Remove()

	Workbenches.SpawnBench(options, core, Workbenches.AddBench(options))
end)

--Faction Access
function Workbenches.ToggleFactionAccess()
	local bench = net.ReadEntity()

	bench:SetFactionAccess(!bench:GetFactionAccess())
end
net.Receive("WBFactionAccessToggle", Workbenches.ToggleFactionAccess)

--Presets
net.Receive("WBRequestPresets", function(len, ply)
	if !ply:IsSuperAdmin() then
		return
	end

	local ent = net.ReadEntity()

	net.Start("WBSendPresets")
		jlib.WriteCompressedTable(Workbenches.Presets)
		net.WriteEntity(ent)
	net.Send(ply)
end)

net.Receive("WBDeletePreset", function(len, ply)
	if !ply:IsSuperAdmin() then
		return
	end

	local id = net.ReadString()

	Workbenches.Presets[id] = nil
	Workbenches.SavePresets()
end)

--Inventory requests
net.Receive("WBRequestInv", function(len, ply)
	local ent = net.ReadEntity()

	if !ent:GetCapturable() or ent:HasAccess(ply) then
		ent:OpenInventory(ply)
	end
end)

--Capture mechanics
net.Receive("WBConfirmClaim", function(len, ply)
	local ent = net.ReadEntity()

	if ply:GetPos():Distance(ent:GetPos()) > 250 then return end

	ent:StartClaim(ply)
end)

--Lockpicking
hook.Add("PlayerInitialSpawn", "WBSendLockpickLevels", function(ply)
	local i = 1

	for bench, _ in pairs(Workbenches.BenchEnts) do
		if bench.LockpickLevel then
			timer.Simple(i * 0.5, function()
				net.Start("WBSetLockpickLevel")
					net.WriteEntity(bench)
					net.WriteInt(bench.LockpickLevel, 32)
				net.Send(ply)
			end)

			i = i + 1
		end
	end
end)

--Recipes
net.Receive("WBAddRecipe", function(len, ply)
	if !ply:IsSuperAdmin() then
		return
	end

	local output = net.ReadString()
	local input  = jlib.ReadCompressedTable()
	local time   = net.ReadInt(32)
	local category = net.ReadString()

	Workbenches.Recipes[category] = Workbenches.Recipes[category] or {}
	Workbenches.Recipes[category][output] = {
		ingredients = input,
		time = time
	}

	Workbenches.SaveRecipes()

	ply:notify("Successfully added recipe!")
end)

net.Receive("WBDeleteRecipe", function(len, ply)
	if !ply:IsSuperAdmin() then
		return
	end

	local output = net.ReadString()
	local category = net.ReadString()

	Workbenches.Recipes[category][output] = nil
	if table.Count(Workbenches.Recipes[category]) == 0 then
		Workbenches.Recipes[category] = nil
	end

	Workbenches.SaveRecipes()
end)

hook.Add("PlayerInitialSpawn", "WBSendRecipes", function(ply)
	net.Start("WBUpdateRecipes")
		jlib.WriteCompressedTable(Workbenches.Recipes)
	net.Send(ply)
end)

net.Receive("WBTakeItem", function(len, ply)
	local ent = net.ReadEntity()
	local uniqueID = net.ReadString()

	if ply:GetPos():Distance(ent:GetPos()) > 250 then return end

	ent:TakeItem(uniqueID, ply)
end)

net.Receive("WBTakeAllItems", function(len, ply)
	local ent = net.ReadEntity()

	if ply:GetPos():Distance(ent:GetPos()) > 250 then return end

	ent:TakeAllItems(ply)
end)

function Workbenches.ConvertRecipeStruct()
	if !file.Exists("workbenches/conversioncomplete.txt", "DATA") then
		Workbenches.Recipes = {["Default"] = table.Copy(Workbenches.Recipes)}
		Workbenches.SaveRecipes()

		file.Write("workbenches/conversioncomplete.txt", "")
	end
end

--Workbench sounds
hook.Add("PlayerInitialSpawn", "WorkbenchSounds", function(ply)
	for bench in pairs(Workbenches.BenchEnts) do
		if bench.Sound and bench.SoundPlaying then
			bench:StartBenchSound(ply)
		end
	end
end)

--Old bench conversion functions
function Workbenches.ConvertChemBenches()
	for i, ent in ipairs(ents.FindByClass("chembench")) do
		local options = {
			name = "Chem Bench",
			model = "models/mosi/fallout4/furniture/workstations/chemistrystation01.mdl",
			color = Color(255, 255, 0, 255),
			coreID = "Multicraft",
			capturable = false,
			display3D2D = true,
			lockpickable = false,
			sound = "chems-boiling.wav",
			maxCrafts = 5,
			category = "Chems",
			outputs = {},
			pos = ent:GetPos(),
			angles = ent:GetAngles()
		}

		for id, item in pairs(jChems.Chems) do
			Workbenches.Recipes.Chems = Workbenches.Recipes.Chems or {}
			Workbenches.Recipes.Chems[id] = {
				ingredients = item.recipe,
				time = item.time
			}

			Workbenches.SaveRecipes()

			options.outputs[id] = true
		end

		Workbenches.SaveRecipes()
		Workbenches.SpawnBench(options, Workbenches.Cores.Multicraft, Workbenches.AddBench(options))

		if ent.PermaProps_ID then
			PermaProps.SQL.Query("DELETE FROM permaprops WHERE id = ".. ent.PermaProps_ID ..";")
		end

		ent:Remove()
	end
end
concommand.Add("Workbenches.ConvertChemBenches", Workbenches.ConvertChemBenches)

function Workbenches.ConvertExtractors()
	for i, ent in ipairs(ents.FindByClass("loot_extractor")) do
		local options = {
			name = "Extractor",
			model = "models/ams2/crusher_machine.mdl",
			color = Color(255, 255, 0, 255),
			coreID = "Infinitecraft",
			capturable = true,
			display3D2D = true,
			lockpickable = true,
			LockpickLevel = 3,
			sound = "OBJ_Workshop_GeneratorLarge_01_LOOP.wav",
			invX = 7,
			invY = 7,
			pos = ent:GetPos(),
			angles = ent:GetAngles(),
			output = {}
		}

		for item, recipe in pairs(extractorsConfig.Items) do
			options.output[item] = recipe.time
		end

		Workbenches.SpawnBench(options, Workbenches.Cores.Infinitecraft, Workbenches.AddBench(options))

		if ent.PermaProps_ID then
			PermaProps.SQL.Query("DELETE FROM permaprops WHERE id = ".. ent.PermaProps_ID ..";")
		end

		ent:Remove()
	end
end
concommand.Add("Workbenches.ConvertExtractors", Workbenches.ConvertExtractors)

function Workbenches.ConvertReactors()
	for i, ent in ipairs(ents.FindByClass("nuclear_reactor")) do
		local options = {
			name = "Reactor",
			model = "models/props/keitho/fusiongenerator.mdl",
			color = Color(255, 255, 0, 255),
			coreID = "Singlecraft",
			capturable = true,
			display3D2D = true,
			lockpickable = true,
			LockpickLevel = 3,
			sound = "Fusion_Loop.wav",
			invX = 7,
			invY = 7,
			pos = ent:GetPos(),
			angles = ent:GetAngles(),
			input = "component_nuclear_material",
			output = "fusion_core",
			productionTime = 360,
			maxUses = 3
		}

		Workbenches.SpawnBench(options, Workbenches.Cores.Singlecraft, Workbenches.AddBench(options))

		if ent.PermaProps_ID then
			PermaProps.SQL.Query("DELETE FROM permaprops WHERE id = ".. ent.PermaProps_ID ..";")
		end

		ent:Remove()
	end
end
concommand.Add("Workbenches.ConvertReactors", Workbenches.ConvertReactors)

local oldEnts = {
	["nuclear_reactor"] = true,
	["loot_extractor"] = true,
	["chembench"] = true
}
hook.Add("PlayerSpawnSENT", "OldEntsBlacklist", function(ply, class)
	if oldEnts[class] then
		ply:notify("Stop it.")
		return false
	end
end)
