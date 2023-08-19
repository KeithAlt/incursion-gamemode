// Copyright © 2020 VCMod (freemmaann). All Rights Reserved. if you have any complaints or ideas contact me: steam - steamcommunity.com/id/freemmaann/ or email - freemmaann@gmail.com.

include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize() end

function ENT:Think() if VC and VC.CodeEnt.Spikestrip and VC.CodeEnt.Spikestrip.Think then return VC.CodeEnt.Spikestrip.Think(self) end end