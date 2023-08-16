AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2015 by Mayhem, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/fallout/radroach.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.SightDistance = 2500 -- How far it can see
ENT.StartHealth = 2000
ENT.MoveType = MOVETYPE_STEP
ENT.HullType = HULL_LARGE
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.Bleeds = true -- Does the SNPC bleed? (Blood decal, particle, etc.)
ENT.BloodColor = "Red" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.MeleeAttackDistance = 18
ENT.MeleeAttackDamageType = DMG_SLASH -- Type of Damage
ENT.Immune_AcidPoisonRadiation = true -- Makes the SNPC not get damage from Acid, posion, radiation
ENT.HasDeathRagdoll = true -- If set to false, it will not spawn the regular ragdoll of the SNPC
ENT.TimeUntilMeleeAttackDamage = false -- This counted in seconds | This calculates the time until it hits something

	-- Relationships ---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_FO3_ROACH"} -- NPCs with the same class with be allied to each other

	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_Idle = {
"npc/radroach/roach_idle01.mp3",
"npc/radroach/roach_idle02.mp3",
"npc/radroach/roach_idle03.mp3"
}

ENT.SoundTbl_Death = {
"npc/radroach/roach_death01.mp3",
"npc/radroach/roach_death02.mp3",
"npc/radroach/roach_death03.mp3"
}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(20, 20, 30), -Vector(20, 20, 0))
	self:SetSkin(1)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MultipleMeleeAttacks()
local EnemyDistance = self:VJ_GetNearestPointToEntityDistance(self:GetEnemy(),self:GetPos():Distance(self:GetEnemy():GetPos()))
	if EnemyDistance > 0 && EnemyDistance < 18 then
		self.MeleeAttackDistance = 18
		self.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1}
		self.MeleeAttackAngleRadius = 70 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
		self.MeleeAttackDamageAngleRadius = 70 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
		self.MeleeAttackDamageDistance = 200
		self.TimeUntilMeleeAttackDamage = false // 1.7 -- This counted in seconds | This calculates the time until it hits something
		self.NextAnyAttackTime_Melee = 0.8 -- How much time until it can use any attack again? | Counted in Seconds
		self.MeleeAttackDamage = 35
		self:EmitSound("npc/radroach/roach_attack0"..math.random(1,3)..".mp3", 70, 100, 1)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key,activator,caller,data)
	if key == "event_emit FootLeft" then
		self:EmitSound("npc/radroach/foot/roach_foot_l0"..math.random(1,3)..".mp3", 60, 100, 1)

	elseif key == "event_emit FootRight" then
		self:EmitSound("npc/radroach/foot/roach_foot_r0"..math.random(1,3)..".mp3", 60, 100, 1)

	elseif key == "event_mattack left" then
		self:MeleeAttackCode()

	elseif key == "event_mattack leftjump" then
		self:MeleeAttackCode()
	end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2015 by Mayhem, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
