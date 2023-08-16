
AddCSLuaFile()

pk_pills.register("fo3_frankhorrigan",{
	printName="Frank Horrigan",
	type="ply",
	side="wild",
	model="models/pw_newvegas/creatures/armormutant.mdl",
	camera={
		offset=Vector(0,0,100),
		dist=128
	},
	anims={
	    default={
	        idle="Mtidle",
	        walk="walk",
	        run="run",
			jump="specialidle_hitlegright",
	        -----
	        flamethrower="2hhaim",
	        attack1="2hmattackrightpower",
	        attack2="2hmattackleftpower",
	        attack3="2hmattackforwardpower",
	        -----
	        taunt_passive="Specialidle_Mtscan",
	    }
	},
	aim={},h2hattackleftpower="h2hattackforwardpower",
	sounds={
		melee_hit = "Zombie.AttackHit",
		melee = "npc/antlion_guard/foot_heavy1.wav",
		melee_miss = "npc/antlion_guard/foot_heavy2.wav",
		step = pk_pills.helpers.makeList("foot/supermutant_foot_#.mp3",6),
		step_level = 100,
		-----
		threat = pk_pills.helpers.makeList("frank/threat#.ogg",8),
		passive = pk_pills.helpers.makeList("frank/passive#.ogg",7),
		j_step="NPC_Strider.Footstep",
		j_land = pk_pills.helpers.makeList("physics/concrete/boulder_impact_hard#.wav",3)
	},
	attack={
		-- mode= "auto",
		mode= "trigger",
		func=function(ply,ent)
			if ply.frankdelay and ply.frankdelay > CurTime() then
				ply:falloutNotify("Reloading Flamethrowers... [ " .. math.floor(ply.frankdelay - CurTime()) .. " ]" )
				return
			end
			local p = ent:GetPuppet()
			-- pk_pills.common.melee(ply,ent,{delay=0.4,	range=100,	dmg=150})
			ply:Freeze(true)
			ent:PillAnim("flamethrower")
			local fx = ents.Create("mr_effect96")
			fx:SetParent(p)
			fx:Spawn()
			fx:Fire("setparentattachment","weapon")
			for i=1,7 do
				timer.Simple(0.25*i,function()if !IsValid(ent) then return end
					for f=3*i,6*i do
						local m = math.random(-25,25)*i
						local fxfire = ents.Create("env_fire")
						fxfire:SetPos(p:LocalToWorld(Vector(40*f,-10+m,10)))
						fxfire:SetKeyValue("damagescale",35)
						fxfire:SetKeyValue("spawnflags",bit.bor(1,2,4,8))
						fxfire:SetKeyValue("firesize",115)
						fx:EmitSound("ambient/fire/mtov_flame2.wav")
						fxfire:Spawn()
						fxfire:Activate()
						fxfire:Fire("StartFire")
						SafeRemoveEntityDelayed(fxfire,5)
						fxfire:EmitSound("ambient/fire/ignite.wav")
						util.ScreenShake(ent:GetPos(), 3, 5, 1, 500)
					end
				end)
			end

			ply.frankdelay = CurTime() + 13
			timer.Simple(2,function()
				SafeRemoveEntity(fx)
				ply:Freeze(false)
			end)
		end,
		delay=10,
	},
	attack2={
	    mode= "trigger",
	    func=function(ply,ent)
	        local p = ent:GetPuppet()
			timer.Simple(.5, function()
				util.ScreenShake(ent:GetPos(), 3, 5, 1, 500)
				ent:PillSound("j_land")
			end)

			ent:PillSound("threat")

			if SERVER then
				for k,v in pairs(ents.FindInSphere(p:GetPos() + p:GetForward()*190,135)) do
					if v == ent then continue end
					if v == ply then continue end
					if v == puppet then continue end
					if v:IsPlayer() && v:Alive() then
						if (v:Health() < v:GetMaxHealth()*0.5) then
							timer.Simple(0.7, function()
								ParticleEffectAttach("mr_fx_beamelectric_arcc1", PATTACH_ABSORIGIN, v, v:LookupAttachment("mouth"))
								v:EmitSound("swordclash2.wav")
								v:Kill()



								local zone = Dismemberment.GetDismembermentZone(HITGROUP_HEAD)
								Dismemberment.Dismember(v, zone.Bone, zone.Attachment, zone.ScaleBones, zone.Gibs, IsValid(v) and v:GetForward() or VectorRand())
															
								
								ent:EmitSound("ambient/energy/spark5.wav")

								timer.Simple(3, function()
									v:StopParticles()
									v:EmitSound("ambient/energy/spark3.wav")
									if ent.taunting then return end
									ent:PillSound("threat")
									ent.taunting = true

									timer.Simple(10, function()
										ent.taunting = nil
									end)
								end)
							end)
						end
						timer.Simple(0.8, function()
							ent:EmitSound("pierce.mp3", 100)
							v:EmitSound("ambient/energy/zap" .. math.random(1,9) .. ".wav")
							v:TakeDamage(160, ply, ply)
							if v:Alive() then
								ParticleEffectAttach("mr_electric_1", PATTACH_POINT_FOLLOW, v, 3)
								timer.Simple(3, function()
									v:StopParticles()
								end)
							end
						end)
					end
				end
			end
	        ent:PillAnim("attack"..math.random(3))
	    end,
	    delay=1,
	},
	reload=function(ply,ent)
		local p = ent:GetPuppet()
		ent:PillSound("threat")
	end,
	flashlight=function(ply,ent)
		local p = ent:GetPuppet()
		ent:PillAnim("taunt_passive")
		ent:PillSound("passive")
	end,
	land=function(ply,ent)
		ent:PillSound("j_land")
		util.ScreenShake(ent:GetPos(), 8, 6, 2, 500)

		local TEMP_DecalTable = {}
		for P=1, #player.GetAll() do
			table.insert(TEMP_DecalTable,player.GetAll()[P])
		end

		util.Decal("Scorch", ent:GetPos(), ent:GetPos()+Vector(0,0,-100), TEMP_DecalTable)

		for k,v in pairs(ents.FindInSphere(ent:GetPos(),250)) do
			if v == ent then continue end
			if v == ply then continue end
			if v == puppet then continue end

			v:TakeDamage(250-(v:GetPos():Distance(ent:GetPos())))
		end
	end,
	moveSpeed={
		walk=90,
		run=325,
		ducked=0
	},
	jumpPower=450,
	noFallDamage=true,
	health=2000,
	events=function(ply,ent,key)
		local puppet = ent:GetPuppet()
		local s = string.Explode(" ",key)
		if s[1] == "event_emit" then
			if s[2] == "FootLeft" or s[2] == "FootRight" then
				ent:PillSound("j_step")
				if ply:KeyDown(IN_SPEED) then
					util.ScreenShake(ent:GetPos(), 8, 6, 0.5, 500)
					for k,v in pairs(ents.FindInSphere(ent:GetPos(),250)) do
						if v == ent then continue end
						if v == ply then continue end
						if v == puppet then continue end

						v:Kill()
					end
				end
			end
		end
		if key == "event_swing" then
			ent:PillSound("melee_miss")
		end
	end
})
