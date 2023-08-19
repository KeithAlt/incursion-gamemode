AddCSLuaFile()

pk_pills.register("pill_sentry_vt", {
    printName = "Sentry Bot (Vault-Tec)",
    side = "hl_combine",
    type = "ply",
    model = "models/fallout/sentrybot_vault.mdl",
    default_rp_cost = 15000,
    side = "hl_combine",
    blood = spark,
    skin = 0,
    camera = {
      offset = Vector(0, 1, 90),
              dist = 125
    },
    hull = Vector(20, 20, 72),
    anims = {
        default = {
            idle = "mtidle",
            walk = "walk",
            run = "run",
            attack = "2hhattackspinloop",
            attack3 = "specialidle_hitarmright",
            povorot_r = "turnright",
            jump = "specialidle_warning"

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
        mode = "auto",
        func = pk_pills.common.shoot,
        anim = "attack",
        delay = .05,
        damage = 10,
        spread = .05,
        tracer = "AR2Tracer"
    },
    attack2 = {
      mode = "trigger",
      func = function(ply, ent)
        if ent.blast then return end
        ent:PillAnim("attack3", true)
        ent:PillSound("engage")
        local pos = ply:GetShootPos() + ply:EyeAngles():Forward() * 100
          local rocket = ents.Create("rpg_missile")
          rocket:SetPos(pos + Vector(-20))
          rocket:SetAngles(ply:EyeAngles())
          rocket:SetSaveValue("m_flDamage", 200)
          rocket:SetOwner(ply)
          rocket:SetVelocity(ply:EyeAngles():Forward() * 1500)
          rocket:Spawn()
          ent.blast = true


        timer.Simple(5, function()
            if IsValid(ent) then
            ent.blast = nil
          end
        end)
      end,
      },
    moveSpeed = {
        walk = 150,
        run = 300
    },
    sounds = {
        shoot = "weapons/lightmachinegun/wpn_lightmachgun.wav",
        step = "sentrybot/sentry_foot.ogg",
        step_level = 50,
        engage={
        "sentrybot/engaging.ogg",
        "sentrybot/engaging2.ogg",
        "sentrybot/engaging3.ogg",
      },
        engage_pitch=100,
        engage_level=100,
        engage_volume=500,

        threat={
          "sentrybot/private.ogg",
          "sentrybot/private2.ogg",
          "sentrybot/private3.ogg",
        },
        threat_pitch=100,
        threat_level=100,
        threat_volume=300,

        report={
          "sentrybot/report.ogg",
          "sentrybot/report1.ogg",
          "sentrybot/report2.ogg",
        },
        threat_pitch=100,
        threat_level=100,
        threat_volume=300
    },
    reload = function(ply,ent)
  	if ply then
  	ent:PillSound("threat")
  	end
  end,

  flashlight = function(ply,ent)
  if ply then
  ent:PillSound("report")
  end
end,


    jumpPower = 0,
    health = 1500
})
