// Copyright © 2020 VCMod (freemmaann). All Rights Reserved. if you have any complaints or ideas contact me: steam - steamcommunity.com/id/freemmaann/ or email - freemmaann@gmail.com.

include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize() self.VC_Color = Color(0,255,255,255) self.VC_Length = 142 self.VC_Text = "Vehicle Fuel 10%" self.VC_PVsb = util.GetPixelVisibleHandle() end