AddCSLuaFile()

SWEP.PrintName = "Tranquilizer Rifle"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.ViewModel = "models/weapons/v_winchester1873.mdl"
SWEP.WorldModel = "models/weapons/w_winchester_1873.mdl"
SWEP.UseHands = true
SWEP.ViewModelFOV = 50
SWEP.ViewModelFlip			= true

SWEP.Slot = 1
SWEP.SlotPos = 3
SWEP.HoldType 				= "crossbow"

SWEP.DrawWeaponInfoBox = false

SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip= 5
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo	 = "357"
SWEP.Primary.Damage		= 1

SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"

CreateConVar( "dart_tranqtime", 30, FCVAR_ARCHIVE )

function SWEP:ShootBullet( damage, num, aimcone )
	local bullet = {}

	bullet.Num 	= num
	bullet.Src 	= self:GetOwner():GetShootPos()
	bullet.Dir 	= self:GetOwner():GetAimVector()
	bullet.Spread 	= Vector( aimcone, aimcone, 0 )
	bullet.Tracer	= 5
	bullet.Force	= 1
	bullet.Damage	= damage
	bullet.AmmoType = "Pistol"

	function bullet.Callback( pl, tr, dmg )
		local victim = tr.Entity
		local hitgroup = tr.HitGroup

		if ( IsValid( victim ) and victim:IsPlayer()) then
			if victim:WearingPA() and SERVER then
				self:GetOwner():falloutNotify("[ ! ] You cannot tranquilize Power Armor!", "ui/notify.mp3") 
				return 
			end

			local time
			if ( hitgroup == HITGROUP_HEAD ) then
				time = 8
			elseif ( hitgroup == HITGROUP_CHEST ) then
				time = 16
			elseif ( hitgroup == HITGROUP_STOMACH ) then
				time = 25
			else
				time = 35
			end

			if ( victim.RifleTranqTime ) then
				victim.RifleTranqTime = victim.RifleTranqTime - ( time / 16 ) * 15
			else
				victim.RifleTranqTime = time
			end

			if SERVER then
				timer.Remove(victim:EntIndex() .. "TRANQTIMER")
				local deaths = victim:Deaths()
		
				if victim.RifleTranqTime <= 0 then
					victim:Knockout(self:GetOwner())
					victim.RifleTranqTime = nil
					return
				end
		
				timer.Create(victim:EntIndex() .. "TRANQTIMER", victim.RifleTranqTime or 35, 1, function()
					if IsValid(victim) and deaths == victim:Deaths() then
						victim:Knockout(self:GetOwner())
					end
					victim.RifleTranqTime = nil
				end)
				victim:falloutNotify("[ ! ]  You feel something sharp prick you", "weapons/fx/nearmiss/bulletLtoR0" .. math.random(7,14) .. ".wav")
			end
		end
	end

	self:GetOwner():FireBullets( bullet )
	self:ShootEffects()
end

function SWEP:PrimaryAttack()
	if self:GetNextPrimaryFire() > CurTime() then return end

	self:SetNextPrimaryFire( CurTime() + 1.5 )
	self:ShootBullet( 0.1, 1, 0 )
	self:EmitSound( "weapons/usp/usp1.wav" )
	self:TakePrimaryAmmo( 1 )
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
	if ( self:DefaultReload( ACT_VM_RELOAD ) ) then
		self:EmitSound( "weapons/pistol/pistol_reload1.wav" )

		timer.Simple(0.5, function()
			vm = self:GetOwner():GetViewModel()
			vm:ResetSequence(vm:LookupSequence(ACT_VM_IDLE)) -- Fuck you, garry, why the hell can't I reset a sequence in multiplayer?
			vm:SetPlaybackRate(.01) --
		end)
	end
end