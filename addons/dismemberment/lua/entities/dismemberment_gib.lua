AddCSLuaFile()

ENT.Type      = "anim"
ENT.Base      = "base_gmodentity"

ENT.PrintName = "Gib"
ENT.Author    = "jonjo"

ENT.Spawnable = true

if SERVER then
    function ENT:Initialize()
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
		self:SetTrigger(true)
    end

	function ENT:PhysicsCollide(colDat, physObj)
		if colDat.OurOldVelocity:Length() > 100 then
			util.Decal("Blood", colDat.HitPos + colDat.HitNormal, colDat.HitPos - colDat.HitNormal)
		end
	end
end
