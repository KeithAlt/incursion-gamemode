AddCSLuaFile()

DEFINE_BASECLASS( "gb_base_emitter" )

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "M18 GREEN"
ENT.Author			                 =  "Chappi"
ENT.Contact			                 =  "chappi555@gmail.com"
ENT.Category                         =  "Gbombs"

ENT.Model                            =  "models/chappi/m18.mdl"        
ENT.Effect                           =  "M18_GREEN"
ENT.ExplosionSound                   =  "weapons/smokegrenade/sg_explode.wav"          
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "weapons/pinpull.wav" 

ENT.Timed                            =  true

ENT.Life                             =  2            
ENT.MaxDelay                         =  1       
ENT.ImpactSpeed                      =  250           
ENT.Mass                             =  5
ENT.ArmDelay                         =  2             
ENT.EmitTime                         =  20
ENT.Timer                            =  1

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
	 self:SetSkin(1)
	 self.Armed    = true
	 self.Exploded = false
	 self.Used     = false
	 self.Arming   = false
	 if !(WireAddon == nil) then self.Inputs   = Wire_CreateInputs(self, { "Arm" }) end
	end
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