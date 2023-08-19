/*---------------------------------------------------------
------mmmm---mmmm-aaaaaaaa----ddddddddd---------------------------------------->
     mmmmmmmmmmmm aaaaaaaaa   dddddddddd	  Name: Mad Bomb Collar
     mmm mmmm mmm aaa    aaa  ddd     ddd	  Author: Worshipper
    mmm  mmm  mmm aaaaaaaaaaa ddd     ddd	  Project Start: October 23th, 2009
    mmm       mmm aaa     aaa dddddddddd	  Version: 2.0
---mmm--------mmm-aaa-----aaa-ddddddddd---------------------------------------->
---------------------------------------------------------*/

// Variables that are used on both client and server

game.AddParticles("particles/buu_particles.pcf")

local RecoilMul = CreateConVar ("mad_recoilmul", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE})
local DamageMul = CreateConVar ("mad_damagemul", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE})

SWEP.Category			= "Mad Bomb Collar"

SWEP.MadCow = true
SWEP.Author				= "Worshipper"
SWEP.Contact			= "Josephcadieux@hotmail.com"

// I have nothing to say here because I'm a prick
SWEP.Purpose			= ""
SWEP.Instructions			= ""

SWEP.CSMuzzleFlashes = true

SWEP.ViewModelFOV			= 60
SWEP.ViewModelFlip		= false
SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"
SWEP.AnimPrefix			= "python"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound		= Sound("Weapon_AK47.Single")
SWEP.Primary.Recoil		= 10
SWEP.Primary.Damage		= 10
SWEP.Primary.NumShots		= 1
SWEP.Primary.NumAmmo		= 1
SWEP.Primary.Cone			= 0
SWEP.Primary.Delay 		= 0
SWEP.Primary.SuppressorSound = ""
SWEP.Primary.NoSuppressorSound = ""

SWEP.Primary.ClipSize		= 5					// Size of a clip
SWEP.Primary.DefaultClip	= 5					// Default number of bullets in a clip
SWEP.Primary.Automatic		= false				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1					// Size of a clip
SWEP.Secondary.DefaultClip	= -1					// Default number of bullets in a clip
SWEP.Secondary.Automatic	= false				// Automatic/Semi Auto
SWEP.Secondary.Ammo		= "none"

SWEP.MeleeRange				= 70

SWEP.ActionDelay			= CurTime()
SWEP.ShootDelay				= 0
SWEP.ReloadTime 			= -1

SWEP.FireChance 			= -1


// I added this function because some weapons like the Day of Defeat weapons need 1.2 or 1.5 seconds to deploy
SWEP.DeployDelay			= 1

SWEP.ShellEffect			= "effect_mad_shell_pistol"	// "effect_mad_shell_pistol" or "effect_mad_shell_rifle" or "effect_mad_shell_shotgun"
SWEP.ShellDelay				= 0

// Is it a pistol, a rifle, a shotgun or a sniper? Choose only one of them or you'll fucked up everything. BITCH!
SWEP.Pistol				= false
SWEP.Rifle				= false
SWEP.Shotgun			= false
SWEP.Sniper				= false
SWEP.HoldingPos 		= Vector(0,0,0)
SWEP.HoldingAng 		= Vector(0,0,0)
SWEP.IronSightsPos 		= Vector (0, 0, 0)
SWEP.IronSightsAng 		= Vector (0, 0, 0)
SWEP.RunArmOffset 		= Vector (0, 0, 5.5)
SWEP.RunArmAngle 			= Vector (-35, -3, 0)

// Burst options
SWEP.Burst				= false
SWEP.BurstShots			= 3
SWEP.BurstDelay			= 0.05
SWEP.BurstCounter			= 0
SWEP.BurstTimer			= 0

// Custom mode options (Do not put a burst mode and a custom mode at the same time, it will not work)
SWEP.Type				= 1 					// 1 = Automatic/Semi-Automatic mode, 2 = Suppressor mode, 3 = Burst fire mode
SWEP.Mode				= false

SWEP.data 				= {}
SWEP.data.NormalMsg		= "Switched to semi-automatic."
SWEP.data.ModeMsg			= "Switched to automatic."
SWEP.data.Delay			= 0.5 				// You need to wait 0.5 second after you change the fire mode
SWEP.data.Cone			= 1
SWEP.data.Damage			= 1
SWEP.data.Recoil			= 1
SWEP.data.Automatic		= false

// Constant accuracy means that your crosshair will not change if you're running, shooting or walking
SWEP.ConstantAccuracy		= false

// I don't think it's hard to understand this
SWEP.Penetration			= false
SWEP.MinPenetration			= -1
SWEP.PenetrationDmgMult		= -1
SWEP.Ricochet				= true
SWEP.MaxRicochet			= 1
SWEP.ChainHit				= 3
SWEP.SuperRicochet			= false
SWEP.ExplosiveShot			= false

SWEP.Tracer				= 0					// 0 = Normal Tracer, 1 = Ar2 Tracer, 2 = Airboat Gun Tracer, 3 = Normal Tracer + Sparks Impact

SWEP.IdleDelay			= 0
SWEP.IdleApply			= false
SWEP.AllowIdleAnimation		= true
SWEP.AllowPlaybackRate		= true

SWEP.BoltActionSniper		= false				// Use this value if you want to remove the scope view after you shoot
SWEP.ScopeAfterShoot		= false				// Do not try to change this value

SWEP.IronSightZoom 		= 1.5
SWEP.ScopeZooms			= {10}
SWEP.ScopeScale 			= 0.4

SWEP.ShotgunReloading		= false
SWEP.ShotgunFinish		= 0.5
SWEP.ShotgunBeginReload		= 0.3

SWEP.EmptyReload			= false

