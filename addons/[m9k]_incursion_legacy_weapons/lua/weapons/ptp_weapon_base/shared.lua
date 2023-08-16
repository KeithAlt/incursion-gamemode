if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end
///////////////////////////////////////////////////////////
///														///
///				Project Start: 11/11/13					///
///														///
///////////////////////////////////////////////////////////
/*---------------------------------------------------------
	Client Variables
---------------------------------------------------------*/
if ( CLIENT ) then

	SWEP.PrintName			= "SWEPNAME"			
	SWEP.Author				= "Fonix"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "" --Text Font
	SWEP.IconLetterCSS		= "" --For Css Font
	SWEP.DrawCrosshair		= false
	SWEP.DrawAmmo			= true
	SWEP.CSMuzzleFlashes	= true
	
	killicon.AddFont( "weapon_cs_ak47_gb", "TextKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
	surface.CreateFont("TextKillIcons", { font="Roboto-Medium", weight="500", size=ScreenScale(13),antialiasing=true,additive=true })
	surface.CreateFont("TextSelectIcons", { font="Roboto-Medium", weight="500", size=ScreenScale(20),antialiasing=true,additive=true })
	surface.CreateFont("CSKillIcons", { font="csd", weight="500", size=ScreenScale(30),antialiasing=true,additive=true })
	surface.CreateFont("CSSelectIcons", { font="csd", weight="500", size=ScreenScale(60),antialiasing=true,additive=true })

end
/*---------------------------------------------------------
	The Layout...
---------------------------------------------------------*/
SWEP.Category			= "Hello"
SWEP.ViewModelFlip		= true

SWEP.Spawnable			= false 	-- Delete this comment and change these to true
SWEP.AdminSpawnable		= false		-- If you don't you can't spawn the swep :(

SWEP.ViewModel			= "models/weapons/v_rif_ak47.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_ak47.mdl"
SWEP.ViewModelFOV		= 80

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= true

SWEP.Primary.Sound			= Sound( "" )
SWEP.SilencedSound			= Sound( "" ) --This is for silencers. Dont bite me, I know its really called a suppressor.
SWEP.Primary.Recoil			= 1
SWEP.Primary.Damage			= 34
SWEP.Primary.NumShots		= 0
SWEP.Primary.Cone			= 0.02
SWEP.Primary.ClipSize		= 30
SWEP.Primary.Delay			= 0.08
SWEP.Primary.DefaultClip	= 300
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "smg1"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

--Uncomment these when you make a swep.

--SWEP.IronSightsPos = Vector(-6.614, -11.551, 2.648) --This is just a place holder for aiming and dashing
--SWEP.IronSightsAng = Vector(2.275, 0, 0)			--Aswell this
--SWEP.AimSightsPos = Vector(-6.614, -11.551, 2.648)  -- Aimsight is for ironsights
--SWEP.AimSightsAng = Vector(2.275, 0, 0)
--SWEP.DashArmPos = Vector(4.355, -7.206, -0.681)		--Dashing is for when you are sprinting
--SWEP.DashArmAng = Vector(-10.965, 37.062, -10.664)

--Extras
SWEP.MuzzleEffect			= "lee_muzzle_rifle"	-- Muzzle attachments should not be messed with
SWEP.MuzzleAttachment			= "1"			-- There's only one anyways
SWEP.MuzzleAttachmentTrue		= true		-- Keep it true
SWEP.TracerShot				= 3		-- On what shot should there be a tracer?
SWEP.TakeAmmoOnShot			= 1     -- How many rounds should we take per shot? Typically leave this at one.
SWEP.BulletForce			= 10	-- The force a bullet has on a prop
SWEP.Silenceable			= false		-- If the model supports a silencer
SWEP.SilenceHolster			= 0		-- The timing for silencer animation
SWEP.ZoomFOV				= 65	-- Fov for when we're aiming
SWEP.CSSZoom				= false	-- This is for using Zoom Delays. Example the AUG zoom in CSS
SWEP.MPrecoil				= 1		-- Changes the amount of view punch in multiplayer
SWEP.ReloadHolster			= 1		-- How long should we wait before allowing think when reloading(Seconds or Gmodical Units. Idk)
SWEP.ReloadSound			= false	-- This has only been found to be used on HL2 weapons

--FireModes
SWEP.FiringMode			= false --Can we switch the firing modes? Auto, Semi, and Burst?
SWEP.Burstable 			= false --Can we burst with firing modes?
SWEP.BurstShots 		= 0 	--How many rounds should we shoot on burst? If you use more than 5 you are retarded beyond hell.
SWEP.PistolBurstOnly	= false --This might be confusing like the rest of my base. Only use this for pistols that only "burst" and "Semi" fire.


-- Accuracy
SWEP.CrouchCone				= 0.01 -- Accuracy when we're crouching
SWEP.CrouchWalkCone			= 0.02 -- Accuracy when we're crouching and walking
SWEP.WalkCone				= 0.025 -- Accuracy when we're walking
SWEP.AirCone				= 0.1 -- Accuracy when we're in air
SWEP.StandCone				= 0.015 -- Accuracy when we're standing still
SWEP.IronSightsCone			= 0.006 -- Accuracy when we're aiming
SWEP.Delay				= 0.08	-- Delay For Not Zoom
SWEP.Recoil				= 1	-- Recoil For not Aimed
SWEP.RecoilZoom				= 0.3	-- Recoil For Zoom

/*---------------------------------------------------------
---------------------------------------------------------*/
function SWEP:Initialize()

	if ( SERVER ) then
		self:SetNPCMinBurst( 30 )
		self:SetNPCMaxBurst( 30 )
		self:SetNPCFireRate( 0.01 )
	end

	
	self.Weapon:SetNetworkedBool( "Ironsights", false )
	self.Weapon:SetNetworkedBool("Burst",false)
	self.Weapon:SetNetworkedBool("HitRecoil", true) 
	
	self.Reloadaftershoot = 0 
	self.nextreload = 0 
	
	//Spread Values
	--self:SetNWInt("crouchcone", self.CrouchCone)
	--self:SetNWInt("crouchwalkcone", self.CrouchWalkCone)
	--self:SetNWInt("walkcone", self.WalkCone)
	--self:SetNWInt("aircone", self.AirCone)
	--self:SetNWInt("standcone", self.StandCone)
	--self:SetNWInt("ironsightscone", self.IronSightsCone)
	//Recoil Values
	--self:SetNWInt("recoil", self.Recoil)
	--self:SetNWInt("recoilzoom", self.RecoilZoom)
	//Delay Values
	--self:SetNWInt("delay", self.Delay)
	--self:SetNWInt("delayzoom", self.DelayZoom)
	//ThinkSkip
	--self:SetNWInt("thinkskip", self.ThinkSkip)
	--self:SetNWInt("ironsighttoggle", false)
	
	self:SetNWInt("firemode", 1)
	
	self:SetWeaponHoldType( self.HoldType )
end

/*---------------------------------------------------------
Think
---------------------------------------------------------*/
function SWEP:Think()

		
		--self:FlipTheViewModel()
		--//When the convar says so, flip it.
		
		self:SpreadSystem()
		//A Spread System that Changes the SPREAD
	
		self:DrawHud2()
		//I couldnt think of any other way to make a zoom ads with crosshairs disabled You more than likely will not use this anyways.
			
		self:DashingPos()
		//Dont to be confused with doshing 
		
		self:FireModes()
		//Fire modes
		
		self:Burst()
		//Burst

		//Garanties on disable that ironsights stay the aimsights
		local DisableDashing = false
	
			if GetConVar("sv_ptp_dashing_disable") == nil then
			DisableDashing = false
			else
			DisableDashing = GetConVar("sv_ptp_dashing_disable"):GetBool()
			end
	
		if DisableDashing then 
		self.IronSightsPos = self.AimSightsPos
		self.IronSightsAng = self.AimSightsAng
		end
	
	end

SWEP.SetNextFireMode		= 0
SWEP.Cycle					= 0
/*---------------------------------------------------------
FireModes
---------------------------------------------------------*/
function SWEP:FireModes()

	if !self.FiringMode then return end 
	
	if self.Owner:KeyDown(IN_USE) and self.Owner:KeyDown(IN_ATTACK) and self.SetNextFireMode < CurTime() then
	
		if self.Primary.Automatic or self.Cycle == 1 then
			self.Primary.Automatic = false
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Semi-Automatic Selected" )
			self.Weapon:EmitSound("weapons/universal/firemode.wav")
			self.SetNextFireMode = CurTime() + 0.5
			self.Weapon:SetNetworkedBool("Burst",false)
			if self.Burstable then
				self.Cycle	= 2
				else
				self.Cycle  = 3
			end
		end
		if self.Cycle == 2 and self.SetNextFireMode < CurTime() then
			self.Primary.Automatic = false
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Burst Selected" )
			self.Weapon:EmitSound("weapons/universal/firemode.wav")
			self.SetNextFireMode = CurTime() + 0.5
			self.Weapon:SetNetworkedBool("Burst",true)
			if self.PistolBurstOnly then
				self.Cycle = 1
				else
				self.Cycle = 3
			end
		end
		if self.Cycle == 3 and self.SetNextFireMode < CurTime() then
			self.Primary.Automatic = true
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Automatic Selected " )
			self.Weapon:EmitSound("weapons/universal/firemode.wav")
			self.SetNextFireMode = CurTime() + 0.5
			self.Weapon:SetNetworkedBool("Burst",false)
		end
	end
end

SWEP.BurstDelay 		= 0.5
SWEP.BurstShots 		= 3
SWEP.BurstCounter 	= 0
SWEP.BurstTimer 		= 0
/*---------------------------------------------------------
Burst
---------------------------------------------------------*/
function SWEP:Burst()
	
	if self.Weapon:GetNetworkedBool("Burst",true) then
		if self.BurstTimer + self.Delay < CurTime() then
			if self.BurstCounter > 0 then
				self.BurstCounter = self.BurstCounter - 1
				self.BurstTimer = CurTime()
				
				if self:CanPrimaryAttack() then
						if self.Weapon:GetNetworkedBool("Silenced") == true then
								self.Weapon:EmitSound( self.SilencedSound )
								self:CSShootBullet( self.Primary.Damage * 0.8, self.Primary.Recoil * 0.75, self.Primary.NumShots, self.Primary.Cone )
						else	
								self.Weapon:EmitSound( self.Primary.Sound , 300, math.Rand(90,110)) 
								self:CSShootBullet( self.Primary.Damage , self.Primary.Recoil , self.Primary.NumShots, self.Primary.Cone )
							end
						
						self.SetNextFireMode = (CurTime() + 0.3)
						
						self:TakePrimaryAmmo( self.TakeAmmoOnShot )
						//Remove X bullet from our clip
				end
			end
		end
	
	end
end
/*---------------------------------------------------------
ViewModelFlip
---------------------------------------------------------*/
function SWEP:FlipTheViewModel()

		--local LeftyFlip = true									-- Cant get this shit to work. Im fucking retarded and give.
																	-- Try again later faggot.
	
			--if GetConVar("cl_ptp_viewmodel_lefty") == nil then
			--LeftyFlip = true
			--else
			--LeftyFlip = GetConVar("cl_ptp_viewmodel_lefty"):GetBool()
			--end
		
		--if LeftyFlip then 
		--if self.ViewModelFlip then
			--self.ViewModelFlip = false
		--else
			--self.ViewModelFlip = true
			--LeftyFlip	= false
		--end
	--end
end

/*---------------------------------------------------------
DrawHud 2
---------------------------------------------------------*/
function SWEP:DrawHud2()

end

/*---------------------------------------------------------
DashingPos
---------------------------------------------------------*/
function SWEP:DashingPos()

		local DisableDashing = false
	
		if GetConVar("sv_ptp_dashing_disable") == nil then
		DisableDashing = false
		else
		DisableDashing = GetConVar("sv_ptp_dashing_disable"):GetBool()
		end
	
	if DisableDashing then return end
		
	if self.Owner:KeyPressed(IN_USE) then return end
	
		if self.Owner:KeyDown(IN_SPEED) then 
			self.IronSightsPos	= self.DashArmPos
			self.IronSightsAng	= self.DashArmAng
			self.Weapon:SetNetworkedBool("Ironsights", true)
			self.SwayScale 	= 1.0
			self.BobScale 	= 2.2
		end
		
		if self.Owner:KeyReleased(IN_SPEED) then
			self.Weapon:SetNextPrimaryFire( CurTime() + 0.3 )
			self.Weapon:SetNetworkedBool("Ironsights", false)
		end
		
		if self.Owner:KeyDown(IN_SPEED) then return end
		
		if self.Owner:KeyPressed(IN_ATTACK2) then
		self.IronSightsPos = self.AimSightsPos
		self.IronSightsAng = self.AimSightsAng
		end
end

/*---------------------------------------------------------
SpreadSystem
---------------------------------------------------------*/
function SWEP:SpreadSystem()

	if self.Owner:OnGround() and (self.Owner:KeyDown(IN_FORWARD) or self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_MOVERIGHT) or self.Owner:KeyDown(IN_MOVELEFT)) then
		if self.Owner:KeyDown(IN_DUCK) then
			self.Primary.Cone = self.CrouchWalkCone
		elseif self.Owner:KeyDown(IN_SPEED) then
		self.Primary.Cone = self.AirCone
		else
			self.Primary.Cone = self.WalkCone
		end
	elseif self.Owner:OnGround() and self.Owner:KeyDown(IN_DUCK) then
		self.Primary.Cone = self.CrouchCone
	elseif not self.Owner:OnGround() then
		self.Primary.Cone = self.AirCone
	else
			self.Primary.Cone = self.StandCone
	end
	
	if self.Weapon:GetNetworkedBool( "Ironsights") and self.Owner:OnGround() then
			self.Primary.Cone  = self.IronSightsCone
	end

	if self.Owner:KeyPressed(IN_SPEED) or self.Owner:KeyPressed(IN_JUMP) then
	self.Weapon:SetNetworkedBool("Ironsights", false)
	self.Owner:SetFOV(0, 0.15)
	self.Primary.Recoil = self.Recoil
	end
	//Shift or Jump. Either will return the player to normal FOV, recoil and no ironsights.
		
	if (game.SinglePlayer() ) then
		self:SetNWInt("sprecoil", 1.8)
		self:SetNWInt("mprecoil", 1)
	else
		self:SetNWInt("mprecoil", 1)
		self:SetNWInt("sprecoil", 1)
	end
end
/*---------------------------------------------------------
Deploy
---------------------------------------------------------*/
function SWEP:Deploy()

	if self.Weapon:GetNetworkedBool("Silenced") == true then
			self.Weapon:SendWeaponAnim( ACT_VM_DRAW_SILENCED );
		else
			self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
		end
	//Which draw should we use? The bool knows all.

	self:SetWeaponHoldType( self.HoldType )
	//Restores the Weapon hold type 
	
	self.Reloadaftershoot = CurTime() + 1
	//Can't shoot while deploying

	self:SetIronsights(false)
	//Set the ironsight mode to false

	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	//Set the next primary fire to 1 second after deploying

	self.Primary.Delay = self.Delay
	//Set Delay back to normal
		
	self.Primary.Recoil = self.Recoil
	//Set Recoil to normal
	
	if self.PistolBurstOnly then
		self.Cycle = 2
	end
	
	if timer.Exists("ReloadTimer") then
		timer.Destroy("ReloadTimer")
	end
	//Destroy the faggot timer on deploy if its running.

	self:SetNWInt("skipthink", false)
				
	return true
end

/*---------------------------------------------------------
Reload
---------------------------------------------------------*/
function SWEP:Reload()
 
		if self.Owner:KeyDown(IN_ATTACK) then return end
		
		if( self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 || self.Weapon:Clip1() >= self.Primary.ClipSize)	then return end
		//Why go through the function is dis nigga got no reserve, aswell a full clip?
	
		--if (game.SinglePlayer()) then
			--self:SetNWInt("skipthink", true)
				--timer.Create("ReloadTimer", self.ReloadHolster + .2, 1,
				--function()
					--if self.Weapon == nil then return end
				--self:SetNWInt("skipthink", false)
			--end)
		--end
		//Skip the entire Think Function in Single player. This is not needed in Multiplayer.
		
		if ( self.Reloadaftershoot > CurTime() ) then return end 
		//If you're firing, you can't reload
	
		if self.Weapon:GetNetworkedBool("Silenced") == true then
			self.Weapon:DefaultReload( ACT_VM_RELOAD_SILENCED );
		else
			self.Weapon:DefaultReload( ACT_VM_RELOAD );
		end
		//Which pull out should we use for the bool.

		self.Weapon:SetNetworkedBool("Ironsights", false)
		//Set the ironsight to false

		self.Owner:SetFOV( 0, 0.15 )
		//Set the Fov back to normal if zoomed
	
		self:SetWeaponHoldType( self.HoldType )
		//Make sure that holdtypes dont get mixed and masshshed and stuff
	
		if ( self.Weapon:Clip1() < self.Primary.ClipSize ) and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
			
		self.MouseSensitivity = 1
		//Set MouseSens Back to one

		self.Primary.Delay = self.Delay
		//Set Delay back to normal

		self.Primary.Recoil = self.Recoil
		//Set Recoil to normal
		
		if not CLIENT then
			self.Owner:DrawViewModel(true)
		end
		
		if (self.ReloadSound) then 
		self.Weapon:EmitSound(self.Primary.Reload)
		end
	end
end

SWEP.SetNextFireMode2 = CurTime()
/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	
	if self.SetNextFireMode > CurTime() then return end
	
		local DisableDashing = false
	
		if GetConVar("sv_ptp_dashing_disable") == nil then
		DisableDashing = false
		else
		DisableDashing = GetConVar("sv_ptp_dashing_disable"):GetBool()
		end
		//Grab the Value from the convar
		
	if self.Owner:KeyDown(IN_SPEED) and not DisableDashing then return end 
	//Skip firing when sprinting and dashing is allowed
	
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self.SetNextFireMode2 = CurTime() + (self.Primary.Delay*0.1)
	
	if ( !self:CanPrimaryAttack() ) then return end

	if self.Weapon:GetNetworkedBool("Silenced") == true then
		self.Weapon:EmitSound( self.SilencedSound )
		self:CSShootBullet( self.Primary.Damage * 0.8, self.Recoil * 0.75, self.Primary.NumShots, self.Primary.Cone )
	else	
		self.Weapon:EmitSound( self.Primary.Sound , 300, math.Rand(90,110)) 
		self:CSShootBullet( self.Primary.Damage , self.Recoil , self.Primary.NumShots, self.Primary.Cone )
	end
	//If Swep Data is Silenced Play Silenced else Unsilenced

	self:TakePrimaryAmmo( self.TakeAmmoOnShot )
	//Remove X bullet from our clip
	
	if self.Weapon:GetNetworkedBool("Burst", true) then
		self.BurstTimer = CurTime()
		self.SetNextPrimaryFire = CurTime() + 0.5
		self.BurstCounter = self.BurstShots - 1
	end
	
	if ( self.Owner:IsNPC() ) then return end
	
	// Punch the player's view
	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.2) * 0.5, math.Rand(-0.1,0.1) * 0.5, 0 ) )
	
	// In singleplayer this function doesn't get called on the client, so we use a networked float
	// to send the last shoot time. In multiplayer this is predicted clientside so we don't need to 
	// send the float.
	if ( (game.SinglePlayer() && SERVER) || CLIENT ) then
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
	end
	
