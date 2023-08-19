AddCSLuaFile( )
ENT.Type            = "anim"
ENT.Base            = "base_anim"
ENT.PrintName		= "Building"
ENT.Author			= "Lenny"
ENT.Spawnable       = true
ENT.Category        = "Claymore Gaming : Fortifications"


function ENT:SetupDataTables()
    self:NetworkVar("Int", 1, "BuildStatus")
    self:NetworkVarNotify( "BuildStatus", self.BuildStatusChange )
end

function ENT:BuildStatusChange(_, old, new)
    local effectdata = EffectData()
    effectdata:SetOrigin( self:GetPos() )
    util.Effect( "flash_smoke", effectdata )

    if new == 10 and SERVER then
        local ent = ents.Create(self.fortification)
        ent:SetPos(self:GetPos())
        ent:SetAngles(self:GetAngles())
        ent:Spawn()
        ent.Owner = self.Owner

        ent:GetPhysicsObject():Wake()

        self:Remove()
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

function ENT:Initialize()
    self:SetModel("models/props_junk/iBeam01a_cluster01.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    if SERVER then
        self:SetMaxHealth(500)
        self:SetHealth(500)
    end
end
