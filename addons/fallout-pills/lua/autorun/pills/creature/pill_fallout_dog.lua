AddCSLuaFile()


pk_pills.register("fallout_dog", {
    printName = "Dog",
    side = "hl_antlion",
    type = "ply",
    model = "models/fallout/dogmeat.mdl",
    default_rp_cost = 4000,
    options = function()
        return {
            {
                skin = 1
            },
        }
    end,
    camera = {
        offset = Vector(0, 0, 30),
        dist = 90
    },
    hull = Vector(35, 35, 75),
    anims = {
        default = {
            idle = "mtidle",
            walk = "walk",
            run = "h2hfastforward",
            melee1 = "h2hattackleft",
            melee2 = "h2hattackpower",
            melee3 = "h2hattackright",
            charge_start = "h2hequip",
            charge_loop = "h2hfastforward",
            charge_hit = "h2hattackpower",
            swim = "swimidle",
            bark = "specialidle_barksingle",
            land = "specialidle_whimper",
            happy = "specialidle_happypant",
            aroo = "specialidle_aroo",
            growl = "h2haim"

        }
    },
    sounds = {
        melee = pk_pills.helpers.makeList("dog/dog_attackforward02.mp3",  3),
        charge_start = "dog/dog_growl01.mp3",
        bark = {"dog/dog_bark06.mp3",
          "dog/dog_bark07.mp3",
          "dog/dog_bark05.mp3",
          "dog/dog_bark04.mp3",
          "dog/dog_bark03.mp3",
          "dog/dog_bark02.mp3",
          "dog/dog_bark01.mp3",
        },
        charge_hit = "cazadore/cazadore_sting_attack02.mp3", --"npc/antlion_guard/shove1.wav",
        loop_fly = "cazadore/cazadore_wingflap_back01.mp3",
        loop_charge = "dog/dog_attackmid01.mp3",
        land = "dog/dog_sniff04.mp3",
        death = "dog/dog_death01.mp3",
        happy = "dog/dog_tongue_pt1.mp3",
        growl = {"dog/dog_growl05.mp3",
          "dog/dog_growl04.mp3",
          "dog/dog_growl03.mp3",
          "dog/dog_growl02.mp3",
          "dog/dog_growl01.mp3",
        },
        step = pk_pills.helpers.makeList("dog/foot/dog_foot06.mp3", 4)
    },
    aim = {
        xPose = "head_yaw",
        yPose = "head_pitch",
        nocrosshair = true
    },
    attack = {
        mode = "trigger",
        func = pk_pills.common.melee,
        animCount = 3,
        delay = 2.2,
        range = 125,
        dmg = 25
    },
    charge = {
        vel = 800,
        dmg = 45,
        delay = 0.8
    },
    attack2 = {
        mode = "trigger",
        func = function(ply, ent)
            ent:PillChargeAttack()
        end
    },
    movePoseMode = "yaw",
    moveSpeed = {
        walk = 100,
        run = 500
    },
    jumpPower = 250,
    health = 500,
    noFallDamage = true,
    damageFromWater = 1,
    jump = function(ply, ent)
      if ply then
        ent:PillSound("bark")
        ent:PillAnim("swim")
        end
    end,
    reload = function(ply, ent)
        if ply then
            ent:PillAnim("bark")
          end

            timer.Simple(0.5, function()
              if ply then
            ent:PillSound("bark")
        end
      end)
    end,
    flashlight = function(ply, ent)
      if ply then
        ent:PillAnim("growl")
        ent:PillSound("growl")
      end
end,
    land = function(ply, ent)
      if ply then
        ent:PillAnim("land")
      end
    end,

    die = function(ply, ent)
      if ply then
        ent:PillSound("death")
      end
    end,

})
