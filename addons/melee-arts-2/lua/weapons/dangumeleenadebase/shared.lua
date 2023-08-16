--creds to HoobSug

include( "autorun/meleewoundautorun.lua" )

SWEP.Base = "weapon_base"

SWEP.AdminSpawnable = true

SWEP.AutoSwitchTo = false
SWEP.Slot = 0
SWEP.PrintName = "Melee Arts 2 Base"
SWEP.Author = "danguyen"
SWEP.Spawnable = false
SWEP.AutoSwitchFrom = false
SWEP.Weight = 5
SWEP.DrawCrosshair = false

SWEP.Category = "Melee Arts II"
SWEP.SlotPos = 1
SWEP.QuadAmmoCounter = false
SWEP.AmmoQuadColor = Color(84,196,247,255)

SWEP.Purpose = "Sword stuff."
SWEP.Instructions = "LMB - Attack (Hold to charge) | RMB - Block | R - Shove | ALT - Throw (Hold to charge)"
SWEP.ViewModelFOV = 50
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"

SWEP.UseHands = true
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true

--STAT RATING (1-6)
SWEP.Type=3 --1: Blade, 2: Axe, 3:Bludgeon, 4: Spear
SWEP.Strength=3 -- 1-2: Small Weapons, 3-4: Medium Weapons (e.g crowbar), 5-6: Heavy Weapons (e.g Sledgehammers and Greatswords). Strength affects throwing distance and force
SWEP.Speed=4 -- 1-2: Slow, 3-4: Decent, 5-6: Fast
SWEP.Tier=3 -- General rating based on how good/doodoo the weapon is
SWEP.JokeWep=false

--SWEPs are dumb (or I am) so we must state the weapon name again
SWEP.WepName="dangumeleebase"

--Stamina Costs
SWEP.PriAtkStamina=5
SWEP.ThrowStamina=5
SWEP.BlockStamina=5
SWEP.ShoveStamina=5

--Shield Only
SWEP.ShieldHealth=100

--Primary Attack Charge Values
SWEP.chargeBar = ""
SWEP.Charge = 0
SWEP.ChargeSpeed = 0.5
SWEP.DmgMin = 8
SWEP.DmgMax = 30
SWEP.Delay = 0.5
SWEP.TimeToHit = 0.05
SWEP.AttackAnimRate = 0.8
SWEP.Range = 50
SWEP.Punch1 = Angle(-2, 0, 0)
SWEP.Punch2 = Angle(-2, 0, 0)
SWEP.HitFX = "bloodsplat"
SWEP.HitFX2 = "BloodImpact"
SWEP.IdleAfter = true
--Throwing Attack Charge Values
SWEP.CanThrow = false
SWEP.Charge2 = 0
SWEP.ChargeSpeed2 = 0.3
SWEP.DmgMin2 = 5
SWEP.DmgMax2 = 20
SWEP.ThrowModel = "models/weapons/w_crowbar.mdl"
SWEP.ThrowMaterial = ""
SWEP.ThrowScale = 1
SWEP.ThrowForce = 1500
SWEP.FixedThrowAng = Angle(0,0,0)
SWEP.SpinAng = Vector(0,1500,0)

--HOLDTYPES
SWEP.AttackHoldType="melee"
SWEP.Attack2HoldType="knife"
SWEP.ChargeHoldType="melee"
SWEP.IdleHoldType="melee2"
SWEP.BlockHoldType="slam"
SWEP.ShoveHoldType="fist"
SWEP.ThrowHoldType="grenade"

--SOUNDS
SWEP.SwingSound="WeaponFrag.Throw"
SWEP.ThrowSound="weapons/iceaxe/iceaxe_swing1.wav"
SWEP.Hit1Sound="ambient/machines/slicer3.wav"
SWEP.Hit2Sound="ambient/machines/slicer3.wav"
SWEP.Hit3Sound="ambient/machines/slicer2.wav"

SWEP.Impact1Sound="weapons/crowbar/crowbar_impact1.wav"
SWEP.Impact2Sound="weapons/crowbar/crowbar_impact2.wav"

SWEP.ViewModelBoneMods = {

}


SWEP.NextFireShove = 0
SWEP.NextFireBlock = 0
SWEP.NextStun = 0

SWEP.DefSwayScale 	= 1.0
SWEP.DefBobScale 	= 1.0

SWEP.StunPos = Vector(-3.921, 0, 3.72)
SWEP.StunAng = Vector(-18.292, -0.704, -31.659)

SWEP.ShovePos = Vector(-8.36, -17.688, -1.92)
SWEP.ShoveAng = Vector(0, 90, -70)

SWEP.RollPos = Vector(0,0,0)
SWEP.RollAng = Vector(0, 0, 0)

SWEP.WhipPos = Vector(-0.19, -28, -1.92)
SWEP.WhipAng = Vector(61.206, 14.069, 7.034)

SWEP.ThrowPos = Vector(-0.19, -28, -1.92)
SWEP.ThrowAng = Vector(61.206, 14.069, 7.034)

SWEP.FanPos = Vector(-20, -8.443, 8.239)
SWEP.FanAng = Vector(16.884, 0, -70)

SWEP.WallPos = Vector(-0.601, -11.056, -9.65)
SWEP.WallAng = Vector(0, 0, 0)

SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = SWEP.ShieldHealth
SWEP.Primary.DefaultClip = SWEP.ShieldHealth
SWEP.Primary.Spread = 0
SWEP.Primary.NumberofShots = 0

SWEP.CanDecapitate = false
SWEP.CanKnockout = false

local rndr = render
local mth = math
local srface = surface
local inpat = input

function SWEP:Deploy()
	local ply=self.Owner
	self:OnDeploy()
	if self.Type==5 then
		self.Owner:SetNWBool("MeleeArtShieldening",true)
	end
	self:SendWeaponAnim( ACT_VM_DRAW )
	self:SetNextPrimaryFire( CurTime() + self:SequenceDuration() )
	self:SetHoldType( self.IdleHoldType )
	self.Primary.Cone = self.DefaultCone
	self.Weapon:SetNWInt("Reloading", CurTime() + self:SequenceDuration() )
	self.Weapon:SetNWString( "AniamtionName", "none" )
	self.WalkSpeed=ply:GetWalkSpeed()
	self.RunSpeed=ply:GetRunSpeed()
	self.JumpPower=ply:GetJumpPower()
	return true
end

function SWEP:OnDeploy()
	self.WalkSpeed=ply:GetWalkSpeed()
	self.RunSpeed=ply:GetRunSpeed()
	self.JumpPower=ply:GetJumpPower()
end

function SWEP:AttackAnimation()
self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
end
function SWEP:AttackAnimation2()
self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
end
function SWEP:AttackAnimationCOMBO()
self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
end
function SWEP:AttackAnimation3()
self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
end


local nxtbreathdown = 0

