AddCSLuaFile()

pk_pills.register("feral", {
    printName = "Feral Ghoul",
    side = "hl_antlion",
    type = "ply",
    model = "models/fallout/ghoulferal.mdl",
      "models/fallout/ghoularmored.mdl",
      "models/fallout/ghoulferal_jumpsuit.mdl",
      "models/fallout/ghoulferal_trooper.mdl",
  --  default_rp_cost = 4000,
    options = function()
        return {
            {
                skin = 0
            },
            {
                skin = 1
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
            idle = "mtidle",
            walk = "walk",
            run = "run",
            jump = "specialidle_hitlegleft",
            melee1 = "h2hattackleftpower",
            melee2 = "h2hattackrightpower",
            melee3 = "h2hattackright_b",
            special = "specialidle_resurrection",
            swim = "mtforward",
            taunt = "h2haim",
            taunt2 = "h2hequip",
        }
    },
    sounds = {
        melee = pk_pills.helpers.makeList("ghoulferal/feralghoul_attack01.mp3", 3),
        melee_hit = pk_pills.helpers.makeList("ghoulferal/feralghoul_swing04.mp3", 3),
        land = "ghoulferal/feralghoul_alert01.mp3",
        scrape = "ghoulferal/feralghoul_aware03.mp3",
        teeth = "ghoulferal/feralghoul_aware04.mp3",
        step = pk_pills.helpers.makeList("ghoulferal/foot/feralghoul_foot_l01.mp3", 4)
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

			timer.Simple(0.5, function()
				for k,v in pairs(ents.FindInSphere(ent:GetPos() + ply:GetForward() * 25, 80)) do
					if (v:IsPlayer() or v:IsNPC()) and v != ply then
						v:TakeDamage(35, ply, ply)
						v:SetVelocity(ply:GetForward() * 500)
						ent:PillSound("melee_hit")
					end
				end
			end)
		end,
		delay = 3,
	},
    jumpPower = 500,
    attack2 = {
        mode = "trigger",
        func = function(ply, ent)
			if not ply:IsOnGround() then return end
			if ent.specialCooldown and ent.specialCooldown > CurTime() then
				ply:notify("Your special attack is on cooldown [" .. math.Round(ent.specialCooldown - CurTime(),0) .. "]")
				return
			end

			ent.specialCooldown = CurTime() + 20

            ent:PillAnim("special")
			ent:EmitSound("ghoulferal/feralghoul_aware02.mp3")
			ent:EmitSound("npc/ghoulferal/feralghoul_radiate.mp3", 125, 100, 1.15)

			local pill = ent

			timer.Simple(0, function() -- NOTE: Required for util.Effects to work
				if IsValid(pill) then
					ply:Freeze(true)

					for index, victim in pairs(ents.FindInSphere(ent:GetPos(), 850)) do
						if victim:IsPlayer() and victim:Alive() then
							victim:ScreenFade(SCREENFADE.IN, Color(0,255,0,25), 1, 1)
						end
					end

					if pill:GetPuppet():GetSkin() != 2 then
						pill:GetPuppet():SetSkin(2)
					end

					-- Effect code
					local effectdata = EffectData()
					effectdata:SetOrigin(pill:GetPos())
					util.Effect( "vm_distort", effectdata )

					ParticleEffect( "mr_portal_exit", ent:GetPos() + Vector(0,0,50), Angle( 0, 0, 0 ), ent )
					ParticleEffect( "mr_acid_ground_1", ent:GetPos(), Angle( 0, 0, 0 ), ent )

					-- Damage code
					for i = 1, 8 do
						timer.Simple(i / 2, function()
							if IsValid(pill) and ply:Alive() then
								for index, victim in pairs(ents.FindInSphere(ent:GetPos(), 500)) do
									if victim:IsPlayer() and victim:Alive() and victim != ply then
										victim:ScreenFade(SCREENFADE.IN, Color(0,255,0,50), 1, 0)
										victim:TakeDamage(14, ent, ply)
										victim:SendLua("surface.PlaySound('radzones/rads.wav')")
									end
								end
							end
						end)
					end

					timer.Simple(3, function()
						if IsValid(ent) then
							ent:StopParticles()
						end

						if IsValid(ply) then
							ply:Freeze(false)
						end
					end)
				end
			end)
        end,
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
		  ply:ChatPrint(nil, "Right-Click to combust")
		  ply:ChatPrint(nil, "Left-Click to Strike")
		  ply:ChatPrint(nil, "CTRL to Borrow")
		end
	end,

    health = 750,
    noFallDamage = true,
    damageFromWater = 1
})
