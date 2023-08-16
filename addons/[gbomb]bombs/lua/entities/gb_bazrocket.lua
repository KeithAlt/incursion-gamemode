AddCSLuaFile()

DEFINE_BASECLASS( "gb_base_rocket" )

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Bazooka Rocket"
ENT.Author			                 =  "Chappi"
ENT.Contact			                 =  "chappi555@gmail.com"
ENT.Category                         =  "Gbombs"

ENT.Model                            =  "models/chappi/baz_rocket.mdl"
ENT.RocketTrail                      =  "rpg_trail"
ENT.RocketBurnoutTrail               =  "nebel_trail_burnout"
ENT.Effect                           =  "frag_explosion"
ENT.EffectAir                        =  "frag_explosion_air"
ENT.EffectWater                      =  "water_small" 
ENT.ExplosionSound                   =  "BaseExplosionEffect.Sound"         
ENT.StartSound                       =  "weapons/rpg/rocketfire1.wav"                        
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"  
ENT.EngineSound                      =  "Missile.Ignite"  

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.UseRandomSounds                  =  false
ENT.SmartLaunch                      =  true  
ENT.Timed                            =  false 

ENT.ExplosionDamage                  =  65
ENT.ExplosionRadius                  =  200            
ENT.PhysForce                        =  240             
ENT.SpecialRadius                    =  45           
ENT.MaxIgnitionTime                  =  0           
ENT.Life                             =  20            
ENT.MaxDelay                         =  0           
ENT.TraceLength                      =  100           
ENT.ImpactSpeed                      =  100      
ENT.Mass                             =  15
ENT.EnginePower                      =  200
ENT.FuelBurnoutTime                  =  2           
ENT.IgnitionDelay                    =  0            
ENT.ArmDelay                         =  0.1
ENT.RotationalForce                  =  170                               
ENT.ForceOrientation                 =  "NORMAL"
ENT.Timer                            =  0

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
	 ent:SetVar("SOUND", "weapons/explode4.wav")
	 ent:SetVar("Shocktime",1)
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



function ENT:Use( activator, caller )
	if !activator:KeyDown( IN_RELOAD ) then
	
		if(self.Exploded) then return end
		if(self.Dumb) then return end
		if(GetConVar("gb_easyuse"):GetInt() >= 1) then
			 if(self:IsValid()) then
				 if (!self.Exploded) and (!self.Burnt) and (!self.Fired) then
					 if (activator:IsPlayer()) then
						 self:EmitSound(self.ActivationSound)
						 self:Launch()
					 end
				 end
			 end
		end
	else
		activator:EmitSound("items/ammo_pickup.wav", 60, 100)
		activator:SetNWInt("ammo_bazrocket", activator:GetNWInt("ammo_bazrocket") + 1)
		
		if !activator:HasWeapon( "weapon_gb_bazrocket" ) then
			activator:Give("weapon_gb_bazrocket")
		end
		self:Remove()
		
	end
end


function ENT:Think()
     if(self.Burnt) then return end
     if(!self.Ignition) then return end -- if there wasn't ignition, we won't fly
	 if(self.Exploded) then return end -- if we exploded then what the fuck are we doing here
	 if(!self:IsValid()) then return end -- if we aren't good then something fucked up
	 local phys = self:GetPhysicsObject()  
	 local thrustpos = self:GetPos()
	 if(self.ForceOrientation == "RIGHT") then
	     phys:AddVelocity(self:GetRight() * self.EnginePower) -- Continuous engine impulse
	 elseif(self.ForceOrientation == "LEFT") then
	     phys:AddVelocity(self:GetRight() * -self.EnginePower) -- Continuous engine impulse
	 elseif(self.ForceOrientation == "UP") then
	     phys:AddVelocity(self:GetUp() * self.EnginePower) -- Continuous engine impulse
	 elseif(self.ForceOrientation == "DOWN") then 
	     phys:AddVelocity(self:GetUp() * -self.EnginePower) -- Continuous engine impulse
	 elseif(self.ForceOrientation == "INV") then
	     phys:AddVelocity(self:GetForward() * -self.EnginePower) -- Continuous engine impulse
	 else
		if (self.entity_Target == nil or self.entity_Target:IsValid() == false ) then 
			phys:AddVelocity(self:GetForward() * self.EnginePower) -- Continuous engine impulse
		end
	 end
	 if (self.Armed)   then
		
        phys:AddAngleVelocity(Vector(self.RotationalForce,0,0)) -- Rotational force
	 end
	 
	 if self.entity_Target != nil then
		 if self.entity_Target:IsValid() == true then
			local phys = self:GetPhysicsObject()
			local ang = (self.entity_Target:GetPos()-self:GetPos()):Angle()
			self:SetAngles( ang)
			
			phys:SetVelocity(self:GetForward() * self.EnginePower * 5000)
			
		
		 end
	 end
	 self:NextThink(CurTime() + 0.01)
	 return true
end



