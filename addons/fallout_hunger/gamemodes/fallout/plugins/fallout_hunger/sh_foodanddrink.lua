local stats = {"S", "P", "E", "C", "I", "A", "L"}

local function randomStat(ply)
    net.Start("StartAlcoholEffect")
    net.Send(ply)

    local stat = stats[math.random(1, #stats)]
    local amt = math.random(-4, 4)
    if amt == 0 then return end

    local time = math.random(30, 90)
    ply:BuffStat(stat, amt, time)
end

local function NukaDrink(ply)
	ply:EmitSound("ui/drink.wav")
	ply:falloutNotify("✚ The cold beverage refreshes & energizes you!", "ui/notify.mp3")
end

local function Drink(ply)
	ply:EmitSound("npc/barnacle/barnacle_gulp1.wav")
	ply:falloutNotify("✚ The drink refreshes you", "ui/notify.mp3")
end

local function Eat(ply)
	ply:EmitSound("ui/aid" .. math.random(3) .. ".wav")
	ply:falloutNotify("✚ The food satisfies your hunger!", "ui/notify.mp3")

	ply:BuffStat("P", 1, 60, true)
	ply:BuffStat("S", 1, 60, true)
	ply:HealOverTime("Food", 10, 5)
end

/**local function Poisoned_Drink(ply)
	ply:EmitSound("ui/drink.wav")
	ply:falloutNotify("The cold beverage refreshes & energizes you!", "ui/notify.mp3")

	timer.Simple(60, function()
		ply:falloutNotify("You've been poisoned", "fx/fx_poison_stinger.mp3")
		ply:ScreenFade(SCREENFADE.OUT, Color(255,255,255), 2, 3)

		timer.Simple(2, function()
			if IsValid(ply) and ply:Alive() then
				ply:EmitSound("fx/fx_flinder_body_head03.wav")
				ply:ChatPrint("[ DEATH ]  You died from being poisoned . . .")
				ply:Kill()
			end
		end)
	end)
end**/

jonjo_items.food = {
  ["Preserved Cram"] = {
    ["model"] = "models/mosi/fallout4/props/food/cram.mdl",
    ["desc"] = "A tin of pre-cooked meat.",
		["rads"] = 3,
    ["amt"] = 15,
		["extra"] = Eat
  },
  ["Cotton Candy"] = {
    ["model"] = "models/mosi/fallout4/props/food/cottoncandy.mdl",
    ["desc"] = "A container of delicious treats.",
		["rads"] = 3,
    ["amt"] = 8,
		["extra"] = Eat
  },
	["Mirelurk Egg"] = {
		["model"] = "models/mosi/fallout4/props/food/mirelurkegg.mdl",
		["desc"] = "A mirelurk egg. Home to an unborn crab creature.",
		["rads"] = 3,
		["amt"] = 25,
		["extra"] = Eat
	},
	["Blambo Mac and Cheese"] = {
		["model"] = "models/mosi/fallout4/props/food/dogfood.mdl",
		["desc"] = "A can of Dog Food.",
		["rads"] = 3,
		["amt"] = 9,
		["extra"] = Eat
	},
	["Deathclaw Scramble"] = {
		["model"] = "models/mosi/fallout4/props/food/deathclawomelette.mdl",
		["desc"] = "A scrambled deathclaw egg.",
		["rads"] = 3,
		["amt"] = 60,
		["extra"] = Eat
	},
	["Mirelurk Scramble"] = {
		["model"] = "models/mosi/fallout4/props/food/mirelurkomelette.mdl",
		["desc"] = "A scrambled mirelurk egg.",
		["rads"] = 3,
		["amt"] = 45,
		["extra"] = Eat
	},
	["MRE"] = {
		["model"] = "models/mosi/fallout4/props/food/mre.mdl",
		["desc"] = "A military-grade meal.",
		["amt"] = 25,
		["extra"] = Eat
	},
	["Dog Food"] = {
		["model"] = "models/mosi/fallout4/props/food/macandcheese.mdl",
		["desc"] = "A box of pre-war Blambo Mac and Cheese.",
		["rads"] = 3,
		["amt"] = 17,
		["extra"] = Eat
	},
	["Yum Yum Develed Eggs"] = {
		["model"] = "models/mosi/fallout4/props/food/yumyumdeviledeggs.mdl",
		["desc"] = "A box of pre-war develed eggs.",
		["rads"] = 2,
		["amt"] = 17,
		["extra"] = Eat
	},
	["Salisbury Steak"] = {
		["model"] = "models/mosi/fallout4/props/food/salisburysteak.mdl",
		["desc"] = "A box of ancient but still delicious salsbury steak.",
		["rads"] = 5,
		["amt"] = 20,
		["extra"] = Eat
	},
	["Pork and Beans"] = {
		["model"] = "models/mosi/fallout4/props/food/porknbeans.mdl",
		["desc"] = "A can of pre-war pork and beans.",
		["rads"] = 3,
		["amt"] = 17,
		["extra"] = Eat
	},
	["Potato Crisps"] = {
		["model"] = "models/mosi/fallout4/props/food/potatocrisps.mdl",
		["desc"] = "A container of tasty crisps.",
		["rads"] = 2,
		["amt"] = 8,
		["extra"] = Eat
	},
	["Blambo Mac and Cheese"] = {
		["model"] = "models/mosi/fallout4/props/food/macandcheese.mdl",
		["desc"] = "A box of pre-war Blambo Mac and Cheese.",
		["rads"] = 3,
		["amt"] = 17,
		["extra"] = Eat
	},
	["Fancy Lad Cakes"] = {
		["model"] = "models/mosi/fallout4/props/food/fancyladcakes.mdl",
		["desc"] = "A box of delicious tiny cakes.",
		["rads"] = 3,
		["amt"] = 17,
		["extra"] = Eat
	},
	["Dandy Boy Apples"] = {
		["model"] = "models/fallout 3/dandy_apples.mdl",
		["desc"] = "Freshly boxed apples.",
		["rads"] = 3,
		["amt"] = 17,
		["extra"] = Eat
	},
  ["InstaMash"] = {
    ["model"] = "models/mosi/fallout4/props/food/instamash.mdl",
    ["desc"] = "Freeze-dried powdered mashed potatoes.",
		["rads"] = 3,
    ["amt"] = 15,
		["extra"] = Eat
  },
  ["Bubblegum"] = {
    ["model"] = "models/mosi/fallout4/props/food/bubblegum.mdl",
    ["desc"] = "Tasty confectionery.",
		["rads"] = 3,
    ["amt"] = 10,
		["extra"] = Eat
  },
  ["Sugar Bombs"] = {
    ["model"] = "models/fo3_sugar_bombs.mdl",
    ["desc"] = "Sugar frosting on each of the uniquely shaped wheat cereals, resembling the mini nuke.",
		["rads"] = 3,
    ["amt"] = 15,
		["extra"] = Eat
	},
	["Funnel Cake"] = {
		["model"] = "models/mosi/fallout4/props/food/funnelcake.mdl",
		["desc"] = "A cult-classic cake that only has more of a zing due to the radiation.",
		["rads"] = 3,
		["amt"] = 15,
		["extra"] = Eat
	},
  ["Salisbury Steak"] = {
    ["model"] = "models/fallout 3/steak.mdl",
    ["desc"] = "Made from a blend of minced beef and other ingredients, shaped to resemble a steak.",
		["rads"] = 3,
  	["amt"] = 20,
		["extra"] = Eat
  },
	["Buzz Bites"] = {
		["model"] = "models/mosi/fallout4/props/food/slocumsbuzzbites.mdl",
		["desc"] = "A delicious box of Donut Bites.",
		["rads"] = 3,
		["amt"] = 20,
		["extra"] = Eat
	},
	["Longneck Sardines"] = {
		["model"] = "models/mosi/fallout4/props/food/longneckcan.mdl",
		["desc"] = "A can of pre-war sardines.",
		["rads"] = 2,
		["amt"] = 10,
		["extra"] = Eat
	},
  ["Gunner's Famous Popcorn"] = {
    ["model"] = "models/fo3_popcorn_box.mdl",
    ["desc"] = "Gunner's Famous popcorn!",
    ["amt"] = 3,
		["extra"] = Eat
  },
  ["NCR Ration Pack"] = {
    ["model"] = "models/fo3_burger_box.mdl",
    ["desc"] = "A small container filled with ediable rations.",
    ["amt"] = 50,
		["extra"] = Eat
  },
  ["Blackhoods Ration Pack"] = {
    ["model"] = "models/fo3_burger_box.mdl",
    ["desc"] = "A small container filled with ediable rations.",
    ["amt"] = 15,
		["extra"] = Eat
  },
  ["Mutfruit"] = {
    ["model"] = "models/fallout/consumables/mutfruit.mdl",
    ["desc"] = "Tasty fresh produce.",
    ["amt"] = 20,
    ["rads"] = 1,
		["extra"] = Eat
  },
  ["Carrot"] = {
    ["model"] = "models/fallout/consumables/carrot.mdl",
    ["desc"] = "Tasty fresh produce.",
    ["amt"] = 20,
    ["rads"] = 1,
		["extra"] = Eat
  },
  ["Tarberry"] = {
    ["model"] = "models/fallout/consumables/tarberry.mdl",
    ["desc"] = "Tasty fresh produce.",
    ["amt"] = 20,
    ["rads"] = 1,
		["extra"] = Eat
  },
  ["Tato"] = {
    ["model"] = "models/fallout/consumables/tato.mdl",
    ["desc"] = "Tasty fresh produce.",
    ["amt"] = 20,
    ["rads"] = 1,
		["extra"] = Eat
  },
	["Deathclaw Egg"] = {
		["model"] = "models/mosi/fallout4/props/food/deathclawegg.mdl",
		["desc"] = "A deathclaw egg. Home to an unborn monster.",
		["amt"] = 50,
		["rads"] = 1,
		["extra"] = Eat
	},
	["The Cake"] = {
		["model"] = "models/mosi/fallout4/props/food/preservedpie.mdl",
		["desc"] = "This will be SO worth it.",
		["rads"] = 99,
		["amt"] = 100,
		["extra"] = Eat
	},
	["Moldy Food"] = {
		["model"] = "models/mosi/fallout4/props/food/moldyfood.mdl",
		["desc"] = "It's so moldy and gross, we don't even know what it was.",
		["rads"] = 15,
		["amt"] = 5,
		["extra"] = Eat
	},
/** CUSTOM ORDER Zoinks#4596 **/
	["Salient Green"] = {
		["model"] = "models/fallout/items/centaurblood.mdl",
		["desc"] = "A jar containing plant material broken down into its base components.",
		["rads"] = 0,
		["amt"] = 20,
		["extra"] = Eat
	},
}

jonjo_items.drink = {
	["Purified Water"] = {
		["model"] = "models/mosi/fallout4/props/drink/water.mdl",
		["desc"] = "A bottle of purified water.",
		["amt"] = 35,
		["extra"] = NukaDrink
	},
	["Dirty Water"] = {
		["model"] = "models/mosi/fallout4/props/drink/dirtywater.mdl",
		["desc"] = "A bottle filled with dirty water. Drink at your own risk.",
		["amt"] = 17,
		["rads"] = 4,
		["extra"] = Drink
	},
	["Lemonade"] = {
		["model"] = "models/mosi/fallout4/props/drink/lemonade.mdl",
		["desc"] = "A can of pre-war lemonade.",
		["amt"] = 17,
		["rads"] = 2
	},
	["Milk"] = {
		["model"] = "models/mosi/fallout4/props/drink/milkbottle.mdl",
		["desc"] = "A bottle of Brahman Milk.",
		["amt"] = 22,
		["rads"] = 3
	},
	["Sunset Sarsaparilla"] = {
		["model"] = "models/mosi/fallout4/props/drink/sunsetsarsaparilla.mdl",
		["desc"] = "Sunset Sarsaparilla is a root-beer-type carbonated beverage.",
		["amt"] = 20,
		["extra"] = NukaDrink
	},
	["Vim"] = {
		["model"] = "models/mosi/fallout4/props/drink/vim.mdl",
		["desc"] = "A sweet, lemony Cola drink.",
		["amt"] = 20,
		["extra"] = NukaDrink
	},
	["Nuka-Cola Classic"] = {
    ["model"] = "models/mosi/fallout4/props/drink/nukacola.mdl",
    ["desc"] = "A clear bottle containing dark brown liquid with the classic Nuka-Cola label.",
    ["amt"] = 20,
		["extra"] = NukaDrink
  },
	["Nuka-Cola Quantum"] = {
	  ["model"] = "models/mosi/fallout4/props/drink/nukacola2.mdl",
	  ["desc"] = "Twice the calories, twice the carbohydrates, twice the caffeine and twice the taste of regular Nuka-Cola.",
	  ["amt"] = 50,
		["extra"] = NukaDrink
  },
  ["Nuka-Cherry"] = {
    ["model"] = "models/nukacola/nukacola_grape.mdl",
    ["desc"] = "Cherry flavoured variant of the classic Nuka-Cola.",
    ["amt"] = 20,
		["extra"] = NukaDrink
  },
  ["Nuka-Fusion"] = {
    ["model"] = "models/maxib123/nukafusion.mdl",
    ["desc"] = "The unique taste of Nuka-Fusion is the result of a combination of seventeen fruit essences, balanced to enhance the classic cola flavor.",
    ["amt"] = 20,
		["extra"] = NukaDrink
  },
	["Nuka-Clear"] = {
    ["model"] = "models/maxib123/nukaclear.mdl",
    ["desc"] = "A clear variant of the classic Nuka-Cola.",
    ["amt"] = 20,
		["extra"] = NukaDrink
  },
	["Nuka-Cola Wild"] = {
		["model"] = "models/nukacola/nukacola_wild.mdl",
		["desc"] = "An experimental Cola flavor launched just before the Great War.",
		["amt"] = 13,
		["extra"] = randomStat
	},
	["Nuka-Victory"] = {
		["model"] = "models/nukacola/nukacola_victory.mdl",
		["desc"] = "The rarest flavor of Nuka-Cola ever released. This beverage is one of the most rare you could possibly find. Drinking it would be incredibly stupid.",
		["amt"] = 100,
		["extra"] = NukaDrink
	},
	["Nuka-Cola Grape"] = {
		["model"] = "models/nukacola/nukacola_grape.mdl",
		["desc"] = "A grape flavored version of Nuka Cola.",
		["amt"] = 20,
		["extra"] = NukaDrink
	},
	["Nuka-Cola Orange"] = {
		["model"] = "models/nukacola/nukacola_orange.mdl",
		["desc"] = "An Orange flavored version of Nuka Cola.",
		["amt"] = 20,
		["extra"] = NukaDrink
	},
	["Nuka-Cola Orange"] = {
		["model"] = "models/nukacola/nukacola_orange.mdl",
		["desc"] = "An Orange flavored version of Nuka Cola.",
		["amt"] = 20,
		["extra"] = NukaDrink
	},
	["Nuka-Cola Quartz"] = {
		["model"] = "models/nukacola/nukacola_quartz.mdl",
		["desc"] = "A glowing bottle of Nuka Cola, it's flavor to difficult to distinguish.",
		["amt"] = 20,
		["extra"] = NukaDrink
	},
	["Nuka-Dark Whiskey"] = {
		["model"] = "models/nukacola/nukacola_dark.mdl",
		["desc"] = "A trial-alcholic drink released by Nuka Cola intended for a more adult audience. It didn't do very well.",
		["amt"] = 13,
		["extra"] = randomStat
	},
	["Whiskey"] = {
    ["model"] = "models/mosi/fallout4/props/alcohol/whiskey.mdl",
    ["desc"] = "A bottle of whiskey",
    ["amt"] = 13,
    ["extra"] = randomStat
  },
	["Militia Moonshine"] = {
		["model"] = "models/fallout/items/whiskeybottle02.mdl",
		["desc"] = "A bottle of homemade Militia Moonshine",
		["amt"] = 15,
		["extra"] = randomStat
	},
	["Bourbon"] = {
		["model"] = "models/mosi/fallout4/props/alcohol/bourbon.mdl",
		["desc"] = "A bottle of Bourbon",
		["amt"] = 13,
		["extra"] = randomStat
	},
	["Rum"] = {
		["model"] = "models/mosi/fallout4/props/alcohol/rum.mdl",
		["desc"] = "A bottle of Bourbon",
		["amt"] = 13,
		["extra"] = randomStat
	},
	["Beer"] = {
    ["model"] = "models/fallout 3/beer.mdl",
    ["desc"] = "A bottle of beer",
    ["amt"] = 10,
    ["extra"] = randomStat
  },
  ["Vodka"] = {
    ["model"] = "models/mosi/fallout4/props/alcohol/vodka.mdl",
    ["desc"] = "A bottle of vodka",
    ["amt"] = 13,
    ["extra"] = randomStat
  },
  ["Wine"] = {
    ["model"] = "models/mosi/fallout4/props/alcohol/wine.mdl",
    ["desc"] = "A bottle of wine",
    ["amt"] = 13,
    ["extra"] = randomStat
  },
/** CUSTOM ORDER Zoinks#4596 **/
	["Battle Brew"] = {
		["model"] = "models/fallout 3/vodka.mdl",
		["desc"] = "Bottle of potent concoction made from mutant cave fungus and Salient Green",
		["amt"] = 20,
		["extra"] = randomStat
	},
}