SWEP.Offset = { --Procedural world model animation, defaulted for CS:S purposes.
	Pos = {
		Up = 0,
		Right = 0,
		Forward = 0
	},
	Ang = {
		Up = 0,
		Right = 0,
		Forward = 0
	},
	Scale = 1
}
--[[
local function FixHolsters()

	for _, Ply in pairs( player.GetAll() ) do
	
		local Wep = Ply:GetActiveWeapon()
		
		if !IsValid( Wep ) then continue; end
		if !Wep:IsWeapon() then continue; end
		if !Wep.MadCow then continue; end
		
		if Wep.Owner:GetVelocity():Length() > 350 or Wep.Weapon:GetDTBool(0) then
			
			if Wep.Rifle or Wep.Sniper or Wep.Shotgun then
				if ( Ply:Crouching() and Ply:GetVelocity():Length() == 0 ) then
					Wep:SetWeaponHoldType( 'normal' )
				else
					Wep:SetWeaponHoldType( 'passive' )
				end
			elseif Wep.Pistol then
				Wep:SetWeaponHoldType( 'normal' )
			end
			
		else
			Wep:SetWeaponHoldType(Wep.HoldType)
		end
		
	end
end
hook.Add( 'Think', 'FixMadcowHolsters', FixHolsters )
--]]
/*---------------------------------------------------------
   Name: SWEP:Initialize()
   Desc: Called when the weapon is first loaded.
---------------------------------------------------------*/
function SWEP:Initialize()
	if(self.Owner:IsNPC()) then
		self:SetWeaponHoldType("smg")
	else
		self:SetWeaponHoldType(self.HoldType)
	end
	--[[
	if (SERVER and self.Owner:IsNPC()) then
		// Fucking NPCs
		self:SetNPCMinBurst(30)
		self:SetNPCMaxBurst(30)
		self:SetNPCFireRate(self.Primary.Delay)
		self:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_VERY_GOOD )
	end
	--]]
	self.Reloadaftershoot = 0 				-- Can't reload when firing
	self:SetWeaponHoldType(self.HoldType)
	self.Weapon:SetNetworkedBool("Reloading", false)

	PrecacheParticleSystem("smoke_trail")
	
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)
		
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
end

function SWEP:PreDrawViewModel( vm, wep, ply )

	vm:SetMaterial( "" ) -- Hide that view model with hacky material

end

/*---------------------------------------------------------
   Name: ENT:SetupDataTables()
   Desc: Setup the data tables.
---------------------------------------------------------*/
function SWEP:SetupDataTables()  // zDark.com - Fix - 19 August 2010

	self:DTVar("Bool", 0, "Holsted")
	self:DTVar("Bool", 1, "Ironsights")
	self:DTVar("Bool", 2, "Scope")
	self:DTVar("Bool", 3, "Mode")
	
end 

/*---------------------------------------------------------
   Name: SWEP:IdleAnimation()
   Desc: Are you seriously too stupid to understand the function by yourself?
---------------------------------------------------------*/
function SWEP:IdleAnimation(time)

	if not self.AllowIdleAnimation then return false end

	self.IdleApply = true
	self.ActionDelay = CurTime() + time
	self.IdleDelay = CurTime() + time
end

/*---------------------------------------------------------
   Name: SWEP:PrimaryAttack()
   Desc: +attack1 has been pressed.
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	-- Holst/Deploy your fucking weapon
	if (not self.Owner:IsNPC() and self.Owner:KeyDown(IN_USE)) then
		bHolsted = !self.Weapon:GetDTBool(0)
		self:SetHolsted(bHolsted)

		self.Weapon:SetNextPrimaryFire(CurTime() + 0.3)
		self.Weapon:SetNextSecondaryFire(CurTime() + 0.3)

		self:SetIronsights(false)

		return
	end

	if (not self:CanPrimaryAttack()) then return end

	self.ActionDelay = (CurTime() + self.Primary.Delay + 0.05)
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

	-- If the burst mode is activated, it's going to shoot the three bullets (or more if you're dumb and put 4 or 5 bullets for your burst mode)
	if self.Weapon:GetDTBool(3) and self.Type == 3 then
		self.BurstTimer 	= CurTime()
		self.BurstCounter = self.BurstShots - 1
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
	end

	self.Weapon:EmitSound(self.Primary.Sound)

	self:TakePrimaryAmmo(self.Primary.NumAmmo)
	
	self:ShootBulletInformation()
	
	local Vm = self.Owner:GetViewModel()
	if Vm == nil then return end
	
	timer.Create("SmokeTrail",1,1,function()ParticleEffectAttach( "smoke_trail",  PATTACH_POINT_FOLLOW , Vm, Vm:LookupAttachment( "1" )) ParticleEffectAttach( "smoke_trail",  PATTACH_POINT_FOLLOW , Vm, Vm:LookupAttachment( "2" )) end)
end

/*---------------------------------------------------------
   Name: SWEP:SecondaryAttack()
   Desc: +attack2 has been pressed.
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

	if self.Owner:IsNPC() then return end
	if not IsFirstTimePredicted() then return end

	if (self.Owner:KeyDown(IN_USE) and (self.Mode)) then // Mode
		bMode = !self.Weapon:GetDTBool(3)
		self:SetMode(bMode)
		self:SetIronsights(false)

		self.Weapon:SetNextPrimaryFire(CurTime() + self.data.Delay)
		self.Weapon:SetNextSecondaryFire(CurTime() + self.data.Delay)

		return
	end

	if (!self.IronSightsPos) or (self.Owner:KeyDown(IN_SPEED) or self.Weapon:GetDTBool(0)) then return end
	
	// Not pressing Use + Right click? Ironsights
	bIronsights = !self.Weapon:GetDTBool(1)
	self:SetIronsights(bIronsights)

	self.Weapon:SetNextPrimaryFire(CurTime() + 0.2)
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.2)
end

/*---------------------------------------------------------
   Name: SWEP:SetHolsted()
---------------------------------------------------------*/
function SWEP:SetHolsted(b)

	if (self.Owner) then
		if (b) then
			self.Weapon:EmitSound("weapons/universal/iron_in.wav")
		else
			self.Weapon:EmitSound("weapons/universal/iron_out.wav")
		end
	end

	if (self.Weapon) then
		self.Weapon:SetDTBool(0, b)
	end
end

/*---------------------------------------------------------
   Name: SWEP:SetIronsights()
---------------------------------------------------------*/
function SWEP:SetIronsights(b)

	if (self.Owner:IsValid()) then
		if (b) then
			if (SERVER) then
				self.Owner:SetFOV(65, 0.2)
			end

			if self.AllowIdleAnimation then
				if self.Weapon:GetDTBool(3) and self.Type == 2 then
					self.Weapon:SendWeaponAnim(ACT_VM_IDLE_SILENCED)
				else
					self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
				end

				self.Owner:GetViewModel():SetPlaybackRate(0)
			end

			self.Weapon:EmitSound("weapons/universal/iron_in.wav")
		else
			if (SERVER) then
				self.Owner:SetFOV(0, 0.2)
			end

			if self.AllowPlaybackRate and self.AllowIdleAnimation then
				self.Owner:GetViewModel():SetPlaybackRate(1)
			end	

			self.Weapon:EmitSound("weapons/universal/iron_out.wav")
		end
	end

	if (self.Weapon) then
		self.Weapon:SetDTBool(1, b)
	end
