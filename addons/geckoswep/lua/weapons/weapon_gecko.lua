AddCSLuaFile( )

SWEP.PrintName = "Fire"
SWEP.Author = "Lenny"
SWEP.Instructions = "Left click to attack, right click to leap."

SWEP.Spawnable = true
SWEP.AdminSpawnable = false

SWEP.HoldType = "knife"
SWEP.ViewModel = "models/weapons/c_physcannon.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.ShowViewModel = false;
SWEP.ShowWorldModel = false;

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 1

SWEP.Secondary.ClipSize = 5
SWEP.Secondary.DefaultClip = 5
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 5

SWEP.Slot = 3
SWEP.SlotPos = 4

function SWEP:Deploy()
    self:GetOwner():DrawViewModel( false )
end

function SWEP:DrawWorldModel( flags )
	return false
end

function SWEP:ShouldDrawViewModel()
    return false
end

function SWEP:PrimaryAttack()
    local ply = self:GetOwner()

    if (!ply.BreathingFire) then
        ply.BreathingFire = true;
    end

    if SERVER then
        local tr = ply:TraceHullAttack(ply:GetPos(), ply:GetPos() + (ply:GetForward() * 500), Vector(-10, -10, -10), Vector(10,10,10), 3, DMG_BURN, 1, true)
        if (tr:IsValid()) then
            tr:Ignite(1, 1)
        end
    end

    timer.Simple(1.5, function()
        ply.BreathingFire = false;
    end)

    timer.Create(ply:SteamID64() .. "GeckoFireAnim", 2, 1, function()
        ply.BreathingFire = false
    end)

    local flamefx = EffectData()
    flamefx:SetOrigin( ply:GetPos() + (ply:GetForward() * 500) + (ply:GetUp() * 100) )
    flamefx:SetStart( ply:GetShootPos() )
    flamefx:SetAttachment( 1 )
    flamefx:SetEntity( self )
    util.Effect( "swep_flamethrower_flame", flamefx, true, true )

    timer.Simple(1, function()
        ply.BreathingFire = false;
    end)
end

function SWEP:SecondaryAttack()
    local ply = self:GetOwner()

    if SERVER then
        ply:TraceHullAttack(ply:GetPos(), ply:GetPos() + (ply:GetForward() * 250), Vector(-10, -10, -10), Vector(10,10,10), 6, DMG_SLASH, 50, true)
    end

    ply.Slashing = true
    timer.Create(ply:SteamID64() .. "_slashing", .5, 1, function()
        ply.Slashing = false
    end)
end


hook.Add("EntityTakeDamage", "Gecko_FallProtection", function(target, info)
    if (target:GetModel() != "models/fallout/gecko.mdl") then return end
    if (info:GetDamageType() == DMG_FALL && target.GeckoJump ) then
        target.GeckoJump = false
        info:SetDamage(0)
    end
end)

hook.Add("CalcMainActivity", "GeckoAnims_Weapon", function(ply, velocity)
    if (ply:GetModel() != "models/fallout/gecko.mdl") then return end

    if (ply.BreathingFire) then
        return -1, 2
    end

    if (ply.Slashing) then
        return -1, 9
    end

    if (ply:KeyDown(IN_SPEED) && ply:IsOnGround()) then
        return -1, 24
    end

    if (!ply:IsOnGround()) then
        return -1, 5
    end

    if (velocity * 1 == Vector(0, 0, 0) && ply:IsOnGround()) then
        return -1, 23
    else
        return -1, 25
    end
end)

hook.Add("KeyPress", "GeckoSuperJump_ss", function(ply, key)
    if (ply:GetModel() != "models/fallout/gecko.mdl") then return end
    if (key == IN_JUMP) then
        local JumpSounds = { "npc/fast_zombie/leap1.wav", "npc/zombie/zo_attack2.wav", "npc/fast_zombie/fz_alert_close1.wav", "npc/zombie/zombie_alert1.wav" }
        ply:EmitSound(JumpSounds[math.random(4)])
        ply.GeckoJump = true;
        ply:SetVelocity( ply:GetForward() * 400 + Vector(0,0,400) )
    end
end)
