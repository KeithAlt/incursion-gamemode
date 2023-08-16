AddCSLuaFile()



SWEP.PrintName = "Tranquilizer M9"



SWEP.Spawnable = true

SWEP.AdminOnly = false



SWEP.ViewModel = "models/weapons/c_m9.mdl"

SWEP.WorldModel = "models/weapons/w_m9.mdl"

SWEP.UseHands = true

SWEP.ViewModelFOV = 50



SWEP.Slot = 1

SWEP.SlotPos = 3



SWEP.DrawWeaponInfoBox = false



SWEP.Primary.ClipSize = 5

SWEP.Primary.DefaultClip= 5

SWEP.Primary.Automatic = false

SWEP.Primary.Ammo = "357"



SWEP.Secondary.ClipSize	= -1

SWEP.Secondary.DefaultClip = -1

SWEP.Secondary.Automatic = false

SWEP.Secondary.Ammo	= "none"


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
				time = 0
			elseif ( hitgroup == HITGROUP_CHEST ) then
				time = 2
			elseif ( hitgroup == HITGROUP_STOMACH ) then
				time = 4
			else
				time = 5
			end

			if ( victim.m9TranqTime ) then
				victim.m9TranqTime = victim.m9TranqTime - ( time / 16 ) * 15

				if SERVER then
					victim:falloutNotify("[ ! ]  You feel something sharp prick you", "weapons/fx/nearmiss/bulletLtoR0" .. math.random(7,14) .. ".wav")
				end
			else
				if time <= 0 then
					if SERVER then
						victim:Knockout(self:GetOwner())
						victim:falloutNotify("[ ! ]  You feel something sharp prick you and instantly collapse!", "weapons/fx/nearmiss/bulletLtoR0" .. math.random(7,14) .. ".wav")
						self:GetOwner():falloutNotify("© HEADSHOT " , "ui/ui_items_bottlecaps_up_03.wav")
					end
				else
					if SERVER then
						victim:falloutNotify("[ ! ]  You feel something sharp prick you", "weapons/fx/nearmiss/bulletLtoR0" .. math.random(7,14) .. ".wav")
					end
					victim.m9TranqTime = time
				end
			end
		end
	end

	self:GetOwner():FireBullets( bullet )
	self:ShootEffects()
end

function SWEP:PrimaryAttack()
	local victim = self:GetOwner():GetEyeTrace().Entity
	if self:GetNextPrimaryFire() > CurTime() then return end

	self:SetNextPrimaryFire( CurTime() + 1.5 )
	self:ShootBullet( 0.1, 1, 0 )
	self:EmitSound( "weapons/usp/usp1.wav" )
	self:TakePrimaryAmmo( 1 )

	if SERVER and IsValid(victim) and victim:IsPlayer() then
		if victim:WearingPA() and SERVER then
			self:GetOwner():falloutNotify("[ ! ] You cannot tranquilize Power Armor!", "ui/notify.mp3") 
			return 
		end

		timer.Remove(victim:SteamID() .. "M9TRANQTIMER")

		if victim.m9TranqTime and victim.m9TranqTime <= 0 then
			victim:Knockout(self:GetOwner())
			victim.m9TranqTime = nil
			return
		end
		
		timer.Create(victim:SteamID() .. "M9TRANQTIMER", victim.m9TranqTime or 35, 1, function()
			if IsValid(victim) then
				victim:Knockout(self:GetOwner())
				victim.m9TranqTime = nil
			end
		end)
	end
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

hook.Add("PlayerDeath", "RESETM9TRANQTIMER", function(ply)
	if ply.m9TranqTime then ply.m9TranqTime = nil end
end)