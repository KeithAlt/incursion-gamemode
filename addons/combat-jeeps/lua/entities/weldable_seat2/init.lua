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
			self.MountedGuns[i]:SetModel( "models/weapons/w_mach_m249para.mdl" )
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
						bullet.Spread     = Vector( .04, .04, .04 )                // Aim Cone 
						bullet.Tracer    = 1                                            // Show a tracer on every x bullets  
						bullet.Force    = 0                                         // Amount of force to give to phys objects 
						bullet.Damage    = 5
						bullet.AmmoType = "Ar2" 
						bullet.Attacker = gunner				
						bullet.TracerName = "Tracer"                             
						wep:FireBullets( bullet )
						wep:EmitSound( "Weapon_M249.Single", 80, 60 )    

						local effectdata = EffectData()
							effectdata:SetStart( wep:GetPos() + Vector(0,-10,6) )
							effectdata:SetOrigin( wep:GetPos() + Vector(0,-10,6)  )
							effectdata:SetAngles( wep:GetAngles() + Angle(0,-90,0))
						util.Effect( "RifleShellEject", effectdata ) 
						
						local Attachment = wep:GetAttachment( 1 )

						local e = EffectData()
							e:SetOrigin( Attachment.Pos )
							e:SetAngles(wep:GetAngles())
						util.Effect( "MuzzleEffect", e )

						wep.LastAttack = CurTime()
				
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
    
    local ent = ents.Create("weldable_seat2")
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