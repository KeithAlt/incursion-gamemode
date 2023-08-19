
if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType 		= "rpg"
end

if (CLIENT) then
	SWEP.PrintName 		= "Fat Man"
	SWEP.Slot 			= 3
	SWEP.SlotPos 		= 1
	SWEP.IconLetter 		= " "
	SWEP.ViewModelFOV 		= 65

	killicon.AddFont("weapon_real_cs_ak47", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.EjectDelay			= 0

SWEP.Instructions 		= " "

SWEP.Base 				= "weapon_stef_base"
SWEP.Category				= "Fallout Sweps - Projectile Weapons"

SWEP.Spawnable 			= true
SWEP.AdminSpawnable 		= true
SWEP.HoldType 		= "rpg"
SWEP.ViewModelFlip 		= false

SWEP.ViewModel			= "models/weapons/v_fatman.mdl"
SWEP.WorldModel			= "models/weapons/w_fatman.mdl"
SWEP.MuzzleEffect			= "none" -- This is an extra muzzleflash effect
SWEP.Primary.Sound 		= Sound("weapon_fatman.Single")
SWEP.Primary.Recoil 		= 5
SWEP.Primary.Damage 		= 1
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 		= 0.023
SWEP.Primary.ClipSize 		= 1
SWEP.Primary.Delay 		= 1
SWEP.Primary.DefaultClip 	= 4
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 		= "MiniNuke"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.IronSightsPos = Vector (0, 0, 0)
SWEP.IronSightsAng = Vector (0, 0, 0)

/*---------------------------------------------------------
Think
---------------------------------------------------------*/
function SWEP:Think()
	if self.Owner:KeyDown(IN_SPEED) then
				self:SetHoldType("normal")
	else
			self:SetHoldType(self.HoldType)
	end
	if self.MoveTime and self.MoveTime < CurTime() and SERVER then
		self.MoveTime = nil
	end
end


local ActIndex = {
	[ "pistol" ] 		= ACT_HL2MP_IDLE_PISTOL,
	[ "revolver" ] 		= ACT_HL2MP_IDLE_REVOLVER,
	[ "smg" ] 			= ACT_HL2MP_IDLE_SMG1,
	[ "grenade" ] 		= ACT_HL2MP_IDLE_GRENADE,
	[ "ar2" ] 			= ACT_HL2MP_IDLE_AR2,
	[ "shotgun" ] 		= ACT_HL2MP_IDLE_SHOTGUN,
	[ "rpg" ]	 		= ACT_HL2MP_IDLE_RPG,
	[ "physgun" ] 		= ACT_HL2MP_IDLE_PHYSGUN,
	[ "crossbow" ] 		= ACT_HL2MP_IDLE_CROSSBOW,
	[ "melee" ] 		= ACT_HL2MP_IDLE_MELEE,
	[ "slam" ] 			= ACT_HL2MP_IDLE_SLAM,
	[ "normal" ]		= ACT_HL2MP_IDLE,
	[ "fist" ]			= ACT_HL2MP_IDLE_FIST,
	[ "melee2" ]		= ACT_HL2MP_IDLE_MELEE2,
	[ "passive" ]		= ACT_HL2MP_IDLE_PASSIVE,
	[ "knife" ]			= ACT_HL2MP_IDLE_KNIFE
}

/*---------------------------------------------------------
Initialize
---------------------------------------------------------*/
function SWEP:Initialize()
self:SetHoldType( self.HoldType )
end


function SWEP:SetHoldType( t )
	local index = ActIndex[ t ]
	if (index == nil) then
		Msg( "SWEP:SetHoldType - ActIndex[ \""..t.."\" ] isn't set! (defaulting to normal)\n" )
		t = "normal"
	end
	self.ActivityTranslate = {}
	self.ActivityTranslate [ ACT_MP_STAND_IDLE ] 				= index
	self.ActivityTranslate [ ACT_MP_WALK ] 						= index+1
	self.ActivityTranslate [ ACT_MP_RUN ] 						= index+2
	self.ActivityTranslate [ ACT_MP_CROUCH_IDLE ] 				= index+3
	self.ActivityTranslate [ ACT_MP_CROUCHWALK ] 				= index+4
	self.ActivityTranslate [ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] 	= index+5
	self.ActivityTranslate [ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = index+5
	self.ActivityTranslate [ ACT_MP_RELOAD_STAND ]		 		= index+6
	self.ActivityTranslate [ ACT_MP_RELOAD_CROUCH ]		 		= index+6
	self.ActivityTranslate [ ACT_MP_JUMP ] 						= index+7
	self.ActivityTranslate [ ACT_RANGE_ATTACK1 ] 				= index+8
	if t == "normal" then
		self.ActivityTranslate [ ACT_MP_JUMP ] = ACT_HL2MP_JUMP_SLAM
	end
	if t == "passive" then
		self.ActivityTranslate [ ACT_MP_CROUCH_IDLE ] = ACT_HL2MP_CROUCH_IDLE
	end
	if t == "knife" || t == "melee2" then
		self.ActivityTranslate [ ACT_MP_CROUCH_IDLE ] = nil
	end
	self:SetupWeaponHoldTypeForAI( t )
	self._InternalHoldType = t
end


function SWEP:PrimaryAttack()

	if not self:CanPrimaryAttack() or self.Owner:WaterLevel() > 2 then return end
	-- If your gun have a problem or if you are under water, you'll not be able to fire

	self.Reloadaftershoot = CurTime() + self.Primary.Delay
	-- Set the reload after shoot to be not able to reload when firering

	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	-- Set next secondary fire after your fire delay
	--self:LaunchNade()
	
	timer.Create( "fatman_timer", 0.26, 1, function()
if SERVER then
local LaunchedGren = ents.Create("stef_fo3_mininuke")
LaunchedGren:SetPos(self.Owner:GetShootPos() + self.Owner:EyeAngles():Forward()*8 + self.Owner:EyeAngles():Right()*2 - self.Owner:EyeAngles():Up()*1)
LaunchedGren:SetAngles(self.Owner:EyeAngles())
LaunchedGren:SetOwner(self.Owner)
LaunchedGren:Spawn()
LaunchedGren:Activate()
LaunchedGren:SetVelocity(self.Owner:EyeAngles():Forward()*900 + Vector(0,0,100))
end
self:RecoilPower()
	self:TakePrimaryAmmo(1)
	-- Take 1 ammo in you clip
end )
	
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	-- Set next primary fire after your fire delay
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Weapon:EmitSound(self.Primary.Sound)
	-- Emit the gun sound when you fire

	



	if ((game.SinglePlayer() and SERVER) or CLIENT) then
		self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
	end
end

function SWEP:RecoilPower()

	if not self.Owner:IsOnGround() then
		if (self:GetIronsights() == true) then
			
			-- Put normal recoil when you're in ironsight mod

			self.Owner:ViewPunch(Angle(math.Rand(-2.5,2.5) * (self.Primary.Recoil), math.Rand(-2.5,2.5) * (self.Primary.Recoil), 0))
			-- Punch the screen 1x less hard when you're in ironsigh mod
		else
			
			-- Recoil * 2.5

			self.Owner:ViewPunch(Angle(math.Rand(-2.5,2.5) * (self.Primary.Recoil * math.Rand(-2.5,2.5)), math.Rand(-2.5,2.5) * (self.Primary.Recoil), 0))
			-- Punch the screen * 2.5
		end

	elseif self.Owner:KeyDown(IN_FORWARD, IN_BACK, IN_MOVELEFT, IN_MOVERIGHT) then
		if (self:GetIronsights() == true) then
			
			-- Put recoil / 2 when you're in ironsight mod

			self.Owner:ViewPunch(Angle(math.Rand(-2.5,2.5) * (self.Primary.Recoil / 1.5), math.Rand(-2.5,2.5) * (self.Primary.Recoil / 1.5), 0))
			-- Punch the screen 1.5x less hard when you're in ironsigh mod
		else
			
			-- Recoil * 1.5

			self.Owner:ViewPunch(Angle(math.Rand(-2.5,2.5) * (self.Primary.Recoil * 1.5), math.Rand(-2.5,2.5) * (self.Primary.Recoil * 1.5), 0))
			-- Punch the screen * 1.5
		end

	elseif self.Owner:Crouching() then
		if (self:GetIronsights() == true) then
			
			-- Put 0 recoil when you're in ironsight mod

			self.Owner:ViewPunch(Angle(math.Rand(-2.5,2.5) * (self.Primary.Recoil / 3), math.Rand(-2.5,2.5) * (self.Primary.Recoil / 3), 0))
			-- Punch the screen 3x less hard when you're in ironsigh mod
		else
			
			-- Recoil / 2

			self.Owner:ViewPunch(Angle(math.Rand(-2.5,2.5) * (self.Primary.Recoil / 2), math.Rand(-2.5,2.5) * (self.Primary.Recoil / 2), 0))
			-- Punch the screen / 2
		end
	else
		if (self:GetIronsights() == true) then
			
			-- Put recoil / 4 when you're in ironsight mod

			self.Owner:ViewPunch(Angle(math.Rand(-2.5,2.5) * (self.Primary.Recoil / 2), math.Rand(-2.5,2.5) * (self.Primary.Recoil / 2), 0))
			-- Punch the screen 2x less hard when you're in ironsigh mod
		else
			
			-- Put normal recoil when you're not in ironsight mod

			self.Owner:ViewPunch(Angle(math.Rand(-2.5,2.5) * self.Primary.Recoil, math.Rand(-2.5,2.5) *self.Primary.Recoil, 0))
			-- Punch the screen
		end
	end
end

function SWEP:Reload()

	if ( self.Reloadaftershoot > CurTime() ) then return end 
	-- If you're firing, you can't reload

	self.Weapon:DefaultReload(ACT_VM_RELOAD) 
	-- Animation when you're reloading

	if ( self.Weapon:Clip1() < self.Primary.ClipSize ) and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
	-- When the current clip < full clip and the rest of your ammo > 0, then

		self.Owner:SetFOV( 0, 0.5 )
		-- Zoom = 0
		
			timer.Create( "fatman_reload6", 4.9, 1, function()
			self:EmitSound( "weapons/fatman/reload/kawaiidesu.wav" )
		end)
			timer.Create( "fatman_reload5", 3.9, 1, function()
			self:EmitSound( "weapons/fatman/reload/whizz.wav" )
		end)
				timer.Create( "fatman_reload4", 3.15, 1, function()
			self:EmitSound( "weapons/fatman/reload/nuke_place.wav" )
		end)
				timer.Create( "fatman_reload3", 2.8, 1, function()
			self:EmitSound( "weapons/fatman/reload/plonk.wav" )
		end)
				timer.Create( "fatman_reload2", 1.35, 1, function()
			self:EmitSound( "weapons/fatman/reload/wpn_fatman_unequip.wav" )
		end)
			self:EmitSound( "weapons/fatman/reload/slide.wav" )

		self:SetIronsights(false)
		-- Set the ironsight to false
	end
end

function SWEP:Deploy()

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	-- Set the deploy animation when deploying
	
	self.Reloadaftershoot = CurTime() + 1
	-- Can't shoot while deploying
	self.Owner:EmitSound( "weapons/fatman/wpn_fatman_equip.wav" )
	self:SetIronsights(false)
	-- Set the ironsight mod to false

	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	-- Set the next primary fire to 1 second after deploying

	return true
end


