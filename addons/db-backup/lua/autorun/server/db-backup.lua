local remoteAuth = "KFt*%27!v%27qF`2C%27e!"
local maxBackups = 20

local function Init()
	if !file.Exists("db-backups", "DATA") then
		file.CreateDir("db-backups")
	end
end
Init()

local function OpenDB(path)
	print("Reading current DB")

	local f = file.Open(path, "rb", "GAME")
	local data = f:Read(f:Size())

	f:Close()
	return data
end

local function SaveDB(db)
	print("Saving DB")

	local files = file.Find("db-backups/*.dat", "DATA", "datedesc")
	local filename = string.format("db-backups/%s.dat", os.date("%d-%m-%yT%H-%M-%S"))

	local f = file.Open(filename, "wb", "DATA")
	f:Write(db)
	f:Close()

	while #files > (maxBackups - 1) do
		print("Deleting old backup " .. files[#files])
		file.Delete("db-backups/" .. files[#files])
		table.remove(files, #files)
	end
end

local function BackupLocal()
	local isValid = true
	local response = sql.Query("PRAGMA integrity_check;")
	if !response then
		print("DB is corrupt, refusing to backup")
		isValid = false
	end
	if !isValid then return end

	print("Backing up local DB")

	SaveDB(OpenDB("sv.db"))
	print("Successfully backed up local DB")
end

local function BackupRemote()
	print("Sending request to backup remote DB")
	if !jlib.IsDev() then
		http.Fetch("https://claymoregaming.com/backup/?auth=" .. remoteAuth, function(response)
			if response == "Backup successful" then
				print("Successfully backed up remote DB")
			else
				print("WARNING: Failed to backup remote DB: " .. response)
			end
		end, function(err)
			print("WARNING: Failed to backup remote DB: " .. err)
		end)
	else
		print("Skipping remote backup on dev server")
	end
end

local function FullBackup()
	BackupRemote()
	BackupLocal()
end

timer.Simple(0, FullBackup)
timer.Create("DBBackup", 1800, 0, FullBackup)
hook.Add("ShutDown", "DBBackup", FullBackup)
