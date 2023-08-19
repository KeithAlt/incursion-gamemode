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
		self.Veh:SetKeyValue( "LimitView", "25" )
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
		// Ang
		gunnerangles[1] = Angle( 0, 0, 0 )
		gunnerangles[2] = Angle( 0, 0, 0 )
		// Gunner

		// Mounted gun pos
		mgpos[1] = Vector( 0, -50, 90 )
		mgpos[2] = Vector( 17, 10, 46 )

		// Mounted gun angles
		mgang[1] = Angle( 0, 90, 0 )
		mgang[2] = Angle( 0, 90, 0 )

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

		local radio = ents.Create("fallout_radio")
		radio:SetPos(self.Veh:LocalToWorld(gunnerseats[2] - self.Veh:GetForward()*85) - Vector(-20,0,0))
		radio:SetAngles(self.Veh:GetAngles() - Angle(0,-90,0))
		radio:SetParent(self.Veh)
		radio:Spawn()

		local cage = ents.Create("playercapture_cell")
		cage:SetPos(self.Veh:LocalToWorld(gunnerseats[1] - self.Veh:GetForward()*-50) - Vector(0,0,50))
		cage:SetAngles(self.Veh:GetAngles() - Angle(0,0,10))
		cage:SetModelScale(0.75)
		cage:SetParent(self.Veh)
		cage:SetMaterial("models/props_pipes/Pipesystem01a_skin3")
		cage:Spawn()

		local headspike1 = ents.Create("prop_physics_override")
		headspike1:SetModel("models/optinvfallout/headpike1.mdl")
		headspike1:SetPos(self.Veh:LocalToWorld(gunnerseats[1] - self.Veh:GetForward()*-25) - Vector(5,0,50))
		headspike1:SetAngles(self.Veh:GetAngles() - Angle(35,0,10))
		headspike1:SetParent(self.Veh)
		headspike1:Spawn()

		local headspike2 = ents.Create("prop_physics_override")
		headspike2:SetModel("models/maxib123/legionheadpike.mdl")
		headspike2:SetPos(self.Veh:LocalToWorld(gunnerseats[1] - self.Veh:GetForward()*-25) - Vector(5,0,35))
		headspike2:SetAngles(self.Veh:GetAngles() - Angle(-35,0,0))
		headspike2:SetParent(self.Veh)
		headspike2:Spawn()

		local pit = ents.Create("prop_physics_override")
		pit:SetModel("models/maxib123/firepit.mdl")
		pit:SetModelScale(0.60)
		pit:SetPos(self.Veh:LocalToWorld(gunnerseats[1] - self.Veh:GetForward()*-38) - Vector(0,0,-40))
		pit:SetAngles(self.Veh:GetAngles() - Angle(0,0,10))
		pit:SetParent(self.Veh)
		pit:Spawn()

		local fire = ents.Create("mr_effect96")
		fire:SetPos(self.Veh:LocalToWorld(gunnerseats[1] - self.Veh:GetForward()*-35) - Vector(0,0,-65))
		fire:SetAngles(self.Veh:GetAngles() - Angle(0,0,10))
		fire:SetParent(self.Veh)
		fire:SetMaterial("models/props_pipes/Pipesystem01a_skin3")
		fire:Spawn()
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
							e:SetScale( 2 )
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

    local ent = ents.Create("combat_jeep1")
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