end

/*---------------------------------------------------------
   Name: SWEP:SetMode()
---------------------------------------------------------*/
function SWEP:SetMode(b)

	if (self.Weapon) then
		self.Weapon:SetDTBool(3, b)
	end

	if (!self.Owner) then return end
	
	if (b) then
		if self.Type == 1 then
			self.Primary.Automatic = self.data.Automatic
			self.Weapon:EmitSound("weapons/smg1/switch_burst.wav")
		elseif self.Type == 2 then
			self.Weapon:SendWeaponAnim(ACT_VM_ATTACH_SILENCER)
			self.Primary.Sound = Sound(self.Primary.SuppressorSound)

			if (IsValid(self.Owner) and self.Owner:GetViewModel()) then
				self:IdleAnimation(self.Owner:GetViewModel():SequenceDuration())
			end
		elseif self.Type == 3 then
			self.Weapon:EmitSound("weapons/smg1/switch_burst.wav")
		end

		if (SERVER) then
			self.Owner:PrintMessage(HUD_PRINTTALK, self.data.ModeMsg)
		end
	else
		if self.Type == 1 then
			self.Primary.Automatic = !self.data.Automatic
			self.Weapon:EmitSound("weapons/smg1/switch_single.wav")
		elseif self.Type == 2 then
			self.Weapon:SendWeaponAnim(ACT_VM_DETACH_SILENCER)
			self.Primary.Sound = Sound(self.Primary.NoSuppressorSound)

			if (IsValid(self.Owner) and self.Owner:GetViewModel()) then
				self:IdleAnimation(self.Owner:GetViewModel():SequenceDuration())
			end
		elseif self.Type == 3 then
			// Nothing here for the burst fire mode
			self.Weapon:EmitSound("weapons/smg1/switch_single.wav")
		end

		if (SERVER and self.Owner:IsValid()) then
			self.Owner:PrintMessage(HUD_PRINTTALK, self.data.NormalMsg)
		end
	end
end

/*---------------------------------------------------------
   Name: SWEP:CheckReload()
   Desc: CheckReload.
---------------------------------------------------------*/
function SWEP:CheckReload()
end

/*---------------------------------------------------------
   Name: SWEP:Reload()
   Desc: Reload is being pressed.
---------------------------------------------------------*/
function SWEP:Reload()

	if (self.ReloadTime > 0 ) then
		self:SpecialReload()
		return
	end

	// When the weapon is already doing an animation, just return end because we don't want to interrupt it
	if (self.ActionDelay > CurTime()) then return end 

	if self.EmptyReload then
		if self.Weapon:Clip1() == 0 and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
			self:SetIronsights(false)
			self:ReloadAnimation()
			self:MagazineDrop()
			self:ReloadSounds()
		end
		return
	end
	
	if (self.Weapon:Clip1() < self.Primary.ClipSize) and (self.Owner:GetAmmoCount(self.Primary.Ammo) > 0) then
		self:SetIronsights(false)
		self:ReloadAnimation()
		self:MagazineDrop()
		self:ReloadSounds()
	end
end

/*---------------------------------------------------------
   Name: SWEP:ReloadSounds()
   Desc: Just in case a weapon doesn't have specific sounds binded to its viewmodel
---------------------------------------------------------*/
function SWEP:ReloadSounds()

end

/*---------------------------------------------------------
   Name: SWEP:SpecialReload()
   Desc: Reload is being pressed but with a specified time
---------------------------------------------------------*/
function SWEP:SpecialReload()

	-- When the weapon is already doing an animation, just return end because we don't want to interrupt it
	if (self.ActionDelay > CurTime()) then return end 
	
	if (self.Weapon:GetNWBool("Reloading")) then return end

	if (self.Weapon:Clip1() < self.Primary.ClipSize) and (self.Owner:GetAmmoCount(self.Primary.Ammo) > 0) then
		self:SetIronsights(false)
		--self.Weapon:DefaultReload(ACT_VM_RELOAD)
		self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
		self.Weapon:SetNetworkedInt("ReloadTime", CurTime() + self.ReloadTime)
		self.Weapon:SetNetworkedBool("Reloading", true)
		self.Weapon:SetNextPrimaryFire(CurTime() + self.ReloadTime)
		self.Weapon:SetNextSecondaryFire(CurTime() + self.ReloadTime)
		self:MagazineDrop()
	end
	
	self:IdleAnimation(self.ReloadTime)
end

/*---------------------------------------------------------
   Name: SWEP:MagazineDrop()
   Desc: Omitting for now because nothing has a magazine
---------------------------------------------------------*/
function SWEP:MagazineDrop() 

end

/*---------------------------------------------------------
   Name: SWEP:ReloadAnimation()
---------------------------------------------------------*/
function SWEP:ReloadAnimation()

	// Reload with the suppressor animation if you're suppressor is on the FUCKING gun
	if self.Weapon:GetDTBool(3) and self.Type == 2 then
		self.Weapon:DefaultReload(ACT_VM_RELOAD_SILENCED)
	else
		self.Weapon:DefaultReload(ACT_VM_RELOAD)
	end

	if (IsValid(self.Owner) and self.Owner:GetViewModel()) then
		self:IdleAnimation(self.Owner:GetViewModel():SequenceDuration())
	end
end

/*---------------------------------------------------------
   Name: SWEP:SecondThink()
   Desc: Called every frame. Use this function if you don't 
	   want to copy/past the think function everytime you 
	   create a new weapon with this base...
---------------------------------------------------------*/
function SWEP:SecondThink()
end

