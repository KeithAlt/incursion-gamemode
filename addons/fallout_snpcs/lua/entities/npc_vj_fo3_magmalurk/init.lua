AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2015 by Mayhem, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/fallout/magmalurk.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.SightDistance = 3009 -- How far it can see
ENT.StartHealth = 10000
ENT.MoveType = MOVETYPE_STEP
ENT.HullType = HULL_LARGE
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.Bleeds = true -- Does the SNPC bleed? (Blood decal, particle, etc.)
ENT.BloodColor = "Blue" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.MeleeAttackDistance = 70
ENT.MeleeAttackDamageType = DMG_BURN -- Type of Damage
ENT.Immune_AcidPoisonRadiation = true -- Makes the SNPC not get damage from Acid, posion, radiation
ENT.HasDeathRagdoll = true -- If set to false, it will not spawn the regular ragdoll of the SNPC
ENT.TimeUntilMeleeAttackDamage = false -- This counted in seconds | This calculates the time until it hits something

	-- Relationships ---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_FO3_CRAB"} -- NPCs with the same class with be allied to each other

	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_Idle = {
"npc/magmalurk/mirelurk_idle01.mp3",
"npc/magmalurk/mirelurk_idle02.mp3",
"npc/magmalurk/mirelurk_idle03.mp3",
"npc/magmalurk/mirelurk_idle04.mp3"
}

ENT.SoundTbl_Death = {
"npc/magmalurk/mirelurk_death01.mp3",
"npc/magmalurk/mirelurk_death02.mp3"
}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(50, 50, 100), -Vector(50, 50, 0))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAlert()
	self:VJ_ACT_PLAYACTIVITY(ACT_IDLE_ANGRY,true,4,false)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MultipleMeleeAttacks()
local EnemyDistance = self:VJ_GetNearestPointToEntityDistance(self:GetEnemy(),self:GetPos():Distance(self:GetEnemy():GetPos()))
if EnemyDistance > 0 && EnemyDistance < 70 then
	local randattack_close = math.random(1,5)
		self.MeleeAttackDistance = 70
		if randattack_close == 1 then
			self.AnimTbl_MeleeAttack = {"vjseq_h2hattackleft"}
			self.MeleeAttackAngleRadius = 70 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
			self.MeleeAttackDamageAngleRadius = 70 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
			self.MeleeAttackDamageDistance = 300
			self.NextAnyAttackTime_Melee = 1 -- How much time until it can use any attack again? | Counted in Seconds
			self.TimeUntilMeleeAttackDamage = false // 1.7 -- This counted in seconds | This calculates the time until it hits something
			self.MeleeAttackDamage = 85
			self.MeleeAttackDamageType = DMG_BURN

		elseif randattack_close == 2 then
			self.AnimTbl_MeleeAttack = {"vjseq_h2hattackleftpower"}
			self.MeleeAttackAngleRadius = 70 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
			self.MeleeAttackDamageAngleRadius = 70 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
			self.MeleeAttackDamageDistance = 300
			self.NextAnyAttackTime_Melee = 1.6 -- How much time until it can use any attack again? | Counted in Seconds
			self.TimeUntilMeleeAttackDamage = false // 1.7 -- This counted in seconds | This calculates the time until it hits something
			self.MeleeAttackDamage = 85
			self.MeleeAttackDamageType = DMG_BURN
			self:EmitSound("npc/magmalurk/mirelurk_attackpower01.mp3", 80, 100, 1)

		elseif randattack_close == 3 then
			self.AnimTbl_MeleeAttack = {"vjseq_h2hattackright"}
			self.MeleeAttackAngleRadius = 70 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
			self.MeleeAttackDamageAngleRadius = 70 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
			self.MeleeAttackDamageDistance = 300
			self.NextAnyAttackTime_Melee = 1 -- How much time until it can use any attack again? | Counted in Seconds
			self.TimeUntilMeleeAttackDamage = false // 1.7 -- This counted in seconds | This calculates the time until it hits something
			self.MeleeAttackDamage = 85
			self.MeleeAttackDamageType = DMG_BURN

		elseif randattack_close == 4 then
			self.AnimTbl_MeleeAttack = {"vjseq_h2hattackrightpower"}
			self.MeleeAttackAngleRadius = 70 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
			self.MeleeAttackDamageAngleRadius = 70 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
			self.MeleeAttackDamageDistance = 300
			self.NextAnyAttackTime_Melee = 1.6 -- How much time until it can use any attack again? | Counted in Seconds
			self.TimeUntilMeleeAttackDamage = false // 1.7 -- This counted in seconds | This calculates the time until it hits something
			self.MeleeAttackDamage = 85
			self.MeleeAttackDamageType = DMG_BURN
			self:EmitSound("npc/magmalurk/mirelurk_attackpower01.mp3", 80, 100, 1)

		elseif randattack_close == 5 then
			self.AnimTbl_MeleeAttack = {"vjseq_h2hattackpower"}
			self.MeleeAttackAngleRadius = 70 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
			self.MeleeAttackDamageAngleRadius = 70 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
			self.MeleeAttackDamageDistance = 300
			self.NextAnyAttackTime_Melee = 2 -- How much time until it can use any attack again? | Counted in Seconds
			self.TimeUntilMeleeAttackDamage = false // 1.7 -- This counted in seconds | This calculates the time until it hits something
			self.MeleeAttackDamage = 85
			self.MeleeAttackDamageType = DMG_BURN
			self:EmitSound("npc/magmalurk/mirelurk_attackpowerrun01.mp3", 80, 100, 1)
		end
	end
if EnemyDistance > 150 && EnemyDistance < 180 then
		self.MeleeAttackDistance = 180
		self.AnimTbl_MeleeAttack = {"H2hattackforwardpower"}
		self.MeleeAttackAngleRadius = 250 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
		self.MeleeAttackDamageAngleRadius = 250 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
		self.MeleeAttackDamageDistance = 100
		self.NextAnyAttackTime_Melee = 1.6 -- How much time until it can use any attack again? | Counted in Seconds
		self.TimeUntilMeleeAttackDamage = false // 1.7 -- This counted in seconds | This calculates the time until it hits something
		self.MeleeAttackDamage = 50
		self.MeleeAttackDamageType = DMG_BLAST
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key,activator,caller,data)
	if key == "event_emit FootLeft" then
		self:EmitSound("npc/magmalurk/foot/mirelurk_foot_l0"..math.random(1,2)..".mp3", 70, 100, 1)

	elseif key == "event_emit FootRight" then
		self:EmitSound("npc/magmalurk/foot/mirelurk_foot_r0"..math.random(1,2)..".mp3", 70, 100, 1)

	elseif key == "event_play MeleePowerRun" then
		self:EmitSound("npc/magmalurk/mirelurk_attackpowerforward01.mp3", 70, 100, 1)

	elseif key == "event_play Melee" then
		self:EmitSound("npc/magmalurk/mirelurk_attack0"..math.random(1,2)..".mp3", 80, 100, 1)

	elseif key == "event_play IdleAngry" then
		self:EmitSound("npc/magmalurk/mirelurk_warning.mp3", 80, 100, 1)

	elseif key == "event_mattack left" then
		self:MeleeAttackCode()

	elseif key == "event_mattack right" then
		self:MeleeAttackCode()

	elseif key == "event_mattack leftpower" then
		self:MeleeAttackCode()

	elseif key == "event_mattack rightpower" then
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
