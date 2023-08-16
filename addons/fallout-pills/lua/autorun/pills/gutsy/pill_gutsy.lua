AddCSLuaFile()

pk_pills.register("pill_gutsy", {
    printName = "Mister Gutsy",
    side = "hl_combine",
    type = "ply",
    model = "models/fallout/mistergutsy.mdl",
    default_rp_cost = 15000,
    side = "hl_combine",
    skin = 0,
    camera = {
        offset = Vector(35, 35, 75),
        dist = 90
    },
    hull = Vector(20, 20, 72),
    anims = {
        default = {
            idle = "1hmaim",
            walk = "walk",
            run = "run",
            melee = "2hlaim",
            launch = "1hpuneequip",
            povorot_r = "turnright",
            jump = "specialidle_deactivate",
            charge_start = "specialidle_knockdowngetup",
            charge_loop = "run"

        },
    },
    aim = {
        offset = 120,
        xPose = "aim_yaw",
        yPose = "aim_pitch"
    },
    --attachment="eyes",
    --fixTracers=true
    --simple=true
    attack = {
		mode = "trigger",
        func = function(ply, ent)
            ent:PillChargeAttack()
            ent:PillSound("engage")
        end
      },
    charge = {
        vel = 800,
        dmg = 100,
        delay = 2.1
      },
    attack2 = {
      mode = "auto",
      delay = 3,
      func = function(ply, ent)
          --if ent.attacking then return end
          ent:PillAnim("Mortar_Shoot", true)
          ent:SetPlaybackRate(2)

          --ent.attacking=true
          timer.Simple(.5, function()
              if not IsValid(ent) then return end
              ent:PillSound("threat")
              ent:PillAnim("launch")
              local angs = ply:EyeAngles()
              angs.p = angs.p - 45
			  for i = 1,5 do
				  timer.Simple(0.1 + i/4, function()
              local nade = ents.Create("pill_proj_energy_grenade")
              nade:SetPos(ent:LocalToWorld(Vector(math.random(50), 0, math.random(50))))
              nade:SetAngles(angs)
              nade:SetOwner(ply)
              nade:Spawn()
			  ent:EmitSound("weapons/grenade_launcher1.wav")
			  	end)
		  	end
          end)
      end
  },
    moveSpeed = {
        walk = 150,
        run = 300
    },
    sounds = {
        shoot = "weapons/lightmachinegun/wpn_lightmachgun.wav",
        step = "gutsy/gutsy_foot.ogg",
        step_level = 50,
        engage={
        "gutsy/g_engage1.ogg",
        "gutsy/g_engage2.ogg",
        "gutsy/g_engage3.ogg",
      },
        engage_pitch=100,
        engage_level=100,
        engage_volume=500,

        threat={
          "gutsy/fire1.ogg",
          "gutsy/fire2.ogg",
          "gutsy/fire3.ogg",
          "gutsy/fire4.ogg",
        },
        threat_pitch=100,
        threat_level=100,
        threat_volume=300,

        report={
          "gutsy/chat.ogg",
          "gutsy/chat.ogg2",
          "gutsy/chat.ogg3",
          "gutsy/chat.ogg4",
          "gutsy/chat.ogg5",
        },
        report_pitch=100,
        report_level=100,
        report_volume=300
    },
    reload = function(ply,ent)
		if ent.CoolDown then
		ply:ChatPrint(">> Your Patriotic Buff is on Cool Down <<")
		return end
		  ent:PillSound("threat")
		  ent:PillAnim("charge_start", true)
		  ent.CoolDown = true

		  local zone = ents.Create("prop_physics")
		  zone:SetModel("models/props_phx/construct/glass/glass_angle360.mdl")
		  zone:SetRenderMode(RENDERMODE_TRANSTEXTURE)
		  zone:SetColor(Color(0,255,0,65))
		  zone:SetModelScale( zone:GetModelScale() * 5)
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
				print("Buff Ran!")
				local radius = 300
				for _, ent in pairs(ents.FindInSphere(ply:GetPos(), radius)) do
				if ent == ply then continue end

				if ent:IsPlayer() && !ent.buff then
					local run = ent:GetRunSpeed()
					local walk = ent:GetWalkSpeed()
					ply:ChatPrint(">> You buffed "..ent:GetName())
					ent:ChatPrint(">> The Gutsy's Patroitism has given you a Speed Buff! <<")
					ent:SetRunSpeed(run + 35)
					ent:SetWalkSpeed(walk + 20)
					ent:EmitSound("items/battery_pickup.wav")
					ent.buff = true

					vPoint = ent:GetPos()
					effectdata = EffectData()
					effectdata:SetOrigin( vPoint )
					effectdata:SetScale(0.1)
					util.Effect( "VortDispel", effectdata )

				timer.Simple(15, function()
					if !IsValid(ent) then return end
					ent:SetRunSpeed(run)
					ent:SetWalkSpeed(walk)
					ent:ChatPrint(">> Your speed buff has ended! <<")
					ent:EmitSound("items/medshotno1.wav")
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
		ply:ChatPrint(">> Patriotic Buff Expired <<")
		end)

		timer.Simple(35, function()
		if !IsValid(ply) then return end
				ent.CoolDown = nil
			 ply:ChatPrint(">> Patriotic Buff Ready <<")
		end)
	end,

  flashlight = function(ply,ent)
  if ply then
  ent:PillSound("report")
  end
end,
collide = function(ply, ent, collide)
    if ent.blades and collide.HitNormal.z < 0.5 and collide.HitNormal.z > -0.5 then
        local force = -collide.HitNormal
        --GTFO
        ent:GetPhysicsObject():ApplyForceCenter(force * 1000)
        --Give Damage
        local dmginfo = DamageInfo()
        dmginfo:SetDamage(25)
        dmginfo:SetAttacker(ply)
        dmginfo:SetDamageForce(force * -10000)
        collide.HitEntity:TakeDamageInfo(dmginfo)

        if (collide.HitEntity:IsPlayer() or collide.HitEntity:IsNPC() or collide.HitEntity:GetClass() == "pill_ent_phys") then
            ent:PillSound("cut_flesh")
        else
            ent:PillSound("cut")
        end
      end
    end,


    jumpPower = 0,
    health = 500
})
