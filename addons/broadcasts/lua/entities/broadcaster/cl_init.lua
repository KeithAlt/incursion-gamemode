include("shared.lua")

function ENT:Initialize()
	BROADCASTS.RegisterBroadcast(self)
end
