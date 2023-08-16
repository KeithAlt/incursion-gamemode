noSayBlacklist = {}
noSayBlacklist.Database = {}
noSayBlacklist.Config = {}
noSayBlacklist.Translate = {}
noSayBlacklist.Core = {}
noSayBlacklist.UI = {}

function noSayBlacklist.Core.Print(...)
	local args = {...}
	table.insert(args, 1, Color(150, 255, 255))
	table.insert(args, 2, "[NoSay] ")
	table.insert(args, 3, Color(255, 255, 255, 255))
	MsgC(unpack(args))
	MsgC("\n")
end

noSayBlacklist.Core.Print("Loading noSay Blacklist")

local path = "nosay_blacklist/"
if SERVER then
	local files, folders = file.Find(path .. "*", "LUA")

	for _, folder in SortedPairs(folders, true) do
		noSayBlacklist.Core.Print("Loading folder: ", folder)
	    for b, File in SortedPairs(file.Find(path .. folder .. "/sh_*.lua", "LUA"), true) do
	    	noSayBlacklist.Core.Print("    ", File)
	        AddCSLuaFile(path .. folder .. "/" .. File)
	        include(path .. folder .. "/" .. File)
	    end

	    for b, File in SortedPairs(file.Find(path .. folder .. "/sv_*.lua", "LUA"), true) do
	    	noSayBlacklist.Core.Print("    ", File)
	        include(path .. folder .. "/" .. File)
	    end

	    for b, File in SortedPairs(file.Find(path .. folder .. "/cl_*.lua", "LUA"), true) do
	    	noSayBlacklist.Core.Print("    ", File)
	        AddCSLuaFile(path .. folder .. "/" .. File)
	    end
	end

	hook.Add("InitPostEntity", "nosay_load_settings", function()
		noSayBlacklist.Database.GetSettings(function(data)
			if not data and not data[1] then return end
			for k, v in pairs(data) do
				noSayBlacklist.Core.UpdateSetting(v.setting, v.value)
			end
		end)

		noSayBlacklist.Database.GetWords(function(data)
			if not data and not data[1] then return end
			for k, v in pairs(data) do
				if not (v.replace == "") then
					noSayBlacklist.Core.Words[v.word] = v.replace
				else
					noSayBlacklist.Core.Words[v.word] = true
				end
			end
		end)
	end)

	hook.Add("PlayerInitialSpawn", "nosay_send_settings", function(ply)
		net.Start("nosay_admin_inital_settings")
		net.WriteTable(noSayBlacklist.Core.Settings)
		net.Send(ply)

		net.Start("nosay_admin_inital_words")
		net.WriteTable(noSayBlacklist.Core.Words)
		net.Send(ply)
	end)
end

if CLIENT then
	local files, folders = file.Find(path .. "*", "LUA")

	for _, folder in SortedPairs(folders, true) do
		noSayBlacklist.Core.Print("Loading folder: ", folder)
	    for b, File in SortedPairs(file.Find(path .. folder .. "/sh_*.lua", "LUA"), true) do
	    	noSayBlacklist.Core.Print("    ", File)
	        include(path .. folder .. "/" .. File)
	    end

	    for b, File in SortedPairs(file.Find(path .. folder .. "/cl_*.lua", "LUA"), true) do
	    	noSayBlacklist.Core.Print("    ", File)
	        include(path .. folder .. "/" .. File)
	    end
	end
end

noSayBlacklist.Core.Print("Loaded noSay Blacklist")