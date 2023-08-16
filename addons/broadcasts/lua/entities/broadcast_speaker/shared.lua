ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Broadcast Receiver"
ENT.Author = "DanFMN"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Owner = nil
ENT.Category = "Claymore Gaming"
ENT.WorldModel = "models/mosi/fallout4/props/radio/radio_prewar.mdl"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.ListenDistance = BROADCASTS.Config.DefaultListenDistance

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "OwningEnt")
end
