--[[-----------------------------------
AUTHOR: dougRiss
DATE: 11/7/2014
PURPOSE: Create build functions for our
frequently used derma forms to cut back
on time spent fighting with them
--]]-----------------------------------
include("config/config.lua")

function buildFrame(title, showClose, width, length)
	local frame = vgui.Create("DFrame")
	frame:SetTitle(title)
	frame:SetSize(width, length)
	frame:SetDraggable(false)
	frame:ShowCloseButton(showClose)
	frame:MakePopup()
	frame:Center() 
	frame:ParentToHUD()
	
	if(frame && DEBUGGING_MODE) then print("Frame created.") end
	return frame
end

function buildButton(parent, text, width, length, x, y)
	btn = vgui.Create("DButton", parent)
	btn:SetPos(x, y)
	btn:SetSize(width, length)
	btn:SetText(text)
	
	if(btn && DEBUGGING_MODE) then print("    Button created. ") end
	return btn
end

function buildTextEntry(parent, text, multiline, width, length, x, y)
	textEntry = vgui.Create("DTextEntry", parent)
	textEntry:SetPos(x, y)
	textEntry:SetSize(width, length)
	textEntry:SetValue(text)
	textEntry:SetMultiline(multiline)
	
	if(textEntry && DEBUGGING_MODE) then print("    TextEntry created.") end
	return textEntry
end

function buildLabel(parent, text, width, length, x, y)
	label = vgui.Create( "DLabel", filePanel)
	label:SetPos(x, y)
	label:SetSize(width, length)
	label:SetText(text)
	
	if(label && DEBUGGING_MODE) then print ("    Label created.") end
	return label
end

function displayNotification(notification) -- to display when a change is successful
	local theWidth = 150
	successNotification = vgui.Create( "DNotify" )
	successNotification:SetPos(ScrW() * 0.5 - theWidth * 0.5, ScrH() * 0.5)
	successNotification:SetSize( theWidth, 40 )
	successNotification:SetLife(1)
	
	local aLabel = vgui.Create( "DLabel", successNotification)
	aLabel:Dock( FILL )
	aLabel:SetText( notification )
	aLabel:SetFont( "GModNotify" )
	aLabel:SetDark( true )
	aLabel:SizeToContents()
	
	successNotification:AddItem(aLabel)
end