/*---------------------------------------------------------
   Name: SWEP:SpecialReloadThink()
   Desc: Called every frame. Used to correct the reload
	   time on specially sequenced weapons
---------------------------------------------------------*/
function SWEP:SpecialReloadThink()
	if self.Weapon:GetNetworkedBool("Reloading") == true then
		if self.Weapon:GetNetworkedInt("ReloadTime") < CurTime() then
		
			self.Weapon:SetNetworkedBool("Reloading", false)
			local ammo = self.Owner:GetAmmoCount( self.Primary.Ammo )
			ammo = ammo - ( self.Primary.ClipSize - self.Weapon:Clip1() )
			self.Owner:RemoveAmmo(self.Primary.ClipSize - self.Weapon:Clip1(), self.Primary.Ammo, false)
			if ammo >= 0 then
				self.Weapon:SetClip1(self.Primary.ClipSize)
			else
				self.Weapon:SetClip1(self.Primary.ClipSize + ammo)
			end
			
			if (IsValid(self.Owner) and self.Owner:GetViewModel()) then
				--self:IdleAnimation(self.Owner:GetViewModel():SequenceDuration())
			end
			
		end
	end
end

/*---------------------------------------------------------
   Name: SWEP:Think()
   Desc: Called every frame.
---------------------------------------------------------*/
function SWEP:Think()

	if self.Owner:GetVelocity():Length() > 350 or self.Weapon:GetDTBool(0) then
		
		if self.Rifle or self.Sniper or self.Shotgun then
			if ( self.Owner:Crouching() and self.Owner:GetVelocity():Length() == 0 ) then
				self:SetWeaponHoldType( 'normal' )
				self:SetHoldType( 'normal' )
			else
				self:SetWeaponHoldType( 'passive' )
				self:SetHoldType( 'passive' )
			end
		elseif self.Pistol then
			self:SetWeaponHoldType( 'normal' )
			self:SetHoldType( 'normal' )
		end
		
	else
		self:SetWeaponHoldType(self.HoldType)
		self:SetHoldType(self.HoldType)
	end

	self:SecondThink()
	
	if( self.ReloadTime > 0 ) then
		self:SpecialReloadThink()
	end

	if self.Weapon:Clip1() > 0 and self.IdleDelay < CurTime() and self.IdleApply then
		local WeaponModel = self.Weapon:GetOwner():GetActiveWeapon():GetClass()

		if self.Owner and self.Weapon:GetOwner():GetActiveWeapon():GetClass() == WeaponModel and self.Owner:Alive() then
			if self.Weapon:GetDTBool(3) and self.Type == 2 then
				self.Weapon:SendWeaponAnim(ACT_VM_IDLE_SILENCED)
			else
				self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
			end

			if self.AllowPlaybackRate and not self.Weapon:GetDTBool(1) then
				self.Owner:GetViewModel():SetPlaybackRate(1)
			else
				self.Owner:GetViewModel():SetPlaybackRate(0)
			end		
		end

		self.IdleApply = false
	elseif self.Weapon:Clip1() <= 0 then
		self.IdleApply = false
	end

	if self.Weapon:GetDTBool(1) and self.Owner:KeyDown(IN_SPEED) then
		self:SetIronsights(false)
	end

	// Burst fire mode
	if self.Weapon:GetDTBool(3) and self.Type == 3 then
		if self.BurstTimer + self.BurstDelay < CurTime() then
			if self.BurstCounter > 0 then
				self.BurstCounter = self.BurstCounter - 1
				self.BurstTimer = CurTime()
				
				if self:CanPrimaryAttack() then
					self.Weapon:EmitSound(self.Primary.Sound)
					self:ShootBulletInformation()
					self:TakePrimaryAmmo(1)
				end
			end
		end
	end

	self:NextThink(CurTime())
end

function SWEP:OnRemove()

	if ( IsValid( self.Owner ) && CLIENT && self.Owner:IsPlayer() ) then
		local vm = self.Owner:GetViewModel()
		if ( IsValid( vm ) ) then vm:SetMaterial( "" ) vm:StopParticleEmission() end
	end
end

/*---------------------------------------------------------
   Name: SWEP:Holster()
   Desc: Weapon wants to holster.
	   Return true to allow the weapon to holster.
---------------------------------------------------------*/
function SWEP:Holster()

	self:OnRemove()
	return true
	
end

/*---------------------------------------------------------
   Name: SWEP:OnDrop()
   Desc: Weapon wants to be dropped.
---------------------------------------------------------*/
function SWEP:OnDrop()

	self:OnRemove()

end
/*---------------------------------------------------------
   Name: SWEP:Deploy()
   Desc: Whip it out.
---------------------------------------------------------*/
function SWEP:Deploy()

	self:DeployAnimation()

	if (IsValid(self.Owner) and self.Owner:GetViewModel()) then
		self:IdleAnimation(self.Owner:GetViewModel():SequenceDuration())
	end

	self.Weapon:SetNextPrimaryFire(CurTime() + self.DeployDelay + 0.05)
	self.Weapon:SetNextSecondaryFire(CurTime() + self.DeployDelay + 0.05)
	self.ActionDelay = (CurTime() + self.DeployDelay + 0.05)

	self:SetIronsights(false)

	return true
end

/*---------------------------------------------------------
   Name: SWEP:DeployAnimation()
---------------------------------------------------------*/
function SWEP:DeployAnimation()

	// Weapon has a suppressor
	if self.Weapon:GetDTBool(3) and self.Type == 2 then
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW_SILENCED)
	else
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	end
end

/*---------------------------------------------------------
   Name: SWEP:CrosshairAccuracy()
   Desc: Crosshair informations.
---------------------------------------------------------*/
SWEP.SprayTime 		= 0.1
SWEP.SprayAccuracy 	= 0.2

function SWEP:CrosshairAccuracy()

	// Is it a constant accuracy weapon or is it a NPC? The NPC doesn't need a crosshair. Fuck him!
	if (self.ConstantAccuracy) or (self.Owner:IsNPC()) then
		return 1.0
	end
	
	local LastAccuracy 	= self.LastAccuracy or 0
	local Accuracy 		= 1.0
	local LastShoot 		= self.Weapon:GetNetworkedFloat("LastShootTime", 0)
	
	local Speed 		= self.Owner:GetVelocity():Length()

	local SpeedClamp = math.Clamp(math.abs(Speed / 705), 0, 1)
	
	if (CurTime() <= LastShoot + self.SprayTime) then
		Accuracy = Accuracy * self.SprayAccuracy
	end
	
	if (not self.Owner:IsOnGround()) then
		Accuracy = Accuracy * 0.1
	elseif (Speed > 10) then
		Accuracy = Accuracy * (((1 - SpeedClamp) + 0.1) / 2)
	end

	if (LastAccuracy != 0) then
		if (Accuracy > LastAccuracy) then
			Accuracy = math.Approach(self.LastAccuracy, Accuracy, FrameTime() * 2)
		else
			Accuracy = math.Approach(self.LastAccuracy, Accuracy, FrameTime() * -2)
		end
	end
	
	self.LastAccuracy = Accuracy
	return math.Clamp(Accuracy, 0.2, 1)