end

SWEP.IronAjust = 0
/*---------------------------------------------------------
   Name: SWEP:CSShootBullet( )
---------------------------------------------------------*/
function SWEP:CSShootBullet( dmg, recoil, numbul, cone )
		
	numbul 	= numbul 	or 1
	cone 	= cone 		or 0.01
	
	local bullet = {}
	bullet.Num 		= numbul
	bullet.Src 		= self.Owner:GetShootPos()				// Source
	bullet.Dir 		= self.Owner:GetAimVector()				// Dir of bullet
	bullet.Spread 	= Vector( cone, cone, 0 )					// Aim Cone
	bullet.Tracer	= self.TracerShot								// Show a tracer on every x bullets 
	bullet.Force	= self.BulletForce								// Amount of force to give to phys objects
	bullet.Damage	= dmg
	
	self.Owner:FireBullets( bullet )
	self.Owner:MuzzleFlash()							// Crappy muzzle light
	self.Owner:SetAnimation( PLAYER_ATTACK1 ) 					//3rd Person Animation
	
	if self.Weapon:GetNetworkedBool("Silenced") == false then
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		else
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK_SILENCED ) 
	end
		
	local fx 		= EffectData()
		fx:SetEntity(self.Weapon)
		fx:SetOrigin(self.Owner:GetShootPos())
		fx:SetNormal(self.Owner:GetAimVector())
		fx:SetAttachment(self.MuzzleAttachment)

		util.Effect(self.MuzzleEffect,fx)
		
			
	// CUSTOM RECOIL !
	if ( (game.SinglePlayer() && SERVER) || ( !game.SinglePlayer() && CLIENT && IsFirstTimePredicted() ) ) then
	
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - (self.Recoil / 5) //Dont mess with this.
		self.Owner:SetEyeAngles( eyeang )
	
	end

