AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2016 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/gibs/humans/mgib_02.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 990
ENT.SightDistance = 1000
ENT.HullType = HULL_TINY
ENT.MovementType = VJ_MOVETYPE_STATIONARY
ENT.Aerial_AnimTbl_Alerted = {"idle"}
ENT.FindEnemy_UseSphere = true
ENT.CanTurnWhileStationary = false
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_COMBINE"} -- NPCs with the same class will be friendly to each other | Combine: CLASS_COMBINE, Zombie: CLASS_ZOMBIE, Antlions = CLASS_ANTLION
ENT.BloodColor = "Blue" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.HasMeleeAttack = true -- How close does it have to be until it attacks?
ENT.MeleeAttackDistance = 50
ENT.MeleeAttackDamageDistance = 80 -- How far does the damage go?
ENT.TimeUntilMeleeAttackDamage = 0.1 -- This counted in seconds | This calculates the time until it hits something
ENT.NextAnyAttackTime_Melee = 1 -- How much time until it can use a attack again? | Counted in Seconds
ENT.MeleeAttackDamage = 9
ENT.Immune_Dissolve = true -- Immune to Dissolving | Example: Combine Ball
ENT.Immune_AcidPoisonRadiation = true -- Immune to Acid, Poison and Radiation
ENT.Immune_Electricity = true -- Immune to Electrical
ENT.Immune_Physics = true -- Immune to Physics
ENT.Immune_Blast = true
ENT.GodMode = true
ENT.Immune_Bullet = true
ENT.DisableMeleeAttackAnimation = true
ENT.AnimTbl_MeleeAttack = {} -- Melee Attack Animations
ENT.MeleeAttackDamageType = DMG_POISON -- Type of Damage
ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
ENT.MeleeAttackBleedEnemy = true -- Should the player bleed when attacked by melee
ENT.MeleeAttackBleedEnemyChance = 1 -- How chance there is that the play will bleed? | 1 = always
ENT.MeleeAttackBleedEnemyDamage = 3 -- How much damage will the enemy get on every rep?
ENT.MeleeAttackBleedEnemyTime = 1 -- How much time until the next rep?
ENT.MeleeAttackBleedEnemyReps = 5 -- How many reps?
ENT.HasDeathRagdoll = false

	-- ====== Flinching Code ====== --
ENT.CanFlinch = 1 -- 0 = Don't flinch | 1 = Flinch at any damage | 2 = Flinch only from certain damages
ENT.FlinchChance = 8 -- Chance of it flinching from 1 to x | 1 will make it always flinch
ENT.NextMoveAfterFlinchTime = 1.3 -- How much time until it can move, attack, etc. | Use this for schedules or else the base will set the time 0.6 if it sees it's a schedule!
ENT.NextFlinchTime = 5 -- How much time until it can flinch again?
ENT.AnimTbl_Flinch = {"am_hurt_left_leg","am_hurt_right_leg"} 
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_MeleeAttack = {""}
ENT.SoundTbl_MeleeAttackMiss = {""}
ENT.SoundTbl_Pain = {""}
ENT.SoundTbl_Death = {""}
ENT.SoundTbl_Breath = {""}

ENT.IdleSoundLevel = 150
----------------------------------------------------------------
function ENT:CustomOnInitialize()
ParticleEffectAttach("manhac_las",PATTACH_POINT_FOLLOW,self,0)
self.DisableMakingSelfEnemyToNPCs = true
self.VJ_NoTarget = true
self:SetNoDraw(true)
self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
timer.Simple(math.random(16,20),function() if IsValid(self) then 
self:Remove() end end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnRemove() 
ParticleEffect("explosion_turret_break",self:GetPos(),Angle(0,0,0),nil)
util.BlastDamage(self,self,self:GetPos(),250,math.random(33,40))
end
	----------------------------------------
function ENT:CustomOnThink_AIEnabled()
if self:GetEnemy() != nil then
if self:GetPos():Distance(self:GetEnemy():GetPos()) < 140 then


self:Remove()

end
end
end
/*-----------------------------------------------

	*** Copyright (c) 2012-2016 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/