// Copyright © 2020 VCMod (freemmaann). All Rights Reserved. if you have any complaints or ideas contact me: steam - steamcommunity.com/id/freemmaann/ or email - freemmaann@gmail.com.

// Force players to download needed files
AddCSLuaFile() AddCSLuaFile("vcmod/client/init.lua")

// Initialize basic VCMod functionality, setup the initial core tables
if SERVER then resource.AddWorkshop("632470227") end

if !VC then VC = {} end if !VC.Versions then VC.Versions = {} end if !VC.Loaded then VC.Loaded = {} end if !VC.AddonData then VC.AddonData = {} end VC.Copyright = "Copyright © 2020 VCMod (freemmaann)." VC.Host = "https://vcmod.org/" if !VC.AUMsg then VC.AUMsg = {} end file.CreateDir("vcmod")

// CHeck if htis is AU or not
VC.isAutoUpdate = file.Exists("autorun/vc_load.lua", "LUA")

// Don't load things again
local dir = "init" if VC.Loaded[dir] then return end VC.Loaded[dir] = CurTime()

// Load logging before we do anything else (if possible)
local dir = "vcmod/server/logging.lua" if SERVER and file.Exists(dir, "LUA") then include(dir) end

// Load some VCMod color data
VC.Color = {}
VC.Color.Main = Color(0,0,0,220)
VC.Color.Base = Color(237, 237, 237, 255)
VC.Color.Accent = Color(127, 37, 37, 255)
VC.Color.Accent_Light = Color(163, 48, 48, 255)

// Setup VCMod custom "print()"
function VCPrint_noPrefix(msg) MsgC(VC.Color.Accent_Light, msg, "\n") end
function VCPrint(msg) local smsg = "VCMod: " if CLIENT then smsg = "VCMod Local: " else if VC.log then VC.log('<General> '..(msg or "")) end end MsgC(VC.Color.Accent_Light, smsg, VC.Color.Base, msg or "", "\n") end

// Print the welcome message
VCPrint_noPrefix("")
VCPrint_noPrefix("----------------------------------------------------------------------------")
VCPrint("Welcome to VCMod"..(VC.isAutoUpdate and " Auto-Updater"..(VC_AU_Ver and " version "..VC_AU_Ver or "") or "")..".")
VCPrint_noPrefix("----------------------------------------------------------------------------")
VCPrint_noPrefix("")

// Include clientside code
if CLIENT then include("vcmod/client/init.lua") end