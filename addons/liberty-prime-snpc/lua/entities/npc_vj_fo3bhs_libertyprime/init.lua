AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2017 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/VJ_FO/libertyprime.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = GetConVarNumber("vj_fo3_libertyprime_h")
ENT.HullType = HULL_LARGE
ENT.VJ_IsHugeMonster = true -- Is this a huge monster?
ENT.TurningSpeed = 10 -- How fast it can turn
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_UNITED_STATES_FRIENDLY","CLASS_PLAYER_ALLY"} -- NPCs with the same class with be allied to each other
ENT.Immune_AcidPoisonRadiation = true -- Makes the SNPC not get damage from Acid, posion, radiation
ENT.Immune_Physics = true -- If set to true, the SNPC won't take damage from props
ENT.FriendsWithAllPlayerAllies = true -- Should this SNPC be friends with all other player allies that are running on VJ Base?
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.MeleeAttackDamage = GetConVarNumber("vj_fo3_libertyprime_d")
ENT.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1} -- Melee Attack Animations
ENT.MeleeAttackDistance = 125 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 250 -- How far does the damage go?
ENT.TimeUntilMeleeAttackDamage = false // 1.7 -- This counted in seconds | This calculates the time until it hits something
ENT.NextAnyAttackTime_Melee = 3.6 -- How much time until it can use any attack again? | Counted in Seconds
ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
ENT.MeleeAttackWorldShakeOnMiss = true -- Should it shake the world when it misses during melee attack?
ENT.MeleeAttackWorldShakeOnMissAmplitude = 30 -- How much the screen will shake | From 1 to 16, 1 = really low 16 = really high
ENT.MeleeAttackWorldShakeOnMissRadius = 7000 -- How far the screen shake goes, in world units
ENT.MeleeAttackWorldShakeOnMissDuration = 1 -- How long the screen shake will last, in seconds
ENT.MeleeAttackWorldShakeOnMissFrequency = 100 -- Just leave it to 100
ENT.HasRangeAttack = true -- Should the SNPC have a range attack?
ENT.DisableRangeAttackAnimation = true -- if true, it will disable the animation code
ENT.NextRangeAttackTime = 0 -- How much time until it can use a range attack?
ENT.DisableFootStepSoundTimer = true -- If set to true, it will disable the time system for the footstep sound code, allowing you to use other ways like model events
/*ENT.HasWorldShakeOnMove = true -- Should the world shake when it's moving?
ENT.NextWorldShakeOnRun = 1.5 -- How much time until the world shakes while it's running
ENT.NextWorldShakeOnWalk = 1.5 -- How much time until the world shakes while it's walking
ENT.WorldShakeOnMoveAmplitude = 10 -- How much the screen will shake | From 1 to 16, 1 = really low 16 = really high
ENT.WorldShakeOnMoveRadius = 7000 -- How far the screen shake goes, in world units
ENT.WorldShakeOnMoveDuration = 0.4 -- How long the screen shake will last, in seconds
ENT.WorldShakeOnMoveFrequency = 100 -- Just leave it to 100*/
ENT.HasDeathRagdoll = false -- If set to false, it will not spawn the regular ragdoll of the SNPC
ENT.HasDeathNotice = true -- Set to true if you want it show a message after it dies
ENT.DeathNoticeWriting = "A Liberty Prime is now Offline!" -- Message that will appear
//ENT.WaitBeforeDeathTime = 6 -- Time until the SNPC spawns its corpse and gets removed
ENT.NextSoundTime_Breath1 = 200
ENT.NextSoundTime_Breath2 = 200
ENT.HasSoundTrack = true -- Does the SNPC have a sound track?
ENT.HasImpactSounds = false -- If set to false, it won't play the impact sounds
ENT.AlertSounds_OnlyOnce = true -- After it plays it once, it will never play it again
ENT.IdleSounds_PlayOnAttacks = true -- It will be able to continue and play idle sounds when it performs an attack
ENT.FollowPlayer = false -- Should the SNPC follow the player when the player presses a certain key?
ENT.FollowPlayerCloseDistance = 300 -- If the SNPC is that close to the player then stand still until the player goes farther away
ENT.BecomeEnemyToPlayer = true -- Should the friendly SNPC become enemy towards the player if it's damaged by a player?
ENT.BecomeEnemyToPlayerLevel = 6 -- How many times does the player have to hit the SNPC for it to become enemy?
ENT.HasDeathAnimation = true -- Does it play an animation when it dies?
ENT.AnimTbl_Death = {"vjseq_brace"} -- Death Animations
ENT.DeathAnimationTime = 6 -- Time until the SNPC spawns its corpse and gets removed
ENT.GibOnDeathDamagesTable = {"All"} -- Damages that it gibs from | "UseDefault" = Uses default damage types | "All" = Gib from any damage
ENT.ConstantlyFaceEnemy = true -- Should it face the enemy constantly?
ENT.ConstantlyFaceEnemy_IfAttacking = true -- Should it face the enemy when attacking?
ENT.ConstantlyFaceEnemy_Postures = "Standing" -- "Both" = Moving or standing | "Moving" = Only when moving | "Standing" = Only when standing
ENT.ConstantlyFaceEnemyDistance = 2000 -- How close does it have to be until it starts to face the enemy?
ENT.NoChaseAfterCertainRange = true -- Should the SNPC not be able to chase when it's between number x and y?
ENT.NoChaseAfterCertainRange_FarDistance = 600 -- How far until it can chase again? | "UseRangeDistance" = Use the number provided by the range attack instead
ENT.NoChaseAfterCertainRange_CloseDistance = 50 -- How near until it can chase again? | "UseRangeDistance" = Use the number provided by the range attack instead
ENT.NoChaseAfterCertainRange_Type = "OnlyRange" -- "Regular" = Default behavior | "OnlyRange" = Only does it if it's able to range attack
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_FootStep = {"vj_fo3_libertyprime/foot1.mp3","vj_fo3_libertyprime/foot2.mp3"}
ENT.SoundTbl_Breath = {"vj_fo3_libertyprime/idle_loop.wav"}
ENT.SoundTbl_Idle = {"vj_fo3_libertyprime/attack1.mp3","vj_fo3_libertyprime/attack3.mp3","vj_fo3_libertyprime/attack4.mp3","vj_fo3_libertyprime/attack5.mp3","vj_fo3_libertyprime/attack7.mp3","vj_fo3_libertyprime/attack9.mp3","vj_fo3_libertyprime/attack10.mp3","vj_fo3_libertyprime/attack11.mp3","vj_fo3_libertyprime/attack14.mp3","vj_fo3_libertyprime/attack15.mp3","vj_fo3_libertyprime/attack16.mp3","vj_fo3_libertyprime/attack18.mp3","vj_fo3_libertyprime/attack19.mp3","vj_fo3_libertyprime/attack20.mp3","vj_fo3_libertyprime/attack23.mp3"}
ENT.SoundTbl_CombatIdle = {"vj_fo3_libertyprime/attack1.mp3","vj_fo3_libertyprime/attack3.mp3","vj_fo3_libertyprime/attack4.mp3","vj_fo3_libertyprime/attack5.mp3","vj_fo3_libertyprime/attack7.mp3","vj_fo3_libertyprime/attack9.mp3","vj_fo3_libertyprime/attack10.mp3","vj_fo3_libertyprime/attack11.mp3","vj_fo3_libertyprime/attack14.mp3","vj_fo3_libertyprime/attack15.mp3","vj_fo3_libertyprime/attack16.mp3","vj_fo3_libertyprime/attack18.mp3","vj_fo3_libertyprime/attack19.mp3","vj_fo3_libertyprime/attack20.mp3","vj_fo3_libertyprime/attack23.mp3","vj_fo3_libertyprime/attack2.mp3","vj_fo3_libertyprime/attack6.mp3","vj_fo3_libertyprime/attack8.mp3","vj_fo3_libertyprime/attack12.mp3","vj_fo3_libertyprime/attack13.mp3","vj_fo3_libertyprime/attack17.mp3","vj_fo3_libertyprime/attack21.mp3","vj_fo3_libertyprime/attack22.mp3"}
ENT.SoundTbl_Alert = {"vj_fo3_libertyprime/alert.mp3"}
ENT.SoundTbl_MeleeAttack = {}
ENT.SoundTbl_MeleeAttackExtra = {"vj_impact_metal/metalhit1.wav","vj_impact_metal/metalhit2.wav","vj_impact_metal/metalhit3.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_fo3_libertyprime/foot2.mp3"}
ENT.SoundTbl_Pain = {}
ENT.SoundTbl_Death = {"vj_fo3_libertyprime/die.mp3"}
ENT.SoundTbl_SoundTrack = {""}