end

/*---------------------------------------------------------
   Name: SWEP:ShootBulletInformation()
   Desc: This function add the damage, the recoil, the number of shots and the cone on the bullet.
---------------------------------------------------------*/
function SWEP:ShootBulletInformation()

	local CurrentDamage
	local CurrentRecoil
	local CurrentCone

	if self.Weapon:GetDTBool(3) then
		CurrentDamage = self.Primary.Damage * self.data.Damage * DamageMul:GetFloat()
		CurrentRecoil = self.Primary.Recoil * self.data.Recoil * RecoilMul:GetFloat()
		CurrentCone = self.Primary.Cone * self.data.Cone
	else
		CurrentDamage = self.Primary.Damage * DamageMul:GetFloat()
		CurrentRecoil = self.Primary.Recoil * RecoilMul:GetFloat()
		CurrentCone = self.Primary.Cone
	end

	if self.Owner:IsNPC() then
		self:ShootBullet(CurrentDamage, CurrentRecoil, self.Primary.NumShots, self.Primary.Cone)
		return
	end

	// When we have collected some fuel, we do a lot of damage! >:D
	if self.Owner:GetNetworkedInt("Fuel") > 0 then
		CurrentDamage = CurrentDamage * 1.25
	end

	local accMult = 1.0
	if self.Weapon:GetDTBool(1) then accMult = accMult / 6.0 end
	if self.Owner:KeyDown(IN_FORWARD || IN_BACK || IN_MOVELEFT || IN_MOVERIGHT) then accMult = accMult * 1.5 end
	if not self.Owner:IsOnGround() then accMult = accMult * 2.5 end
	if self.Owner:Crouching() then accMult = accMult / 4.0 end
	
	self:ShootBullet(CurrentDamage, CurrentRecoil * accMult, self.Primary.NumShots, CurrentCone)
	self.Owner:ViewPunch(Angle(math.Rand(-0.75, -1.0) * (CurrentRecoil * accMult), math.Rand(-1, 1) * (CurrentRecoil * accMult), 0))
	
end

/*---------------------------------------------------------
   Name: SWEP:ShootEffects()
   Desc: A convenience function to shoot effects.
---------------------------------------------------------*/
function SWEP:ShootEffects()

	if not self.Owner:IsNPC() then
		self:ShootAnimation()
	end

	local WeaponModel = self.Weapon:GetOwner():GetActiveWeapon():GetClass()
	if (not self.Owner:IsNPC() and self.Weapon:Clip1() < 1) then
		timer.Simple(self.Owner:GetViewModel():SequenceDuration() + self.ShootDelay, function() 
			if self.Owner then
				if self.Owner:Alive() and self.Weapon:GetOwner():GetActiveWeapon():GetClass() == WeaponModel then
					self.ActionDelay = CurTime()
					self:Reload() 
				end
			end
		end)
	end

	self.Owner:MuzzleFlash()						// Crappy muzzle light
	self.Owner:SetAnimation(PLAYER_ATTACK1)				// 3rd Person Animation

	if self.Owner:IsNPC() then return end
	
	local effectdata = EffectData()
		effectdata:SetOrigin(self.Owner:GetShootPos())
		effectdata:SetEntity(self.Weapon)
		effectdata:SetStart(self.Owner:GetShootPos())
		effectdata:SetNormal(self.Owner:GetAimVector())
		effectdata:SetAttachment(1)

	// Add a timer to solve this problem : in multiplayer, when you aim with the ironsights, tracers, effects, etc. still come from where the barrel is when you don't aim with ironsights
	timer.Simple(0, function()
		if not self.Owner then return end
		if not IsFirstTimePredicted() then return end

		if (self.Shotgun) then
			util.Effect("effect_mad_shotgunsmoke", effectdata)
		else
			util.Effect("effect_mad_gunsmoke", effectdata)
		end
	end)

	/*
	// Shell eject
	timer.Simple(self.ShellDelay, function()
		if not self.Owner then return end
		if not IsValid(self.Owner) then return end
		if not IsFirstTimePredicted() then return end
		if not self.Owner:IsNPC() and not self.Owner:Alive() then return end
		
		local effectdata = EffectData()
		effectdata:SetEntity(self.Weapon)
		effectdata:SetNormal(self.Owner:GetAimVector())
		effectdata:SetAttachment(2)
		util.Effect(self.ShellEffect, effectdata)
	end)
	*/

	// Crosshair effect
	if ((game.SinglePlayer() and SERVER) or CLIENT) then
		self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
	end
	
end

