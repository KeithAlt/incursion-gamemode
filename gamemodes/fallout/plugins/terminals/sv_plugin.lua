local PLUGIN = PLUGIN

function PLUGIN:saveDiskData()
	--old stuff
	--[[
	local path = "nutscript/"..SCHEMA.folder.."/disk_data.txt"
	file.CreateDir("nutscript/"..SCHEMA.folder.."/")
	
    file.Write(path, pon.encode({TerminalR.DiskData}))
	--]]
end

--new stuff
function PLUGIN:saveDisk(disk, ID) --saves a single disk with its itemID as the name of the folder
	local path = "nutscript/"..SCHEMA.folder.."/disks/" ..ID.. ".txt"
	file.CreateDir("nutscript/"..SCHEMA.folder.."/disks/")
	
    file.Write(path, pon.encode({disk}))
end

--new stuff
function PLUGIN:deleteDisk(ID) --deletes the disk from the files
	local path = "nutscript/"..SCHEMA.folder.."/disks/" ..ID.. ".txt"
	file.CreateDir("nutscript/"..SCHEMA.folder.."/disks/")
	file.Delete(path)
end

function PLUGIN:readDisk(ID) --saves a single disk with its itemID as the name of the folder
	local path = "nutscript/"..SCHEMA.folder.."/disks/" ..ID.. ".txt"
    local status, decoded = pcall(pon.decode, file.Read(path, "DATA"))

    local tbl

	if (status and decoded) then
		local value = decoded[1]

		if (value != nil) then
			tbl = value
		else
			tbl = {}
		end
	else
		tbl = {}
    end

	return tbl
end

--[[
hook.Add("InitPostEntity", "terminal_disk_passwords", function()
    
end)
--]]

function PLUGIN:LoadData()
	local path = "nutscript/"..SCHEMA.folder.."/disk_data.txt"
	if(file.Exists(path, "DATA")) then
		local status, decoded = pcall(pon.decode, file.Read(path, "DATA"))

		local tbl

		if (status and decoded) then
			local value = decoded[1]

			if (value != nil) then
				tbl = value
			else
				tbl = {}
			end
		else
			tbl = {}
		end
		
		for k, v in pairs(tbl) do
			PLUGIN:saveDisk(v, k)
		end
		
		file.Delete(path)
	end
end

hook.Add("ShutDown", "terminal_disk_passwords2", function()
    PLUGIN:saveDiskData()
end)

--no longer used
--[[
netstream.Hook("foDiskRnm", function(client, index, title)
    local item = nut.item.instances[index]

    local char = client:getChar()
    if (!char) then return end
    local inv = char:getInv()

    --if (item and item.uniqueID == ("disk") and inv:getItemByID(index))  then
    if (item and item.uniqueID == ("disk"))  then
        --TerminalR.DiskData[index] = TerminalR.DiskData[index] or {}
        --TerminalR.DiskData[index].title = {title}
        netstream.Start(client, "foDiskTitle", index, title)
    end
end)
--]]

--prints a new disk
netstream.Hook("foDiskPrint", function(client, entIndex, Info, noDrop)
	local entity = ents.GetByIndex(entIndex)

    if(!IsValid(entity)) then return end

    local char = client:getChar()
    if (!char) then return end
	
	local itemID
	
	local diskData = {
		author = Info.author,
		editor = Info.editor,
		printer = Info.printer,
		encrypt = Info.encrypt,
		name = Info.title,
		tempID = true,
	}
	
	local inventory = char:getInv()
	if(!inventory:add("disk", 1, diskData)) then
		if(!noDrop) then
			local ang = entity:GetAngles()
			local dropPos = entity:GetPos() + ang:Forward()*15 + ang:Up()*10

			nut.item.spawn("disk", dropPos, function(item, ent)
				itemID = item:getID()
			
				ent.CooldownInsert = CurTime() + 5
				
				item:setData("author", Info.author)
				item:setData("editor", Info.editor)
				item:setData("printer", Info.printer)
				item:setData("encrypt", Info.encrypt)
				item:setData("name", Info.title)
				
				if(itemID) then
					local diskData = {
						text = Info.text,
						title = Info.title, 
						author = Info.author,
						editor = Info.editor,
						printer = Info.printer,
						encrypt = Info.encrypt,
						pass = Info.pass
					}
					
					PLUGIN:saveDisk(diskData, itemID)
				end
			end, Angle(280, 0, ang.y ))
		end
	else
		timer.Simple(1, function() --this timer makes sure the code runs after the item is in the inventory
			inventory = char:getInv()
		
			--this is sort of a workaround to the fact that inventory:add doesn't return an item or anything
			for k, v in pairs(inventory:getItems()) do
				if(v.uniqueID == "disk") then
					if(v:getData("tempID")) then
						v:setData("tempID", nil)
						itemID = v:getID()
					end
				end
			end
			
			if(itemID) then
				local diskData = {
					text = Info.text,
					title = Info.title, 
					author = Info.author,
					editor = Info.editor,
					printer = Info.printer,
					encrypt = Info.encrypt,
					pass = Info.pass
				}
				
				PLUGIN:saveDisk(diskData, itemID)
			end
		end)
	end
end)

--this is just a hook that tells the afk system that terminal users aren't afk
netstream.Hook("terminalAFKRefresh", function(client)
	AFKKick.ResetAFKTime(client)
end)

--[[
netstream.Hook("foDiskFavAdd", function(client, Info)
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
end)
--]]