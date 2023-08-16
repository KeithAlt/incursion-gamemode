--[[
	MySQL Wrapper using mysqloo
	https://github.com/FredyH/MySQLOO
]]
require("mysqloo")

jlib.MySQL = jlib.MySQL or {}
jlib.MySQL.Print = print
hook.Add("jlibLoaded", "jMySQL", function()
	jlib.MySQL.Print = jlib.GetPrintFunction("[jMySQL]")
end)

jlib.MySQL.DefaultConnections = {
	{
		Host = "remote_db_address_here",
		Port = 3306,
		Database = "remote_db_name_here",
		User = "remote_db_username_here",
		Password = "remote_db_password_here"
	}
}
jlib.MySQL.Connections = jlib.MySQL.Connections or {}

-- DB metatable
local DB = {}
DB.__index = DB

function DB:__tostring()
	return IsValid(self) and self.Host .. ":" .. self.Port .. "(" .. self.Database .. ")" or "Invalid Connection"
end

function DB.Create(host, database, user, password, port)
	if jlib.MySQL.Connections[database] then
		// if IsValid(jlib.MySQL.Connections[database]) then
		// 	jlib.MySQL.Print("Already connected")
		// else
		// 	jlib.MySQL.Connections[database]:Connect()
		// end
		return jlib.MySQL.Connections[database]
	end

	local db = {}
	setmetatable(db, DB)
	db:Connect(host, database, user, password, port)

	jlib.MySQL.Connections[database] = db

	return db
end

function DB:Connect(host, database, user, password, port)
	port = port or 3306
	self.Host = host
	self.Port = port
	self.Database = database
	self.MySQL = self.MySQL or mysqloo.connect(host, user, password, database, port)

	function self.MySQL:onConnected()
		jlib.MySQL.Print("Successfully connected to the remote database!")
	end

	function self.MySQL:onConnectionFailed(err)
		jlib.MySQL.Print("Failed to connect to the remote database!")
		jlib.MySQL.Print("Error: ", err)
	end

	if self.MySQL:status() != mysqloo.DATABASE_CONNECTED then
		self.MySQL:connect()
	else
		jlib.MySQL.Print("Already connected")
	end
end

function DB:Query(sql, success, err, finalErr, maxRetries)
	local q = self.MySQL:query(sql)
	local retries = 0
	maxRetries = maxRetries or self:GetMaxRetries()

	function q.onSuccess(s)
		local results = {}

		while s:hasMoreResults() do
			table.insert(results, s:getData())
			s:getNextResults()
		end

		if success then
			success(unpack(results))
		end
	end

	function q.onError(s, errStr, errSql)
		jlib.MySQL.Print("Received error from " .. tostring(self))

		if errStr == "Lost connection to MySQL server during query" then
			jlib.MySQL.Print("Connection to MySQL server was lost, retrying query (" .. retries .. ")")
			if retries < maxRetries then
				q:start()

				retries = retries + 1
			else
				jlib.MySQL.Print("Aborting query after " .. retries .. " retries")
				if finalErr then
					finalErr(errStr, errSql, s)
				end
			end
		else
			jlib.MySQL.Print("Error: ", errStr)
			if finalErr then
				finalErr(errStr, errSql, s)
			end
		end

		if err then
			err(errStr, errSql, s)
		end
	end

	q:start()
end

function DB:Escape(str)
	return self.MySQL:escape(str)
end

function DB:SetMaxRetries(n)
	self.MaxRetries = n
end

function DB:GetMaxRetries()
	return self.MaxRetries or 10
end

function DB:Disconnect()
	if self.MySQL then
		self.MySQL:disconnect(true)
	end
end

function DB:IsValid()
	return self.MySQL and self.MySQL:status() == mysqloo.DATABASE_CONNECTED
end

jlib.MySQL.Meta = DB
jlib.MySQL.Create = DB.Create

function jlib.MySQL.GetConnection(id)
	return jlib.MySQL.Connections[id]
end

function jlib.MySQL.InitDBs()
	jlib.MySQL.Print("Establishing default MySQL connections")
	for i, info in ipairs(jlib.MySQL.DefaultConnections) do
		jlib.MySQL.Create(
			info.Host,
			info.Database,
			info.User,
			info.Password,
			info.Port
		)
	end

	hook.Run("jMySQLReady")
end

hook.Add("Initialize", "jMySQL", jlib.MySQL.InitDBs)
