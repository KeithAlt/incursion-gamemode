ITEM.name = "Disk"
ITEM.desc = "A disk that can be used to store data."
ITEM.model = "models/unconid/pc_models/floppy_disk_3_5.mdl"
ITEM.category = "Documents"
ITEM.width = 1
ITEM.height = 1
ITEM.noBusiness = false
ITEM.price = 100

--replace this later
function ITEM:onSendData()
    local receiver = self.player

    local index = self:getID()
    --local title = TerminalR.DiskData[index] and TerminalR.DiskData[index].title and TerminalR.DiskData[index].title[1]
    --local author = receiver:IsAdmin() and TerminalR.DiskData[index] and TerminalR.DiskData[index].author
	
	local name = self:getName()
	local desc = self:getDesc()

    netstream.Start(receiver, "foDiskData", index, name, desc)
end

function ITEM:onRemoved()
    TerminalR.DiskData[self:getID()] = nil
end

function ITEM:getDesc()
	local desc = self.desc
	
	local encrypt = self:getData("encrypt")
	if(encrypt) then
		desc = desc.. "\nThis disk is encrypted."
	end	
	
	local author = self:getData("author")
	if(author) then
		desc = desc.. "\nAuthor: " ..author.. "."
		
		local editor = self:getData("editor")
		if(editor and editor != author) then
			desc = desc.. "\nEditor: " ..editor.. "."
		end
	end	
	
	local printer = self:getData("printer")
	if(printer) then
		desc = desc.. "\nPrinted By: " ..printer.. "."
	end
	
	return desc
end

function ITEM:getName()
	local name = self:getData("name") or self.name
	
	--just in case something weird happens
	if(istable(name)) then
		name = "Disk"
	end
	
	return name
end