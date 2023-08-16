AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "ai_translations.lua" )
SWEP.testtimer = false
include('shared.lua')
SWEP.IsCloaked              = false
SWEP.Weight				= 30		// Decides whether we should switch from/to this
SWEP.AutoSwitchTo			= true		// Auto switch to  we pick it up
SWEP.AutoSwitchFrom			= true		// Auto switch from  you pick up a better weapon
SWEP.timer = false
SWEP.NextFireTimer          = false
SWEP.FailedBlinkTimer       = false
SWEP.Phase=1

function SWEP:Initialize()

	self:SetWeaponHoldType("shotgun")
	 
	self:Proficiency()
	self.Weapon.Owner:SetKeyValue( "spawnflags", "256" )
	
			 
	hook.Add( "Think", self, self.onThink )
end

function SWEP:onThink()
	if !IsValid(self) or !IsValid(self.Owner) then return; end
	if self.Owner:GetNWBool("Stun") == true then return end
	self.Owner:ClearCondition(13)
	self.Owner:ClearCondition(17)
	self.Owner:ClearCondition(18)
	self.Owner:ClearCondition(20)
	self.Owner:ClearCondition(48)
	self.Owner:ClearCondition(42)
	self.Owner:ClearCondition(45)
	
	if self.Owner:GetEnemy() then
		if self.Owner:GetNWBool("MAGuardening") == true and self.Owner:GetPos():Distance( self.Owner:GetEnemy():GetPos() ) < 150 then
			self.Owner:SetNPCState(NPC_STATE_SCRIPT)
			self.Owner:SetSequence("walk_SMG1_Relaxed_all")
		end
	end
	
	if self.NextFireTimer == false and self.Owner:GetEnemy() then
		if self.Owner:GetEnemy():GetNWBool("MeleeArtAttacking") == true then
			if self.Owner:GetNWBool("Stun") == true then return end
			self.NextFireTimer = true
			timer.Simple( 0.2, function()
				local randomtimer = 1			
				timer.Simple(randomtimer, function()
					self.NextFireTimer = false
				end)
			end)
			self.Owner:SetNWBool("MAGuardening",true)
			print("guarding")
		end
		if self.Owner:GetEnemy():GetNWBool("MeleeArtAttacking") == false then
			self.NextFireTimer = false
			self.Owner:SetNWBool("MAGuardening",false)
			self.Owner:ExitScriptedSequence()
			self.Owner:SetNPCState(NPC_STATE_COMBAT)
			self:NextFire()
		end
	end
end

function SWEP:Stun()
	self.Owner:SetNWBool("MAGuardening",false)
	self.Owner:SetNWBool("Stun",true)
	print("stunned")
	self.Owner:SetNPCState(NPC_STATE_SCRIPT)
	self.Owner:SetSequence("PreSkewer")
	self.Owner:EmitSound("physics/flesh/flesh_strider_impact_bullet2.wav")
	local effectdata = EffectData() 
	effectdata:SetOrigin( self.Owner:GetPos() + Vector(0,0,50) ) 
	effectdata:SetNormal( self.Owner:GetPos():GetNormal() ) 
	effectdata:SetEntity( self.Owner ) 
	util.Effect( "stundeflection", effectdata )
	--[[self.Owner:ClearCondition(68)
	self.Owner:SetCondition(67)]]--
	timer.Simple( 1.5,function()
		if self:IsValid() then
			--[[self.Owner:SetCondition(68)
			self.Owner:ClearCondition(67)]]--
			self.Owner:SetNWBool("Stun",false)
			
			--[[local boom = -1500
			local shiftstraight = self.Owner:GetAngles():Forward()*boom
			shiftstraight.z = 100
			self.Owner:SetVelocity(shiftstraight)]]--
			self.Owner:ExitScriptedSequence()
			self.Owner:SetNPCState(NPC_STATE_ALERT)
			print("nostun")
		end
	end)
end

function SWEP:Stun2()
	self.Owner:SetNWBool("MAGuardening",false)
	self.Owner:SetNWBool("Stun",true)
	print("stunned")
	self.Owner:StopMoving()
	self.Owner:SetNPCState(NPC_STATE_SCRIPT)
	self.Owner:SetSequence("PreSkewer")
	self.Owner:EmitSound("physics/flesh/flesh_strider_impact_bullet2.wav")
	self.Owner:ClearCondition(68)
	self.Owner:SetCondition(67)
	timer.Simple( 1.5,function()
		if self:IsValid() then
			self.Owner:SetCondition(68)
			self.Owner:ClearCondition(67)
			self.Owner:SetNWBool("Stun",false)
			
			--[[local boom = -1500
			local shiftstraight = self.Owner:GetAngles():Forward()*boom
			shiftstraight.z = 100
			self.Owner:SetVelocity(shiftstraight)]]--
			self.Owner:ExitScriptedSequence()
			self.Owner:SetNPCState(NPC_STATE_ALERT)
			print("nostun")
		end
	end)
end

