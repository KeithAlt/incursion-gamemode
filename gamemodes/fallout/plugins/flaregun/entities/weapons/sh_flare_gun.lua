local PLUGIN = PLUGIN

SWEP.Author = "Zombie Extinguisher"
SWEP.Contact = ""
SWEP.Purpose = "Shoot Flares to get rescued"
SWEP.Instructions = "Reload on full clip to change the Flaremode"
SWEP.Base = "weapon_base"
SWEP.Gun = ("flaregun_hud")

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false
SWEP.HoldType			= "pistol"
SWEP.Category 			= "Zombie's Weps"
SWEP.PrintName 			= "The Flare Gun"

SWEP.Secondary.IronFOV			= 60

SWEP.Slot = 1
SWEP.SlotPos = 3
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.ViewModelFOV = 65
SWEP.ViewModelFlip = false
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.BounceWeaponIcon   	= false

SWEP.ViewModel = "models/weapons/v_flaregun.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"

SWEP.Primary.Sound = Sound( "weapons/flaregun/fire.wav" )
SWEP.Primary.NumShots = 1
SWEP.Primary.ClipSize = 3
SWEP.Primary.DefaultClip = 3
SWEP.Primary.Automatic = false
SWEP.Primary.Delay = 10
SWEP.IsAlwaysRaised = true

SWEP.Secondary.Sound = Sound( "weapons/flaregun/fire.wav" )
SWEP.Secondary.NumShots = 1
SWEP.Secondary.ClipSize = 6
SWEP.Secondary.DefaultClip = 30
SWEP.Secondary.Automatic = false
SWEP.Secondary.Delay = 10

SWEP.SightsPos = Vector(-5.64, -6.535, 2.68)
SWEP.SightsAng = Vector(0, 0, 0)
SWEP.RunSightsPos = Vector (2, -5, -5)
SWEP.RunSightsAng = Vector (15, 0, 0)

local EnableMode3= CreateConVar( "flaregun_mode3", 1 )
local EnableMode2= CreateConVar( "flaregun_mode2", 1 )


function SWEP:PrimaryAttack()
	if self:Clip1() <= 0 then return end

	if(SERVER) then
		PLUGIN:flareLaunch(self.Owner)
	end

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	self:ShootFlare()
	self.Weapon:EmitSound( self.Primary.Sound )
	self:SetClip1( self:Clip1() -1 )
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
	if self:Clip1() == 0 then
		self:DefaultReload( ACT_VM_RELOAD )
	end
end

function SWEP:ShootFlare()
	if SERVER then
		local tracer = self.Owner:GetEyeTrace()
		local Flare1 = ents.Create( "env_flare" )
		if !Flare1:IsValid() then return false end
		Flare1:SetPos(self.Owner:GetShootPos())
		Flare1:SetAngles( self.Owner:GetAimVector( ):Angle() )
		Flare1:SetKeyValue("spawnflags", 4)
		Flare1:SetKeyValue( "scale", "9" )
		Flare1:EmitSound("Weapon_Flaregun.Burn")
		Flare1:Spawn()
		SafeRemoveEntityDelayed(Flare1, 100)
		Flare1:Activate()
		Flare1:Fire( "Launch", "1500", 0.1 )
		self.Owner:falloutNotify("You have shot an Emergency Flare", "HL1/fvox/bell.wav")

		timer.Simple(nut.config.get("flareTime", 30), function()
			SafeRemoveEntity(Flare1)
		end)
	end
end

function SWEP:FireDamage()
	if SERVER then
	flame = ents.Create("point_hurt")

	flame:SetPos(Flare3:GetPos())
	if !flame:IsValid() then return false end
	flame:SetOwner(self.Owner)
	flame:SetKeyValue("DamageRadius", 10000)
	flame:SetKeyValue("Damage", 10)
	flame:SetKeyValue("DamageDelay", 0.4)
	flame:SetKeyValue("DamageType", 8)
	flame:Spawn()
	flame:Fire("TurnOn", "", 0)
	flame:Fire("kill", "", 0.5)
	end
end