/*---------------------------------------------------------
   Name: SWEP:ShootFire()
   Desc: Shoot fire bullets.
---------------------------------------------------------*/
function SWEP:ShootFire(attacker, tr, dmginfo)

	self.Owner:SetNetworkedInt("Fuel", math.Clamp(self.Owner:GetNetworkedInt("Fuel") - (math.random(1, 3) / self.Primary.NumShots), 0, 100))

	local effectdata = EffectData()
	effectdata:SetOrigin(tr.HitPos)
	effectdata:SetNormal(tr.HitNormal)
	effectdata:SetScale(20)
	util.Effect("effect_mad_firehit", effectdata)

	util.Decal("FadingScorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)

	local random = (1 / self.Primary.Delay) * (self.Primary.NumShots * (self.Primary.NumShots / 4))
	
	if self.FireChance >= 0 then
		random = self.FireChance
	end

	if math.random(0, random) < 1 then
		if tr.Entity:GetPhysicsObject():IsValid() and not tr.Entity:IsPlayer() then
			tr.Entity:Ignite(math.random(5, 20), 0)

			local tracedata = {}
			tracedata.start = tr.HitPos
			tracedata.endpos = Vector(tr.HitPos.x, tr.HitPos.y, tr.HitPos.z - 10)
			tracedata.filter = tr.HitPos
			local tracedata = util.TraceLine(tracedata)

			if tracedata.HitWorld then
				local fire = ents.Create("env_fire")
				fire:SetPos(tr.HitPos)
				fire:SetKeyValue("health", math.random(5, 15))
				fire:SetKeyValue("firesize", "20")
				fire:SetKeyValue("fireattack", "10")
				fire:SetKeyValue("damagescale", "1.0")
				fire:SetKeyValue("StartDisabled", "0")
				fire:SetKeyValue("firetype", "0")
				fire:SetKeyValue("spawnflags", "128")
				fire:Spawn()
				fire:Fire("StartFire", "", 0)
			end
		end
	end
end


/*---------------------------------------------------------
   Name: SWEP:ShootAnimation()
---------------------------------------------------------*/
function SWEP:ShootAnimation()

	// Too lazy to create a table :)
	local AllowDryFire = self.Owner:GetActiveWeapon():GetClass() == ("weapon_mad_deagle") 
				   or self.Owner:GetActiveWeapon():GetClass() == ("weapon_mad_usp") 

	if (self.Weapon:Clip1() <= 0) then
		if (AllowDryFire) then
			if self.Weapon:GetDTBool(3) and self.Type == 2 then
				self.Weapon:SendWeaponAnim(ACT_VM_DRYFIRE_SILENCED)	// View model animation
			else
				self.Weapon:SendWeaponAnim(ACT_VM_DRYFIRE) 		// View model animation
			end
		elseif self.Weapon:GetDTBool(3) and self.Type == 2 then
			self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK_SILENCED) 	// View model animation
		else
			self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK) 		// View model animation
		end
	else
		if self.Weapon:GetDTBool(3) and self.Type == 2 then
			self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK_SILENCED) 	// View model animation
		else
			self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK) 		// View model animation
		end
	end
end

/*---------------------------------------------------------
   Name: SWEP:FireShot()
   Desc: A convenience function to call ShootFire
---------------------------------------------------------*/

function SWEP:FireShot(attacker, tr, dmginfo) 
	if not self.Owner:IsNPC() and self.Owner:GetNetworkedInt("Fuel") > 0 then
		self:ShootFire(attacker, tr, dmginfo) 
	end
end

/*---------------------------------------------------------
   Name: SWEP:ShootBullet()
   Desc: A convenience function to shoot bullets.
---------------------------------------------------------*/
local TracerName = "Tracer"

function SWEP:ShootBullet(damage, recoil, num_bullets, aimcone)

	num_bullets 		= num_bullets or 1
	aimcone 			= aimcone or 0

	self:ShootEffects()

	if self.Tracer == 1 then
		TracerName = "Ar2Tracer"
	elseif self.Tracer == 2 then
		TracerName = "AirboatGunHeavyTracer"
	else
		TracerName = "Tracer"
	end
	
	local bullet = {}
		bullet.Num 		= num_bullets
		bullet.Src 		= self.Owner:GetShootPos()			// Source
		bullet.Dir 		= self.Owner:GetAimVector()			// Dir of bullet
		bullet.Spread 	= Vector(aimcone, aimcone, 0)			// Aim Cone
		bullet.Tracer	= 1							// Show a tracer on every x bullets
		bullet.TracerName = TracerName
		bullet.Force	= damage * 0.5					// Amount of force to give to phys objects
		bullet.Damage	= damage
		bullet.Callback	= function(attacker, tr, dmginfo) 
			self:FireShot(attacker, tr, dmginfo)
			local effectdata = EffectData()
				effectdata:SetOrigin(tr.HitPos)
				effectdata:SetNormal(tr.HitNormal)
				effectdata:SetRadius(tr.MatType)
				effectdata:SetScale(1)
			return self:RicochetCallback_Redirect(attacker, tr, dmginfo) 
		end
	self.Owner:FireBullets(bullet)

	if self.Weapon:GetDTBool(3) then
		if self.Silenced == false then
			local Vm = self.Owner:GetViewModel()
			local fx = EffectData()
			fx:SetEntity(self.Weapon)
			fx:SetOrigin(self.Owner:GetShootPos())
			fx:SetNormal(self.Owner:GetAimVector())
			fx:SetAttachment(Vm:LookupAttachment( "1" ))
			util.Effect("buu_muzzle",fx)
		end
	else
		if ( self.Weapon:Clip1() <= 0 ) && self.ShootEmptyAnim == true then
			self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK_EMPTY)
		else
			self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK) 
		end
	end
	if self.Silenced == true then
		local Vm = self.Owner:GetViewModel()
		local fx = EffectData()
		fx:SetEntity(self.Weapon)
		fx:SetOrigin(self.Owner:GetShootPos())
		fx:SetNormal(self.Owner:GetAimVector())
		fx:SetAttachment(Vm:LookupAttachment( "1" ))
		util.Effect("buu_muzzle_silenced",fx)
	end
	
	// Realistic recoil. Only on snipers and shotguns. Disable for the admin gun because if you put the max damage, you'll fly like you never fly!
	if (SERVER and (self.Sniper or self.Shotgun) and not self.Owner:GetActiveWeapon():GetClass() == ("weapon_mad_admin")) then
		self.Owner:SetVelocity(self.Owner:GetAimVector() * -(damage * num_bullets))
	end

	// Recoil
	if (not self.Owner:IsNPC()) and ((game.SinglePlayer() and SERVER) or (not game.SinglePlayer() and CLIENT)) then
		local eyeangle 	= self.Owner:EyeAngles()
		eyeangle.pitch 	= eyeangle.pitch - recoil
		self.Owner:SetEyeAngles(eyeangle)
	end
	
	local trace = self.Owner:GetEyeTrace()

	if !self.Shotgun then return end
	if trace.HitPos:Distance(self.Owner:GetShootPos()) > 250 or self.DestroyDoor == 0 then return end

	if trace.Entity:GetClass() == "prop_door_rotating" and (SERVER) then

		trace.Entity:Fire("open", "", 0.001)
		trace.Entity:Fire("unlock", "", 0.001)

		local pos = trace.Entity:GetPos()
		local ang = trace.Entity:GetAngles()
		local model = trace.Entity:GetModel()
		local skin = trace.Entity:GetSkin()

		local smoke = EffectData()
			smoke:SetOrigin(pos)
			util.Effect("effect_smokedoor", smoke)

		trace.Entity:SetNotSolid(true)
		trace.Entity:SetNoDraw(true)

		local function ResetDoor(door, fakedoor)
			door:SetNotSolid(false)
			door:SetNoDraw(false)
			fakedoor:Remove()
		end

		local norm = (pos - self.Owner:GetPos())
		norm:Normalize()
		local push = 1000 * norm
		local ent = ents.Create("prop_physics")

		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:SetModel(model)

		if(skin) then
			ent:SetSkin(skin)
		end

		ent:Spawn()

		timer.Simple(0.01, function() if ent and push then ent:GetPhysicsObject():SetVelocity(push) end end)              
		timer.Simple(0.01, function() if ent and push then ent:GetPhysicsObject():SetVelocity(push) end end)
		timer.Simple(25, function() ResetDoor( trace.Entity, ent, 10) end )
	end
