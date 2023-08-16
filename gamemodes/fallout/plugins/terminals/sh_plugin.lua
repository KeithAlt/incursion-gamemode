local PLUGIN = PLUGIN
PLUGIN.name = "Terminals"
PLUGIN.author = "Xenikay & SuperMicronde"
PLUGIN.desc = "Modified version of Terminal R for NutScript"

TerminalR = TerminalR or {}
TerminalR.DiskData = TerminalR.DiskData or {}

--grabs all of the character's favorited disks
function PLUGIN:getFavoriteDisk(client)
	local char = client:getChar()
	if(!char) then return end

	local path = "nutscript/"..SCHEMA.folder.."/disk_data/" ..char:getID().. ".txt"
	local status, decoded = pcall(pon.decode, file.Read(path, "DATA"))

	if(istable(decoded)) then
		return decoded
	else
		return {}
	end
end

--grabs all of the character's favorited disks
function PLUGIN:favoriteAdd(Info)
	local client = LocalPlayer()

    local char = client:getChar()
    if (!char) then return end
	
	local favorites = PLUGIN:getFavoriteDisk(client)
	
	--add the disk to favorites
	favorites[#favorites+1] = {
		text = Info.text,
		title = Info.title, 
		author = Info.author,
		editor = Info.editor,
		printer = Info.printer,
		encrypt = Info.encrypt,
		pass = Info.pass
	}
	
	PLUGIN:updateFavorites(char, favorites)
end

--grabs all of the character's favorited disks
function PLUGIN:favoriteRemove(InfoID)
	local client = LocalPlayer()

    local char = client:getChar()
    if (!char) then return end
	
	local favorites = PLUGIN:getFavoriteDisk(client)
	table.remove(favorites, InfoID)
	
	PLUGIN:updateFavorites(char, favorites)
end

function PLUGIN:updateFavorites(char, favorites)
	local path = "nutscript/"..SCHEMA.folder.."/disk_data/"--char" ..char:getID().. ".txt"
	
	if(!file.Exists(path, "DATA")) then
		file.CreateDir("nutscript/"..SCHEMA.folder.."/disk_data/")
	end
    
    file.Write(path..char:getID().. ".txt", pon.encode(favorites))
end

if (CLIENT) then
	TerminalR.Version = "00002"
	TerminalR.Programs = {}
end

if (SERVER) then
	TerminalR.Save = {}
	TerminalR.NextSave = CurTime() + 240
end

local dir = PLUGIN.folder.."/"

local files, directories = file.Find(dir.."terminalr/*", "LUA")
for k , v in pairs (files) do
	if (SERVER) then
		if (string.sub(v, 1, 3) == "cl_") then
			AddCSLuaFile("terminalr/" ..v)
		elseif (string.sub(v, 1, 3) == "sv_") then
			include("terminalr/" ..v)
		elseif (string.sub(v, 1, 3) == "sh_") then
			AddCSLuaFile("terminalr/" ..v)
			include("terminalr/" ..v)
		end
	end
	
	if (CLIENT) then
		include("terminalr/" .. v)
	end
end

local files, directories = file.Find(dir.."terminalr/programs/*", "LUA")
for k , v in pairs(files) do
	MsgC(Color(0, 255, 0), "[Terminal] Program added : " ..v.."\n")
	
	if (SERVER) then
		AddCSLuaFile("terminalr/programs/" ..v)
	end
	
	if (CLIENT) then
		include("terminalr/programs/" ..v)
	end
end

nut.util.include("cl_plugin.lua")
nut.util.include("sv_plugin.lua")