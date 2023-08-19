
local sndMissileFire = Sound("weapons/stinger_fire1.wav")
local sndFucked = Sound("HL1/fvox/near_death.wav")


if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	AddCSLuaFile( "cl_init.lua" )
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= true
	SWEP.AutoSwitchFrom		= true
	
	SWEP.HoldType			= "ar2"

end

if ( CLIENT ) then

	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= true
	SWEP.ViewModelFOV		= 64
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	
	
	SWEP.PrintName			= "Nuclear Airstrike"			
	SWEP.Author				= "Teta_Bonita"
	SWEP.Category			= "Nuclear Warfare"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 11
	
end

SWEP.Author			= "Teta_Bonita"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= "Aim away from face"

SWEP.Spawnable		= true
SWEP.AdminOnly		= true

SWEP.ViewModel			= "models/weapons/v_IRifle.mdl"
SWEP.WorldModel			= "models/weapons/w_IRifle.mdl"

SWEP.Primary.Recoil			= 0
SWEP.Primary.Damage			= -1
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0
SWEP.Primary.Delay			= 2

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 2
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "slam"

SWEP.Secondary.Recoil		= 0
SWEP.Secondary.Damage		= -1
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0
SWEP.Secondary.Delay		= 2

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.Rocket = SWEP.Rocket or NULL
SWEP.RocketPhysObj = NULL
SWEP.IsFucked = false
SWEP.DrawSpriteTime = 0

function SWEP:Initialize()

	if ( SERVER ) then
		self:SetWeaponHoldType( self.HoldType )
	end

end


function SWEP:Deploy()


end


function SWEP:Reload()
	self.Weapon:DefaultReload( ACT_VM_RELOAD )
end

function SWEP:Think()

	if self.Rocket and self.Rocket:IsValid() then
	
		if self.IsFucked then
		
			local RocketAng = (self.Owner:GetPos() - self.Rocket:GetPos()):GetNormalized()
			self.Rocket:SetAngles(RocketAng:Angle())
			self.RocketPhysObj:SetVelocity(RocketAng*1200)
			
			self.Weapon:SetNextPrimaryFire( CurTime() + 1e-5 )
	
		elseif self.Owner:KeyDown(IN_ATTACK) and self.Weapon:Clip1() < 1 then
		
			local hitpos = self.Owner:GetEyeTrace().HitPos
			
			local RocketAng = (hitpos - self.Rocket:GetPos()):GetNormalized()
			self.Rocket:SetAngles(RocketAng:Angle())
			self.RocketPhysObj:SetVelocity(RocketAng*1200)
			
			self.Weapon:SetNextPrimaryFire( CurTime() + 1e-5 )
		
		end
		
	end

end

function SWEP:PrimaryAttack()
	if self.Weapon:Clip1() < 1 then return end
	
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:TakePrimaryAmmo(1)

	if SERVER then
		local PlayerPos = self.Owner:GetShootPos()
		local PlayerAng = self.Owner:GetAimVector()
		
		local trace = {}
		trace.start = PlayerPos + PlayerAng*16
		trace.endpos = PlayerPos + PlayerAng*65536
		trace.filter = {self.Owner}
		local hitpos = util.TraceLine(trace).HitPos
		
		trace.start = hitpos + Vector(0,0,2048)
		trace.endpos = trace.start + Vector(0,0,6144)
		local traceRes = util.TraceLine(trace)
		local spawnpos
		
		if traceRes.Hit then
			spawnpos = traceRes.HitPos - Vector(0,0,64)
		else
			spawnpos = hitpos + Vector(0,0,8192)
		end

		self.Rocket = ents.Create("sent_nuke_missile")
		self.Rocket:SetVar("owner",self.Owner)
		self.Rocket:SetPos(spawnpos)
		self.Rocket:SetAngles(Angle(90,0,0))
		self.Rocket:Spawn()
		self.Rocket:Activate()
		self.RocketPhysObj = self.Rocket:GetPhysicsObject()
		
		self.Rocket:EmitSound(sndMissileFire)
	end
end

function SWEP:SecondaryAttack()
	if self.Weapon:Clip1() < 1 then return end
	
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	
	if not self.IsFucked then
		self.IsFucked = true --fuck yourself
		self:TakePrimaryAmmo(1)
		
		if SERVER then
			local PlayerPos = self.Owner:GetPos()
			local trace = {}
			trace.start = PlayerPos + Vector(0,0,2048)
			trace.endpos = trace.start + Vector(0,0,6144)
			local traceRes = util.TraceLine(trace)
			local spawnpos
			
			if traceRes.Hit then
				spawnpos = traceRes.HitPos - Vector(0,0,64)
			else
				spawnpos = PlayerPos + Vector(0,0,8192)
			end

			self.Rocket = ents.Create("sent_nuke_missile")
			self.Rocket:SetVar("owner",self.Owner)
			self.Rocket:SetPos(spawnpos)
			self.Rocket:SetAngles(Angle(90,0,0))
			self.Rocket:Spawn()
			self.Rocket:Activate()
			self.RocketPhysObj = self.Rocket:GetPhysicsObject()
			
			self.Rocket:EmitSound(sndMissileFire)
			self.Owner:EmitSound(sndFucked)
		end
	end

end


function SWEP:Holster()
	return true
end


function SWEP:OnRemove()
	return true
end


