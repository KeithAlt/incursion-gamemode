AddCSLuaFile()

ENT.Type      = "anim"
ENT.Base      = "base_gmodentity"

ENT.PrintName = "Plastic Surgeon"
ENT.Author    = "jonjo"
ENT.Category  = "Claymore Gaming"

ENT.Spawnable = true

if SERVER then
    function ENT:Initialize()
        self:SetModel(Armor.Config.SurgeonModel or "models/Humans/Group01/Female_01.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
		self:DropToFloor()
    end

	function ENT:Use(ply)
		net.Start("ArmorSurgeon")
			net.WriteBool(false)
		net.Send(ply)
	end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end