ENT.SoundTrackChance = 4

ENT.AlertSoundLevel = 110
ENT.IdleSoundLevel = 120
ENT.CombatIdleSoundLevel = 120
ENT.MeleeAttackSoundLevel = 110
ENT.ExtraMeleeAttackSoundLevel = 90
ENT.MeleeAttackMissSoundLevel = 110
ENT.PainSoundLevel = 110
ENT.DeathSoundLevel = 110
ENT.ImpactSoundLevel = 110
ENT.FootStepSoundLevel = 110
ENT.BeforeRangeAttackSoundLevel = 110
ENT.RangeAttackSoundLevel = 110
ENT.BreathSoundLevel = 70

ENT.GeneralSoundPitch1 = 100
ENT.GeneralSoundPitch2 = 100

ENT.NextSoundTime_Idle2 = 8

ENT.AttackTimersCustom = {"timer_range_finished_libertylaser","timer_range_start_libertylaser"}

-- Custom
ENT.LibertyPrime_DoingNukeAttack = false
ENT.LibertyPrime_DoingLaserAttack = false
ENT.LibertyPrime_NextNukeAttackT = 0
ENT.LibertyPrime_NextDmgSpark = 0
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	print("Liberty Prime Spawned")
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:SetCollisionBounds(Vector(100, 100, 490), Vector(-100, -100, 0))
	PrintMessage(HUD_PRINTCENTER, "A Liberty Prime is now Online!")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Controller_IntMsg(ply)
	ply:ChatPrint("MOUSE2 + JUMP: Throw Mininuke")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key,activator,caller,data)
	if key == "event_lfoot" then
		self:FootStepSoundCode()
		VJ_EmitSound(self,"vj_fo3_libertyprime/foot"..math.random(1,2).."_move.mp3",100,100)
		util.ScreenShake(self:GetAttachment(self:LookupAttachment("lfoot")).Pos,10,100,0.4,7000)
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetAttachment(self:LookupAttachment("lfoot")).Pos)
		effectdata:SetScale(1000)
		util.Effect("ThumperDust",effectdata)
	end
	if key == "event_rfoot" then
		self:FootStepSoundCode()
		VJ_EmitSound(self,"vj_fo3_libertyprime/foot"..math.random(1,2).."_move.mp3",100,100)
		util.ScreenShake(self:GetAttachment(self:LookupAttachment("rfoot")).Pos,10,100,0.4,7000)
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetAttachment(self:LookupAttachment("rfoot")).Pos)
		effectdata:SetScale(1000)
		util.Effect("ThumperDust",effectdata)
	end
	if key == "event_mattack stomp" then
		self:MeleeAttackCode()
	end
	if key == "event_bodygroup 1 1" then
		self:SetBodygroup(1,1)
		self:BeforeRangeAttackSoundCode("vj_fo3_libertyprime/range_equip.mp3")
	end
	if key == "event_rattack range" then
		self:VJ_ACT_PLAYACTIVITY(ACT_RANGE_ATTACK1,false,0,true)
	end
	if key == "event_bodygroup 1 0" then
		self:SetBodygroup(1,0)
	end
	if key == "event_rattack throw" then
		self:RangeAttackCode()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	if self.RangeAttacking == false then
		self:SetBodygroup(1,0)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAlert()
	if self.HasDone_PlayAlertSoundOnlyOnce == false then
		self.NextIdleSoundT = CurTime() + 13
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MultipleRangeAttacks()
	if self:GetEnemy():GetPos():Distance(self:GetPos()) > 600 && CurTime() > self.LibertyPrime_NextNukeAttackT && ((self.VJ_IsBeingControlled == false) or (self.VJ_IsBeingControlled == true && self.VJ_TheController:KeyDown(IN_JUMP))) then
		self.LibertyPrime_DoingNukeAttack = true
		self.LibertyPrime_DoingLaserAttack = false
		self.RangeAttackEntityToSpawn = "obj_fo3_libertymininuke" -- The entity that is spawned when range attacking
		self.RangeDistance = 2700 -- This is how far away it can shoot
		self.RangeToMeleeDistance = 600 -- How close does it have to be until it uses melee?
		self.RangeUseAttachmentForPos = true -- Should the projectile spawn on a attachment?
		self.RangeUseAttachmentForPosID = "bomb" -- The attachment used on the range attack if RangeUseAttachmentForPos is set to true
		self.TimeUntilRangeAttackProjectileRelease = false //2.8 -- How much time until the projectile code is ran?
		self.NextAnyAttackTime_Range = 3.4667 -- How much time until it can use any attack again? | Counted in Seconds
		self.DisableDefaultRangeAttackCode = false
		self.RangeAttackAnimationFaceEnemy = true
		self.RangeAttackAnimationStopMovement = true
	else
		self.LibertyPrime_DoingNukeAttack = false
		self.LibertyPrime_DoingLaserAttack = true
		self.RangeDistance = 6000 -- This is how far away it can shoot
		self.RangeToMeleeDistance = 200 -- How close does it have to be until it uses melee?
		self.TimeUntilRangeAttackProjectileRelease = 0.01 -- How much time until the projectile code is ran?
		self.NextAnyAttackTime_Range = 0.35 -- How much time until it can use any attack again? | Counted in Seconds
		self.DisableDefaultRangeAttackCode = true
		self.RangeAttackAnimationFaceEnemy = false
		self.RangeAttackAnimationStopMovement = false
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:LibertyPrime_DoLaserTrace()
	local tracedata = {}
	tracedata.start = self:GetAttachment(self:LookupAttachment("eye")).Pos
	tracedata.endpos = self:GetEnemy():GetPos()+self:GetEnemy():OBBCenter() //self:GetEnemy():GetPos() + self:GetUp()*math.Rand(-20,20) + self:GetRight()*math.Rand(-20,20)
	tracedata.filter = self
	local tr = util.TraceLine(tracedata)
	return tr.HitPos
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomRangeAttackCode()
	if self.LibertyPrime_DoingNukeAttack == true then
		self:SetBodygroup(1,0)
	elseif self.LibertyPrime_DoingLaserAttack == true then
		//if ((self:GetAngles() - (self:GetEnemy():GetPos() -self:GetPos()):Angle()).y <= 40 or (self:GetAngles() - (self:GetEnemy():GetPos() -self:GetPos()):Angle()).y >= 320) then -- If it's between 45 and 315 then don't shoot!
		local trpos = self:LibertyPrime_DoLaserTrace() //self:GetEnemy():GetPos() + self:GetUp()*math.Rand(-20,20) + self:GetRight()*math.Rand(-20,20)
		VJ_EmitSound(self,"vj_fo3_libertyprime/laser.wav",110,100)
		util.ScreenShake(trpos, 100, 200, 0.4, 3000)
		util.ParticleTracerEx("Weapon_Combine_Ion_Cannon_Beam", self:GetPos(), trpos, false, self:EntIndex(), 1)
		if GetConVarNumber("vj_fo3_lp_laserexplosionparticles") == 1 then
			if self:GetEnemy():IsOnGround() then
				ParticleEffect("aurora_shockwave", trpos, Angle(0,0,0), nil)
				ParticleEffect("aurora_shockwave_debris", trpos, Angle(0,0,0), nil)
			end
			ParticleEffect("Weapon_Combine_Ion_Cannon_Exlposion_c", trpos, Angle(0,0,0), nil)
		end
		util.VJ_SphereDamage(self,self,trpos,80,40,DMG_GENERIC,true,false,{Force=90})
		//util.BlastDamage(self,self,trpos,80,40)
		/*for k,v in ipairs(ents.FindInSphere(trpos,80)) do
			v:TakeDamage(40, self)
			VJ_DestroyCombineTurret(self,v)
		end*/
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_Miss()
	self.NextIdleSoundT_RegularChange = CurTime() + math.random(3,4)
	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetAttachment(self:LookupAttachment("rfoot")).Pos) -- the vector of were you want the effect to spawn
	effectdata:SetScale(1000) -- how big the particles are, can even be 0.1 or 0.6
	util.Effect("ThumperDust",effectdata) -- Add as many as you want
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnRangeAttack_BeforeStartTimer()
	if self.LibertyPrime_DoingNukeAttack == true then
		self:VJ_ACT_PLAYACTIVITY(ACT_ARM,false,0,true)
		self.PlayingAttackAnimation = true
		self.CurrentAttackAnimation = ACT_ARM
		self.CurrentAttackAnimationDuration = VJ_GetSequenceDuration(self,self.CurrentAttackAnimation) + 1.64
		timer.Simple(self.CurrentAttackAnimationDuration,function()
			if IsValid(self) then
				self.PlayingAttackAnimation = false
			end
		end)
		self.LibertyPrime_NextNukeAttackT = CurTime() + 20
	elseif self.LibertyPrime_DoingLaserAttack == true then
		self:RestartGesture(ACT_GESTURE_RANGE_ATTACK1)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackCode_GetShootPos(TheProjectile)
