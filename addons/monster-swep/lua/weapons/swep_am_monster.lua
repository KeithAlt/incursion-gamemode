AddCSLuaFile()

SWEP.Base = "weapon_base"
SWEP.PrintName = "Monster abilities"
SWEP.Author = "Amarok"
SWEP.Instructions = "Left click to attack, right click to leap, reload to activate 'night vision'."
SWEP.Spawnable = true
SWEP.AdminSpawnable = false

SWEP.HoldType = "knife"
SWEP.ViewModel = Model("models/weapons/v_hands.mdl")
SWEP.WorldModel = ""

SWEP.HitDistance = 50

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay = 1

SWEP.Secondary.ClipSize		= 5
SWEP.Secondary.DefaultClip	= 5
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.Delay = 5

SWEP.Nightvision = false
SWEP.SwayScale = 1.25
SWEP.IsAlwaysLowered = true
SWEP.FireWhenLowered = true
SWEP.NextReload = CurTime()

SWEP.Slot				= 3
SWEP.SlotPos			= 4

if ( SERVER ) then
	util.AddNetworkString( "AM_NightvisionOn" )
	util.AddNetworkString( "AM_NightvisionOff" )
end

function SWEP:Initialize()

	self:SetWeaponHoldType( self.HoldType )

end


function SWEP:PrimaryAttack()

	if ( SERVER ) then

		if ( not self:CanPrimaryAttack() ) then return end

		self.Owner:LagCompensation( true )
		local HitSounds = { "npc/fast_zombie/claw_strike1.wav", "npc/fast_zombie/claw_strike2.wav", "npc/fast_zombie/claw_strike3.wav" }
		local trc = self.Owner:GetEyeTrace()
		if not IsValid(trc.Entity) or (self.Owner:EyePos():Distance(trc.Entity:GetPos()) > 100) then
			self.Owner:EmitSound( "npc/zombie/claw_miss1.wav", 80, 100 )
		else
			self:ShootBullet( 0, 1, 0 )
			trc.Entity:TakeDamage( 35, self:GetOwner(), self )
			self.Owner:EmitSound( HitSounds[math.random(3)], 100, 100 )
		end
		self.Owner:LagCompensation( false )
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )


	end
end


function SWEP:SecondaryAttack()

	if ( SERVER ) then

		if ( not self:CanSecondaryAttack() ) or self.Owner:IsOnGround() == false then return end

		local JumpSounds = { "npc/fast_zombie/leap1.wav", "npc/zombie/zo_attack2.wav", "npc/fast_zombie/fz_alert_close1.wav", "npc/zombie/zombie_alert1.wav" }
		self.SecondaryDelay = CurTime()+10
		self.Owner:SetVelocity( self.Owner:GetForward() * 200 + Vector(0,0,400) )
		self.Owner:EmitSound( JumpSounds[math.random(4)], 100, 100 )
		self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )

	end
end


function SWEP:Reload()

	if ( SERVER ) then
		if self.NextReload > CurTime() then return end

		self.NextReload = CurTime() + 2
		local ply = self:GetOwner()
		if self.Nightvision == false then
			self.Nightvision = true
			net.Start( "AM_NightvisionOn" )
			net.WriteEntity( ply )
			net.Send( ply )
		elseif self.Nightvision == true then
			self.Nightvision = false
			net.Start( "AM_NightvisionOff" )
			net.WriteEntity( ply )
			net.Send( ply )
		end
	end

end

function SWEP:Deploy()
	if ( SERVER ) then
		self.Owner.ShouldReduceFallDamage = true
		return true
	end
end

function SWEP:OnRemove()

	if ( SERVER ) then
		if self.Nightvision == true then
			self.Nightvision = false
			local ply = self:GetOwner()
			net.Start( "AM_NightvisionOff" )
			net.WriteEntity( ply )
			net.Send( ply )
		end
	end

end


function SWEP:Holster()

	if ( SERVER ) then
		local ply = self:GetOwner()
		self.Nightvision = false
		net.Start( "AM_NightvisionOff" )
		net.WriteEntity( ply )
		net.Send( ply )
		self.Owner.ShouldReduceFallDamage = false
		return true
	end

end


if( CLIENT ) then

	net.Receive( "AM_NightvisionOn", function ( len, ply )
		local ply = net.ReadEntity()
		am_nightvision = DynamicLight( 0 )
		if ( am_nightvision ) then
			am_nightvision.Pos = ply:GetPos()
			am_nightvision.r = 11
			am_nightvision.g = 50
			am_nightvision.b = 4
			am_nightvision.Brightness = 1
			am_nightvision.Size = 2000
			am_nightvision.DieTime = CurTime()+100000
			am_nightvision.Style = 1
		end
		timer.Create( "AM_LightTimer", 0.05, 0, function()
			am_nightvision.Pos = ply:GetPos()
		end)
	end)

	net.Receive( "AM_NightvisionOff", function ( len, ply )
		local ply = net.ReadEntity()
		timer.Destroy( "AM_LightTimer" )
		if am_nightvision then
			am_nightvision.DieTime = CurTime()+0.1
		end
	end)

end

local function ReduceFallDamage( target, dmginfo )
	if target:IsPlayer() and target.ShouldReduceFallDamage and dmginfo:IsFallDamage() then
		dmginfo:SetDamage( 0 )
	end
end

hook.Add("EntityTakeDamage", "ReduceFallDamage", ReduceFallDamage)
