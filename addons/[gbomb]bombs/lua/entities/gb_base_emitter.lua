AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

local damagesound                    =  "weapons/rpg/shotdown.wav"

ENT.Spawnable		            	 =  false         
ENT.AdminSpawnable		             =  false        

ENT.PrintName		                 =  "Name"        
ENT.Author			                 =  "Chappi"      
ENT.Contact			                 =  "Add me on steam fagit" 
ENT.Category                         =  ""            

ENT.Model                            =  ""            
ENT.Effect                           =  ""                    
ENT.ExplosionSound                   =  ""            
ENT.ArmSound                         =  ""            
ENT.ActivationSound                  =  ""            

ENT.Timed                            =  false   
            
ENT.Life                             =  0          
ENT.MaxDelay                         =  0                    
ENT.ImpactSpeed                      =  0          
ENT.Mass                             =  0                      
ENT.ArmDelay                         =  0             
ENT.EmitTime                         =  0            
ENT.Timer                            =  0

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

function ENT:Initialize()
 if (SERVER) then
     self:SetModel(self.Model)
	 self:PhysicsInit( SOLID_VPHYSICS )
	 self:SetSolid( SOLID_VPHYSICS )
	 self:SetMoveType( MOVETYPE_VPHYSICS )
	 self:SetUseType( ONOFF_USE ) -- doesen't fucking work

	 local phys = self:GetPhysicsObject()
	 
	 if (phys:IsValid()) then
		 phys:SetMass(self.Mass)
		 phys:Wake()
     end
	 
	 local skincount = self:SkinCount()
	 
	 if (skincount > 0) then
	     self:SetSkin(math.random(0,skincount))
	 end

	 self.Armed    = false
	 self.Exploded = false
	 self.Used     = false
	 self.Arming   = false
	 
	  if !(WireAddon == nil) then self.Inputs = Wire_CreateInputs(self, { "Arm" }) end
	 
	end
end

function ENT:TriggerInput(iname, value)
     if (!self:IsValid()) then return end
	 if (iname == "Arm") then
         if (value >= 1) then
             if (!self.Exploded and !self.Armed and !self.Arming) then
			     self:EmitSound(self.ActivationSound)
                 self:Arm()
             end 
         end
     end		 
end 

function ENT:Explode()
     if !self.Exploded then return end
	 local pos = self:LocalToWorld(self:OBBCenter())
	
	 sound.Play(self.ExplosionSound, pos, 160, 130,1)
	 ParticleEffectAttach(self.Effect,PATTACH_ABSORIGIN_FOLLOW,self,0)
	 timer.Simple(self.EmitTime, function()
		 if !self:IsValid() then return end 
	     self:Remove()
     end)
end

function ENT:OnTakeDamage(dmginfo)
     if self.Exploded then return end
	 if (self.Life <= 0) then return end
	 if !self:IsValid() then return end
	 
     self:TakePhysicsDamage(dmginfo)
	 local phys = self:GetPhysicsObject()
	 
	 if(GetConVar("gb_fragility"):GetInt() >= 1) then
	     if(!self.Armed and !self.Arming and !self.Exploded and !self.Used) then
	         self:Arm()
	     end
	 end
end

function ENT:PhysicsCollide( data, physobj )
     if(self.Exploded) then return end
     if(!self:IsValid()) then return end
	 if(self.Life <= 0) then return end
	 if(GetConVar("gb_fragility"):GetInt() >= 1) then
	     if(data.Speed > self.ImpactSpeed) then
	 	     if(!self.Armed and !self.Arming) then
		         self:EmitSound(damagesound)
	             self:Arm()
	         end
		 end
	 end
end

function ENT:Arm()
     if(!self:IsValid()) then return end
	 if(self.Exploded) then return end
	 if(self.Armed) then return end
	 self.Arming = true
	 self.Used = true
	 timer.Simple(self.ArmDelay, function()
	     if !self:IsValid() then return end 
	     self.Armed = true
		 self.Arming = false
		 self:EmitSound(self.ArmSound)
		 if(self.Timed) then 
		     timer.Simple(self.Timer,function()
		         if !self:IsValid() then return end
		         timer.Simple(math.Rand(0,self.MaxDelay),function()
		             if !self:IsValid() then return end 
			         self.Exploded = true
			         self:Explode()
			     end)
	         end)
	     end
     end)
end

function ENT:Use( activator, caller )
     if(self.Exploded) then return end
     if(self:IsValid()) then
	     if(GetConVar("gb_easyuse"):GetInt() >= 1) then
	         if(!self.Armed) then
		         if(!self.Exploded) and (!self.Used) then
		             if(activator:IsPlayer()) then
                         self:EmitSound(self.ActivationSound)
                         self:Arm()
		             end
	             end
             end
         end
	 end
end

function ENT:OnRemove()
	 self:StopParticles()
end

if ( CLIENT ) then
     function ENT:Draw()
         self:DrawModel()
		 if !(WireAddon == nil) then Wire_Render(self.Entity) end
     end
end