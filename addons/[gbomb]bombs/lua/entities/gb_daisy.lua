AddCSLuaFile()

DEFINE_BASECLASS( "gb_base_adv" )

ENT.Spawnable		            	 =  true
ENT.AdminSpawnable		             =  true

ENT.PrintName		                 =  "Dirty Bomb (Warhead)"
ENT.Author			                 =  "Claymore Gaming"
ENT.Category                         =  "Claymore Bombs"

ENT.Model                            =  "models/llama/megatonbomb.mdl"
ENT.Effect                           =  "daisy_explo"
ENT.EffectAir                        =  "daisy_explo_air"
ENT.EffectWater                      =  "water_huge"
ENT.ExplosionSound                   =  "gbombs/daisy/daisy_explo.wav"
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"
ENT.ActivationSound                  =  "buttons/button14.wav"

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.UseRandomModels                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  2000
ENT.PhysForce                        =  5000
ENT.ExplosionRadius                  =  3000
ENT.SpecialRadius                    =  3000
ENT.MaxIgnitionTime                  =  0
ENT.Life                             =  25
ENT.MaxDelay                         =  2
ENT.TraceLength                      =  200
ENT.ImpactSpeed                      =  350
ENT.Mass                             =  500
ENT.ArmDelay                         =  2
ENT.Timer                            =  0

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

function ENT:SpawnFunction( ply, tr )
     if ( !tr.Hit ) then return end
	 self.GBOWNER = ply
     local ent = ents.Create( self.ClassName )
	 ent:SetPhysicsAttacker(ply)
     ent:SetPos( tr.HitPos + tr.HitNormal * 16 )
	 ent:SetModelScale(0.25)
     ent:Spawn()
     ent:Activate()

     return ent
end

function ENT:ExploSound(pos)
	 local ent = ents.Create("gb4_shockwave_sound_lowsh")
	 ent:SetPos( pos )
	 ent:Spawn()
	 ent:Activate()
	 ent:SetVar("GBOWNER", self.GBOWNER)
	 ent:SetVar("MAX_RANGE",500000)
	 ent:SetVar("SHOCKWAVE_INCREMENT",20000)
	 ent:SetVar("DELAY",0.01)
	 ent:SetVar("SOUND", self.ExplosionSound)
	 ent:SetVar("Shocktime",5)
end

function ENT:Use( activator, caller )
     if(self.Exploded) then return end
     if(self:IsValid()) then
		 	 if self.Armed && activator:getSpecial("I") < 25 then
			  activator:ChatPrint("[ ! ]  You require Level 25 Intelligence to disarm this Warhead!")
		  elseif self.Armed && activator:getSpecial("I") >= 25 then
			  local disarmprop = ents.Create("prop_physics")
			  disarmprop:SetModel("models/llama/megatonbomb.mdl")
			  disarmprop:SetModelScale(0.25)
			  disarmprop:SetPos(self:GetPos())
			  disarmprop:SetAngles(self:GetAngles())
			  disarmprop:Spawn()
			  disarmprop:Activate()
			  disarmprop:EmitSound("ambient/energy/zap6.wav")
			 for k,v in pairs(player.GetAll()) do
			 	v:falloutNotify("☢ " .. activator:Nick() .. " has disabled the Warhead! ☢", "ui/goodkarma.ogg")
			 end
			 timer.Simple(120, function()
				 if IsValid(disarmprop) then
				  disarmprop:Remove()
				 end
				end)
			 self:Remove()
			 return end

	         if(!self.Armed) then
		        if(!self.Exploded) and (!self.Used) then
		            if(activator:IsPlayer()) then
                     self:EmitSound(self.ActivationSound)
                     self:Arm()
					 for k,v in pairs(player.GetAll()) do
					 v:falloutNotify("☢ A Warhead has been Activated ☢", "orbital_alert.ogg")
					 v:ChatPrint(". . . A distant alert can be heard . . .")

					 local fx = ents.Create("prop_physics")
					 fx:SetModel("models/llama/megatonbomb.mdl")
					 fx:SetMaterial("Models/effects/comball_sphere")
					 fx:SetPos(self:GetPos())
					 fx:SetAngles(self:GetAngles())
					 fx:SetModelScale(0.26)
					 fx:SetParent(self)
					 fx:SetNotSolid(true)
					 fx:Spawn()
					 fx:Activate()
					 self:EmitSound("npc/strider/striderx_alert4.wav", 100, 80)
					 self:SetOwner(nil)

					 for i=1, 5 do
						 timer.Simple(60/i, function()
						 self:EmitSound("orbital_alert.ogg", 100)
							if i == 5 then
								timer.Simple(50, function()
									util.ScreenShake(self:GetPos(), 500, 100, 3, 30000)
									self.Exploded = true
									self:Explode()
								end)
							end
						 end)
					 end
					end
	             end
             end
         end
	 end
end

function ENT:OnTakeDamage(dmginfo)
end
