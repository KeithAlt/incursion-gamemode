AddCSLuaFile()

--Shared
ENT.Type      = "anim"
ENT.Base      = "base_gmodentity"

ENT.Category  = "Claymore Gaming"
ENT.PrintName = "Farm Water"
ENT.Author    = "jonjo"

ENT.Spawnable = true

if SERVER then --Server-side
    function ENT:Initialize()
        self:SetModel("models/props_junk/metalgascan.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        self:SetPos(self:GetPos() + Vector(0, 0, 10)) --Spawns in the floor otherwise
        local phys = self:GetPhysicsObject()
	    if (phys:IsValid()) then
		    phys:Wake()
	    end
    end
end

if CLIENT then --Client-side
    function ENT:Draw()
        self:DrawModel()
    end
end