end

/*---------------------------------------------------------
   Name: SWEP:BulletPenetrate()
---------------------------------------------------------*/
function SWEP:BulletPenetrate(bouncenum, attacker, tr, dmginfo, isplayer)

	if (CLIENT) then return end

	local MaxPenetration

	if self.Primary.Ammo == "Pistol" then
		MaxPenetration = 150
	elseif self.Primary.Ammo == "smg1" then
		MaxPenetration = 120
	elseif self.Primary.Ammo == "buckshot" then
		MaxPenetration = 70
	elseif self.Primary.Ammo == "AR2" then
		MaxPenetration = 200
	elseif self.Primary.Ammo == "357" then
		MaxPenetration = 400
	elseif self.Primary.Ammo == "XBowBolt" then
		MaxPenetration = 500
	else
		MaxPenetration = 150
	end
	
	if self.MinPenetration >= 0 and MaxPenetration < self.MinPenetration then
		MaxPenetration = self.MinPenetration
	end
		
	local DoDefaultEffect = true
	// Don't go through metal, sand or player
	if ((tr.MatType == MAT_METAL and self.Ricochet) or (tr.MatType == MAT_SAND) or (tr.Entity:IsPlayer())) then return false end

	// Don't go through more than 3 times
	if (bouncenum > self.ChainHit) then return false end
	
	// Direction (and length) that we are going to penetrate
	local PenetrationDirection = tr.Normal * MaxPenetration
	
	if (tr.MatType == MAT_GLASS or tr.MatType == MAT_PLASTIC or tr.MatType == MAT_WOOD or tr.MatType == MAT_FLESH or tr.MatType == MAT_ALIENFLESH) then
		PenetrationDirection = tr.Normal * (MaxPenetration * 2)
	end
		
	local trace 	= {}
	trace.endpos 	= tr.HitPos
	trace.start 	= tr.HitPos + PenetrationDirection
	trace.mask 		= MASK_SHOT
	trace.filter 	= {self.Owner}
	   
	local trace 	= util.TraceLine(trace) 
	
	// Bullet didn't penetrate.
	if (trace.StartSolid or trace.Fraction >= 1.0 or tr.Fraction <= 0.0) then return false end
	
	// Damage multiplier depending on surface
	local fDamageMulti = 0.5
	
	if fDamageMulti < self.PenetrationDmgMult then
		fDamageMulti = self.PenetrationDmgMult
	end
	
	if (tr.MatType == MAT_CONCRETE) then
		fDamageMulti = fDamageMulti - 0.2
	elseif (tr.MatType == MAT_WOOD or tr.MatType == MAT_PLASTIC or tr.MatType == MAT_GLASS) then
		fDamageMulti = fDamageMulti + 0.3
	elseif (tr.MatType == MAT_FLESH or tr.MatType == MAT_ALIENFLESH) then
		fDamageMulti = fDamageMulti + 0.4
	end
	
	if fDamageMulti > 0.95 then
		fDamageMulti = 0.95;
	end
		
	// Fire bullet from the exit point using the original trajectory
	local bullet = 
	{	
		Num 		= 1,
		Src 		= trace.HitPos,
		Dir 		= tr.Normal,	
		Spread 		= Vector(0, 0, 0),
		Tracer		= 1,
		TracerName 	= "effect_mad_penetration_trace",
		Force		= (dmginfo:GetDamage() * fDamageMulti) * 0.5,
		Damage		= (dmginfo:GetDamage() * fDamageMulti),
		HullSize	= 2
	}
	
	bullet.Callback   = function(a, b, c) 
		if (self.Ricochet) then 
			self:FireShot(a, b, c)
			return self:RicochetCallback(bouncenum + 1, a, b, c) 
		end 
	end
	
	timer.Simple(0.05, function()
		if not IsFirstTimePredicted() then return end
		attacker.FireBullets(attacker, bullet, true)
	end)

	return true
end

