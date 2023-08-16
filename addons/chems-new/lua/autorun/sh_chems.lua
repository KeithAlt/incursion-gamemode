AddCSLuaFile("chems_config.lua")
jChems = jChems or {}
jChems.Config = jChems.Config or {}
include("chems_config.lua")

jChems.Components = {
	["ketoacid"] = {
		["name"] = "Keto Acid",
		["model"] = "models/blues_pharm/jar_1.mdl"
	},
	["sulfur"] = {
		["name"] = "Sulfur",
		["model"] = "models/blues_pharm/jar_1.mdl"
	},
	["salicylicacid"] = {
		["name"] = "Salicylic Acid",
		["model"] = "models/blues_pharm/jar_2.mdl"
	},
	["propionicacid"] = {
		["name"] = "Propionic Acid",
		["model"] = "models/blues_pharm/jar_2.mdl"
	},
	["aceticanhydride"] = {
		["name"] = "Acetic Anhydride",
		["model"] = "models/blues_pharm/jar_4.mdl"
	},
	["seleniumdioxide"] = {
		["name"] = "Selenium Dioxide",
		["model"] = "models/blues_pharm/jar_4.mdl"
	},
	["napththol"] = {
		["name"] = "2-Napththol",
		["model"] = "models/blues_pharm/jar_3.mdl"
	},
	["methyltestosterone"] = {
		["name"] = "Methyltestosterone",
		["model"] = "models/blues_pharm/jar_3.mdl"
	},
	["acetone"] = {
		["name"] = "Acetone",
		["model"] = "models/blues_pharm/jar_3.mdl"
	},
	["progestorone"] = {
		["name"] = "Progestorone",
		["model"] = "models/blues_pharm/jar_3.mdl"
	},
	["deionizedwater"] = {
		["name"] = "Deionized Water",
		["model"] = "models/blues_pharm/jar_5.mdl"
	},
	["food_kiyya"] = {
		["name"] = "Kiyya",
		["model"] = "models/props/de_inferno/potted_plant3_p1.mdl"
	},
	["chemx"] = {
		["name"] = "Chemical X",
		["model"] =  "models/blues_pharm/jar_1.mdl"
	}
}