function SWEP:Think()
	local ply=self.Owner
	local wep=self.Weapon
	self:SecondThink()
	if !SERVER then return end

	if CurTime() < self.NextStun then
		self.Owner:SetNWBool("MeleeArtStunned",true)
	else
		self.Owner:SetNWBool("MeleeArtStunned",false)
	end

	if self.Owner:GetNWBool("MeleeArtStunned")==true then
		if SERVER then
			self:SetHoldType("normal")
		end
		self.Owner:SetRunSpeed(self.WalkSpeed/7)
		self.Owner:SetWalkSpeed(self.WalkSpeed/7)
		self.Owner:SetJumpPower(self.JumpPower/self.JumpPower)
		self.Owner:SetNWBool("MeleeArtAttacking2",false)
		self.Owner:SetNWBool("MeleeArtAttacking",false)
	elseif self.Owner:GetNWBool("MeleeArtShieldening")==true then
		self.Owner:SetRunSpeed(self.RunSpeed/2)
		self.Owner:SetWalkSpeed(self.WalkSpeed/2)
		self.Owner:SetJumpPower(self.JumpPower/2)
	else
		if SERVER then
			if self.Owner:GetNWBool("MeleeArtAttacking2")==false then
				self:SetHoldType(self.IdleHoldType)
			end
		end
	end

	if self.Owner:KeyDown(IN_ATTACK2) then --Blocking
		if CurTime() < self.NextFireBlock+0.35 or self.Owner:GetNWBool("MeleeArtStunned")==true then return end
		if self.Type==5 then
			self.Charge=0
			self.Charge2=0
			self.Owner:SetNWBool("MeleeArtAttacking",false)
			self.Owner:SetNWBool("MeleeArtThrowing",false)
			ply:SetNWString("chargebar","")
			ply:SetNWBool("chargemaxxxed",false)
		return end
		self.Charge=0
		self.Charge2=0
		self.Owner:SetNWBool("MeleeArtAttacking",false)
		self.Owner:SetNWBool("MeleeArtThrowing",false)
		ply:SetNWString("chargebar","")
		ply:SetNWBool("chargemaxxxed",false)
		self.Owner:SetNWBool("MAGuardening",true)
		self.Owner:SetRunSpeed(self.WalkSpeed)
		self.Owner:SetJumpPower(self.JumpPower/2)
		if SERVER then
			self:SetHoldType(self.BlockHoldType)
		end
		self.Weapon:SetNextPrimaryFire( CurTime() + 0.2 )
		self.Weapon:SetNextSecondaryFire( CurTime() + 0.2 )
		self.NextFireShove = CurTime() + 0.2
	return true

	elseif self.Owner:KeyReleased(IN_ATTACK2) then
		self.Owner:SetNWBool("MAGuardening",false)
		self.Owner:SetRunSpeed(self.RunSpeed)
		self.Owner:SetJumpPower(self.JumpPower)
		parryframe=true
		if SERVER then
			self:SetHoldType(self.IdleHoldType)
		end
	--Blocking Fin
	elseif self.Owner:KeyDown(IN_ATTACK) and !self.Owner:IsNPC() then --Primary Attack
		--if self.Owner:GetNWInt( 'MeleeArts2Stamina' )<=self.PriAtkStamina then return end
		if self.Owner:GetNWBool("MeleeArtStunned")==true or self.Owner:GetNWBool("MeleeArtThrowing")==true then return end
		self.Charge2=0
		self.Owner:SetNWBool("MeleeArtAttacking",false)
		if self.Weapon:GetNextPrimaryFire() < CurTime() then
			self.Owner:SetNWBool("MeleeArtAttacking",true)
			if self.Type==7 then
				self.Charge = math.Clamp(self.Charge + self.ChargeSpeed*(1+((self.Weapon:GetNWInt("QSChain")/8)*self.Speed)), self.DmgMin, self.DmgMax)
			else
				self.Charge = math.Clamp(self.Charge + self.ChargeSpeed, self.DmgMin, self.DmgMax)
			end
			if GetConVarNumber( "ma2_togglechargeui" ) == 1 then
				if (self.Charge-self.DmgMin)/self.DmgMax*100<=10 then
					ply:SetNWString("chargebar","██")
				elseif (self.Charge-self.DmgMin)/(self.DmgMax-self.DmgMin)*100<=20 then
					ply:SetNWString("chargebar","████")
				elseif (self.Charge-self.DmgMin)/(self.DmgMax-self.DmgMin)*100<=30 then
					ply:SetNWString("chargebar","██████")
				elseif (self.Charge-self.DmgMin)/(self.DmgMax-self.DmgMin)*100<=40 then
					ply:SetNWString("chargebar","████████")
				elseif (self.Charge-self.DmgMin)/(self.DmgMax-self.DmgMin)*100<=50 then
					ply:SetNWString("chargebar","██████████")
				elseif (self.Charge-self.DmgMin)/(self.DmgMax-self.DmgMin)*100<=60 then
					ply:SetNWString("chargebar","████████████")
				elseif (self.Charge-self.DmgMin)/(self.DmgMax-self.DmgMin)*100<=70 then
					ply:SetNWString("chargebar","██████████████")
				elseif (self.Charge-self.DmgMin)/(self.DmgMax-self.DmgMin)*100<=80 then
					ply:SetNWString("chargebar","████████████████")
				elseif (self.Charge-self.DmgMin)/(self.DmgMax-self.DmgMin)*100<=90 then
					ply:SetNWString("chargebar","██████████████████")
				elseif (self.Charge-self.DmgMin)/(self.DmgMax-self.DmgMin)*100>90 then
					ply:SetNWString("chargebar","████████████████████")
					ply:SetNWBool("chargemaxxxed",true)
				end
			end
			self.Owner:SetJumpPower(0)
			if SERVER then
				self:SetHoldType(self.ChargeHoldType)
			end
			self.Weapon:SetNextSecondaryFire( CurTime() + self.Delay )
		end
	return true

	elseif self.Owner:KeyReleased(IN_ATTACK) and self.Charge>0 then
		if self.Charge>self.DmgMax/1.3 then
			self:AttackAnimation()
			if SERVER then
				self:SetHoldType(self.AttackHoldType)
			end
			ply:ViewPunch( ( self.Punch2 ) )

		else
			if self.Type!=7 then
			self:AttackAnimation2()
			else
				if self.Weapon:GetNWInt("QSChain")>1 then
					self:AttackAnimationCOMBO()
				else
					self:AttackAnimation2()
				end
			end
			if SERVER then
				self:SetHoldType(self.Attack2HoldType)
			end
			ply:ViewPunch( ( self.Punch1 ) )
		end

		if SERVER then
			self.Owner:GetViewModel():SetPlaybackRate(self.AttackAnimRate)
		end
		self.Owner:SetNWBool("MeleeArtAttacking2",true)
		self.Owner:SetNWBool("MeleeArtAttacking",false)
		self.Owner:SetRunSpeed(self.RunSpeed)
		self.Owner:SetJumpPower(self.JumpPower)
		--self.Owner:PrintMessage(HUD_PRINTCENTER,"")
		--self.Owner:SetNWInt( 'MeleeArts2Stamina', math.floor(self.Owner:GetNWInt( 'MeleeArts2Stamina' )-(self.PriAtkStamina+(self.Charge/4))) )
		self.NextFireBlock = CurTime() + self.Delay/2
		self.NextFireShove = CurTime() + self.Delay
		timer.Simple(0.01, function()
			if ply:Alive() and IsValid(ply) then
				self:AtkAnim()
			end
		end)
		if ply:Alive() and IsValid(ply) then
			ply:SetNWString("chargebar","")
			ply:SetNWBool("chargemaxxxed",false)
			self:Atk()
			self.Charge=0
		end
	--Primary Attack Fin

	elseif self.Owner:KeyDown(IN_BULLRUSH) then --Throwing
		--if self.Owner:GetNWInt( 'MeleeArts2Stamina' )<=self.ThrowStamina then return end
		if !self.CanThrow or GetConVarNumber( "ma2_togglethrowing" ) == 0 then return end
		if self.Owner:GetNWBool("MeleeArtStunned")==true then return end
		if self.Weapon:GetNextSecondaryFire() < CurTime() then
			self.Owner:SetNWBool("MeleeArtThrowing",true)
			self.Charge2 = math.Clamp(self.Charge2 + self.ChargeSpeed2, self.DmgMin2, self.DmgMax2)
			self:NextThink(CurTime() + 1)
			if GetConVarNumber( "ma2_togglechargeui" ) == 1 then
				if (self.Charge2-self.DmgMin2)/self.DmgMax*100<=10 then
					ply:SetNWString("chargebar","██")
				elseif (self.Charge2-self.DmgMin2)/(self.DmgMax2-self.DmgMin2)*100<=20 then
					ply:SetNWString("chargebar","████")
				elseif (self.Charge2-self.DmgMin2)/(self.DmgMax2-self.DmgMin2)*100<=30 then
					ply:SetNWString("chargebar","██████")
				elseif (self.Charge2-self.DmgMin2)/(self.DmgMax2-self.DmgMin2)*100<=40 then
					ply:SetNWString("chargebar","████████")
				elseif (self.Charge2-self.DmgMin2)/(self.DmgMax2-self.DmgMin2)*100<=50 then
					ply:SetNWString("chargebar","██████████")
				elseif (self.Charge2-self.DmgMin2)/(self.DmgMax2-self.DmgMin2)*100<=60 then
					ply:SetNWString("chargebar","████████████")
				elseif (self.Charge2-self.DmgMin2)/(self.DmgMax2-self.DmgMin2)*100<=70 then
					ply:SetNWString("chargebar","██████████████")
				elseif (self.Charge2-self.DmgMin2)/(self.DmgMax2-self.DmgMin2)*100<=80 then
					ply:SetNWString("chargebar","████████████████")
				elseif (self.Charge2-self.DmgMin2)/(self.DmgMax2-self.DmgMin2)*100<=90 then
					ply:SetNWString("chargebar","██████████████████")
				elseif (self.Charge2-self.DmgMin2)/(self.DmgMax2-self.DmgMin2)*100>90 then
					ply:SetNWString("chargebar","████████████████████")
					ply:SetNWBool("chargemaxxxed",true)
				end
			end
			--self.Owner:SetRunSpeed(200)
			if SERVER then
				self:SetHoldType(self.ThrowHoldType)
			end
		end
		self.Weapon:SetNextPrimaryFire( CurTime() + self.Delay/4 )
	return true

	elseif self.Owner:KeyReleased(IN_BULLRUSH) and self.Charge2>0 then
		if self.Owner:GetNWBool("MeleeArtStunned")==true then return end
		self:AttackAnimation3()
		self.Owner:SetNWBool("MeleeArtThrowing",false)
		--self.Owner:SetRunSpeed(400)
		ply:SetNWString("chargebar","")
		ply:SetNWBool("chargemaxxxed",false)
		if SERVER then
			ply:EmitSound(self.ThrowSound)
		end
		--self.Owner:SetNWInt( 'MeleeArts2Stamina', math.floor(self.Owner:GetNWInt( 'MeleeArts2Stamina' )-(self.ThrowStamina+self.Charge2/2)) )
		self.NextFireBlock = CurTime() + self.Delay
		self.NextFireShove = CurTime() + self.Delay
			local pos = self.Owner:GetShootPos()
			local ang = self.Owner:GetAimVector():Angle()
			pos = pos +ang:Forward()

			--some weird technique
			local ent = ents.Create("meleeartsthrowable")
			ent:SetModel(self.ThrowModel)
			if self.ThrowMaterial!="" then
				ent:SetMaterial(self.ThrowMaterial)
			end
			ent:SetModelScale(self.ThrowScale)
			ent:SetAngles(self.Owner:GetAimVector():Angle())
			ent:SetOwner(self.Weapon:GetOwner())
			ent:SetNWInt( 'throwdamage', self.Charge2 )
			ent:SetNWInt( 'weaponname', self.WepName )
			ent:SetNWInt( 'impact1sound', self.Impact1Sound )
			ent:SetNWInt( 'impact2sound', self.Impact2Sound )
			ent:SetNWInt( 'hit1Sound', self.Hit1Sound )
			ent:SetNWInt( 'hit2Sound', self.Hit2Sound )
			ent:SetNWInt( 'hit3Sound', self.Hit3Sound )
			ent:SetNWAngle( 'anglefix', self.FixedThrowAng )
			ent:SetNWAngle( 'spinvector', self.SpinAng )
			ent:SetPos(pos)
			ent:Spawn()
			ent:Activate()
			local f = self.Owner:EyeAngles()
			local ph = ent:GetPhysicsObject()
			if IsValid(ph) then
				ph:SetVelocity(self.Owner:GetAimVector()*self.ThrowForce)
			end
			self.Charge2=0
			if IsValid(self.Owner) then
				if SERVER then
					if self.Owner:HasWeapon( "meleearts_bludgeon_fists" ) then
						self.Owner:SelectWeapon( "meleearts_bludgeon_fists" )
					end
				end
				self.Owner:StripWeapon(self.WepName)
			end
	end--Throwing Fin
