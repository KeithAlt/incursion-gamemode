AddCSLuaFile( )
ENT.Type            = "anim"
ENT.Base            = "base_anim"
ENT.PrintName		= "Barbed Wire"
ENT.Author			= "Lenny"
ENT.Spawnable       = true
ENT.Category        = "Claymore Gaming : Fortifications"

function ENT:Initialize()
    self:SetModel("models/props_trenches/lapland02_128.mdl")

    if SERVER then
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        self:SetMaxHealth(5000)
        self:SetHealth(5000)
    end
end

function ENT:StartTouch(ply)
    if !ply:IsPlayer() then return end

    ply:SetVelocity(ply:GetForward() * -250)
    ply:TakeDamage(10)

    local effect = EffectData()
    effect:SetOrigin(ply:GetShootPos())
    util.Effect("BloodImpact", effect)
end

function ENT:OnTakeDamage(dmg)
    if self:Health() < 0 then return end    

    self:SetHealth( self:Health() - dmg:GetDamage() )

    local attacker = dmg:GetAttacker()
    if attacker:IsPlayer() and attacker:GetActiveWeapon() and attacker:GetActiveWeapon():GetClass() == "hammer" then return end

    if self:Health() - dmg:GetDamage() <= 0 and !self.deleting then
        self.deleting = true

        self:Remove()
        ParticleEffect("vj_explosion2", self:GetPos(), Angle(0,0,0), nil)
    end
end