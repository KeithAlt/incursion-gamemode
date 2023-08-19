--[[
	© 2018 Thriving Ventures AB do not share, re-distribute or modify
	
	without permission of its author (gustaf@thrivingventures.com).
]]

local plugin = plugin;
plugin.reports = plugin.reports or {};

plugin:IncludeFile("shared.lua", SERVERGUARD.STATE.SHARED);
plugin:IncludeFile("sh_commands.lua", SERVERGUARD.STATE.SHARED);
plugin:IncludeFile("cl_panel.lua", SERVERGUARD.STATE.CLIENT);

plugin:Hook("serverguard.mysql.CreateTables", "serverguard.reports.CreateTables", function()
	local REPORTS_TABLE_QUERY = serverguard.mysql:Create("serverguard_reports");
		REPORTS_TABLE_QUERY:Create("id", "INTEGER NOT NULL AUTO_INCREMENT");
		REPORTS_TABLE_QUERY:Create("name", "VARCHAR(255) NOT NULL");
		REPORTS_TABLE_QUERY:Create("steamID", "VARCHAR(255) DEFAULT \"Unknown\" NOT NULL");
		REPORTS_TABLE_QUERY:Create("text", "TEXT NOT NULL");
		REPORTS_TABLE_QUERY:Create("time", "INT(11) NOT NULL");
		REPORTS_TABLE_QUERY:PrimaryKey("id");
	REPORTS_TABLE_QUERY:Execute();
end);

hook.Add("serverguard.PostUpdate", "serverguard.reports.PostUpdate", function(version) -- we want this to run regardless of whether or not the plugin is enabled
	if (version and util.ToNumber(string.gsub(version, "%.", "")) < 150) then
		plugin.queueUpdate = true;
	end;
end);

hook.Add("serverguard.mysql.OnConnected", "serverguard.reports.OnConnectedUpdate", function()
	if (!plugin.queueUpdate) then
		return;
	end;

	--[[	
	local ALTER_QUERY = serverguard.mysql.Push("ALTER", "serverguard_reports");
		ALTER_QUERY:AddSyntax("ADD");
		ALTER_QUERY:AddValue("steamID VARCHAR(255) DEFAULT \"Unknown\" NOT NULL");
	serverguard.mysql.Pop();
	--]]
end);

plugin:Hook("serverguard.mysql.OnConnected", "serverguard.reports.OnConnected", function()	
	local queryObj = serverguard.mysql:Select("serverguard_reports");
		queryObj:Callback(function(result, status, lastID)
			if (type(result) == "table" and #result > 0) then
				for k, v in pairs(result) do
					table.insert(plugin.reports, {
						id = v.id, name = v.name, steamID = v.steamID, text = v.text, time = v.time
					});
				end;
			end;
		end);
	queryObj:Execute();
end);

plugin:Hook("PlayerSay", "reports.PlayerSay", function(player, text, bTeam)
	if (text[1] == "@") then
		text = text:sub(2);

		if (#text != 0) then
			serverguard.netstream.GetStored()["sgSendReport"][1](player, text);
			serverguard.Notify(player, SGPF("report_received", player:Name(), text));
		end;
		
		return ""
	end
end);

local function SendReportChunk(player)
	if (#player.sgReportChunks >= 1) then
		local chunk = player.sgReportChunks[1];

		serverguard.netstream.Start(player, "sgSendReportChunk", {
			id = chunk.id, name = chunk.name, steamID = chunk.steamID, text = chunk.text, time = tonumber(chunk.time)
		});

		table.remove(player.sgReportChunks, 1);
	end;
end;

serverguard.netstream.Hook("sgRequestReports", function(player, data)
	if (serverguard.player:HasPermission(player, "Manage Reports")) then
		if (!player.sgReportChunks) then
			player.sgReportChunks = {};
		end;

		player.sgReportChunks = table.Copy(plugin.reports);

		SendReportChunk(player);
	end;
end);

serverguard.netstream.Hook("sgRequestReportChunk", function(player, data)
	if (serverguard.player:HasPermission(player, "Manage Reports")) then
		SendReportChunk(player);
	end;
end);

serverguard.netstream.Hook("sgRemoveReport", function(player, data)
	if (serverguard.player:HasPermission(player, "Manage Reports")) then
		local id = data;
		
		for k, v in pairs(plugin.reports) do
			if (v.id == id) then
				table.remove(plugin.reports, k);
			end;
		end;

		local deleteObj = serverguard.mysql:Delete("serverguard_reports");
			deleteObj:Where("id", id);
		deleteObj:Execute();
	end;
end);

serverguard.netstream.Hook("sgRequestRemoveAllReports", function(player, data)
	if (serverguard.player:HasPermission(player, "Delete All Reports")) then
		plugin.reports = {};

		serverguard.mysql:Delete("serverguard_reports"):Execute();

		serverguard.netstream.Start(player, "sgRemoveAllReports", true);
	end;
end);

serverguard.netstream.Hook("sgSendReport", function(pPlayer, data)
	local rawText = data;
	local text = string.gsub(rawText, "\n", " ");
	local playerName = pPlayer:Nick();
	local playerSteamID = pPlayer:SteamID();
	local reportTime = os.time();

	if (string.len(text) > 256) then
		text = string.sub(text, 1, 253) .. "...";
	end

	for k, v in ipairs(player.GetAll()) do
		if (serverguard.player:HasPermission(v, "Manage Reports") and v != pPlayer) then
			serverguard.Notify(v, SGPF("report_received", pPlayer:Name(), text));
		end;
	end;

	local insertCallback = function(result)
		local queryObj = serverguard.mysql:Select("serverguard_reports");
			queryObj:Where("name", playerName);
			queryObj:Where("steamID", playerSteamID);
			queryObj:Where("time", reportTime);
			queryObj:Callback(function(result, status, lastID)
				if (type(result) == "table" and #result > 0) then
					table.insert(plugin.reports, {
						id = result[1].id, name = result[1].name, steamID = result[1].steamID, text = result[1].text, time = result[1].time
					});
				end;
			end);
		queryObj:Execute();
	end;

	local insertObj = serverguard.mysql:Insert("serverguard_reports");
		insertObj:Insert("name", playerName);
		insertObj:Insert("steamID", playerSteamID);
		insertObj:Insert("text", rawText);
		insertObj:Insert("time", reportTime);
		insertObj:Callback(insertCallback);
	insertObj:Execute();
end);