
local sndRPGFire = Sound("Weapon_RPG.Single")
REDEEMER = {}

if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	AddCSLuaFile( "cl_init.lua" )
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= true
	SWEP.AutoSwitchFrom		= true
	
	SWEP.HoldType			= "rpg"

end

if ( CLIENT ) then

	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= true
	SWEP.ViewModelFOV		= 72
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	
	
	SWEP.PrintName			= "Mach Nuke"			
	SWEP.Author				= "RayFanMan (RayFan9876)"
	SWEP.Category			= "Nuclear Warfare"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 10

end

SWEP.Author			= "RayFanMan (RayFan9876)"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= "Fires nukes very fast!! Keep away from face."

SWEP.Spawnable		= true
SWEP.AdminOnly		= true

SWEP.ViewModel			= "models/weapons/v_toolgun.mdl"
SWEP.WorldModel			= "models/weapons/w_toolgun.mdl"

SWEP.Primary.Recoil			= 1.5
SWEP.Primary.Damage			= -1
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0
SWEP.Primary.Delay			= 0.3

SWEP.Primary.ClipSize		= 12
SWEP.Primary.DefaultClip	= 24
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "slam"
SWEP.Primary.NextFire 		= 0

SWEP.Secondary.Recoil		= 0
SWEP.Secondary.Damage		= -1
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0
SWEP.Secondary.Delay		= 0.3

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.NextFire 	= 0

SWEP.Rocket = SWEP.Rocket or NULL
SWEP.IsGuidingNuke = false
SWEP.DrawReticle = false
SWEP.LastAng = Vector(0,0,0)


function SWEP:Initialize()

	if ( SERVER ) then
		self:SetWeaponHoldType( self.HoldType )
	end

end


function SWEP:Deploy()

	self.Owner:SetNWBool("DrawReticle",false)

end


function SWEP:Reload()
	if self.Rocket and self.Rocket:IsValid() then return false end
	self.Weapon:DefaultReload( ACT_VM_RELOAD )
end

function SWEP:Think()

	if self.IsGuidingNuke and self.Rocket and self.Rocket:IsValid() then
		local PlayerAng = self.Owner:GetAimVector()
		self.Rocket:SetAngles(PlayerAng:Angle())
		self.RocketPhysObj:SetVelocity(PlayerAng*1200)
		
		local ViewEnt = self.Owner:GetViewEntity() -- we should be able to do this client-side, but for some fucking reason GetViewEntity() is server only
		
		if self.DrawReticle and ViewEnt ~= self.Rocket then
			self.DrawReticle = false
			self.Owner:SetNWBool("DrawReticle",false)
		end
		
		if not self.DrawReticle and ViewEnt == self.Rocket then
			self.DrawReticle = true
			self.Owner:SetNWBool("DrawReticle",true)
		end
		
		if ViewEnt == self.Owner or ViewEnt == NULL then
			self.Owner:SetViewEntity(self.Rocket) 
		end
		
	else
		self:StopGuiding()
	end

end

function SWEP:PrimaryAttack()
	if self.Primary.NextFire > CurTime() or self.Weapon:Clip1() < 1 then return end
	
	self.Primary.NextFire = CurTime() + self.Primary.Delay
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Weapon:EmitSound(sndRPGFire)
	self.Owner:MuzzleFlash()
	self:TakePrimaryAmmo(1)
	
	if SERVER then
		if self.IsGuidingNuke and self.Rocket and self.Rocket:IsValid() then
			self:StopGuiding()
			local nuke = ents.Create("sent_nuke")
			nuke:SetPos( self.Rocket:GetPos() )
			nuke:SetOwner(self.Owner)
			nuke:Spawn()
			nuke:Activate()
			self.Rocket:Remove()
			
			return
		end

		local PlayerPos = self.Owner:GetShootPos()
		local PlayerAng = self.Owner:GetAimVector()
		
		--the muzzle attachement for the rocket launcher is fucked, so we need to adjust the missile's position by hand
		local PlayerForward = self.Owner:GetForward()
		local PlayerRight = self.Owner:GetRight()
		local SpawnPos = PlayerPos + 32*PlayerForward + 32*PlayerRight
		
		local trace = {}
		trace.start = PlayerPos + PlayerAng*32
		trace.endpos = PlayerPos + PlayerAng*16384
		trace.filter = {self.Owner}
		local traceRes = util.TraceLine(trace)

		self.Rocket = ents.Create("sent_nuke_missile")
		self.Rocket:SetVar("owner",self.Owner)
		self.Rocket:SetPos(SpawnPos)
		self.Rocket:SetAngles(PlayerAng:Angle())
		self.Rocket:Spawn()
		self.Rocket:Activate()
		
		self.RocketPhysObj = self.Rocket:GetPhysicsObject()
		self.RocketPhysObj:SetVelocity(PlayerAng*512 - 16*PlayerRight + Vector(0,0,256))
		
		timer.Simple(0.5, function() REDEEMER.AimRocket(self.Rocket, traceRes.HitPos) end)
	end
end

function SWEP:SecondaryAttack()

	if self.Secondary.NextFire > CurTime() then 
	return end
	
	self.Secondary.NextFire = CurTime() + self.Secondary.Delay

	if self.IsGuidingNuke then
		self:StopGuiding()
	else
		self:StartGuiding()
	end
	
end

function SWEP:StartGuiding()

	if not self.Rocket or self.Rocket == NULL then return end

	self.LastAng = self.Owner:EyeAngles()
	self.Owner:SetEyeAngles(self.Rocket:GetAngles())
	
	self.IsGuidingNuke = true
	self.DrawReticle = true
	self.Owner:SetNWBool("DrawReticle",true)
	self.Owner:SetViewEntity(self.Rocket)
	
	if SERVER then
		self.Owner:DrawViewModel(false) --we need to hide the viewmodel while we're guiding the rocket.  Otherwise it would look fugly.
		self.Owner:CrosshairDisable()
	end


end

function SWEP:StopGuiding()

	if not self.IsGuidingNuke then return end

	self.IsGuidingNuke = false
	self.DrawReticle = false
	self.Owner:SetNWBool("DrawReticle",false)
	self.Owner:SetViewEntity(self.Owner)
	
	if SERVER then
		self.Owner:DrawViewModel(true)
		self.Owner:CrosshairEnable()
	end
	
	self.Owner:SetEyeAngles(self.LastAng)
	
end

function REDEEMER.AimRocket(rocket,pos)

	local NewAng = (pos - rocket:GetPos()):GetNormalized()
	rocket:SetAngles(NewAng:Angle())

end


function SWEP:Holster()

	self:StopGuiding()
	return true

end


function SWEP:OnRemove()

	self:StopGuiding()
	return true
end


