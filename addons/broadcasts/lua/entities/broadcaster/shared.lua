ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Broadcast Transmitter"
ENT.Author = "Claymore Gaming"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Owner = nil
ENT.Category = "Claymore Gaming"
ENT.WorldModel = "models/clutter/hamradio.mdl"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "OwningEnt")
end

function ENT:OnRemove()
	BROADCASTS.OnBroadcastRemoved(self)
end