--[[
	Server-side functions you can use for buffs in the "use" function of the chem, see the existing chems for examples:
	ply:AddMaxHP(hp, time, quality)
	ply:AddDR(% damage resistance, time, quality)
	ply:AddDMG(% damage buff, time, quality)
	ply:AddSpeed(% speed increase, time, quality)
	ply:BuffStat("SPECIAL letter", buff amt, time, dontStack)
]]
jChems.Chems = {
	["buffout"] = {
		["name"] = "Buffout",
		["desc"] = "Provides +50 Max HP, +10 DR, +5 DMG for 2 minutes or more if the chemist is skilled.",
		["model"] = "models/mosi/fallout4/props/aid/buffout.mdl",
		["time"] = 120, --How long it takes to craft
		["recipe"] = { --The components it takes to craft, see the list above for available components
			["deionizedwater"] = 1, --["componentID"] = amt
			["acetone"] = 2,
			["methyltestosterone"] = 1
		},
		["use"] = function(item, ply, quality)
			if SERVER then
				ply:AddMaxHP(50, 120, quality)
				ply:AddDR(10, 120, quality)
				ply:AddDMG(5, 120, quality)
			else
				jChems.Effects.Swallow()
				ply:EmitSound("ui/eating_mentats.wav")
				nut.fallout.notify("✚ You feel strong and resilient . . .")
			end
		end,
		["addictionChance"] = 14,
		["addictionEffects"] = {
			[1] = function(ply)
				if SERVER then
					ply:SetFOV(60, 10)

					if timer.Exists(ply:SteamID64() .. "buffoutTwitches") then
						timer.Remove(ply:SteamID64() .. "buffoutTwitches")
					end
				end
			end,
			[2] = function(ply)
				if SERVER then
					local steamID = ply:SteamID64()

					timer.Create(steamID .. "buffoutTwitches", 15, 0, function()
						if !IsValid(ply) then timer.Remove(steamID .. "buffoutTwitches") return end
						ply:SetEyeAngles(Angle(math.random(0, 360), math.random(0, 360), ply:EyeAngles().roll))
					end)
				else
					jChems.Effects.ColorModify(Color(65, 65, 0))
				end
			end,
			[3] = function(ply)
				if SERVER then
					ply:SetMaxHealth(ply:GetMaxHealth() * 0.5)
					ply:SetHealth(math.min(ply:Health(), ply:GetMaxHealth()))
				end
			end
		},
		["onAddictionCleared"] = function(ply)
			if timer.Exists(ply:SteamID64() .. "buffoutTwitches") then
				timer.Remove(ply:SteamID64() .. "buffoutTwitches")
				ply:falloutNotify("✚ Your addiction has ended!", "ui/levelup.mp3")
			end
		end
	},
	["kiyyaref"] = {
		["name"] = "Kiyya Pack",
		["desc"] = "Provides +25 Max HP / +5 DR / +5 AGIL for 3 minutes or more if the chemist is skilled.",
		["model"] = "models/clutter/cigarettepack.mdl",
		["time"] = 300, --How long it takes to craft
		["recipe"] = { --The components it takes to craft, see the list above for available components
			["food_kiyya"] = 3, --["componentID"] = amt
			["acetone"] = 1,
			["deionizedwater"] = 1
		},
		["use"] = function(item, ply, quality)
			if SERVER then
				local multi = jChems.Config.Multipliers[quality]
				ply:AddMaxHP(25, 145 * multi, quality)
				ply:AddDR(15, 145 * multi, quality)
				ply:AddSpeed(15, 145 * multi, quality)
				ply:BuffStat("A", 3 * multi, 145, quality)
				ply:falloutNotify("✚ You may have smoked to much . . .")

				timer.Simple(1, function()
				  ply:EmitSound("vo/npc/Barney/ba_ohshit03.wav")
				end)

				timer.Simple(15, function()
				  ply:ChatPrint("✧ ⍙⊑⏃⏁ ⏁⊑⟒ ⎎⎍☊☍ ✧")
				  ply:EmitSound("vo/npc/Barney/ba_wounded02.wav")
				end)

				timer.Simple(60.5, function()
				  ply:ChatPrint("✧ ⍜⊑ ⎅⟒⏃⍀ ☌⍜⎅ ⊑⟒⌰⌿ ⋔⟒ ✧")
				  ply:EmitSound("vo/npc/Barney/ba_no01.wav")
				end)

				timer.Simple(112, function()
				  ply:ChatPrint("✧ ☊⏃⋏ ⏃⋏⊬⍜⋏⟒ ⊑⟒⏃⍀ ⋔⟒ ✧")
				  ply:EmitSound("vo/npc/Barney/ba_pain02.wav")
				end)
			else
				jChems.Effects.Inhale()
				if timer.Exists("KiyyaSmokeB") then return end

				timer.Create("KiyyaSmokeB", 145, 1, function()
					hook.Remove("RenderScreenspaceEffects", "KiyyaSmokeB")
					hook.Remove("Think", "KiyyaSmokeB")

					if IsValid(KiyyaSmokeBMusic) then KiyyaSmokeBMusic:Stop() end

					for k,v in pairs(ply.popUpEnts) do
						v:Remove()
					end
					ply.popUpEnts = {}
				end)

				local deaths = ply:Deaths()

				hook.Add("Think", "KiyyaSmokeB", function()
					if ply:Deaths() > deaths then
						hook.Remove("RenderScreenspaceEffects", "KiyyaSmokeB")
						hook.Remove("Think", "KiyyaSmokeB")

						if IsValid(KiyyaSmokeBMusic) then KiyyaSmokeBMusic:Stop() end

						for k,v in pairs(ply.popUpEnts) do
							v:Remove()
						end

						timer.Remove("KiyyaSmokeB")

						return
					end

					local popUpModels = {
					  "models/f3alien/slow.mdl",
					  "models/f3alien/slow.mdl",
					  "models/f3alien/slow.mdl",
					  "models/f3alien/slow.mdl",
					  "models/f3alien/slow.mdl",
					  "models/f3alien/slow.mdl",
					  "models/f3alien/slow.mdl",
					  "models/f3alien/slow.mdl",
					  "models/f3alien/slow.mdl",
					  "models/f3alien/slow.mdl",
					  "models/f3alien/slow.mdl",
					  "models/f3alien/slow.mdl",
					  "models/f3alien/slow.mdl",
					  "models/f3alien/slow.mdl",
					  "models/f3alien/slow.mdl",
					  "models/f3alien/slow.mdl",
					  "models/f3alien/slow.mdl",
					  "models/f3alien/slow.mdl",
					  "models/f3alien/slow.mdl",
					  "models/f3alien/slow.mdl",
					  "models/f3alien/slow.mdl",
					  "models/f3alien/slow.mdl",
					}

					ply.popUpEnts = ply.popUpEnts or {}

					if #ply.popUpEnts >= 50 then return end

					if math.Rand(0, 100) <= 99.9 then return end

					local spookyProp = ents.CreateClientProp(popUpModels[math.random(1, #popUpModels)])
					spookyProp:SetPos(ply:GetEyeTrace().HitPos)
					spookyProp:SetAngles(AngleRand())
					spookyProp:Spawn()

					table.insert(ply.popUpEnts, spookyProp)
				end)

				hook.Add("RenderScreenspaceEffects", "KiyyaSmokeB", function()
					local color = jlib.Rainbow(95)

					DrawColorModify({
						["$pp_colour_addr"] = (color.r/255)/35,
						["$pp_colour_addg"] = (color.g/255)/2,
						["$pp_colour_addb"] = (color.b/255)/35,
						["$pp_colour_brightness"] = 0,
						["$pp_colour_contrast"] = 1,
						["$pp_colour_colour"] = 1,
						["$pp_colour_mulr"] = (color.r/255)/10,
						["$pp_colour_mulg"] = (color.g/255)/10,
						["$pp_colour_mulb"] = (color.b/255)/10
					})

					DrawSobel(0.1)
					DrawMotionBlur(0.0, 0.0, 1)
					DrawToyTown(0, 0)
					DrawSharpen(0, 0)
				end)

				local KiyyaSmokeBMusic = nil

				sound.PlayURL("https://drive.google.com/u/1/uc?id=1OLPUkjjuSOTc3RZ012oY4SaSR3mc_rBR&export=download", "noblock", function(soundchannel, errorID, errorname)
					soundchannel:Play()
					soundchannel:SetVolume(0.50)
					soundchannel:EnableLooping(false)

					KiyyaSmokeBMusic = soundchannel
				end)
			end
		end,
		["addictionChance"] = 0,
		["addictionEffects"] = {
			[1] = function(ply)
				if SERVER then
					ply:SetFOV(60, 10)

					if timer.Exists(ply:SteamID64() .. "kiyyaTwitches") then
						timer.Remove(ply:SteamID64() .. "kiyyaTwitches")
					end
				end
			end,
			[2] = function(ply)
				if SERVER then
					local steamID = ply:SteamID64()

					timer.Create(steamID .. "kiyyaTwitches", 15, 0, function()
						if !IsValid(ply) then timer.Remove(steamID .. "kiyyaTwitches") return end
						ply:SetEyeAngles(Angle(math.random(0, 360), math.random(0, 360), ply:EyeAngles().roll))
					end)
				else
					jChems.Effects.ColorModify(Color(65, 65, 0))
				end
			end,
			[3] = function(ply)
				if SERVER then
					ply:SetMaxHealth(ply:GetMaxHealth() * 0.5)
					ply:SetHealth(math.min(ply:Health(), ply:GetMaxHealth()))
				end
			end
		},
		["onAddictionCleared"] = function(ply)
			if timer.Exists(ply:SteamID64() .. "kiyyaTwitches") then
				timer.Remove(ply:SteamID64() .. "kiyyaTwitches")
				ply:falloutNotify("✚ Your addiction has ended!", "ui/levelup.mp3")
			end
		end
	},
	["kiyyares"] = {
		["name"] = "Kiyya Smoke",
		["desc"] = "Provides +10 Max HP / +2 DR / +2.5 AGIL for 3 minutes.",
		["model"] = "models/llama/cig.mdl",
		["time"] = 60, --How long it takes to craft
		["recipe"] = { --The components it takes to craft, see the list above for available components
			["food_kiyya"] = 1, --["componentID"] = amt
		},
		["use"] = function(item, ply, quality)
			if SERVER then
				local multi = jChems.Config.Multipliers[quality]
				ply:AddMaxHP(10, 180 * multi, quality)
				ply:AddDR(2, 180 * multi, quality)
				ply:AddSpeed(15, 180 * multi, quality)
				ply:BuffStat("A", 3, 180 * multi, quality)
				ply:EmitSound("vo/npc/Barney/ba_ohyeah.wav")
				ply:falloutNotify("✚ You feel at peace . . .")

				timer.Simple(1, function()
				  ply:EmitSound("vo/npc/Barney/ba_laugh01.wav")
				end)

				timer.Simple(15, function()
				  ply:ChatPrint("☮ If money is the root of all Evil, why do they ask for it at Church? ☮")
				  ply:EmitSound("vo/npc/Barney/ba_laugh02.wav")
				end)

				timer.Simple(60.5, function()
					ply:ChatPrint("☮ Why is it called a building if it's already built? ☮")
				  ply:EmitSound("vo/npc/Barney/ba_laugh03.wav")
				end)

				timer.Simple(112, function()
				  ply:ChatPrint("☮ Who knew what time it was when the first clock was made? ☮")
				  ply:EmitSound("vo/npc/Barney/ba_laugh04.wav")
				end)
			else
				jChems.Effects.Inhale()
				if timer.Exists("KiyyaSmoke") then return end

				ply.popUpEnts = ply.popUpEnts or {}

				local KiyyaSmokeMusic

				timer.Create("KiyyaSmoke", 180, 1, function()
					hook.Remove("RenderScreenspaceEffects", "KiyyaSmoke")
					hook.Remove("Think", "KiyyaSmoke")

					if IsValid(KiyyaSmokeMusic) then KiyyaSmokeMusic:Stop() end

					for k,v in pairs(ply.popUpEnts) do
						v:Remove()
					end
					ply.popUpEnts = {}
				end)

				local deaths = ply:Deaths()

				hook.Add("Think", "KiyyaSmoke", function()
					if ply:Deaths() > deaths then
						hook.Remove("RenderScreenspaceEffects", "KiyyaSmoke")
						hook.Remove("Think", "KiyyaSmoke")

						if IsValid(KiyyaSmokeMusic) then KiyyaSmokeMusic:Stop() end

						for k,v in pairs(ply.popUpEnts) do
							v:Remove()
						end
						ply.popUpEnts = {}

						timer.Remove("KiyyaSmoke")

						return
					end

					if #ply.popUpEnts >= 100 then return end

					if math.Rand(0, 100) <= 99.9 then return end

					local spookyProp = ents.CreateClientProp("models/props/de_inferno/potted_plant3_p1.mdl")
					spookyProp:SetPos(ply:GetPos() + (ply:GetForward() * 100))
					spookyProp:SetAngles(AngleRand())
					spookyProp:Spawn()

					table.insert(ply.popUpEnts, spookyProp)
				end)

				hook.Add("RenderScreenspaceEffects", "KiyyaSmoke", function()
					local color = jlib.Rainbow(50)

					DrawColorModify({
						["$pp_colour_addr"] = (color.r/255)/10,
						["$pp_colour_addg"] = (color.g/255)/10,
						["$pp_colour_addb"] = (color.b/255)/10,
						["$pp_colour_brightness"] = 0,
						["$pp_colour_contrast"] = 1,
						["$pp_colour_colour"] = 1,
						["$pp_colour_mulr"] = (color.r/255)/10,
						["$pp_colour_mulg"] = (color.g/255)/10,
						["$pp_colour_mulb"] = (color.b/255)/10
					})

					DrawSobel(0.1)
					DrawMotionBlur(0.0, 0.0, 0)
					DrawToyTown(0, 0)
					DrawSharpen(0, 0)
				end)

				sound.PlayURL("https://drive.google.com/u/1/uc?id=1KlNtErXggK98DHevEvE3YfvyBQfZKOMr&export=download", "noblock", function(soundchannel, errorID, errorname)
					soundchannel:SetVolume(0.50)
					soundchannel:EnableLooping(false)
					soundchannel:Play()

					KiyyaSmokeMusic = soundchannel
				end)
			end
		end,
		["addictionChance"] = 0,
		["addictionEffects"] = {
			[1] = function(ply)
				if SERVER then
					ply:SetFOV(60, 10)

					if timer.Exists(ply:SteamID64() .. "kiyyaTwitches") then
						timer.Remove(ply:SteamID64() .. "kiyyaTwitches")
					end
				end
			end,
			[2] = function(ply)
				if SERVER then
					local steamID = ply:SteamID64()

					timer.Create(steamID .. "kiyyaTwitches", 15, 0, function()
						if !IsValid(ply) then timer.Remove(steamID .. "kiyyaTwitches") return end
						ply:SetEyeAngles(Angle(math.random(0, 360), math.random(0, 360), ply:EyeAngles().roll))
					end)
				else
					jChems.Effects.ColorModify(Color(65, 65, 0))
				end
			end,
			[3] = function(ply)
				if SERVER then
					ply:SetMaxHealth(ply:GetMaxHealth() * 0.5)
					ply:SetHealth(math.min(ply:Health(), ply:GetMaxHealth()))
				end
			end
		},
		["onAddictionCleared"] = function(ply)
			if timer.Exists(ply:SteamID64() .. "kiyyaTwitches") then
				timer.Remove(ply:SteamID64() .. "kiyyaTwitches")
				ply:falloutNotify("✚ Your addiction has ended!", "ui/levelup.mp3")
			end
		end
	},
	["daddyo"] = {
		["name"] = "Daddy-O",
		["desc"] = "Provides +3 INT, +3 PER, -2 CHR for 5 minutes.",
		["model"] = "models/mosi/fallout4/props/aid/daddyo.mdl",
		["time"] = 30,
		["recipe"] = {
			["deionizedwater"] = 1,
			["progestorone"] = 1
		},
		["use"] = function(item, ply, quality)
			if SERVER then
				local multi = jChems.Config.Multipliers[quality]
				ply:BuffStat("I", 3, 300 * multi, true)
				ply:BuffStat("P", 3, 300 * multi, true)
				ply:BuffStat("C", -2, 300 * multi, true)
				ply:EmitSound("ui/stim.wav")
				ply:falloutNotify("You feel more mentally sharp . . .")
			end
		end,
		["addictionChance"] = 10,
		["addictionEffects"] = {
			[1] = function(ply)
				if SERVER then
					ply:falloutNotify("✚ Your Daddy-O addiction is satisfied", "ui/addicteds.wav")
				end

				if CLIENT then
					chat.AddText(Color(255,0,0), "➤ ", Color(255,125,125), "By feeding your addiction, you'll avoid a passive debuff:")
					chat.AddText(Color(255,255,255), "• ", Color(0,148,255), "Daytripper Addiction:", Color(50,200,255), " -2 PER")
				end
			end,
			[2] = function(ply)
				if SERVER then
					ply:falloutNotify("✚ You feel addiction fatigue [-2 PER]", "ui/addicteds.wav")
					ply:BuffStat("P", -2, -1)
				end
				if CLIENT then
					jChems.Effects.Sobel()
					jChems.Effects.Blur()
				end
			end,
			[3] = function(ply)
				if SERVER then
					ply:falloutNotify("✚ You feel withdrawl pains . . .", "ui/addicteds.wav")
					ply:SetRunSpeed(ply:GetRunSpeed() * 0.4)
				end
			end
		}
	},
	["daytripper"] = {
		["name"] = "Day Tripper",
		["desc"] = "Provides +3 LCK, +3 CHR, -2 STR for 5 minutes. Side affects may include: severe hallucinations.",
		["model"] = "models/mosi/fallout4/props/aid/daytripper.mdl",
		["time"] = 30,
		["recipe"] = {
			["deionizedwater"] = 1,
			["propionicacid"] = 1
		},
		["use"] = function(item, ply, quality)
			if SERVER then
				local multi = jChems.Config.Multipliers[quality]
				ply:BuffStat("L", 3, 300 * multi, true)
				ply:BuffStat("C", 3, 300 * multi, true)
				ply:BuffStat("S", -2, 300 * multi, true)
				ply:EmitSound("ui/psy.wav")
				ply:falloutNotify("✚ You feel reality begin to warp . . .")
			else
				jChems.Effects.Swallow()

				--just fuck my shit up
				jlib.Hallucinate(180, "https://cdn.discordapp.com/attachments/560572621603864600/570426726354518031/daytripper.mp3")
			end
		end,
		["addictionChance"] = 3,
		["addictionEffects"] = {
			[1] = function(ply)
				if SERVER then
					ply:falloutNotify("✚ Your Daytripper addiction is satisfied", "ui/addicteds.wav")
					ply:BuffStat("L", 2, -1, true)
				end

				if CLIENT then
					chat.AddText(Color(255,0,0), "➤ ", Color(255,125,125), "By feeding your addiction, you'll avoid a passive debuff:")
					chat.AddText(Color(255,255,255), "• ", Color(0,148,255), "Daytripper Addiction:", Color(50,200,255), " -3 INTEL")
				end
			end,
			[2] = function(ply)
				if SERVER then
					ply:falloutNotify("✚ You feel addiction fatigue [-3 INTEL]", "ui/addicteds.wav")
					ply:BuffStat("I", -3, -1)
				end
				if CLIENT then
					jChems.Effects.Sobel()
					jChems.Effects.Sharpen()
					jChems.Effects.Blur()
				end
			end,
			[3] = function(ply)
				if SERVER then
					ply:falloutNotify("✚ You feel an extreme head pain . . .", "ui/addicteds.wav")
				end

				if CLIENT then
					jChems.Effects.Sobel()
					jChems.Effects.Sharpen()
					jChems.Effects.Blur()
					jChems.Effects.ToyTown()
					jChems.Effects.ColorModify(Color(255, 100, 100))
				end
			end
		}
	},
	["jet"] = {
		["name"] = "Jet",
		["desc"] = "Provides +50 speed for 1 minute or more if the chemist is skilled.",
		["model"] = "models/mosi/fallout4/props/aid/jet.mdl",
		["time"] = 60,
		["recipe"] = {
			["deionizedwater"] = 1,
			["ketoacid"] = 1,
			["salicylicacid"] = 1
		},
		["use"] = function(item, ply, quality)
			if SERVER then
				ply:AddSpeed(25, 60, quality)
				ply:EmitSound("ui/using_jet.wav")
				ply:falloutNotify("✚ You feel more energetic . . .")
			else
				jChems.Effects.Inhale()
			end
		end,
		["addictionChance"] = 15,
		["addictionEffects"] = {
			[1] = function(ply)
				if SERVER then
					ply:falloutNotify("✚ Your Jet addiction is satisfied")
				end

				if CLIENT then
					chat.AddText(Color(255,0,0), "➤ ", Color(255,125,125), "By feeding your addiction, you'll avoid a passive debuff:")
					chat.AddText(Color(255,255,255), "• ", Color(0,148,255), "Jet Addiction:", Color(50,200,255), " -25% HP")
				end
			end,
			[2] = function(ply)
				if SERVER then
					ply:SetMaxHealth(ply:GetMaxHealth() * 0.75)
					ply:SetHealth(math.min(ply:Health(), ply:GetMaxHealth()))
					ply:falloutNotify("✚ You feel addiction fatigued [-25% HP]", "ui/addicteds.wav")
				end
				if CLIENT then
					jChems.Effects.Sobel()
					jChems.Effects.Blur()
				end
			end,
			[3] = function(ply)
				if SERVER then
					ply:falloutNotify("✚ Your vision fogs from withdrawls", "ui/addicteds.wav")
				end
				if CLIENT then
					jChems.Effects.ColorModify(Color(100, 0, 100))
				end
			end
		}
	},
	["rebound"] = {
		["name"] = "Rebound",
		["desc"] = "Provides +40 speed & +1 ENDURANCE for 1 minute",
		["model"] = "models/fallout/rebound.mdl",
		["time"] = 100,
		["recipe"] = {
			["deionizedwater"] = 1,
			["ketoacid"] = 1,
			["salicylicacid"] = 1
		},
		["use"] = function(item, ply, quality)
			if SERVER then
				ply:AddSpeed(20, 60, quality)
				ply:BuffStat("E", 2, 60)
				ply:EmitSound("ui/using_jet.wav")
				ply:falloutNotify("✚ You feel more energetic . . .")
			else
				jChems.Effects.Inhale()
			end
		end,
		["addictionChance"] = 15,
		["addictionEffects"] = {
			[1] = function(ply)
				if SERVER then
					ply:falloutNotify("✚ Your Rebound addiction is satisfied")
				end

				if CLIENT then
					chat.AddText(Color(255,0,0), "➤ ", Color(255,125,125), "By feeding your addiction, you'll avoid a passive debuff:")
					chat.AddText(Color(255,255,255), "• ", Color(0,148,255), "Rebound Addiction:", Color(50,200,255), " -15 SPD")
				end
			end,
			[2] = function(ply)
				if SERVER then
					ply:SetRunSpeed(ply:GetRunSpeed() - 15)
					ply:falloutNotify("✚ You feel addiction fatigued [-15 SPD]", "ui/addicteds.wav")
				end
				if CLIENT then
					jChems.Effects.Sobel()
					jChems.Effects.Blur()
				end
			end,
			[3] = function(ply)
				if SERVER then
					ply:falloutNotify("✚ Your vision fogs from withdrawls", "ui/addicteds.wav")
				end
				if CLIENT then
					jChems.Effects.ColorModify(Color(100, 0, 100))
				end
			end
		}
	},
	["steady"] = {
		["name"] = "Steady",
		["desc"] = "Provides +15 speed & +5 ENDURANCE for 1 minute",
		["model"] = "models/fallout/steady.mdl",
		["time"] = 120,
		["recipe"] = {
			["deionizedwater"] = 1,
			["ketoacid"] = 1,
			["salicylicacid"] = 1
		},
		["use"] = function(item, ply, quality)
			if SERVER then
				ply:AddSpeed(15, 60, quality)
				ply:BuffStat("E", 5, 60)
				ply:EmitSound("ui/using_jet.wav")
				ply:falloutNotify("You feel durable . . .")
			else
				jChems.Effects.Inhale()
			end
		end,
		["addictionChance"] = 10,
		["addictionEffects"] = {
			[1] = function(ply)
				if SERVER then
					ply:falloutNotify("✚ Your Steady addiction is satisfied")
				end

				if CLIENT then
					chat.AddText(Color(255,0,0), "➤ ", Color(255,125,125), "By feeding your addiction, you'll avoid a passive debuff:")
					chat.AddText(Color(255,255,255), "• ", Color(0,148,255), "Steady Addiction:", Color(50,200,255), " -15 SPEED")
				end
			end,
			[2] = function(ply)
				if SERVER then
					ply:SetRunSpeed(ply:GetRunSpeed() - 15)
					ply:falloutNotify("✚ Your addiction fatigues you [-15 SPD]", "ui/addicteds.wav")
				end
				if CLIENT then
					jChems.Effects.Sobel()
					jChems.Effects.Blur()
				end
			end,
			[3] = function(ply)
				if SERVER then
					ply:falloutNotify("✚ Your vision fogs from withdrawls", "ui/addicteds.wav")
				end
				if CLIENT then
					jChems.Effects.ColorModify(Color(100, 0, 100))
				end
			end
		}
	},
	["ultrajet"] = {
		["name"] = "Ultra Jet",
		["desc"] = "Only for the most extreme retards.",
		["model"] = "models/mosi/fallout4/props/aid/jet.mdl",
		["time"] = 3600,
		["recipe"] = {
			["deionizedwater"] = 5,
			["ketoacid"] = 5,
			["salicylicacid"] = 5,
			["chemx"] = 1
		},
		["use"] = function(item, ply, quality)
			local multi = jChems.Config.Multipliers[quality]
			if SERVER then
				ply:AddSpeed(500, 30, quality)
				ply:SetFOV(90, 30 * multi)
				ply:EmitSound("ui/using_jet.wav")

				ply:EmitSound("ultrajetscream.ogg", 100)

				timer.Simple(30 * multi, function()
					ply:setRagdolled(true, 15)
					ply:falloutNotify("You feel like you could sprint forever . . .")
				end)
			else
				jChems.Effects.Inhale()

				--just fuck my shit up
				if timer.Exists("UltraJet") then return end

				ply.popUpEnts = ply.popUpEnts or {}

				local ultraJetMusic

				timer.Create("UltraJet", 3, 30, function()
					hook.Remove("RenderScreenspaceEffects", "UltraJet")
					hook.Remove("Think", "UltraJet")

					if IsValid(ultraJetMusic) then ultraJetMusic:Stop() end

					for k,v in pairs(ply.popUpEnts) do
						v:Remove()
					end
					ply.popUpEnts = {}
				end)

				local deaths = ply:Deaths()

				hook.Add("Think", "UltraJet", function()
					if ply:Deaths() > deaths then
						hook.Remove("RenderScreenspaceEffects", "UltraJet")
						hook.Remove("Think", "UltraJet")

						if IsValid(ultraJetMusic) then ultraJetMusic:Stop() end

						for k,v in pairs(ply.popUpEnts) do
							v:Remove()
						end
						ply.popUpEnts = {}

						timer.Remove("UltraJet")

						return
					end

					if #ply.popUpEnts >= 100 then return end

					if math.Rand(0, 100) <= 99.9 then return end

					local spookyProp = ents.CreateClientProp("models/mosi/fallout4/props/aid/jet.mdl")
					spookyProp:SetPos(ply:GetPos() + (ply:GetForward() * 100))
					spookyProp:SetAngles(AngleRand())
					spookyProp:Spawn()

					table.insert(ply.popUpEnts, spookyProp)
				end)

				hook.Add("RenderScreenspaceEffects", "UltraJet", function()
					local color = jlib.Rainbow(400)

					DrawColorModify({
						["$pp_colour_addr"] = (color.r/255)/10,
						["$pp_colour_addg"] = (color.g/255)/10,
						["$pp_colour_addb"] = (color.b/255)/10,
						["$pp_colour_brightness"] = 0,
						["$pp_colour_contrast"] = 1,
						["$pp_colour_colour"] = 3,
						["$pp_colour_mulr"] = (color.r/255)/10,
						["$pp_colour_mulg"] = (color.g/255)/10,
						["$pp_colour_mulb"] = (color.b/255)/10
					})

					DrawSobel(3)
					DrawMotionBlur(0.0, 0.0, 25)
					DrawToyTown(25, 25)
					DrawSharpen(25, 25)
				end)

				sound.PlayURL("https://drive.google.com/u/1/uc?id=1dteYSm5Pdma2zIlOWGunSf7KWbuW7ZLd&export=download", "noblock", function(soundchannel, errorID, errorname)
					soundchannel:SetVolume(3)
					soundchannel:EnableLooping(true)
					soundchannel:Play()

					ultraJetMusic = soundchannel
				end)
			end
		end,
		["addictionChance"] = 100,
		["addictionEffects"] = {
			[1] = function(ply)
				if SERVER then
					local timerID = "UltraJetFalls" .. ply:SteamID64()
					ply:falloutNotify("✚ You are addicted to Ultra-Jet", "ui/addicteds.wav")

					timer.Create(timerID, 1, 0, function()
						if !IsValid(ply) then
							timer.Remove(timerID)
							return
						end

						if math.Rand(0, 100) <= 95 then return end

						if ply:Alive() and !IsValid(ply.nutRagdoll) then
							ply:setRagdolled(true, 3)
						end
					end)
				end
			end,
			[2] = function(ply)
				if SERVER then
					ply:SetMaxHealth(ply:GetMaxHealth() * 0.75)
					ply:SetHealth(math.min(ply:Health(), ply:GetMaxHealth()))
				end
			end,
			[3] = function(ply)
				if CLIENT then
					jChems.Effects.ColorModify(Color(100, 0, 100))
				end
			end
		},
		["onAddictionCleared"] = function(ply)
			if IsValid(ply) then
				timer.Remove("UltraJetFalls" .. ply:SteamID64())
				ply:falloutNotify("✚ Your addiction has ended!", "ui/levelup.mp3")
			end
		end
	},
	["medx"] = {
		["name"] = "Med-X",
		["desc"] = "Provides +20 DR for 4 minutes or more if the chemist is skilled.",
		["model"] = "models/mosi/fallout4/props/aid/medx.mdl",
		["time"] = 90,
		["recipe"] = {
			["deionizedwater"] = 1,
			["napththol"] = 1
		},
		["use"] = function(item, ply, quality)
			if SERVER then
				ply:AddDR(20, 240, quality)
				ply:EmitSound("ui/stim.wav")
				ply:falloutNotify("✚ You feel more pain resistant . . .")
			end
		end,
		["addictionChance"] = 12,
		["addictionEffects"] = {
			[1] = function(ply)
				if SERVER then
					ply:falloutNotify("✚ Your Med-X addiction is satisfied", "ui/addicteds.wav")
				end

				if CLIENT then
					chat.AddText(Color(255,0,0), "➤ ", Color(255,125,125), "By feeding your addiction, you'll avoid a passive debuff:")
					chat.AddText(Color(255,255,255), "• ", Color(0,148,255), "Med-X Addiction:", Color(50,200,255), "-15% HP")
				end
			end,
			[2] = function(ply)
				if SERVER then
					ply:falloutNotify("✚ You feel addiction fatigue [-15% HP]", "ui/addicteds.wav")
					ply:SetMaxHealth(ply:GetMaxHealth() * 0.85)
					ply:SetHealth(math.min(ply:Health(), ply:GetMaxHealth()))
				end
					if CLIENT then
						jChems.Effects.Sobel()
						jChems.Effects.Blur()
					end
			end,
			[3] = function(ply)
				if SERVER then
					ply:falloutNotify("✚ You feel physically unable to jump", "ui/addicteds.wav")
					ply:SetJumpPower(0)
				end
			end
		}
	},
	["hydra"] = {
		["name"] = "Hydra",
		["desc"] = "Provides +25 DR for 2 minutes or more if the chemist is skilled.",
		["model"] = "models/fallout/hydra.mdl",
		["time"] = 100,
		["recipe"] = {
			["deionizedwater"] = 1,
			["seleniumdioxide"] = 1,
			["napththol"] = 1
		},
		["use"] = function(item, ply, quality)
			if SERVER then
				ply:AddDR(25, 120, quality)
				ply:falloutNotify("✚ You feel more paint resistant")
			else
				ply:EmitSound("ui/stim.wav")
			end
		end,
		["addictionChance"] = 7,
		["addictionEffects"] = {
			[1] = function(ply)
				if SERVER then
					ply:falloutNotify("✚ Your Hydra addiction is satisfied", "ui/addicteds.wav")
				end

				if CLIENT then
					chat.AddText(Color(255,0,0), "➤ ", Color(255,125,125), "By feeding your addiction, you'll avoid a passive debuff:")
					chat.AddText(Color(255,255,255), "• ", Color(0,148,255), "Hydra Addiction:", Color(50,200,255), " -15 SPD")
				end
			end,
			[2] = function(ply)
				if SERVER then
					ply:falloutNotify("✚ Your addiction fatigues you [-15 SPD]", "ui/addicteds.wav")
					ply:SetRunSpeed(ply:GetRunSpeed() * 0.85)
				end
				if CLIENT then
					jChems.Effects.Sobel()
					jChems.Effects.Blur()
				end
			end,
			[3] = function(ply)
				if SERVER then
					ply:falloutNotify("✚ You feel physically unable to jump", "ui/addicteds.wav")
					ply:SetJumpPower(0)
				end
			end
		}
	},
	["mentats"] = {
		["name"] = "Mentats",
		["desc"] = "Provides +2 INT, +2 PER for 5 minutes.",
		["model"] = "models/mosi/fallout4/props/aid/mentats.mdl",
		["time"] = 30,
		["recipe"] = {
			["deionizedwater"] = 1,
			["seleniumdioxide"] = 1
		},
		["use"] = function(item, ply, quality)
			if SERVER then
				local multi = jChems.Config.Multipliers[quality]
				ply:BuffStat("I", 2, 300 * multi, true)
				ply:BuffStat("P", 2, 300 * multi, true)
				ply:falloutNotify("You feel mentally sharper . . .")
			else
				jChems.Effects.Swallow()
				ply:EmitSound("ui/eating_mentats.wav")
			end
		end,
		["addictionChance"] = 60,
		["addictionEffects"] = {
			[1] = function(ply)
				if SERVER then
					ply:falloutNotify("✚ Your Mentats addiction is satisfied", "ui/addicteds.wav")
				end

				if CLIENT then
					chat.AddText(Color(255,0,0), "➤ ", Color(255,125,125), "By feeding your addiction, you'll avoid a passive debuff:")
					chat.AddText(Color(255,255,255), "• ", Color(0,148,255), "Mentats Addiction:", Color(50,200,255), " -2 PER")
				end
			end,
			[2] = function(ply)
				if SERVER then
					ply:falloutNotify("✚ You feel addiction fatigue [-2 PER]", "ui/addicteds.wav")
					ply:BuffStat("P", -2, -1)
				end

				if CLIENT then
					jChems.Effects.Sharpen()
					jChems.Effects.Sobel()
					jChems.Effects.Blur()
				end
			end,
			[3] = function(ply)
				if SERVER then
					ply:falloutNotify("✚ You feel less agile . . .", "ui/addicteds.wav")
					ply:SetRunSpeed(ply:GetRunSpeed() * 0.5)
				end
			end
		}
	},
	["orangementats"] = {
		["name"] = "Orange Mentats",
		["desc"] = "Provides +2 INT, +2 PER for 5 minutes | 0% Addiction Chance",
		["model"] = "models/fallout/orangementats.mdl",
		["time"] = 30,
		["recipe"] = {
			["deionizedwater"] = 1,
			["seleniumdioxide"] = 1
		},
		["use"] = function(item, ply, quality)
			if SERVER then
				local multi = jChems.Config.Multipliers[quality]
				ply:BuffStat("I", 2, 300 * multi, true)
				ply:BuffStat("P", 2, 300 * multi, true)
				ply:falloutNotify("You feel mentally sharper . . .")
			else
				jChems.Effects.Swallow()
				ply:EmitSound("ui/eating_mentats.wav")
			end
		end,
		["addictionChance"] = 0
	},
	["grapementats"] = {
		["name"] = "Grape Mentats",
		["desc"] = "Provides +2 INT, +2 PER for 5 minutes | 0% Addiction Chance",
		["model"] = "models/fallout/grapementats.mdl",
		["time"] = 30,
		["recipe"] = {
			["deionizedwater"] = 1,
			["seleniumdioxide"] = 1
		},
		["use"] = function(item, ply, quality)
			if SERVER then
				local multi = jChems.Config.Multipliers[quality]
				ply:BuffStat("I", 2, 300 * multi, true)
				ply:BuffStat("P", 2, 300 * multi, true)
				ply:falloutNotify("You feel mentally sharper . . .")
			else
				jChems.Effects.Swallow()
				ply:EmitSound("ui/eating_mentats.wav")
			end
		end,
		["addictionChance"] = 0
	},
	["berrymentats"] = {
		["name"] = "Berry Mentats",
		["desc"] = "Provides +2 INT, +2 PER for 5 minutes | 0% Addiction Chance",
		["model"] = "models/fallout/berrymentats.mdl",
		["time"] = 30,
		["recipe"] = {
			["deionizedwater"] = 1,
			["seleniumdioxide"] = 1
		},
		["use"] = function(item, ply, quality)
			if SERVER then
				local multi = jChems.Config.Multipliers[quality]
				ply:BuffStat("I", 2, 300 * multi, true)
				ply:BuffStat("P", 2, 300 * multi, true)
				ply:falloutNotify("✚ You feel mentally sharper . . .")
			else
				jChems.Effects.Swallow()
				ply:EmitSound("ui/eating_mentats.wav")
			end
		end,
		["addictionChance"] = 0
	},
	["xcell"] = {
		["name"] = "X-Cell",
		["desc"] = "Provides +2 to every stat for 5 minutes | +15% DR | +15% DMG Boost | Known as the most valuable chem in the wasteland.",
		["model"] = "models/mosi/fallout4/props/aid/xcell.mdl",
		["time"] = 3000,
		["recipe"] = {
			["deionizedwater"] = 5,
			["seleniumdioxide"] = 5,
			["methyltestosterone"] = 3,
			["aceticanhydride"] = 4
		},
		["use"] = function(item, ply, quality)
			if SERVER then
				local multi = jChems.Config.Multipliers[quality]
				ply:BuffStat("S", 5, 300 * multi, true)
				ply:BuffStat("P", 5, 300 * multi, true)
				ply:BuffStat("E", 5, 300 * multi, true)
				ply:BuffStat("C", 5, 300 * multi, true)
				ply:BuffStat("I", 5, 300 * multi, true)
				ply:BuffStat("A", 5, 300 * multi, true)
				ply:BuffStat("L", 5, 300 * multi, true)
				ply:AddSpeed(30, 300, quality)
				ply:AddDR(15, 300, quality)
				ply:AddDMG(15, 300, quality)
				ply:EmitSound("ui/stim.wav")
				ply:falloutNotify("✚ You feel like you have super powers . . .")
			else
				jChems.Effects.Swallow()
			end
		end,
		["addictionChance"] = 25,
		["addictionEffects"] = {
			[1] = function(ply)
				if SERVER then
					ply:falloutNotify("✚ Your X-Cell addiction is satisfied", "ui/addicteds.wav")
				end

				if CLIENT then
					chat.AddText(Color(255,0,0), "➤ ", Color(255,125,125), "By feeding your addiction, you'll avoid a passive debuff:")
					chat.AddText(Color(255,255,255), "• ", Color(0,148,255), "Mentats Addiction:", Color(50,200,255), " -5 INTEL")
				end
			end,
			[2] = function(ply)
				if SERVER then
					ply:falloutNotify("✚ You feel addiction fatigue [-5 INTEL]", "ui/addicteds.wav")
					ply:BuffStat("I", -5, -1)
				end

				if CLIENT then
					jChems.Effects.Sharpen()
					jChems.Effects.Sobel()
					jChems.Effects.Blur()
				end
			end,
			[3] = function(ply)
				if SERVER then
					ply:SetRunSpeed(ply:GetRunSpeed() * 0.5)
				end
			end
		}
	},
	["turbo"] = {
		["name"] = "Turbo",
		["desc"] = "Provides a brief but drastic speed buff that often results in unconciousness afterwards.",
		["model"] = "models/fallout/turbo.mdl",
		["time"] = 160,
		["recipe"] = {
			["deionizedwater"] = 1,
			["ketoacid"] = 1,
			["salicylicacid"] = 1
		},
		["use"] = function(item, ply, quality)
			if SERVER then
				ply:AddSpeed(80, 10, quality)
				ply:EmitSound("ui/using_jet.wav")
				ply:falloutNotify("You feel very energetic . . .")
			else
				jChems.Effects.Inhale()
			end
		end,
		["addictionChance"] = 5,
	},
	["psycho"] = {
		["name"] = "Psycho",
		["desc"] = "Provides +15 DR, +15 DMG for 1 minute or more if the chemist is skilled.",
		["model"] = "models/mosi/fallout4/props/aid/pyscho.mdl",
		["time"] = 160,
		["recipe"] = {
			["deionizedwater"] = 1,
			["aceticanhydride"] = 1
		},
		["use"] = function(item, ply, quality)
			if SERVER then
				ply:AddDR(15, 60, quality)
				ply:AddDMG(15, 60, quality)
				ply:EmitSound("ui/stim.wav")
				ply:falloutNotify("✚ You feel powerful yet angry . . .")
			else
				jChems.Effects.Inject()
			end
		end,
		["addictionChance"] = 25,
		["addictionEffects"] = {
			[1] = function(ply)
				if SERVER then
					ply:falloutNotify("✚ Your Psycho addiction is satisfied", "ui/addicteds.wav")
					ply:AddDMG(5, -1)
				end

				if CLIENT then
					chat.AddText(Color(255,0,0), "➤ ", Color(255,125,125), "By feeding your addiction, you'll avoid a passive debuff:")
					chat.AddText(Color(255,255,255), "• ", Color(0,148,255), "Psycho Addiction:", Color(50,200,255), "-15% SPD")
				end
			end,
			[2] = function(ply)
				if SERVER then
					ply:falloutNotify("✚ You feel addiction fatigued [-15% SPD]", "ui/addicteds.wav")
					ply:SetRunSpeed(ply:GetRunSpeed() * 0.85)
				else
					jChems.Effects.Sharpen()
					jChems.Effects.Sobel()
				end
			end,
			[3] = function(ply)
				if SERVER then
					ply:falloutNotify("✚ You feel an extreme headpain . . .", "ui/addicteds.wav")
					ply:SetRunSpeed(ply:GetWalkSpeed())
				else
					jChems.Effects.Sharpen()
					jChems.Effects.Sobel()
				end
			end
		}
	},
	["stimpack"] = {
		["name"] = "Stimpack",
		["desc"] = "Heals the injector by 65 HP over 10s or more if the chemist is skilled.",
		["model"] = "models/mosi/fallout4/props/aid/stimpak.mdl",
		["time"] = 90,
		["recipe"] = {
			["deionizedwater"] = 1,
			["aceticanhydride"] = 1
		},
		["use"] = function(item, ply, quality)
			if SERVER then
				ply:HealOverTime("Stimpack", 65, 10, quality)
				ply:EmitSound("ui/stim.wav")
				ply:falloutNotify("✚ You feel your wounds healing . . .")
			end
		end,
		["addictionChance"] = 0,
		["nonHuman"] = true
	},
	["doctorbag"] = {
		["name"] = "Super Stimpack",
		["desc"] = "Heals the user by 100 HP over 25s or more if the chemist is skilled.",
		["model"] = "models/fallout/superstimpak.mdl",
		["time"] = 120,
		["recipe"] = {
			["deionizedwater"] = 3,
			["aceticanhydride"] = 2
		},
		["use"] = function(item, ply, quality)
			if SERVER then
				ply:HealOverTime("SuperStim", 100, 15, quality)
				ply:falloutNotify("✚ You feel your wounds healing . . .")
				ply:EmitSound("ui/stim.wav")
			end
		end,
		["addictionChance"] = 0,
		["nonHuman"] = true
	},
	["realdoctorsbag"] = {
		["name"] = "Doctors Bag",
		["desc"] = "Heals the user by 100 HP over 25s.",
		["model"] = "models/fallout/doctorsbag.mdl",
		["time"] = 500,
		["recipe"] = {
			["deionizedwater"] = 3,
			["aceticanhydride"] = 2
		},
		["use"] = function(item, ply, quality)
			if SERVER then
				ply:HealOverTime("DoctorsBag", 100, 8, quality)
				ply:falloutNotify("✚ You feel your wounds healing . . .")
			end
		end,
		["addictionChance"] = 0,
		["nonHuman"] = true
	},
	["fixer"] = {
		["name"] = "Fixer",
		["desc"] = "Clears the user of all traces of previously consumed Chems. This chem takes 30 seconds to purge the body fully.",
		["model"] = "models/fallout/fixer.mdl",
		["time"] = 240,
		["recipe"] = {
			["deionizedwater"] = 2,
			["methyltestosterone"] = 1,
			["acetone"] = 1,
			["salicylicacid"] = 1
		},
		["use"] = function(item, ply, quality)
			if SERVER then
				ply:ScreenFade(SCREENFADE.IN, Color(255,255,255,155), 0.5, 1)
				ply:falloutNotify("Your Chem traces will purge in 30 seconds")
				ply:EmitSound("ui/eating_mentats.wav")

				local charID = ply:getChar():getID()

				timer.Simple(30, function()
					if IsValid(ply) and charID == ply:getChar():getID() then
						ply:falloutNotify("✚ Your feel your body cleanse itself", "fx/fx_poison_stinger.mp3")
						jChems.ClearHistory(ply)
					end
				end)
			end
		end,
		["addictionChance"] = 0
	},
	["addictol"] = {
		["name"] = "Addictol",
		["desc"] = "Clears the user of all addictions",
		["model"] = "models/fallout/addictol.mdl",
		["time"] = 240,
		["recipe"] = {
			["deionizedwater"] = 2,
			["methyltestosterone"] = 1,
			["acetone"] = 1,
			["salicylicacid"] = 1
		},
		["use"] = function(item, ply, quality)
			if SERVER then
				jChems.ClearAllAddictions(ply)

				ply:falloutNotify("✚ Your addictions have been purged!", "ui/paintjob.mp3")
			else
				jChems.Effects.Inhale()
			end
		end,
		["addictionChance"] = 0
	}
}
for k, v in pairs(jChems.Chems) do
	v.uniqueID = k
end

hook.Add("InitPostEntity", "ChemsInit", function()
	-- Used for the backpack blacklist system
	nut.config.add("allowChemsInBackpacks", false, "Should chems be storable in backpacks?", false, {
		category = "chems"
	})

	-- Used for balancing heal rate live in-game
	nut.config.add("healRate", 2, "At what rate should chems regenerate health? (Lower = Faster)", nil, {
		data = {min = 0.01, max = 10},
		category = "chems"
	})

	local allowedPAChems = {
		["Stimpack"] = true,
		["Super Stimpack"] = true,
		["Addictol"] = true,
	}
	for k, v in pairs(jChems.Chems) do
		local ITEM = nut.item.register(k, nil, false, nil, true)
		ITEM.name    = v.name
		ITEM.model   = v.model
		ITEM.isChem = true
		ITEM.getDesc = function(item)
			return v.desc .. "\nConcocted by a " .. jChems.Config.SkillLevels[item:getData("quality", 0)]
		end

		ITEM["functions"].Use = {onRun = function(item)
			local ply = item.player

			if ply:IsSynth() then
				ply:falloutNotify("[SYNTH] You can not consume this...", "ui/ui_hacking_bad.mp3")
				return false
			end

			if !Armor.IsHuman(ply:getChar()) and !v.nonHuman then
				ply:falloutNotify("Only humans can use this chem.")
				return
			end

			if ply:IsHandcuffed() or ply:getNetVar("restricted") then
				ply:falloutNotify("You cannot eat this while tied . . .", "ui/notify.mp3")
				return false
			end

			if ply:WearingPA() and !allowedPAChems[v.name] then
				ply:falloutNotify("You can't use consume this while wearing PA.", "ui/notify.mp3")
				return false
			end

			jChems.RollAddiction(v, ply)
			v.use(item, ply, item:getData("quality", 0))

			if SERVER then
				net.Start("ChemsUse")
					net.WriteString(k)
					net.WriteUInt(item:getData("quality", 0), 32)
				net.Send(ply)

				jChems.AddToHistory(k, ply)
			end
		end}
	end

	for k, v in pairs(jChems.Components) do
		local ITEM = nut.item.register(k, nil, false, nil, true)
		ITEM.name    = v.name
		ITEM.model   = v.model
		ITEM.desc    = "A bottle of " .. v.name
	end

	nut.command.add("givechemmats", {
		superAdminOnly = true,
		syntax = "<string chemID> <integer amount>",
		onRun = function(ply, args)
			local materials = jChems.Chems[args[1]].recipe

			for j = 1, args[2] or 1 do
				for k,v in pairs(materials) do
					for i = 1, v do
						ply:getChar():getInv():add(k)
					end
				end
			end
		end
	})

	nut.command.add("wipeoldchems", {
		superAdminOnly = true,
		onRun = function(ply, args)
			--Remove all entries of old chem items from marketplace
			nut.db.query("DELETE FROM `nut_marketplace` WHERE _itemID LIKE 'jonjo_%';")

			--Remove all entries of old chem items from stash
			//for id, char in pairs(nut.char.loaded) do
			//    local stash = char:getStash()

			//    if table.Count(stash) == 0 then
			//        continue
			//    end

			//    for itemID, _ in pairs(stash) do
			//        local item = nut.item.instances[itemID]

			//        if !item then
			//            stash[itemID] = nil
			//        end
			//    end

			//    char:setStash(stash)
			//end

			nut.db.query("SELECT * FROM `nut_stash`;", function(response)
				for k, v in pairs(response) do
					local itemIDs = util.JSONToTable(v._items)

					for itemID, _ in pairs(itemIDs) do
						nut.db.query("SELECT * FROM `nut_items` WHERE _itemID = '" .. itemID .. "';", function(data)
							if data and data[1] and data[1]._uniqueID:StartWith("jonjo_") then
								itemIDs[itemID] = nil
								//print(itemID .. " removed from " .. v._charID " stash")
							end
						end)
					end

					local json = util.TableToJSON(itemIDs)
					nut.db.query("UPDATE `nut_stash` SET _items = '" .. json .. "' WHERE _charID = " .. v._charID .. ";")
				end
			end)

			--Remove all entires of old chem items from items
			nut.db.query("DELETE FROM `nut_items` WHERE _uniqueID LIKE 'jonjo_%';")
		end
	})

	local ITEM = nut.item.register("chem_test_kit", nil, false, nil, true)
	ITEM.name = "Chem Test Kit"
	ITEM.desc = "This can be used to test what drugs someone has taken in the last " .. string.NiceTime(jChems.Config.TestKitTime)
	ITEM.model = "models/fallout/rebound.mdl"
	
	function ITEM:getDesc()
		return self:getData("testResult", self.desc)
	end
	
	ITEM.functions.Use = {
		onRun = function(item)
			local ply = item.player
			local target = ply:GetEyeTrace().Entity
	
			if IsValid(ply) and IsValid(target) and target:IsPlayer() and target:Alive() then
	
				if target:GetPos():DistToSqr(ply:GetPos()) > 200 * 200 then
					ply:falloutNotify("You are too far away!")
					return false
				end
	
				jlib.RequestBool("Do you wish to use your chem test?", function(bool)
					if bool and IsValid(ply) and IsValid(target) then
						ply:ConCommand("say /it takes a sample of the persons blood & mixes with test kit...")
						target:EmitSound("items/medshot4.wav", 0.75, 0.7)
						target:ScreenFade(SCREENFADE.IN, Color(255,255,255,155), 0.5, 2)
						target:TakeDamage(1, ply, ply)
						target:falloutNotify("Someone has used a chem test on you...", "fx/fx_poison_stinger.mp3")
	
						jlib.Announce(ply, Color(255,0,0), "[CHEM TEST KIT]", Color(255,255,255), " Your chem test will finish mixing in 30 seconds...")
						item:setData("used", true)
						item:setData("testResult", "A chem test kit that's currently processing it's results...")
	
						local testResult = "Chem Use Results" .. " (" .. string.NiceTime(jChems.Config.TestKitTime) .. ")" .. ":"
						local chemsDone = jChems.GetChemsDone(target, jChems.Config.TestKitTime)
	
						if #chemsDone > 0 then
							for i, chemID in ipairs(chemsDone) do
								testResult = testResult .. "\n· " .. jChems.Chems[chemID].name .. " : ☑\n"
							end
						else
							testResult = testResult .. "\nNone : ☒"
						end
	
						timer.Simple(30, function()
							if item and IsValid(ply) then
								ply:falloutNotify("☑ Your chem test results are ready")
								ply:EmitSound("items/medshot4.wav", 0.75, 0.7)
	
								item:setData("testResult", testResult)
							elseif item then
								item:setData("used", false)
								item:setData("testResult", nil)
							end
						end)
					end
				end, ply, "Yes", "No")
			end
	
			return false
		end,
		onCanRun = function(item)
			return !IsValid(item.entity) and !item:getData("used", false)
		end
	}
end)


--Addiction
function jChems.ClearAllAddictions(ply)
	if !IsValid(ply) or !ply.addictions then
		return
	end

	for id, level in pairs(ply.addictions) do
		jChems.ClearAddiction(ply, id)
	end
end

function jChems.ClearAddiction(ply, id)
	if SERVER then
		if !IsValid(ply) or !ply.addictions then
			return
		end

		ply.addictions[id] = nil

		if timer.Exists(id .. ply:SteamID64()) then
			timer.Remove(id .. ply:SteamID64())
		end

		jlib.ResetPlayer(ply)

		net.Start("ChemsClearAddiction")
			net.WriteString(id)
		net.Send(ply)

		ply:getChar():setData("addictions", table.Copy(ply.addictions))
	else
		jChems.Effects.Clear()
	end

	if isfunction(jChems.Chems[id].onAddictionCleared) then
		jChems.Chems[id].onAddictionCleared(ply)
	end
end

net.Receive("ChemsClearAddiction", function()
	jChems.ClearAddiction(LocalPlayer(), net.ReadString())
end)
