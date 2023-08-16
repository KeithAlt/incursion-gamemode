ENT.Spawnable			= false
ENT.AdminSpawnable		= false

include("shared.lua")

/*---------------------------------------------------------
   Name: ENT:Initialize()
---------------------------------------------------------*/
function ENT:Initialize()
	self.TimeLeft = CurTime() + 3
end