function apcFunctions_SGM(ent)

	if SERVER then
		local driver = ent:GetDriver()
			if driver:IsValid() then
				local aim = ent:WorldToLocalAngles(driver:GetAimVector():Angle())
				local mainTrace = util.QuickTrace((ent:GetPos()+ent:GetUp()*140), driver:GetAimVector()*8000, {ent, driver})
				if driver:KeyDown(IN_ATTACK) and ((ent:GetNWInt("lastFire",0) + 6) < CurTime()) and (ent:GetNWInt("aim_pitch") > -25 and ent:GetNWInt("aim_pitch") < 20) then
					ent:EmitSound("vehicles/sgmcars/apc_fo4/fire.wav", 120, 100, 1, CHAN_WEAPON)
					ent:SetNWInt("lastFire",CurTime())
					local radius = 300
					util.BlastDamage( ent, driver, mainTrace.HitPos, radius, 250 )
					local effectdata = EffectData()
					effectdata:SetOrigin( mainTrace.HitPos )
					util.Effect( "Explosion", effectdata, true, true )
					util.Effect( "HelicopterMegaBomb", effectdata, true, true )
					util.Effect( "ThumperDust", effectdata, true, true )


					local muzzleeffectdata = EffectData()
					local muzzle = ent:GetAttachment(ent:LookupAttachment("main_muzzle"))
					muzzleeffectdata:SetOrigin( muzzle.Pos)
					muzzleeffectdata:SetAngles( muzzle.Ang)
					muzzleeffectdata:SetScale(8.0)
					util.Effect( "MuzzleEffect", muzzleeffectdata, true, true )



				else if driver:KeyPressed(IN_ATTACK) then
							driver:EmitSound("items/medshotno1.wav", 100, 100, 1, CHAN_WEAPON)
						end
				end
				ent:SetNWInt("aim_yaw",aim.y)
				ent:SetNWInt("aim_pitch",aim.p)


				local muzzle_l = ent:GetAttachment(ent:LookupAttachment("turret_l_muzzle"))

				if !ent.turret_l_DummySpawned then
					ent.turret_l_Dummy = ents.Create("prop_physics")
					ent.turret_l_Dummy:SetModel("models/props_junk/PopCan01a.mdl")

					ent.turret_l_Dummy:SetPos(muzzle_l.Pos)
					ent.turret_l_Dummy:SetAngles(muzzle_l.Ang)
					ent.turret_l_Dummy:SetColor(Color(0,0,0,0))
					ent.turret_l_Dummy:SetRenderMode( RENDERMODE_TRANSALPHA )
					ent.turret_l_Dummy:SetNotSolid(true)
					ent.turret_l_Dummy:Spawn()
					ent.turret_l_Dummy:SetParent(ent, ent:LookupAttachment("turret_l_muzzle"))
					ent.turret_l_DummySpawned = true
				end

				local bullet_l = {}
					bullet_l.Num 			= 1
					bullet_l.Src 			= muzzle_l.Pos
					bullet_l.Dir 			= driver:GetAimVector()
					bullet_l.Spread 		= Vector(0.0125,0.0125,0)
					bullet_l.Tracer		= 1
					bullet_l.TracerName 	= "Tracer"
					bullet_l.Force		= 2
					bullet_l.Damage		= 3
					bullet_l.Attacker 	= driver
					bullet_l.IgnoreEntity = ent

				local muzzle_r = ent:GetAttachment(ent:LookupAttachment("turret_r_muzzle"))

				if !ent.turret_r_DummySpawned then
					ent.turret_r_Dummy = ents.Create("prop_physics")
					ent.turret_r_Dummy:SetModel("models/props_junk/PopCan01a.mdl")

					ent.turret_r_Dummy:SetPos(muzzle_r.Pos)
					ent.turret_r_Dummy:SetAngles(muzzle_r.Ang)
					ent.turret_r_Dummy:SetColor(Color(0,0,0,0))
					ent.turret_r_Dummy:SetRenderMode( RENDERMODE_TRANSALPHA )
					ent.turret_r_Dummy:SetNotSolid(true)
					ent.turret_r_Dummy:Spawn()
					ent.turret_r_Dummy:SetParent(ent, ent:LookupAttachment("turret_r_muzzle"))
					ent.turret_r_DummySpawned = true
				end

				local bullet_r = {}
					bullet_r.Num 			= 1
					bullet_r.Src 			= muzzle_r.Pos
					bullet_r.Dir 			= driver:GetAimVector()
					bullet_r.Spread 		= Vector(0.0125,0.0125,0)
					bullet_r.Tracer		= 1
					bullet_r.TracerName 	= "Tracer"
					bullet_r.Force		= 2
					bullet_r.Damage		= 3
					bullet_r.Attacker 	= driver
					bullet_r.IgnoreEntity = ent


				if driver:KeyDown(IN_ATTACK2) and (ent:GetNWInt("aim_pitch") > -25 and ent:GetNWInt("aim_pitch") < 50) and (ent:GetNWInt("turretLastFire", 0) + 0.075) < CurTime() then
					ent:SetNWInt("turretLastFire",CurTime())
						if ((ent:GetNWInt("aim_yaw")-90) > -35 and (ent:GetNWInt("aim_yaw")-90) < 90) then
							ent.turret_l_Dummy:FireBullets( bullet_l )
							ent.turret_l_Dummy:EmitSound("weapons/smg1/smg1_fire1.wav", 100, 100, 0.25, CHAN_WEAPON)

							local muzzleeffect_l_data = EffectData()
							muzzleeffect_l_data:SetOrigin( muzzle_l.Pos)
							muzzleeffect_l_data:SetAngles( muzzle_l.Ang)
							muzzleeffect_l_data:SetScale(1.0)
							util.Effect( "MuzzleEffect", muzzleeffect_l_data, true, true )

						end


						if ((ent:GetNWInt("aim_yaw")-90) > -90 and (ent:GetNWInt("aim_yaw")-90) < 35) then
							ent.turret_r_Dummy:FireBullets( bullet_r )
							ent.turret_r_Dummy:EmitSound("weapons/smg1/smg1_fire1.wav", 100, 100, 0.25, CHAN_WEAPON)
							local muzzleeffect_r_data = EffectData()
							muzzleeffect_r_data:SetOrigin( muzzle_r.Pos)
							muzzleeffect_r_data:SetAngles( muzzle_r.Ang)
							muzzleeffect_r_data:SetScale(1.0)
							util.Effect( "MuzzleEffect", muzzleeffect_r_data, true, true )
						end


				end

			end


	end

			ent:SetPoseParameter("main_yaw",(ent:GetNWInt("aim_yaw")+270)*(-1))
			ent:SetPoseParameter("main_pitch",ent:GetNWInt("aim_pitch")*(-1))

			if ((ent:GetNWInt("aim_yaw")-90) > -35 and (ent:GetNWInt("aim_yaw")-90) < 90) then
				ent:SetPoseParameter("turret_l_yaw",(ent:GetNWInt("aim_yaw")-90)*(-1))
				ent:SetPoseParameter("turret_l_pitch",ent:GetNWInt("aim_pitch")*(-1))
			end
			if ((ent:GetNWInt("aim_yaw")-90) > -90 and (ent:GetNWInt("aim_yaw")-90) < 35) then
				ent:SetPoseParameter("turret_r_yaw",(ent:GetNWInt("aim_yaw")-90)*(-1))
				ent:SetPoseParameter("turret_r_pitch",ent:GetNWInt("aim_pitch")*(-1))
			end
end
hook.Add("PlayerSpawnedVehicle", "SGM_APC_FALLOUT_SPAWN", function(ply, vehicle)
    if vehicle:GetModel() != "models/sentry/apc_fo4.mdl" then return end

    local mdl = vehicle:GetModel()
    if mdl == "models/sentry/apc_fo4.mdl" then
        local hookID = "ScuffedVehicleThink" .. vehicle:EntIndex()

        hook.Add("Think", hookID, function()
            if !IsValid(vehicle) then
                hook.Remove("Think", hookID)
                return
            end
						apcFunctions_SGM(vehicle)
        end)

        vehicle:CallOnRemove("StopThink", function(self) hook.Remove("Think", "ScuffedVehicleThink" .. self:EntIndex()) end)
    end
end)