function SWEP:NextFire()
	if !self:IsValid() or !self.Owner:IsValid() then return; end
	if self.Owner:IsCurrentSchedule(SCHED_CHASE_ENEMY) then return end
	if self.Owner:GetNWBool("Stun") == true then return end
	if self.Owner:GetNWBool("MAGuardening") == true then return end
	if self.Owner:GetEnemy():GetNWBool("MAGuardening") == true then
		self.Owner:SetSchedule( SCHED_IDLE_STAND )
		self.Owner:SetNPCState(NPC_STATE_SCRIPT)
		self.Owner:SetSequence("shoot_shotgun")
		timer.Simple( 0.5, function()
			pos = self.Owner:GetShootPos()
			ang = self.Owner:GetAimVector()
				self.Owner:EmitSound("physics/body/body_medium_impact_soft1.wav")
					if SERVER and IsValid(self.Owner) then
							local slash = {}
							slash.start = pos
							slash.endpos = pos + (ang * 90)
							slash.filter = self.Owner
							slash.mins = Vector(-5, -5, 0)
							slash.maxs = Vector(5, 5, 5)
							local slashtrace = util.TraceHull(slash)
							if slashtrace.Hit then
								targ = slashtrace.Entity
								if targ:IsPlayer() or targ:IsNPC() then

									paininfo = DamageInfo()
									paininfo:SetDamage(2)
									paininfo:SetDamageType(DMG_SLASH)
									paininfo:SetAttacker(self.Owner)
									paininfo:SetInflictor(self.Weapon)
									local RandomForce = math.random(1000,20000)
									paininfo:SetDamageForce(slashtrace.Normal * RandomForce)
									if targ:IsPlayer() then
										self.Owner:EmitSound("physics/body/body_medium_impact_hard6.wav")
										if targ:GetNWBool("MAGuardening")==true then
											local enemywep=targ:GetActiveWeapon()
											targ:SetNWBool("MAGuardening",false)
											enemywep.NextStun = CurTime() + 1.5
											targ:ViewPunch( Angle( -20, 0, 0 ) )
											targ:EmitSound("physics/flesh/flesh_strider_impact_bullet2.wav")

										end
									end
									
									
									if SERVER then targ:TakeDamageInfo(paininfo) end
								end
							end
						end
					end)
					self.NextFireTimer = true
					self.Owner:StopMoving()
					local randomtimer = 1			
					timer.Simple(randomtimer, function()
						if self:IsValid() then
							self.Owner:SetNPCState(NPC_STATE_COMBAT)
							self.Owner:ExitScriptedSequence()
							self.NextFireTimer = false
						end
					end)
		
	return end
	self.NextFireTimer = true
	self:Chase_Enemy()
	
	local randomtimer = 1			
	timer.Simple(randomtimer, function()
	self.NextFireTimer = false
		end)
	end

	
	
function SWEP:Proficiency()
timer.Simple(0.5, function()
if !self:IsValid() or !self.Owner:IsValid() then return; end
 self.Owner:SetCurrentWeaponProficiency(4)
 self.Owner:CapabilitiesAdd( CAP_FRIENDLY_DMG_IMMUNE )
 self.Owner:CapabilitiesRemove( CAP_WEAPON_MELEE_ATTACK1 )
 self.Owner:CapabilitiesRemove( CAP_INNATE_MELEE_ATTACK1 )
end)
end

function SWEP:GetCapabilities()
	return bit.bor( CAP_WEAPON_MELEE_ATTACK1 )
end

AccessorFunc( SWEP, "fNPCMinBurst",                 "NPCMinBurst" )
AccessorFunc( SWEP, "fNPCMaxBurst",                 "NPCMaxBurst" )
AccessorFunc( SWEP, "fNPCFireRate",                 "NPCFireRate" )
AccessorFunc( SWEP, "fNPCMinRestTime",         "NPCMinRest" )
AccessorFunc( SWEP, "fNPCMaxRestTime",         "NPCMaxRest" )

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:Chase_Enemy()
	if !self:IsValid() or !self.Owner:IsValid() then return;end 	
	if self.Owner:GetEnemy():GetPos():Distance(self:GetPos()) > 70 then
		self.Owner:SetSchedule( SCHED_CHASE_ENEMY )
	end
	if self.CooldownTimer == false and self.Owner:GetEnemy():GetPos():Distance(self:GetPos()) <= 85 then
		self.Owner:SetSchedule( SCHED_MELEE_ATTACK1 )
		self:NPCShoot_Primary( ShootPos, ShootDir )
	end
end
			
function SWEP:NPCShoot_Primary( ShootPos, ShootDir )
	if !self:IsValid() or !self.Owner:IsValid() then return;end 
	if !self.Owner:GetEnemy() then return end
	self.CooldownTimer = true
	local seqtimer = 0.4
		if self.Owner:GetClass() == "npc_alyx" then
	seqtimer = 0.8
end

timer.Simple(seqtimer, function()
if !self:IsValid() or !self.Owner:IsValid() then return;end 
if self.Owner:IsCurrentSchedule( SCHED_MELEE_ATTACK1 ) then
	self:PrimaryAttack()
		end
self.CooldownTimer = false		
	end)
end