AddCSLuaFile()
// FIXME: This needs to be fucking rewritten in a pill rework deployment

pk_pills.register("pill_protectron_enclave", {
    printName = "Protectron (Enclave)",
    side = "hl_combine",
    type = "ply",
    model = "models/fallout/protectron.mdl",
    default_rp_cost = 15000,
    blood = spark,
    skin = 2,
	jumpPower = 0,
	health = 750,
    moveSpeed = {
        walk = 75,
        run = 125
    },
    aim = {
        offset = 7,
        xPose = "aim_yaw",
        yPose = "aim_pitch"
    },
    camera = {
        offset = Vector(0, 1, 85),
        dist = 90
    },
    hull = Vector(20, 20, 72),
    anims = {
        default = {
            idle = "ACT_IDLE",
            walk = "ACT_RUN",
            run = "mtfastforward",
            attack = "mtspecialidle_hittorso",
            melee1 = "h2hattackright_chop",
            povorot_r = "turnright",
            dance = "specialidle_hitbrain",
            jump = "specialidle_hitbrain"

        },
    },
	sounds = {
		shoot = "weapons/lasermusket/LaserMusketFire.wav",
		step = "deathclaw/deathclawsm_swing02.mp3",
		step_level = 50,
		melee = {"deathclaw/deathclawsm_swing04.mp3"},

		joke = {
			"protectron/pro_joke1.ogg",
			"protectron/pro_joke2.ogg",
			"protectron/pro_joke3.ogg",
			"protectron/pro_joke4.ogg",
			"protectron/pro_joke5.ogg",
			"protectron/pro_joke6.ogg",
		},

	    threat = {
	      "protectron/pro_threat1.ogg",
	      "protectron/pro_threat2.ogg",
	      "protectron/pro_threat3.ogg",
	      "protectron/pro_threat4.ogg",
	      "protectron/pro_engage1.ogg",
	      "protectron/pro_engage2.ogg",
	      "protectron/pro_engage3.ogg",
	      "protectron/pro_threat4.ogg",
	    },
        threat_pitch = 100,
        threat_level = 100,
        threat_volume = 300,

		report = {
			"protectron/pro_report1.ogg",
			"protectron/pro_report2.ogg",
			"protectron/pro_report3.ogg",
			"protectron/pro_report4.ogg",
			"protectron/pro_report5.ogg",
		},
	},
    attack = {
        mode = "trigger",
        func = function(ply, ent)
			if ent.ShotCoolDown then return end
			ent.ShotCoolDown = true

			// Create our laser sprite effect
			local blastspr = ents.Create("env_sprite");
			blastspr:SetPos( ent:GetPos() + Vector(0,0,85) )
			blastspr:SetKeyValue( "model", "sprites/vortring1.vmt")
			blastspr:SetKeyValue( "scale",0.5)
			blastspr:SetKeyValue( "framerate",60)
			blastspr:SetKeyValue( "spawnflags","1")
			blastspr:SetKeyValue( "brightness","255")
			blastspr:SetKeyValue( "angles","0 0 0")
			blastspr:SetKeyValue( "rendermode","9")
			blastspr:SetKeyValue( "renderamt","255")
			blastspr:SetParent(ent:GetPuppet(), 8)
			blastspr:Spawn()

			blastspr:SetColor(Color(255,0,0))
			blastspr:Fire("kill","",2.2)

			ent:EmitSound(Sound("NPC_Vortigaunt.ZapPowerup"))

			timer.Simple(2, function()
				if !IsValid(ply) or !IsValid(ent) then return end

				for index, entity in pairs(ents.FindInSphere(ply:GetPos(), 500)) do
					if entity:IsPlayer() and entity:Alive() then
						entity:ScreenFade(SCREENFADE.IN, Color(255,155,155, 75), 0.5, 0)
					end
				end

				ent:PillAnim("")
				ent:PillLoopSound("laser")
				ent:PillSound("shoot")
				ent:StopSound(Sound("NPC_Vortigaunt.ZapPowerup"))
				ply:Freeze(true)

				// Create our laser tracer effect
				util.ParticleTracerEx("keith_tracer_laser",
					ent:GetPos() + Vector(0,0,85),
					ply:GetEyeTrace().HitPos,
					false,
					ply:EntIndex(),
					0
				)

				timer.Simple(0.15, function()
					if !IsValid(ply) or !IsValid(ent) then return end

					local vPoint = ply:GetEyeTrace().HitPos
					local effectdata = EffectData()
					effectdata:SetOrigin( vPoint )
					effectdata:SetScale(1)
					util.Effect( "effect_mad_gnomatron", effectdata )

					ply:Freeze(false)

					util.BlastDamage(ent, ply, vPoint, 300, 100)
					util.ScreenShake(vPoint, 50, 50, 1, 500)
				end)
			end)

			timer.Simple(3, function()
				if !IsValid(ply) or !IsValid(ent) then return end
				ent.ShotCoolDown = nil
			end)
		end
    },
	attack2 = {
		mode = "trigger",
		func = pk_pills.common.melee,
		animCount = 1,
		delay = 0.8,
		range = 75,
		anim = "melee1",
		dmg = 75
	},
    reload = function(ply,ent)
		if ent.CoolDown then
			jlib.Announce(ply, Color(255,0,0), "[WARNING] ", Color(255,155,155), "Your protectron buff is on cooldown")
			return
		end

		ent:PillSound("threat")
		ent:PillAnim("charge_start", true)
		ent.CoolDown = true

		local zone = ents.Create("prop_physics")
		zone:SetModel("models/props_phx/construct/glass/glass_angle360.mdl")
		zone:SetRenderMode(RENDERMODE_TRANSTEXTURE)
		zone:SetColor(Color(0,25,255,65))
		zone:SetModelScale( zone:GetModelScale() * 7)
		zone:SetMoveType(MOVETYPE_NONE)
		zone:SetParent(ent:GetPuppet(), 8)
		zone:SetPos(ent:GetPos())
		zone:SetAngles(ent:EyeAngles())
		zone:DrawShadow(false)
		zone:SetNotSolid(true)
		zone:EmitSound("buttons/combine_button2.wav")

		for i = 1,12 do
			timer.Simple(i + 1, function()
			  if !IsValid(ent) or !IsValid(ply) then return end
				local radius = 400
				for _, ent in pairs(ents.FindInSphere(ply:GetPos(), radius)) do
					if ent == ply then continue end

					if ent:IsPlayer() and ent:Alive() and !ent.buff then
						ent:falloutNotify("You feel protected [20s HP Buff]", "items/medshotno1.wav")

						ent:AddMaxHP(50, 20)
						ent:AddDR(10, 20)

						ent:EmitSound("items/battery_pickup.wav")
						ent.buff = true

						vPoint = ent:GetPos()
						effectdata = EffectData()
						effectdata:SetOrigin( vPoint )
						effectdata:SetScale(0.1)
						util.Effect( "VortDispel", effectdata )

						timer.Simple(20, function()
							if !IsValid(ent) then return end

							ent:falloutNotify("Protectron buff expired", "items/medshotno1.wav")
							ent.buff = nil
						end)
					end
				end
			end)
		end

		timer.Simple(15, function()
			if !IsValid(ply) or !IsValid(zone) then return end
			zone:Remove()
			ply:EmitSound("buttons/combine_button1.wav")
		end)

		timer.Simple(35, function()
			if !IsValid(ply) then return end
			ent.CoolDown = nil
			jlib.Announce(ply, Color(0,255,0), "[WARNING] ", Color(155,255,155), "Your protectron buff is ready")
		end)
	end,

	jump = function(ply,ent)
		ent:PillSound("joke")
		ent:PillAnim("dance")
	end,

	flashlight = function(ply,ent)
		ent:PillSound("report")
	end,
})
