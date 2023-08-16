////////////////////////////////////////////////////////////////
// Tactical Nuke, Autorun
// By Svn
///////////////////////////////////////////////////////////////
//Editing this file will invalidate your support warranty.////

--[[
_________________________________________________________________________________
@ Script Detail(s)
Name 		: Tactical Nuke
ProductID 	: none
Version 	: 1.0
Release 	: 12.09.17
@ Author(s)
Programmed 	by: Svn, Creators of M9K's Nuke
_________________________________________________________________________________
_________________________________________________________________________________
@ Consumer Details
Steam64: public
_________________________________________________________________________________
]]--
------------------------------------------------------------------------
-- Debug Variable
local DEBUG_ENABLED = false;
------------------------------------------------------------------------
-- Script Details
ScriptDetail = {}
ScriptDetail.TacticalNuke = {}
ScriptDetail.TacticalNuke.PrintName 	= "Event"
ScriptDetail.TacticalNuke.PrintID 		= "none"
ScriptDetail.TacticalNuke.Version 		= "1.0"
ScriptDetail.TacticalNuke.Release 		= "12.09.17"
ScriptDetail.TacticalNuke.Author 		=  [[
[Programmed] by: Svn, Creators of M9K's Nuke
]]
ScriptDetail.TacticalNuke.Affiliation 	= [[
]]
ScriptDetail.TacticalNuke.CNID 		= "public"
------------------------------------------------------------------------
-- Script Print Details
ScriptDetailPrint = {
'\n',
"_________________________________________________________________________________",
"",
"---------- Tactical Nuke --------------------------------------------------------",
"_________________________________________________________________________________",
"",
"@ Script Detail(s)",
"[Name]      : "..ScriptDetail.TacticalNuke.PrintName,
"[ProductID] : "..ScriptDetail.TacticalNuke.PrintID,
"[Version]   : "..ScriptDetail.TacticalNuke.Version,
"[Release]   : "..ScriptDetail.TacticalNuke.Release..'\n',
"@ Author(s)",
ScriptDetail.TacticalNuke.Author,
"@ Affiliation(s)",
ScriptDetail.TacticalNuke.Affiliation,
"@ Consumer Details",
"Steam64: "..ScriptDetail.TacticalNuke.CNID,
"_________________________________________________________________________________",
'\n',
}
for k, i in ipairs(ScriptDetailPrint) do
    MsgC(Color(50,142,255),i..'\n')
end
------------------------------------------------------------------------
-- File Allocation
local inc_cfg_root 		= "config_tacticalnuke.lua";
local inc_files_dir 	= "script/tacticalnuke/";
local inc_files_sv 		= file.Find(inc_files_dir.."sv/sv_*","LUA");
local inc_files_sh 		= file.Find(inc_files_dir.."sh/sh_*","LUA");
local inc_files_cl 		= file.Find(inc_files_dir.."cl/cl_*","LUA");
AddCSLuaFile(inc_cfg_root)
include(inc_cfg_root)
for k , v in pairs(inc_files_sv) do
	include(inc_files_dir.."sv/"..v)
	if DEBUG_ENABLED == true then
		print("ALLOCATION : "..v.." WAS SUCCESSFUL.")
	end
end
for k , v in pairs(inc_files_sh) do
	AddCSLuaFile(inc_files_dir.."sh/"..v)
	include(inc_files_dir.."sh/"..v)
	if DEBUG_ENABLED == true then
		print("ALLOCATION : "..v.." WAS SUCCESSFUL.")
	end
end
for k , v in pairs(inc_files_cl) do
	AddCSLuaFile(inc_files_dir.."cl/"..v)
	include(inc_files_dir.."cl/"..v)
	if DEBUG_ENABLED == true then
		print("ALLOCATION : "..v.." WAS SUCCESSFUL.")
	end
end
------------------------------------------------------------------------
-- Workshop Allocation
//////////////////
if SERVER then
/////////////////
local inc_ws_dir = {
};
for k , v in pairs(inc_ws_dir) do
	resource.AddWorkshop(v)
	if DEBUG_ENABLED == true then
		print("ALLOCATION : "..v.." WAS SUCCESSFUL.")
	end
end
////////
end
///////
------------------------------------------------------------------------
-- Shared Resources
------------------------------------------------------------------------
-- Meta Tables
------------------------------------------------------------------------
-- Extra
//////////////////
if SERVER then
/////////////////
util.AddNetworkString("TNUKE_NETWORK_CLIENT")
////////
end
///////
