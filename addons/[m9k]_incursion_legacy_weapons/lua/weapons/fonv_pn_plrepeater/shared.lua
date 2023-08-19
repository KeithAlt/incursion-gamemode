SWEP.Spawnable            = true
SWEP.AdminSpawnable        = true
SWEP.UseHands			   = true

SWEP.BounceWeaponIcon  = false

SWEP.Author            = "Deika"
SWEP.Contact        = ""
SWEP.Purpose        = ""
SWEP.Instructions    = "Eat shit"

if CLIENT then

    SWEP.PrintName = "Plasma Repeater"            
	
	SWEP.Category  = "Project Nevada"
	
	SWEP.HoldType = "ar2"
	SWEP.ViewModelFOV = 75
	SWEP.ViewModelFlip = false
	SWEP.ViewModel = "models/weapons/c_plasmarepeater.mdl"
	SWEP.WorldModel = "models/weapons/w_plasmarepeater.mdl"
	SWEP.Slot = 3
    SWEP.SlotPos = 0
	SWEP.ShowViewModel = true
	SWEP.ShowWorldModel = true
	SWEP.ViewModelBoneMods = {}
	
    SWEP.DrawAmmo            = true
    SWEP.DrawCrosshair        = true
    SWEP.CSMuzzleFlashes    = true
	
	SWEP.IconLetter = "."

	
end

	SWEP.ViewModel = "models/weapons/c_plasmarepeater.mdl"
	SWEP.WorldModel = "models/weapons/w_plasmarepeater.mdl"

SWEP.Primary.Sound             = Sound("weapons/plasmarepeater/wpn_rifleplasma_fire.wav")
SWEP.Primary.Damage            = 33
SWEP.Primary.Force             = 1
SWEP.Primary.NumShots          = 1
SWEP.Primary.Delay             = .392
SWEP.Primary.Ammo              = "MicrofusionCell"
SWEP.Primary.Spread 		   = .025

SWEP.Primary.ClipSize        = 24
SWEP.Primary.DefaultClip    =  144
SWEP.Primary.Automatic        = false

SWEP.Secondary.Sound        = Sound("")
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos = Vector(0, 0, 0)
SWEP.IronSightsAng = Vector(0, 0, 0)

SWEP.LastPrimaryAttack = 0
game.AddAmmoType( {
 name = "MircoCell Battery",
 dmgtype = DMG_BULLET,
 tracer = TRACER_LINE,
 plydmg = 0,
 npcdmg = 0,
 force = 2000,
 minsplash = 10,
 maxsplash = 5
} )
function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end		
	local trace = {}
		trace.start = self.Owner:GetShootPos()
		trace.endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 24^14
		trace.filter = self.Owner
	local tr = util.TraceLine(trace)
	
	local vAng = (tr.HitPos-self.Owner:GetShootPos()):GetNormal():Angle()
	
	self.Owner:ViewPunch(Angle( -0.3, -0.3, 0 ))
	
	local bullet = {}
		bullet.Num = self.Primary.NumShots
		bullet.Src = self.Owner:GetShootPos()
		bullet.Dir = self.Owner:GetAimVector()
		bullet.Spread = Vector( self.Primary.Spread , self.Primary.Spread, 0)
		bullet.Tracer = 1
		bullet.TracerName = "none"
		bullet.Force = self.Primary.Force
		bullet.Damage = self.Primary.Damage
		bullet.AmmoType = (self.Primary.Ammo)
	local hit1, hit2 = tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal
	
	local effect = EffectData()
	effect:SetOrigin(tr.HitPos)
	effect:SetNormal(tr.HitNormal)
	effect:SetScale(30)
	
	local effect		= EffectData()
	effect:SetEntity(self.Weapon)
	effect:SetOrigin(self.Owner:GetShootPos())
	effect:SetNormal(self.Owner:GetAimVector())
	util.Effect("fo3_muzzle_plasmarifle", effect)


	
	self.Owner:FireBullets( bullet )
	
	self.Weapon:EmitSound(Sound(self.Primary.Sound))
	self:TakePrimaryAmmo(1)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	
end
function SWEP:Initialize()
	self:SetWeaponHoldType( "ar2" )
end
 

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
	if ( self:Clip1() < self.Primary.ClipSize && self:Ammo1() > 0 ) then
	self.Weapon:EmitSound("weapons/plasmarepeater/magout.wav")
		self:DefaultReload( ACT_VM_RELOAD )
	end
end
function SWEP:Deploy()
self.Weapon:EmitSound("weapons/plasmarepeater/wpn_rifleplasma_equip.wav")
self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
   return true
end