
/*
General
*/
local MODULE = bLogs:Module()

MODULE.Category = "VCMod"
MODULE.Name = "General"
MODULE.Colour = Color(127, 37, 37, 255)
MODULE:Hook("bLogs_VCMod_General","blogs_VCMod_General",function(msg) MODULE:Log(msg) end)

bLogs:AddModule(MODULE)

/*
Car Dealer
*/
local MODULE = bLogs:Module()

MODULE.Category = "VCMod"
MODULE.Name = "Car Dealer"
MODULE.Colour = Color(127, 37, 37, 255)
MODULE:Hook("bLogs_VCMod_CD","blogs_VCMod_CD",function(msg) MODULE:Log(msg) end)

bLogs:AddModule(MODULE)

/*
Repair Man
*/
local MODULE = bLogs:Module()

MODULE.Category = "VCMod"
MODULE.Name = "Repair Man"
MODULE.Colour = Color(127, 37, 37, 255)
MODULE:Hook("bLogs_VCMod_RM","blogs_VCMod_RM",function(msg) MODULE:Log(msg) end)

bLogs:AddModule(MODULE)

/*
Fuel
*/
local MODULE = bLogs:Module()

MODULE.Category = "VCMod"
MODULE.Name = "Fuel"
MODULE.Colour = Color(127, 37, 37, 255)
MODULE:Hook("bLogs_VCMod_Fuel","blogs_VCMod_Fuel",function(msg) MODULE:Log(msg) end)

bLogs:AddModule(MODULE)