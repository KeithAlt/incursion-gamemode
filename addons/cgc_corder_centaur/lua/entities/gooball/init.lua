AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
ENT.Delay = 10

function ENT:Initialize()
    local mdl = self:GetModel()

    if not mdl or mdl == "" or mdl == "models/error.mdl" then
        self:SetModel("models/fallout/weapons/proj_missile.mdl")
    end

    self.Entity:PhysicsInit(SOLID_VPHYSICS)
    self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
    self.Entity:SetSolid(SOLID_VPHYSICS)
    self.SpawnTime = CurTime()
    self.PhysObj = self.Entity:GetPhysicsObject()
    self.damage = 30

    if self.PhysObj:IsValid() then
        self.PhysObj:Wake()
    end

    self:SetFriction(self.Delay)
    self.killtime = CurTime() + self.Delay

    timer.Simple(.3, function()
        if IsValid(self.PhysObj) then
            self.PhysObj:SetVelocity(self.Owner:GetForward() * 1500)
        end
        ParticleEffectAttach("mr_acid_trail", PATTACH_ABSORIGIN_FOLLOW, self, 1)
    end)
end

function ENT:Think()
    if self.killtime < CurTime() then
        self:Explode()

        return false
    end

    self:NextThink(CurTime())

    return true
end

--[[---------------------------------------------------------
   Name: ENT:Explode()
---------------------------------------------------------]]
function ENT:Explode()
    if not IsValid(self.Owner) then
        self:Remove()

        return
    end

    local dmg = DamageInfo()
    dmg:SetAttacker(self.Owner)
    dmg:SetDamage(self.damage + (self.damage * (0.010 * self.Owner:getSpecial("p"))))
    
    timer.Simple(0, function()
        local groundEffect = ents.Create("mr_effect50")
        groundEffect:SetPos(self:GetPos())
        groundEffect:Spawn()
        
        timer.Simple(1, function()
            groundEffect:Remove()
        end)
    end)


    for _, v in ipairs(ents.FindInSphere(self:GetPos(), 300)) do
        if not v:IsPlayer() then continue end
        if v == self.Owner then continue end
        if v:GetMoveType() == MOVETYPE_NOCLIP then continue end
        if not IsValid(v) then continue end

        local deaths = v:Deaths()

        timer.Create(v:EntIndex() .. "GOOTIME", 1, 10, function()
            if not IsValid(v) or not v:Alive() or deaths < v:Deaths() then
                timer.Remove(v:EntIndex() .. "GOOTIME")
                return
            end

            v:TakeDamageInfo(dmg)
            ParticleEffectAttach("mr_acid_trail", PATTACH_POINT_FOLLOW, v, 1)

            timer.Simple(.3, function()
                v:StopParticles()
            end)
        end)
    end

    self:Remove()
end

--[[---------------------------------------------------------
   Name: ENT:PhysicsCollide()
---------------------------------------------------------]]
function ENT:PhysicsCollide(data, physobj)
    self:Explode()
end

function ENT:PhysicsCollide(data, phys)
    if data.Speed > 60 then
        --self.killtime = CurTime() - 1
        self:Explode()
    end
end