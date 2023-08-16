AddCSLuaFile("shared.lua")

include('shared.lua')

/*-----------------------------------------------

	*** Copyright (c) 2012-2015 by DrVrej, All rights reserved. ***

	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,

	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.

-----------------------------------------------*/

ENT.Model = "models/arachnit/fallout4/synths/synthgeneration1.mdl" -- Leave empty if using more than one model

ENT.StartHealth = GetConVarNumber("npc_vj_resistance_srpa_soldier_h")

ENT.MeleeAttackDamage = GetConVarNumber("npc_vj_resistance_srpa_soldier_d")

ENT.MoveType = MOVETYPE_STEP

ENT.HullType = HULL_HUMAN

ENT.HullSizeNormal = false -- set to false to cancel out the self:SetHullSizeNormal()

ENT.SightDistance = 10000 -- How far it can see

ENT.SightAngle = 80 -- The sight angle | Example: 180 would make the it see all around it | Measured in degrees and then converted to radians

ENT.TurningSpeed = 20 -- How fast it can turn

ENT.Bleeds = true -- Does the SNPC bleed? (Blood decal, particle, etc.)

ENT.BloodColor = "Oil" -- The blood type, this will determine what it should use (decal, particle, etc.)

ENT.HasBloodParticle = true -- Does it spawn a particle when damaged?

ENT.HasBloodDecal = true -- Does it spawn a decal when damaged?

ENT.HasBloodPool = false -- Does it have a blood pool?

ENT.Flinches = 1 -- 0 = No Flinch | 1 = Flinches at any damage | 2 = Flinches only from certain damages

ENT.FlinchingChance = 12 -- chance of it flinching from 1 to x | 1 will make it always flinch

ENT.FlinchingSchedules = {SCHED_FLINCH_PHYSICS} -- If self.FlinchUseACT is false the it uses this | Common: SCHED_BIG_FLINCH, SCHED_SMALL_FLINCH, SCHED_FLINCH_PHYSICS

ENT.MoveWhenDamagedByEnemy = true -- Should the SNPC move when being damaged by an enemy?

ENT.MoveWhenDamagedByEnemySCHED1 = SCHED_FORCED_GO_RUN -- The schedule it runs when MoveWhenDamagedByEnemy code is ran | The first # in math.random

ENT.MoveWhenDamagedByEnemySCHED2 = SCHED_FORCED_GO_RUN -- The schedule it runs when MoveWhenDamagedByEnemy code is ran | The second # in math.random

ENT.NextMoveWhenDamagedByEnemy1 = 3 -- Next time it moves when getting damaged | The first # in math.random

ENT.NextMoveWhenDamagedByEnemy2 = 3.5 -- Next time it moves when getting damaged | The second # in math.random

ENT.HasAllies = true -- Put to false if you want it not to have any allies

ENT.VJ_NPC_Class = {"CLASS_INSTITUTE"} -- NPCs with the same class with be allied to each other

ENT.PlayerFriendly = true -- Makes the SNPC friendly to the player and HL2 Resistance

ENT.MoveOutOfFriendlyPlayersWay = false -- Should the SNPC move out of the way when a friendly player comes close to it?

ENT.FollowPlayer = true -- Should the SNPC follow the player when the player presses a certain key?

ENT.FollowPlayerChat = false -- Should the SNPCs say things like "Blank stopped following you" | self.AllowPrintingInChat overrides this variable!

ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?

ENT.HasGrenadeAttack = true -- Should the SNPC have a grenade attack?

ENT.NextThrowGrenadeTime1 = 10 -- Time until it runs the throw grenade code again | The first # in math.random

ENT.NextThrowGrenadeTime2 = 15 -- Time until it runs the throw grenade code again | The second # in math.random

ENT.BecomeEnemyToPlayer = true -- Should the friendly SNPC become enemy towards the player if it's damaged by a player?

ENT.BecomeEnemyToPlayerLevel = 1

ENT.ThrowGrenadeChance = 1 -- Chance that it will throw the grenade | Set to 1 to throw all the time

ENT.GrenadeAttackThrowDistance = 1000 -- How far it can throw grenades

