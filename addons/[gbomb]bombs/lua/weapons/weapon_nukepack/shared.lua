
if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	--AddCSLuaFile( "cl_init.lua" )
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= true
	SWEP.AutoSwitchFrom		= true
	
	SWEP.HoldType			= "smg"

end

if ( CLIENT ) then

	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= true
	SWEP.ViewModelFOV		= 64
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	
	
	SWEP.PrintName			= "Nuclear Detonation Pack"			
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

SWEP.ViewModel			= "models/weapons/v_c4.mdl"
SWEP.WorldModel			= "models/weapons/w_c4.mdl"

SWEP.Primary.Recoil			= 0
SWEP.Primary.Damage			= -1
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0
SWEP.Primary.Delay			= 3.5

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 2
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "slam"

SWEP.Secondary.Recoil		= 0
SWEP.Secondary.Damage		= -1
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0
SWEP.Secondary.Delay		= 0.2
SWEP.Secondary.NextFire 	= 0

SWEP.Secondary.ClipSize		= 1
SWEP.Secondary.DefaultClip	= 1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.DetTime = 20

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

	
end

local PlantBomb = function(EntTable)
	if (!IsValid(EntTable) || !EntTable.Owner:Alive()) then return end

	local PlayerPos = EntTable.Owner:GetShootPos()
	local PlayerAng = EntTable.Owner:GetAimVector()
	
	local trace = {}
	trace.start = PlayerPos + PlayerAng*4
	trace.endpos = PlayerPos + PlayerAng*40
	trace.filter = {EntTable.Owner}
	local hitpos = util.TraceLine(trace).HitPos
	
	local bomb = ents.Create("sent_nuke_detpack")
	bomb:SetVar("DetTime",EntTable.DetTime)
	bomb:SetNWInt("DetTime",EntTable.DetTime)
	bomb:SetPos(hitpos)
	bomb:SetOwner(EntTable.Owner)
	bomb:Spawn()

end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self:TakePrimaryAmmo(1)
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	if SERVER then timer.Simple(self.Primary.Delay + 0.2, function() PlantBomb(self) end) end
end

function SWEP:SecondaryAttack()
	if self.Secondary.NextFire > CurTime() then 
	return end
	
	self.Secondary.NextFire = CurTime() + self.Secondary.Delay
	
	if self.DetTime == 10 then
		self.DetTime = 20
	elseif self.DetTime == 20 then
		self.DetTime = 30
	else
		self.DetTime = 10
	end
	
	self.Owner:PrintMessage(HUD_PRINTCENTER,"Detonation Time: "..self.DetTime.." seconds")

end


function SWEP:Holster()
	return true
end


function SWEP:OnRemove()
	return true
end


