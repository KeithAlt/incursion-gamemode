AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2017 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/adi/courser/courser_01.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 3500
ENT.HullType = HULL_HUMAN
ENT.VJ_IsHugeMonster = true
ENT.FindEnemy_UseSphere = true
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_COMBINE"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Red" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.MeleeAttackDamage = math.random(30,44)
ENT.Immune_Dissolve = true -- Immune to Dissolving | Example: Combine Ball
ENT.Immune_AcidPoisonRadiation = true -- Immune to Acid, Poison and Radiation
ENT.Immune_Electricity = true -- Immune to Electrical
ENT.Immune_Physics = true -- Immune to Physics
ENT.Immune_Blast = true
ENT.PlayerFriendly = true -- Makes the SNPC friendly to the player and HL2 Resistance
ENT.FollowPlayer = true -- Should the SNPC follow the player when the player presses a certain key?
ENT.BecomeEnemyToPlayerLevel = 1
ENT.NextThrowGrenadeTime1 = 10 -- Time until it runs the throw grenade code again | The first # in math.random
ENT.NextThrowGrenadeTime2 = 18 -- Time until it runs the throw grenade code again | The second # in math.random
ENT.ThrowGrenadeChance = 1 -- Chance that it will throw the grenade | Set to 1 to throw all the time
ENT.FootStepTimeRun = 0.4 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = 0.5 -- Next foot step sound when it is walking
ENT.HasGrenadeAttack = true -- Should the SNPC have a grenade attack?
ENT.HasOnPlayerSight = true -- Should do something when it sees the enemy? Example: Play a sound
ENT.OnPlayerSightDistance = 2000 -- How close should the player be until it runs the code?
ENT.OnPlayerSightDispositionLevel = 2 -- 0 = Run it every time | 1 = Run it only when friendly to player | 2 = Run it only when enemy to player
ENT.HasSoundTrack = true
	-- ====== Flinching Code ====== --
ENT.CanFlinch = 1 -- 0 = Don't flinch | 1 = Flinch at any damagFe | 2 = Flinch only from certain damages
ENT.AnimTbl_Flinch = {ACT_FLINCH_PHYSICS} -- If it uses normal based animation, use this
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_SoundTrack = {""}

ENT.OnPlayerSightSoundChance = 2

-- Custom
ENT.SARY = false
ENT.SARY2 = false
ENT.att = false
ENT.att1 = false
ENT.att2 = false
ENT.SoundTbl_Alert = {"cuszsda/overwatchtarget1sterilized.wav","cuszsda/overwatchtargetcontained.wav"}
ENT.SoundTbl_FootStep = {"cuszsda/gear1.wav","cuszsda/gear2.wav","cuszsda/gear3.wav","cuszsda/gear4.wav","cuszsda/gear5.wav","cuszsda/gear6.wav"}
ENT.SoundTbl_Pain = {"cuszsda/pain1.wav","cuszsda/pain2.wav","cuszsda/pain3.wav"}
ENT.SoundTbl_Death = {"cuszsda/die1.wav","cuszsda/die2.wav","cuszsda/die3.wav"}
ENT.AlertSoundLevel = 90
ENT.PainSoundLevel = 90
ENT.DeathSoundLevel = 90
ENT.FootStepSoundLevel = 70
--------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	if SERVER then -- PARTICLE EFFECT EVENTS (By Keith)
		ParticleEffect("_sai_wormhole", self:GetPos(), Angle(-90), self)
		ParticleEffect("mr_cop_anomaly_electra_a", self:GetPos(), self:GetAngles(), self)
		ParticleEffectAttach("super_shlrd",PATTACH_POINT_FOLLOW,self,0)
		self:EmitSound("npc/scanner/cbot_energyexplosion1.wav")
		util.ScreenShake(self:GetPos(), 100, 100, 2, 100)
		timer.Simple(1, function()
			self:StopParticles()
		end)
	end
end



function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo)

