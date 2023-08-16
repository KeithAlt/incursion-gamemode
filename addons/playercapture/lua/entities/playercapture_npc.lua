AddCSLuaFile()

--Shared
ENT.Type      = "anim"
ENT.Base      = "base_gmodentity"

ENT.PrintName = "NPC"
ENT.Category  = "Claymore Gaming"
ENT.Author    = "jonjo"

ENT.Spawnable = false

if CLIENT then --Client-side
    function ENT:Draw()
        self:DrawModel()
    end
end