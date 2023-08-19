AddCSLuaFile( )
ENT.Type            = "anim"
ENT.Base            = "base_anim"
ENT.PrintName		= "Gallows"
ENT.Author			= "Lenny"
ENT.Spawnable       = true
ENT.Category        = "Claymore Gaming"

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/fallout4/buildings/gallows.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        
        self:SetUseType(SIMPLE_USE)
        self.noose1 = ents.Create("noose")
        self.noose1:SetPos(self:GetPos() + self:GetForward() * 50 + self:GetRight() * 50 + Vector(0, 0, 260))
        self.noose1:DeleteOnRemove(self)
        self.noose1:SetParent(self)
        self.noose1:Spawn()
        self.noose2 = ents.Create("noose")
        self.noose2:SetPos(self:GetPos() + self:GetForward() * 50 + self:GetRight() * -80 + Vector(0, 0, 260))
        self.noose2:DeleteOnRemove(self)
        self.noose2:SetParent(self)
        self.noose2:Spawn()
    end
end