/*---------------------------------------------------------
   Name: SWEP:RicochetCallback()
---------------------------------------------------------*/
function SWEP:RicochetCallback(bouncenum, attacker, tr, dmginfo)

	if (CLIENT) then return end

	if (not self) then return end

	local DoDefaultEffect = true
	if (tr.HitSky) then return end
	
	// Can we go through whatever we hit?
	if (self.Penetration) and (self:BulletPenetrate(bouncenum, attacker, tr, dmginfo)) then
		return {damage = true, effects = DoDefaultEffect}
	end
	
	if self.ExplosiveShot then
		local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)
			effectdata:SetNormal(tr.HitNormal)
			effectdata:SetScale(1)
		util.Effect("ManhackSparks", effectdata)
		util.Effect("cball_explode", effectdata)
		util.Effect("Explosion", effectdata)
		ParticleEffect("dusty_explosion_rockets",tr.HitPos,Angle(0,0,0),nil)
		util.BlastDamage(self, attacker, tr.HitPos, 75, dmginfo:GetDamage())
		util.ScreenShake(tr.HitPos, 100, 100, 7.5, 75)
	end
	
	// Your screen will shake and you'll hear the savage hiss of an approaching bullet which passing if someone is shooting at you.
	if (tr.MatType != MAT_METAL and not self.SuperRicochet ) then
		if (SERVER) then
			util.ScreenShake(tr.HitPos, 5, 0.1, 0.5, 64)
			sound.Play("Bullets.DefaultNearmiss", tr.HitPos, 250, math.random(110, 180), 1)
		end

		if self.Tracer == 1 or self.Tracer == 2 then
			local effectdata = EffectData()
				effectdata:SetOrigin(tr.HitPos)
				effectdata:SetNormal(tr.HitNormal)
				effectdata:SetScale(20)
			util.Effect("AR2Impact", effectdata)
		elseif self.Tracer == 3 then
			local effectdata = EffectData()
				effectdata:SetOrigin(tr.HitPos)
				effectdata:SetNormal(tr.HitNormal)
				effectdata:SetScale(20)
			util.Effect("StunstickImpact", effectdata)
		end

		return 
	end

	if (self.Ricochet == false) then return {damage = true, effects = DoDefaultEffect} end
	
	if (bouncenum > self.MaxRicochet) then return end
	
	// Bounce vector
	local trace = {}
	trace.start = tr.HitPos
	trace.endpos = trace.start + (tr.HitNormal * 16384)

	local trace = util.TraceLine(trace)

 	local DotProduct = tr.HitNormal:Dot(tr.Normal * -1) 
	
	local bullet = 
	{	
		Num 		= 1,
		Src 		= tr.HitPos + (tr.HitNormal * 5),
		Dir 		= ((2 * tr.HitNormal * DotProduct) + tr.Normal) + (VectorRand() * 0.05),
		Spread 		= Vector(0, 0, 0),
		Tracer		= 1,
		TracerName 	= "effect_mad_ricochet_trace",
		Force		= dmginfo:GetDamage() * 0.25,
		Damage		= dmginfo:GetDamage() * 0.5,
		HullSize	= 2
	}
		
	// Added conditional to stop errors when bullets ricochet after weapon switch
	bullet.Callback   = function(a, b, c) 
		if (self.Ricochet) then 
			self:FireShot(a, b, c)
			return self:RicochetCallback(bouncenum + 1, a, b, c) 
		end 
	end

	timer.Simple(0.05, function()
		if not IsFirstTimePredicted() then return end
		attacker.FireBullets(attacker, bullet, true)
	end)
	
	return {damage = true, effects = DoDefaultEffect}
end

/*---------------------------------------------------------
   Name: SWEP:RicochetCallback_Redirect()
---------------------------------------------------------*/
function SWEP:RicochetCallback_Redirect(a, b, c)
 
	return self:RicochetCallback(0, a, b, c) 
end

function SWEP:Graze( target, dmg )

end

function SWEP:Parry( target, dmg )

end

/*---------------------------------------------------------
   Name: SWEP:CanPrimaryAttack()
   Desc: Helper function for checking for no ammo.
---------------------------------------------------------*/
function SWEP:CanPrimaryAttack()

	// Clip is empty or you're under water
	if (self.Weapon:Clip1() <= 0) or (self.Owner:WaterLevel() > 2) then
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
//		self.Weapon:EmitSound("Default.ClipEmpty_Pistol")
		return false
	end

	// You're sprinting or your weapon is holsted
	if not self.Owner:IsNPC() and (self.Owner:KeyDown(IN_SPEED) or self.Weapon:GetDTBool(0) or self.Owner:WaterLevel() > 2) then
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
		return false
	end

	return true
end

/*---------------------------------------------------------
   Name: SWEP:CanSecondaryAttack()
   Desc: Helper function for checking for no ammo.
---------------------------------------------------------*/
function SWEP:CanSecondaryAttack()

	// Clip is empty or you're under water
	if (self.Weapon:Clip2() <= 0) then
		self.Weapon:SetNextSecondaryFire(CurTime() + 0.5)
//		self.Weapon:EmitSound("Default.ClipEmpty_Pistol")
		return false
	end

	// You're sprinting or your weapon is holsted
	if not self.Owner:IsNPC() and (self.Owner:KeyDown(IN_SPEED) or self.Weapon:GetDTBool(0) or self.Owner:WaterLevel() > 2) then
		self.Weapon:SetNextSecondaryFire(CurTime() + 0.5)
		return false
	end

	return true
end

function SWEP:DrawWorldModel()

	local hand, offset, rotate

	if not IsValid(self.Owner) then
		self:SetRenderOrigin( nil )
        self:SetRenderAngles( nil )
        self:DrawModel()
		return
	end

	hand = self.Owner:GetAttachment(self.Owner:LookupAttachment("anim_attachment_rh"))
	
	if hand == nil then
		self:SetRenderOrigin( nil )
        self:SetRenderAngles( nil )
		self:DrawModel()
		return
	end
	
	offset = hand.Ang:Right() * self.Offset.Pos.Right + hand.Ang:Forward() * self.Offset.Pos.Forward + hand.Ang:Up() * self.Offset.Pos.Up
	
	hand.Ang:RotateAroundAxis(hand.Ang:Right(), self.Offset.Ang.Right)
	hand.Ang:RotateAroundAxis(hand.Ang:Forward(), self.Offset.Ang.Forward)
	hand.Ang:RotateAroundAxis(hand.Ang:Up(), self.Offset.Ang.Up)
	
	self:SetRenderOrigin(hand.Pos + offset)
	self:SetRenderAngles(hand.Ang)

	self:DrawModel()

	if (CLIENT) then
		self:SetModelScale(self.Offset.Scale,self.Offset.Scale - 0.1,self.Offset.Scale)
	end
end

/*---------------------------------------------------------
   Name: SWEP:EntityFaceBack
   Desc: Is the entity face back to the player?
---------------------------------------------------------*/
function SWEP:EntsInSphereBack(pos, range)

	local ents = ents.FindInSphere(pos, range)

	for k, v in pairs(ents) do
		if v ~= self and v ~= self.Owner and (v:IsNPC() or v:IsPlayer()) and IsValid(v) and self:EntityFaceBack(v) then
			return true
		end
	end

	return false
end

/*---------------------------------------------------------
   Name: SWEP:EntityFaceBack
   Desc: Is the entity face back to the player?
---------------------------------------------------------*/
function SWEP:EntityFaceBack(ent)

	local angle = self.Owner:GetAngles().y - ent:GetAngles().y

	if angle < -180 then angle = 360 + angle end
	if angle <= 90 and angle >= -90 then return true end

	return false
end

/*---------------------------------------------------------
   Name: SWEP:EntityFaceFront
   Desc: Is the player face front to the entity?
---------------------------------------------------------*/
function SWEP:EntityFaceFront(ent, ang)

	local angle = self.Owner:EyeAngles().y - ( ent:GetPos() - self.Owner:GetPos() ):Angle().y
	
	if angle < -180 then angle = 360 + angle end
	if angle <= ang and angle >= -ang then return true end

	return false
end