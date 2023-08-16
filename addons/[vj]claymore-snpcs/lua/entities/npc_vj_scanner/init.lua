AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2015 by drvj, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/headcrab.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 220
ENT.SightDistance = 10000
ENT.MoveType = MOVETYPE_STEP
ENT.HullType = HULL_TINY
ENT.SightAngle = 180 
ENT.FindEnemy_UseSphere = true
ENT.FindEnemy_CanSeeThroughWalls = true
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_COMBINE"}
ENT.BloodColor = ""
ENT.Immune_Dissolve = true -- Immune to Dissolving | Example: Combine Ball
ENT.Immune_AcidPoisonRadiation = true -- Immune to Acid, Poison and Radiation
ENT.Immune_Electricity = true -- Immune to Electrical
ENT.Immune_Physics = true -- Immune to Physics
ENT.Immune_Melee = true
ENT.RunAwayOnUnknownDamage = false
ENT.HasMeleeAttack = false
ENT.MeleeAttackDamageType = DMG_SLASH 
ENT.HasBloodPool = false -- Does it have a blood pool?
ENT.DeathAnimationTime = 3.3
ENT.HasRangeAttack = false 
ENT.HasDeathRagdoll = false
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play

-----custom
----------------------------------------
function ENT:CustomOnThink()
if !IsValid(self.man) then
self:TakeDamage(999999999999999,self,self) 
end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnKilled(dmginfo,hitgroup) 
ParticleEffect("explosion_turret_break",self:GetPos(),Angle(0,0,0),nil)
util.VJ_SphereDamage(self,self,self:GetPos(),220,math.random(26,37),DMG_BLAST,true,true)
end
function ENT:CustomOnThink_AIEnabled()
if self:GetEnemy() != nil then
if self:GetPos():Distance(self:GetEnemy():GetPos()) < 160 then
self:StopMoving()
end
end
end
-------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
ParticleEffectAttach("super_hover",PATTACH_POINT_FOLLOW,self,0)
self:SetMaterial("models/effects/vol_light001.mdl")
self:SetNoDraw(true)
self.man = ents.Create("npc_turret_floor")
self.man:SetPos(self:GetPos() + self:GetUp()*8)
self.man:SetAngles(self:GetAngles())
self.man:Spawn()
self.man:SetModelScale(0.2)
self.man:Activate()
self.man:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
self.man:SetParent(self)
self.man:SetOwner(self)
self:DeleteOnRemove(self.man)

self.man3 = ents.Create("prop_physics")
self.man3:SetModel("models/props_combine/combine_mine01.mdl")
self.man3:SetPos(self:GetPos() + self:GetUp()*8)
self.man3:SetAngles(self:GetAngles())
self.man3:Spawn()
self.man3:SetModelScale(0.8)
self.man3:Activate()
self.man3:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
self.man3:SetParent(self)
self.man3:SetOwner(self)
self:DeleteOnRemove(self.man3)
self:SetCollisionBounds(Vector(20, 20, 80), Vector(-20, -20, 0))

timer.Simple(math.random(57,78),function() if IsValid(self) then
    self:Remove()
	ParticleEffect("explosion_turret_break",self:GetPos(),Angle(0,0,0),nil)
	util.VJ_SphereDamage(self,self,self:GetPos(),220,math.random(26,37),DMG_BLAST,true,true)
	end end)
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2015 by drvj, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/