if self.SARY2 == true then

	dmginfo:ScaleDamage(0.41)
	end
	end
	----------------------------------------
function ENT:CustomOnThink_AIEnabled()
if self:GetEnemy() != nil then
if self.SARY == false then
self.SARY = true
self.SARY2 = true
VJ_EmitSound(self,"cuszsda/sp.wav",100,100)
VJ_EmitSound(self,"cuszsda/sp.wav",100,100)
VJ_EmitSound(self,"cuszsda/sp.wav",100,100)
ParticleEffectAttach("super_shlrd",PATTACH_POINT_FOLLOW,self,0)
timer.Simple(math.random(7,11),function() if IsValid(self) then
self.SARY2 = false
VJ_EmitSound(self,"cuszsda/rea.wav",100,100)
VJ_EmitSound(self,"cuszsda/rea.wav",100,100)
VJ_EmitSound(self,"cuszsda/rea.wav",100,100)
self:StopParticles()
ParticleEffectAttach("super_broc",PATTACH_POINT_FOLLOW,self,0)
timer.Simple(0.1,function() if IsValid(self) then
ParticleEffectAttach("combne_las",PATTACH_POINT_FOLLOW,self,3) end end)
 timer.Simple(math.random(13,22),function() if IsValid(self) then self.SARY = false end end) end end)
