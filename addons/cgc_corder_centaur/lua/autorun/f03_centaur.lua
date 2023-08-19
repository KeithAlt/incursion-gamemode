local bsounds = {
	"fx/fx_flinder_body_head01.wav",
	"fx/fx_flinder_body_head02.wav",
	"fx/fx_flinder_body_head03.wav",
}

local function Transform(ply)
	ParticleEffectAttach("mr_gushing_blood", PATTACH_POINT_FOLLOW, ply, 3)

	for i = 0, 5 do
		timer.Simple(i, function()
			if IsValid(ply) then
				ply:EmitSound(bsounds[ math.random(#bsounds) ])

				if i == 5 then
					jlib.Zap(ply)
					ply:StopParticles()
					
					timer.Simple(0.5, function()
						ParticleEffectAttach("mr_fx_beamelectric_arcc1", PATTACH_POINT_FOLLOW, ply, 3)
						
						timer.Simple(1.5, function()
							ply:StopParticles()
						end)
					end)
				end
			end
		end)
	end

end

hook.Add("InitPostEntity", "CENTAUR_CreateInjection", function()
	local ITEM = nut.item.register("centaur_injector", nil, false, nil, true)
	ITEM.name  = "F.E.V Experiment"
	ITEM.model = "models/mosi/fallout4/props/aid/syringeammo.mdl"
	ITEM.desc  = "A strange syringe with green glowing liquid inside, but with some small strange differences . . ."
	
	ITEM.functions.Inject = {
		name = "Inject",
		icon = "icon16/arrow_up.png",
		onRun = function(item)
			local tr = item.player:GetEyeTrace()
	
			if tr.Entity and tr.Entity:IsPlayer() then
				item.player:falloutNotify("You have injected someone with the F.E.V . . .")
				tr.Entity:falloutNotify("You have injected someone with the F.E.V . . .")
				tr.Entity:EmitSound("ui/stim.wav")
	
				Transform(tr.Entity)
				local time = 5
				timer.Simple(time, function()
					pk_pills.apply(tr.Entity, "unity_centaur", "lock-life")
				end)
	
				return true
			end
	
			item.player:falloutNotify("Couldn't find a target. . .")
			return false
		end,
		onCanRun = function(item)
			return !IsValid(item.entity)
		end
	}
	ITEM.functions.Use = {
		name = "Use",
		icon = "icon16/user.png",
		onRun = function(item)
			local ply = item.player
	
			ply:falloutNotify("You have injected yourself with the F.E.V . . .")
			ply:EmitSound("ui/stim.wav")
	
			Transform(ply)
			local time = 5
			timer.Simple(time, function()
				pk_pills.apply(ply, "unity_centaur", "lock-life")
			end)
	
			return true
		end,
		onCanRun = function(item)
			return !IsValid(item.entity)
		end
	}

	pk_pills.register("unity_centaur",{
		printName = "Unity Centaur",
		type = "ply",
		side = "wild",
		model = "models/fallout/centaur.mdl",
		camera = {
			offset = Vector(0,0,50),
			dist = 100
		},
		anims = {
			default = {
				idle = "idle",
				walk = "walk",
				run = "mtfastforward",
				jump = "specialidle_hitlegright",
				-----
				gooattack = "h2hrecoil",
	
				attack1 = "h2hattackright",
				attack2 = "h2hattackleft",
				-----
				taunt_passive = "Specialidle_Mtscan",
			}
		},
		aim = {},
		sounds = {
			melee_hit = "Zombie.AttackHit",
			melee = "npc/antlion_guard/foot_heavy1.wav",
			melee_miss = "npc/antlion_guard/foot_heavy2.wav",
			step = {
				"foot/npc_centaur_foot_01.mp3",
				"foot/npc_centaur_foot_02.mp3",
				"foot/npc_centaur_foot_03.mp3",
				"foot/npc_centaur_foot_04.mp3",
				"foot/npc_centaur_foot_05.mp3",
				"foot/npc_centaur_foot_06.mp3",
				"foot/npc_centaur_foot_07.mp3",
				"foot/npc_centaur_foot_08.mp3",
				"foot/npc_centaur_foot_09.mp3",
				"foot/npc_centaur_foot_10.mp3",
				"foot/npc_centaur_foot_11.mp3",
				"foot/npc_centaur_foot_12.mp3",
			},
			step_level = 100,
			j_land = pk_pills.helpers.makeList("physics/concrete/boulder_impact_hard#.wav",3)
		},
		attack = {
			-- mode= "auto",
			mode = "trigger",
			func = function(ply,ent)
				local p = ent:GetPuppet()
				-- pk_pills.common.melee(ply,ent,{delay=0.4,	range=100,	dmg=150})
				ent:PillAnim("gooattack")
				ply:EmitSound("spit/npc_centaur_attackspit_0" .. math.random(1,4) .. ".mp3")
	
				if SERVER then
					local goo = ents.Create("gooball")
					goo:SetNoDraw(true)
					goo:SetPos(ply:GetPos() + ply:GetUp() * 100 + ply:GetForward() * 80)
					goo:Spawn()
					goo.Owner = ply
				end
			end,
			delay=3,
		},
		attack2 = {
			mode = "trigger",
			func = function(ply,ent)
				local p = ent:GetPuppet()
				ent:PillAnim("attack" .. math.random(1,2), true)
				ent:EmitSound("attack/npc_centaur_attack_0" .. math.random(1, 3) .. ".mp3")
	
				timer.Simple(.5, function()
					for k,v in ipairs(ents.FindInSphere(ent:GetPos() + ent:GetForward() * 50,200)) do
						if (v:IsPlayer() or v:IsNPC()) and v != ply and v != ent and v != p then
							v:TakeDamage(70, ply, ply)
							v:SetVelocity(ent:GetForward() * 750)
							ParticleEffectAttach("mr_acid_trail", PATTACH_POINT_FOLLOW, v, 1)
							timer.Simple(.3, function()
								v:StopParticles()
							end)
						end
					end
				end)
			end,
			delay = 1,
		},
		moveSpeed = {
			walk = 30,
			run = 125,
			ducked = 15
		},
		//jumpPower=450,
		noFallDamage = true,
		health = 800,
	})
end)