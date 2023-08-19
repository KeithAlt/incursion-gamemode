// Copyright © 2020 VCMod (freemmaann). All Rights Reserved. if you have any complaints or ideas contact me: steam - steamcommunity.com/id/freemmaann/ or email - freemmaann@gmail.com.

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// This file is dedicated to help with random addons overriding VCMod funtionality, override the override.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// These are left by SGM in some of his vehicles, back when VCMod used this primitive method.
VC_MakeScripts = function() end
VC_MakeScript = function() end

// Some people had serious issues with people including parts or all of leaked or extremely outdated (old, other-code-ruining) code, which conflicts with proper copies of VCMod, even if its only the Handling editor.
// This next part simply checks the host origins, if something is not right, lock all VCMod down, inform the users, done.

// Only simply checks every minute or so for a limited amount of time. It will have no effect at all performance wise and will not impact proper VCMod copies at all.
local function _()if VC&&VC~=""then local _="Host compatibility issue, possible leak detected."if VC.Host&&!string.find(VC.Host,"://vcmod.org")||SERVER&&VC["W".."_D".."o_G"]&&!string.find(VC["W".."_D".."o_G"]"","://vcmod.org")then if VCMsg then VCMsg(_)end if VCPrint then VCPrint("".._)end print("VCMod: ".._) VC="" end end end _()timer.Simple(10,_)timer.Simple(7200,_)timer.Create("VC_HostCompatibility",10,720,_)