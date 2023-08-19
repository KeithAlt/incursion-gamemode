AddCSLuaFile()

pk_pills.packStart("Fallout PILLS","FI","icon/fo3pr.png")

pk_pills.register("cazadore", {
    printName = "Cazadore",
    side = "hl_antlion",
    type = "ply",
    model = "models/fallout/cazadore.mdl",
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
        offset = Vector(0, 0, 30),
        dist = 150
    },
    hull = Vector(35, 35, 75),
    anims = {
        default = {
            idle = "mtidle",
            walk = "mtforward",
            run = "h2hforward",
            glide = "h2hforward",
            jump = "h2hflyhigh",
            melee1 = "h2hattackforwardpower",
            melee2 = "h2hattackpower",
            melee3 = "h2hattackright",
            charge_start = "h2hattackforwardpower",
            charge_loop = "h2hattackforwardpower",
            charge_hit = "h2hhitbody",
            swim = "mtforward",
            burrow_in = "mtagitated",
            burrow_loop = "digidle",
            burrow_out = "digout"
        }
    },
    sounds = {
        melee = pk_pills.helpers.makeList("cazadore/cazadore_hit_sfx01.mp3", 3),
        melee_hit = pk_pills.helpers.makeList("cazadore/cazadore_sting_attack02.mp3", 3),
        charge_start = "cazadore/cazadore_powerattackvox02.mp3",
        charge_hit = "cazadore/cazadore_sting_attack02.mp3", --"npc/antlion_guard/shove1.wav",
        loop_fly = "cazadore/cazadore_wingflap_back01.mp3",
        loop_charge = "cazadore/cazadore_wingturn01.mp3",
        land = "cazadore/foot/cazadore_foot04.mp3",
        burrow_in = "npc/antlion/digdown1.wav",
        burrow_out = "npc/antlion/digup1.wav",
        step = pk_pills.helpers.makeList("cazadore/foot/cazadore_foot10.mp3", 4)
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
        range = 75,
        dmg = 25
    },
    charge = {
        vel = 800,
        dmg = 50,
        delay = .6
    },
    attack2 = {
        mode = "trigger",
        func = function(ply, ent)
            ent:PillChargeAttack()
        end
    },
    movePoseMode = "yaw",
    moveSpeed = {
        walk = 200,
        run = 500
    },
    jumpPower = 500,
    jump = function(ply, ent)
        if ply:GetVelocity():Length() < 300 then
            ply:SetVelocity(Vector(0, 0, 500))
        end
    end,
    glideThink = function(ply, ent)
        ent:PillLoopSound("cazadore/cazadore_wingturn01.mp3")
        local puppet = ent:GetPuppet()

        if puppet:GetBodygroup(1) == 0 then
            puppet:SetBodygroup(1, 1)
        end
    end,
    land = function(ply, ent)
        ent:PillLoopStop("cazadore/cazadore_wingturn01.mp3")
        local puppet = ent:GetPuppet()
        puppet:SetBodygroup(1, 0)
    end,
    canBurrow = true,
    health = 120,
    noFallDamage = true,
    damageFromWater = 1
})
