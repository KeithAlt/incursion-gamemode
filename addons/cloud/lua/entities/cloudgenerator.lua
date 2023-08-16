AddCSLuaFile()

ENT.Type      = "anim"
ENT.Base      = "base_gmodentity"

ENT.Category  = "Claymore Gaming"
ENT.PrintName = "Cloud Generator"
ENT.Author    = "jonjo"

ENT.Spawnable = true

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/props_vehicles/generatortrailer01.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        self:PhysWake()

        self:SetMaxHealth(600)
        self:SetHealth(600)
    end

    function ENT:OnTakeDamage(dmg)
        print(dmg:GetInflictor(), dmg:GetAttacker())

        if self.Disabled or dmg:GetInflictor() == self then return end

        self:TakePhysicsDamage(dmg)

        self:SetHealth(self:Health() - dmg:GetDamage())
        if self:Health() <= 0 then
            self.Disabled = true

            util.BlastDamage(self, dmg:GetAttacker(), self:GetPos(), 300, 200)

            local data = EffectData()
            data:SetOrigin(self:GetPos())

            util.Effect("Explosion", data)

            self:Remove()
        end
    end

    function ENT:Use(ply)
        self:SetStatus(!self:GetStatus())

        if self:GetStatus() then
            self:StartGeneration()
        else
            self:StopGeneration()
        end
    end

    function ENT:StartGeneration()
        self.mins = self:GetPos() - Vector(TheCloud.Config.GeneratorZoneSize / 2, TheCloud.Config.GeneratorZoneSize / 2, 0)
        self.maxs = self:GetPos() + Vector(TheCloud.Config.GeneratorZoneSize / 2, TheCloud.Config.GeneratorZoneSize / 2, 0) + Vector(0, 0, 100)
        self:SetMins(self.mins)
        self:SetMaxs(self.maxs)

        self.SPos = self:GetPos()
        self.SAng = self:GetAngles()

        self:GetPhysicsObject():EnableMotion(false)

        self.SoundID = self:StartLoopingSound("OBJ_Workshop_GeneratorLarge_01_LOOP.wav")
    end

    function ENT:StopGeneration()
        self:GetPhysicsObject():EnableMotion(true)

        self:StopLoopingSound(self.SoundID)
    end

    function ENT:Think()
        if !self:GetStatus() then return end

        self:NextThink(CurTime() + 1)

        local plys = jlib.FindPlayersInBox(self.mins, self.maxs)

        for _, ply in pairs(plys) do
            local char = ply:getChar()
            if char then
                local faction = nut.faction.indices[char:getFaction()].uniqueID
                if TheCloud.Config.ImmuneFactions[faction] then
                    continue
                end
            end

            ply:TakeDamage(TheCloud.Config.GeneratorDamage)

            if char then
                char:setVar("DmgTakenFromCloud", char:getVar("DmgTakenFromCloud", 0) + TheCloud.Config.GeneratorDamage)

                if char:getVar("DmgTakenFromCloud", 0) > TheCloud.Config.DamageForInfection then
                    ply:Give(TheCloud.Config.InfectionSWEP)
                    char:setVar("DmgTakenFromCloud", 0)
                end
            end
        end

        self:SetPos(self.SPos)
        self:SetAngles(self.SAng)
        self:GetPhysicsObject():EnableMotion(false)

        return true
    end

    function ENT:OnRemove()
        hook.Remove("PhysgunPickup", "NoPickup" .. self:EntIndex())

        if self.SoundID then
            self:StopLoopingSound(self.SoundID)
        end
    end
end

if CLIENT then
    function ENT:CreateFog()
        local mins, maxs = self:GetMins(), self:GetMaxs()

        local area = math.abs((maxs.x - mins.x) * (maxs.y - mins.y))

        local amt = area / 7000 * GetConVar("falloutRadsZonePlacer_fogDens"):GetFloat()

        local particles = {}

        for i = 1, amt do
            local particle = TheCloud.Emitter:Add(string.format("particle/smokesprites_00%02d", math.random(7,16)), Vector(math.Rand(maxs.x, mins.x), math.Rand(maxs.y, mins.y), math.max(maxs.z, mins.z)))
            particle:SetAirResistance(0)
            particle:SetVelocity(Vector(0, 0, -100000))
            particle:SetLifeTime(0)
            particle:SetDieTime(300)
            particle:SetColor(180, 0, 0)
            particle:SetStartAlpha(120)
            particle:SetEndAlpha(120)
            particle:SetCollide(true)
            particle:SetStartSize(100)
            particle:SetEndSize(100)
            particle:SetRoll(math.Rand(0,360))
            particle:SetRollDelta(0.01 * math.Rand(-40, 40))
            table.insert(particles, particle)
        end

        self.Particles = particles
    end

    function ENT:RemoveFog()
        if istable(self.Particles) then
            for k, v in pairs(self.Particles) do
                v:SetLifeTime(v:GetDieTime())
            end

            self.Particles = nil
        end
    end

    function ENT:Draw()
        self:DrawModel()

        local inRange = LocalPlayer():GetPos():DistToSqr(self:GetPos()) < 1000000

        if self:GetStatus() and !self.Particles and inRange then
            self:CreateFog()

            local timerID = "FogTimer" .. self:EntIndex()
            timer.Create("FogTimer" .. self:EntIndex(), 300, 0, function()
                if !IsValid(self) then
                    timer.Remove(timerID)
                    return
                end

                if self:GetStatus() and inRange then
                    self:CreateFog()
                end
            end)
        elseif self.Particles and (!self:GetStatus() or !inRange) then
            self:RemoveFog()
        end
    end

    function ENT:OnRemove()
        self:RemoveFog()
    end
end

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Status")
    self:NetworkVar("Vector", 0, "Mins")
    self:NetworkVar("Vector", 1, "Maxs")

    if SERVER then
        self:SetStatus(false)
    end
end

hook.Add("PhysgunPickup", "Cloudgenerator", function(ply, ent)
    if ent:GetClass() == "cloudgenerator" and ent:GetStatus() then
        return false
    end
end)