AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2015 by Mayhem, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/fallout/ghoulferal_jumpsuit.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.SightDistance = 1500 -- How far it can see
ENT.StartHealth = 300
ENT.MoveType = MOVETYPE_STEP
ENT.HullType = HULL_LARGE
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.Bleeds = true -- Does the SNPC bleed? (Blood decal, particle, etc.)
ENT.BloodColor = "Red" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.MeleeAttackDistance = 25
ENT.MeleeAttackDamageType = DMG_SLASH -- Type of Damage
ENT.Immune_AcidPoisonRadiation = true -- Makes the SNPC not get damage from Acid, posion, radiation
ENT.HasDeathRagdoll = true -- If set to false, it will not spawn the regular ragdoll of the SNPC
ENT.TimeUntilMeleeAttackDamage = false -- This counted in seconds | This calculates the time until it hits something

	-- Relationships ---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_FO3_GHOUL"} -- NPCs with the same class with be allied to each other

	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_Death = {
"npc/ghoulferal/feralghoul_death01.mp3",
"npc/ghoulferal/feralghoul_death02.mp3",
"npc/ghoulferal/feralghoul_death03.mp3",
"npc/ghoulferal/feralghoul_death04.mp3"
}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(30, 30, 90), -Vector(30, 30, 0))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MultipleMeleeAttacks()
local EnemyDistance = self:VJ_GetNearestPointToEntityDistance(self:GetEnemy(),self:GetPos():Distance(self:GetEnemy():GetPos()))
	if EnemyDistance > 0 && EnemyDistance < 25 then
		self.MeleeAttackDistance = 25
		self.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1}
		self.MeleeAttackAngleRadius = 70 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
		self.MeleeAttackDamageAngleRadius = 70 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
		self.MeleeAttackDamageDistance = 60
		self.NextAnyAttackTime_Melee = 1.4 -- How much time until it can use any attack again? | Counted in Seconds
		self.TimeUntilMeleeAttackDamage = false // 1.7 -- This counted in seconds | This calculates the time until it hits something
		self.MeleeAttackDamage = math.Rand(10, 25)
		self.MeleeAttackDamageType = DMG_SLASH
		self:EmitSound("npc/ghoulferal/feralghoul_attack0"..math.random(1,4)..".mp3", 80, 100, 1)
	end
	
	if EnemyDistance > 90 && EnemyDistance < 150 then
		self.MeleeAttackDistance = 150
		self.AnimTbl_MeleeAttack = {"H2hattackforwardpower"}
		self.MeleeAttackAngleRadius = 70 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
		self.MeleeAttackDamageAngleRadius = 70 -- What is the damage angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
		self.MeleeAttackDamageDistance = 80
		self.NextAnyAttackTime_Melee = 1.4 -- How much time until it can use any attack again? | Counted in Seconds
		self.TimeUntilMeleeAttackDamage = false // 1.7 -- This counted in seconds | This calculates the time until it hits something
		self.MeleeAttackDamage = math.Rand(20, 35)
		self.MeleeAttackDamageType = DMG_SLASH
		self:EmitSound("npc/ghoulferal/feralghoul_attack0"..math.random(1,4)..".mp3", 80, 100, 1)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key,activator,caller,data)
	if key == "event_emit FootLeft" then
		self:EmitSound("npc/ghoulferal/foot/feralghoul_foot_l0"..math.random(1,2)..".mp3", 70, 100, 1)
		
	elseif key == "event_emit FootRight" then
		self:EmitSound("npc/ghoulferal/foot/feralghoul_foot_r0"..math.random(1,2)..".mp3", 70, 100, 1)
	
	elseif key == "event_emit FootRunLeft" then
		self:EmitSound("npc/ghoulferal/foot/feralghoul_foot_run_l0"..math.random(1,2)..".mp3", 70, 100, 1)
		
	elseif key == "event_emit FootRunRight" then
		self:EmitSound("npc/ghoulferal/foot/feralghoul_foot_run_r0"..math.random(1,2)..".mp3", 70, 100, 1)
	
	elseif key == "event_mattack leftA" then	
		self:MeleeAttackCode()
		self:EmitSound("npc/ghoulferal/feralghoul_swing0"..math.random(1,5)..".mp3", 80, 100, 1)
		
	elseif key == "event_mattack leftB" then	
		self:MeleeAttackCode()
		self:EmitSound("npc/ghoulferal/feralghoul_swing0"..math.random(1,5)..".mp3", 80, 100, 1)
		
	elseif key == "event_mattack leftC" then	
		self:MeleeAttackCode()
		self:EmitSound("npc/ghoulferal/feralghoul_swing0"..math.random(1,5)..".mp3", 80, 100, 1)
		
	elseif key == "event_mattack rightA" then	
		self:MeleeAttackCode()
		self:EmitSound("npc/ghoulferal/feralghoul_swing0"..math.random(1,5)..".mp3", 80, 100, 1)
		
	elseif key == "event_mattack rightB" then	
		self:MeleeAttackCode()
		self:EmitSound("npc/ghoulferal/feralghoul_swing0"..math.random(1,5)..".mp3", 80, 100, 1)
		
	elseif key == "event_mattack rightC" then	
		self:MeleeAttackCode()
		self:EmitSound("npc/ghoulferal/feralghoul_swing0"..math.random(1,5)..".mp3", 80, 100, 1)
		
	elseif key == "event_mattack leftpower" then	
		self:MeleeAttackCode()
		self:EmitSound("npc/ghoulferal/feralghoul_swing0"..math.random(1,5)..".mp3", 80, 100, 1)
	
	elseif key == "event_mattack rightpower" then	
		self:MeleeAttackCode()
		self:EmitSound("npc/ghoulferal/feralghoul_swing0"..math.random(1,5)..".mp3", 80, 100, 1)
	
	elseif key == "event_mattack forwardpower" then
		self:MeleeAttackCode()
		self:EmitSound("npc/ghoulferal/feralghoul_swing0"..math.random(1,5)..".mp3", 80, 100, 1)		
	end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2015 by Mayhem, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/