wRarity.Config.NPCKillDropChance = 5 --Percent chance that an NPC will drop something when killed
wRarity.Config.DeconstructValue = 35 --Percentage of original construction materials you will receive back when you deconstruct a weapon
wRarity.Config.BonusPerLuck = 0.015 --Each rarity above the first one will have this bonus chance per level of luck
wRarity.Config.DropTimeout = 90 --Time in seconds it takes for a dropped item to despawn
wRarity.Config.BenchModel = "models/fallout new vegas/reload_bench.mdl" --Model for the trade up bench
wRarity.Config.TradeupAmt = 5 --Amount of rarity X weapons you need to get 1 of the next rarity
wRarity.Config.MaxTradeupRarity = 4 --The highest rarity someone can trade up to
wRarity.Config.Rarities = { --List of all possible rarities, MUST be in descending order
	{
		["name"] = "Common", --Display name of the rarity
		["color"] = Color(148, 148, 148, 255), --Display color of the rarity
		["buff"] = 0, --Percent buff the rarity will apply to a given weapon's damage
		["chance"] = 74.4 --Chance an obtained weapon will be of this rarity, the sum of all the chances MUST equal 100
	},
	{
		["name"] = "Uncommon",
		["color"] = Color(66, 255, 82, 255),
		["buff"] = 2.5,
		["chance"] = 20
	},
	{
		["name"] = "Rare",
		["color"] = Color(41, 44, 255, 255),
		["buff"] = 5,
		["chance"] = 5
	},
	{
		["name"] = "Superior",
		["color"] = Color(212, 41, 255, 255),
		["buff"] = 7.5,
		["chance"] = 0.5
	},
	{
		["name"] = "Legendary",
		["color"] = Color(255, 216, 41, 255),
		["buff"] = 12.5,
		["chance"] = 0.1
	}
}
wRarity.Config.BossDrops = { --Drop table for weapon drops from killing a boss
	{
		["chance"] = 10,
		["items"] = {
			"weapon_r91_carb",
			"weapon_chineseassaultrifle",
			"weapon_assaultcarbinesil",
			"weapon_serviceriflebayo",
			"weapon_assaultcarbine",
			"weapon_huntingshotgun"
		}
	},
	{
		["chance"] = 15,
		["items"] = {
			"weapon_dresscane",
			"weapon_cleaver",
			"weapon_tireiron",
			"weapon_fireaxe",
			"weapon_chineseofficersword"
		}
	},
	{
		["chance"] = 15,
		["items"] = {
			"component_nuclear_material",
			"component_fiberoptics"
		}
	},
	{
		["chance"] = 15,
		["items"] = {
			"weapon_10mmsmg",
			"weapon_9mmpistol",
			"weapon_45smg",
			"weapon_127mmsmgsil",
			"weapon_22smg",
		}
	},
	{
		["chance"] = 10,
		["items"] = {
			"vb01",
			"vb02",
			"humvee_4",
			"tank",
			"apc",
			"chimera"
		}
	},
	{
		["chance"] = 5,
		["items"] = {
			"weapon_huntingshotextchoke",
			"weapon_caravanshotgun",
			"weapon_singleshotgun",
			"weapon_combatshotgun"
		}
	},    {
			["chance"] = 13,
			["items"] = {
				"weapon_chinesepistol",
				"weapon_huntingrevolver",
				"weapon_44revolver",
				"frame_weapon_44revolver"
			}
		},
		{
			["chance"] = 7,
			["items"] = {
				"weapon_cowboyrepeater",
				"weapon_huntingrifleext",
				"weapon_sniperriflesil",
				"weapon_cowboyrepeaterbrass"
			}
		},
		{
			["chance"] = 10,
			["items"] = {
				"component_gold",
			}
		}

}

wRarity.debug = true