end

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {}
	if self.Type==5 then
		self.AmmoDisplay.Draw = self.DrawAmmo
	else
		self.AmmoDisplay.Draw = false
	end
	self.AmmoDisplay.PrimaryClip = self:Clip1()

	return self.AmmoDisplay
end

function SWEP:SecondThink()

end

function SWEP:PrimaryAttack()
end

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
--Backstab
function SWEP:BackstabPeople(ent)
	local angle = self.Owner:GetAngles().y -ent:GetAngles().y
	if angle < -180 then angle = 360 +angle end
	if angle <= 60 and angle >= -60 then return true end
	return false
end

--Front
function SWEP:FrontstabPeople(ent)
	local angle = self.Owner:GetAngles().y -ent:GetAngles().y
	if angle < 180 then angle = 180 +angle end
	if angle <= 60 and angle >= -60 then return true end
	return false
end

function SWEP:AtkExtra()
	if self.CanKnockout == true && tr.Entity:Alive() then
	local ply = self.Owner
	local tr = util.TraceLine( { --shamelessly copied from the fist weapon (i edited it tho so that's a dub)
        start = self.Owner:GetShootPos(),
        endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.Range,
        filter = self.Owner,
        mask = MASK_SHOT_HULL
    } )
    local hit = false
    local pos = ply:GetEyeTrace()
    if ( SERVER && IsValid( tr.Entity ) && ( tr.Entity:IsNPC() || tr.Entity:IsPlayer()) ) then
        if tr.HitGroup == HITGROUP_HEAD && self.Owner:hasSkerk("knockout") == 1 or 2 && self.Owner:IsBehind(tr.Entity) then
			local hasPA = false
			local armor = tr.Entity:getChar():getVar("armor", nil) -- Armor Check
			if armor and nut.armor.armors[armor]["powerArmor"] then
				hasPA = true
			end
			ply:ChatPrint("Oh!")
			if self.Owner:hasSkerk("knockout") == 1 or 2 && !hasPA then
			target = tr.Entity
			ply:ChatPrint(">> Victim knocked!")
			tr.Entity:Knockout(self.Owner)
			target:ChatPrint(">> You have been Knocked!")
			target:ChatPrint("(WARNING: Informing others via Discord/Voice Chat will result in a ban! [Meta-game])")
		elseif self.Owner:hasSkerk("knockout") == 1 && hasPA then
			ply:ChatPrint(">> You lack the skill to knockout a victim with Power Armor!")
		elseif self.Owner:hasSkerk("knockout") == 2 && hasPA then
            ply:ChatPrint(">> Victim knocked!")
			tr.Entity:Knockout(self.Owner)
			target:ChatPrint(">> You have been Knocked!")
			target:ChatPrint("(WARNING: Informing others via Discord/Voice Chat will result in a ban! [Meta-game])")
			end
        end
        hit = true
		end
	end
end

function SWEP:AtkAnim()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end

function SWEP:Atk()
	local ply = self.Owner
	local wep = self.Weapon
	if IsFirstTimePredicted() then
	if SERVER then
		ply:EmitSound(self.SwingSound)
		if !ply:IsNPC() then
			ply:LagCompensation(true)
		end
	end
	local tr = util.TraceLine( { --shamelessly copied from the fist weapon (i edited it tho so that's a dub)
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.Range,
		filter = self.Owner,
		mask = MASK_SHOT_HULL
	} )
	if ( !IsValid( tr.Entity ) ) then
		tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.Range,
			filter = self.Owner,
			mins = Vector( -1,-1,0 ),
			maxs = Vector( 1,1,0 ),
			mask = MASK_SHOT_HULL
		} )
	end
	local hit = false
	local pos = ply:GetEyeTrace()
	if ( SERVER && IsValid( tr.Entity ) && ( tr.Entity:IsNPC() || tr.Entity:IsPlayer()) ) then

		local dmginfo = DamageInfo()

		local attacker = self.Owner
		if ( !IsValid( attacker ) ) then attacker = self end
		dmginfo:SetAttacker( attacker )

		dmginfo:SetInflictor( self )
		dmginfo:SetDamage( math.floor(self.Charge) )
		dmginfo:SetDamageForce( self.Owner:GetForward() * 5000 )
		if self.Type==1 or self.Type==2  then
			dmginfo:SetDamageType( 4 )
		elseif self.Type==3 then
			dmginfo:SetDamageType( 128 )
		elseif self.Type==4 then
			dmginfo:SetDamageType( 1 )
		elseif self.Type==7 then
			dmginfo:SetDamageType( 128 )
		elseif self.Type==5 then
			dmginfo:SetDamageType( 128 )
		elseif self.Type==666 then
			dmginfo:SetDamageType( 67108864 )
		end
		if ( self:BackstabPeople( tr.Entity ) and tr.Entity:GetPos():Distance( self.Owner:GetPos() ) < self.Range+20 ) then
			dmginfo:SetDamage( math.floor(self.Charge*1.7) )
			tr.Entity:TakeDamageInfo( dmginfo )
			if tr.Entity:GetBloodColor()~=-1 then
				tr.Entity:EmitSound("physics/flesh/flesh_bloody_break.wav")
			end
			tr.Entity:EmitSound("physics/flesh/flesh_strider_impact_bullet3.wav")
		else
			tr.Entity:TakeDamageInfo( dmginfo )
		end
		self:AtkExtra()
		if tr.Entity:GetNWBool("MAGuardening")==true or tr.Entity:GetNWBool("MeleeArtShieldening")==true then
			if SERVER then
				if self.Type!=4 then
					local w = math.random(1)
					w = math.random(1,2)
					if w == 1 then
						ply:EmitSound(self.Impact1Sound)
					elseif w == 2 then
						ply:EmitSound(self.Impact2Sound)
					end
				end
			end
			if self.Type==4 then
				if self.Strength==1 then
					self.NextStun = CurTime() + 1.25
				elseif self.Strength==2 then
					self.NextStun = CurTime() + 1
				elseif self.Strength==3 then
					self.NextStun = CurTime() + 0.9
				elseif self.Strength==4 then
					self.NextStun = CurTime() + 0.8
				elseif self.Strength==5 then
					self.NextStun = CurTime() + 0.6
				elseif self.Strength==6 then
					self.NextStun = CurTime() + 0.4
				end
				ply:ViewPunch( Angle( -10, 0, 0 ) )
				local effectdata = EffectData()
				effectdata:SetOrigin( pos.HitPos )
				effectdata:SetNormal( tr.Entity:GetPos():GetNormal() )
				effectdata:SetEntity( tr.Entity )
				util.Effect( "spearpierce", effectdata, true, true )
				ply:DoCustomAnimEvent( PLAYERANIMEVENT_CUSTOM_SEQUENCE , 1 )
			else
				self.NextStun = CurTime() + 1.5
				ply:EmitSound("physics/flesh/flesh_strider_impact_bullet2.wav")
				ply:ViewPunch( Angle( -20, 0, 0 ) )
				ply:DoCustomAnimEvent( PLAYERANIMEVENT_CUSTOM_SEQUENCE , 1 )
				local effectdata = EffectData()
				effectdata:SetOrigin( pos.HitPos )
				effectdata:SetNormal( tr.Entity:GetPos():GetNormal() )
				effectdata:SetEntity( tr.Entity )
				util.Effect( "stundeflection", effectdata, true, true )
			end
		else
		--Apply debuffs
			if self.Type==1 then
				local bleedDmg=(0.5*(self.Strength/3))
				MAWoundage:AddStatus(tr.Entity, self.Owner, "bleed", 6,bleedDmg)
				--print("uhh sword")
			elseif self.Type==2 then
				MAWoundage:AddStatus(tr.Entity, self.Owner, "expose", self.Strength)
				--print("uhh axe")
			elseif self.Type==3 then
				chance = math.ceil(10*((self.DmgMax/self.Charge)/(tr.Entity:GetMaxHealth()/tr.Entity:Health()))*3/self.Strength)
				MAWoundage:AddStatus(tr.Entity, self.Owner, "cripple", chance)
				--print("uhh bludgeon")
			elseif self.Type==4 then
				--print("uhh spear")
			elseif self.Type==7 then
				if self.Weapon:GetNWInt("QSChain")<6 then
					self.Weapon:SetNWInt("QSChain",self.Weapon:GetNWInt("QSChain")+1)
					if self.Weapon:GetNWInt("QSChain")==6 then
						self.Owner:EmitSound("ambient/levels/canals/windchime4.wav",50)
					else
						self.Owner:EmitSound("ambient/levels/canals/windchime2.wav",40)
					end
				end
				if self.Weapon:GetNWInt("QSChain")>2 then
					tr.Entity:EmitSound("physics/body/body_medium_impact_hard6.wav")
					if SERVER then
						local boom =100*self.Strength
						local shiftstraight = ply:GetAngles():Forward()*boom
						shiftstraight.z = 5
						tr.Entity:SetVelocity(shiftstraight)
					end
				end
			end

		end

		if pos.Entity==tr.Entity then
			if tr.Entity:GetBloodColor()~=-1 then
				local effectdata = EffectData()
				local blood = tr.Entity:GetBloodColor()
				effectdata:SetColor(blood)
				effectdata:SetOrigin( pos.HitPos )
				effectdata:SetNormal( tr.Entity:GetPos():GetNormal() )
				effectdata:SetEntity( tr.Entity )
				effectdata:SetAttachment(5)
				if self.HitFX=="bloodsplat" then
					if tr.Entity:GetBloodColor()==0 then
						util.Effect( self.HitFX, effectdata, true, true )
					else
						util.Effect( "bloodsplatyellow", effectdata, true, true )
					end
				else
					util.Effect( self.HitFX, effectdata, true, true )
				end
				util.Effect( self.HitFX2, effectdata, true, true )
			else
				local effectdata = EffectData()
				effectdata:SetOrigin( pos.HitPos )
				effectdata:SetNormal( tr.Entity:GetPos():GetNormal() )
				effectdata:SetEntity( tr.Entity )
				effectdata:SetAttachment(5)
				util.Effect( "MetalSpark", effectdata, true, true)
			end
		else
			if tr.Entity:GetBloodColor()~=-1 then
				local effectdata = EffectData()
				local blood = tr.Entity:GetBloodColor()
				effectdata:SetColor(blood)
				effectdata:SetOrigin( tr.Entity:GetPos()+Vector(0,0,40) )
				effectdata:SetNormal( tr.Entity:GetPos():GetNormal() )
				effectdata:SetEntity( tr.Entity )
				effectdata:SetAttachment(5)
				if self.HitFX=="bloodsplat" then
					if tr.Entity:GetBloodColor()==0 then
						util.Effect( self.HitFX, effectdata, true, true )
					else
						util.Effect( "bloodsplatyellow", effectdata, true, true )
					end
				else
					util.Effect( self.HitFX, effectdata, true, true )
				end
				util.Effect( self.HitFX2, effectdata, true, true )
			else
				local effectdata = EffectData()
				effectdata:SetOrigin( pos.HitPos )
				effectdata:SetNormal( tr.Entity:GetPos():GetNormal() )
				effectdata:SetEntity( tr.Entity )
				effectdata:SetAttachment(5)
				util.Effect( "MetalSpark", effectdata, true, true )
			end
		end

		if SERVER and tr.Entity:GetNWBool("MAGuardening")==false and tr.Entity:GetNWBool("MeleeArtShieldening")==false then
			local w = math.random(1)
			w = math.random(1,3)
			if w == 1 then
				ply:EmitSound(self.Hit1Sound)
			elseif w == 2 then
				ply:EmitSound(self.Hit2Sound)
			elseif w == 3 then
				ply:EmitSound(self.Hit3Sound)
			end
		end

		hit = true

	elseif ( SERVER && IsValid( tr.Entity )) then
		--self:AttackAnimation2()

		local dmginfo = DamageInfo()

			local attacker = self.Owner
			if ( !IsValid( attacker ) ) then attacker = self end
			dmginfo:SetAttacker( attacker )

			dmginfo:SetInflictor( self )
			dmginfo:SetDamage( math.floor(self.Charge) )
			dmginfo:SetDamageForce( self.Owner:GetForward() * self.Strength*1000 )
			tr.Entity:TakeDamageInfo( dmginfo )
			--self.Owner:SetNWInt( 'MeleeArts2Stamina', math.floor(self.Owner:GetNWInt( 'MeleeArts2Stamina' )-((self.PriAtkStamina*5)/self.Strength)) )
			if SERVER then
				local phys = tr.Entity:GetPhysicsObject()
				if IsValid(phys) then
					--print(phys:GetMaterial())
					if phys:GetMaterial()=="metal" or phys:GetMaterial()=="metal_barrel" or phys:GetMaterial()=="metalvehicle" or phys:GetMaterial()=="floating_metal_barrel" or phys:GetMaterial()=="metalpanel" or phys:GetMaterial()=="combine_metal"  then
						local w = math.random(1)
						w = math.random(1,2)
						if w == 1 then
							ply:EmitSound(self.Impact1Sound)
						elseif w == 2 then
							ply:EmitSound(self.Impact2Sound)
						end
						if self.WepName!="meleearts_bludgeon_fists" then
							local effectdata = EffectData()
							effectdata:SetOrigin( pos.HitPos )
							effectdata:SetNormal( tr.Entity:GetPos():GetNormal() )
							effectdata:SetEntity( tr.Entity )
							util.Effect( "stundeflection", effectdata, true, true )
						end
						if tr.Entity:Health()==0 then
							ply:ViewPunch( Angle( -20, 0, 0 ) )
							ply:EmitSound("physics/flesh/flesh_strider_impact_bullet2.wav")
							self.NextStun = CurTime() + 1.5
							ply:DoCustomAnimEvent( PLAYERANIMEVENT_CUSTOM_SEQUENCE , 1 )
						end
					elseif phys:GetMaterial()=="wood" or phys:GetMaterial()=="wood_crate" or phys:GetMaterial()=="wood_solid" then
						local w = math.random(1)
						w = math.random(1,2)
						if w == 1 then
							tr.Entity:EmitSound("physics/wood/wood_plank_break1.wav")
							ply:EmitSound(self.Impact1Sound)
						elseif w == 2 then
							tr.Entity:EmitSound("physics/wood/wood_plank_break3.wav")
							ply:EmitSound(self.Impact2Sound)
						end
					elseif phys:GetMaterial()=="flesh" then
						local w = math.random(1)
						w = math.random(1,2)
						if w == 1 then
							tr.Entity:EmitSound(self.Hit1Sound)
						elseif w == 2 then
							tr.Entity:EmitSound(self.Hit2Sound)
						elseif w == 3 then
							tr.Entity:EmitSound(self.Hit2Sound)
						end
						local effectdata = EffectData()
						effectdata:SetOrigin( pos.HitPos )
						effectdata:SetNormal( tr.Entity:GetPos():GetNormal() )
						effectdata:SetEntity( tr.Entity )
						util.Effect( "bloodsplat", effectdata, true, true )
					elseif phys:GetMaterial()=="zombieflesh" or phys:GetMaterial()=="antlion" or phys:GetMaterial()=="alienflesh" then
						local w = math.random(1)
						w = math.random(1,2)
						if w == 1 then
							tr.Entity:EmitSound(self.Hit1Sound)
						elseif w == 2 then
							tr.Entity:EmitSound(self.Hit2Sound)
						elseif w == 3 then
							tr.Entity:EmitSound(self.Hit2Sound)
						end
						local effectdata = EffectData()
						effectdata:SetOrigin( pos.HitPos )
						effectdata:SetNormal( tr.Entity:GetPos():GetNormal() )
						effectdata:SetEntity( tr.Entity )
						util.Effect( "bloodsplatyellow", effectdata, true, true )
					elseif phys:GetMaterial()=="chainlink" then
						local w = math.random(1)
						w = math.random(1,2)
						if w == 1 then
							tr.Entity:EmitSound("physics/metal/metal_chainlink_impact_hard1.wav")
							ply:EmitSound(self.Impact1Sound)
						elseif w == 2 then
							tr.Entity:EmitSound("physics/metal/metal_chainlink_impact_hard2.wav")
							ply:EmitSound(self.Impact2Sound)
						end
					else
						local w = math.random(1)
						w = math.random(1,2)
						if w == 1 then
							ply:EmitSound(self.Impact1Sound)
						elseif w == 2 then
							ply:EmitSound(self.Impact2Sound)
						end
					end
				end

			end
		if self.Type==7 then
			if self.Weapon:GetNWInt("QSChain")>0 then
				self.Weapon:SetNWInt("QSChain",0)
				self.Owner:EmitSound("ambient/levels/canals/windchime2.wav",40,80)
			end
		end
	else
		if self.Type==7 then
			if self.Weapon:GetNWInt("QSChain")>0 then
				self.Weapon:SetNWInt("QSChain",0)
				self.Owner:EmitSound("ambient/levels/canals/windchime2.wav",40,80)
			end
		end
	end

	if ( SERVER && IsValid( tr.Entity ) ) then
		local phys = tr.Entity:GetPhysicsObject()
		if ( IsValid( phys ) and IsValid(self.Owner) ) then
			phys:ApplyForceOffset( self.Owner:GetAimVector() * math.floor(self.Charge)*2 * phys:GetMass(), tr.HitPos )
		end
	end
	if SERVER then
		if !ply:IsNPC() and IsValid(self.Owner) then
			self.Owner:LagCompensation( false )
		end
	end
	if ply:Alive() and IsValid(self.Owner) then
		timer.Simple(.3, function()
			if SERVER and ply:Alive() and IsValid(ply) then
				self.Owner:SetNWBool("MeleeArtAttacking2",false)
				self:SetHoldType(self.IdleHoldType)
			end
		end)
		timer.Simple(self:SequenceDuration(), function()
			if IsValid(wep) and wep.IdleAfter==true then
				if ply:Alive() and ply:GetCycle() < 1 and ply:GetNWBool("MeleeArtAttacking2")==false then
					self:SendWeaponAnim( ACT_VM_IDLE )
				end
			end
		end)
	end
	end
	if self.Type==7 then
		self.Weapon:SetNextPrimaryFire( CurTime() + self.Delay/(1+(self.Weapon:GetNWInt("QSChain")/5)*self.Speed) )
	else
		self.Weapon:SetNextPrimaryFire( CurTime() + self.Delay )
	end