ENT.GrenadeAttackThrowDistanceClose = 500 -- How close until it stops throwing grenades

ENT.AnimTbl_GrenadeAttack = {"grenThrow"} -- Grenade Attack Animations

ENT.GrenadeAttackAnimationDelay = 0 -- It will wait certain amount of time before playing the animation

ENT.GrenadeAttackAnimationStopAttacks = true -- Should it stop attacks for a certain amount of time?

ENT.FootStepTimeRun = 0.3 -- Next foot step sound when it is running

ENT.FootStepTimeWalk = 0.5 -- Next foot step sound when it is walking

ENT.CallForBackUpOnDamage = true -- Should the SNPC call for help when damaged? (Only happens if the SNPC hasn't seen a enemy)

ENT.CallForBackUpOnDamageDistance = 800 -- How far away the SNPC's call for help goes | Counted in World Units

ENT.CallForBackUpOnDamageUseCertainAmount = false -- Should the SNPC only call certain amount of people?

ENT.NextCallForBackUpOnDamageTime1 = 9 -- Next time it use the CallForBackUpOnDamage function | The first # in math.random

ENT.NextCallForBackUpOnDamageTime2 = 11 -- Next time it use the CallForBackUpOnDamage function | The second # in math.random





	-- ====== Sound File Paths ====== --

ENT.SoundTbl_Alert = {"synth_attack1.wav", "synth_attack3.wav", "synth_ai1.wav", "synth_ai2.wav"}

ENT.SoundTbl_CombatIdle = {"synth_attack1.wav", "synth_attack2.wav", "synth_attack3.wav", "synth_ai1.wav", "synth_ai2.wav"}

ENT.SoundTbl_Idle = {"synth_idle.wav", "synth_idle2.wav", "synth_idle3.wav", "synth_ai1.wav", "synth_ai2.wav"}

ENT.DefaultSoundTbl_FootStep = {"npc/stalker/stalker_footstep_right2.wav","npc/stalker/stalker_footstep_right1.wav","npc/stalker/stalker_footstep_left1.wav","npc/stalker/stalker_footstep_left2.wav"}

ENT.DefaultSoundTbl_MeleeAttack = {"physics/body/body_medium_impact_hard1.wav","physics/body/body_medium_impact_hard2.wav","physics/body/body_medium_impact_hard3.wav","physics/body/body_medium_impact_hard4.wav","physics/body/body_medium_impact_hard5.wav","physics/body/body_medium_impact_hard6.wav"}

ENT.DefaultSoundTbl_MeleeAttackMiss = {"npc/zombie/claw_miss1.wav","npc/zombie/claw_miss2.wav"}

ENT.DefaultSoundTbl_Impact = {"physics/metal/weapon_impact_hard1.wav","physics/metal/weapon_impact_hard2.wav","physics/metal/weapon_impact_hard3.wav"}

ENT.DefaultSoundTbl_MedicAfterHeal = {"synth_ai2.wav"}



	-- ====== Sound Pitch ====== --

-- Higher number = Higher pitch | Lower number = Lower pitch

-- Highest number is 254

	-- !!! Important variables !!! --

ENT.UseTheSameGeneralSoundPitch = true

	-- If set to true, it will make the game decide a number when the SNPC is created and use it for all sound pitches set to "UseGeneralPitch"

	-- It picks the number between the two variables below:

ENT.GeneralSoundPitch1 = 100

ENT.GeneralSoundPitch2 = 100

	-- This two variables control any sound pitch variable that is set to "UseGeneralPitch"

	-- To not use these variables for a certain sound pitch, just put the desired number in the specific sound pitch

ENT.FootStepPitch1 = 100

ENT.FootStepPitch2 = 100

ENT.BreathSoundPitch1 = 100

ENT.BreathSoundPitch2 = 100

ENT.IdleSoundPitch1 = "UseGeneralPitch"

ENT.IdleSoundPitch2 = "UseGeneralPitch"

ENT.CombatIdleSoundPitch1 = "UseGeneralPitch"

ENT.CombatIdleSoundPitch2 = "UseGeneralPitch"

ENT.OnReceiveOrderSoundPitch1 = "UseGeneralPitch"

ENT.OnReceiveOrderSoundPitch2 = "UseGeneralPitch"

ENT.FollowPlayerPitch1 = "UseGeneralPitch"

ENT.FollowPlayerPitch2 = "UseGeneralPitch"

ENT.UnFollowPlayerPitch1 = "UseGeneralPitch"

ENT.UnFollowPlayerPitch2 = "UseGeneralPitch"

ENT.BeforeHealSoundPitch1 = "UseGeneralPitch"

ENT.BeforeHealSoundPitch2 = "UseGeneralPitch"

ENT.AfterHealSoundPitch1 = 100

ENT.AfterHealSoundPitch2 = 100

ENT.OnPlayerSightSoundPitch1 = "UseGeneralPitch"

ENT.OnPlayerSightSoundPitch2 = "UseGeneralPitch"

ENT.AlertSoundPitch1 = "UseGeneralPitch"

ENT.AlertSoundPitch2 = "UseGeneralPitch"

ENT.CallForHelpSoundPitch1 = "UseGeneralPitch"

ENT.CallForHelpSoundPitch2 = "UseGeneralPitch"

ENT.BecomeEnemyToPlayerPitch1 = "UseGeneralPitch"

ENT.BecomeEnemyToPlayerPitch2 = "UseGeneralPitch"

ENT.BeforeMeleeAttackSoundPitch1 = "UseGeneralPitch"

ENT.BeforeMeleeAttackSoundPitch2 = "UseGeneralPitch"

ENT.MeleeAttackSoundPitch1 = 100

ENT.MeleeAttackSoundPitch2 = 100

ENT.ExtraMeleeSoundPitch1 = 100

ENT.ExtraMeleeSoundPitch2 = 100

ENT.MeleeAttackMissSoundPitch1 = 100

ENT.MeleeAttackMissSoundPitch2 = 100

ENT.SuppressingPitch1 = "UseGeneralPitch"

ENT.SuppressingPitch2 = "UseGeneralPitch"

ENT.WeaponReloadSoundPitch1 = "UseGeneralPitch"

ENT.WeaponReloadSoundPitch2 = "UseGeneralPitch"

ENT.GrenadeAttackSoundPitch1 = "UseGeneralPitch"

ENT.GrenadeAttackSoundPitch2 = "UseGeneralPitch"

ENT.OnGrenadeSightSoundPitch1 = "UseGeneralPitch"

ENT.OnGrenadeSightSoundPitch2 = "UseGeneralPitch"

ENT.PainSoundPitch1 = "UseGeneralPitch"

ENT.PainSoundPitch2 = "UseGeneralPitch"

ENT.ImpactSoundPitch1 = 100

ENT.ImpactSoundPitch2 = 100

ENT.DamageByPlayerPitch1 = "UseGeneralPitch"

ENT.DamageByPlayerPitch2 = "UseGeneralPitch"

ENT.DeathSoundPitch1 = "UseGeneralPitch"

ENT.DeathSoundPitch2 = "UseGeneralPitch"


-- To add rest of the SNPC and get full list of the function, you need to decompile VJ Base.


function ENT:CustomOnInitialize()
	if SERVER then -- PARTICLE EFFECT EVENTS (By Keith)
		self:SetBodygroup(1, math.random(1,4))
		ParticleEffect("mr_energybeam_1", self:GetPos() + Vector(0,0,300), Angle(-270,-0, -0), self)
		ParticleEffect("_sai_wormhole", self:GetPos(), Angle(-90), self)
		ParticleEffect("mr_cop_anomaly_electra_a", self:GetPos(), self:GetAngles(), self)
		ParticleEffectAttach("super_shlrd",PATTACH_POINT_FOLLOW,self,0)
		self:EmitSound("npc/scanner/cbot_energyexplosion1.wav")
		util.ScreenShake(self:GetPos(), 100, 100, 2, 100)
		timer.Simple(0.5, function()
			self:StopParticles()
		end)
	end
end



/*-----------------------------------------------

	*** Copyright (c) 2012-2015 by DrVrej, All rights reserved. ***

	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,

	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.

-----------------------------------------------*/

