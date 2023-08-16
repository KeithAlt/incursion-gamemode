AddCSLuaFile()

ENT.Type      = "anim"
ENT.Base      = "base_gmodentity"

ENT.PrintName = "Extractor"
ENT.Author    = "jonjo"
ENT.Category  = "Claymore Gaming"

ENT.Spawnable = true

ENT.LockpickLevel = 3

function ENT:GetProduction()
    return self:GetNWString("ProductionItem", "Nothing")
end

function ENT:GetOwnership(ply)
    return self:GetNWEntity("Owner", NULL)
end

function ENT:GetProductionID()
    return self:GetNWString("ProductionItemID", nil)
end

function ENT:OnLockpicked(lockpicker)
    if CLIENT then return end
    self:OpenInventory(lockpicker)
end