--[[-----------------------------------
AUTHOR: dougRiss
DATE: 11/7/2014
PURPOSE: Instructions for opening a file
from your disk, be it a sign or a book.
--]]-----------------------------------
include("config/config.lua")
include("build.lua")

--[[-----------------------------------
Reads a table from a text file.
--]]-----------------------------------
local function readFromFile(name, signOwner, signID, gr_type)
	local aSign = util.KeyValuesToTable(file.Read("goodreads/"..gr_type.."/"..name ,"DATA"))
	aSign.owner = signOwner
	aSign.id = signID
	if(aSign && DEBUGGING_MODE) then 
		print("successfully loaded from 'data/goodreads/"..gr_type.."/"..name)
	end
	return aSign
end

--[[-----------------------------------
Presents the user with a derma panel
with all files present in the appropriate
folder.
--]]-----------------------------------
function openFileDialog(owner, id, nwstring)
	local gr_type
	
	if(nwstring == NW_STRING_BOOK) then 
		gr_type = "book"
	elseif(nwstring == NW_STRING_SIGN) then 
		gr_type = "sign"
	else
		print("Bad network string supplied")
		return
	end
	
	if(DEBUGGING_MODE) then print("Opening file of type: "..gr_type) end
	
	filePanel = buildFrame("Select Action", true, 175, 200, true)

	local fileListView = vgui.Create( "DListView", filePanel )
	fileListView:AddColumn( "Signs" )
	fileListView:SetPos(5, 30)
	fileListView:SetSize(165, 125)
	fileListView:SetMultiSelect(false)
	local allFiles = file.Find("goodreads/"..gr_type.."/*", "DATA", dateasc)
	
	local i = 1
	for k in pairs(allFiles) do
		fileListView:AddLine(allFiles[i])
		i = i + 1
	end
	
	local openFileButton = buildButton(filePanel, "Load File", 165, 35, 5, 160)
	openFileButton.DoClick = (function ()
		if (fileListView:GetSelectedLine()) then
			fileName = allFiles[fileListView:GetSelectedLine()]
			aSign = readFromFile(fileName, owner, id, gr_type)
			
			net.Start(nwstring)
				net.WriteTable(aSign)
			net.SendToServer()
			
			filePanel:Remove()
			filePanel = nil
		end
	end)
end