end
end
if self:GetEnemy() != nil then
if self:Health() <= 3200 then
if self:GetPos():Distance(self:GetEnemy():GetPos()) < 2300 then
if self.att == false then
if !IsValid(self.manha1) && !IsValid(self.manha2) && !IsValid(self.manha3) && !IsValid(self.manha4) && !IsValid(self.manha5) && !IsValid(self.manha6) then
self.att = true
self.att1 = true
self:VJ_ACT_PLAYACTIVITY("signal_advance",true,3.4,false)
timer.Simple(0.7,function() if IsValid(self) then

self.manha1 = ents.Create("npc_manhack")
self.manha1:SetPos(self:GetPos() + self:GetUp()*math.random(30,50) +self:GetRight()*math.random(-50,50))
self.manha1:SetAngles(self:GetAngles())
self.manha1:Spawn()
self.manha1:SetModelScale(0.4)
self.manha1:Activate()
self.manha1:SetOwner(self)
self:DeleteOnRemove(self.manha1)
self.manha2 = ents.Create("npc_manhack")
self.manha2:SetPos(self:GetPos() + self:GetUp()*math.random(30,50) +self:GetRight()*math.random(-50,50))
self.manha2:SetAngles(self:GetAngles())
self.manha2:Spawn()
self.manha2:SetModelScale(0.4)
self.manha2:Activate()
self.manha2:SetOwner(self)
self:DeleteOnRemove(self.manha2)
self.manha3 = ents.Create("npc_manhack")
self.manha3:SetPos(self:GetPos() + self:GetUp()*math.random(30,50) +self:GetRight()*math.random(-50,50))
self.manha3:SetAngles(self:GetAngles())
self.manha3:Spawn()
self.manha3:SetModelScale(0.4)
self.manha3:Activate()
self.manha3:SetOwner(self)
self:DeleteOnRemove(self.manha3)
timer.Simple(0.01,function() if IsValid(self) then
self.manhaa1 = ents.Create("npc_vj_flyer")
self.manhaa1:SetPos(self.manha1:GetPos())
self.manhaa1:SetAngles(self:GetAngles())
self.manhaa1:Spawn()
self.manhaa1:SetParent(self.manha1)
self.manhaa1:SetModelScale(0.1)
self.manhaa1:Activate()
self.manhaa1:SetOwner(self)
self.manhas1 = ents.Create("npc_vj_flyer")
self.manhas1:SetPos(self.manha2:GetPos())
self.manhas1:SetAngles(self:GetAngles())
self.manhas1:Spawn()
self.manhas1:SetParent(self.manha2)
self.manhas1:SetModelScale(0.1)
self.manhas1:Activate()
self.manhas1:SetOwner(self)
self.manhad1 = ents.Create("npc_vj_flyer")
self.manhad1:SetPos(self.manha3:GetPos())
self.manhad1:SetAngles(self:GetAngles())
self.manhad1:Spawn()
self.manhad1:SetParent(self.manha3)
self.manhad1:SetModelScale(0.1)
self.manhad1:Activate()
self.manhad1:SetOwner(self)

self.manhaf1 = ents.Create("npc_vj_flyer")
self.manhaf1:SetPos(self.manha4:GetPos())
self.manhaf1:SetAngles(self:GetAngles())
self.manhaf1:Spawn()
self.manhaf1:SetParent(self.manha4)
self.manhaf1:SetModelScale(0.1)
self.manhaf1:Activate()
self.manhaf1:SetOwner(self)

self.manhaq1 = ents.Create("npc_vj_flyer")
self.manhaq1:SetPos(self.manha5:GetPos())
self.manhaq1:SetAngles(self:GetAngles())
self.manhaq1:Spawn()
self.manhaq1:SetParent(self.manha5)
self.manhaq1:SetModelScale(0.1)
self.manhaq1:Activate()
self.manhaq1:SetOwner(self)

self.manhae1 = ents.Create("npc_vj_flyer")
self.manhae1:SetPos(self.manha6:GetPos())
self.manhae1:SetAngles(self:GetAngles())
self.manhae1:Spawn()
self.manhae1:SetParent(self.manha6)
self.manhae1:SetModelScale(0.1)
self.manhae1:Activate()
self.manhae1:SetOwner(self) end end)

self.manha4 = ents.Create("npc_manhack")
self.manha4:SetPos(self:GetPos() + self:GetUp()*math.random(30,50) +self:GetRight()*math.random(-50,50))
self.manha4:SetAngles(self:GetAngles())
self.manha4:Spawn()
self.manha4:SetModelScale(0.4)
self.manha4:Activate()
self.manha4:SetOwner(self)
self:DeleteOnRemove(self.manha4)
self.manha5 = ents.Create("npc_manhack")
self.manha5:SetPos(self:GetPos() + self:GetUp()*math.random(30,50) +self:GetRight()*math.random(-50,50))
self.manha5:SetAngles(self:GetAngles())
self.manha5:Spawn()
self.manha5:SetModelScale(0.4)
self.manha5:Activate()
self.manha5:SetOwner(self)
self:DeleteOnRemove(self.manha5)
self.manha6 = ents.Create("npc_manhack")
self.manha6:SetPos(self:GetPos() + self:GetUp()*math.random(30,50) +self:GetRight()*math.random(-50,50))
self.manha6:SetAngles(self:GetAngles())
self.manha6:Spawn()
self.manha6:SetModelScale(0.4)
self.manha6:Activate()
self.manha6:SetOwner(self)
self:DeleteOnRemove(self.manha6)
 end end)
 timer.Simple(1.3,function() if IsValid(self) then self.att1 = false end end)
