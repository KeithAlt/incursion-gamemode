MsgC(Color(255,0,0), "[DATABASE BACKUP SYSTEM] ", Color(255,255,255), "Refreshing lua...\n")

// General configuration vars
dataSnapshot = dataSnapshot || {}
dataSnapshot.config = dataSnapshot.config || {}

dataSnapshot.config.backupPath = "snapshots"
dataSnapshot.config.backupLimit = 10 // How many backups will we allow to exist?
dataSnapshot.config.backupFreq = 5 // 	How frequently (in hours) will we perform a snap?

// Target directories to clone
dataSnapshot.config.targetDirs = {
	"nutscript/fallout/",
	"broadcasts",
	"workbenches",
	"entity-vault",
}

// Target files to clone
dataSnapshot.config.targetFiles = {}

// Log our events
function dataSnapshot.log(msg)
	MsgC(Color(0,255,0), "[SNAPSHOT LOG] ", Color(255,255,255), msg .. "\n")
end

// Verify our root backup path exists
local function verifyPaths()
	local pathsExist = file.IsDir(dataSnapshot.config.backupPath, "DATA")

	if !pathsExist then
		file.CreateDir(dataSnapshot.config.backupPath)
		dataSnapshot.log("Missing root backup path; creating")
	else
		dataSnapshot.log("Root backup path verified")
	end
end

local function deleteDirectory(path)
	dataSnapshot.log("Attempting to delete dir: " .. path)
	local files, dirs = file.Find(path .. "/*", "DATA")
	local dirPath = path .. "/"

	for i, f in pairs(files) do
		file.Delete(dirPath .. f)
	end

	for i, d in pairs(dirs) do
		deleteDirectory(path .. "/" .. d)
		file.Delete(path .. d)
	end

	file.Delete(path)
end

// Cleanup snapshots we no longer need
local function cleanupSnapshots()
	local _, dirs = file.Find(dataSnapshot.config.backupPath .. "/*", "DATA")
	local dirPath = dataSnapshot.config.backupPath .. "/"

	if (#dirs) < dataSnapshot.config.backupLimit + 1 then
		dataSnapshot.log("Cleanup limit is currently met")
		return
	end

	dataSnapshot.log("Snapshot backups exceed tolerated limit (of " .. dataSnapshot.config.backupLimit .. "); Cleaning...")
	local targetDir = dirPath .. dirs[1]
	deleteDirectory(targetDir)
end


// Get a formatted date string
local function getDateFMT()
	local date_table = os.date("*t")
	local hour = date_table.hour
	local year, month, day = date_table.year, date_table.month, date_table.day
	return month .. "-" .. day .. "-" .. year .. "@" .. hour .. "h"
end

// Create a snapshot directory
local function createDirFMT()
	local _, dirs = file.Find(dataSnapshot.config.backupPath .. "/*", "DATA")
	local isAboveLimit = #dirs > dataSnapshot.config.backupLimit

	if isAboveLimit then
		PrintTable(dirs)
		dataSnapshot.log("We are above our snapshot limit")
	end

	local dirName = getDateFMT()
	local newDir = dataSnapshot.config.backupPath .. "/" .. dirName

	if !table.HasValue(dirs, dirName) then
		file.CreateDir(newDir)
		dataSnapshot.log("Created new snapshot dir: " .. dirName)
	else
		dataSnapshot.log("Directory by name of: " .. dirName .. " already exists")
	end

	return newDir
end

// Clones a target file
local function cloneFile(targetFile, targetFilePath, cloneDir)
	local fullPath = targetFilePath .. "/" .. targetFile
	dataSnapshot.log("Attempting to file clone: " .. fullPath)
	local isValidFile = file.Exists(fullPath, "DATA")
	local isValidCloneDir = file.IsDir(cloneDir, "DATA")

	if !isValidCloneDir then
		file.CreateDir(cloneDir)
		dataSnapshot.log("Failed to verify existence of: " .. cloneDir .. " dir; creating...")
	end

	if !isValidFile then
		dataSnapshot.log("Error Information:\n- targetFilePath: " ..
			tostring(targetFilePath) ..
			"\n- targetFile: " ..
			tostring(targetFile) ..
			"\n- cloneDir: " ..
			tostring(cloneDir) ..
			"\n- isValidFile: " ..
			tostring(isValidFile) ..
			"\n- isValidCloneDir: " ..
			tostring(isValidCloneDir)
		)
		ErrorNoHalt("Cannot verify file integrity to clone")
		return
	end

	local fileContents = file.AsyncRead(fullPath, "DATA", function(fileName, gamPath, status, data)
		if status == FSASYNC_ERR then
			ErrorNoHalt("Async read status for: " .. fileName .. " failed")
			return
		end

		file.Write(cloneDir .. "/" .. targetFile, data)
		dataSnapshot.log("Successfully file cloned '" .. fileName .. "' to '" .. cloneDir .. "'")
	end, true)

	return fileContents
end

// Clone a target directory
local function cloneDirectory(inputDir)
	if !file.IsDir(inputDir, "DATA") then
		ErrorNoHalt("failed to clone dirPath of: " .. inputDir)
		return
	end

	local outputDir = createDirFMT()
	local files, dirs = file.Find(inputDir .. "/*", "DATA")

	dataSnapshot.log("Attempting to dir clone: " .. inputDir)
	local fullOutputDir = outputDir .. "/" .. inputDir

	for i, d in pairs(dirs) do
		file.CreateDir(fullOutputDir .. "/" .. d)
		dataSnapshot.log("Successfully created clone dir: " .. outputDir .. "/" .. d)
		cloneDirectory(inputDir .. "/" .. d)
	end

	for i, f in pairs(files) do
		cloneFile(f, inputDir, fullOutputDir)
	end

	dataSnapshot.log("Successfully dir cloned '" .. inputDir .. "' to '" .. outputDir .. "'")
end

// Create a snapshot
local function createSnapshot()
	dataSnapshot.log("Starting data snapshot...")

	local targetDirs = dataSnapshot.config.targetDirs
	local targetFiles = dataSnapshot.config.targetFiles

	for i, _ in pairs(targetDirs) do
		cloneDirectory(targetDirs[i])
	end

	for i, _ in pairs(targetFiles) do
		cloneFile(targetFiles[i])
	end
	dataSnapshot.log("Finished data snapshot")
end

// Start a new snapshot process
function dataSnapshot.start()
	createSnapshot()
	cleanupSnapshots()
end

// Init our system
function dataSnapshot.Init()
	dataSnapshot.log("Initalizing data snapshot system")
	verifyPaths()
	timer.Create("snapshot_timer", (dataSnapshot.config.backupFreq * 3600) + 15, 0, dataSnapshot.start)
end

hook.Add("InitPostEntity", "SnapshotInit", dataSnapshot.Init())