end

SWEP.NextSecondaryAttack = 0

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

end

function SWEP:ShootEffects()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end

function SWEP:NPCShoot_Primary( ShootPos, ShootDir )
end

SWEP.Secondary.Ammo = "none"
SWEP.VElements = {

}
SWEP.WElements = {
}


local nxt = 0
local ftmul = 0
local fmul
local nxtsken = 0

function SWEP:GetFrames()
local ply = self.Owner
local wep = self.Weapon
local ff, lf = wep:GetNWInt( "FirstFrame" ), wep:GetNWInt( "LastFrame" )
	return ff, lf
end

function SWEP:GetFramesDelay()
local ply = self.Owner
local wep = self.Weapon
local fd = wep:GetNWInt( "TFrameDelay" )
	return fd
end

function SWEP:SetFrame( frame )
	local ply = self.Owner
	local wep = self.Weapon
	wep:SetNWInt( "AnimTime", frame )

end


function SWEP:DoBones()
local FT = FrameTime()
local ply = self.Owner
local wep = self.Weapon
local vm = ply:GetViewModel()
local animtime = wep:GetNWInt( "AnimTime" )

if self.ViewModelBoneMods[animtime] and self.ViewModelBoneMods[animtime]["FrameSpeed"] then
ftmul = self.ViewModelBoneMods[animtime]["FrameSpeed"].speed
else
ftmul = 2
end

	for i=0, vm:GetBoneCount() do
		local bonename = vm:GetBoneName(i)

		if (self.ViewModelBoneMods[animtime]) and (self.ViewModelBoneMods[bonename]) then

			if animtime > 0 and (self.ViewModelBoneMods[animtime][bonename]) then
					self.ViewModelBoneMods[bonename].pos = LerpVector( FT*ftmul, self.ViewModelBoneMods[bonename].pos, self.ViewModelBoneMods[animtime][bonename].pos )
					self.ViewModelBoneMods[bonename].scale = LerpVector( FT*ftmul, self.ViewModelBoneMods[bonename].scale, self.ViewModelBoneMods[animtime][bonename].scale )
					self.ViewModelBoneMods[bonename].angle = LerpAngle( FT*ftmul, self.ViewModelBoneMods[bonename].angle, self.ViewModelBoneMods[animtime][bonename].angle )
				elseif !(self.ViewModelBoneMods[bonename]) then
					local newbone = { [bonename] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) } }
					table.Add( self.ViewModelBoneMods[0], newbone )
				elseif !(self.ViewModelBoneMods[animtime][bonename]) then
					self.ViewModelBoneMods[bonename].pos = LerpVector( FT*ftmul, self.ViewModelBoneMods[bonename].pos, self.ViewModelBoneMods[0][bonename].pos )
					self.ViewModelBoneMods[bonename].scale = LerpVector( FT*ftmul, self.ViewModelBoneMods[bonename].scale, self.ViewModelBoneMods[0][bonename].scale )
					self.ViewModelBoneMods[bonename].angle = LerpAngle( FT*ftmul, self.ViewModelBoneMods[bonename].angle, self.ViewModelBoneMods[0][bonename].angle )
				else
					self.ViewModelBoneMods[bonename].pos = LerpVector( FT*ftmul, self.ViewModelBoneMods[bonename].pos, self.ViewModelBoneMods[0][bonename].pos )
					self.ViewModelBoneMods[bonename].scale = LerpVector( FT*ftmul, self.ViewModelBoneMods[bonename].scale, self.ViewModelBoneMods[0][bonename].scale )
					self.ViewModelBoneMods[bonename].angle = LerpAngle( FT*ftmul, self.ViewModelBoneMods[bonename].angle, self.ViewModelBoneMods[0][bonename].angle )
			end
		end
	end
