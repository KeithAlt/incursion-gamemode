AddCSLuaFile( "shared.lua" )
include('shared.lua')
/*-----------------------------------------------
	This SNPC is made by DrVrej
-----------------------------------------------*/
ENT.Model = {"models/fallout/eyebot.mdl"} -- Leave empty if using more than one model
ENT.HasBloodPool = false -- Does it have a blood pool?
ENT.BloodColor = "Oil"
ENT.StartHealth = 300
ENT.AnimTbl_MeleeAttack = {"attack"} -- Melee Attack Animations
ENT.MeleeAttackDamage = 0
ENT.MeleeAttackDamageDistance = 0 -- How far does the damage go?
ENT.MeleeAttackDistance = 0 -- How close does it have to be until it attacks?
-- This counted in seconds | This calculates the time until it hits something
ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
ENT.HasFootStepSound = false -- Should the SNPC make a footstep sound when it's moving?
ENT.HasDeathBodyGroup = false -- Set to true if you want to put a bodygroup when it dies
ENT.CustomBodyGroup = false -- Set true if you want to set custom bodygroup
ENT.HasIdleSounds = true
ENT.IdleSounds_PlayOnAttacks = false
ENT.IdleSounds_NoRegularIdleOnAlerted = true
ENT.IdleSoundChance = 1
ENT.NextSoundTime_Idle2 = 10
ENT.NextSoundTime_Idle1 = 10
ENT.PainSoundLevel = 100
ENT.SetCorpseOnFire = true
ENT.FadeCorpse = true -- Fades the ragdoll on death
ENT.FadeCorpseTime = 25 -- How much time until the ragdoll fades | Unit = Seconds
ENT.FollowPlayer = false
ENT.PlayerFriendly = false
ENT.TurningSpeed = 10
ENT.NextMeleeAttackTime = 0
ENT.SightDistance = 1000
ENT.PainSoundChance = .25


	-- Sounds --
-- Reminder: If you leave a sound blank, the game will still trfy to play!
ENT.SoundTbl_Death = {"npc/manhack/gib.wav"}
ENT.SoundTbl_Impact = {"physics/metal/metal_sheet_impact_hard2.wav", "physics/metal/metal_sheet_impact_hard6.wav", "physics/metal/metal_sheet_impact_hard7.wav", "physics/metal/metal_sheet_impact_hard2.wav"}
ENT.SoundTbl_Breath = {"npc/scanner/combat_scan_loop6.wav"}
ENT.SoundTbl_Alert = {"falloutradio/eden/enclave_radio1.ogg", "falloutradio/falloutradio/eden/enclave_radio2.ogg", "falloutradio/eden/enclave_radio3.ogg", "falloutradio/eden/enclave_radio4.ogg", "falloutradio/eden/enclave_radio5.ogg", "falloutradio/eden/enclave_radio6.ogg", "falloutradio/eden/enclave_radio7.ogg", "falloutradio/eden/enclave_radio8.ogg", "falloutradio/eden/enclave_radio9.ogg", "falloutradio/eden/enclave_radio10.ogg", "eden.wav"}
ENT.SoundTbl_Idle = {"eyebot/eye_war10.ogg", "eyebot/eye_war9.ogg", "eyebot/eye_war8.ogg", "eyebot/eye_war7.ogg", "eyebot/eye_war6.ogg", "eyebot/eye_war5.ogg", "eyebot/eye_war4.ogg"}
ENT.SoundTbl_Pain = {"eyebot/eye_war10.ogg", "eyebot/eye_war9.ogg", "eyebot/eye_war8.ogg", "eyebot/eye_war7.ogg", "eyebot/eye_war6.ogg", "eyebot/eye_war5.ogg", "eyebot/eye_war4.ogg"}

ENT.BreathSoundLevel = 55
ENT.HullType = HULL_HUMAN
ENT.HasHull = false -- Set to false to disable HULL
ENT.HullSizeNormal = true -- set to false to cancel out the self:SetHullSizeNormal()
ENT.HasSetSolid = true -- set to false to disable SetSolid
ENT.NextAlertSoundT = 2


function ENT:CustomInitialize()
	self:SetCollisionBounds(Vector(25, 25, 100), Vector(-25, -25, 0))
end

function ENT:CustomOnDeath_BeforeCorpseSpawned(dmginfo,hitgroup)
	self:EmitSound("eyebot/eye_war" .. math.random(1,10) .. ".ogg", 150, 25)
end

function ENT:CustomOnRemove()
	self:StopAllCommonSounds()
end

function ENT:CustomOnMeleeAttack_BeforeStartTimer()
	self.NextMeleeAttackTime = 0
end

function ENT:CustomOnAlert(argent)
	if self.alertupdate then return end
	self.NextAlertSoundT = 180
	self.alertupdate = true
end


function ENT:CustomOnAcceptInput(key,activator,caller,data)
	if SERVER && activator:KeyPressed(IN_USE) && !self.timer then
		self.PlayerFriendly = true
		self:StopAllCommonSounds()
		self:EmitSound("eyebot/eye_war" .. math.random(1,10) .. ".ogg")
		self.timer = true
		activator:falloutNotify("You have dismissed your Eyebot companion", "ui/notify.mp3")

		timer.Simple(15, function()
			if IsValid(self) then
				self.PlayerFriendly = false
				self.timer = nil
			end
		end)
	end
end
