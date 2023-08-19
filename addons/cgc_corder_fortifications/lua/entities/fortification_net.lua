AddCSLuaFile( )
ENT.Type            = "anim"
ENT.Base            = "base_anim"
ENT.PrintName		= "Net"
ENT.Author			= "Lenny"
ENT.Spawnable       = true
ENT.Category        = "Claymore Gaming : Fortifications"

function ENT:Initialize()
    self:SetModel("models/props_trenches/r_trenchcamo3.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)

    self:SetPos( self:GetPos() - Vector(0, 0, 18))

    if SERVER then
        self:SetMaxHealth(3000)
        self:SetHealth(3000)
    end

    self.slowedPlayers = {}
end

function ENT:Think()
    // cant add here for some reason...
    local min, max = self:GetCollisionBounds()
    min = min + self:GetPos()
    max = max + self:GetPos()
    
    local entList = ents.FindInBox(min, max)

    for _, ply in ipairs(entList) do
        if !ply:IsPlayer() then continue end
        if ply:WearingPA() then continue end
        if self.slowedPlayers[ply:EntIndex()] then continue end

        ply:SprintDisable()
        self.slowedPlayers[ply:EntIndex()] = ply:GetWalkSpeed()
        ply:SetWalkSpeed( ply:GetWalkSpeed() - 30 )
    end

    for slowed, oldSpeed in pairs(self.slowedPlayers) do
        local ply = ents.GetByIndex(slowed)
        local inside = ply:GetPos():WithinAABox(min, max)
        if inside then continue end

        ply:SprintEnable()
        ply:SetWalkSpeed(oldSpeed)
        self.slowedPlayers[slowed] = nil
    end

    self:NextThink(CurTime() + .1)
    return true
end

function ENT:OnRemove()
    for slowed, oldSpeed in pairs(self.slowedPlayers) do
        local ply = ents.GetByIndex(slowed)
        if IsValid(ply) then
            ply:SprintEnable()
            ply:SetWalkSpeed(oldSpeed)
            self.slowedPlayers[slowed] = nil
        end
    end
end


function ENT:OnTakeDamage(dmg)
    if self:Health() < 0 then return end    

    self:SetHealth( self:Health() - dmg:GetDamage() )

    local attacker = dmg:GetAttacker()
    if attacker:IsPlayer() and attacker:GetActiveWeapon() and attacker:GetActiveWeapon():GetClass() == "hammer" then return end

    if self:Health() - dmg:GetDamage() <= 0 then

        timer.Simple(1, function()
            self:Remove()
        end)

        ParticleEffect("vj_explosion2", self:GetPos(), Angle(0,0,0), nil)
    end
end