timer.Simple(math.random(15,26),function() if IsValid(self) then self.att = false end end)
end
end
end
end
end
if self:GetEnemy() != nil then
if self:Health() <= 2400 then
if self:GetPos():Distance(self:GetEnemy():GetPos()) < 3000 then
if self.att1 == false then
if !IsValid(self.scanner1) && !IsValid(self.scanner2) then
self.att1 = true
self:VJ_ACT_PLAYACTIVITY("grenPlace",true,3.3,false)
timer.Simple(0.5,function() if IsValid(self) then
self.scanner1 = ents.Create("npc_vj_scanner")
self.scanner1:SetPos(self:GetPos())
self.scanner1:SetAngles(self:GetAngles())
self.scanner1:Spawn()
self.scanner1:Activate()
self.scanner1:SetOwner(self)
self:DeleteOnRemove(self.scanner1) end end)
timer.Simple(0.7,function() if IsValid(self) then
self.scanner2 = ents.Create("npc_vj_scanner")
self.scanner2:SetPos(self:GetPos(Vector (10, 10, 10)))
self.scanner2:SetAngles(self:GetAngles())
self.scanner2:Spawn()
self.scanner2:Activate()
self.scanner2:SetOwner(self)
self:DeleteOnRemove(self.scanner2)
end end )
timer.Simple(math.random(19,25),function() if IsValid(self) then self.att1 = false end end)
end
end
end
end
end
if self:GetEnemy() != nil then
if self:Health() <= 2000 then
if self.att2 == false then
local enmy = self:GetEnemy()
self.att2 = true
self.att = true
self.att1 = true
local Sky = self:GetEnemy()
local pos = Sky:LocalToWorld(Vector(1,1,0))
self:VJ_ACT_PLAYACTIVITY("signal_advance",true,3.4,false)
timer.Simple(0.7,function() if IsValid(self) && IsValid(enmy) then
VJ_EmitSound(self,"cuszsda/spl.wav",120,120)
VJ_EmitSound(self,"cuszsda/spl.wav",120,120)
VJ_EmitSound(self,"cuszsda/spl.wav",120,120)
local effectsuper = ents.Create("info_particle_system")
		effectsuper:SetKeyValue("effect_name","super_turret")
		effectsuper:SetPos(pos)
		effectsuper:Spawn()
		effectsuper:Fire()
		effectsuper:Activate()
		effectsuper:Fire("Start","",0)
		effectsuper:Fire("Kill","",2.6)

		local effectsuper6 = ents.Create("info_particle_system")
		effectsuper6:SetKeyValue("effect_name","explosion_huge_d")
		effectsuper6:SetPos(pos)
		effectsuper6:Spawn()
		effectsuper6:Fire()
		effectsuper6:Activate()
		effectsuper6:Fire("Start","",0)
		effectsuper6:Fire("Kill","",1)





local effectsuper2 = ents.Create("info_particle_system")
		effectsuper2:SetKeyValue("effect_name","super_exp")
		effectsuper2:SetPos(pos)
		effectsuper2:Spawn()
		effectsuper2:Fire()
		effectsuper2:Activate()
		effectsuper2:Fire("Start","",2.5)
		effectsuper2:Fire("Kill","",2.7)

		local effectsuper23 = ents.Create("info_particle_system")
		effectsuper23:SetKeyValue("effect_name","explosion_huge_d")
		effectsuper23:SetPos(pos)
		effectsuper23:Spawn()
		effectsuper23:Fire()
		effectsuper23:Activate()
		effectsuper23:Fire("Start","",2.5)
		effectsuper23:Fire("Kill","",2.7)

		local effectsuper24 = ents.Create("info_particle_system")
		effectsuper24:SetKeyValue("effect_name","explosion_huge_d")
		effectsuper24:SetPos(pos)
		effectsuper24:Spawn()
		effectsuper24:Fire()
		effectsuper24:Activate()
		effectsuper24:Fire("Start","",2.5)
		effectsuper24:Fire("Kill","",2.7)
timer.Simple(2.6,function() if IsValid(self) && IsValid(enmy) then
VJ_EmitSound(self,"cuszsda/explo.wav",140,140)
VJ_EmitSound(self,"cuszsda/explo.wav",140,140)
util.VJ_SphereDamage(self,self,effectsuper2:GetPos(),650,math.random(69,80),DMG_BLAST,true,true)
end end)
		end
		end)
		timer.Simple(3.3,function() if IsValid(self) then
		self.att = false
self.att1 = false
 timer.Simple(math.random(20,28),function() if IsValid(self) then self.att2 = false end end)
 end end)
		end
		end
		end
end
---------------------------------------------------------------------------------------------------------------------------------------------

/*-----------------------------------------------
	*** Copyright (c) 2012-2017 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
