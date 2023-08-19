AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2015 by Mayhem, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/fallout/radscorpion.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.SightDistance = 1500 -- How far it can see
ENT.StartHealth = 1200
ENT.MoveType = MOVETYPE_STEP
ENT.HullType = HULL_LARGE
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.Bleeds = true -- Does the SNPC bleed? (Blood decal, particle, etc.)
ENT.BloodColor = "Green" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.MeleeAttackDistance = 80
ENT.MeleeAttackDamageType = DMG_SLASH -- Type of Damage
ENT.Immune_AcidPoisonRadiation = true -- Makes the SNPC not get damage from Acid, posion, radiation
ENT.HasDeathRagdoll = true -- If set to false, it will not spawn the regular ragdoll of the SNPC
ENT.TimeUntilMeleeAttackDamage = false -- This counted in seconds | This calculates the time until it hits something

	-- Relationships ---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_FO3_SCORP"} -- NPCs with the same class with be allied to each other

	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_Idle = {
"npc/radscorpion/radscorpion_idle01.mp3",
"npc/radscorpion/radscorpion_idle02.mp3"
}

ENT.SoundTbl_Death = {
"npc/radscorpion/radscorpion_death01.mp3",
"npc/radscorpion/radscorpion_death02.mp3"
}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(40, 40, 80), -Vector(40, 40, 0))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MultipleMeleeAttacks()
local EnemyDistance = self:VJ_GetNearestPointToEntityDistance(self:GetEnemy(),self:GetPos():Distance(self:GetEnemy():GetPos()))
	if EnemyDistance > 0 && EnemyDistance < 80 then
		self.MeleeAttackDistance = 80
		self.AnimTbl_MeleeAttack = {"2H2Hattackright"}
		self.MeleeAttackAngleRadius = 70 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
		self.MeleeAttackDamageAngleRadius = 70 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
		self.MeleeAttackDamageDistance = 200
		self.TimeUntilMeleeAttackDamage = false // 1.7 -- This counted in seconds | This calculates the time until it hits something
		self.NextAnyAttackTime_Melee = 1.5 -- How much time until it can use any attack again? | Counted in Seconds
		self.MeleeAttackDamage = 30
	end

	if EnemyDistance > 80 && EnemyDistance < 120 then
		self.MeleeAttackDistance = 120
		self.AnimTbl_MeleeAttack = {"H2hattackforwardpower"}
		self.MeleeAttackAngleRadius = 70 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
		self.MeleeAttackDamageAngleRadius = 70 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
		self.MeleeAttackDamageDistance = 200
		self.TimeUntilMeleeAttackDamage = false // 1.7 -- This counted in seconds | This calculates the time until it hits something
		self.NextAnyAttackTime_Melee = 1.4 -- How much time until it can use any attack again? | Counted in Seconds
		self.MeleeAttackDamage = 30
		self.MeleeAttackDamageType = DMG_POISON
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key,activator,caller,data)
	if key == "event_emit FootLeft" then
		self:EmitSound("npc/radscorpion/foot/radscorpion_foot_l0"..math.random(1,2)..".mp3", 70, 100, 1)

	elseif key == "event_emit FootRight" then
		self:EmitSound("npc/radscorpion/foot/radscorpion_foot_r0"..math.random(1,2)..".mp3", 70, 100, 1)

	elseif key == "event_play Strike" then
		self:EmitSound("npc/radscorpion/radscorpion_attack0"..math.random(1,3)..".mp3", 80, 100, 1)
		self.MeleeAttackDamageType = DMG_SLASH
		self.SoundTbl_MeleeAttack = {
			"npc/radscorpion/radscorpion_clawatk01.mp3",
			"npc/radscorpion/radscorpion_clawatk02.mp3",
			"npc/radscorpion/radscorpion_clawatk03.mp3"
			}

	elseif key == "event_play AttackSting" then
		self:EmitSound("npc/radscorpion/radscorpion_attacktail01.mp3", 80, 100, 1)
		self.SoundTbl_MeleeAttack = {
			"npc/radscorpion/radscorpion_attacksting01.mp3",
			"npc/radscorpion/radscorpion_attacksting02.mp3",
			"npc/radscorpion/radscorpion_attacksting03.mp3"
			}
		self.MeleeAttackDamageType = DMG_POISON

	elseif key == "event_mattack left" then
		self:MeleeAttackCode()

	elseif key == "event_mattack right" then
		self:MeleeAttackCode()

	elseif key == "event_mattack power" then
		self:MeleeAttackCode()

	elseif key == "event_mattack forwardpower" then
		self:MeleeAttackCode()
	end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2015 by Mayhem, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
