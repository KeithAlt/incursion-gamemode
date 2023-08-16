if SERVER then
    util.AddNetworkString("WARHORN_ShowUI")
end

SWEP.PrintName = "War Horn"
SWEP.Category = "Caesar's Legion Banners"
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Author = "Lenny"

SWEP.HoldType = "slam"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "rpg"
SWEP.Primary.Damage         = 0
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay = 1.1
SWEP.Primary.Ammo       = "none"

SWEP.Primary.ClipSize  = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic  = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.WorldModel = "models/props_lab/huladoll.mdl"
SWEP.ViewModel = ""

SWEP.BuffRadius = 600
SWEP.Cooldown = 120
local ResistanceBuffTime = 120
local DamageBuffTime = 120
local inspirationTime = 120
local meta = FindMetaTable("Player")

if SERVER then
    function meta:Inspire()
		local drBuff = 8
		local dmgBuff = 8

        self:AddDR(drBuff, ResistanceBuffTime)
        self:AddDMG(dmgBuff, DamageBuffTime)
        self:falloutNotify("You feel inspired by the sound of the war horn.")
        self.Inspired = true

        net.Start("WARHORN_ShowUI")
        net.Send(self)

        self:ScreenFade(SCREENFADE.IN, Color(255, 204, 38, 255), 0.3, 0)
        timer.Simple(0, function()
            ParticleEffectAttach("_ax_barrel_fire_flame", PATTACH_POINT_FOLLOW, self, 0)
        end)

        local dur = SoundDuration("warcry/warbell.ogg")
        timer.Remove(self:EntIndex() .. "warhornsound")
        self:EmitSound("warcry/warbell.ogg", 100)
        timer.Create(self:EntIndex() .. "warhornsound", 12, 0, function()
            if IsValid(self) then
                self:StopSound("warcry/warbell.ogg")

                // wait a tick or it will be weird
                timer.Simple(0, function()
                    self:EmitSound("warcry/warbell.ogg", 100)
                end)
            end
        end)

        local ply = self

        timer.Simple(inspirationTime, function()
            if IsValid(ply) then
                ply.Inspired = false
                ply:StopParticles()
                timer.Remove(ply:EntIndex() .. "warhornsound")
                ply:StopSound("warcry/warbell.ogg")
            end
        end)

		jlib.Announce(
			ply, Color(255, 255, 0, 255), "[INSPIRE] ", Color(155, 255, 155, 255), "A bloody rage fuels & buffs you by:",
			Color(255, 255, 255, 255),	"\n 	|_ ", Color(255,255,0), "[DR] ", Color(100,255,100), "+ " .. drBuff,
			Color(255, 255, 255, 255),	"\n 	|_ ", Color(255,255,0), "[DMG] ", Color(100,255,100), "+ " .. dmgBuff
		)
    end

    function SWEP:PrimaryAttack()
        local ply = self:GetOwner()
        if SERVER then
            if not IsFirstTimePredicted and self:CanPrimaryAttack() then return end
            self:SetNextPrimaryFire(CurTime() + self.Cooldown)
            ply:EmitSound("warcry/horn.ogg")
            jlib.Announce(player.GetAll(), Color(255, 150, 0), "The echos of a war horn can be heard ringing in the distance . . .")

            timer.Simple(1, function()
                for index, playerObj in pairs(player.GetAll()) do
                    if playerObj:Team() and playerObj:Team() == ply:Team() then
                        playerObj:Inspire()
                    end
                end
            end)

			self:Remove()
        end
    end

    util.AddNetworkString("WARHORN_ShowUI")

    hook.Add("ScalePlayerDamage", "WARHORN_DECAP", function(ply, hit, info)
        // Taken from sv_dismemberment.
        local attacker = info:GetAttacker()

        if attacker.Inspired and IsValid(ply) and IsValid(attacker) then
            timer.Simple(.1, function()
                if not ply:Alive() then
                    Dismemberment.QuickDismember(ply, HITGROUP_HEAD, attacker)
                end
            end)
        end
    end)

    hook.Add("PlayerDeath", "WARHORN_StopInspiration", function(ply)
        ply.Inspired = false
        timer.Remove(ply:EntIndex() .. "warhornsound")
        ply:StopSound("warcry/warbell.ogg")
    end)
end

function SWEP:Deploy()
	if SERVER then
		if IsValid(self.ent) then return end
		self:SetNoDraw(true)
		self.ent = ents.Create("prop_physics")
			self.ent:SetModel("models/roman_flags_standard/roman_silver_signum.mdl")
			self.ent:SetModelScale(self.ent:GetModelScale() * 1.25, 1)
			self.ent:SetPos(self.Owner:GetPos() + Vector(13,0,160) + (self.Owner:GetForward()*30))
			self.ent:SetAngles(Angle(0,self.Owner:EyeAngles().y,self.Owner:EyeAngles().r))
			self.ent:SetParent(self.Owner)
			self.ent:Fire("SetParentAttachmentMaintainOffset", "eyes", 0.01)
			self.ent:SetCollisionGroup( COLLISION_GROUP_WORLD )
            self.ent:SetColor(Color(255, 204, 38, 255))
			self.ent:Spawn()
			self.ent:Activate()
    end
	return true
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
		self:SetColor(Color(255, 204, 38, 255))
		if not IsValid(self.ent) then return end
		self.ent:Remove()
	end
end

function SWEP:OnRemove()
	if SERVER then
		self:SetColor(Color(255, 204, 38, 255))
		if not IsValid(self.ent) then return end
		self.ent:Remove()
	end
end