end


SWEP.AngFrames = {
["FOV"] = 0,
["PosAdd"] = Vector(0, 0, 0),
[0] = Angle(0,0,0),
[1] = Angle(5,5,5),
[2] = Angle(0,-15,-5),
[3] = Angle(0,15,-25)
}

SWEP.IdkTestView = false

local ViewMul1 = 0
local nxtfraem = 0
local maxframe = 3
local tstang = Angle(0,0,0)
local lerpfov = 0
local ironfov = 0
local lerpsprint = Angle(0,0,0)
local posadd = Vector(0, 0, 0)
local skensangle = Angle(0, 0, 0)

local lerpshitmudafaka = Angle(0,0,0)

function SWEP:ViewCalc()
end

function SWEP:CalcView( ply, origin, angles, fov )
if !IsFirstTimePredicted() then
	local FT = FrameTime()

	local ply = self.Owner
	local wep = self.Weapon
	local angtime = wep:GetNWInt( "AngFrame" )

	self:ViewCalc()

		--[[if self.Weapon:GetNWBool("Reloading") == true then
			if nxtfraem < CurTime() then
			nxtfraem = CurTime() + 1
				if angtime < maxframe then
					self.Weapon:SetNetworkedInt( "AngFrame", angtime + 1 )
				end
			else
			//self.Weapon:SetNetworkedInt( "AngFrame", 0 )
			end
			ViewMul1 = Lerp(FT*5, ViewMul1, 1)
		else
			self.Weapon:SetNetworkedInt( "AngFrame", 0 )
			ViewMul1 = Lerp(FT*5, ViewMul1, 0)
		end]]

		tstang = LerpAngle( FT*2, tstang, self.AngFrames[angtime])
		lerpfov = Lerp( FT*2, lerpfov, self.AngFrames["FOV"])

		posadd = LerpVector( FT*2, posadd, self.AngFrames["PosAdd"])

		if wep:GetNWBool("AnimExpect") == true then
			skensangle = LerpAngle( FT*2, skensangle, Angle(mth.sin(CurTime()/2) * 2, mth.sin(CurTime()/2) * 5, mth.sin(CurTime()/2) * 5) )
		else
			skensangle = LerpAngle( FT*2, skensangle, Angle(0, 0, 0) )
		end

		lerpshitmudafaka = LerpAngle( FT*7, lerpshitmudafaka, ply:EyeAngles())

		origin = origin + posadd --+ ( ply:EyeAngles():Forward() ) --* ironpos

		if self.IdkTestView == false then
			angles = angles + tstang + lerpsprint + skensangle //angles + self.AngFrames[angtime]//LerpAngle( FT*2, angles, angles + self.AngFrames[angtime])
		else
			angles = lerpshitmudafaka + lerpsprint
		end

		fov = fov + lerpfov - ironfov

		return origin, angles, fov
end

end

/*---------------------------------------------------------
   Name: GetViewModelPosition
   Desc: Allows you to re-position the view model
---------------------------------------------------------*/
	local Mul = 0
	local MulB = 0
	local MulI = 0
	local MulBI = 0
	local breath = 0

	local ModX = 0
	local ModY = 0
	local ModZ = 0

	local ModAngX = 0
	local ModAngY = 0
	local ModAngZ = 0

	local SprintMul = 0

	local nearwallang = 0

	local rollmul = 0

	local shovemul = 0

	local stunmul = 0

	local whipmul = 0

	local fanmul = 0

	local throwmul = 0

	local veloshit = 0

function SWEP:GetViewModelPosition( pos, ang )
local ply = self.Owner
local wep = self.Weapon
	if !IsValid(ply) then return end

