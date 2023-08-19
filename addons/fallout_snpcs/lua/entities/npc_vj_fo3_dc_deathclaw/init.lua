AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2015 by Mayhem, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/fallout/deathclaw.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.SightDistance = 1500 -- How far it can see
ENT.StartHealth = 600
ENT.MoveType = MOVETYPE_STEP
ENT.HullType = HULL_LARGE
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.Bleeds = true -- Does the SNPC bleed? (Blood decal, particle, etc.)
ENT.BloodColor = "Red" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.MeleeAttackDistance = 80
ENT.MeleeAttackDamageType = DMG_SLASH -- Type of Damage
ENT.Immune_AcidPoisonRadiation = true -- Makes the SNPC not get damage from Acid, posion, radiation
ENT.HasDeathRagdoll = true -- If set to false, it will not spawn the regular ragdoll of the SNPC
ENT.TimeUntilMeleeAttackDamage = false -- This counted in seconds | This calculates the time until it hits something

	-- Relationships ---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_FO3_DEATHCLAW"} -- NPCs with the same class with be allied to each other

	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_Idle = {
"npc/deathclaw/deathclaw_idle01.mp3",
"npc/deathclaw/deathclaw_idle02.mp3",
"npc/deathclaw/deathclaw_idle03.mp3",
"npc/deathclaw/deathclaw_idle04.mp3"
}

ENT.SoundTbl_Death = {
"npc/deathclaw/deathclaw_death01.mp3",
"npc/deathclaw/deathclaw_death02.mp3"
}

