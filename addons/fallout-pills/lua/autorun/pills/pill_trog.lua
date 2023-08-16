AddCSLuaFile()

pk_pills.register("trog", {
    printName = "Trog",
    side = "hl_antlion",
    type = "ply",
    model = "models/fallout/streettrog.mdl",
    default_rp_cost = 4000,
    options = function()
        return {
            {
                skin = 0
            },
            {
                skin = 1
            },
            {
                skin = 2
            },
            {
                skin = 3
            }
        }
    end,
    camera = {
        offset = Vector(0, 0, 50),
        dist = 150
    },
    hull = Vector(35, 35, 75),
    anims = {
        default = {
            idle = "ACT_IDLE",
            walk = "walk",
            run = "walk",
            jump = "h2hunequip",
            melee1 = "h2hattackleftpower",
            melee2 = "h2hattackrightpower",
            melee3 = "h2hattackright",
            charge_start = "h2hequip",
            charge_loop = "walk" ,
            charge_hit = "h2hattackforwardpower",
            swim = "mtforward",
            taunt = "h2haim",
            taunt2 = "h2hequip",
            burrow_in = "h2hunequip",
            burrow_loop = "digidle",
            burrow_out = "getupfacedown"
        }
    },
    sounds = {
        melee = pk_pills.helpers.makeList("ghoulferal/feralghoul_attack01.mp3", 3),
        melee_hit = pk_pills.helpers.makeList("ghoulferal/feralghoul_swing04.mp3", 3),
        charge_start = "ghoulferal/feralghoul_aware02.mp3",
        charge_hit = "ghoulferal/feralghoul_swing03.mp3", --"npc/antlion_guard/shove1.wav",
        loop_charge = "ghoulferal/feralghoul_seizure_short.mp3",
        land = "ghoulferal/feralghoul_alert01.mp3",
        burrow_in = "npc/antlion/digdown1.wav",
        burrow_out = "npc/antlion/digup1.wav",
        scrape = "ghoulferal/feralghoul_aware03.mp3",
        teeth = "ghoulferal/feralghoul_aware04.mp3",
        step = pk_pills.helpers.makeList("ghoulferal/foot/feralghoul_foot_l01.mp3", 4)
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
        delay = .5,
        range = 145,
        dmg = 40
    },
    charge = {
        vel = 900,
        dmg = 75,
        delay = 1.3
    },
    jumpPower = 300,
    attack2 = {
        mode = "trigger",
        func = function(ply, ent)
            ent:PillChargeAttack()
        end
    },
    movePoseMode = "yaw",
    moveSpeed = {
        walk = 125,
        run = 500
    },
    reload = function(ply, ent)
        if ply then
            ent:PillAnim("taunt")
            ent:PillSound("scrape")
        end
    end,
    flashlight = function(ply, ent)
        if ply then
            ent:PillAnim("taunt2")
            ent:PillSound("teeth")
        end
    end,
    land = function(ply, ent)
        local puppet = ent:GetPuppet()
        puppet:SetBodygroup(1, 0)
    end,

function(ply, cmd, args)
  if isValid(ply) then
  ply:ChatPrint(nil, "You are a Monster.")
  ply:ChatPrint(nil, "Unholster to attack (Hold R)")
  ply:ChatPrint(nil, "Right-Click to Charge")
  ply:ChatPrint(nil, "Left-Click to Strike")
  ply:ChatPrint(nil, "CTRL to Borrow")
end
end,

    health = 500,
    noFallDamage = true,
    damageFromWater = 1
})