--if !IsFirstTimePredicted() then
	local bIron = wep:GetNWBool( "Ironsights" )
	local sprintshit = wep:GetNWBool( "SprintShit" )

	self.SwayScale 	= self.DefSwayScale
	self.BobScale 	= self.DefBobScale

	local FT = 0
	if game.SinglePlayer() then
		FT = FrameTime()
	else
		FT = FrameTime()/2
	end
	local FT2 = FT / 25

			local Offset	=  Vector(0,0,0)

	--local lagspeed = 20 - self.Primary.Cone
	--gunlagang = LerpAngle( FT*lagspeed, gunlagang, self.Owner:EyeAngles())

	wep:SetNWInt("NearWallMul", nearwallang)
	if ply:KeyDown(IN_MOVERIGHT) then
		veloshit = Lerp(FT*6, veloshit, -ply:GetVelocity():Length()/100 )//-5 )
	elseif ply:KeyDown(IN_MOVELEFT) then
		veloshit = Lerp(FT*6, veloshit, ply:GetVelocity():Length()/100 )//5 )
	else
		veloshit = Lerp(FT*6, veloshit, 0 )
	end

		ang = ang * 1

		if wep:GetNWBool("cowboyroll4") then
			rollmul = Lerp(FT*20, rollmul, 1)
		else
			rollmul = Lerp(FT*14, rollmul, 0)
		end

		if self.Owner:GetNWBool("MeleeArtAttacking") then
			whipmul = Lerp(FT*6, whipmul, 1)
		else
			whipmul = Lerp(FT*30, whipmul, 0)
		end

		if self.Owner:GetNWBool("MeleeArtThrowing") then
			throwmul = Lerp(FT*6, throwmul, 1)
		else
			throwmul = Lerp(FT*30, throwmul, 0)
		end

		if self.Owner:GetNWBool("MAGuardening") then
			fanmul = Lerp(FT*15, fanmul, 1)
		else
			fanmul = Lerp(FT*6, fanmul, 0)
		end

		if self.Owner:GetNWBool("MeleeArtShoving") then
			shovemul = Lerp(FT*20, shovemul, 1)
		else
			shovemul = Lerp(FT*6, shovemul, 0)
		end

		if self.Owner:GetNWBool("MeleeArtStunned") then
			stunmul = Lerp(FT*15, stunmul, 1)
		else
			stunmul = Lerp(FT*15, stunmul, 0)
		end

		ang:RotateAroundAxis( ang:Right(), 		( ModAngX * Mul ) + (self.ThrowAng.x * throwmul) + (self.StunAng.x * stunmul) + (self.ShoveAng.x * shovemul) + (self.WallAng.x * nearwallang) + ( self.RollAng.x * rollmul ) + ( self.WhipAng.x * whipmul ) + ( self.FanAng.x * fanmul ) )
		ang:RotateAroundAxis( ang:Up(), 		( ModAngY * Mul ) + (self.ThrowAng.y * throwmul) + (self.StunAng.y * stunmul) + (self.ShoveAng.y * shovemul) + (self.WallAng.y * nearwallang) + ( self.RollAng.y * rollmul ) + ( self.WhipAng.y * whipmul ) + ( self.FanAng.y * fanmul ) )
		ang:RotateAroundAxis( ang:Forward(), 	( ModAngZ * Mul ) + (veloshit) + (self.ThrowAng.z * throwmul) + (self.StunAng.z * stunmul) + (self.ShoveAng.z * shovemul) + (self.WallAng.z * nearwallang) + ( self.RollAng.z * rollmul ) + ( self.WhipAng.z * whipmul ) + ( self.FanAng.z * fanmul ) )

	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()

		--if !wep:GetNWBool( "FuckDaModel" ) then
			ModX = Offset.x * Right * Mul + ( ang:Right() * (self.ThrowPos.x * throwmul) ) + ( ang:Right() * (self.ShovePos.x * shovemul) ) + ( ang:Right() * (self.StunPos.x * stunmul) ) + ( ang:Right() * (self.WallPos.x * nearwallang) + ( ang:Right() * ( self.RollPos.x * rollmul ) ) + ( ang:Right() * ( self.WhipPos.x * whipmul ) ) + ( ang:Right() * ( self.FanPos.x * fanmul ) ) )
			ModY = Offset.y * Forward * Mul + ( ang:Forward() * (self.ThrowPos.y * throwmul) ) + ( ang:Forward() * (self.ShovePos.y * shovemul) ) + ( ang:Forward() * (self.StunPos.y * stunmul) ) + ( ang:Forward()  * (self.WallPos.y * nearwallang) + ( ang:Forward() * ( self.RollPos.y * rollmul ) ) + ( ang:Forward() * ( self.WhipPos.y * whipmul ) ) + ( ang:Forward() * ( self.FanPos.y * fanmul ) ) )
			ModZ = Offset.z * Up * Mul + ( ang:Up() * (self.ThrowPos.z * throwmul) ) + ( ang:Up() * (self.ShovePos.z * shovemul) ) + ( ang:Up() * (self.StunPos.z * stunmul) ) + ( ang:Up()  * (self.WallPos.z * nearwallang) + ( ang:Up() * ( self.RollPos.z * rollmul ) ) + ( ang:Up() * ( self.WhipPos.z * whipmul ) )  + ( ang:Up() * ( self.FanPos.z * fanmul ) ) )
		--else
		/*	ModX = Offset.x * Right
			ModY = Offset.y * Forward + ( ang:Forward() * -5)
			ModZ = Offset.z * Up + ( ang:Up() * -3)*/
		--end

		Mul = Lerp(FT*7, Mul, 0)
		MulB = Lerp(FT*15, MulB, 1)

	if ply:KeyDown(IN_DUCK) then
		MulI = Lerp(FT*2, MulI, 0)
	else
		MulI = Lerp(FT*15, MulI, 1)
	end

	breath = (mth.sin(CurTime())/(2)) * MulB
			pos = pos + ModX
			pos = pos + ModY + (EyeAngles():Up() * (breath) )
			pos = pos + ModZ

			ang = ang

		ang:RotateAroundAxis( ang:Right(), (mth.sin(CurTime()/2)) * MulI )
		ang:RotateAroundAxis( ang:Up(), (mth.sin(CurTime()/2)) * MulI )
		ang:RotateAroundAxis( ang:Forward(), (mth.sin(CurTime()/2)) * MulI )

return pos, ang

--end

end

function SWEP:AdjustMouseSensitivity()

end


function SWEP:Equip()
	self:SetHoldType(self.IdleHoldType)
end

function SWEP:OnRestore()

	self.NextSecondaryAttack = 0

end

function SWEP:ReloadFunc()

end

function SWEP:ReloadFinished()

end

SWEP.ShoveDelay=false

function SWEP:Reload()
	--if self.Owner:GetNWInt( 'MeleeArts2Stamina' )<=self.ShoveStamina then return end
	if CurTime() < self.NextFireShove then return end
	if self.Owner:GetNWBool("MeleeArtStunned")==true or self.Owner:GetNWBool("MeleeArtAttacking")==true or self.Owner:GetNWBool("MeleeArtThrowing")==true or self.Owner:GetNWBool("MAGuardening")==true then return end

	ply=self.Owner
	wep=self.Weapon
	local ply = self.Owner
	local wep = self.Weapon

	if SERVER then
		ply:EmitSound("physics/body/body_medium_impact_soft1.wav")
		self.Owner:LagCompensation( true )
		self.Owner:SetNWBool("MeleeArtShoving", true)
		--self.Owner:SetNWInt( 'MeleeArts2Stamina', math.floor(self.Owner:GetNWInt( 'MeleeArts2Stamina' )-(self.ShoveStamina)) )
		self.Owner:SetNWBool("MAParryFrame",true)
		timer.Simple(0.01, function()
			if IsValid(self.Owner) then
				self.Owner:SetNWBool("MAParryFrame",false)
				timer.Simple(0.25, function()
					if ply:Alive() then
						self.Owner:SetNWBool("MeleeArtShoving", false)
					end
				end)
			end
		end)
	end
	self.Owner:DoCustomAnimEvent( PLAYERANIMEVENT_CUSTOM_SEQUENCE , 2 )
	local tr = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 48,
		filter = self.Owner,
		mask = MASK_SHOT_HULL
	} )

	if ( !IsValid( tr.Entity ) ) then
		tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 48,
			filter = self.Owner,
			mins = Vector( -10, -10, -8 ),
			maxs = Vector( 10, 10, 8 ),
			mask = MASK_SHOT_HULL
		} )
	end

	local hit = false

	if ( SERVER && IsValid( tr.Entity ) && ( tr.Entity:IsNPC() || tr.Entity:IsPlayer()) ) then
		local dmginfo = DamageInfo()

		local attacker = self.Owner
		if ( !IsValid( attacker ) ) then attacker = self end
		dmginfo:SetAttacker( attacker )
		dmginfo:SetDamageType(128)
		dmginfo:SetInflictor( self )
		dmginfo:SetDamage( 2 )
		dmginfo:SetDamageForce( self.Owner:GetForward() * 5000 )

		tr.Entity:TakeDamageInfo( dmginfo )

		if tr.Entity:IsPlayer() then
			if tr.Entity:GetNWBool("MAGuardening")==true then
				local enemywep=tr.Entity:GetActiveWeapon()
				tr.Entity:SetNWBool("MAGuardening",false)
				enemywep.NextStun = CurTime() + 1.5
				tr.Entity:DoCustomAnimEvent( PLAYERANIMEVENT_CUSTOM_SEQUENCE , 1 )
				tr.Entity:ViewPunch( Angle( -20, 0, 0 ) )
				tr.Entity:EmitSound("physics/flesh/flesh_strider_impact_bullet2.wav")
			end
		end

		if tr.Entity:IsNPC() and tr.Entity:GetNWBool("MABoss")==true or tr.Entity:IsNPC() and tr.Entity:GetNWBool("MACombatant")==true then
			if tr.Entity:GetNWBool("MAGuardening")==true then
				--tr.Entity:StopMoving()
				--tr.Entity:ExitScriptedSequence()
				tr.Entity:GetActiveWeapon():Stun2()
			end
		end
		if SERVER then
			ply:EmitSound("physics/body/body_medium_impact_hard6.wav")
		end

		hit = true

	end

	if ( SERVER && IsValid( tr.Entity ) ) then
		local phys = tr.Entity:GetPhysicsObject()
		if ( IsValid( phys ) ) then
			phys:ApplyForceOffset( self.Owner:GetAimVector() * math.floor(self.Charge)*2 * phys:GetMass(), tr.HitPos )
		end
	end

	if SERVER then
		self.Owner:LagCompensation( false )
	end
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Delay )
	self.NextFireShove = CurTime() + 1
	self.NextFireBlock = CurTime() + self.Delay
