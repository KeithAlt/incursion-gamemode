poptracker = {}

if(SERVER) then	
	function poptracker:getOffset()
		-- Simple way of keeping track of the passage of days.
		-- If the date is different than the stored date, increment offset by 1, a day passing.
		local date = tonumber(os.date("%d", os.time()))
		if(poptracker.date != date) then
			poptracker.date = date
			poptracker.offset = (poptracker.offset or 0) + 1
		end
		
		return poptracker.offset
	end
	
	-- Calculates how many hours of play the specified faction has in the timeSpan
	function poptracker:getFactionActivityReport(faction, timeSpan, callbackFunc)
		local offset = poptracker:getOffset()
	
		local queryObj = serverguard.mysql:Select("serverguard_playtime")
			queryObj:WhereGT("offset", offset - timeSpan)
			queryObj:Where("faction", faction)
			queryObj:Select("playTime")
			queryObj:Callback(function(result, status, lastID)
				local factionTime = 0
			
				if(result) then
					for k, v in pairs(result) do
						factionTime = factionTime + tonumber(v.playTime)
					end
				end
			
				callbackFunc(factionTime)
			end)
		queryObj:Execute()
		
		return response
	end
	
	-- Returns table of staff activity for the past timeSpan days
	function poptracker:getStaffActivityReport(rank, timeSpan, callbackFunc)
		local offset = poptracker:getOffset()
	
		local queryObj = serverguard.mysql:Select("serverguard_playtime")
			queryObj:Select("steamID")
			queryObj:Select("steamName")
			queryObj:Select("playTime")
			queryObj:WhereGT("offset", offset - timeSpan)
			queryObj:Where("rank", rank)
			queryObj:Callback(function(result, status, lastID)
				callbackFunc(result)
			end)
		queryObj:Execute()
	end
	
	-- Creates the tables
	function poptracker:CreateTables()
		local PLAYTIME_QUERY = serverguard.mysql:Create("serverguard_playtime")
			PLAYTIME_QUERY:Create("id", "INTEGER NOT NULL AUTO_INCREMENT")
			PLAYTIME_QUERY:Create("offset", "INT(11) NOT NULL")
			PLAYTIME_QUERY:Create("faction", "VARCHAR(255) NOT NULL")
			PLAYTIME_QUERY:Create("steamID", "VARCHAR(255) NOT NULL")
			PLAYTIME_QUERY:Create("steamName", "VARCHAR(255) NOT NULL")
			PLAYTIME_QUERY:Create("rank", "VARCHAR(255) NOT NULL")
			PLAYTIME_QUERY:Create("playTime", "INT(11) NOT NULL")
			PLAYTIME_QUERY:Create("date", "VARCHAR(255) NOT NULL")
			PLAYTIME_QUERY:PrimaryKey("id")
		PLAYTIME_QUERY:Execute()
		
		poptracker.dbInit = true
	end
	
	-- Adds an entry to the playTime table
	function poptracker:InsertTable(client, char, playTime)
		local offset = poptracker:getOffset()
	
		local faction = char:getFaction()
		local factionUID = nut.faction.indices[faction] and nut.faction.indices[faction].uniqueID or "Undefined"
		local steamID = client:SteamID()
		local name = client:GetName()
		local rank = serverguard.player:GetRank(client) or "user"
		
		local day = tonumber(os.date("%d", os.time()))
		local month = tonumber(os.date("%m", os.time()))
		local year = tonumber(os.date("%Y", os.time()))
		local date = day.. "/" ..month.. "/" ..year
	
		local insertObj = serverguard.mysql:Insert("serverguard_playtime")
			insertObj:Insert("offset", offset)
			insertObj:Insert("faction", factionUID)
			insertObj:Insert("steamID", steamID)
			insertObj:Insert("steamName", name)
			insertObj:Insert("rank", rank)
			insertObj:Insert("playTime", math.Round(playTime))
			insertObj:Insert("date", date)
		insertObj:Execute()
	end
	
	-- Deletes the playtime table, for testing/debugging purposes
	function poptracker:DeleteTable()
		serverguard.mysql:Drop("serverguard_playtime"):Execute()
	end
	
	--  prints the entire table, for debugging, but I left it in case it was useful for anything
	function poptracker:QueryTable()
		local queryObj = serverguard.mysql:Select("serverguard_playtime");
			queryObj:Callback(function(result, status, lastID)
				PrintTable(result)
				--return result
			end)
		queryObj:Execute()
	end
	
	-- Saves play time based on how long it has been since the beginning
	local function playTimeEnd(client, char)
		if(client.playTimeLog and char) then
			local playTime = (CurTime() - client.playTimeLog) / 60 -- In minutes

			poptracker:InsertTable(client, char, playTime)
		end
	end
	
	-- When a player loads a character
	local function playTimeStart(client, char, lastChar)
		--lastchar currently not working, code is also unnecessary since changing chars calls charkick
		--[[
		if(client.playTimeLog and lastChar) then
			playTimeEnd(client, lastChar)
		end
		--]]
		
		client.playTimeLog = CurTime()
	end
	
	local function SaveData()
		local data = {
			poptracker.date or 1,
			poptracker.offset or 1,
			poptracker.dbInit or false,
		}
		
		local json = util.TableToJSON(data)
		
		local path = "poptracker/poptracker.txt"
		file.Write(path, json)
	end
	
	local function LoadData()
		local path = "poptracker/"
		if(!file.Exists(path, "DATA")) then
			file.CreateDir(path)
			file.Write(path.. "poptracker.txt", "")
		end
		
		local json = file.Read(path) or ""
		local data = util.JSONToTable(json)
	
		if(data) then
			poptracker.date = tonumber(data[1])
			poptracker.offset = tonumber(data[2])
			poptracker.dbInit = data[3]
		end
		
		if(!poptracker.dbInit) then
			poptracker:CreateTables()
			
			SaveData()
		end
	end
	
	hook.Add("SaveData", "poptrackerSaveData", SaveData)
	hook.Add("LoadData", "poptrackerLoadData", LoadData)
	
	-- When a player disconnects
	local function PlayerDisconnected(client)
		playTimeEnd(client, client:getChar())
	end
	
	-- When the server shuts down, save all player's play time
	local function ShutDown(client)
		for k, client in pairs(player.GetAll()) do
			playTimeEnd(client, client:getChar())
		end
	end
	
	-- When the player loads into a character
	local function PlayerLoadedChar(client, char, lastChar)
		playTimeStart(client, char, lastChar)
	end	
	
	-- When a character is transferred to a different faction, unused but in the file in case it's used later
	local function CharacterFactionTransfered(char, oldFaction, faction)

	end
	
	-- When a character is kicked (also called when a player changes characters)
	local function OnCharKicked(client, char)
		playTimeEnd(client, char)
	end
	
	hook.Add("PlayerDisconnected", "poptrackerPlayerDisconnected", PlayerDisconnected)
	hook.Add("ShutDown", "poptrackerShutDown", ShutDown)
	hook.Add("PrePlayerLoadedChar", "poptrackerPlayerLoadedChar", PlayerLoadedChar)
	hook.Add("CharacterFactionTransfered", "poptrackerFactionTransfer", CharacterFactionTransfered)
	hook.Add("OnCharKicked", "poptrackerOnCharKicked", OnCharKicked)
