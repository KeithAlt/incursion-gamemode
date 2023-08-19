// Copyright © 2020 VCMod (freemmaann). All Rights Reserved. if you have any complaints or ideas contact me: steam - steamcommunity.com/id/freemmaann/ or email - freemmaann@gmail.com.

// Force players to download this file
AddCSLuaFile()

// Add client loader to the mix
AddCSLuaFile("vcmod/client/load.lua")

// Which VCMod addon is this?
vcmod_main = true

// Record version number
local old = VC_AU_Ver

// VCMod Auto Updater version nunmber
VC_AU_Ver = 9.65

// Auto Updater version missmatch check
if old and old < VC_AU_Ver then print("VCMod: Issue found, VCMod addons version incompatibility found(old: "..old..", new: "..VC_AU_Ver.."). Update all of your VCMod addons!") end

// Start the loading process
include("vcmod/init.lua")

// Check if RunString works properly
if !VC.Test_RS then RunString("VC.Test_RS = true", "vc_rs_t") if !VC.Test_RS then VCPrint("ERROR: RunString is non-functional, stopping.") return end end

// Initialize the Auto Updter loading
local tType = SERVER and "server" or "client" include("vcmod/"..tType.."/load.lua")
