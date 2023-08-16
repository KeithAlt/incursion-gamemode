AddCSLuaFile()

pk_pills.register("pill_eyebot", {
    printName = "Eyebot",
    side = "hl_combine",
    type = "phys",
    model = "models/legoj15/fo4/eyebot.mdl",
    default_rp_cost = 15000,
    side = "hl_combine",
    blood = spark,
    skin = 0,
    camera = {
        offset = Vector(0, 0, 35),
        dist = 250
    },
	driveType = "fly",
	driveOptions = {
		speed = 12
	},
    hull = Vector(35, 35, 75),
    anims = {
        default = {
            idle = "mtidle",
            walk = "walk",
            run = "mtfastforward",
            attack = "mtspecialidle_hittorso",
            melee1 = "h2hattackright_chop",
            povorot_r = "turnright",
            dance = "specialidle_hitbrain",
            jump = "specialidle_hitbrain"

        },
    },
    aim = {
        offset = 0,
        xPose = "aim_yaw",
        yPose = "aim_pitch",
		overrideStart = Vector(10, 0, -33)

    },

    --attachment="eyes",
    --fixTracers=true
    --simple=true
    attack = {
      mode = "auto",
      func = pk_pills.common.shoot,
      delay = 0.1,
      damage = 5,
      spread = .02,
      tracer = "tfa_tracer_incendiary",
    },
    attack2 = {
        mode = "trigger",
        func = function(ply, ent)
    if music then
        ent:PillSound("off")
        music:Stop()
        music = nil
    else
        local tab = ent.formTable.sounds.music
        music = CreateSound(ent, tab[math.random(1, #tab)])
        ent:PillSound("on")
        music:Play()
    end
end
    },
    health = 350,
    damageFromWater = -1,
    sounds = {
        loop_move = "npc/scanner/combat_scan_loop6.wav",
        shoot = "weapons/riflealien/wpn_alienrifle_fire.wav",
        die = "npc/scanner/scanner_explode_crash2.wav",
        on = "falloutradio/fx/pipboy_radio_on.mp3",
        off = "falloutradio/fx/pipboy_radio_off.mp3",
        step = "deathclaw/deathclawsm_swing02.mp3",
        step_level = 0,
        step_pitch= 0,
        step_volume = 0,
        music = {
          "falloutradio/16tons.mp3",
          "falloutradio/aintmisbehavin.mp3",
          "falloutradio/aintthatakickinthehead.mp3",
          "falloutradio/akisstobuildadreamon.mp3",
          "falloutradio/anythinggoes.mp3",
          "falloutradio/atombombbaby.mp3",
          "falloutradio/bigiron.mp3",
          "falloutradio/bluemoon.mp3",
          "falloutradio/butcherpete.mp3",
          "falloutradio/civilization.mp3",
          "falloutradio/countryroads.mp3",
          "falloutradio/crawlout.mp3",
          "falloutradio/crazyhecallsme.mp3",
          "falloutradio/dontfencemein.mp3",
          "falloutradio/endoftheworld.mp3",
          "falloutradio/fairweatherfriend.mp3",
          "falloutradio/gentlepeople.mp3",
          "falloutradio/gunwasloaded.mp3",
          "falloutradio/heartachesbythenumber.mp3",
          "falloutradio/idontwanttosettheworldonfire.mp3",
          "falloutradio/itsalloverbutthecrying.mp3",
          "falloutradio/jinglejanglejingle.mp3",
          "falloutradio/johnnyguitar.mp3",
          "falloutradio/lonestar.mp3",
          "falloutradio/maybe.mp3",
          "falloutradio/mr5x5.mp3",
          "falloutradio/orangecolouredsky.mp3",
          "falloutradio/personality.mp3",
          "falloutradio/pistolpackinmama.mp3",
          "falloutradio/praisethelord.mp3",
          "falloutradio/rainmustfall.mp3",
          "falloutradio/rocket69.mp3",
          "falloutradio/sixtyminuteman.mp3",
          "falloutradio/uraniumfever.mp3",
          "falloutradio/waybackhome.mp3",
          "falloutradio/wonderfulguy.mp3"
        },
      enclave = {"eyebot/eye_enclave.ogg",
        "eyebot/eye_enclave1.ogg",
      },
      theme = {"eyebot/eye_roads.ogg",
        "eyebot/eye_jingle.ogg",
        "eyebot/eye_roads.ogg",
      },
      war = {"eyebot/eye_war.ogg",
        "eyebot/eye_war4.ogg",
        "eyebot/eye_war5.ogg",
        "eyebot/eye_war7.ogg",
        "eyebot/eye_war8.ogg",
        "eyebot/eye_war9.ogg",
        "eyebot/eye_war10.ogg",
        "eyebot/eye_war11.ogg",
        "eyebot/eye_war12.ogg",
        "eyebot/eye_war14.ogg",
      },
    },
    reload = function(ply,ent)
      if enclave then
          enclave:Stop()
          ent:PillSound("off")
          enclave = nil
      else
          local tab = ent.formTable.sounds.enclave
          enclave = CreateSound(ent, tab[math.random(1, #tab)])
          ent:PillSound("on")
          enclave:Play()
      end
  end,
        flashlight = function(ply,ent)
          if war then
            ent:PillSound("war")
              war:Stop()
              war = nil
          else
              local tab = ent.formTable.sounds.war
              war = CreateSound(ent, tab[math.random(1, #tab)])
              war:Play()
          end
      end

})
