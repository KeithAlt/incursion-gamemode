if SERVER then
    AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "Caesar's Legion Banner"
    SWEP.Category = "Caesar's Legion Banners"
    SWEP.Slot = 3
    SWEP.SlotPos = 1
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false
    SWEP.Author = "Neiremberg"
end

SWEP.HoldType = "slam"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix = "rpg"
SWEP.Primary.Damage = 0
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Delay = 1.1
SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.WorldModel = "models/props_lab/huladoll.mdl"
SWEP.ViewModel = ""
SWEP.BuffExpireTime = 120 -- In seconds

function SWEP:Deploy()
    if SERVER then
        if IsValid(self.ent) then return end
        self:SetNoDraw(true)
        self.ent = ents.Create("prop_physics")
        self.ent:SetModel("models/roman_flags_standard/roman_banner_spqr.mdl")
        self.ent:SetModelScale(self.ent:GetModelScale() * 1.25, 1)
        self.ent:SetPos(self.Owner:GetPos() + Vector(10, 0, 160) + (self.Owner:GetForward() * 28))
        self.ent:SetAngles(Angle(0, self.Owner:EyeAngles().y, self.Owner:EyeAngles().r))
        self.ent:SetParent(self.Owner)
        self.ent:Fire("SetParentAttachmentMaintainOffset", "eyes", 0.01)
        self.ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
        self.ent:Spawn()
        self.ent:Activate()
    end

    return true
end

function SWEP:PrimaryAttack()
    if self.PrimaryCooldown and (CurTime() < self.PrimaryCooldown) then return end
    self:EmitSound("warcry/drum" .. math.random(1, 5) .. ".ogg")
    self.PrimaryCooldown = CurTime() + 2
end



function SWEP:SecondaryAttack()
    if SERVER then
        if self.SecondaryCooldown and (CurTime() < self.SecondaryCooldown) then
            if self.SecondaryNotifCooldown and (CurTime() > self.SecondaryNotifCooldown) and IsValid(self.Owner) then
                self.Owner:falloutNotify("☒ Your call to arms is on cooldown [" .. math.Round(self.SecondaryCooldown - CurTime()) .. "]", "ui/notify.mp3")
                self.SecondaryNotifCooldown = CurTime() + 2
            end

            self.SecondaryNotifCooldown = self.SecondaryNotifCooldown or CurTime()

            return
        end

        self.SecondaryCooldown = CurTime() + 25
        local ply = self.Owner
        ply:EmitSound("warcry/war.ogg")

        for index, nearPly in pairs(ents.FindInSphere(ply:GetPos(), 800)) do
            if nearPly:IsPlayer() and nearPly:Alive() and not nearPly:GetNoDraw() and (nearPly:Team() == ply:Team()) and not nearPly.SPQRBuffActive then

                nearPly:BuffStat("S", 10, self.BuffExpireTime)
                nearPly:AddDR(5, self.BuffExpireTime)
                nearPly:falloutNotify("➲ You've received the blessing of Mars", "shelter/sfx/collect_stimpack.ogg")
                nearPly:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 50), 0.3, 0)
                nearPly.SPQRBuffActive = true
                local target = nearPly

                timer.Simple(0, function()
                    ParticleEffectAttach("_ax_barrel_fire_flame", PATTACH_POINT_FOLLOW, nearPly, 0)
                end)

                timer.Simple(1, function()
                    if IsValid(target) then
                        target:StopParticles()
                    end
                end)

                timer.Simple(self.BuffExpireTime, function()
                    if IsValid(target) and target.SPQRBuffActive then
                        target.SPQRBuffActive = nil
                    end
                end)
            end
        end
    end
end

function SWEP:Holster()
    if SERVER then
        if not IsValid(self.ent) then return end
        self.ent:Remove()
    end

    return true
end

function SWEP:OnDrop()
    if SERVER then
        self:SetColor(Color(255, 255, 255, 255))
        if not IsValid(self.ent) then return end
        self.ent:Remove()
    end
end

function SWEP:OnRemove()
    if SERVER then
        self:SetColor(Color(255, 255, 255, 255))
        if not IsValid(self.ent) then return end
        self.ent:Remove()
    end
end