function SWEP:ShootFlare2()
	if SERVER then
	local tracer = self.Owner:GetEyeTrace()

	Flare2 = ents.Create( "env_flare" )
	if !Flare2:IsValid() then return false end
	Flare2:SetPos(self.Owner:GetShootPos())
	Flare2:SetAngles( self.Owner:GetAimVector( ):Angle() )
	Flare2:SetKeyValue("spawnflags", 4)
	Flare2:SetKeyValue( "scale", "20" )
	Flare2:EmitSound("Weapon_Flaregun.Burn")
	Flare2:Spawn()
	SafeRemoveEntityDelayed(Flare2, 200)
	Flare2:Activate()
	Flare2:Fire( "Launch", "5000", 0.1 )
	end
end

function SWEP:ShootFlare3()
	if SERVER then
	local tracer = self.Owner:GetEyeTrace()
	Flare3 = ents.Create( "env_flare" )
	if !Flare3:IsValid() then return false end
	Flare3:SetPos(self.Owner:GetShootPos())
	Flare3:SetAngles( self.Owner:GetAimVector( ):Angle() )
	Flare3:SetKeyValue("spawnflags", 4)
	Flare3:SetKeyValue( "scale", "60" )
	Flare3:EmitSound("Weapon_Flaregun.Burn")
	Flare3:Spawn()
	SafeRemoveEntityDelayed(Flare3, 200)
	Flare3:Activate()
	Flare3:Fire( "Launch", "1500", 0.1 )
	end
end

function SWEP:Reload()

	if self:Clip1() == 6 then
		if self.mode == 1 and CurTime() > self.changemode then
		self.changemode = CurTime() + 1
		self:SetClip1( self:Clip1() -1 )
		self:DefaultReload( ACT_VM_RELOAD )
		self.Weapon:EmitSound(Sound("AmmoCrate.Open"))
		self:SetClip1( self:Clip1() +1 )
		if SERVER then
			--self.Owner:PrintMessage(HUD_PRINTTALK, "Big Flares Selected")
		end
		self.mode = 2

		elseif self.mode == 2 and CurTime() > self.changemode then
		self.changemode = CurTime() + 1
		self:SetClip1( self:Clip1() -1 )
		self:DefaultReload( ACT_VM_RELOAD )
		self.Weapon:EmitSound(Sound("AmmoCrate.Open"))
		self:SetClip1( self:Clip1() +1 )
		if SERVER then
			--self.Owner:PrintMessage(HUD_PRINTTALK, "Flare Fire Emitters Selected")
		end
		self.mode = 3

		elseif self.mode == 3 and CurTime() > self.changemode then
		self.changemode = CurTime() + 1
		self:SetClip1( self:Clip1() -1 )
		self:DefaultReload( ACT_VM_RELOAD )
		self.Weapon:EmitSound(Sound("AmmoCrate.Open"))
		self:SetClip1( self:Clip1() +1 )
		if SERVER then
			--self.Owner:PrintMessage(HUD_PRINTTALK, "Small Flares Selected")
		end
		self.mode = 1
	end

	elseif self:Clip1() < 6 then
		self:DefaultReload( ACT_VM_RELOAD )
	end

end

function SWEP:SecondaryAttack()
end

function SWEP:Initialize()
	self.mode = 1
	self.changemode = 0

	if CLIENT then
		local oldpath = "vgui/hud/name" -- the path goes here
		local newpath = string.gsub(oldpath, "name", self.Gun)
		self.WepSelectIcon = surface.GetTextureID(newpath)
	end
end

function SWEP:IronSight()

	if !self.Owner:IsNPC() then
	if self.ResetSights and CurTime() >= self.ResetSights then
	self.ResetSights = nil

	if self.Silenced then
		self:SendWeaponAnim(ACT_VM_IDLE_SILENCED)
	else
		self:SendWeaponAnim(ACT_VM_IDLE)
	end
	end end

	if self.CanBeSilenced and self.NextSilence < CurTime() then
		if self.Owner:KeyDown(IN_USE) and self.Owner:KeyPressed(IN_ATTACK2) then
			self:Silencer()
		end
	end

	if self.SelectiveFire and self.NextFireSelect < CurTime() and not (self.Weapon:GetNWBool("Reloading")) then
		if self.Owner:KeyDown(IN_USE) and self.Owner:KeyPressed(IN_RELOAD) then
			self:SelectFireMode()
		end
	end

