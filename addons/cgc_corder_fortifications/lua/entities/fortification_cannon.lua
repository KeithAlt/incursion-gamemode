AddCSLuaFile( )
ENT.Type            = "anim"
ENT.Base            = "base_anim"
ENT.PrintName		= "Artillery Cannon"
ENT.Author			= "Lenny"
ENT.Spawnable       = true
ENT.Category        = "Claymore Gaming : Fortifications"

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Loaded")
    self:NetworkVar("Bool", 1, "Disabled")
    self:NetworkVar("Bool", 2, "Reloading")

    self:NetworkVar("Entity", 1, "Controller")

    if SERVER then
        self:SetLoaded(false)
        self:SetDisabled(false)
    end
end

function ENT:Initialize()
    self:SetModel("models/cgc/artillery/cannon.mdl")
    if SERVER then
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)

        self:SetMaxHealth(4000)
        self:SetHealth(4000)
    end    
end

function ENT:AdjustPitch(ang)
    // Limits the maximum angle at -30, preventing further. Could clamp, but would still send networking.
    if self:GetManipulateBoneAngles(1).x <= -30 and ang.x == -1 then return end
    if self:GetManipulateBoneAngles(1).x >= 5 and ang.x == 1 then return end

    self:ManipulateBoneAngles(1, self:GetManipulateBoneAngles(1) + ang);
end

local dist = 250 * 250
function ENT:Think()
    if !self:GetController() then return end

    if !IsValid(self:GetController()) then
        self:SetController(nil)
        return
    end

    if self:GetController():GetPos():DistToSqr(self:GetPos()) > dist then
        if SERVER then
            self:GetController():falloutNotify("You have walked too far away!")
        end
        self:SetController(nil)
        return
    end
end

function ENT:Use(ply)
    if self:GetDisabled() then return end
    if IsValid(self:GetController()) then 
        ply:falloutNotify("The artillery is already being controlled.")
        return 
    end
    
    net.Start("FORTIFICATIONS_ARTILLERYMENU")
        net.WriteEntity(self)
    net.Send(ply)
    self:SetController(ply)
end


local explodeSounds = {
    "fo_sfx/explosion/grenade/frag/fx_explosion_grenade_frag_high_04.ogg",
    "fo_sfx/explosion/grenade/frag/fx_explosion_grenade_frag_high_05.ogg",
    "fo_sfx/explosion/grenade/frag/fx_explosion_grenade_frag_high_06.ogg",
}

function ENT:Shoot()
    if self:GetDisabled() then return end
    if !self:GetLoaded() then
        self:SetReloading(true)
        self:EmitSound("vehicles/sgmcars/tank_fo4/reload.wav", 90, 100)
        timer.Simple(5, function()    
            self:SetReloading(false)
            self:SetLoaded(true)
        end)
        return
    end

    //local pos = self:GetPos() + self:GetForward() * 170 + self:GetUp() * 45
    local pos = self:GetAttachment(1).Pos
    self:EmitSound("vehicles/sgmcars/tank_fo4/fire.wav", 90, 100)

    self:GetPhysicsObject():SetVelocity( self:GetForward() * -50 )

    local rocket = ents.Create("cgc_missile")
    rocket:SetPos(pos)
    rocket:SetAngles(self:GetAttachment(1).Ang)
    rocket:Spawn()

    ParticleEffect("mr_effect_05", pos, self:GetAngles(), self)
    timer.Simple(.2, function()
        self:StopParticles()
    end)

    local collide = rocket.PhysicsCollide
    local phys = rocket:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetVelocity( rocket:GetForward() * 6000 )
    end

    rocket.Think = function()
        if rocket.nextsound and rocket.nextsound > CurTime() then return end
        rocket:EmitSound("fo_sfx/explosion/artillery/near/fx_explosion_artillery_near_02.ogg", 100, 100, 1)

        rocket.nextsound = CurTime() + 1
    end

    rocket.PhysicsCollide = function(data, phys)
        collide(data, phys)
        rocket:EmitSound(explodeSounds[math.random(#explodeSounds)])

        for _,v in ipairs(ents.FindInSphere(rocket:GetPos(), 700)) do // for some reason doesnt already do this, so we will do it here instead
            if v:GetMoveType() == MOVETYPE_NOCLIP then continue end
            v:TakeDamage(250)
        end

        ParticleEffect("vj_explosion2", rocket:GetPos(), Angle(0,0,0), nil)
    end

    self:SetLoaded(false)
end

function ENT:OnTakeDamage(dmg)
    if self:Health() < 0 then return end    
    

    self:SetHealth( self:Health() - dmg:GetDamage() )

    local attacker = dmg:GetAttacker()
    if attacker:IsPlayer() and attacker:GetActiveWeapon() and attacker:GetActiveWeapon():GetClass() == "hammer" then return end

    if self:Health() - dmg:GetDamage() <= 0 and !self:GetDisabled() then
        ParticleEffect("vj_explosion2", self:GetPos(), Angle(0,0,0), nil)
        self:SetColor(Color(48, 48, 48))
        self:SetDisabled(true)

        timer.Simple(1, function()
            ParticleEffect("mr_hugefire_1a", self:GetPos(), self:GetAngles(), self)
        end)

        timer.Simple(15, function()
            self:Remove()
        end)
    end
end