end

hook.Add( "DoAnimationEvent" , "MA2AnimEventTest" , function( ply , event , data )
	if event == PLAYERANIMEVENT_CUSTOM_SEQUENCE then
		if data == 1 then
			ply:AnimRestartGesture( GESTURE_SLOT_FLINCH, ACT_LAND, true )
			return ACT_INVALID
		end
		if data == 2 then
			ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_MELEE_SHOVE_1HAND, true )
			return ACT_INVALID
		end
	end
end )

function SWEP:CustomHud()//Функция для худа, если нужно оставить базовый код
end

local tstdata = {}

function SWEP:DrawHUDBackground()
end

function SWEP:DrawHUD()
	self:DrawScopeShit()
end


--[[---------------------------------------------------------

-----------------------------------------------------------]]
function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )

	-- Set us up the texture
	srface.SetDrawColor( 255, 255, 255, alpha )
	srface.SetTexture( self.WepSelectIcon )

	-- Lets get a sin wave to make it bounce
	local fsin = 0
	-- And fucking rotation
	local rsin = 0

	rsin = mth.sin( CurTime() * 3 ) * 6

	-- Borders
	y = y + 10
	x = x + 10
	wide = wide - 20

	-- Draw that mother
	srface.DrawTexturedRectRotated( x + 80 + (fsin), y + 50 - (fsin),  wide-fsin*2 , ( wide / 2 ) + (fsin), rsin )

	-- Draw weapon info box
	self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )

end

--[[---------------------------------------------------------
	This draws the weapon info box
-----------------------------------------------------------]]
function SWEP:PrintWeaponInfo( x, y, alpha )

	if ( self.DrawWeaponInfoBox == false ) then return end

	if (self.InfoMarkup == nil ) then
		local str
		local title_color = "<color=230,230,230,255>"
		local text_color = "<color=150,150,150,255>"
		local joke_color = "<color=255,20,147,255>"

		str = "<font=HudSelectionText>"
		if ( self.Author != "" ) then str = str .. title_color .. "Author:</color>\t"..text_color..self.Author.."</color>\n" end
		if ( self.Purpose != "" ) then str = str .. title_color .. "</color>\n"..text_color..self.Purpose.."</color>\n\n" end
				-- Moar info --
		str = str .. title_color .. "Tier:</color>\t"..text_color..self.Tier.."</color>\n"
		if self.Type==1 then
			str = str .. title_color .. "Type:</color>\t"..text_color.."Blade".."</color>\n"
		elseif self.Type==2 then
			str = str .. title_color .. "Type:</color>\t"..text_color.."Axe".."</color>\n"
		elseif self.Type==3 then
			str = str .. title_color .. "Type:</color>\t"..text_color.."Bludgeon".."</color>\n"
		elseif self.Type==4 then
			str = str .. title_color .. "Type:</color>\t"..text_color.."Spear".."</color>\n"
		elseif self.Type==5 then
			str = str .. title_color .. "Type:</color>\t"..text_color.."Shield".."</color>\n"
		elseif self.Type==6 then
			str = str .. title_color .. "Type:</color>\t"..text_color.."Special".."</color>\n"
		elseif self.Type==7 then
			str = str .. title_color .. "Type:</color>\t"..text_color.."Quarterstaff".."</color>\n"
		elseif self.Type==666 then
			str = str .. title_color .. "Type:</color>\t"..text_color.."Jesus's own Pencil".."</color>\n"
		end
		str = str .. title_color .. "Damage:</color>\t"..text_color..self.DmgMin*GetConVarNumber("ma2_damagemultiplier").."-"..self.DmgMax*GetConVarNumber("ma2_damagemultiplier").."</color>\n"
		if !self.CanThrow or GetConVarNumber( "ma2_togglethrowing" ) == 0 then
			str = str .. title_color .. "Throw:</color>\t"..text_color.."Can't throw this weapon".."</color>\n"
		else
			str = str .. title_color .. "Throw:</color>\t"..text_color..self.DmgMin2*GetConVarNumber("ma2_damagemultiplier").."-"..self.DmgMax2*GetConVarNumber("ma2_damagemultiplier").."</color>\n"
		end
		if self.Speed==1 then
			str = str .. title_color .. "Speed:</color>\t"..text_color.."★".."</color>\n"
		elseif self.Speed==2 then
			str = str .. title_color .. "Speed:</color>\t"..text_color.."★★".."</color>\n"
		elseif self.Speed==3 then
			str = str .. title_color .. "Speed:</color>\t"..text_color.."★★★".."</color>\n"
		elseif self.Speed==4 then
			str = str .. title_color .. "Speed:</color>\t"..text_color.."★★★★".."</color>\n"
		elseif self.Speed==5 then
			str = str .. title_color .. "Speed:</color>\t"..text_color.."★★★★★".."</color>\n"
		elseif self.Speed==6 then
			str = str .. title_color .. "Speed:</color>\t"..text_color.."★★★★★★".."</color>\n"
		end
		if self.Strength==1 then
			str = str .. title_color .. "Strength:</color>\t"..text_color.."★".."</color>\n"
		elseif self.Strength==2 then
			str = str .. title_color .. "Strength:</color>\t"..text_color.."★★".."</color>\n"
		elseif self.Strength==3 then
			str = str .. title_color .. "Strength:</color>\t"..text_color.."★★★".."</color>\n"
		elseif self.Strength==4 then
			str = str .. title_color .. "Strength:</color>\t"..text_color.."★★★★".."</color>\n"
		elseif self.Strength==5 then
			str = str .. title_color .. "Strength:</color>\t"..text_color.."★★★★★".."</color>\n"
		elseif self.Strength==6 then
			str = str .. title_color .. "Strength:</color>\t"..text_color.."★★★★★★".."</color>\n"
		end
		if self.JokeWep then
			str = str .. joke_color .. "Joke Weapon"
		end
		if ( self.Instructions != "" ) then str = str .. title_color .. "</color>\n"..text_color..self.Instructions.."</color>\n" end
		str = str .. "</font>"

		self.InfoMarkup = markup.Parse( str, 250 )
	end

	srface.SetDrawColor( 60, 60, 60, alpha )
	srface.SetTexture( self.SpeechBubbleLid )

	srface.DrawTexturedRect( x, y - 64 - 5, 128, 64 )
	draw.RoundedBox( 8, x - 5, y - 6, 260, self.InfoMarkup:GetHeight() + 18, Color( 60, 60, 60, alpha ) )

	self.InfoMarkup:Draw( x+5, y+5, nil, nil, alpha )

end

function SWEP:RenderSomeShit()
		tstdata.angles = self.Owner:GetAngles() + self.Owner:GetViewPunchAngles()
		tstdata.origin = self.Owner:GetShootPos()
		tstdata.x = 0
		tstdata.y = 0
		tstdata.w = ScrW()
		tstdata.h = ScrH()
		tstdata.drawviewmodel  = false
		tstdata.fov = 15
		rndr.RenderView( tstdata )

end

hudbopmul = 0

