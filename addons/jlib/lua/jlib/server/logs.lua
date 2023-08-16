jlib.logs = jlib.logs or {}

util.AddNetworkString("jSendLogs")
util.AddNetworkString("jRequestPage")

function jlib.logs.GetTableName(table)
	return "jlogs_" .. table
end

function jlib.logs.CreateLog(table, columns)
	table = jlib.logs.GetTableName(table)

	if sql.TableExists(table) then
		return false, "Table already exists."
	end

	local query = "CREATE TABLE IF NOT EXISTS " .. SQLStr(table) .. " (id INTEGER PRIMARY KEY AUTOINCREMENT, "
	for _, name in ipairs(columns) do
		if isstring(name) then
			query = query .. SQLStr(name) .. " BLOB, "
		end
	end
	query = query .. "Time INTEGER);"

	local result = sql.Query(query)

	if result == false then
		return result, sql.LastError()
	else
		return result
	end
end

function jlib.logs.Add(table, values)
	table = jlib.logs.GetTableName(table)

	if !sql.TableExists(table) then
		return false, "Table does not exist."
	end

	local columns = sql.Query("PRAGMA table_info(" .. SQLStr(table) .. ");")

	local query = "INSERT INTO " .. SQLStr(table) .. " ("

	for _, column in ipairs(columns) do
		if tonumber(column.pk) == 1 then continue end

		query = query .. SQLStr(column.name) .. ", "
	end

	query = query:Left(#query - 2) .. ") VALUES("

	for _, value in ipairs(values) do
		query = query .. SQLStr(value) .. ", "
	end
	query = query .. os.time() .. ");"

	local result = sql.Query(query)

	if result == false then
		return result, sql.LastError()
	else
		return result
	end
end

function jlib.logs.RemoveTable(table)
	table = jlib.logs.GetTableName(table)

	if sql.TableExists(table) then
		sql.Query("DROP TABLE " .. SQLStr(table) .. ";")
	else
		return false, "Table does not exist."
	end
end

function jlib.logs.ReadLogs(table, amt, page, cond)
	table = jlib.logs.GetTableName(table)

	if !sql.TableExists(table) then
		return false, "Table does not exist."
	end

	local result = sql.Query("SELECT * FROM " .. SQLStr(table, true) .. (cond and (" WHERE " .. cond) or "") .. " ORDER BY Time DESC" .. (amt and (" LIMIT " .. amt .. " OFFSET " .. (((page or 1) - 1) * amt)) or "") .. ";")

	if result == false then
		return result, sql.LastError()
	end

	local columns = sql.Query("PRAGMA table_info(" .. SQLStr(table) .. ");")

	local logs = {}
	logs.logTypes = {}
	local logTypeDict = {}

	for _, column in ipairs(columns) do
		if tonumber(column.pk) == 1 then continue end

		logs.logTypes[#logs.logTypes + 1] = column.name
		logTypeDict[column.name] = tonumber(column.cid)
	end

	for id, logEntry in ipairs(result or {}) do
		logs[id] = {}
		for k, value in pairs(logEntry) do
			if logTypeDict[k] then
				logs[id][logTypeDict[k]] = value
			end
		end
	end

	return logs
end

function jlib.logs.SendLogs(table, ply, amt, page, cond)
	local logs, err = jlib.logs.ReadLogs(table, amt, page, cond)

	if !logs then
		print(err)
	end

	if #logs <= 0 then
		ply:falloutNotify("No more logs to load.")
		return
	end

	net.Start("jSendLogs")
		jlib.WriteCompressedTable(logs)
		net.WriteString(table)
		net.WriteInt(amt, 32)
	net.Send(ply)
end

jlib.logs.AuthFuncs = jlib.logs.AuthFuncs or {}
jlib.logs.CondFuncs = jlib.logs.CondFuncs or {}

function jlib.logs.IsAuthed(table, ply)
	return jlib.logs.AuthFuncs[table] and jlib.logs.AuthFuncs[table](ply) or false
end

function jlib.logs.GetCond(table, ply)
	return jlib.logs.CondFuncs[table] and jlib.logs.CondFuncs[table](ply) or nil
end

net.Receive("jRequestPage", function(len, ply)
	local table = net.ReadString(table)

	if jlib.logs.IsAuthed(table, ply) or ply:IsSuperAdmin() then
		local page = net.ReadInt(32)
		local amt = net.ReadInt(32)

		jlib.logs.SendLogs(table, ply, amt, page, jlib.logs.GetCond(table, ply))
	end
end)