ENT.SoundTbl_MeleeAttack = {
"npc/deathclaw/deathclaw_claw_atk01.mp3",
"npc/deathclaw/deathclaw_claw_atk02.mp3",
"npc/deathclaw/deathclaw_claw_atk03.mp3",
"npc/deathclaw/deathclaw_claw_atk04.mp3"
}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(50, 50, 120), -Vector(50, 50, 0))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MultipleMeleeAttacks()
local EnemyDistance = self:VJ_GetNearestPointToEntityDistance(self:GetEnemy(),self:GetPos():Distance(self:GetEnemy():GetPos()))
	if EnemyDistance > 0 && EnemyDistance < 80 then
	local randattack_close = math.random(1,6)
		self.MeleeAttackDistance = 80
		if randattack_close == 1 then
			self.AnimTbl_MeleeAttack = {"vjseq_h2hattackleft_a"}
			self.MeleeAttackAngleRadius = 80 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
			self.MeleeAttackDamageAngleRadius = 80 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
			self.MeleeAttackDamageDistance = 300
			self.NextAnyAttackTime_Melee = 1 -- How much time until it can use any attack again? | Counted in Seconds
			self.TimeUntilMeleeAttackDamage = false // 1.7 -- This counted in seconds | This calculates the time until it hits something
			self.MeleeAttackDamage = 40
			self.MeleeAttackDamageType = DMG_SLASH
			self:EmitSound("npc/deathclaw/deathclaw_attack0"..math.random(1,2)..".mp3", 80, 100, 1)

		elseif randattack_close == 2 then
			self.AnimTbl_MeleeAttack = {"vjseq_h2hattackleft_b"}
			self.MeleeAttackAngleRadius = 100 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
			self.MeleeAttackDamageAngleRadius = 100 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
			self.MeleeAttackDamageDistance = 300
			self.NextAnyAttackTime_Melee = 1 -- How much time until it can use any attack again? | Counted in Seconds
			self.TimeUntilMeleeAttackDamage = false // 1.7 -- This counted in seconds | This calculates the time until it hits something
			self.MeleeAttackDamage = 40
			self.MeleeAttackDamageType = DMG_SLASH
			self:EmitSound("npc/deathclaw/deathclaw_attack0"..math.random(1,2)..".mp3", 80, 100, 1)

		elseif randattack_close == 3 then
			self.AnimTbl_MeleeAttack = {"vjseq_h2hattackleftpower"}
			self.MeleeAttackAngleRadius = 70 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
			self.MeleeAttackDamageAngleRadius = 70 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
			self.MeleeAttackDamageDistance = 300
			self.NextAnyAttackTime_Melee = 1.5 -- How much time until it can use any attack again? | Counted in Seconds
			self.TimeUntilMeleeAttackDamage = false // 1.7 -- This counted in seconds | This calculates the time until it hits something
			self.MeleeAttackDamage = 40
			self.MeleeAttackDamageType = DMG_SLASH
			self:EmitSound("npc/deathclaw/deathclaw_attackpower01.mp3", 80, 100, 1)

		elseif randattack_close == 4 then
			self.AnimTbl_MeleeAttack = {"vjseq_h2hattackright_a"}
			self.MeleeAttackAngleRadius = 70 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
			self.MeleeAttackDamageAngleRadius = 70 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
			self.MeleeAttackDamageDistance = 300
			self.NextAnyAttackTime_Melee = 1 -- How much time until it can use any attack again? | Counted in Seconds
			self.TimeUntilMeleeAttackDamage = false // 1.7 -- This counted in seconds | This calculates the time until it hits something
			self.MeleeAttackDamage = 40
			self.MeleeAttackDamageType = DMG_SLASH
			self:EmitSound("npc/deathclaw/deathclaw_attack0"..math.random(1,2)..".mp3", 80, 100, 1)

		elseif randattack_close == 5 then
			self.AnimTbl_MeleeAttack = {"vjseq_h2hattackright_b"}
			self.MeleeAttackAngleRadius = 70 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
			self.MeleeAttackDamageAngleRadius = 70 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
			self.MeleeAttackDamageDistance = 300
			self.NextAnyAttackTime_Melee = 1 -- How much time until it can use any attack again? | Counted in Seconds
			self.TimeUntilMeleeAttackDamage = false // 1.7 -- This counted in seconds | This calculates the time until it hits something
			self.MeleeAttackDamage = 40
			self.MeleeAttackDamageType = DMG_SLASH
			self:EmitSound("npc/deathclaw/deathclaw_attack0"..math.random(1,2)..".mp3", 80, 100, 1)

		elseif randattack_close == 6 then
			self.AnimTbl_MeleeAttack = {"vjseq_h2hattackrightpower"}
			self.MeleeAttackAngleRadius = 70 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
			self.MeleeAttackDamageAngleRadius = 70 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
			self.MeleeAttackDamageDistance = 300
			self.NextAnyAttackTime_Melee = 1.5 -- How much time until it can use any attack again? | Counted in Seconds
			self.TimeUntilMeleeAttackDamage = false // 1.7 -- This counted in seconds | This calculates the time until it hits something
			self.MeleeAttackDamage = 40
			self.MeleeAttackDamageType = DMG_SLASH
			self:EmitSound("npc/deathclaw/deathclaw_attackpower01.mp3", 80, 100, 1)
		end
	end

	if EnemyDistance > 300 && EnemyDistance < 330 then
		self.MeleeAttackDistance = 330
		self.AnimTbl_MeleeAttack = {"H2hattackforwardpower"}
		self.MeleeAttackAngleRadius = 70 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
		self.MeleeAttackDamageAngleRadius = 70 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
		self.MeleeAttackDamageDistance = 150
		self.NextAnyAttackTime_Melee = 1.6 -- How much time until it can use any attack again? | Counted in Seconds
		self.TimeUntilMeleeAttackDamage = false // 1.7 -- This counted in seconds | This calculates the time until it hits something
		self.MeleeAttackDamage = 30
		self.MeleeAttackDamageType = DMG_SLASH
		self:EmitSound("npc/deathclaw/deathclaw_attackpowerforward01.mp3", 80, 100, 1)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key,activator,caller,data)
	if key == "event_emit FootLeft" then
		self:EmitSound("npc/deathclaw/foot/deathclaw_foot_l0"..math.random(1,2)..".mp3", 70, 100, 1)

	elseif key == "event_emit FootRight" then
		self:EmitSound("npc/deathclaw/foot/deathclaw_foot_r0"..math.random(1,2)..".mp3", 70, 100, 1)

	elseif key == "event_emit FootRunRight" then
		self:EmitSound("npc/deathclaw/foot/deathclaw_foot_run_r.mp3", 70, 100, 1)

	elseif key == "event_emit FootRunLeft" then
		self:EmitSound("npc/deathclaw/foot/deathclaw_foot_run_l0"..math.random(1,3)..".mp3", 80, 100, 1)

	elseif key == "event_mattack lefta" then
		self:MeleeAttackCode()

	elseif key == "event_mattack leftb" then
		self:MeleeAttackCode()

	elseif key == "event_mattack righta" then
		self:MeleeAttackCode()

	elseif key == "event_mattack rightb" then
		self:MeleeAttackCode()

	elseif key == "event_mattack leftpower" then
		self:MeleeAttackCode()

	elseif key == "event_mattack rightpower" then
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
