--[[-----------------------------------
AUTHOR: dougRiss
DATE: 11/7/2014
PURPOSE: Instructions for saving a file
to your disk, be it a sign or a book.
--]]-----------------------------------
include("config/config.lua")
include("build.lua")

--[[-----------------------------------
Pulls out all characters that would 
have a hand in not letting the file save
such as : < > / | \ ' 
--]]-----------------------------------
local function stripNonAlphaNum(fileName)
	if (string.find(fileName, "[^%w*]") != nil) then
		fileName = string.gsub(fileName, "[^%w*]", " ")
	end
	return fileName
end 

--[[-----------------------------------
Writes a table to a file to be read later
--]]-----------------------------------
local function saveToFile(sign, fileName, gr_type)
	if(!file.Exists("goodreads/"..gr_type.."/", "DATA")) then
		file.CreateDir("goodreads/"..gr_type.."/")
	end
	file.Write("goodreads/"..gr_type.."/"..fileName..".txt", util.TableToKeyValues(sign))
	if(DEBUGGING_MODE) then print("Sign saved to 'data/goodreads/"..gr_type.."/"..fileName..".txt'") end
end

--[[-----------------------------------
Derma frame that prompts user response
--]]-----------------------------------
function saveFileDialog(theText, theTitle, nwstring)
	local gr_type
	
	if(nwstring == NW_STRING_BOOK) then 
		gr_type = "book"
	elseif(nwstring == NW_STRING_SIGN) then 
		gr_type = "sign"
	else
		print("Bad network string supplied")
		return
	end
	
	filePanel = buildFrame("Select Action", true, 175, 120, true)
	
	fileNameEntry = buildTextEntry(filePanel, "default", false, 165, 20, 5, 55)
	
	errorLabel = buildLabel(filePanel, "Alpha-Numeric Characters Only", 165, 20, 5, 30)
	
	saveButton = buildButton(filePanel, "Save File", 165, 35, 5, 80)
	saveButton.DoClick = (function()
		local t = {text = theText, name = theTitle, id = "", owner = ""}
		saveToFile(t, stripNonAlphaNum(fileNameEntry:GetValue()), gr_type)
		filePanel:Remove()
		filePanel = nil
	end)
end