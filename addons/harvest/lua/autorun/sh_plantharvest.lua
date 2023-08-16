Harvest = Harvest or {}
Harvest.Spawns = Harvest.Spawns or {}
Harvest.Plants = {
	-- CHEM INGREDIENTS --
	["Jalapeno"] = {
		["PrintName"] = "Jalapeno",
		["Desc"] = "A very hot pepper",
		["PlantModel"] = "models/mosi/fnv/props/plants/jalapeno.mdl",
		["ItemModel"] = "models/mosi/fnv/props/jalapenopepper.mdl",
		["Effect"] = function(ply)
			if SERVER then
				ply:ConCommand("say /it chews on some raw Jalapeno . . .")
				ply:Ignite(5)
				ply:EmitSound("ui/eating_food_0" .. math.random(1,5) .. ".wav")
				ply:AddHunger(10)
				ply:addRadsUpdate(4)

				local dat = EffectData()
				dat:SetColor(BLOOD_COLOR_ANTLION_WORKER)
				dat:SetOrigin(ply:GetPos() + (Vector(0, 0, 63)))
				util.Effect("BloodImpact", dat, true, true)

				timer.Simple(4, function()
					if !IsValid(ply) then return end
					ply:ChatPrint("( The flavor indicates this can be used as a chem ingredient )")
				end)
			end
		end
	},
	["BarrelCactus"] = {
		["PrintName"] = "Barrel Cactus Fruit",
		["Desc"] = "A sweet fruit harvested from a barrel cactus",
		["PlantModel"] = "models/mosi/fnv/props/plants/barrelcactus.mdl",
		["ItemModel"] = "models/mosi/fnv/props/barrelcactus.mdl",
		["Effect"] = function(ply)
			if SERVER then
				ply:ConCommand("say /it chews on some raw Barrel Cactus Fruit . . .")
				ply:EmitSound("ui/eating_food_0" .. math.random(1,5) .. ".wav")
			end
			if CLIENT then
				jlib.Hallucinate(40, "https://claymoregaming.com/sandman.mp3")
			end
		end
	},
	["CoyoteTobacco"] = {
		["PrintName"] = "Coyote Tobacco",
		["Desc"] = "50/50 odds of either getting +10 DR or falling unconscious for 15s",
		["PlantModel"] = "models/mosi/fnv/props/plants/coyotetobacco.mdl",
		["ItemModel"] = "models/mosi/fnv/props/coyotetobacco.mdl",
		["Effect"] = function(ply)
			if SERVER then
				local num = math.random()
				ply:EmitSound("ui/eating_food_0" .. math.random(1,5) .. ".wav")
				ply:ConCommand("say /it chews on some raw Coyote Tobacco . . .")

				if num < 0.5 then
					ply:AddDR(10, 120)
				else
					ply:Knockout(ply, true)
					ply:ChatPrint("... The chew chews YOU . . .")
				end

				local dat = EffectData()
				dat:SetColor(BLOOD_COLOR_ANTLION_WORKER)
				dat:SetOrigin(ply:GetPos() + (Vector(0, 0, 63)))
				util.Effect("BloodImpact", dat, true, true)
				ply:addRadsUpdate(3)

				timer.Simple(4, function()
					if !IsValid(ply) then return end
					ply:ChatPrint("( The flavor indicates this can be used as a chem ingredient )")
				end)
			end
		end
	},
	["HoneyMesquite"] = {
		["PrintName"] = "Honey Mesquite Pod",
		["Desc"] = "The honey mesquite pod grows on a short tree with willow-like branches.",
		["PlantModel"] = "models/mosi/fnv/props/plants/honeymesquite.mdl",
		["ItemModel"] = "models/mosi/fnv/props/honeymesquite.mdl",
		["Effect"] = function(ply)
			if SERVER then
				local dat = EffectData()
				dat:SetColor(BLOOD_COLOR_ANTLION_WORKER)
				dat:SetOrigin(ply:GetPos() + (Vector(0, 0, 63)))
				util.Effect("BloodImpact", dat, true, true)
				ply:EmitSound("ui/eating_food_0" .. math.random(1,5) .. ".wav")
				ply:addRadsUpdate(5)

				ply:ConCommand("say /it chews on some raw Honey Pods . . .")

				timer.Simple(4, function()
					if !IsValid(ply) then return end
					ply:ChatPrint("( The flavor indicates this can be used as a chem ingredient )")
				end)
			end
		end
	},
	["PricklyPear"] = {
		["PrintName"] = "Prickly Pear Fruit",
		["Desc"] = "A sweet fruit harvested from a prickly pear cactus",
		["PlantModel"] = "models/mosi/fnv/props/plants/pricklypearcactus.mdl",
		["ItemModel"] = "models/mosi/fnv/props/pricklypearcactus.mdl",
		["Effect"] = function(ply)
			if SERVER then
				ply:EmitSound("npc/barnacle/barnacle_gulp2.wav")
				ply:ConCommand("say /it chews on some raw Barrel Cactus Fruit . . .")
			end
			if CLIENT then
				jlib.Hallucinate(40, "https://claymoregaming.com/sandman.mp3")
			end
		end
	},
	["Fungus"] = {
		["PrintName"] = "Fungus",
		["Desc"] = "Looks like it might make for a tasty snack",
		["PlantModel"] = "models/mosi/fnv/props/plants/cavefungus.mdl",
		["ItemModel"] = "models/mosi/fnv/props/plants/cavefungus.mdl",
		["Effect"] = function(ply)
			if SERVER && !ply.fungusUnconcious then
				ply:EmitSound("ui/eating_food_0" .. math.random(1,5) .. ".wav")
				ply:ConCommand("say /it chews on some strange Fungus . . .")
				ply:Knockout(ply, true)

				local dat = EffectData()
				dat:SetColor(BLOOD_COLOR_ANTLION_WORKER)
				dat:SetOrigin(ply:GetPos() + (Vector(0, 0, 63)))
				util.Effect("BloodImpact", dat, true, true)
				ply:addRadsUpdate(10)

				timer.Simple(4, function()
					if !IsValid(ply) then return end
					ply:ChatPrint("( The flavor indicates this can be used as a chem ingredient )")
				end)
			end
		end
	},
	["Flower"] = {
		["PrintName"] = "Broc Flower",
		["Desc"] = "It's a flower",
		["PlantModel"] = "models/mosi/fnv/props/plants/brocflower.mdl",
		["ItemModel"] = "models/mosi/fnv/props/brocflower.mdl",
		["Effect"] = function(ply)
			if SERVER then
				ply:ConCommand("say /it chews on some raw Broc Flower . . .")
				ply:EmitSound("ui/eating_food_0" .. math.random(1,5) .. ".wav")
			end
		end
	},
	["Banana"] = {
		["PrintName"] = "Banana Yucca",
		["Desc"] = "A nutritious plant with medicinal effects",
		["PlantModel"] = "models/mosi/fnv/props/plants/bananayucca.mdl",
		["ItemModel"] = "models/mosi/fnv/props/bananayucca.mdl",
		["Effect"] = function(ply)
			if SERVER then
				jlib.HealOverTime(ply, "Banana", 10, 10)
				ply:EmitSound("ui/eating_food_0" .. math.random(1,5) .. ".wav")
				ply:ConCommand("say /it chews on some raw Banana Yucca . . .")
				ply:addRadsUpdate(5)

				timer.Simple(4, function()
					if !IsValid(ply) then return end
					ply:ChatPrint("( The flavor indicates this can be used as a chem ingredient )")
				end)
			end
		end
	},
	-- FOOD HYBRID ITEMS --
	["WildTarberry"] = {
		["PrintName"] = "Wild Tarberry",
		["Desc"] = "Wild Wasteland fruit.",
		["PlantModel"] = "models/a31/fallout4/props/plants/tarberryplant02.mdl",
		["ItemModel"] = "models/a31/fallout4/props/plants/tarberry_item.mdl",
		["Effect"] = function(ply)
			if SERVER then
				jlib.HealOverTime(ply, "Tarberry", 10, 10)
				ply:AddHunger(10)
				ply:EmitSound("ui/eating_food_0" .. math.random(1,5) .. ".wav")
				ply:ConCommand("say /it chews on some raw Wild Tarberry . . .")
				ply:addRadsUpdate(5)

				local dat = EffectData()
				dat:SetColor(BLOOD_COLOR_ANTLION_WORKER)
				dat:SetOrigin(ply:GetPos() + (Vector(0, 0, 63)))
				util.Effect("BloodImpact", dat, true, true)
			end
		end
	},
	["Razorgraine"] = {
		["PrintName"] = "Razorgraine",
		["Desc"] = "Also known as Wasteland Maize.",
		["PlantModel"] = "models/mosi/fnv/props/plants/maize.mdl",
		["ItemModel"] = "models/mosi/fnv/props/maize.mdl",
		["Effect"] = function(ply)
			if SERVER then
				jlib.HealOverTime(ply, "Maize", 10, 10)
				ply:AddHunger(10)
				ply:EmitSound("ui/eating_food_0" .. math.random(1,5) .. ".wav")
				ply:ConCommand("say /it eats some Razorgraine . . .")
				ply:addRadsUpdate(5)

				local dat = EffectData()
				dat:SetColor(BLOOD_COLOR_ANTLION_WORKER)
				dat:SetOrigin(ply:GetPos() + (Vector(0, 0, 63)))
				util.Effect("BloodImpact", dat, true, true)
			end
		end
	},
	["Whitehorsenettle"] = {
		["PrintName"] = "White Horsenettle",
		["Desc"] = "A bunch of Horsenettle Seeds.",
		["PlantModel"] = "models/mosi/fnv/props/plants/whitehorsenettle.mdl",
		["ItemModel"] = "models/mosi/fnv/props/whitehorsenettle.mdl",
		["Effect"] = function(ply)
			if SERVER then
				jlib.HealOverTime(ply, "Seeds", 10, 10)
				ply:AddHunger(10)
				ply:EmitSound("ui/eating_food_0" .. math.random(1,5) .. ".wav")
				ply:ConCommand("say /it chews on a bunch of random seeds . . .")
				ply:addRadsUpdate(4)

				local dat = EffectData()
				dat:SetColor(BLOOD_COLOR_ANTLION_WORKER)
				dat:SetOrigin(ply:GetPos() + (Vector(0, 0, 63)))
				util.Effect("BloodImpact", dat, true, true)
			end
		end
	},
	["NevadaAgave"] = {
		["PrintName"] = "Nevada Agave",
		["Desc"] = "A rare wasteland plant often used for healing skin blemishes.",
		["PlantModel"] = "models/mosi/fnv/props/plants/nevadaagave.mdl",
		["ItemModel"] = "models/mosi/fnv/props/nevadaagave.mdl",
		["Effect"] = function(ply)
			if SERVER then
				jlib.HealOverTime(ply, "Agave", 10, 10)
				ply:AddHunger(10)
				ply:EmitSound("ui/eating_food_0" .. math.random(1,5) .. ".wav")
				ply:ConCommand("say /it chews on some raw Nevada Agave . . .")
				ply:addRadsUpdate(5)

				local dat = EffectData()
				dat:SetColor(BLOOD_COLOR_ANTLION_WORKER)
				dat:SetOrigin(ply:GetPos() + (Vector(0, 0, 63)))
				util.Effect("BloodImpact", dat, true, true)

				timer.Simple(4, function()
					if !IsValid(ply) then return end
					ply:ChatPrint("( The flavor indicates this can be used as a chem ingredient )")
				end)
			end
		end
	},
	["Xanderroot"] = {
		["PrintName"] = "Xanderroot",
		["Desc"] = "A root often used for medicinal purposes.",
		["PlantModel"] = "models/mosi/fnv/props/plants/xanderroot02.mdl",
		["ItemModel"] = "models/mosi/fnv/props/xanderroot.mdl",
		["Effect"] = function(ply)
			if SERVER then
				jlib.HealOverTime(ply, "Xander", 10, 10)
				ply:AddHunger(10)
				ply:EmitSound("ui/eating_food_0" .. math.random(1,5) .. ".wav")
				ply:ConCommand("say /it chews on some raw Xanderroot . . .")
				ply:addRadsUpdate(10)

				local dat = EffectData()
				dat:SetColor(BLOOD_COLOR_ANTLION_WORKER)
				dat:SetOrigin(ply:GetPos() + (Vector(0, 0, 63)))
				util.Effect("BloodImpact", dat, true, true)

				timer.Simple(4, function()
					if !IsValid(ply) then return end
					ply:ChatPrint("( The flavor indicates this can be used as a chem ingredient )")
				end)
			end
		end
	},
	["PintoPod"] = {
		["PrintName"] = "Pinto Pod",
		["Desc"] = "A pod of Pinto beans.",
		["PlantModel"] = "models/mosi/fnv/props/plants/pinto.mdl",
		["ItemModel"] = "models/mosi/fnv/props/pintobeanpod.mdl",
		["Effect"] = function(ply)
			if SERVER then
				jlib.HealOverTime(ply, "Pinto", 10, 10)
				ply:AddHunger(10)
				ply:EmitSound("ui/eating_food_0" .. math.random(1,5) .. ".wav")
				ply:ConCommand("say /it chews on some raw Pinto Pods . . .")
				ply:addRadsUpdate(5)

				local dat = EffectData()
				dat:SetColor(BLOOD_COLOR_ANTLION_WORKER)
				dat:SetOrigin(ply:GetPos() + (Vector(0, 0, 63)))
				util.Effect("BloodImpact", dat, true, true)

				timer.Simple(4, function()
					if !IsValid(ply) then return end
					ply:ChatPrint("( The flavor indicates this can be used as a chem ingredient )")
				end)
			end
		end
	},
	["BuffaloGoard"] = {
		["PrintName"] = "Buffalo Goard",
		["Desc"] = "A vegitatious wasteland delicacy.",
		["PlantModel"] = "models/mosi/fnv/props/plants/buffalogourd.mdl",
		["ItemModel"] = "models/mosi/fnv/props/buffalogourd.mdl",
		["Effect"] = function(ply)
			if SERVER then
				jlib.HealOverTime(ply, "Goard", 10, 10)
				ply:AddHunger(10)
				ply:EmitSound("ui/eating_food_0" .. math.random(1,5) .. ".wav")
				ply:ConCommand("say /it tears open and devours an entire Gourd . . .")
				ply:addRadsUpdate(5)

				local dat = EffectData()
				dat:SetColor(BLOOD_COLOR_ANTLION_WORKER)
				dat:SetOrigin(ply:GetPos() + (Vector(0, 0, 63)))
				util.Effect("BloodImpact", dat, true, true)
			end
		end
	},
	-- TRUE FOOD ITEMS --
	["Food_Melon"] = {
		["PrintName"] = "Melon",
		["Desc"] = "A vegitatious wasteland delicacy.",
		["PlantModel"] = "models/mosi/fnv/props/plants/buffalogourd.mdl",
		["ItemModel"] = "models/a31/fallout4/props/plants/melon_item.mdl",
		["Effect"] = function(ply)
			if SERVER then
				jlib.HealOverTime(ply, "Melon", 25, 10)
				ply:AddHunger(10)
				ply:EmitSound("ui/eating_food_0" .. math.random(1,5) .. ".wav")
				ply:ConCommand("say /it tears open and devours an entire Melon . . .")
				ply:addRadsUpdate(6)

				local dat = EffectData()
				dat:SetColor(BLOOD_COLOR_ANTLION_WORKER)
				dat:SetOrigin(ply:GetPos() + (Vector(0, 0, 63)))
				util.Effect("BloodImpact", dat, true, true)
			end
		end
	},
	["Food_Pumpkin"] = {
		["PrintName"] = "Pumpkin",
		["Desc"] = "A vegitatious wasteland delicacy.",
		["PlantModel"] = "models/luria/sonic_mania/phantom_ruby.mdl",
		["ItemModel"] = "models/a31/fallout4/props/plants/pumpkin_item.mdl",
		["Effect"] = function(ply)
			if SERVER then
				jlib.HealOverTime(ply, "Pumpkin", 25, 10)
				ply:AddHunger(10)
				ply:EmitSound("ui/eating_food_0" .. math.random(1,5) .. ".wav")
				ply:ConCommand("say /it tears open and devours an entire Pumpkin . . .")
				ply:addRadsUpdate(6)

				local dat = EffectData()
				dat:SetColor(BLOOD_COLOR_ANTLION_WORKER)
				dat:SetOrigin(ply:GetPos() + (Vector(0, 0, 63)))
				util.Effect("BloodImpact", dat, true, true)
			end
		end
	},
	["Food_TarberryPie"] = {
		["PrintName"] = "Tarberry Pie",
		["Desc"] = "A nutritious wasteland pie.",
		["PlantModel"] = "models/luria/sonic_mania/phantom_ruby.mdl",
		["ItemModel"] = "models/mosi/skyrim/fooddrink/pie.mdl",
		["Effect"] = function(ply)
			if SERVER then
				jlib.HealOverTime(ply, "TarberryPie", 50, 30)
				ply:AddHunger(85)
				ply:EmitSound("ui/eating_food_0" .. math.random(1,5) .. ".wav")
				ply:ConCommand("say /it eats an entire Tarberry Pie . . .")
				ply:addRadsUpdate(4)

				local dat = EffectData()
				dat:SetColor(BLOOD_COLOR_ANTLION_WORKER)
				dat:SetOrigin(ply:GetPos() + (Vector(0, 0, 63)))
				util.Effect("BloodImpact", dat, true, true)
			end
		end
	},
	["Food_MutFruitPie"] = {
		["PrintName"] = "Mutfruit Pie",
		["Desc"] = "A nutritious wasteland pie.",
		["PlantModel"] = "models/luria/sonic_mania/phantom_ruby.mdl",
		["ItemModel"] = "models/mosi/skyrim/fooddrink/pie.mdl",
		["Effect"] = function(ply)
			if SERVER then
				jlib.HealOverTime(ply, "MutfruitPie", 50, 30)
				ply:AddHunger(85)
				ply:EmitSound("ui/eating_food_0" .. math.random(1,5) .. ".wav")
				ply:ConCommand("say /it eats an entire Mutfruit pie . . .")
				ply:addRadsUpdate(4)

				local dat = EffectData()
				dat:SetColor(BLOOD_COLOR_ANTLION_WORKER)
				dat:SetOrigin(ply:GetPos() + (Vector(0, 0, 63)))
				util.Effect("BloodImpact", dat, true, true)
			end
		end
	},
	["Food_PumpkinPie"] = {
		["PrintName"] = "Pumpkin Pie",
		["Desc"] = "A nutritious wasteland pie.",
		["PlantModel"] = "models/luria/sonic_mania/phantom_ruby.mdl",
		["ItemModel"] = "models/mosi/skyrim/fooddrink/pie.mdl",
		["Effect"] = function(ply)
			if SERVER then
				jlib.HealOverTime(ply, "PumpkinPie", 50, 30)
				ply:AddHunger(85)
				ply:EmitSound("ui/eating_food_0" .. math.random(1,5) .. ".wav")
				ply:ConCommand("say /it eats an entire Pumpkin pie . . .")
				ply:addRadsUpdate(4)

				local dat = EffectData()
				dat:SetColor(BLOOD_COLOR_ANTLION_WORKER)
				dat:SetOrigin(ply:GetPos() + (Vector(0, 0, 63)))
				util.Effect("BloodImpact", dat, true, true)
			end
		end
	},
	["Food_MysteriousMeat"] = {
		["PrintName"] = "Mysterious Cooked Meat",
		["Desc"] = "Cooked meat from an unknown source . . .",
		["PlantModel"] = "models/luria/sonic_mania/phantom_ruby.mdl",
		["ItemModel"] = "models/mosi/fallout4/props/food/stingwingfillet.mdl",
		["Effect"] = function(ply)
			if SERVER then
				jlib.HealOverTime(ply, "MysteriousMeat", 15, 15)
				ply:AddHunger(25)
				ply:EmitSound("ui/eating_food_0" .. math.random(1,5) .. ".wav")
				ply:ConCommand("say /it eats a slice of mysterious meat . . .")
				ply:addRadsUpdate(10)

				local dat = EffectData()
				dat:SetColor(BLOOD_COLOR_RED)
				dat:SetOrigin(ply:GetPos() + (Vector(0, 0, 63)))
				util.Effect("BloodImpact", dat, true, true)
			end
		end
	},
	["Food_WastelandStew"] = {
		["PrintName"] = "Wasteland Stew",
		["Desc"] = "Cooked meat from an unknown source . . .",
		["PlantModel"] = "models/luria/sonic_mania/phantom_ruby.mdl",
		["ItemModel"] = "models/mosi/fallout4/props/food/squirrelsoup.mdl",
		["Effect"] = function(ply)
			if SERVER then
				jlib.HealOverTime(ply, "Stew", 100, 100)
				ply:AddHunger(35)
				ply:EmitSound("npc/barnacle/barnacle_gulp1.wav")
				ply:ConCommand("say /it slurps the stew . . .")
				ply:BuffStat("E", 2, 300)
				ply:addRadsUpdate(5)

				local dat = EffectData()
				dat:SetColor(BLOOD_COLOR_YELLOW)
				dat:SetOrigin(ply:GetPos() + (Vector(0, 0, 63)))
				util.Effect("BloodImpact", dat, true, true)
			end
		end
	},
	-- CUSTOM DRINKS --
	["Food_HomemadeWine"] = {
		["PrintName"] = "Homemade Wine",
		["Desc"] = "A bottle of homemade Wine.",
		["PlantModel"] = "models/luria/sonic_mania/phantom_ruby.mdl",
		["ItemModel"] = "models/mosi/skyrim/fooddrink/wine2a.mdl",
		["Effect"] = function(ply)
			if SERVER then
				ply:EmitSound("npc/barnacle/barnacle_gulp2.wav")
				ply:ConCommand("say /it glugs a bottle of homemade wine . . .")

				timer.Simple(4, function()
					local num = math.random()
					if num < 0.2 then
						ply:BuffStat("E", 3, 300)
						ply:addRadsUpdate(10)
						ply:ChatPrint("... The Wine tastes . . . Homemade")
						ply:EmitSound("vo/npc/Barney/ba_ohyeah.wav")
					else
						ply:Knockout(ply, true)
						ply:ChatPrint("... The Wine is stronger than you can handle . . .")
						ply:addRadsUpdate(10)
						ply:EmitSound("vo/npc/Barney/ba_ohshit03.wav")
					end
				end)
			end
		end
	},
	["Food_ExoticHomemadeWine"] = {
		["PrintName"] = "Exotic Homemade Wine",
		["Desc"] = "A bottle of Exotic Homemade Wine",
		["PlantModel"] = "models/luria/sonic_mania/phantom_ruby.mdl",
		["ItemModel"] = "models/mosi/skyrim/fooddrink/wine2b.mdl",
		["Effect"] = function(ply)
			if SERVER then
				ply:EmitSound("npc/barnacle/barnacle_gulp2.wav")
				ply:ConCommand("say /it glugs an entire bottle of wine . . .")

				timer.Simple(4, function()
					local num = math.random()
					if num < 0.2 then
						ply:BuffStat("E", 6, 300)
						ply:addRadsUpdate(5)
						ply:ChatPrint("... The Exotic Wine tastes . . . exotic")
						ply:EmitSound("vo/npc/Barney/ba_ohyeah.wav")
					else
						ply:Knockout(ply, true)
						ply:ChatPrint("... The Wine is stronger than you can handle . . .")
						ply:addRadsUpdate(5)
						ply:EmitSound("vo/npc/Barney/ba_ohshit03.wav")
					end
				end)
			end
		end
	},
	["Food_HomemadeAle"] = {
		["PrintName"] = "Homemade Ale",
		["Desc"] = "A bottle of homemade Ale.",
		["PlantModel"] = "models/luria/sonic_mania/phantom_ruby.mdl",
		["ItemModel"] = "models/mosi/skyrim/fooddrink/wine1a.mdl",
		["Effect"] = function(ply)
			if SERVER then
				ply:EmitSound("npc/barnacle/barnacle_gulp2.wav")
				ply:ConCommand("say /it glugs an entire bottle of ale . . .")
				timer.Simple(4, function()
					local num = math.random()
					if num < 0.5 then
						ply:BuffStat("S", 5, 300)
						ply:addRadsUpdate(10)
						ply:ChatPrint("...  The Ale tastes strong . . .")
						ply:EmitSound("vo/npc/Barney/ba_ohyeah.wav")
					else
						ply:Knockout(ply, true)
						ply:ChatPrint("... The Ale is stronger than you can handle . . .")
						ply:addRadsUpdate(10)
						ply:EmitSound("vo/npc/Barney/ba_ohshit03.wav")
					end
				end)
			end
		end
	},
	["Food_ExoticHomemadeAle"] = {
		["PrintName"] = "Exotic Homemade Ale",
		["Desc"] = "A bottle of Exotic homemade Ale.",
		["PlantModel"] = "models/luria/sonic_mania/phantom_ruby.mdl",
		["ItemModel"] = "models/mosi/skyrim/fooddrink/wine1b.mdl",
		["Effect"] = function(ply)
			if SERVER then
				ply:EmitSound("npc/barnacle/barnacle_gulp2.wav")
				ply:ConCommand("say /it glugs an entire bottle of ale . . .")
				timer.Simple(4, function()
				local num = math.random()
					if num < 0.5 then
						ply:BuffStat("S", 5, 300)
						ply:BuffStat("P", 2, 300)
						ply:addRadsUpdate(5)
						ply:ChatPrint("... The Ale tastes POWERFUL . . .")
						ply:EmitSound("vo/npc/Barney/ba_ohyeah.wav")
					else
						ply:Knockout(ply, true)
						ply:ChatPrint("... The Ale is far to exotic for you . . .")
						ply:addRadsUpdate(5)
						ply:EmitSound("vo/npc/Barney/ba_ohshit03.wav")
					end
				end)
			end
		end
	},
	["Food_MagnumOpus"] = {
		["PrintName"] = "Magnum Opus",
		["Desc"] = "A bottle of the best liquor ever made.",
		["PlantModel"] = "models/luria/sonic_mania/phantom_ruby.mdl",
		["ItemModel"] = "models/mosi/skyrim/fooddrink/decanter.mdl",
		["Effect"] = function(ply)
			if SERVER then
				ply:EmitSound("npc/barnacle/barnacle_gulp1.wav")
				ply:ConCommand("say /it glugs an entire bottle of perfection . . .")
				ply:BuffStat("S", 5, 500)
				ply:BuffStat("P", 5, 500)
				ply:BuffStat("E", 5, 500)
				ply:BuffStat("I", 5, 500)
				ply:BuffStat("A", 5, 500)
				ply:BuffStat("L", 5, 500)
				ply:Armor(300)
			end
		end
	},
}

hook.Add("InitPostEntity", "HarvestItemInit", function()
	for id, plant in pairs(Harvest.Plants) do
		local ITEM = nut.item.register(id:lower(), nil, false, nil, true)
		ITEM.name  = plant.PrintName
		ITEM.model = plant.ItemModel
		ITEM.desc  = plant.Desc

		if isfunction(plant.Effect) then
			ITEM.functions.Use = {
				onRun = function(item)
					local ply = item.player or item:getOwner()

					if ply:IsHandcuffed() or ply:getNetVar("restricted") then
						ply:falloutNotify("You cannot eat this while tied . . .", "ui/notify.mp3")
						return false
					end

					plant.Effect(ply)

					net.Start("HarvestPlantEffect")
						net.WriteString(id)
					net.Send(ply)
				end
			}
		end
	end
end)
