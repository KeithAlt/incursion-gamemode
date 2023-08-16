AddCSLuaFile()

pk_pills.register("pill_roboscorp", {
    printName = "Roboscorpion",
    side = "hl_combine",
    type = "ply",
    model = "models/fallout/roboscorpion.mdl",
    default_rp_cost = 15000,
    side = "hl_combine",
    blood = spark,
    skin = 0,
    camera = {
        offset = Vector(500, 1, 85),
        dist = 175
    },
    hull = Vector(35, 35, 75),
    anims = {
        default = {
            idle = "mtidle",
            walk = "mtfastforward",
            run = "mtfastforward",
            attack = "h2hattackpower",
            melee1 = "2h2hattackright",
            dance = "specialidle_intimidatedance",
            jump = "specialidle_hitbrain"

        },
    },
    aim = {
        offset = 7,
        xPose = "aim_yaw",
        yPose = "aim_pitch"
    },

    --attachment="eyes",
    --fixTracers=true
    --simple=true
    attack = {
        mode = "trigger",
        func = function(ply, ent)
            --if ent.attacking then return end
            ent:PillAnim("attack", true)
            ent:PillSound("engage")
            ent:SetPlaybackRate(0)

            --ent.attacking=true
            timer.Simple(1, function()
                if not IsValid(ent) then return end
                ent:PillSound("shoot")
                local angs = ply:EyeAngles()
                angs.p = angs.p - 5
                local nade = ents.Create("pill_proj_energy_strike")
                nade:SetPos(ent:LocalToWorld(Vector(0, 0, 95)))
                nade:SetAngles(angs)
                nade:SetOwner(ply)
                nade:Spawn()
            end)
        end
    },
      moveSpeed = {
          walk = 150,
          run = 300
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
    moveSpeed = {
        walk = 100,
        run = 200
    },
    sounds = {
        shoot = "weapons/lasermusket/LaserMusketFire.wav",
        step = "deathclaw/deathclawsm_swing02.mp3",
        step_level = 50,
        melee={"deathclaw/deathclawsm_swing04.mp3"},
        blast={
        "weapons/laserrifle/wpn_riflelaser_reloadinout.wav"
      },

        threat={
          "roboscorp/threat1.ogg",
          "roboscorp/threat2.ogg",
          "roboscorp/threat3.ogg",
          "roboscorp/threat4.ogg",
        },
        threat_pitch=100,
        threat_level=100,
        threat_volume=300,

        report={
          "roboscorp/talk1.ogg",
          "roboscorp/talk2.ogg",
          "roboscorp/talk3.ogg",
          "roboscorp/talk4.ogg",
          "roboscorp/talk5.ogg",
          "roboscorp/talk6.ogg",
          "roboscorp/talk7.ogg",
        },
        engage={
          "roboscorp/engage1.ogg",
          "roboscorp/engage2.ogg",
          "roboscorp/engage3.ogg",
          "roboscorp/engage4.ogg",
        },
    },
    reload = function(ply,ent)
  	if ply then
  	ent:PillSound("threat")
  	end
  end,

  jump = function(ply,ent)
      if ply then
        ent:PillSound("threat")
        ent:PillAnim("dance")
      end
        end,

  flashlight = function(ply,ent)
  if ply then
  ent:PillSound("report")
  end
end,



    jumpPower = 0,
    health = 3500
})
