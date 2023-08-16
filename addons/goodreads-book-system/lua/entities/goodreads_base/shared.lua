--[[-----------------------------------
AUTHOR: dougRiss
DATE: 11/7/2014
PURPOSE: Set up our entity details
--]]-----------------------------------
include("config/config.lua")

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
ENT.Spawnable = false

ENT.PrintName		= "RP Goodreads Base Entity"
ENT.Author			= "DougRiss"
ENT.Contact			= "himself@dougriss.com"
ENT.Purpose			= "serve as a base for other entities"
ENT.Instructions	= "Ignore me!"

function ENT:SetupDataTables()
end 

--[[hooks]]--