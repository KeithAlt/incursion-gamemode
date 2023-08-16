AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

util.PrecacheSound( "BaseExplosionEffect.Sound" ) 

--[[
This bomb base should be used for dumb entities. Those entities can be exploded only by damage.
They do not posses any inputs/outputs, cannot be armed nor used.
--]]

local ExploSnds = {}
ExploSnds[1]                         =  "BaseExplosionEffect.Sound"

local Models = {}
Models[1]                            =  "model"

local damagesound                    =  "weapons/rpg/shotdown.wav"

ENT.Spawnable		            	 =  false         
ENT.AdminSpawnable		             =  false         

ENT.PrintName		                 =  "Name"       
ENT.Author			                 =  "Chappi"     
ENT.Contact			                 =  "Add me on steam fagit" 
ENT.Category                         =  ""           

ENT.Model                            =  ""            
ENT.Effect                           =  ""            
ENT.EffectAir                        =  ""            
ENT.EffectWater                      =  ""           
ENT.ExplosionSound                   =  ""           
ENT.ParticleTrail                    =  ""
ENT.NBCEntity                        =  ""   

ENT.ShouldUnweld                     =  false        
ENT.ShouldIgnite                     =  false        
ENT.ShouldExplodeOnImpact            =  false        
ENT.Flamable                         =  false         
ENT.UseRandomSounds                  =  false             
ENT.UseRandomModels                  =  false
ENT.IsNBC                            =  false

ENT.ExplosionDamage                  =  0             
ENT.PhysForce                        =  0             
ENT.ExplosionRadius                  =  0             
ENT.SpecialRadius                    =  0             
ENT.MaxIgnitionTime                  =  5           
ENT.Life                             =  20            
ENT.MaxDelay                         =  2             
ENT.TraceLength                      =  500          
ENT.ImpactSpeed                      =  500          
ENT.Mass                             =  0                       

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

function ENT:Initialize(ply)
 if (SERVER) then
     self:LoadModel()
	 self:PhysicsInit( SOLID_VPHYSICS )
	 self:SetSolid( SOLID_VPHYSICS )
	 self:SetMoveType( MOVETYPE_VPHYSICS )
	 self:SetUseType( ONOFF_USE ) -- doesen't fucking work
	 local phys = self:GetPhysicsObject()
	 local skincount = self:SkinCount()
	 if (phys:IsValid()) then
		 phys:SetMass(self.Mass)
		 phys:Wake()
     end
	 if (skincount > 0) then
	     self:SetSkin(math.random(0,skincount))
	 end
	 self.Exploded = false
	end
end

function ENT:LoadModel()
     if self.UseRandomModels then
	     self:SetModel(table.Random(Models))
	 else
	     self:SetModel(self.Model)
	 end
end

function ENT:ExploSound(pos, ply)
	 local ent = ents.Create("gb4_shockwave_sound_lowsh")
	 ent:SetPos( pos ) 
	 ent:Spawn()
	 ent:Activate()
	 ent:SetVar("GBOWNER", self.GBOWNER)
	 ent:SetVar("MAX_RANGE",500000)
	 ent:SetVar("SHOCKWAVE_INCREMENT",20000)
	 ent:SetVar("DELAY",0.01)
	 ent:SetVar("SOUND", self.ExplosionSound)
	 ent:SetVar("Shocktime",1)
end

function ENT:Explode()
     if !self.Exploded then return end
	 local pos = self:LocalToWorld(self:OBBCenter())
	 self:ExploSound(pos)
	 
	 local ent = ents.Create("gb4_shockwave_ent_instant")
	 ent:SetPos( pos ) 
	 ent:Spawn()
	 ent:Activate()
	 ent:SetVar("GBOWNER", self.GBOWNER)
	 ent:SetVar("MAX_RANGE",self.ExplosionRadius)
	 ent:SetVar("SHOCKWAVE_INCREMENT",self.ExplosionRadius)
	 ent:SetVar("DELAY",0.01)
	
	 if(self:WaterLevel() >= 1) then
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

function ENT:OnTakeDamage(dmginfo)
     if self.Exploded then return end
     self:TakePhysicsDamage(dmginfo)
	 
     if (self.Life <= 0) then return end

	 if self:IsValid() then
	     self.Life = self.Life - dmginfo:GetDamage()
		 if (self.Life <= self.Life/2) and !self.Exploded and self.Flamable then
		     self:Ignite(self.MaxDelay,0)
		 end
		 if (self.Life <= 0) then 
		     timer.Simple(math.Rand(0,self.MaxDelay),function()
			     if !self:IsValid() then return end 
			     self.Exploded = true
			     self:Explode()
			 end)
	     end
	end
end

function ENT:PhysicsCollide( data, physobj )
     if(self.Exploded) then return end
     if(!self:IsValid()) then return end
	 if(self.Life <= 0) then return end

     if self.ShouldExplodeOnImpact then
	     if (data.Speed > self.ImpactSpeed ) then
			 self.Exploded = true
			 self:Explode()
		 end
	 end
end

function ENT:OnRemove()
	 self:StopParticles()
end

if ( CLIENT ) then
     function ENT:Draw()
         self:DrawModel()
     end
end