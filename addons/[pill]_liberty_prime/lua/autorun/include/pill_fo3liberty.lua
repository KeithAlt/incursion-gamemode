AddCSLuaFile()

prime_superlaser = CreateConVar( "prime_superlaser", "1", FCVAR_NOTIFY, "Enable Super Laser." )

pk_pills.packStart("Fallout 3 [Liberty Prime]","FO3","icon/fo3pr.png")


pk_pills.register("sk_liberty_prime_pill",{
		printName="Liberty Prime",
	type="ply",
	model="models/fallout/libertyprime.mdl",
	anims={
		default={
			idle="mtidle",
			walk="walk",
			run="walk",
			g_attack="1hpattackright",
			equip="1gtequip",
			rattackk="1gtattackthrow",
            mattackk="stomp",
			jump="hookpunch",
			land="layer_aim_pitch",
			povorot_r="turn_left",
			povorot_r="turn_right"
			//melee4="attack4",
			//melee5="attack5",
		},
	},
	hull=Vector(30,30,75),
//	LibertyScale = true, i'm tried...
//	bodyGroupsCoFSkin=true,
//	modelScale=1.2,
	sounds={
	//	teleport="tinixfnaf2sounds/walk1.wav",
		//gs="tinixfnaf2sounds/With_S2.wav",
		freddymusic={
		"npc/libertyprime/freeformci_citadelprimevoi_0006dd17_1.mp3",
		"npc/libertyprime/freeformci_citadelprimevoi_0006dd18_1.mp3",
		"npc/libertyprime/genericrobot_attack1.mp3",
		"npc/libertyprime/genericrobot_attack2.mp3",
		"npc/libertyprime/genericrobot_attack3.mp3",
		"npc/libertyprime/genericrobot_attack4.mp3",
		"npc/libertyprime/genericrobot_attack5.mp3",
		"npc/libertyprime/genericrobot_attack6.mp3",
		"npc/libertyprime/genericrobot_attack7.mp3",
		"npc/libertyprime/genericrobot_attack8.mp3",
		"npc/libertyprime/genericrobot_attack9.mp3",
		"npc/libertyprime/genericrobot_attack10.mp3",
		"npc/libertyprime/genericrobot_attack11.mp3",
		"npc/libertyprime/genericrobot_attack12.mp3",
		"npc/libertyprime/genericrobot_attack13.mp3",
		"npc/libertyprime/genericrobot_attack14.mp3",
		"npc/libertyprime/genericrobot_attack15.mp3",
		"npc/libertyprime/genericrobot_attack16.mp3",
		"npc/libertyprime/genericrobot_attack17.mp3",
		"npc/libertyprime/genericrobot_attack18.mp3",
		"npc/libertyprime/genericrobot_attack19.mp3",
		"npc/libertyprime/genericrobot_attack20.mp3",
		"npc/libertyprime/genericrobot_attack21.mp3",
		"npc/libertyprime/genericrobot_attack22.mp3",
		"npc/libertyprime/genericrobot_attack23.mp3",
		"npc/libertyprime/mq11_mq11ldprimelines_000908ed_1.mp3",
		"npc/libertyprime/mq11_mq11ldprimelines_000908ee_1.mp3",
		"npc/libertyprime/mq11_mq11ldprimelines_000908ef_1.mp3",
		"npc/libertyprime/mq11_mq11ldprimelines_000908f0_1.mp3",
		"npc/libertyprime/mq11_mq11ldprimelines_000908f1_1.mp3",
		"npc/libertyprime/mq11_mq11ldprimelines_000908f2_1.mp3",
		"npc/libertyprime/mq11_mq11primeactivationli_00071ef7_1.mp3"
	//	"npc/libertyprime/voc_robotlibertyprime_dlc03_01.mp3"
		},
		freddymusic_pitch=100,
		freddymusic_level=150,
		step01="npc/libertyprime/foot/libertyprime_foot_l_near.mp3",
		step02="npc/libertyprime/foot/libertyprime_foot_l_near.mp3",
		soundtrack="npc/libertyprime/soundtrack.mp3",
		equipp="npc/libertyprime/libertyprime_bomb_equip.mp3",
		//pk_pills.helpers.makeList("slower/slower_pain#.wav",2),
		melee="npc/libertyprime/foot/libertyprime_foot_l_trans.mp3",
		melee_hit={"faster/faster_hit1.wav","faster/faster_hit2.wav","faster/faster_hit3.wav","faster/faster_hit4.wav"},
		melee_miss="faster/faster_miss.wav",
		loop_move="npc/libertyprime/libertyprime_idle_lp.wav",
		loop_move_level=100,
	//	step=pk_pills.helpers.makeList("npc/libertyprime/foot/libertyprime_foot_r_trans.mp3",2)
	},
	land=function(ply,ent)
	ent:PillAnim("")
	end,
	die=function(ply,ent)
		ply:SetModelScale(1)
	end,

	noragdoll=true,
	antiHazarded=true,

	moveSpeed={
		walk=150,
		run=200,
		ducked=180,
	},
	camera={
		offset=Vector(0,0,400),
		dist=750
	},
	cloak={
		max=-1
	},
    jumpPower=300,
	health=150000,
	movePoseMode="yaw",
		aim={
		xPose="aim_yaw",
		yPose="aim_pitch"
	},
	canAim=function(ply,ent)
		return ent.active
	end,




//	AntiRadiolar=true,



	AdvisorScan2=true,

	attack={
		mode="trigger",
		func = function(ply,ent)
		if ent.lasercooldown then return end -- Added by keith (Scuffed)
		ent.lasercooldown = true

		timer.Simple(0.5, function()
			if IsValid(ent) then
				ent.lasercooldown = nil
			end
		end)

		if ply:KeyDown(IN_USE) and (!ent.superLaserCooldown or CurTime() > ent.superLaserCooldown) then

		ent.superLaserCooldown = CurTime() + 5 // Super laser cooldown

		local tr = ply:GetEyeTraceNoCursor()
			att228 = ent:GetPuppet():GetAttachment(ent:GetPuppet():LookupAttachment("eye"))
	///local posTgt = ply:GetEyeTraceNoCursor().HitPos
	//local dir = ent:GetConstrictedDirection(att.Pos, 45, 45, posTgt) +Vector(math.Rand(-0.014,0.014),math.Rand(-0.014,0.014),math.Rand(-0.012,0.012))
	//local tr = util.TraceLine({start = att228.Pos, endpos = att228.Pos *32768, filter = ent})
//	util.BlastDamage(ent, ent, tr.HitPos, 20, GetConVarNumber("sk_libertyprime_dmg_laser"))
	ent:EmitSound("npc/libertyprime/libertyprime_laser_fire.mp3", 100, 100)

	ent:EmitSound("ambient/explosions/explode_".. math.random(8,9) ..".wav", 100, 100)
	ent:PillGesture("attack")

		local vaporizer = ents.Create("point_hurt")
	vaporizer:SetKeyValue("Damage","1337")
	vaporizer:SetKeyValue("DamageRadius","250")
	vaporizer:SetKeyValue("DamageType",DMG_DISSOLVE)// DMG_BLAST)
	vaporizer:SetPos(tr.HitPos)
	vaporizer:SetOwner(ply)
	vaporizer:Spawn()
	vaporizer:Fire("hurt","",0)
	vaporizer:Fire("kill","",0.1)


	for k, v in pairs ( ents.FindInSphere( tr.HitPos, 260 ) ) do
		if v:IsValid() && v:IsPlayer() then

		v:ConCommand( "pp_motionblur 1; pp_bloom 1; pp_dof 1" )
		timer.Simple( 3, function() v:ConCommand("pp_motionblur 0; pp_bloom 0; pp_dof 0") end)
		end
	end


		local target=ents.Create("info_target")
			target:SetPos(ply:LocalToWorld(Vector(13,0,470)))
			target:SetName("laser_target_"..ent:EntIndex().."_"..os.time())
			target:SetParent(ply)
			target:Spawn()
			target:Fire("kill","",0.4)


		local target2=ents.Create("info_target")
			target2:SetPos(tr.HitPos)
			target2:SetName("laser_target_"..ent:EntIndex().."_"..os.time())
			target2:SetParent(ply)
			target2:Spawn()
			target2:Fire("kill","",0.5)

			target2:EmitSound("ambient/explosions/explode_".. math.random(8,9) ..".wav", 100, 100)

			timer.Simple(0,function()
				if !IsValid(ent) then return end


				//local GetZePos = tr.HitPos
		util.ScreenShake(tr.HitPos, 100, 200, 0.4, 600)
		local function MakeLaserEffectWithTrace(TargetTrace)


		util.ParticleTracerEx(TargetTrace, target:GetPos(), tr.HitPos, false, target:EntIndex(), 1)
	util.ParticleTracerEx(TargetTrace, target:GetPos(), tr.HitPos + Vector(30,0,0), false, target:EntIndex(), 1)
	util.ParticleTracerEx(TargetTrace, target:GetPos(), tr.HitPos + Vector(-30,0,0), false, target:EntIndex(), 1)
	util.ParticleTracerEx(TargetTrace, target:GetPos(), tr.HitPos + Vector(0,30,0), false, target:EntIndex(), 1)
	util.ParticleTracerEx(TargetTrace, target:GetPos(), tr.HitPos + Vector(0,-30,0), false, target:EntIndex(), 1)
	//util.ParticleTracerEx(TargetTrace, target:GetPos(), tr.HitPos + Vector(50,0,0), false, target:EntIndex(), 1)
	//util.ParticleTracerEx(TargetTrace, target:GetPos(), tr.HitPos + Vector(-50,0,0), false, target:EntIndex(), 1)
	//util.ParticleTracerEx(TargetTrace, target:GetPos(), tr.HitPos + Vector(0,50,0), false, target:EntIndex(), 1)
	//util.ParticleTracerEx(TargetTrace, target:GetPos(), tr.HitPos + Vector(0,-50,0), false, target:EntIndex(), 1)


		end

			//dispenser_beam_red_trail
		//	MakeLaserEffectWithTrace("Advisor_Psychic_Shove")
			//util.ParticleTracerEx("Glados_Beam", target:GetPos(), tr.HitPos, false, target:EntIndex(), 1)

						local sys22 = ents.Create("info_particle_system")
			sys22:SetKeyValue( "effect_name", "mini_can_explo" )
			sys22:SetKeyValue( "start_active", "1" )
			sys22:SetAngles( Angle(0, 0, 0) )
			sys22:SetPos( tr.HitPos )
			sys22:Spawn()
			sys22:Activate()
			sys22:Fire("kill","",0.5)





				ent:PillSound("warp_fire")
				local vaporizer = ents.Create("point_hurt")
	vaporizer:SetKeyValue("Damage","500")
	vaporizer:SetKeyValue("DamageRadius","150")
	vaporizer:SetKeyValue("DamageType",DMG_DISSOLVE)// DMG_BLAST)
	vaporizer:SetPos(tr.HitPos)
	vaporizer:SetOwner(ply)
	vaporizer:Spawn()
	vaporizer:Fire("hurt","",0)
	vaporizer:Fire("kill","",0.1)

	local shake = ents.Create( "env_shake" )
		shake:SetOwner( ply )
		shake:SetPos( tr.HitPos )
		shake:SetKeyValue( "amplitude", "1500" )	-- Power of the shake
		shake:SetKeyValue( "radius", "350" )	-- Radius of the shake
		shake:SetKeyValue( "duration", "1" )	-- Time of shake
		shake:SetKeyValue( "frequency", "1755" )	-- How har should the screenshake be
		shake:SetKeyValue( "spawnflags", "4" )	-- Spawnflags( In Air )
		shake:Spawn()
		shake:Activate()
		shake:Fire( "StartShake", "", 0 )
		shake:Fire( "Kill", "", 0.02 )

	for k, v in pairs ( ents.FindInSphere( tr.HitPos, 360 ) ) do
		if v:IsValid() && v:IsPlayer() then
		end
	end

	for k, v in pairs ( ents.FindInSphere( tr.HitPos, 12 ) ) do
		//if v:IsValid() and v:IsPlayer() then return end
		local randamm = math.random(1,5)
		if randamm == 1 then
		v:Ignite( 1, 0 )
		end
	end

	local Pos1 = tr.HitPos + tr.HitNormal
    local Pos2 = tr.HitPos - tr.HitNormal
	util.Decal( "Scorch", Pos1, Pos2 )

	local physExplo = ents.Create( "env_physexplosion" )
	    physExplo:SetOwner( ply )
        physExplo:SetPos( tr.HitPos )
        physExplo:SetKeyValue( "Magnitude", "1000" )	-- Power of the Physicsexplosion
        physExplo:SetKeyValue( "radius", "100" )	-- Radius of the explosion
        physExplo:SetKeyValue( "spawnflags", "19" )
        physExplo:Spawn()
        physExplo:Fire( "Explode", "", 0.02 )
		physExplo:Fire( "Kill", "", 0.02 )

	local ar2Explo = ents.Create( "env_ar2explosion" )
		ar2Explo:SetOwner( ply )
		ar2Explo:SetPos( tr.HitPos )
		ar2Explo:Spawn()
		ar2Explo:Activate()
		ar2Explo:Fire( "Explode", "", 0 )
		ar2Explo:Fire( "Kill", "", 0.02 )

				//util.BlastDamage(ent,ply,tr.HitPos,200,1000)
				if IsValid(tr.Entity) then
					local phys = tr.Entity:GetPhysicsObject()
					if IsValid(phys) then
						phys:ApplyForceCenter(ply:EyeAngles():Forward()*9^7)
					end
				end
			end)


	//self:RestartGesture(ACT_GESTURE_RANGE_ATTACK1)


		else
		local tr = ply:GetEyeTraceNoCursor()
			att228 = ent:GetPuppet():GetAttachment(ent:GetPuppet():LookupAttachment("eye"))
	///local posTgt = ply:GetEyeTraceNoCursor().HitPos
	//local dir = ent:GetConstrictedDirection(att.Pos, 45, 45, posTgt) +Vector(math.Rand(-0.014,0.014),math.Rand(-0.014,0.014),math.Rand(-0.012,0.012))
	//local tr = util.TraceLine({start = att228.Pos, endpos = att228.Pos *32768, filter = ent})
//	util.BlastDamage(ent, ent, tr.HitPos, 20, GetConVarNumber("sk_libertyprime_dmg_laser"))
	ent:EmitSound("npc/libertyprime/libertyprime_laser_fire.mp3", 100, 100)

	ent:PillGesture("attack")

	local spark = ents.Create("env_spark")
	spark:SetPos( tr.HitPos )
	spark:Spawn()
	spark:SetKeyValue("Magnitude",3)
	spark:SetKeyValue("TrailLength",1.5)
	spark:Fire( "SparkOnce","",0.01 )
	spark:Fire("kill","",0.2)

	local light = ents.Create("light_dynamic")
	light:SetPos( tr.HitPos )
	light:Spawn()
	light:SetKeyValue("_light","70 70 200")
	light:SetKeyValue("distance",200)
	light:Fire("kill","",0.2)

	local target=ents.Create("info_target")
			target:SetPos(ply:LocalToWorld(Vector(13,0,470)))
			target:SetName("laser_target_"..ent:EntIndex().."_"..os.time())
			target:SetParent(ent)
			target:Spawn()
			target:Fire("kill","",0.2)


			timer.Simple(0,function()
				if !IsValid(ent) then return end

	local GetZePos = tr.HitPos
		util.ScreenShake(GetZePos, 100, 200, 0.4, 600)
	util.ParticleTracerEx("Weapon_Combine_Ion_Cannon_Beam", target:GetPos(), GetZePos, false, target:EntIndex(), 1)
//	util.ParticleTracerEx("electrical_arc_01", target:GetPos(), GetZePos, false, target:EntIndex(), 1)
//	util.ParticleTracerEx("st_elmos_fire", target:GetPos(), GetZePos, false, target:EntIndex(), 1)
//	util.ParticleTracerEx("electrical_arc_01", target:GetPos(), GetZePos, false, target:EntIndex(), 1)
//	util.ParticleTracerEx("choreo_skyflower_01c", target:GetPos(), GetZePos, false, target:EntIndex(), 1)
	ParticleEffect("aurora_shockwave", GetZePos, Angle(0,0,0), nil)
	ParticleEffect("aurora_shockwave_debris", GetZePos, Angle(0,0,0), nil)
	ParticleEffect("Weapon_Combine_Ion_Cannon_Exlposion_c", GetZePos, Angle(0,0,0), nil)
	ParticleEffect("Weapon_Combine_Ion_Cannon_Explosion_g", GetZePos, Angle(0,0,0), nil)
	ParticleEffect("Weapon_Combine_Ion_Cannon_Explosion_f", GetZePos, Angle(0,0,0), nil)


		ParticleEffect("explosion_turret_break_chunks", GetZePos, Angle(0,0,0), nil)





				ent:PillSound("warp_fire")
				local vaporizer = ents.Create("point_hurt")
	vaporizer:SetKeyValue("Damage","90")
	vaporizer:SetKeyValue("DamageRadius","150")
	vaporizer:SetKeyValue("DamageType",DMG_DISSOLVE)// DMG_BLAST)
	vaporizer:SetPos(tr.HitPos)
	vaporizer:SetOwner(ply)
	vaporizer:Spawn()
	vaporizer:Fire("hurt","",0)
	vaporizer:Fire("kill","",0.1)

	local shake = ents.Create( "env_shake" )
		shake:SetOwner( ply )
		shake:SetPos( tr.HitPos )
		shake:SetKeyValue( "amplitude", "1500" )	-- Power of the shake
		shake:SetKeyValue( "radius", "350" )	-- Radius of the shake
		shake:SetKeyValue( "duration", "1" )	-- Time of shake
		shake:SetKeyValue( "frequency", "1755" )	-- How har should the screenshake be
		shake:SetKeyValue( "spawnflags", "4" )	-- Spawnflags( In Air )
		shake:Spawn()
		shake:Activate()
		shake:Fire( "StartShake", "", 0 )
		shake:Fire( "Kill", "", 0.02 )

	for k, v in pairs ( ents.FindInSphere( tr.HitPos, 360 ) ) do
		if v:IsValid() && v:IsPlayer() then
		end
	end

	for k, v in pairs ( ents.FindInSphere( tr.HitPos, 12 ) ) do
		//if v:IsValid() and v:IsPlayer() then return end
		local randamm = math.random(1,5)
		if randamm == 1 then
		v:Ignite( 1, 0 )
		end
	end

	local Pos1 = tr.HitPos + tr.HitNormal
    local Pos2 = tr.HitPos - tr.HitNormal

	util.Decal( "Scorch", Pos1, Pos2 )

	local physExplo = ents.Create( "env_physexplosion" )
	    physExplo:SetOwner( ply )
        physExplo:SetPos( tr.HitPos )
        physExplo:SetKeyValue( "Magnitude", "1000" )	-- Power of the Physicsexplosion
        physExplo:SetKeyValue( "radius", "100" )	-- Radius of the explosion
        physExplo:SetKeyValue( "spawnflags", "19" )
        physExplo:Spawn()
        physExplo:Fire( "Explode", "", 0.02 )
		physExplo:Fire( "Kill", "", 0.02 )

				//util.BlastDamage(ent,ply,tr.HitPos,200,1000)
				if IsValid(tr.Entity) then
					local phys = tr.Entity:GetPhysicsObject()
					if IsValid(phys) then
						phys:ApplyForceCenter(ply:EyeAngles():Forward()*9^7)
					end
				end
			end)

			ent.usingWarpCannon=true
			timer.Simple(2.4,function()
				if !IsValid(ent) then return end
				ent.usingWarpCannon=nil
			end)

	//self:RestartGesture(ACT_GESTURE_RANGE_ATTACK1)
		end
		end
	},

	reload = function(ply,ent)
	if ply:KeyDown(IN_USE) then

	ent:PillAnim("jump",false)
	timer.Simple(0.1, function() ply:ConCommand("-forward")
	ply:ConCommand("+forward")
	ply:ConCommand("+speed")
	 ent:PillSound("melee")
	end)
	timer.Simple(1.3, function() ply:ConCommand("-speed") end)
	timer.Simple(2, function()
	ply:ConCommand("-forward")
	end)

	timer.Simple(1.7, function()
		for k, v in pairs ( ents.FindInSphere( ply:LocalToWorld(Vector(115,-55,150)), 300 ) ) do

		 	local physExplo = ents.Create( "env_physexplosion" )
		    physExplo:SetOwner( ply )
	        physExplo:SetPos( ent:LocalToWorld(Vector(115,-55,0)) )
	        physExplo:SetKeyValue( "Magnitude", "600" )	-- Power of the Physicsexplosion
	        physExplo:SetKeyValue( "radius", "200" )	-- Radius of the explosion
	        physExplo:SetKeyValue( "spawnflags", "19" )
	        physExplo:Spawn()
	        physExplo:Fire( "Explode", "", 0.01 )
			physExplo:Fire( "Kill", "", 0.02 )

			if v:IsValid() and v ~= ply and v:IsPlayer() or v:IsValid() and v:IsNPC()  then
				v:Kill()
				v:SetNotSolid()
				v:SetNoDraw(true)

				ent:PillSound("step01")
				local shake = ents.Create( "env_shake" )
				shake:SetOwner( ply )
				shake:SetPos( v:GetPos() )
				shake:SetKeyValue( "amplitude", "5000" )	-- Power of the shake
				shake:SetKeyValue( "radius", "1350" )	-- Radius of the shake
				shake:SetKeyValue( "duration", "1" )	-- Time of shake
				shake:SetKeyValue( "frequency", "1755" )	-- How har should the screenshake be
				shake:SetKeyValue( "spawnflags", "4" )	-- Spawnflags( In Air )
				shake:Spawn()
				shake:Activate()
				shake:Fire( "StartShake", "", 0 )
				shake:Fire( "Kill", "", 0.02 )
			end
		end
	end)
	else
	ent:PillAnim("mattackk",true)
	ent:PillSound("melee")

	 timer.Simple(1.5, function()
	 for k, v in pairs ( ents.FindInSphere( ply:LocalToWorld(Vector(115,-55,0)), 450 ) ) do
	 ent:PillSound("step01")

	 local effectdata = EffectData()
			effectdata:SetOrigin(ply:LocalToWorld(Vector(115,-55,0)))
			effectdata:SetScale(400)
			util.Effect("ThumperDust", effectdata)


	 local shake = ents.Create( "env_shake" )
		shake:SetOwner( ply )
		shake:SetPos( ent:LocalToWorld(Vector(115,-55,0)) )
		shake:SetKeyValue( "amplitude", "5000" )	-- Power of the shake
		shake:SetKeyValue( "radius", "1350" )	-- Radius of the shake
		shake:SetKeyValue( "duration", "1" )	-- Time of shake
		shake:SetKeyValue( "frequency", "1755" )	-- How har should the screenshake be
		shake:SetKeyValue( "spawnflags", "4" )	-- Spawnflags( In Air )
		shake:Spawn()
		shake:Activate()
		shake:Fire( "StartShake", "", 0 )
		shake:Fire( "Kill", "", 0.02 )

	 	local physExplo = ents.Create( "env_physexplosion" )
	    physExplo:SetOwner( ply )
        physExplo:SetPos( ent:LocalToWorld(Vector(115,-55,0)) )
        physExplo:SetKeyValue( "Magnitude", "600" )	-- Power of the Physicsexplosion
        physExplo:SetKeyValue( "radius", "300" )	-- Radius of the explosion
        physExplo:SetKeyValue( "spawnflags", "19" )
        physExplo:Spawn()
        physExplo:Fire( "Explode", "", 0.01 )
		physExplo:Fire( "Kill", "", 0.02 )


		if v:IsValid() && v ~= ply then

		local Dmg = DamageInfo()
					Dmg:SetAttacker(ply)
					Dmg:SetInflictor(ent)
					Dmg:SetDamage(130)
					Dmg:SetDamagePosition(ply:LocalToWorld(Vector(115,-55,0)))
					Dmg:SetDamageType(DMG_BLAST)

		v:TakeDamageInfo(Dmg)

		    end
		end
	end)

	end
	end,

	//NEW ATTACK


	attack2={
		mode="trigger",
		func = function(ply,ent)

	if !ply:IsOnGround() or ply:KeyDown(IN_USE) or ent.nukecooldown then return end
		ent:PillAnim("equip",true)
		ent:PillSound("equipp",true)
		ent.nukecooldown = true

		timer.Simple(8, function()
			if IsValid(ent) then
				ent.nukecooldown = nil
			end
		end)

		if ent.BAMB then return end

		ent.BAMB = true

		 //helmet_attachment faceplate_attachment
		//	ent.disguised=true
			ent.disguise_faceplate=ents.Create("prop_dynamic")
			ent.disguise_faceplate:SetModel("models/fallout/mininuke.mdl")
			ent.disguise_faceplate:SetPos(ply:GetPos())
			ent.disguise_faceplate:SetParent(ent:GetPuppet())
			ent.disguise_faceplate:Spawn()
			ent.disguise_faceplate:Fire("setparentattachment","bomb", 0)
           timer.Simple(0.9,function()
		   ent:PillAnim("rattackk",true)
			end)
timer.Simple(1.4,function()

		//	ent.mininukee:Fire("setparentattachment","bomb", 0)

				if ent.disguise_faceplate:IsValid() then ent.disguise_faceplate:Remove() end

			local angs = ply:EyeAngles()
				angs.p=angs.p-25
			local pos =  ply:GetPos() +ply:GetForward() *300 +ply:GetUp() *400 +ply:GetRight() *130
		  local explosion_gb=ents.Create("pill_prime_mininuke")
				explosion_gb:SetPos(pos)
				explosion_gb:SetAngles(angs)
		//		explosion_gb:SetModel("models/fallout/mininuke.mdl")
                explosion_gb:SetOwner(ply)
		   //  Explosion_gb:SetAlpha(0)
			//    explosion_gb:Arm()
				//explosion_gb:TakeDamage( 10000, ply, ply )
			//	explosion_gb.Exploded = true
				//explosion_gb:Explode()
				//Explosion_gb2:SetParent(self.Entity)
				explosion_gb:Spawn()
				explosion_gb:Activate()

				local phys = explosion_gb:GetPhysicsObject()
						phys:Wake()
						phys:SetMass(0.5)
						phys:EnableDrag(false)
						phys:SetBuoyancyRatio(0)
						phys:SetVelocity(explosion_gb:GetAngles():Forward()*2400)


	//if IsValid(phys) then
//	end
				//No comments....
	function explosion_gb:PhysicsCollide()
	local self = explosion_gb
	local radius = 500
	local dmg = 800
	local owner = IsValid(self:GetOwner()) && self:GetOwner() || self
	local pos = self:GetPos()

	//ParticleEffect("nqb_explo", pos, ang, owner)
	local effectData = EffectData()
	effectData:SetScale(1)
	effectData:SetOrigin(pos)
	util.Effect( "nuke_blastwave_fallout", effectData )

	ent:EmitSound("ambient/explosions/explode_9.wav", 100, 100)

	self:EmitSound("explosion/explosion_nuke_small_3d.mp3", 165, 100)
	util.BlastDamage(self, owner, pos, radius, dmg, function(ent)
		if !IsValid(self:GetOwner()) then return true end
		return ent ~= self:GetOwner()
	end, DMG_BLAST, true)
	util.ScreenShake(pos, 5, dmg, math.Clamp(dmg /100, 0.1, 2), radius *2)

	local iDistMin = 26
	local tr
	for i = 1, 6 do
		local posEnd = pos
		if i == 1 then posEnd = posEnd +Vector(0,0,75)
		elseif i == 2 then posEnd = posEnd -Vector(0,0,75)
		elseif i == 3 then posEnd = posEnd +Vector(0,75,0)
		elseif i == 4 then posEnd = posEnd -Vector(0,75,0)
		elseif i == 5 then posEnd = posEnd +Vector(75,0,0)
		elseif i == 6 then posEnd = posEnd -Vector(75,0,0) end
		local tracedata = {}
		tracedata.start = pos
		tracedata.endpos = posEnd
		tracedata.filter = self
		local trace = util.TraceLine(tracedata)
		local iDist = pos:Distance(trace.HitPos)
		if trace.HitWorld && iDist < iDistMin then
			iDistMin = iDist
			tr = trace
		end
	end
	if tr then
		util.Decal("Scorch",tr.HitPos +tr.HitNormal,tr.HitPos -tr.HitNormal)
	end
	self:Remove()
	return true

				end

			//table.insert(systems,sys)
			ent.BAMB=nil
	end)

		end
	},
	moveMod = function(ply, ent, mv, cmd)
				if SERVER then
				local puppet = ent:GetPuppet()

				if !ply.scaled then
					ply:SetModelScale(6.7)
					ply.scaled = true
				end

				if !puppet.SKEventCore then
					puppet.SKEventCore = true

					puppet.AcceptInput = function(self, cvar, activator, caller, data)
						if (activator == self and string.find(cvar, "foot") and not string.find(cvar, "step")) then
							local trans = string.find(cvar, "trans")
							local left = string.find(cvar, "lfoot")
							local iAtt = self:LookupAttachment(left and "lfoot" or "rfoot")
							local att = self:GetAttachment(iAtt)

							if not trans then
								local effectdata = EffectData()
								effectdata:SetOrigin(ply:LocalToWorld(left and Vector(115, 55, 0) or Vector(115, -55, 0)))
								effectdata:SetScale(400)
								util.Effect("ThumperDust", effectdata)
							end

							if trans then
								self:EmitSound("npc/libertyprime/foot/libertyprime_foot_" .. (left and "l" or "r") .. "_trans.mp3", 100, 100)

								return
							end

							self:EmitSound("npc/libertyprime/foot/libertyprime_foot_" .. (left and "l" or "r") .. "_near.mp3", 100, 100)
							util.ScreenShake(att.Pos, 100, 100, 0.5, 1500)

							local Dmg = DamageInfo()
							Dmg:SetAttacker(ply)
							Dmg:SetInflictor(ply)
							Dmg:SetDamage(90)
							Dmg:SetDamagePosition(att.Pos)
							Dmg:SetDamageType(DMG_BLAST)

							for k, v in pairs(ents.FindInSphere(att.Pos, 200)) do
								if v != ply then
									v:TakeDamageInfo(Dmg)
								end
								end
							end
						end
					end
				end
		end,
	flashlight=function(ply,ent)
		if ent.tauntcooldown then return end -- Added by Keith (Scuffed)
		ent.tauntcooldown = true

		timer.Simple(5, function()
			ent.tauntcooldown = nil
		end)

	if ply:KeyDown(IN_USE) then
			if !ply:KeyDown(IN_DUCK) then
				ply:ConCommand('say "@play npc/libertyprime/soundtrack.mp3"')
			else
				ply:ConCommand('say "@play npc/libertyprime/NOTHING.mp3"')//it just playing nothing...
			end
		else
			ent:PillSound("freddymusic")
		end
	end,
	duckBy = 0
})
