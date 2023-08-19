AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )  

include( "shared.lua" )

function ENT:Initialize()

    if ( SERVER ) then 
		local phys, attach, pos, ang, seat
		self:SetModel( "models/Effects/combineball.mdl" )
		self:SetColor(Color(0,0,0,0))
		self:SetRenderMode( RENDERMODE_TRANSALPHA )	
        
		local now = CurTime() - 120
    
        pos = self:GetPos( )
        ang = self:GetAngles( )
        
        ang:RotateAroundAxis( ang:Up( ), 180 )

		self.Veh = ents.Create( "prop_vehicle_prisoner_pod" )
		self.Veh:SetPos( pos )
		self.Veh:SetModel( "models/nova/airboat_seat.mdl" )
		self.Veh:SetKeyValue( "vehiclescript", "scripts/vehicles/prisoner_pod.txt" )
		self.Veh:SetKeyValue( "LimitView", "60" )
		self.Veh.HandleAnimation = function( v, p ) return p:SelectWeightedSequence( ACT_GMOD_SIT_ROLLERCOASTER ) end
		self.Veh:SetAngles( ang )
        self.Veh:Spawn( )

        self.Veh:DeleteOnRemove( self )

		// This Table and spawnsystem from Neuro cars. ThankU all!
		// Passenger Seats - Gunners
		self.MountedGuns = {}
		local mgpos,mgang = {},{},{},{}
		
		// Gunner

		// Mounted gun pos
		mgpos[1] = Vector( 0, 25, 15 )
    
		// Mounted gun angles
		mgang[1] = Angle( 0, 90, 0 )

		for i=1,1 do
			self.MountedGuns[i] = ents.Create( "prop_physics_override" )
			self.MountedGuns[i]:SetPos( self.Veh:LocalToWorld( mgpos[i] ) )
			self.MountedGuns[i]:SetAngles( self.Veh:GetAngles() + mgang[i] )
			self.MountedGuns[i]:SetModel( "models/Airboatgun.mdl" )
			self.MountedGuns[i]:SetParent( self.Veh )
			self.MountedGuns[i]:SetSolid( SOLID_NONE )
			self.MountedGuns[i].LastAttack = now
			self.MountedGuns[i]:Spawn()
			self.Veh.MountedWeapon = self.MountedGuns[i]
		end
    end
end

function ENT:Think( )
    if ( SERVER ) then
        
        timer.Create("FUK_KYU_S_HOL"..self.Entity:EntIndex(), 0.01, 50, function()
			if not self:IsValid() then return end
				
			local seat
			local gunner
			local wep
			// Gunners
			for i=1,1 do
			
				seat = self.Veh
				gunner = seat:GetDriver()
				wep = seat.MountedWeapon
				
				if( IsValid( seat ) && IsValid( gunner ) && IsValid( wep ) ) then
				
					local ang = gunner:EyeAngles()
					
					if ( gunner:KeyDown( IN_ATTACK ) && wep.LastAttack + .06 <= CurTime() ) then
						
						ang = ang + Angle( math.Rand(-.8,.8), math.Rand(-.8,.8), 0 )
						
						local bullet = {} 
						bullet.Num         = 1
						bullet.Src         = wep:GetPos() + wep:GetForward() * 55
						bullet.Dir         = wep:GetAngles():Forward()                    // Dir of bullet 
						bullet.Spread     = Vector( .03, .03, .03 )                // Aim Cone 
						bullet.Tracer    = 1                                            // Show a tracer on every x bullets  
						bullet.Force    = 0                                         // Amount of force to give to phys objects 
						bullet.Damage    = 0
						bullet.AmmoType = "Ar2" 
						bullet.Attacker = gunner				
						bullet.TracerName = "AirboatGunHeavyTracer" 
						bullet.Callback = function ( a, b, c )                   
							util.BlastDamage( gunner, gunner, b.HitPos, 70, 25 )                    
							return { damage = true, effects = DoDefaultEffect }                   
						end 
											
						wep:FireBullets( bullet )
						wep:EmitSound( "npc/turret_floor/shoot"..math.random(2,3)..".wav", 400, 60 )   

						local e = EffectData()
							e:SetStart( wep:GetPos()+wep:GetForward() * 62 )
							e:SetOrigin( wep:GetPos()+wep:GetForward() * 62 )
							e:SetEntity( wep )
							e:SetAttachment(1)
						util.Effect( "ChopperMuzzleFlash", e )

						wep.LastAttack = CurTime() + 0.05
				
					end
					wep:SetAngles( ang )
				end      
			end        
		end)
    end
end

function ENT:Use( pl )
end

function ENT:SpawnFunction( ply, tr )

    if ( !tr.Hit ) then return end
    
    local SpawnPos = tr.HitPos + tr.HitNormal * 100
    
    local ent = ents.Create("weldable_seat1")
	ent:SetPos( SpawnPos )
    ent:Spawn()
    ent:Activate()
    
    return ent
    
end
 
function ENT:OnRemove()
    if SERVER then
		self.Veh:Remove()
		self:Remove() 
    end
end