end

/*---------------------------------------------------------
	Checks the objects before any action is taken
	This is to make sure that the entities haven't been removed
---------------------------------------------------------*/
function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	
	draw.SimpleText( self.IconLetter, "TextSelectIcons", x + wide/2, y + tall*0.2, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
	
	// try to fool them into thinking they're playing a Tony Hawks game
	draw.SimpleText( self.IconLetter, "TextSelectIcons", x + wide/2 + math.Rand(-4, 4), y + tall*0.2+ math.Rand(-14, 14), Color( 255, 210, 0, math.Rand(10, 120) ), TEXT_ALIGN_CENTER )
	draw.SimpleText( self.IconLetter, "TextSelectIcons", x + wide/2 + math.Rand(-4, 4), y + tall*0.2+ math.Rand(-9, 9), Color( 255, 210, 0, math.Rand(10, 120) ), TEXT_ALIGN_CENTER )

	draw.SimpleText( self.IconLetterCSS, "CSSelectIcons", x + wide/2, y + tall*0.2, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
	
	// try to fool them into thinking they're playing a Tony Hawks game
	draw.SimpleText( self.IconLetterCSS, "CSSelectIcons", x + wide/2 + math.Rand(-4, 4), y + tall*0.2+ math.Rand(-14, 14), Color( 255, 210, 0, math.Rand(10, 120) ), TEXT_ALIGN_CENTER )
	draw.SimpleText( self.IconLetterCSS, "CSSelectIcons", x + wide/2 + math.Rand(-4, 4), y + tall*0.2+ math.Rand(-9, 9), Color( 255, 210, 0, math.Rand(10, 120) ), TEXT_ALIGN_CENTER )
	
end

SWEP.RecoilMax = 1
SWEP.RecoilReturn = 0.2
	
local IRONSIGHT_TIME = 0.15
/*---------------------------------------------------------
   Name: GetViewModelPosition
   Desc: Allows you to re-position the view model
---------------------------------------------------------*/
function SWEP:GetViewModelPosition( pos, ang )

	if ( !self.IronSightsPos ) then return pos, ang end

	local bIron = self.Weapon:GetNetworkedBool( "Ironsights" )
	
	if (bIron != self.bLastIron) then
		self.bLastIron = bIron 
		self.fIronTime = CurTime()
		
		if (bIron) then 
			self.SwayScale 	= 0.3
			self.BobScale 	= 0.1
		else 
			self.SwayScale 	= 1.0
			self.BobScale 	= 1.0
		end
	
	end
	
	local fIronTime = self.fIronTime or 0
	
	if (!bIron && fIronTime < CurTime() - IRONSIGHT_TIME) then 
		return pos, ang
	end
	
	local Mul = 1.0
	
	if (fIronTime > CurTime() - IRONSIGHT_TIME) then
		Mul = math.Clamp((CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1)

		if (!bIron) then Mul = 1 - Mul end
	end 
	
	if  self.SetNextFireMode2 > CurTime()  then
			if self.Recoil == self.Recoil then
				self.Recoil = self.Recoil + self.RecoilReturn
			end
		else
			if self.Recoil > self.RecoilMax then
				self.Recoil = self.Recoil - self.RecoilReturn
			end
	end
	
	local OriginalOrigin = self.IronSightsPos
	local VMLoc	= OriginalOrigin - Vector(0	,self.Recoil,0)


	if (self.IronSightsAng) then
		ang = ang * 1
		ang:RotateAroundAxis(ang:Right(), 	self.IronSightsAng.x * Mul)
		ang:RotateAroundAxis(ang:Up(), 	self.IronSightsAng.y * Mul)
		ang:RotateAroundAxis(ang:Forward(), self.IronSightsAng.z * Mul)
	end
	
	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()
	
	pos = pos + VMLoc.x * Right * Mul
	pos = pos + VMLoc.y * Forward * Mul
	pos = pos + VMLoc.z * Up * Mul
	
	return pos, ang
end

SWEP.NextSecondaryAttack = 0

/*---------------------------------------------------------
	Silence Timings and Stuff
---------------------------------------------------------*/
function SWEP:Silence()
	
	if  self.Weapon:GetNetworkedBool("Silenced") == false then
		self:SetIronsights( false )
		self.Weapon:SetNetworkedBool("Silenced", true)
		self.Weapon:SendWeaponAnim( ACT_VM_ATTACH_SILENCER )
		self.CSMuzzleFlashes	= true
	
	else
		self.Weapon:SetNetworkedBool("Silenced", false)
		self:SetIronsights( false )
		self.Weapon:SendWeaponAnim( ACT_VM_DETACH_SILENCER )
		self.CSMuzzleFlashes	= true
	end

	self:SetIronsights( false )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.SilenceHolster + .1)
	self.Weapon:SetNextSecondaryFire( CurTime() + self.SilenceHolster + .5)
	self.Reloadaftershoot = CurTime() + 3 
	self.Weapon:SetNetworkedInt("deploydelay", CurTime() + 3);
end


/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()


	if self.Owner:KeyDown(IN_USE) and (self.Silenceable) then
	
	self:SetNWInt("skipthink", true)
	timer.Simple(self.SilenceHolster, 
		function() 
		if self.Weapon == nil then return end
		self:SetNWInt("skipthink", false)
	end)
	//Skip the entire Think Function
	
	self.Weapon:SetNetworkedBool("Ironsights", false)
	//Set the ironsight to false
	
	self:Silence()
	
	if not self.Owner:KeyDown(IN_SPEED) then self.Weapon:SetNetworkedBool("Ironsights", false)
	end
	self.Owner:SetFOV(0, 0.15)
	self.Primary.Recoil = self.Recoil
	
	end

	if not self.Owner:OnGround() then return end
	if self.Owner:KeyDown(IN_SPEED) then return end
	if self.Owner:KeyDown(IN_USE) then return end
	
	if ( self.NextSecondaryAttack > CurTime() ) then return end
	
	bIronsights = !self.Weapon:GetNetworkedBool( "Ironsights", false )
	
	self:SetIronsights( bIronsights )
	
	self.NextSecondaryAttack = CurTime() + 0.3
	
end



/*---------------------------------------------------------
SetIronsights
---------------------------------------------------------*/
function SWEP:SetIronsights(b)

	
	if self.Owner:KeyDown(IN_USE) then return end
	
	if self.Owner:KeyDown(IN_SPEED) then return end
	
	if !self.Owner:OnGround() then return end
	
	self.Weapon:SetNetworkedBool("Ironsights", b)
		if self.Weapon:GetNetworkedBool( "Ironsights") then
			self.Primary.Recoil = self.recoilzoom
			self.IronSightsPos = self.AimSightsPos
			self.IronSightsAng = self.AimSightsAng
			self.Weapon:EmitSound("weapons/universal/iron_in.wav")
			self.Owner:SetFOV(self.ZoomFOV, 0.15)
				if self.CSSZoom then
					self.Primary.Recoil = self.RecoilZoom
					self.Primary.Delay  = self.DelayZoom
				end
		else
				self.Owner:SetFOV(0, 0.15)
				self.Primary.Recoil = self:GetNWInt("recoil")
						if self.CSSZoom then
							self.Primary.Recoil = self.Recoil
							self.Primary.Delay  = self.Delay
				end
				self.Weapon:EmitSound("weapons/universal/iron_out.wav")
		end
		
end


/*---------------------------------------------------------
	Draw a CrossHair! 
---------------------------------------------------------*/

//Ripped from LeErOy NeWmAn, Don't tell him shhh

SWEP.CrosshairScale = 1
function SWEP:DrawHUD()
	
	local Hl2CrossHair = true
	
		if GetConVar("cl_ptp_hl2crosshair_enable") == nil then
		Hl2CrossHair = true
		else
		Hl2CrossHair = GetConVar("cl_ptp_hl2crosshair_enable"):GetBool()
		end

	if not(Hl2CrossHair) then
	
	self.DrawCrosshair = false
	// Make Sure this shit goes away
	
	local DisableDashing = false
	
		if GetConVar("sv_ptp_dashing_disable") == nil then
		DisableDashing = false
		else
		DisableDashing = GetConVar("sv_ptp_dashing_disable"):GetBool()
		end
		
	if self.Owner:KeyDown(IN_SPEED) and not DisableDashing then return end
	//Remove CrossHair on Sprint
	
	local DrawCrossHair = false
	
	if GetConVar("cl_ptp_crosshair_disable") == nil then
		DrawCrossHair = false
	else
		DrawCrossHair = GetConVar("cl_ptp_crosshair_disable"):GetBool()
	end
	
	if DrawCrossHair then return end
	
	if self.Weapon:GetNetworkedBool( "Ironsights" , true) then return end
	//Remove on IronSights
	
	local x = ScrW() * 0.5
	local y = ScrH() * 0.5
	local scalebywidth = (ScrW() / 1024) * 5

	local scale = 2
	local canscale = true


scale = scalebywidth * self.Primary.Cone

	surface.SetDrawColor(8, 255, 0, 255)

local LastShootTime = self.Weapon:GetNetworkedFloat( "LastShootTime", 0 )
	scale = scale * (2 - math.Clamp( (CurTime() - LastShootTime) * 5, 0.0, 1.0 ))

	local dist = math.abs(self.CrosshairScale - scale)
	self.CrosshairScale = math.Approach(self.CrosshairScale, scale, FrameTime() * 2 + dist * 0.05)

	local gap = 30 * self.CrosshairScale
	local length = gap + 15 * self.CrosshairScale
	surface.DrawLine(x - length, y, x - gap, y)
	surface.DrawLine(x + length, y, x + gap, y)
	surface.DrawLine(x, y - length, x, y - gap)
	surface.DrawLine(x, y + length, x, y + gap)

	//surface.DrawLine(x-2, y, x+2, y)
	//surface.DrawLine(x, y-2, x, y+2)
	else
	
	if self.Weapon:GetNetworkedBool( "Ironsights" , true) then 
		self.DrawCrosshair = false
		else
		self.DrawCrosshair = true
	end
	end
end