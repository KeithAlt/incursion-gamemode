// Copyright © 2020 VCMod (freemmaann). All Rights Reserved. if you have any complaints or ideas contact me: steam - steamcommunity.com/id/freemmaann/ or email - freemmaann@gmail.com.

include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize() self.VC_PVsb = util.GetPixelVisibleHandle() end

local ID = "Fuel_station"
function ENT:Draw(...) if VC and VC.CodeEnt[ID] and VC.CodeEnt[ID].Draw then return VC.CodeEnt[ID].Draw(self, ...) end end