--copy this...
	if self.Owner:KeyDown(IN_SPEED) and not (self.Weapon:GetNWBool("Reloading")) then		-- If you are running
	self.Weapon:SetNextPrimaryFire(CurTime()+0.3)				-- Make it so you can't shoot for another quarter second
	self.IronSightsPos = self.RunSightsPos					-- Hold it down
	self.IronSightsAng = self.RunSightsAng					-- Hold it down
	self:SetIronsights(true, self.Owner)					-- Set the ironsight true
	self.Owner:SetFOV( 0, 0.3 )
	end

	if self.Owner:KeyReleased (IN_SPEED) then	-- If you release run then
	self:SetIronsights(false, self.Owner)					-- Set the ironsight true
	self.Owner:SetFOV( 0, 0.3 )
	end								-- Shoulder the gun

--down to this
	if !self.Owner:KeyDown(IN_USE) and !self.Owner:KeyDown(IN_SPEED) then
	-- If the key E (Use Key) is not pressed, then

		if self.Owner:KeyPressed(IN_ATTACK2) and not (self.Weapon:GetNWBool("Reloading")) then
			self.Owner:SetFOV( self.Secondary.IronFOV, 0.3 )
			self.IronSightsPos = self.SightsPos					-- Bring it up
			self.IronSightsAng = self.SightsAng					-- Bring it up
			self:SetIronsights(true, self.Owner)
			self.DrawCrosshair = false
			-- Set the ironsight true

			if CLIENT then return end
 		end
	end

	if self.Owner:KeyReleased(IN_ATTACK2) and !self.Owner:KeyDown(IN_USE) and !self.Owner:KeyDown(IN_SPEED) then
	-- If the right click is released, then
		self.Owner:SetFOV( 0, 0.3 )
		self.DrawCrosshair = true
		self:SetIronsights(false, self.Owner)
		-- Set the ironsight false

		if CLIENT then return end
	end

		if self.Owner:KeyDown(IN_ATTACK2) and !self.Owner:KeyDown(IN_USE) and !self.Owner:KeyDown(IN_SPEED) then
		self.SwayScale 	= 0.05
		self.BobScale 	= 0.05
		else
		self.SwayScale 	= 1.0
		self.BobScale 	= 1.0
		end
end

/*---------------------------------------------------------
Think
---------------------------------------------------------*/


function SWEP:Think()
	self:IronSight()
end

/*---------------------------------------------------------
GetViewModelPosition
---------------------------------------------------------*/
local IRONSIGHT_TIME = 0.3
-- Time to enter in the ironsight mod

function SWEP:GetViewModelPosition(pos, ang)

	if (not self.IronSightsPos) then return pos, ang end

	local bIron = self.Weapon:GetNWBool("Ironsights")

	if (bIron != self.bLastIron) then
		self.bLastIron = bIron
		self.fIronTime = CurTime()

	end

	local fIronTime = self.fIronTime or 0

	if (not bIron and fIronTime < CurTime() - IRONSIGHT_TIME) then
		return pos, ang
	end

	local Mul = 1.0

	if (fIronTime > CurTime() - IRONSIGHT_TIME) then
		Mul = math.Clamp((CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1)

		if not bIron then Mul = 1 - Mul end
	end

	local Offset	= self.IronSightsPos

	if (self.IronSightsAng) then
		ang = ang * 1
		ang:RotateAroundAxis(ang:Right(), 		self.IronSightsAng.x * Mul)
		ang:RotateAroundAxis(ang:Up(), 		self.IronSightsAng.y * Mul)
		ang:RotateAroundAxis(ang:Forward(), 	self.IronSightsAng.z * Mul)
	end

	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()

	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul

	return pos, ang
end

/*---------------------------------------------------------
SetIronsights
---------------------------------------------------------*/
function SWEP:SetIronsights(b)
	self.Weapon:SetNetworkedBool("Ironsights", b)
end

function SWEP:GetIronsights()
	return self.Weapon:GetNWBool("Ironsights")
end
