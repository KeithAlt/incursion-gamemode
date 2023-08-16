AddCSLuaFile("shared.lua")



if CLIENT then
SWEP.PrintName = "Ghoul"
SWEP.Category         = "Fallout Monsters"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.CSMuzzleFlashes = false
end

SWEP.Spawnable = true 
SWEP.AdminSpawnable = true 
SWEP.HoldType = "knife"
SWEP.Author = "UnionRP"
SWEP.Purpose = ""
SWEP.Instructions = ""

SWEP.ViewModel = ""
SWEP.WorldModel = "" 

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 1.5 

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

function SWEP:Precache()
	util.PrecacheModel(self.ViewModel)

    util.PrecacheSound("ghoul/attack1.wav")
    util.PrecacheSound("ghoul/attack2.wav")
    util.PrecacheSound("ghoul/attack3.wav")
    util.PrecacheSound("ghoul/attack4.wav")
    util.PrecacheSound("ghoul/hit1.wav")
    util.PrecacheSound("ghoul/hit2.wav")
    util.PrecacheSound("ghoul/hit3.wav")
    util.PrecacheSound("ghoul/scream1.wav")
    util.PrecacheSound("ghoul/scream2.wav")
    util.PrecacheSound("ghoul/scream3.wav")
    
end

function SWEP:Think()
    if not self.NextHit or CurTime() < self.NextHit then return end
    self.NextHit = nil

    local pl = self.Owner

    local vStart = pl:EyePos() + Vector(0, 0, -10)
    local trace = util.TraceLine({start=vStart, endpos = vStart + pl:GetAimVector() * 71, filter = pl, mask = MASK_SHOT})

    local ent
    if trace.HitNonWorld then
        ent = trace.Entity
    elseif self.PreHit and self.PreHit:IsValid() and not (self.PreHit:IsPlayer() and not self.PreHit:Alive()) and self.PreHit:GetPos():Distance(vStart) < 110 then
        ent = self.PreHit
        trace.Hit = true
    end

    if trace.Hit then
        pl:EmitSound("npc/zombie/claw_strike"..math.random(1, 3)..".wav")
    end

    pl:EmitSound("npc/zombie/claw_miss"..math.random(1, 2)..".wav")
    self.PreHit = nil

    if ent and ent:IsValid() and not (ent:IsPlayer() and not ent:Alive()) then
            local damage = 25
            local phys = ent:GetPhysicsObject()
            if phys:IsValid() and not ent:IsNPC() and phys:IsMoveable() then
                local vel = damage * 487 * pl:GetAimVector()

                phys:ApplyForceOffset(vel, (ent:NearestPoint(pl:GetShootPos()) + ent:GetPos() * 2) / 3)
                ent:SetPhysicsAttacker(pl)
            end
            if not CLIENT and SERVER then
            ent:TakeDamage(damage, pl, self)
        end
    end
end

SWEP.NextSwing = 0
function SWEP:PrimaryAttack()
    if CurTime() < self.NextSwing then return end
	
	local attack = math.random(1,2)
	if attack == 1 then self:SendWeaponAnim(ACT_VM_SECONDARYATTACK) else
	if attack == 2 then self:SendWeaponAnim(ACT_VM_HITCENTER) end
end
	
	self.Owner:DoAnimationEvent(ACT_GMOD_GESTURE_RANGE_ZOMBIE)
	
    self.Owner:EmitSound("ghoul/hit"..math.random(1, 3)..".wav") 
	timer.Simple(1.4, function(wep) self:SendWeaponAnim(ACT_VM_IDLE) end)
    self.NextSwing = CurTime() + self.Primary.Delay
    self.NextHit = CurTime() + 1
    local vStart = self.Owner:EyePos() + Vector(0, 0, -10)
    local trace = util.TraceLine({start=vStart, endpos = vStart + self.Owner:GetAimVector() * 65, filter = self.Owner, mask = MASK_SHOT})
    if trace.HitNonWorld then
        self.PreHit = trace.Entity
    end
end

SWEP.NextMoan = 0
function SWEP:SecondaryAttack()
    if CurTime() < self.NextMoan then return end

	self.Owner:DoAnimationEvent(ACT_GMOD_GESTURE_TAUNT_ZOMBIE)
	
    if SERVER and not CLIENT then
        self.Owner:EmitSound("ghoul/attack"..math.random(1, 4)..".wav")
    end
    self.NextMoan = CurTime() + 2.5 
end

function SWEP:Reload()
    if CurTime() < self.NextMoan then return end

	self.Owner:DoAnimationEvent(ACT_GMOD_GESTURE_TAUNT_ZOMBIE)
	
    if SERVER and not CLIENT then
        self.Owner:EmitSound("ghoul/scream"..math.random(1, 3)..".wav")
    end
    self.NextMoan = CurTime() + 2.5 
end