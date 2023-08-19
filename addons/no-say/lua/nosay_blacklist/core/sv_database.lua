-- Setup
if noSayBlacklist.Database.UseMySQL then
	require("mysqloo")
end

function noSayBlacklist.Database.Connect()
	if noSayBlacklist.Database.UseMySQL then
		if noSayBlacklist.Database.Connection then
			return
		end

		noSayBlacklist.Database.Connection = mysqloo.connect(noSayBlacklist.Database.Creds.ip, noSayBlacklist.Database.Creds.user, noSayBlacklist.Database.Creds.password, noSayBlacklist.Database.Creds.database, noSayBlacklist.Database.Creds.port)
		noSayBlacklist.Database.Connection.onConnected = function()
			print("=========================")
			print("NoSay database connected")
			print("=========================")
			print("Checking and creating the following tables:")

			print(noSayBlacklist.Database.Identity.."_settings")
			noSayBlacklist.Database.Query("CREATE TABLE IF NOT EXISTS "..noSayBlacklist.Database.Identity.."_settings(setting VARCHAR(64) NOT NULL PRIMARY KEY, value TEXT NOT NULL)")
			for k, v in pairs(noSayBlacklist.Core.Settings) do
				noSayBlacklist.Database.Query(string.format("INSERT INTO "..noSayBlacklist.Database.Identity.."_settings VALUES('%s', '%s')", v.setting, v.value))
			end 

			print(noSayBlacklist.Database.Identity.."_words")
			noSayBlacklist.Database.Query("CREATE TABLE IF NOT EXISTS "..noSayBlacklist.Database.Identity.."_words(word VARCHAR(64) NOT NULL PRIMARY KEY, `replace` VARCHAR(64) NOT NULL)")

			print(noSayBlacklist.Database.Identity.."_strikes")
			noSayBlacklist.Database.Query("CREATE TABLE IF NOT EXISTS "..noSayBlacklist.Database.Identity.."_strikes(userid VARCHAR(64), word VARCHAR(64) NOT NULL, date INTEGER(64) NOT NULL)")
		
		end
		noSayBlacklist.Database.Connection.onConnectionFailed = function(db, sqlerror)
			print("=========================")
			print("NoSay database failed:")

			for i = 1, 10 do
				print(sqlerror)
			end

			print("=========================")
		end

		noSayBlacklist.Database.Connection:connect()
	else
		print("=====================")
		print("NoSay database setup")
		print("=====================")
		print("Checking and creating the following tables:")
		noSayBlacklist.Database.Identity = "nosay"

		print(noSayBlacklist.Database.Identity.."_settings")
		if not sql.TableExists(noSayBlacklist.Database.Identity.."_settings") then
			noSayBlacklist.Database.Query("CREATE TABLE "..noSayBlacklist.Database.Identity.."_settings(setting VARCHAR(64) NOT NULL PRIMARY KEY, value TEXT NOT NULL)")
			for k, v in pairs(noSayBlacklist.Core.Settings) do
				noSayBlacklist.Database.Query(string.format("INSERT INTO "..noSayBlacklist.Database.Identity.."_settings VALUES('%s', '%s')", v.setting, v.value))
			end 
		end

		print(noSayBlacklist.Database.Identity.."_words")
		if not sql.TableExists(noSayBlacklist.Database.Identity.."_words") then
			noSayBlacklist.Database.Query("CREATE TABLE "..noSayBlacklist.Database.Identity.."_words(word VARCHAR(64) NOT NULL PRIMARY KEY, replace VARCHAR(64) NOT NULL)")
				noSayBlacklist.Database.Query("INSERT INTO "..noSayBlacklist.Database.Identity.."_words VALUES('frick', 'poop')")
				noSayBlacklist.Database.Query("INSERT INTO "..noSayBlacklist.Database.Identity.."_words VALUES('heck', '')")
				noSayBlacklist.Database.AddWord("frick", "poop")
				noSayBlacklist.Database.AddWord("heck")
		end

		print(noSayBlacklist.Database.Identity.."_strikes")
		if not sql.TableExists(noSayBlacklist.Database.Identity.."_strikes") then
			noSayBlacklist.Database.Query("CREATE TABLE "..noSayBlacklist.Database.Identity.."_strikes(userid VARCHAR(64), word VARCHAR(64) NOT NULL, date INTEGER(64) NOT NULL)")
		end
	end
end

hook.Add("Initialize", "noSayBlacklistLoadDatabase", function()
	noSayBlacklist.Database.Connect()
end)

function noSayBlacklist.Database.Query(q, callback)
	if noSayBlacklist.Database.UseMySQL then
		local query = noSayBlacklist.Database.Connection:query(q)

		query.onSuccess = function(q, data)
			if callback then
				callback(data, q)
			end
		end

		query:start()
	else
		local query = sql.Query(q)
		if callback then
			callback(query)
		end
	end
end

function noSayBlacklist.Database.Escape(str)
	if noSayBlacklist.Database.UseMySQL then
		return noSayBlacklist.Database.Connection:escape(tostring(str))
	else
		return sql.SQLStr(tostring(str), true)
	end
end

function noSayBlacklist.Database.UpdateSetting(setting, value)
	noSayBlacklist.Database.Query(string.format("UPDATE nosay_settings SET value='%s' WHERE setting='%s'", noSayBlacklist.Database.Escape(value), noSayBlacklist.Database.Escape(setting)))
end

function noSayBlacklist.Database.AddWord(word, replace)
	if replace then
		replace = string.lower(replace)
	end
	noSayBlacklist.Database.Query(string.format("INSERT INTO nosay_words VALUES('%s', '%s')", noSayBlacklist.Database.Escape(string.lower(word)), noSayBlacklist.Database.Escape(replace or "")))
end

function noSayBlacklist.Database.RemoveWord(word)
	noSayBlacklist.Database.Query(string.format("DELETE FROM nosay_words WHERE word='%s'", noSayBlacklist.Database.Escape(word)))
end

function noSayBlacklist.Database.IssueStrike(ply, word)
	noSayBlacklist.Database.Query(string.format("INSERT INTO nosay_strikes VALUES('%s', '%s', %i)", ply:SteamID64(), noSayBlacklist.Database.Escape(word), os.time()))
end

function noSayBlacklist.Database.RemoveStrike(id, word, time)
	noSayBlacklist.Database.Query(string.format("DELETE FROM nosay_strikes WHERE userid='%s' AND word='%s' AND date=%i", noSayBlacklist.Database.Escape(id), noSayBlacklist.Database.Escape(word), noSayBlacklist.Database.Escape(time)))
end

function noSayBlacklist.Database.GetStrikesByID(id, callback)
	noSayBlacklist.Database.Query(string.format("SELECT * FROM nosay_strikes WHERE userid='%s'", noSayBlacklist.Database.Escape(id)), callback)
end 
function noSayBlacklist.Database.GetSettings(callback)
	noSayBlacklist.Database.Query("SELECT * FROM nosay_settings", callback)
end 
function noSayBlacklist.Database.GetWords(callback)
	noSayBlacklist.Database.Query("SELECT * FROM nosay_words", callback)
end 