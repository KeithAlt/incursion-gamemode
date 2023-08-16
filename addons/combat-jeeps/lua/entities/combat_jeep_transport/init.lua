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

        self.Veh = ents.Create( "prop_vehicle_jeep" )
		self.Veh:SetKeyValue( "VehicleScript", "scripts/vehicles/jeep_test.txt" )
		self.Veh:SetModel( "models/buggy.mdl" )
		self.Veh:SetPos( self:GetPos() )
		self.Veh:SetAngles( ang )
        self.Veh:Spawn( )

        self.Veh:DeleteOnRemove( self )

		// This Table and spawnsystem from Neuro cars. ThankU all!
		// Passenger Seats - Gunners
		self.GunnerSeats = {}
		self.MountedGuns = {}
		local gunnerseats,gunnerangles,mgpos,mgang = {},{},{},{}

		// Seat
		// Pos
		gunnerseats[1] = Vector( 0, -70, 70 )
		gunnerseats[2] = Vector( 20, -35, 20 )
		gunnerseats[3] = Vector( 0, -90, 40 )
		gunnerseats[4] = Vector( -38, -55, 23 )
		gunnerseats[5] = Vector( 43, -55, 27 )
		gunnerseats[6] = Vector( 0, 42, 25 )
		// Ang
		gunnerangles[1] = Angle( 0, 0, 0 )
		gunnerangles[2] = Angle( 0, 0, 0 )
		gunnerangles[3] = Angle( 0, 180, 0 )
		gunnerangles[4] = Angle( 0, 90, 0 )
		gunnerangles[5] = Angle( 0, -90, 0 )
		gunnerangles[6] = Angle( 0, 0, 0 )
		// Gunner

		// Mounted gun pos
		mgpos[1] = Vector( 0, -50, 90 )
		mgpos[2] = Vector( 17, 10, 46 )
		mgpos[6] = Vector( 0, 55, 40 )
    
		// Mounted gun angles
		mgang[1] = Angle( 0, 90, 0 )
		mgang[2] = Angle( 0, 90, 0 )
		mgang[6] = Angle( 0, 90, 0 )
    
		local mnt, mntp = {},{}
		mnt[1] = Angle( 0, 90, 180 )
		mnt[2] = Angle( 0, -90, 180 )
    
		mntp[1] = Vector( 10, -32, 38.5 )
		mntp[2] = Vector( 10, 32, 38.5 )

		for i=1,1 do
			self.MountedGuns[i] = ents.Create( "prop_physics_override" )
			self.MountedGuns[i]:SetPos( self.Veh:LocalToWorld( mgpos[i] ) )
			self.MountedGuns[i]:SetAngles( self.Veh:GetAngles() + mgang[i] )
			self.MountedGuns[i]:SetModel( "models/Airboatgun.mdl" )
			self.MountedGuns[i]:SetParent( self.Veh )
			self.MountedGuns[i]:SetSolid( SOLID_NONE )
			self.MountedGuns[i].LastAttack = now
			self.MountedGuns[i]:Spawn()
        
			self.GunnerSeats[i] = ents.Create( "prop_vehicle_prisoner_pod" )
			self.GunnerSeats[i]:SetPos( self.Veh:LocalToWorld( gunnerseats[i] ) )
			self.GunnerSeats[i]:SetModel( "models/nova/jeep_seat.mdl" )
			self.GunnerSeats[i]:SetKeyValue( "vehiclescript", "scripts/vehicles/prisoner_pod.txt" )
			self.GunnerSeats[i]:SetKeyValue( "LimitView", "60" )
			self.GunnerSeats[i].HandleAnimation = function( v, p ) return p:SelectWeightedSequence( ACT_GMOD_SIT_ROLLERCOASTER ) end
			self.GunnerSeats[i]:SetAngles( self.Veh:GetAngles() + gunnerangles[i] )
			self.GunnerSeats[i]:SetParent( self.Veh )
			self.GunnerSeats[i].MountedWeapon = self.MountedGuns[i]
			self.GunnerSeats[i]:Spawn()
			self.GunnerSeats[i].isGunner = true
		end

		for i=2,2 do
			self.MountedGuns[i] = ents.Create( "prop_physics_override" )
			self.MountedGuns[i]:SetPos( self.Veh:LocalToWorld( mgpos[i] ) )
			self.MountedGuns[i]:SetAngles( self.Veh:GetAngles() + mgang[i] )
			self.MountedGuns[i]:SetModel( "models/weapons/w_mach_m249para.mdl" )
			self.MountedGuns[i]:SetParent( self.Veh )
			self.MountedGuns[i]:SetSolid( SOLID_NONE )
			self.MountedGuns[i].LastAttack = now
			self.MountedGuns[i]:Spawn()
        
			self.GunnerSeats[i] = ents.Create( "prop_vehicle_prisoner_pod" )
			self.GunnerSeats[i]:SetPos( self.Veh:LocalToWorld( gunnerseats[i] ) )
			self.GunnerSeats[i]:SetModel( "models/nova/jeep_seat.mdl" )
			self.GunnerSeats[i]:SetKeyValue( "vehiclescript", "scripts/vehicles/prisoner_pod.txt" )
			self.GunnerSeats[i]:SetKeyValue( "LimitView", "60" )
			self.GunnerSeats[i].HandleAnimation = function( v, p ) return p:SelectWeightedSequence( ACT_GMOD_SIT_ROLLERCOASTER ) end
			self.GunnerSeats[i]:SetAngles( self.Veh:GetAngles() + gunnerangles[i] )
			self.GunnerSeats[i]:SetParent( self.Veh )
			self.GunnerSeats[i].MountedWeapon = self.MountedGuns[i]
			self.GunnerSeats[i]:Spawn()
			self.GunnerSeats[i].isGunner= true
		end
		
		for i=3,3 do        
			self.GunnerSeats[i] = ents.Create( "prop_vehicle_prisoner_pod" )
			self.GunnerSeats[i]:SetPos( self.Veh:LocalToWorld( gunnerseats[i] ) )
			self.GunnerSeats[i]:SetModel( "models/nova/jeep_seat.mdl" )
			self.GunnerSeats[i]:SetKeyValue( "vehiclescript", "scripts/vehicles/prisoner_pod.txt" )
			self.GunnerSeats[i]:SetKeyValue( "LimitView", "60" )
			self.GunnerSeats[i].HandleAnimation = function( v, p ) return p:SelectWeightedSequence( ACT_GMOD_SIT_ROLLERCOASTER ) end
			self.GunnerSeats[i]:SetAngles( self.Veh:GetAngles() + gunnerangles[i] )
			self.GunnerSeats[i]:SetParent( self.Veh )
			self.GunnerSeats[i]:Spawn()
			self.GunnerSeats[i].isGunner= true
		end
		
		for i=4,4 do        
			self.GunnerSeats[i] = ents.Create( "prop_vehicle_prisoner_pod" )
			self.GunnerSeats[i]:SetPos( self.Veh:LocalToWorld( gunnerseats[i] ) )
			self.GunnerSeats[i]:SetModel( "models/nova/airboat_seat.mdl" )
			self.GunnerSeats[i]:SetKeyValue( "vehiclescript", "scripts/vehicles/prisoner_pod.txt" )
			self.GunnerSeats[i]:SetKeyValue( "LimitView", "60" )
			self.GunnerSeats[i].HandleAnimation = function( v, p ) return p:SelectWeightedSequence( ACT_GMOD_SIT_ROLLERCOASTER ) end
			self.GunnerSeats[i]:SetAngles( self.Veh:GetAngles() + gunnerangles[i] )
			self.GunnerSeats[i]:SetParent( self.Veh )
			self.GunnerSeats[i]:Spawn()
			self.GunnerSeats[i].isGunner= true
		end
		
		for i=5,5 do        
			self.GunnerSeats[i] = ents.Create( "prop_vehicle_prisoner_pod" )
			self.GunnerSeats[i]:SetPos( self.Veh:LocalToWorld( gunnerseats[i] ) )
			self.GunnerSeats[i]:SetModel( "models/nova/airboat_seat.mdl" )
			self.GunnerSeats[i]:SetKeyValue( "vehiclescript", "scripts/vehicles/prisoner_pod.txt" )
			self.GunnerSeats[i]:SetKeyValue( "LimitView", "60" )
			self.GunnerSeats[i].HandleAnimation = function( v, p ) return p:SelectWeightedSequence( ACT_GMOD_SIT_ROLLERCOASTER ) end
			self.GunnerSeats[i]:SetAngles( self.Veh:GetAngles() + gunnerangles[i] )
			self.GunnerSeats[i]:SetParent( self.Veh )
			self.GunnerSeats[i]:Spawn()
			self.GunnerSeats[i].isGunner= true
		end
		
		for i=6,6 do   
			self.MountedGuns[i] = ents.Create( "prop_physics_override" )
			self.MountedGuns[i]:SetPos( self.Veh:LocalToWorld( mgpos[i] ) )
			self.MountedGuns[i]:SetAngles( self.Veh:GetAngles() + mgang[i] )
			self.MountedGuns[i]:SetModel( "models/weapons/w_mach_m249para.mdl" )
			self.MountedGuns[i]:SetParent( self.Veh )
			self.MountedGuns[i]:SetSolid( SOLID_NONE )
			self.MountedGuns[i].LastAttack = now
			self.MountedGuns[i]:Spawn()
		
			self.GunnerSeats[i] = ents.Create( "prop_vehicle_prisoner_pod" )
			self.GunnerSeats[i]:SetPos( self.Veh:LocalToWorld( gunnerseats[i] ) )
			self.GunnerSeats[i]:SetModel( "models/nova/airboat_seat.mdl" )
			self.GunnerSeats[i]:SetKeyValue( "vehiclescript", "scripts/vehicles/prisoner_pod.txt" )
			self.GunnerSeats[i]:SetKeyValue( "LimitView", "60" )
			self.GunnerSeats[i].HandleAnimation = function( v, p ) return p:SelectWeightedSequence( ACT_GMOD_SIT_ROLLERCOASTER ) end
			self.GunnerSeats[i]:SetAngles( self.Veh:GetAngles() + gunnerangles[i] )
			self.GunnerSeats[i]:SetParent( self.Veh )
			self.GunnerSeats[i].MountedWeapon = self.MountedGuns[i]
			self.GunnerSeats[i]:Spawn()
			self.GunnerSeats[i].isGunner= true
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
			
				seat = self.GunnerSeats[i]
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
						bullet.TracerName = "AirboatGunHeavyTracer" 
						bullet.Attacker = gunner
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
			//
			for i=2,2 do
			
				seat = self.GunnerSeats[i]
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
			
			for i=6,6 do
			
				seat = self.GunnerSeats[i]
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
    
    local ent = ents.Create("combat_jeep_transport")
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