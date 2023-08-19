--[[-----------------------------------
AUTHOR: dougRiss
DATE: 11/7/2014
PURPOSE: Clientside for our sign
--]]-----------------------------------
include("shared.lua")
include("derma/goodread_menu.lua")

--[[-----------------------------------
if mainPanel is not initialized (or nil),
enter the function; else, do nothing. 
The reason this is here is because 
without it, the menu opens a new instance 
of mainPanel on every tick for as long as 
you hold your use key down. This creates 
a sort-of pseudo singleton pattern to 
ensure only one instance lives at a time.
--]]-----------------------------------
local mainPanel

--[[-----------------------------------
creates the folders used to house the
stored sign and book data
--]]-----------------------------------
local function createFolders()
	if(!file.IsDir("/goodreads/book/", "DATA")) then 
		file.CreateDir("/goodreads/book/", "DATA")
	end
	if(!file.IsDir("/goodreads/sign/", "DATA")) then 
		file.CreateDir("/goodreads/sign/", "DATA")
	end   
end

--[[-----------------------------------
Calls the appropriate build method when
the entity is used and sends the client
a network string.
--]]-----------------------------------
local function useSignFrame(name, text, owner, activator, id, nwstring)

	if !mainPanel then
	
		-- this sign has no owner...
		if owner == "" then
			buildClaimPanel(mainPanel, name, activator, id, nwstring)
			
		-- the sign is claimed and the activator is owner...
		elseif owner == activator then 
			buildOwnerPanel(mainPanel, name, owner, id, text, nwstring)
			
		-- the sign is claimed and activator is not owner...
		else
			buildGuestPanel(mainPanel, name, owner, id, text, nwstring)
			
		end
	end
end

--[[-----------------------------------
Receive grabs a network string when the 
server sends it (in this case, nwrpsign) 
and performs a function on its contents.
--]]-----------------------------------
net.Receive("nwgoodreads", 
function (len)
	local theTable = net.ReadTable()
	local id = theTable.id
	local name = theTable.name
	local text = theTable.text
	local owner = theTable.owner
	local activator = theTable.activator:SteamID()
	useSignFrame(name, text, owner, activator, id)
end)

--[[-----------------------------------
Swanky function called every tick that 
the entity is drawn; draws text onto the 
entity that says "Read me"
--]]-----------------------------------

function ENT:Draw()
--To be overwritten by implementations
end
