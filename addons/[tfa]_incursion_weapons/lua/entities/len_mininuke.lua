AddCSLuaFile()
DEFINE_BASECLASS( "gb_base_adv" )

local ExploSnds = {}
ExploSnds[1]                         =  "ambient/explosions/explode_1.wav"
ExploSnds[2]                         =  "ambient/explosions/explode_2.wav"
ExploSnds[3]                         =  "ambient/explosions/explode_3.wav"
ExploSnds[4]                         =  "ambient/explosions/explode_4.wav"
ExploSnds[5]                         =  "ambient/explosions/explode_5.wav"
ExploSnds[6]                         =  "npc/env_headcrabcanister/explosion.wav"

ENT.Spawnable		            	 =  true
ENT.AdminSpawnable		             =  true

ENT.PrintName		                 =  "Mini Nuke"
ENT.Author			                 =  "Chappi"
ENT.Contact		                     =  "chappi555@gmail.com"
ENT.Category                         =  "Gbombs"

ENT.Model                            =  "models/Chappi/mininuq.mdl"
ENT.Effect                           =  "nqb_explo"
ENT.EffectAir                        =  "nqb_explo_air"
ENT.EffectWater                      =  "water_medium"
ENT.ExplosionSound                   =  ""
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"
ENT.ActivationSound                  =  "buttons/button14.wav"
ENT.NBCEntity                        =  "gb_rad_mininuq"

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  true
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  true
ENT.UseRandomModels                  =  false
ENT.Timed                            =  true
ENT.Armed 							 =  true
ENT.IsNBC                            =  false

ENT.ExplosionDamage                  =  150000
ENT.PhysForce                        =  6000
ENT.ExplosionRadius                  =  700
ENT.SpecialRadius                    =  550
ENT.MaxIgnitionTime                  =  0.0001
ENT.Life                             =  0.0001
ENT.MaxDelay                         =  0.0001
ENT.TraceLength                      =  100
ENT.ImpactSpeed                      =  350
ENT.Mass                             =  70
ENT.ArmDelay                         =  0.0001
ENT.Timer                            =  0.0001

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

function ENT:ExploSound(pos)
	local ent = ents.Create("gb4_shockwave_sound_lowsh")
	ent:SetPos( pos )
	ent:Spawn()
	ent:Activate()
	ent:SetVar("GBOWNER", self.GBOWNER)
	ent:SetVar("MAX_RANGE",500000)
	ent:SetVar("SHOCKWAVE_INCREMENT",20000)
	ent:SetVar("DELAY",0.01)
	ent:SetVar("SOUND", "gbombs/nuke_init.wav")
	ent:SetVar("Shocktime",4)
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.GBOWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * 16 )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:PhysicsCollide( data, physobj )
	self.Exploded = true
	self:Explode()
end

function ENT:Explode()
	if !self.Exploded then return end

	local pos = self:GetPos()
	self:ExploSound(pos)

	local ent = ents.Create("gb4_shockwave_ent_instant")
	ent:SetPos( pos )
	ent:Spawn()
	ent:Activate()
	ent:SetVar("GBOWNER", self.GBOWNER)
	ent:SetVar("MAX_RANGE",self.ExplosionRadius)
	ent:SetVar("SHOCKWAVE_INCREMENT",self.ExplosionRadius)
	ent:SetVar("DELAY",0.01)


	for k, v in pairs(ents.FindInSphere(self:GetPos(), 550)) do
		util.BlastDamage(self, self, self:GetPos(), 550, 15000)
	end

	for k, v in pairs(ents.FindInSphere(self:GetPos(), 400)) do
		util.BlastDamage(self, self, self:GetPos(), 400, 15000)
	end

	if (self:WaterLevel() >= 1) then
		local trdata   = {}
		local trlength = Vector(0,0,9000)

		trdata.start   = pos
		trdata.endpos  = trdata.start + trlength
		trdata.filter  = self

		local tr = util.TraceLine(trdata)
		local trdat2   = {}
		trdat2.start   = tr.HitPos
		trdat2.endpos  = trdata.start - trlength
		trdat2.filter  = self
		trdat2.mask    = MASK_WATER + CONTENTS_TRANSLUCENT

		local tr2 = util.TraceLine(trdat2)

		if tr2.Hit then
			ParticleEffect(self.EffectWater, tr2.HitPos, Angle(0,0,0), nil)
		end

	else
		local tracedata    = {}
		tracedata.start    = pos
		tracedata.endpos   = tracedata.start - Vector(0, 0, self.TraceLength)
		tracedata.filter   = self.Entity

		local trace = util.TraceLine(tracedata)

		if trace.HitWorld then
			ParticleEffect(self.Effect,pos,Angle(0,0,0),nil)
		else
			ParticleEffect(self.EffectAir,pos,Angle(0,0,0),nil)
		end
	end

	if self.IsNBC then
		local nbc = ents.Create(self.NBCEntity)
		nbc:SetVar("GBOWNER",self.GBOWNER)
		nbc:SetPos(self:GetPos())
		nbc:Spawn()
		nbc:Activate()
	end

	self:Remove()
end
