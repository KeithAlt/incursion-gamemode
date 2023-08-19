include("shared.lua")

function ENT:Initialize()
	self:SetSubMaterial(0, "models/weapons/v_models/eq_electricgrenade/electricgrenade")
end

net.Receive("ELECTRICGRENADE", function(ent)
	local cnt = net.ReadUInt(16)
	for i = 1, cnt do
		local ent = net.ReadEntity()
		if (IsValid(ent)) then
			ent:AnimRestartGesture(GESTURE_SLOT_CUSTOM, ACT_GMOD_GESTURE_RANGE_FRENZY, true)
		end
	end
end)