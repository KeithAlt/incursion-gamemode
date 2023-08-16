--[[-----------------------------------
AUTHOR: dougRiss
DATE: 11/7/2014
PURPOSE: initializes our base ent
--]]-----------------------------------
AddCSLuaFile("shared.lua")
AddCSLuaFile("init.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("derma/build.lua")
AddCSLuaFile("derma/open_file.lua")
AddCSLuaFile("derma/save_file.lua")
AddCSLuaFile("derma/goodread_menu.lua")
AddCSLuaFile("config/config.lua")
AddCSLuaFile("config/default_content.lua")
include("shared.lua")
include("config/config.lua")

--[[-----------------------------------
Here's the Signs' table. Naturally, it
is empty on initialization, as nobody 
has yet to touch it.
--]]-----------------------------------
local signs = {}

--[[-----------------------------------
Open up a network string that will allow
us to talk between the client and server
about our signs.
--]]-----------------------------------
util.AddNetworkString("nwgoodreads")

--[[-----------------------------------
Receive the table from the clientside
script and do stuff to it.
--]]-----------------------------------
net.Receive("nwgoodreads", -- Not sure if this is the best way to do it, but this is all I knew about talking with the server.
    function (len)
        local theTable = net.ReadTable()
        placeSignInTable(theTable.id, theTable)
    end)

--[[-----------------------------------
Place our sign that we gather from
net.Receive into our signs table
--]]-----------------------------------
function placeSignInTable(id, theTable)
    signs[id] = theTable
end

--[[-----------------------------------
Hook for when the object initializes;
Initializes the object when it's first
spawned.
--]]-----------------------------------
function ENT:Initialize()
    self:SetModel("models/props_lab/clipboard.mdl")
    self:SetUseType(SIMPLE_USE)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetSolid( SOLID_VPHYSICS )
    self:SetSignID(self:GetCreationID()) --sets the sign's ID to it's creationID
    self:SetSignText("")
    self:SetSignOwner("")
    self:SetSignName("")
    
    local newSign = {} 
    newSign.name = self:GetSignName()
    newSign.text = self:GetSignText()
    newSign.owner = self:GetSignOwner()
    newSign.id = self:GetSignID()
    signs[self:GetSignID()] = newSign --store the newly created sign in the table, right?
end

--[[-----------------------------------
Hook for when an entity uses the item;
get the sign from the table and send it
to the clientside scripts
--]]-----------------------------------
function ENT:Use( act, call)
    local me = self:GetSignID() -- on use, get the name of the entity being used
    local theTable = signs[me]          -- store the table entry associated with whatever 'me' turns out to be
    theTable.activator = act
    if act.IsPlayer() then      -- if the activating entity is the player...
        net.Start("nwgoodreads")    -- start the network string
            net.WriteTable(theTable)    -- write the table with our entity's information
        net.Send(act)           -- then send to the player who used it.
    end
end

--[[-----------------------------------
Override ENT:Think to do nothing.
--]]-----------------------------------
function ENT:Think() end