//	return (self:GetEnemy():GetPos() -self:GetAttachment(self:LookupAttachment("bomb")).Pos) + self:GetUp()*350
	return (self:GetEnemy():GetPos()+self:GetEnemy():OBBCenter()-self:GetAttachment(self:LookupAttachment(self.RangeUseAttachmentForPosID)).Pos):GetNormal()*5000
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_OnBleed(dmginfo,hitgroup)
	//self.NextIdleSoundT_RegularChange = CurTime() + math.random(3,4)
	if dmginfo:GetDamagePosition() == Vector(0,0,0) then return end
	if CurTime() > self.LibertyPrime_NextDmgSpark then
		self.DamageSpark1 = ents.Create("env_spark")
		self.DamageSpark1:SetKeyValue("Magnitude","3")
		self.DamageSpark1:SetKeyValue("Spark Trail Length","3")
		self.DamageSpark1:SetPos(dmginfo:GetDamagePosition())
		self.DamageSpark1:SetAngles(self:GetAngles())
		//self.DamageSpark1:Fire("LightColor", "255 255 255")
		self.DamageSpark1:SetParent(self)
		self.DamageSpark1:Spawn()
		self.DamageSpark1:Activate()
		self.DamageSpark1:Fire("StartSpark", "", 0)
		self.DamageSpark1:Fire("StopSpark", "", 0.001)
		self:DeleteOnRemove(self.DamageSpark1)
		self.LibertyPrime_NextDmgSpark = CurTime() + 1
	end

	/*local effectdataspk = EffectData()
	effectdataspk:SetOrigin(dmginfo:GetDamagePosition())
	effectdataspk:SetScale( 40 )
	util.Effect( "ManhackSparks", effectdataspk )*/
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomDeathAnimationCode(dmginfo,hitgroup)
	//self:Ignite(3,0)
	//self:VJ_PlaySequence("brace",1,true,self:SequenceDuration(self:LookupSequence("brace")))
	//self:VJ_ACT_PLAYACTIVITY("vjseq_brace",true,self:SequenceDuration(self:LookupSequence("brace")),false)
	timer.Simple(0.5,function()
		if self:IsValid() then
			util.ScreenShake(self:GetPos(),100,200,1,3000)
			if self.HasGibDeathParticles == true then ParticleEffect("vj_explosion2",self:GetPos() + self:GetUp()*360 + self:GetRight() *-50,Angle(0,0,0),nil) end
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos() +self:GetUp()*360 + self:GetRight() *-50) -- the vector of were you want the effect to spawn
			util.Effect( "Explosion", effectdata )
		end
	end)
	timer.Simple(2,function()
		if self:IsValid() then
			util.ScreenShake(self:GetPos(),100,200,1,3000)
			if self.HasGibDeathParticles == true then ParticleEffect("vj_explosion2",self:GetPos() + self:GetUp()*300,Angle(0,0,0),nil) end
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos() +self:GetUp()*460) -- the vector of were you want the effect to spawn
			util.Effect( "Explosion", effectdata )
		end
	end)
	timer.Simple(3.5,function()
		if self:IsValid() then
			util.ScreenShake(self:GetPos(),100,200,1,3000)
			if self.HasGibDeathParticles == true then ParticleEffect("vj_explosion2",self:GetPos() + self:GetUp()*460,Angle(0,0,0),nil) end
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos() +self:GetUp()*460) -- the vector of were you want the effect to spawn
			util.Effect( "Explosion", effectdata )
		end
	end)
	timer.Simple(5.05,function()
		if self:IsValid() then
			util.ScreenShake(self:GetPos(),100,200,1,3000)
			if self.HasGibDeathParticles == true then ParticleEffect("vj_explosion2",self:GetBonePosition(self:LookupBone("Bip01 R Clavicle")),Angle(0,0,0),nil) end
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetBonePosition(self:LookupBone("Bip01 R Clavicle"))) -- the vector of were you want the effect to spawn
			util.Effect( "Explosion", effectdata )
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetUpGibesOnDeath(dmginfo,hitgroup)
//	if self.DeathAnimationCodeRan == false then return false end
	/** for i = 0, self:GetBoneCount() -15 do
		self:CreateGibEntity("prop_physics",{"models/props_debris/metal_panelchunk01a.mdl","models/props_debris/metal_panelchunk01b.mdl","models/props_debris/metal_panelchunk01d.mdl","models/props_debris/metal_panelchunk01e.mdl","models/props_debris/metal_panelchunk01f.mdl","models/props_debris/metal_panelchunk01g.mdl","models/props_debris/metal_panelchunk02d.mdl","models/props_debris/metal_panelchunk02e.mdl"},{Pos=self:GetBonePosition(i),Vel=self:GetForward()*math.Rand(-200,200)+self:GetRight()*math.Rand(-200,200)+self:GetUp()*math.Rand(350,600)},function(gib) gib:Ignite(math.Rand(20,30),0) gib:SetColor(Color(50,50,50)) end)
		/*(self.libertyGibs = ents.Create("prop_physics")
		self.libertyGibs:SetModel(Model(VJ_PICKRANDOMTABLE({"models/props_debris/metal_panelchunk01a.mdl","models/props_debris/metal_panelchunk01b.mdl","models/props_debris/metal_panelchunk01d.mdl","models/props_debris/metal_panelchunk01e.mdl","models/props_debris/metal_panelchunk01f.mdl","models/props_debris/metal_panelchunk01g.mdl","models/props_debris/metal_panelchunk02d.mdl","models/props_debris/metal_panelchunk02e.mdl"})))
		self.libertyGibs:SetPos(self:GetBonePosition(i))
		self.libertyGibs:SetAngles(self:GetAngles())
		self.libertyGibs:Spawn()
		self.libertyGibs:Activate()
		self.libertyGibs:SetColor(Color(50,50,50))
		self.libertyGibs:SetMaterial(self:GetMaterial())
		self.libertyGibs:Ignite(math.Rand(6,9),0)
		self.libertyGibs:GetPhysicsObject():AddVelocity( Vector( math.Rand( -200, 200 ), math.Rand( -200, 200 ), math.Rand( 500, 600 ) ) )
		if GetConVarNumber("vj_npc_gibcollidable") == 0 then self.libertyGibs:SetCollisionGroup( 1 ) end
		cleanup.ReplaceEntity(self.libertyGibs)
		if GetConVarNumber("vj_npc_fadegibs") == 1 then
		self.libertyGibs:Fire( "kill", "", GetConVarNumber("vj_npc_fadegibstime") ) end*/
	--end
	--return true,{DeathAnim=true}
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomGibOnDeathSounds(dmginfo,hitgroup)
	return false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnKilled(dmginfo,hitgroup)
	util.BlastDamage(self,self,self:GetPos() + self:GetUp()*360,200,40)
	util.BlastDamage(self,self,self:GetPos(),400,40)
	util.ScreenShake(self:GetPos(),100,200,1,3000)
	if self.HasGibDeathParticles == true then
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos() + Vector(0,0,0)) -- the vector of were you want the effect to spawn
		effectdata:SetScale(500) -- how big the particles are, can even be 0.1 or 0.6
		util.Effect("HelicopterMegaBomb", effectdata) -- Add as many as you want
		util.Effect("ThumperDust", effectdata) -- Add as many as you want
		//util.Effect("StriderBlood",effectdata)
		for i = 0, self:GetBoneCount() -62 do
			ParticleEffect("vj_explosion2",self:GetBonePosition(i),Angle(0,0,0),nil)
		end
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos() +self:GetUp()*260) -- the vector of were you want the effect to spawn
		util.Effect("Explosion", effectdata)
		ParticleEffect("mininuke_explosion_child_flash",self:GetPos() + self:GetUp()*260,Angle(0,0,0),nil)
		ParticleEffect("mininuke_explosion_child_flash_mod",self:GetPos() + self:GetUp()*260,Angle(0,0,0),nil)
		ParticleEffect("mininuke_explosion_child_shrapnel",self:GetPos() + self:GetUp()*260,Angle(0,0,0),nil)
		ParticleEffect("mininuke_explosion_child_smoke",self:GetPos() + self:GetUp()*260,Angle(0,0,0),nil)
		ParticleEffect("mininuke_explosion_child_sparks",self:GetPos() + self:GetUp()*260,Angle(0,0,0),nil)
		ParticleEffect("mininuke_explosion_child_sparks2",self:GetPos() + self:GetUp()*260,Angle(0,0,0),nil)
		ParticleEffect("mininuke_explosion_shrapnel_fire_child",self:GetPos() + self:GetUp()*260,Angle(0,0,0),nil)
		ParticleEffect("mininuke_explosion_shrapnel_smoke_child",self:GetPos() + self:GetUp()*260,Angle(0,0,0),nil)
	end
	self:RunGibOnDeathCode(dmginfo,hitgroup)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnRemove()
	VJ_STOPSOUND(self.CurrentDeathSound)
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2017 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