function SWEP:DrawScopeShit()
	local charge = self.Charge
	local ply = self.Owner
	local trace = ply:GetEyeTrace()
		self.QuadTable = {}
		self.QuadTable.w = ScrH()
		self.QuadTable.h = ScrH()
		self.QuadTable.x = (ScrW() - ScrH()) * .5
		self.QuadTable.y = 0

		srface.SetDrawColor( 0, 0, 0, 255 )
		if GetConVarNumber( "ma2_togglecrosshair" ) == 1 then
			surface.SetTexture( surface.GetTextureID("sprites/hud/v_crosshair2") )
			surface.SetDrawColor( 165,236,250, 255 )
			surface.DrawTexturedRect( trace.HitPos:ToScreen().x - 32, trace.HitPos:ToScreen().y - 32, 64, 64 )
		end
		if ply:GetNWBool("MeleeArtAttacking") or ply:GetNWBool("MeleeArtThrowing") then
			if ply:GetNWBool("chargemaxxxed")==true then
				draw.SimpleText(ply:GetNWString("chargeBar"), "QuadFont", ScrW()/2, ScrH()-100, Color(255, 255, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText(ply:GetNWString("chargeBar"), "QuadFont", ScrW()/2, ScrH()-100, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
end


function SWEP:TraceCollider(addforward, addright, addup)
local angles = self.Owner:EyeAngles()
	local collider = {}
		collider.start = self.Owner:EyePos()
		collider.endpos = collider.start + angles:Forward() * addforward
		collider.endpos = collider.endpos + angles:Right() * addright
		collider.endpos = collider.endpos + angles:Up() * addup
		collider.filter = self.Owner
		local trace = util.TraceLine(collider)
	return self.Owner:GetShootPos():Distance(trace.HitPos)
end

/********************************************************
	SWEP Construction Kit base code
		Created by Clavus
	Available for public use, thread at:
	   facepunch.com/threads/1032378

	DESCRIPTION:
		This script is meant for experienced scripters
		that KNOW WHAT THEY ARE DOING. Don't come to me
		with basic Lua questions.

		Just copy into your SWEP or SWEP base of choice
		and merge with your own code.

		The SWEP.VElements, SWEP.WElements and
		SWEP.ViewModelBoneMods tables are all optional
		and only have to be visible to the client.
********************************************************/
if CLIENT then
surface.CreateFont( "QuadFont", {
	font = "Arial",
	size = 25,
	weight = 5,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "QuadFontSmall", {
	font = "Arial",
	size = 15,
	weight = 5,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

end

function SWEP:InitFunc()
end

function SWEP:QuadsHere()
end

function SWEP:GetSCKshitPos(vm)

	//local vm = self.VElements[vm].modelEnt
	local pos, ang
	pos = self.VElements[vm].modelEnt:GetPos()
	ang = self.VElements[vm].modelEnt:GetAngles()

	return pos, ang
end

function SWEP:GetCapabilities()

	return bit.bor( CAP_WEAPON_RANGE_ATTACK1, CAP_INNATE_RANGE_ATTACK1 )

end

function SWEP:ShouldDropOnDie()
	return true
end

function SWEP:Initialize()
self:InitFunc()
	if SERVER then

	end

	if CLIENT then

	self:SetHoldType( self.IdleHoldType )
	self:QuadsHere()
	if self.QuadAmmoCounter == true then
		self.VElements["stam"].draw_func = function( weapon )
			//surface.SetDrawColor(quadInnerColor)
			draw.SimpleText(self.Owner:GetNWInt( 'MeleeArts2Stamina'), "QuadFont", 0, 0, self.AmmoQuadColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			--draw.SimpleText(weapon:Ammo1(), "QuadFont", 0, 25, self.AmmoQuadColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end

		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels

		if IsValid(self.Owner) and self.Owner:IsPlayer() then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)

			end
		end
	end
end

function SWEP:OnDrop()
	if CLIENT and IsValid(self.Owner) and self.Owner:IsPlayer() then
	local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
			vm:SetSubMaterial( 0, "" )
			vm:SetSubMaterial( 1, "" )
			vm:SetSubMaterial( 2, "" )
		end
	end
end

function SWEP:HolsterExtra()
	if self.Owner:GetNWBool("MeleeArtShieldening")==true then
		self.Owner:SetNWBool("MeleeArtShieldening",false)
	end
	if self.Type==7 then
		if self.Weapon:GetNWInt("QSChain")>0 then
			self.Weapon:SetNWInt("QSChain",0)
			self.Owner:EmitSound("ambient/levels/canals/windchime2.wav",40,80)
		end
	end
end

function SWEP:Holster()
	if (self.Owner:GetNWBool("MeleeArtStunned")==true or !IsValid(ply)) then
	return end
	self:HolsterExtra()
	self.Owner:SetNWBool("MeleeArtAttacking",false)
	self.Owner:SetNWBool("MeleeArtShoving", false)
	self.Owner:SetNWBool("MAGuardening", false)
	self.Owner:SetNWBool("MeleeArtThrowing",false)
	self.Charge2=0
	self.Charge=0
	self.WalkSpeed=ply:GetWalkSpeed()
	self.RunSpeed=ply:GetRunSpeed()
	self.JumpPower=ply:GetJumpPower()
	if CLIENT and IsValid(self.Owner) and self.Owner:IsPlayer() then
	local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
			vm:SetSubMaterial( 0, "" )
			vm:SetSubMaterial( 1, "" )
			vm:SetSubMaterial( 2, "" )
		end

	end

	if IsValid(self.Owner) and self.Owner:WaterLevel() == 3 then
	return false
	else
	return true
	end



end

function SWEP:OnRemove()
end

if CLIENT then

local redflare = Material( "effects/redflare" )
	--[[function SWEP:PostDrawViewModel( vm, weapon )
		if self.Weapon:GetNetworkedBool( "FuckDaModel" ) then return false end
	end]]

	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn(vm)

		//self:LaserDraw()
		local vm = self.Owner:GetViewModel()
		self:UpdateBonePositions(vm)

		if !IsValid(vm) then return end

		if (!self.VElements) then return end

		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then

			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end

		end

		for k, name in ipairs( self.vRenderOrder ) do

			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end

			local model = v.modelEnt
			local sprite = v.spriteMaterial

			if (!v.bone) then continue end

			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )

			if (!pos) then continue end

			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )

				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end

				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end

				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end

				if (v.surpresslightning) then
					rndr.SuppressEngineLighting(true)
				end

				rndr.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				rndr.SetBlend(v.color.a/255)
				model:DrawModel()
				rndr.SetBlend(1)
				rndr.SetColorModulation(1, 1, 1)

				if (v.surpresslightning) then
					rndr.SuppressEngineLighting(false)
				end

					if name == "Laser" then
							local pos = model:GetPos()
							local ang = model:GetAngles()
							local lsize = mth.random(3,5)
							local endpos, startpos			// = pos + ang:Up() * 10000

							if name == "Laser" then
								endpos = pos + ang:Right() * -1 + ang:Forward() * 10000 + ang:Up() * 1.2// + ang:Up() * 10
								startpos = pos + ang:Right() * -1 + ang:Forward() * 5 + ang:Up() * 1.2// + ang:Up() * 10
							end

							local trc = util.TraceLine({
								start = startpos,
								endpos = endpos
							})

							rndr.SetMaterial( redflare )
							rndr.DrawBeam(startpos, trc.HitPos, 0.2, 0, 0.99, Color(255,255,255, 100))
							rndr.DrawSprite( trc.HitPos,lsize,lsize,Color( 255,255,255 ) )

					end

			elseif (v.type == "Sprite" and sprite) then

				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				rndr.SetMaterial(sprite)
				rndr.DrawSprite(drawpos, v.size.x, v.size.y, v.color)

			elseif (v.type == "Quad" and v.draw_func) then

				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end

		end

	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()

		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end

		if (!self.WElements) then return end

		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end

		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			bone_ent = self
		end

		for k, name in pairs( self.wRenderOrder ) do

			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end

			local pos, ang

			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end

			if (!pos) then continue end

			local model = v.modelEnt
			local sprite = v.spriteMaterial

			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )

				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end

				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end

				if (v.surpresslightning) then
					rndr.SuppressEngineLighting(true)
				end

				rndr.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				rndr.SetBlend(v.color.a/255)
				model:DrawModel()
				rndr.SetBlend(1)
				rndr.SetColorModulation(1, 1, 1)

				if (v.surpresslightning) then
					rndr.SuppressEngineLighting(false)
				end

			elseif (v.type == "Sprite" and sprite) then

				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				rndr.SetMaterial(sprite)
				rndr.DrawSprite(drawpos, v.size.x, v.size.y, v.color)

			elseif (v.type == "Quad" and v.draw_func) then

				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end

		end

	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )

		local bone, pos, ang
		if (tab.rel and tab.rel != "") then

			local v = basetab[tab.rel]

			if (!v) then return end

			pos, ang = self:GetBoneOrientation( basetab, v, ent )

			if (!pos) then return end

			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)

		else

			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end

			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end

			if (IsValid(self.Owner) and self.Owner:IsPlayer() and
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r
			end

		end

		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then

				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end

			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite)
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then

				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)

			end
		end

	end

	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)

		if self.ViewModelBoneMods then

			if (!vm:GetBoneCount()) then return end

			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = {
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end

				loopthrough = allbones
			end
			// !! ----------- !! //

			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end

				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end

				s = s * ms
				// !! ----------- !! //

				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end

	end

	function SWEP:ResetBonePositions(vm)

		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end

	end

	/**************************
		Global utility code
	**************************/

	function table.FullCopy( tab )

		if (!tab) then return nil end

		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end

		return res

	end

end

print("Melee Art 2 base works, yippee")
