AddCSLuaFile()

pk_pills.register("deathclaw", {
    printName = "Deathclaw",
    side = "hl_antlion",
    type = "ply",
    model = "models/fallout/deathclaw.mdl",
  /**  default_rp_cost = 4000,
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
    end, **/
    camera = {
        offset = Vector(0, 0, 140),
        dist = 90
    },
    hull = Vector(35, 35, 75),
    anims = {
        default = {
            idle = "mtidle",
            walk = "walk",
            run = "run",
            jump = "h2attackfowardpower",
            melee1 = "h2hattackleftpower",
            melee2 = "h2hattackrightpower",
            melee3 = "h2hattackright_b",
            charge_start = "h2haim",
            charge_loop = "run",
            charge_hit = "h2hattackforwardpower",
            heavy_start = "h2hequip",
            heavy_attack = "h2hattackforwardpower",
            heavy_end = "h2hunequip",
            swim = "mtforward",
            taunt = "clawscrape",
            taunt2 = "teethpick",
            burrow_in = "mtagitated",
            burrow_loop = "digidle",
            burrow_out = "getupfacedown"
        }
    },
    sounds = {
        melee = pk_pills.helpers.makeList("deathclaw/deathclaw_attackpower01.mp3", 3),
        melee_hit = pk_pills.helpers.makeList("deathclaw/deathclawgt_claw_atk02.mp3", 3),
        charge_start = "deathclaw/deathclaw_poweratk03.mp3",
        charge_hit = "deathclaw/deathclawgt_claw_atk04.mp3", --"npc/antlion_guard/shove1.wav",
        loop_charge = "deathclaw/deathclaw_deathgt01.mp3",
        land = "deathclaw/deathclawsm_swing02.mp3",
        burrow_in = "npc/antlion/digdown1.wav",
        burrow_out = "npc/antlion/digup1.wav",
        scrape = "deathclaw/deathclaw_idle_clawscrape.mp3",
        teeth = "deathclaw/deathclaw_idle_teethpick.mp3",
        step = pk_pills.helpers.makeList("deathclaw/foot/deathclaw_foot_l01.mp3", 4)
    },
    aim = {
        xPose = "head_yaw",
        yPose = "head_pitch",
        nocrosshair = true
    },
	attack={
		-- mode= "auto",
		mode= "trigger",
		func=function(ply,ent)
			-- pk_pills.common.melee(ply,ent,{delay=0.4,	range=100,	dmg=150})
			ent:PillAnim("melee" .. math.random(1,3))
			ent:PillSound("melee")
			util.ScreenShake(ply:GetPos(), 25, 25, 1, 1000)

			timer.Simple(0.5, function()
				for k,v in pairs(ents.FindInSphere(ent:GetPos() + ply:GetForward() * 160,80)) do
					if (v:IsPlayer() or v:IsNPC()) and (v != ply or v != ent) then
						v:TakeDamage(100, ply, ply)
						v:SetVelocity(ply:GetForward() * 500)
						v:EmitSound("npc/manhack/grind_flesh" .. math.random(1,3) .. ".wav", 60, 95)
					end
				end
			end)
		end,
		delay = 3,
	},
    charge = {
        vel = 900,
        dmg = 350,
        delay = 2
    },
    attack2 = {
        mode = "trigger",
		func=function(ply,ent)
			-- pk_pills.common.melee(ply,ent,{delay=0.4,	range=100,	dmg=150})
			ent:PillAnim("heavy_start")
			ent:PillSound("charge_start")

			timer.Simple(1, function()
				if IsValid(ent) and ply:Alive() then
					ent:PillAnim("heavy_attack")
					ent:PillSound("charge_hit")
					util.ScreenShake(ply:GetPos(), 25, 25, 1, 1000)
					ent:EmitSound("npc/antlion_guard/foot_heavy" .. math.random(1,2) .. ".wav")

					for k,v in pairs(ents.FindInSphere(ent:GetPos() + ent:GetForward() * 175,150)) do
						if (v:IsPlayer() or v:IsNPC()) and (v != ply or v != ent) then
							v:TakeDamage(70, ply, ply)
							v:SetVelocity(ent:GetForward() * 750)
							v:EmitSound("physics/flesh/flesh_squishy_impact_hard" .. math.random(1,4) .. ".wav", 75, 95)
							util.ScreenShake(ply:GetPos(), 25, 25, 1, 1000)
						end
					end
				end

				timer.Simple(1, function()
				if IsValid(ent) and ply:Alive() then
					ent:PillAnim("heavy_end")
				end
				end)
			end)
		end,
		delay = 7,
    },
    movePoseMode = "yaw",
    moveSpeed = {
        walk = 200,
        run = 400
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
    glideThink = function(ply, ent)
        ent:PillLoopSound("deathclaw/foot/deathclaw_foot_run_l03.mp3")
    end,
    land = function(ply, ent)
        ent:PillLoopStop("deathclaw/foot/deathclaw_foot_run_l03.mp3")
    end,

    canBurrow = true,
    health = 2000,
    noFallDamage = true,
    damageFromWater = 1
})
