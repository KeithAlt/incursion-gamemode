AddCSLuaFile()

ENT.Type      = "anim"
ENT.Base      = "base_gmodentity"

ENT.PrintName = "Fusion Core Reactor"
ENT.Author    = "jonjo"
ENT.Category  = "Claymore Gaming"

ENT.Spawnable = true

ENT.LockpickLevel = 3

function ENT:GetOwnership(ply)
    return self:GetNWEntity("Owner", NULL)
end

function ENT:OnLockpicked(lockpicker)
    if CLIENT then return end
    self:OpenInventory(lockpicker)
end

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Fuel")
    self:NetworkVar("Bool", 0, "FactionAccess")
    self:NetworkVar("String", 0, "Faction")

    if SERVER then
        self:SetFuel(0)
        self:SetFactionAccess(false)
        self:SetFaction("")
    end
end