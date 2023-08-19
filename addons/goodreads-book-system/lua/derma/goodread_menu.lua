--[[-----------------------------------
AUTHOR: dougRiss
DATE: 11/7/2014
PURPOSE: Separates the bulk of all the 
clientside lua that is called when an 
entity interacts with a sign or book.
--]]-----------------------------------

include("open_file.lua")
include("save_file.lua")
include("build.lua")
include("config/config.lua")

local function writeToServer(aTable, nwstring)
	net.Start(nwstring)
		net.WriteTable(aTable)
	net.SendToServer()
	
	if(DEBUGGING_MODE) then print("table \""..aTable.name.."\" sent to server; expecting success...") end
end

function buildClaimPanel(mainFrame, theName, theOwner, theID, nwstring)
	mainFrame = buildFrame("Select an Action", false, 175, 100, true)	
	
	claimButton = buildButton(mainFrame, "Claim", 167, 30, 4, 30)
	claimButton.DoClick = function ()
		local t = {text = "", name = theName, owner = theOwner, id = theID}
		writeToServer(t, nwstring)
		displayNotification("Claimed")
		mainFrame:Remove()
		mainFrame = nil
	end --end DoClick
	
	closeButton = buildButton(mainFrame, "Close", 167, 30, 4, 64)
	closeButton.DoClick = function ()
		mainFrame:Remove()
		mainFrame = nil
	end
end

function buildOwnerPanel(mainFrame, theName, theOwner, theID, theText, nwstring)
	mainFrame = buildFrame("Select an Action", false, 400, 400)

	nameBox = buildTextEntry(mainFrame, theName, true, 305, 20, 5, 30)
	nameBox:SetEditable(false)

	textBox = buildTextEntry(mainFrame, theText, true, 305, 340, 5, 55)
	textBox:SetEditable(false)

	closeButton = buildButton(mainFrame, "Close", 80, 45, 315, 350)
	closeButton.DoClick = function ()
		mainFrame:Remove()
		mainFrame = nil
		if(DEBUGGING_MODE) then print("Exiting panel") end
	end --end DoClick

	editButton = buildButton(mainFrame, "Edit", 80, 45, 315, 30)
	editButton.DoClick = function ()
		if editButton:GetText() == "Edit" then
			editButton:SetText("Accept")
			closeButton:SetText("Cancel")
			textBox:SetEditable(true)
			nameBox:SetEditable(true)
			if(DEBUGGING_MODE) then print("Editing readable...") end
		else
			t = {name = nameBox:GetValue(), owner = theOwner, id = theID, text = textBox:GetValue()}
			writeToServer(t, nwstring)
			displayNotification("Changes Saved")
			editButton:SetText("Edit")
			closeButton:SetText("Accept")
			textBox:SetEditable(false)
			nameBox:SetEditable(false)
			if(DEBUGGING_MODE) then print("Readable Saved") end
		end --end if
	end --end DoClick

	openButton = buildButton(mainFrame, "Open...", 80, 45, 315, 80)
	openButton.DoClick = function ()
		openFileDialog(theOwner, theID, nwstring)
		mainFrame:Remove()
		mainFrame = nil
	end --end DoClick()

	saveButton = buildButton(mainFrame, "Save...", 80, 45, 315, 130)
	saveButton.DoClick = function ()
		t = {name = nameBox:GetValue(), owner = theOwner, id = theID, text = textBox:GetValue()}
		writeToServer(t, nwstring)
		saveFileDialog(textBox:GetValue(), nameBox:GetValue(), nwstring)
		editButton:SetText("Edit")
		closeButton:SetText("Close")
		textBox:SetEditable(false)
		nameBox:SetEditable(false)
		if(DEBUGGING_MODE) then print("Readable Saved") end
	end --end DoClick()
end

function buildGuestPanel(mainFrame, theName, theOwner, theID, theText, nwstring)
	mainFrame = buildFrame(theName, false, 400, 400)
	
	textBox = buildTextEntry(mainFrame, theText, true, 305, 360, 5, 30)
	textBox:SetEditable(false)
	
	if(ALLOW_SAVE_ON_VIEW) then
		local saveButton = vgui.Create("DButton", mainPanel)
		saveButton:SetPos(315, 30)
		saveButton:SetSize(80, 45)
		saveButton:SetText("Save")
		saveButton.DoClick = function ()
			saveFileDialog(textBox:GetValue(), name, nwstring)
			mainPanel:Remove()
			mainPanel = nil
		end --end DoClick
	end
	
	acceptButton = buildButton(mainFrame, "Close", 80, 45, 315, 350)
	acceptButton.DoClick = function ()
		mainFrame:Remove()
		mainFrame = nil
	end --end DoClick
end