end

--[[
-- Debug queries/examples
nut.command.add("playtimedb", {
	adminOnly = true,
	syntax = "",
	onRun = function(client, arguments)
		poptracker:CreateTables()
	end
})

nut.command.add("playtimeinsert", {
	adminOnly = true,
	syntax = "",
	onRun = function(client, arguments)
		poptracker:InsertTable(client, client:getChar(), math.random(1,120))
	end
})

nut.command.add("playtimedrop", {
	adminOnly = true,
	syntax = "",
	onRun = function(client, arguments)
		poptracker:DeleteTable()
		poptracker.dbInit = false
	end
})


nut.command.add("playtimequery", {
	adminOnly = true,
	syntax = "",
	onRun = function(client, arguments)
		poptracker:QueryTable()
	end
})

nut.command.add("playtimequery1", {
	adminOnly = true,
	syntax = "",
	onRun = function(client, arguments)
		poptracker:getFactionActivityReport("ncr", 10, function(results)
			print(results)
		end)
	end
})

nut.command.add("playtimequery2", {
	adminOnly = true,
	syntax = "",
	onRun = function(client, arguments)
		local response = {}
		poptracker:getStaffActivityReport("founder", 10, function(results)
			PrintTable(results)
		end)
		
		poptracker:getStaffActivityReport("founder", 9999999999999, function(response)
			print(response)
		end)

		poptracker:getFactionActivityReport("ncr", 9999999999999, function(response)
			print(response)
		end)
	end
})
--]]