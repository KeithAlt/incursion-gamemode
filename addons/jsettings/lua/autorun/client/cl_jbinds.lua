jBinds = jBinds or {}
jBinds.Binds = jBinds.Binds or {}

sql.Query("CREATE TABLE IF NOT EXISTS jbinds (key INTEGER PRIMARY KEY, up TEXT, down TEXT);")

function jBinds.SaveBind(key)
	local bindInfo = jBinds.Binds[key]
	if bindInfo then
		sql.Query("DELETE FROM jbinds WHERE key = " .. key .. ";")
		sql.Query("INSERT INTO jbinds VALUES(" .. key .. ", '" .. util.TableToJSON(bindInfo.up or {}) .. "', '" ..  util.TableToJSON(bindInfo.down or {}) .. "');")
	end
end

function jBinds.LoadBinds()
	local dat = sql.Query("SELECT * FROM jbinds;")
	for i, bind in ipairs(dat) do
		local down = util.JSONToTable(bind.down)
		local up = util.JSONToTable(bind.up)

		jBinds.Binds[tonumber(bind.key)] = {
			down = (istable(down) and #down > 0) and down or nil,
			up = (istable(up) and #up > 0) and up or nil
		}
	end
end

function jBinds.TempBind(key, down, up)
	jBinds.Binds[key] = {down = down, up = up}
end

function jBinds.Bind(key, down, up)
	jBinds.TempBind(key, down, up)
	jBinds.SaveBind(key)
end

function jBinds.SetDefault(key, down, up)
	if !jBinds.LookupBinding(down, up) then
		jBinds.Bind(key, down, up)
	end
end

function jBinds.UnBind(key)
	jBinds.Binds[key] = nil
	sql.Query("DELETE FROM jbinds WHERE key = " .. key .. ";")
end

function jBinds.LookupBinding(down, up)
	return sql.QueryValue("SELECT key FROM jbinds WHERE down LIKE '" .. (util.TableToJSON(down) or "") .. "' OR up LIKE '" .. (util.TableToJSON(up) or "") .. "';")
end

hook.Add("PlayerButtonDown", "jBinds", function(ply, btn)
	local bind = jBinds.Binds[btn]
	if ply == LocalPlayer() and IsFirstTimePredicted() and bind and istable(bind.down) then
		RunConsoleCommand(unpack(bind.down))
	end
end)

hook.Add("PlayerButtonUp", "jBinds", function(ply, btn)
	local bind = jBinds.Binds[btn]
	if ply == LocalPlayer() and IsFirstTimePredicted() and bind and istable(bind.up)  then
		RunConsoleCommand(unpack(bind.up))
	end
end)

hook.Add("InitPostEntity", "jBinds", jBinds.LoadBinds)

hook.Run("jBindsInit")
