AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2015 by Mayhem, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/fallout/mirelurkking.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.SightDistance = 4000 -- How far it can see
ENT.StartHealth = 8500
ENT.MoveType = MOVETYPE_STEP
ENT.HullType = HULL_LARGE
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.Bleeds = true -- Does the SNPC bleed? (Blood decal, particle, etc.)
ENT.BloodColor = "Blue" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.MeleeAttackDistance = 40
ENT.MeleeAttackDamageType = DMG_SHOCK -- Type of Damage
ENT.Immune_AcidPoisonRadiation = true -- Makes the SNPC not get damage from Acid, posion, radiation
ENT.HasDeathRagdoll = true -- If set to false, it will not spawn the regular ragdoll of the SNPC
ENT.TimeUntilMeleeAttackDamage = false -- This counted in seconds | This calculates the time until it hits something
ENT.HasRangeAttack = true -- Should the SNPC have a range attack?
ENT.RangeAttackEntityToSpawn = "obj_fo3_shockwave" -- The entity that is spawned when range attacking
ENT.RangeAttackAnimationFaceEnemy = true -- Should it face the enemy while playing the range attack animation?
ENT.RangeToMeleeDistance = 300 -- How close does it have to be until it uses melee?
ENT.RangeUseAttachmentForPos = true -- Should the projectile spawn on a attachment?
ENT.RangeUseAttachmentForPosID = "mouth" -- The attachment used on the range attack if RangeUseAttachmentForPos is set to true
ENT.TimeUntilRangeAttackProjectileRelease = false -- How much time until the projectile code is ran?
ENT.RangeDistance = 1400
ENT.AnimTbl_RangeAttack = {"2hlattackright"} -- Range Attack Animations
ENT.NextAnyAttackTime_Range = 3 -- How much time until it can use a range attack?
ENT.RangeAttackExtraTimers = {} -- Extra range attack timers | it will run the projectile code after the given amount of seconds

	-- Relationships ---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_FO3_CRAB"} -- NPCs with the same class with be allied to each other

	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_Death = {
"npc/mirelurkking/mirelurkking_death01.mp3",
"npc/mirelurkking/mirelurkking_death02.mp3"
}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackCode_GetShootPos(TheProjectile)
	return (self:GetEnemy():GetPos()+self:GetEnemy():OBBCenter()-self:GetAttachment(self:LookupAttachment(self.RangeUseAttachmentForPosID)).Pos):GetNormal()*800
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(40, 40, 80), -Vector(40, 40, 0))
	self:SetSkin(1)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MultipleMeleeAttacks()
local EnemyDistance = self:VJ_GetNearestPointToEntityDistance(self:GetEnemy(),self:GetPos():Distance(self:GetEnemy():GetPos()))
	if EnemyDistance > 0 && EnemyDistance < 40 then
		self.MeleeAttackDistance = 40
		self.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1}
		self.MeleeAttackAngleRadius = 300 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
		self.MeleeAttackDamageAngleRadius = 70 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
		self.MeleeAttackDamageDistance = 80
		self.TimeUntilMeleeAttackDamage = false // 1.7 -- This counted in seconds | This calculates the time until it hits something
		self.NextAnyAttackTime_Melee = 1.3 -- How much time until it can use any attack again? | Counted in Seconds
		self.MeleeAttackDamage = 80
		self.MeleeAttackDamageType = DMG_SHOCK
		self:EmitSound("npc/mirelurkking/mirelurkking_attack0"..math.random(1,3)..".mp3", 70, 100, 1)
	end

	if EnemyDistance > 100 && EnemyDistance < 130 then
		self.MeleeAttackDistance = 130
		self.AnimTbl_MeleeAttack = {"h2h_attackforwardpower"}
		self.MeleeAttackAngleRadius = 70 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
		self.MeleeAttackDamageAngleRadius = 70 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
		self.MeleeAttackDamageDistance = 300
		self.TimeUntilMeleeAttackDamage = false // 1.7 -- This counted in seconds | This calculates the time until it hits something
		self.NextAnyAttackTime_Melee = 1.2 -- How much time until it can use any attack again? | Counted in Seconds
		self.MeleeAttackDamage = 80
		self.MeleeAttackDamageType = DMG_SHOCK
		self:EmitSound("npc/mirelurkking/mirelurkking_attack0"..math.random(1,3)..".mp3", 70, 100, 1)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key,activator,caller,data)
	if key == "event_emit FootLeft" then
		self:EmitSound("npc/mirelurkking/foot/mirelurkking_foot_l0"..math.random(1,2)..".mp3", 70, 100, 1)

	elseif key == "event_emit FootRight" then
		self:EmitSound("npc/mirelurkking/foot/mirelurkking_foot_r0"..math.random(1,2)..".mp3", 70, 100, 1)

	elseif key == "event_rattack sonic" then
		self:EmitSound("npc/mirelurkking/mirelurkking_attack_sonic.mp3", 80, 100, 1)
		self:RangeAttackCode()

	elseif key == "event_mattack leftjab" then
		self:MeleeAttackCode()

	elseif key == "event_mattack backhand" then
		self:MeleeAttackCode()

	elseif key == "event_mattack forward" then
		self:MeleeAttackCode()

	elseif key == "event_mattack rightjab" then
		self:MeleeAttackCode()

	elseif key == "event_mattack rightslice" then
		self:MeleeAttackCode()

	elseif key == "event_mattack leftslice" then
		self:MeleeAttackCode()
	end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2015 by Mayhem, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
