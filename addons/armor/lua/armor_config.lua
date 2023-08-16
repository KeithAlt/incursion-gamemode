-- Test push
local function BuffStat(ply, item, stat, amt)
	item.ArmorBuffs = item.ArmorBuffs or {}
	item.ArmorBuffs[stat] = ply:BuffStat(stat, amt, -1)
end

local function EndBuff(ply, item, stat)
	if !item.ArmorBuffs or !item.ArmorBuffs[stat] then
		return
	end

	ply:StopStatBuff(stat, item.ArmorBuffs[stat])
	item.ArmorBuffs[stat] = nil
end

Armor.Config.Accessories = {
	["shemagh"] = {
		["name"] = "Shemagh Shade",
		["desc"] = "A demo item - hood",
		["type"] = "hat",
		["hair"] = false,
		["modelType"] = "shemagh2",
		["itemModel"] = "models/fallout/apparel/gscbanditmask.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "sol_",
		["femalePrefix"] = "sol_",
		["maleScale"] = 0.9,
		["femaleScale"] = 0.8,
		["rarity"] = 3,
		["head"] = true,
		["damage"] = 10
	},
	["santa_hat"] = { -- 12.25.2020 Holiday item
		["name"] = "Santa Hat",
		["desc"] = "A unique hat only obtained during a very unique time.",
		["type"] = "hat",
		["hair"] = false,
		["itemModel"] = "models/fallout/apparel/partyhat.mdl",
		["rootPath"] = "models/cgcclothing/",
		["pathType"] = "santa",
		["modelType"] = "santa",
		["maleSuffix"] = "_male",
		["femaleSuffix"] = "_female",
		["rarity"] = 5,
		["head"] = true,
		["damage"] = 25
	},
	["shemaghgas"] = {
		["name"] = "Shemagh Gas Shade",
		["desc"] = "A demo item - hood",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["modelType"] = "shemagh2",
		["itemModel"] = "models/fallout/apparel/gscbanditmask.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "sol_",
		["femalePrefix"] = "sol_",
		["maleScale"] = 0.9,
		["femaleScale"] = 0.8,
		["maleScale"] = 0.8,
		["cannotWear"] = {
			["mask"] = true
		},
		["bodygroup"] = {1, 1},
		["head"] = true,
		["damage"] = 10
	},
	["shemaghghood"] = {
		["name"] = "Shemagh Hood",
		["desc"] = "A demo item - hood",
		["type"] = "hat",
		["hair"] = false,
		["modelType"] = "shemagh",
		["itemModel"] = "models/fallout/apparel/gscbanditmask.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "sol_",
		["femalePrefix"] = "sol_",
		["maleScale"] = 0.9,
		["femaleScale"] = 0.8,
		["rarity"] = 3,
		["head"] = true,
		["damage"] = 10
	},
	["shemaghgashood"] = {
		["name"] = "Shemagh Gas Hood",
		["desc"] = "A demo item - hood",
		["type"] = "hat",
		["modelType"] = "shemagh",
		["itemModel"] = "models/fallout/apparel/gscbanditmask.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "sol_",
		["femalePrefix"] = "sol_",
		["maleScale"] = 0.9,
		["femaleScale"] = 0.8,
		["rarity"] = 3,
		["bodygroup"] = 1,
		["cannotWear"] = {
			["mask"] = true
		},
		["head"] = true,
	},
	["sfacescarf"] = {
		["name"] = "Brown Scarf",
		["desc"] = "A bandana Mask often used and worn by those who seek to hide their complection",
		["type"] = "neck",
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "pimpmyscarf",
		["maleScale"] = 0.9,
		["femaleScale"] = 0.8,
		["rarity"] = 2,
		["bodygroup"] = 1,
		["head"] = true,
	},
	["sgfacescarf"] = {
		["name"] = "Green Scarf",
		["desc"] = "A Scarf Mask often used and worn by those who seek to hide their complection",
		["type"] = "hat",
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "pimpmyscarf",
		["maleScale"] = 0.9,
		["femaleScale"] = 0.8,
		["skin"] = 1,
		["bodygroup"] = 1,
		["rarity"] = 2,
		["head"] = true,
	},
	["scafacescarf"] = {
		["name"] = "Camo Scarf",
		["desc"] = "A Scarf Mask often used and worn by those who seek to hide their complection",
		["type"] = "neck",
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "pimpmyscarf",
		["maleScale"] = 0.9,
		["femaleScale"] = 0.8,
		["skin"] = 2,
		["bodygroup"] = 1,
		["rarity"] = 2,
		["head"] = true,
	},
	["sbfacescarf"] = {
		["name"] = "Blue Scarf",
		["desc"] = "A Scarf Mask often used and worn by those who seek to hide their complection",
		["type"] = "neck",
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "pimpmyscarf",
		["maleScale"] = 0.9,
		["femaleScale"] = 0.8,
		["skin"] = 3,
		["bodygroup"] = 1,
		["rarity"] = 2,
		["head"] = true,
	},
	["sarfacescarf"] = {
		["name"] = "Army Scarf",
		["desc"] = "A Scarf Mask often used and worn by those who seek to hide their complection",
		["type"] = "neck",
		["facialHair"] = false,
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "pimpmyscarf",
		["maleScale"] = 0.9,
		["femaleScale"] = 0.8,
		["skin"] = 4,
		["rarity"] = 2,
		["bodygroup"] = 1,
		["head"] = true,
	},
	["schecfacescarf"] = {
		["name"] = "Plad Scarf",
		["desc"] = "A Scarf Mask often used and worn by those who seek to hide their complection",
		["type"] = "neck",
		["facialHair"] = false,
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "pimpmyscarf",
		["maleScale"] = 0.9,
		["femaleScale"] = 0.8,
		["skin"] = 5,
		["rarity"] = 2,
		["bodygroup"] = 1,
		["head"] = true,
	},
	["syfacescarf"] = {
		["name"] = "Yellow Scarf",
		["desc"] = "A Scarf Mask often used and worn by those who seek to hide their complection",
		["type"] = "neck",
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "pimpmyscarf",
		["maleScale"] = 0.9,
		["femaleScale"] = 0.8,
		["skin"] = 6,
		["rarity"] = 2,
		["bodygroup"] = 1,
		["head"] = true,
	},
	["sdrafacescarf"] = {
		["name"] = "Dragon Scarf",
		["desc"] = "A Scarf Mask often used and worn by those who seek to hide their complection",
		["type"] = "neck",
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "pimpmyscarf",
		["maleScale"] = 0.9,
		["femaleScale"] = 0.8,
		["skin"] = 7,
		["rarity"] = 3,
		["bodygroup"] = 1,
		["head"] = true,
	},
	["sblackfacescarf"] = {
		["name"] = "Black Scarf",
		["desc"] = "A Scarf Mask often used and worn by those who seek to hide their complection",
		["type"] = "neck",
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "pimpmyscarf",
		["maleScale"] = 0.9,
		["femaleScale"] = 0.8,
		["skin"] = 8,
		["rarity"] = 3,
		["bodygroup"] = 1,
		["head"] = true,
	},
	["shorrorfacescarf"] = {
		["name"] = "Horror Scarf",
		["desc"] = "A Scarf Mask often used and worn by those who seek to hide their complection",
		["type"] = "neck",
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "pimpmyscarf",
		["maleScale"] = 0.9,
		["femaleScale"] = 0.8,
		["skin"] = 9,
		["rarity"] = 3,
		["bodygroup"] = 1,
		["head"] = true,
	},
	["sdarkfacescarf"] = {
		["name"] = "Dark Scarf",
		["desc"] = "A Scarf Mask often used and worn by those who seek to hide their complection",
		["type"] = "neck",
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "pimpmyscarf",
		["maleScale"] = 0.9,
		["femaleScale"] = 0.8,
		["skin"] = 10,
		["rarity"] = 3,
		["bodygroup"] = 1,
		["head"] = true,
	},
	["scrimsonfacescarf"] = {
		["name"] = "Crimson Scarf",
		["desc"] = "A Scarf Mask often used and worn by those who seek to hide their complection",
		["type"] = "neck",
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "pimpmyscarf",
		["maleScale"] = 0.75,
		["femaleScale"] = 0.6,
		["skin"] = 11,
		["rarity"] = 3,
		["bodygroup"] = 1,
		["head"] = true,
	},
	["scontingencyfacescarf"] = {
		["name"] = "Contingency Scarf",
		["desc"] = "A Scarf Mask often used and worn by those who seek to hide their complection",
		["type"] = "neck",
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "pimpmyscarf",
		["maleScale"] = 0.9,
		["femaleScale"] = 0.8,
		["skin"] = 12,
		["rarity"] = 3,
		["bodygroup"] = 1,
		["head"] = true,
	},
	["facescarf"] = {
		["name"] = "Brown Face Scarf",
		["desc"] = "A bandana Mask often used and worn by those who seek to hide their complection",
		["type"] = "mask",
		["facialHair"] = false,
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "pimpmyscarf",
		["maleScale"] = 0.93,
		["femaleScale"] = 0.85,
		["rarity"] = 2,
		["cannotWear"] = {
			["mask"] = true
		},
		["head"] = true,
	},
	["gfacescarf"] = {
		["name"] = "Green Face Scarf",
		["desc"] = "A Scarf Mask often used and worn by those who seek to hide their complection",
		["type"] = "mask",
		["facialHair"] = false,
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "pimpmyscarf",
		["maleScale"] = 0.93,
		["femaleScale"] = 0.85,
		["skin"] = 1,
		["rarity"] = 2,
		["cannotWear"] = {
			["mask"] = true
		},
		["head"] = true,
	},
	["cafacescarf"] = {
		["name"] = "Camo Face Scarf",
		["desc"] = "A Scarf Mask often used and worn by those who seek to hide their complection",
		["type"] = "mask",
		["facialHair"] = false,
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "pimpmyscarf",
		["maleScale"] = 0.93,
		["femaleScale"] = 0.85,
		["skin"] = 2,
		["rarity"] = 2,
		["head"] = true,
	},
	["bfacescarf"] = {
		["name"] = "Blue Face Scarf",
		["desc"] = "A Scarf Mask often used and worn by those who seek to hide their complection",
		["type"] = "mask",
		["facialHair"] = false,
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "pimpmyscarf",
		["maleScale"] = 0.93,
		["femaleScale"] = 0.85,
		["skin"] = 3,
		["rarity"] = 2,
		["cannotWear"] = {
			["mask"] = true
		},
		["head"] = true,
	},
	["arfacescarf"] = {
		["name"] = "Army Face Scarf",
		["desc"] = "A Scarf Mask often used and worn by those who seek to hide their complection",
		["type"] = "mask",
		["facialHair"] = false,
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "pimpmyscarf",
		["maleScale"] = 0.93,
		["femaleScale"] = 0.85,
		["skin"] = 4,
		["rarity"] = 2,
		["cannotWear"] = {
			["mask"] = true
		},
		["head"] = true,
	},
	["checfacescarf"] = {
		["name"] = "Plad Face Scarf",
		["desc"] = "A Scarf Mask often used and worn by those who seek to hide their complection",
		["type"] = "mask",
		["facialHair"] = false,
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "pimpmyscarf",
		["maleScale"] = 0.93,
		["femaleScale"] = 0.85,
		["skin"] = 5,
		["rarity"] = 2,
		["cannotWear"] = {
			["mask"] = true
		},
		["head"] = true,
	},
	["yfacescarf"] = {
		["name"] = "Yellow Face Scarf",
		["desc"] = "A Scarf Mask often used and worn by those who seek to hide their complection",
		["type"] = "mask",
		["facialHair"] = false,
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "pimpmyscarf",
		["maleScale"] = 0.93,
		["femaleScale"] = 0.85,
		["skin"] = 6,
		["rarity"] = 2,
		["cannotWear"] = {
			["mask"] = true
		},
		["head"] = true,
	},
	["drafacescarf"] = {
		["name"] = "Dragon Face Scarf",
		["desc"] = "A Scarf Mask often used and worn by those who seek to hide their complection",
		["type"] = "mask",
		["facialHair"] = false,
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "pimpmyscarf",
		["maleScale"] = 0.93,
		["femaleScale"] = 0.85,
		["skin"] = 7,
		["rarity"] = 3,
		["cannotWear"] = {
			["mask"] = true
		},
		["head"] = true,
	},
	["blackfacescarf"] = {
		["name"] = "Black Face Scarf",
		["desc"] = "A Scarf Mask often used and worn by those who seek to hide their complection",
		["type"] = "mask",
		["facialHair"] = false,
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "pimpmyscarf",
		["maleScale"] = 0.93,
		["femaleScale"] = 0.85,
		["skin"] = 8,
		["rarity"] = 3,
		["cannotWear"] = {
			["mask"] = true
		},
		["head"] = true,
	},
	["horrorfacescarf"] = {
		["name"] = "Horror Face Scarf",
		["desc"] = "A Scarf Mask often used and worn by those who seek to hide their complection",
		["type"] = "mask",
		["facialHair"] = false,
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "pimpmyscarf",
		["maleScale"] = 0.93,
		["femaleScale"] = 0.85,
		["skin"] = 9,
		["rarity"] = 3,
		["cannotWear"] = {
			["mask"] = true
		},
		["head"] = true,
	},
	["darkfacescarf"] = {
		["name"] = "Dark Face Scarf",
		["desc"] = "A Scarf Mask often used and worn by those who seek to hide their complection",
		["type"] = "mask",
		["facialHair"] = false,
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "pimpmyscarf",
		["maleScale"] = 0.93,
		["femaleScale"] = 0.85,
		["skin"] = 10,
		["rarity"] = 3,
		["cannotWear"] = {
			["mask"] = true
		},
		["head"] = true,
	},
	["crimsonfacescarf"] = {
		["name"] = "Crimson Face Scarf",
		["desc"] = "A Scarf Mask often used and worn by those who seek to hide their complection",
		["type"] = "mask",
		["facialHair"] = false,
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "pimpmyscarf",
		["skin"] = 11,
		["maleScale"] = 0.93,
		["femaleScale"] = 0.85,
		["rarity"] = 3,
		["cannotWear"] = {
			["mask"] = true
		},
		["head"] = true,
	},
	["contingencyfacescarf"] = {
		["name"] = "Contingency Face Scarf",
		["desc"] = "A Scarf Mask often used and worn by those who seek to hide their complection",
		["type"] = "mask",
		["facialHair"] = false,
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "pimpmyscarf",
		["skin"] = 12,
		["maleScale"] = 0.93,
		["femaleScale"] = 0.85,
		["rarity"] = 3,
		["cannotWear"] = {
			["mask"] = true
		},
		["head"] = true,
	},
	["y-facemask"] = {
        ["name"] = "Yellow Bandana Mask",
        ["desc"] = "A bandana Mask often used and worn by those who seek to hide their complection",
        ["type"] = "mask",
        ["facialHair"] = false,
        ["itemModel"] = "models/fallout/apparel/bandana.mdl",
        ["rootPath"] = "models/visualitygaming/fallout/",
        ["pathType"] = "prop",
        ["malePrefix"] = "combat_",
        ["femalePrefix"] = "combat_",
        ["modelType"] = "headwrap",
        ["maleScale"] = 0.95,
        ["femaleScale"] = 0.85,
        ["rarity"] = 1,
        ["bodygroup"] = {0,0},
        ["cannotWear"] = {
            ["mask"] = true
        },
        ["head"] = true,
    },
    ["p-facemask"] = {
        ["name"] = "Purple Bandana Mask",
        ["desc"] = "A bandana Mask often used and worn by those who seek to hide their complection",
        ["type"] = "mask",
        ["facialHair"] = false,
        ["itemModel"] = "models/fallout/apparel/bandana.mdl",
        ["rootPath"] = "models/visualitygaming/fallout/",
        ["pathType"] = "prop",
        ["malePrefix"] = "combat_",
        ["femalePrefix"] = "combat_",
        ["modelType"] = "headwrap",
        ["maleScale"] = 1.00,
        ["femaleScale"] = 0.85,
        ["rarity"] = 1,
        ["bodygroup"] = {1,1},
        ["cannotWear"] = {
            ["mask"] = true
        },
        ["head"] = true,
    },
    ["a-facemask"] = {
        ["name"] = "Aqua Bandana Mask",
        ["desc"] = "A bandana Mask often used and worn by those who seek to hide their complection",
        ["type"] = "mask",
        ["facialHair"] = false,
        ["itemModel"] = "models/fallout/apparel/bandana.mdl",
        ["rootPath"] = "models/visualitygaming/fallout/",
        ["pathType"] = "prop",
        ["malePrefix"] = "combat_",
        ["femalePrefix"] = "combat_",
        ["modelType"] = "headwrap",
        ["maleScale"] = 0.95,
        ["femaleScale"] = 0.85,
        ["rarity"] = 1,
        ["bodygroup"] = {2,2},
        ["cannotWear"] = {
            ["mask"] = true
        },
        ["head"] = true,
    },
    ["g-facemask"] = {
        ["name"] = "Green Bandana Mask",
        ["desc"] = "A bandana Mask often used and worn by those who seek to hide their complection",
        ["type"] = "mask",
        ["facialHair"] = false,
        ["itemModel"] = "models/fallout/apparel/bandana.mdl",
        ["rootPath"] = "models/visualitygaming/fallout/",
        ["pathType"] = "prop",
        ["malePrefix"] = "combat_",
        ["femalePrefix"] = "combat_",
        ["modelType"] = "headwrap",
        ["maleScale"] = 1.00,
        ["femaleScale"] = 0.85,
        ["rarity"] = 1,
        ["bodygroup"] = {3,3},
        ["cannotWear"] = {
            ["mask"] = true
        },
        ["head"] = true,
    },
    ["r-facemask"] = {
        ["name"] = "Red Bandana Mask",
        ["desc"] = "A bandana Mask often used and worn by those who seek to hide their complection",
        ["type"] = "mask",
        ["facialHair"] = false,
        ["itemModel"] = "models/fallout/apparel/bandana.mdl",
        ["rootPath"] = "models/visualitygaming/fallout/",
        ["pathType"] = "prop",
        ["malePrefix"] = "combat_",
        ["femalePrefix"] = "combat_",
        ["modelType"] = "headwrap",
        ["maleScale"] = 1.05,
        ["femaleScale"] = 0.85,
        ["rarity"] = 1,
        ["bodygroup"] = {4,4},
        ["cannotWear"] = {
            ["mask"] = true
        },
        ["head"] = true,
    },
    ["b-facemask"] = {
        ["name"] = "Blue Bandana Mask",
        ["desc"] = "A bandana Mask often used and worn by those who seek to hide their complection",
        ["type"] = "mask",
        ["facialHair"] = false,
        ["itemModel"] = "models/fallout/apparel/bandana.mdl",
        ["rootPath"] = "models/visualitygaming/fallout/",
        ["pathType"] = "prop",
        ["malePrefix"] = "combat_",
        ["femalePrefix"] = "combat_",
        ["modelType"] = "headwrap",
        ["maleScale"] = .95,
        ["femaleScale"] = 0.85,
        ["rarity"] = 1,
        ["bodygroup"] = {8,8},
        ["cannotWear"] = {
            ["mask"] = true
        },
        ["head"] = true,
    },
	["y-facewrap"] = {
		["name"] = "Yellow Face Wrap",
		["desc"] = "A bandana Mask often used and worn by those who seek to hide their complection",
		["type"] = "mask",
		["facialHair"] = false,
		["itemModel"] = "models/fallout/apparel/bandana.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "combat_",
		["femalePrefix"] = "combat_",
		["modelType"] = "headwrap",
		["maleScale"] = 0.95,
		["femaleScale"] = 0.8,
		["rarity"] = 1,
		["bodygroup"] = {9,9},
		["cannotWear"] = {
			["mask"] = true
		},
		["head"] = true,
	},
	["p-facewrap"] = {
		["name"] = "Purple Face Wrap",
		["desc"] = "A bandana Mask often used and worn by those who seek to hide their complection",
		["type"] = "mask",
		["facialHair"] = false,
		["itemModel"] = "models/fallout/apparel/bandana.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "combat_",
		["femalePrefix"] = "combat_",
		["modelType"] = "headwrap",
		["maleScale"] = 1,
		["femaleScale"] = 0.8,
		["rarity"] = 1,
		["bodygroup"] = {1,1},
		["cannotWear"] = {
			["mask"] = true
		},
		["head"] = true,
	},
	["a-facewrap"] = {
		["name"] = "Aqua Face Wrap",
		["desc"] = "A bandana Mask often used and worn by those who seek to hide their complection",
		["type"] = "mask",
		["facialHair"] = false,
		["itemModel"] = "models/fallout/apparel/bandana.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "combat_",
		["femalePrefix"] = "combat_",
		["modelType"] = "headwrap",
		["maleScale"] = 1,
		["femaleScale"] = 0.8,
		["rarity"] = 1,
		["bodygroup"] = {2,2},
		["cannotWear"] = {
			["mask"] = true
		},
		["head"] = true,
	},
	["g-facewrap"] = {
		["name"] = "Green Face Wrap",
		["desc"] = "A bandana Mask often used and worn by those who seek to hide their complection",
		["type"] = "mask",
		["facialHair"] = false,
		["itemModel"] = "models/fallout/apparel/bandana.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "combat_",
		["femalePrefix"] = "combat_",
		["modelType"] = "headwrap",
		["maleScale"] = 1,
		["femaleScale"] = 0.8,
		["rarity"] = 1,
		["bodygroup"] = {3,3},
		["cannotWear"] = {
			["mask"] = true
		},
		["head"] = true,
	},
	["r-facewrap"] = {
		["name"] = "Red Face Wrap",
		["desc"] = "A bandana Mask often used and worn by those who seek to hide their complection",
		["type"] = "mask",
		["facialHair"] = false,
		["itemModel"] = "models/fallout/apparel/bandana.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "combat_",
		["femalePrefix"] = "combat_",
		["modelType"] = "headwrap",
		["maleScale"] = 1,
		["femaleScale"] = 0.8,
		["rarity"] = 1,
		["bodygroup"] = {4,4},
		["cannotWear"] = {
			["mask"] = true
		},
		["head"] = true,
	},
	["b-facewrap"] = {
		["name"] = "Blue Face Wrap",
		["desc"] = "A bandana Mask often used and worn by those who seek to hide their complection",
		["type"] = "mask",
		["facialHair"] = false,
		["itemModel"] = "models/fallout/apparel/bandana.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "combat_",
		["femalePrefix"] = "combat_",
		["modelType"] = "headwrap",
		["maleScale"] = 1,
		["femaleScale"] = 0.8,
		["rarity"] = 1,
		["bodygroup"] = {1,8},
		["cannotWear"] = {
			["mask"] = true
		},
		["head"] = true,
	},
	["redbandana"] = {
		["name"] = "Red Bandana",
		["desc"] = "A dirty bandana | +1 STR",
		["type"] = "hat",
		["hair"] = true,
		["facialHair"] = true,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/apparel/bandana.mdl",
		["bodygroup"] = 1,
		["pathType"] = "headgear",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 1)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
		end,
	},
	["bluebandana"] = {
		["name"] = "Blue Bandana",
		["desc"] = "A dirty bandana",
		["type"] = "hat",
		["hair"] = true,
		["facialHair"] = true,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/apparel/bandana.mdl",
		["bodygroup"] = 1,
		["skin"] = 1,
		["pathType"] = "headgear",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "E", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "E")
		end,
	},
	["greenbandana"] = {
		["name"] = "Green Bandana",
		["desc"] = "A dirty bandana",
		["type"] = "hat",
		["hair"] = true,
		["facialHair"] = true,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/apparel/bandana.mdl",
		["bodygroup"] = 1,
		["skin"] = 2,
		["pathType"] = "headgear",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "A", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "A")
		end,
	},
	["fedora"] = {
		["name"] = "Pre-War Fedora",
		["desc"] = "The black fedora",
		["type"] = "hat",
		["hair"] = false,
		["maleScale"] = 1.1,
		["facialHair"] = true,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/apparel/strangerhat.mdl",
		["bodygroup"] = 2,
		["pathType"] = "headgear",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "P", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "P")
		end,
		["head"] = true,
		["damage"] = 35,
	},
	["noirfedora"] = {
		["name"] = "Family Fedora",
		["desc"] = "The hat of a true detective | FAMILIES - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/headgear/cowboyhat.mdl",
		["bodygroup"] = 3,
		["pathType"] = "headgear",
		["damage"] = 55,
	},
	["boomerberret"] = {
		["name"] = "Boomer Berret",
		["desc"] = "A pre-war Air Force berret often worn by Boomers | BOOMER - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/apparel/strangerhat.mdl",
		["bodygroup"] = 4,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 55,
	},
	["boomerhat"] = {
		["name"] = "Boomer Captain Hat",
		["desc"] = "A pre-war Air Force Officer's hat often worn by Boomers | BOOMER Officer - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/leatherpilot.mdl",
		["bodygroup"] = 5,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 60,
	},
	["cowboyhat"] = {
		["name"] = "Cowboy Hat",
		["desc"] = "A dusty hat often worn by only the cowiest of boys",
		["type"] = "hat",
		["hair"] = false,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/apparel/cowboyhat4.mdl",
		["bodygroup"] = 6,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 45,
	},
	["ncrcowboyhat"] = {
		["name"] = "Casual Ranger Hat",
		["desc"] = "A casual NCR Ranger Hat | NCR - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/apparel/cowboyhat4.mdl",
		["bodygroup"] = 6,
		["rarity"] = 3,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 60,
	},
	["blackcowboyhat"] = {
		["name"] = "Black Cowboy Hat",
		["desc"] = "A dusty hat often worn by only the cowiest of boys",
		["type"] = "hat",
		["hair"] = false,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/apparel/cowboyhat.mdl",
		["bodygroup"] = 7,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 45,
	},
	["constructionhat"] = {
		["name"] = "Construction Hat",
		["desc"] = "A Construction Worker's hardhat",
		["type"] = "hat",
		["hair"] = false,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/apparel/helmetmetalarmor.mdl",
		["bodygroup"] = 8,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 60,
		["speed"] = -12,
	},
	["enclave_officer_hat"] = {
		["name"] = "Enclave Hat",
		["desc"] = "A hat worn by members of The Enclave | ENCLAVE - FACTION ARMOR",
		["type"] = "hat",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group199",
		["modelType"] = "hat",
		["malePrefix"] = "m_",
		["femalePrefix"] = "f_",
		["hair"] = false,
		["itemModel"] = "models/fallout/generalhelmet.mdl",
		["head"] = true,
		["damage"] = 60,
		["speed"] = 0,
	},
	["baseball"] = {
		["name"] = "Baseball Cap",
		["desc"] = "A baseball cap often worn by those with strong right-arms | +1 STR",
		["type"] = "hat",
		["hair"] = false,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/hoodoasis.mdl",
		["bodygroup"] = 9,
		["pathType"] = "headgear",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 1)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
		end,
		["head"] = true,
		["damage"] = 30,
		["speed"] = 0,
	},
	["partyhat"] = {
		["name"] = "Party Hat",
		["desc"] = "That's right, you're invited!",
		["type"] = "hat",
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/apparel/partyhat.mdl",
		["bodygroup"] = 10,
		["head"] = true,
		["pathType"] = "headgear",
	},
	["pimphat"] = {
		["name"] = "Pimp Hat",
		["desc"] = "A hat often worn by Sex Trafficers | +2 CHR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/apparel/cowboyhat.mdl",
		["bodygroup"] = 11,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "C", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "C")
		end,
		["head"] = true,
		["pathType"] = "headgear",
		["damage"] = 35,
	},
	["rangerhat"] = {
		["name"] = "NCR Patrol Ranger Hat",
		["desc"] = "A Ranger Hat often worn by the NCR's finest | NCR - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/apparel/cowboyhat2.mdl",
		["bodygroup"] = 12,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 65,
	},
	["firefighterhelmet"] = {
		["name"] = "Fire Fighter Helmet",
		["desc"] = "A pre-war helmet worn by Fire Fighters",
		["type"] = "hat",
		["hair"] = false,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/apparel/firehelmet.mdl",
		["bodygroup"] = 13,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 45,
	},
	["motorhelmet"] = {
		["name"] = "Motorcycle Helmet",
		["desc"] = "A Ranger Hat  often worn by the NCR's finest | NCR - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/apparel/gscbandit.mdl",
		["bodygroup"] = 14,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 45,
	},
	["hood"] = {
		["name"] = "Ominous Hood",
		["desc"] = "A hand-made hood used to hide ones complection",
		["type"] = "hat",
		["hair"] = false,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/apparel/headwrap.mdl",
		["bodygroup"] = 15,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 35,
	},
	["tophat"] = {
		["name"] = "Top Hat",
		["desc"] = "Only for the most dapper",
		["type"] = "hat",
		["hair"] = false,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/apparel/tophat.mdl",
		["bodygroup"] = 16,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 35,
	},
	["tradercap"] = {
		["name"] = "Trader Cap",
		["desc"] = "A cap often worn by wasteland traders and merchants | +2 CHR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/fedora1.mdl",
		["bodygroup"] = 17,
		["pathType"] = "headgear",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "C", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "C")
		end,
		["head"] = true,
		["damage"] = 35,
	},
	["headwrap"] = {
		["name"] = "Durag",
		["desc"] = "Some cloth used to cover the head",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/apparel/headwrap.mdl",
		["bodygroup"] = 18,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 35,
	},
	["motorlandhood"] = {
		["name"] = "Wastelander Motor Hood",
		["desc"] = "A handmade hood made of scavenged material",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/fallout4hood.mdl",
		["bodygroup"] = 19,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 45,
	},
	["wastelandhood"] = {
		["name"] = "Wastelander Hood",
		["desc"] = "A handmade hood made of scavenged material",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/apparel/legionhood_go.mdl",
		["bodygroup"] = 20,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 45,
	},
	["prospectorhood"] = {
		["name"] = "Shank Hood",
		["desc"] = "A handmade hood made of scavenged material",
		["type"] = "hat",
		["hair"] = false,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/apparel/headwrap.mdl",
		["bodygroup"] = 21,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 35,
	},
	["policehat"] = {
		["name"] = "Police Hat",
		["desc"] = "A handmade hood made of scavenged material",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats02",
		["itemModel"] = "models/fallout/apparel/firehelmet.mdl",
		["bodygroup"] = 1,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 40,
	},
	["pilot"] = {
		["name"] = "Pilot Hat",
		["desc"] = "A handmade hood made of scavenged material",
		["type"] = "hat",
		["hair"] = false,
		["modelType"] = "hats02",
		["itemModel"] = "models/fallout/apparel/sshelm.mdl",
		["bodygroup"] = 2,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 35,
	},
	["boomerpilot"] = {
		["name"] = "Boomer Pilot Hat",
		["desc"] = "A pilot's hat worn often by Boomers | BOOMER - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["modelType"] = "hats02",
		["itemModel"] = "modelswQ/fallout/leatherpilot.mdl",
		["bodygroup"] = 2,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 60,
	},
	["greencombathelmi"] = {
		["name"] = "Green Combat Helmet MKI",
		["desc"] = "A combat armor helmet | GUNNERS - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["modelType"] = "hats02",
		["itemModel"] = "models/fallout/apparel/combatarmorhelmet.mdl",
		["bodygroup"] = 3,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 50,
	},
	["desertcombathelmi"] = {
		["name"] = "Desert Combat Helmet MKI",
		["desc"] = "A combat armor helmet",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats02",
		["itemModel"] = "models/fallout/apparel/combatarmorhelmet.mdl",
		["bodygroup"] = 3,
		["skin"] = 1,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 50,
	},
	["blackcombathelmi"] = {
		["name"] = "Black Combat Helmet MKI",
		["desc"] = "A combat armor helmet",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats02",
		["itemModel"] = "models/fallout/apparel/combatarmorhelmet.mdl",
		["bodygroup"] = 3,
		["skin"] = 2,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 50,
	},
	/** ["boscombathelmet"] = { -- Old helmet used by the BOS
		["name"] = "BOS Combat Helmet",
		["desc"] = "A combat helmet often worn by Brotherhood of Steel Military personnel | BOS - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats02",
		["itemModel"] = "models/fallout/apparel/mark1combathelmet.mdl",
		["bodygroup"] = 4,
		["skin"] = 1,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 55,
	},**/
	["boscombathelmet"] = {
		["name"] = "BOS Initiate Helmet",
		["desc"] = "A combat helmet often worn by Brotherhood of Steel Military personnel | BOS - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group204",
		["modelType"] = "helmet",
		["maleScale"] = 1,
		["femaleScale"] = 1,
		["maleSuffix"] = "_male",
		["femaleSuffix"] = "_female",
		["itemModel"] = "models/fallout/vargantalthelmet2.mdl",
		["head"] = true,
		["rarity"] = 2,
		["damage"] = 55,
	},
	["blackcombathelminecrosis"] = {
		["name"] = "Necropolis Combat Helmet",
		["desc"] = "A combat armor helmet | NECROPOLIS - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats02",
		["itemModel"] = "models/fallout/apparel/combatarmorhelmet.mdl",
		["bodygroup"] = 3,
		["skin"] = 2,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 53,
	},
	["forestcombathelmi"] = {
		["name"] = "Forest Combat Helmet MKI",
		["desc"] = "A combat armor helmet",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats02",
		["itemModel"] = "models/fallout/apparel/combatarmorhelmet.mdl",
		["bodygroup"] = 3,
		["skin"] = 3,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 50,
	},
	["combathelmii"] = {
		["name"] = "Combat Helmet MKII",
		["desc"] = "An improved combat helmet often worn by professional killers.",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats02",
		["itemModel"] = "models/fallout/apparel/mark1combathelmet.mdl",
		["bodygroup"] = 4,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 55,
	},
	["combathelmiii"] = {
		["name"] = "Combat Helmet MKIII",
		["desc"] = "An improved combat helmet often worn by professional killers.",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats02",
		["itemModel"] = "models/fallout/apparel/mark1combathelmet.mdl",
		["bodygroup"] = 4,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 65,
	},
	["silvercombathelmii"] = {
		["name"] = "Silver Combat Helmet MKII",
		["desc"] = "An improved combat helmet often worn by professional killers.",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats02",
		["itemModel"] = "models/fallout/apparel/mark1combathelmet.mdl",
		["bodygroup"] = 4,
		["skin"] = 1,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 55,
	},
	["silvercombathelmiii"] = {
		["name"] = "Silver Combat Helmet MKIII",
		["desc"] = "An improved combat helmet often worn by professional killers.",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats02",
		["itemModel"] = "models/fallout/apparel/mark1combathelmet.mdl",
		["bodygroup"] = 4,
		["skin"] = 1,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 65,
	},
	["goldcombathelmii"] = {
		["name"] = "Gold Combat Helmet MKII",
		["desc"] = "An improved combat helmet often worn by professional killers.",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats02",
		["itemModel"] = "models/fallout/apparel/mark1combathelmet.mdl",
		["bodygroup"] = 4,
		["skin"] = 2,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 55,
	},
	["goldcombathelmiii"] = {
		["name"] = "Gold Combat Helmet MKIII",
		["desc"] = "An improved combat helmet often worn by professional killers.",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats02",
		["itemModel"] = "models/fallout/apparel/mark1combathelmet.mdl",
		["bodygroup"] = 4,
		["skin"] = 2,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 65,
	},
	["platcombathelmii"] = {
		["name"] = "Platinum Combat Helmet MKIII",
		["desc"] = "An improved combat helmet often worn by professional killers.",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats02",
		["itemModel"] = "models/fallout/apparel/mark1combathelmet.mdl",
		["bodygroup"] = 4,
		["skin"] = 3,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 65,
	},
	["fiendwelp"] = {
		["name"] = "Fiend Anarchist Helmet",
		["desc"] = "A handcrafted leather & bone helmet used by the Chem Fiends | FIENDS - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats02",
		["itemModel"] = "models/fallout/apparel/helmetraider03.mdl",
		["bodygroup"] = 5,
		["skin"] = 2,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 60,
	},
	["fiendblood"] = {
		["name"] = "Fiend Bonecrusher Helmet",
		["desc"] = "A handcrafted leather & bone helmet used by the Chem Fiends | FIENDS - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats02",
		["itemModel"] = "models/fallout/apparel/helmetraider03.mdl",
		["bodygroup"] = 5,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 60,
	},
	["fiendapac"] = {
		["name"] = "Fiend Apocalypto Helmet",
		["desc"] = "A handcrafted leather & bone helmet used by the Chem Fiends | FIENDS - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats02",
		["itemModel"] = "models/fallout/apparel/helmetraider03.mdl",
		["bodygroup"] = 5,
		["skin"] = 1,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 60,
	},
	["blackmotor"] = {
		["name"] = "Black Motorcycle Helmet",
		["desc"] = "A black Motorcyle Helmet, stained by flame",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats02",
		["itemModel"] = "models/fallout/apparel/panzerhelm.mdl",
		["bodygroup"] = 6,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 45,
	},
	["raiderblackmask"] = {
		["name"] = "Black Raider Helmet",
		["desc"] = "A hand-made leather helmet-mask often used by Raiders | FIEND/PARADISE - FACTION NEUTRAL ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["modelType"] = "hats02",
		["itemModel"] = "models/fallout/apparel/raiderarmorhelmet.mdl",
		["bodygroup"] = 6,
		["cannotWear"] = {
			["glasses"] = true,
		},
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are wearing Faction Neutral Armor", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer wearing Faction Neutral Armor", "ui/notify.mp3")
		end,
		["head"] = true,
		["pathType"] = "headgear",
		["damage"] = 55,
	},
	["centurionhelmet"] = {
		["name"] = "Legion Centurion Helmet",
		["desc"] = "A Helmet crafted from the Fallen Foes of Legionary who have earned the right to be that of Centurion | LEGION - FACTION OFFICER ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["modelType"] = "fullhats01",
		["itemModel"] = "models/fallout/apparel/centurionhelmet_go.mdl",
		["bodygroup"] = 9,
		["rootPath"] = "models/lazarusroleplay/headgear/factions/",
		["pathType"] = "legion",
		["malePrefix"] = "m_",
		["femalePrefix"] = "f_",
		["rarity"] = 4,
		["head"] = true,
		["damage"] = 70
	},
	["legionrecruithelmet"] = {
		["name"] = "Legionary Recruit Helmet",
		["desc"] = "A scavenged helmet worn often worn by Recruit Legionaries | LEGION - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["modelType"] = "fullhats01",
		["itemModel"] = "models/fallout/apparel/legionbandana_go.mdl",
		["bodygroup"] = 1,
		["rootPath"] = "models/lazarusroleplay/headgear/factions/",
		["pathType"] = "legion",
		["malePrefix"] = "m_",
		["femalePrefix"] = "f_",
		["rarity"] = 1,
		["cannotWear"] = {
			["glasses"] = true,
			["mask"] = true
		},
		["head"] = true,
		["damage"] = 63
	},
	["legionprimehelmet"] = {
		["name"] = "Legionary Prime Helmet",
		["desc"] = "A scavenged helmet worn often worn by Prime Legionaries | LEGION - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["modelType"] = "fullhats01",
		["itemModel"] = "models/fallout/apparel/legionhelmetbase_go.mdl",
		["bodygroup"] = 2,
		["rootPath"] = "models/lazarusroleplay/headgear/factions/",
		["pathType"] = "legion",
		["malePrefix"] = "m_",
		["femalePrefix"] = "f_",
		["rarity"] = 1,
		["cannotWear"] = {
			["glasses"] = true,
			["mask"] = true
		},
		["head"] = true,
		["damage"] = 64
	},
	["legionveteranhelmet"] = {
		["name"] = "Legionary Veteran Helmet",
		["desc"] = "A scavenged helmet worn often worn by Veteran Legionaries | LEGION - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["modelType"] = "fullhats01",
		["itemModel"] = "models/fallout/apparel/legionwhitehelmetbase_go.mdl",
		["bodygroup"] = 3,
		["rootPath"] = "models/lazarusroleplay/headgear/factions/",
		["pathType"] = "legion",
		["malePrefix"] = "m_",
		["femalePrefix"] = "f_",
		["rarity"] = 2,
		["cannotWear"] = {
			["glasses"] = true,
			["mask"] = true
		},
		["head"] = true,
		["damage"] = 65
	},
	["recruit_decanus"] = {
		["name"] = "Legion Recruit Decanus Helmet",
		["desc"] = "A scavenged helmet worn often worn by Recruit Decanus | LEGION - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["modelType"] = "fullhats01",
		["itemModel"] = "models/fallout/apparel/legionfeatherhead01_go.mdl",
		["bodygroup"] = 4,
		["rootPath"] = "models/lazarusroleplay/headgear/factions/",
		["pathType"] = "legion",
		["malePrefix"] = "m_",
		["femalePrefix"] = "f_",
		["rarity"] = 3,
		["cannotWear"] = {
			["glasses"] = true,
			["mask"] = true
		},
		["head"] = true,
		["damage"] = 66
	},
	["armor_legiondecanus"] = {
		["name"] = "Legion Prime Decanus Helmet",
		["desc"] = "A scavenged helmet worn often worn by Prime Decanus | LEGION - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["modelType"] = "fullhats01",
		["itemModel"] = "models/fallout/apparel/legionfeatherhead01_go.mdl",
		["bodygroup"] = 5,
		["rootPath"] = "models/lazarusroleplay/headgear/factions/",
		["pathType"] = "legion",
		["malePrefix"] = "m_",
		["femalePrefix"] = "f_",
		["rarity"] = 3,
		["cannotWear"] = {
			["glasses"] = true,
			["mask"] = true
		},
		["head"] = true,
		["damage"] = 67
	},
	["legionvetdecanus"] = {
		["name"] = "Legion Veteran Decanus Helmet",
		["desc"] = "A scavenged helmet worn often worn by Veteran Decanus | LEGION - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["modelType"] = "fullhats01",
		["itemModel"] = "models/fallout/apparel/legionfeatherhead02_go.mdl",
		["bodygroup"] = 6,
		["rootPath"] = "models/lazarusroleplay/headgear/factions/",
		["pathType"] = "legion",
		["malePrefix"] = "m_",
		["femalePrefix"] = "f_",
		["rarity"] = 3,
		["cannotWear"] = {
			["glasses"] = true,
			["mask"] = true
		},
		["head"] = true,
		["damage"] = 68
	},
	["legionhood"] = {
		["name"] = "Legion Hood",
		["desc"] = "A scavenged helmet worn often worn by Legion Scouts | LEGION - FACTION ARMOR | +5 SPEED",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "fullhats01",
		["itemModel"] = "models/fallout/apparel/legionhood_go.mdl",
		["bodygroup"] = 7,
		["rootPath"] = "models/lazarusroleplay/headgear/factions/",
		["pathType"] = "legion",
		["malePrefix"] = "m_",
		["femalePrefix"] = "f_",
		["rarity"] = 2,
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false
		},
		["head"] = true,
		["damage"] = 60,
		["speed"] = 5,
	},
	["legionwolfehead"] = {
		["name"] = "Legion Frumentarii Headwear",
		["desc"] = "A headpiece made of Coyote fur often worn by Legion Frumentarii | LEGION - FACTION ARMOR | +5 SPEED",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "fullhats01",
		["itemModel"] = "models/fallout/apparel/legionwollfhead_go.mdl",
		["bodygroup"] = 8,
		["rootPath"] = "models/lazarusroleplay/headgear/factions/",
		["pathType"] = "legion",
		["malePrefix"] = "m_",
		["femalePrefix"] = "f_",
		["rarity"] = 4,
		["cannotWear"] = {
			["glasses"] = true,
			["mask"] = false
		},
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "P", 4)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "P")
		end,
		["head"] = true,
		["damage"] = 65,
	},
	["legionvexhelmet"] = {
		["name"] = "Legion Vexillarius Headwear",
		["desc"] = "A headpiece made of Coyote fur often worn by Legion Vexillarius | LEGION - FACTION ARMOR | +5 SPEED",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["itemModel"] = "models/fallout/apparel/legionwollfhead_go.mdl",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group304",
		["modelType"] = "hood",
		["malePrefix"] = "male_",
		["femalePrefix"] = "female_",
		["armsModel"] = "models/thespireroleplay/humans/group110/arms/male_arm.mdl",
		["rarity"] = 3,
		["cannotWear"] = {
			["glasses"] = true,
			["mask"] = false
		},
		["head"] = true,
		["damage"] = 65,
		["speed"] = 5,
	},
	["legatehelmet"] = {
		["name"] = "Legion Legatus Helmet",
		["desc"] = "The custom made metal helmet worn by the Legates of Caesar Legion. Representing Mars himself | LEGION - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["modelType"] = "fullhats01",
		["itemModel"] = "models/fallout/apparel/legatehelmgo.mdl",
		["bodygroup"] = 10,
		["rootPath"] = "models/lazarusroleplay/headgear/factions/",
		["pathType"] = "legion",
		["malePrefix"] = "m_",
		["femalePrefix"] = "f_",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false
		},
		["rarity"] = 5,
		["head"] = true,
		["damage"] = 90
	},
	["khanfacemask"] = {
		["name"] = "Khan Face Mask",
		["desc"] = "A scavenged helmet worn often worn by the Great Khans | GK - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["modelType"] = "fullhats01",
		["itemModel"] = "models/fallout/apparel/legionbandana_go.mdl",
		["bodygroup"] = 1,
		["rootPath"] = "models/lazarusroleplay/headgear/factions/",
		["pathType"] = "legion",
		["malePrefix"] = "m_",
		["femalePrefix"] = "f_",
		["rarity"] = 1,
		["cannotWear"] = {
			["glasses"] = true,
			["mask"] = true
		},
		["head"] = true,
		["damage"] = 58
	},
	["metalbikerhelmet"] = {
		["name"] = "Metal Biker Helmet",
		["desc"] = "A Metal Helmet worn as a Biker's Helmet in Pre-War America | Male Armor",
		["type"] = "hat",
		["hair"] = false,
		["modelType"] = "helmets01",
		["itemModel"] = "models/fallout/headgear/helmetmetalarmor.mdl",
		["bodygroup"] = 2,
		["pathType"] = "headgear",
		["sex"] = "male",
		["cannotWear"] = {
			["mask"] = false
		},
		["head"] = true,
		["damage"] = 40
	},
	["jackalmetalbikerhelmet"] = {
		["name"] = "Forged Biker Helmet",
		["desc"] = "A Metal Helmet worn as a Biker's Helmet in Pre-War America | FORGED - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["modelType"] = "helmets01",
		["itemModel"] = "models/fallout/headgear/helmetmetalarmor.mdl",
		["bodygroup"] = 2,
		["pathType"] = "headgear",
		["sex"] = "male",
		["cannotWear"] = {
			["mask"] = false
		},
		["head"] = true,
		["damage"] = 68
	},
	["crazedraiderhelmet"] = {
		["name"] = "Crazed Raider Helmet",
		["desc"] = "A Leather helmet often worn by Raiders & Bandits of the Wasteland | FIEND / PARADISE / FORGED - FACTION NEUTRAL ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["modelType"] = "helmets01",
		["itemModel"] = "models/fallout/apparel/raiderarmorhelmet.mdl",
		["bodygroup"] = 3,
		["pathType"] = "headgear",
		["sex"] = "male",
		["cannotWear"] = {
			["glasses"] = true
		},
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are wearing Faction Neutral Armor", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer wearing Faction Neutral Armor", "ui/notify.mp3")
		end,
		["head"] = true,
		["damage"] = 50
	},
	["ncrhelmet"] = {
		["name"] = "NCR Trooper Helmet",
		["desc"] = "A helmet crafted by NCR Engineers and used by NCR Military Personnel | NCR - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["pathType"] = "headgear",
		["modelType"] = "helmets01",
		["bodygroup"] = 6,
		["itemModel"] = "models/fallout/apparel/trooperhelm.mdl",
		["cannotWear"] = {
			["glasses"] = true,
			["mask"] = true
		},
		["head"] = true,
		["damage"] = 63,
		["sex"] = "male"
	},
	["rangerhelmet-b"] = {
		["name"] = "Elite Riot Gear Helmet",
		["desc"] = "A riot police officer helmet worn by the elite of the L.A.P.D. before the war. This specific armor was later adopted by the Riot Rangers, a now disbanded faction that sought to bring cold authority to the wasteland. | Nuclear Patriot - Faction Armor",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true
		},
		["modelType"] = "helmet",
		["itemModel"] = "models/fallout/apparel/combatrangerhelmet.mdl",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group008",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["maleScale"] = 1.05,
		["femaleScale"] = 1,
		["rarity"] = 4,
		["head"] = true,
		["damage"] = 70
	},
	["rangerhelmet-rr-vet"] = {
		["name"] = "Riot Ranger Veteran Helmet",
		["desc"] = "The helmet of a true Riot Ranger. Bruised and battered through the years.",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true
		},
		["itemModel"] = "models/fallout/apparel/combatrangerhelmet.mdl",
		["rootPath"] = "models/cgcclothing/humans/",
		["pathType"] = "militia_courier",
		["modelType"] = "militia_riot_helmet",
		["OnWear"] = function(ply, item)
			ply.RRVetCooldown = ply.RRVetCooldown or CurTime()

			if (ply.RRVetCooldown > CurTime()) then return end
			ply:falloutNotify("The helmet weighs heavy on your shoulders . . .", "fallout/reveal.wav")
			ply.RRVetCooldown = CurTime() + 60
		end,
		["OnRemove"] = function(ply, item)
		end,
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["maleScale"] = 1.08,
		["femaleScale"] = 1.08,
		["rarity"] = 5,
		["head"] = true,
		["damage"] = 70
	},
	["rangerhelmet-r"] = {
		["name"] = "Desert Ranger Helmet [Blue]", -- CONVERTED ANARCHY HELMET DUE TO MILITIA ADDITION
		["desc"] = "A Riot Officer Specialist helmet repurposed by the New California Republic | DR - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true
		},
		["itemModel"] = "models/fallout/apparel/combatrangerhelmet.mdl",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group315",
		["modelType"] = "rangercombat_helmet",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["rarity"] = 4,
		["head"] = true,
		["damage"] = 70
	},
	["rangerhelmet-bullet"] = {
		["name"] = "NCR Ranger Officer Helmet", -- CONVERTED ANARCHY HELMET DUE TO MILITIA ADDITION
		["desc"] = "A Riot Officer Specialist helmet repurposed by the New California Republic | NCR - FACTION OFFICER ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true
		},
		["itemModel"] = "models/fallout/apparel/combatrangerhelmet.mdl",
		["rootPath"] = "models/cgcclothing/humans/",
		["pathType"] = "militia_courier",
		["modelType"] = "militia_riot_helmet",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["noHead"] = true,
		["rarity"] = 4,
		["head"] = true,
		["damage"] = 70
	},
	["rangerhelmet-g"] = {
		["name"] = "Desert Ranger Helmet [Green]", -- CONVERTED ANARCHY HELMET DUE TO MILITIA ADDITION
		["desc"] = "A Riot Officer Specialist helmet repurposed by the New California Republic | DR - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true
		},
		["itemModel"] = "models/fallout/apparel/combatrangerhelmet.mdl",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group315",
		["modelType"] = "rangercombat_helmet",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["skin"] = 2,
		["rarity"] = 4,
		["head"] = true,
		["damage"] = 70
	},
	["rangerhelmet-veteran"] = {
		["name"] = "Desert Ranger Veteran Helmet", -- CONVERTED ANARCHY HELMET DUE TO MILITIA ADDITION
		["desc"] = "A Riot Officer Specialist helmet repurposed by the New California Republic | DR - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true
		},
		["itemModel"] = "models/fallout/apparel/combatrangerhelmet.mdl",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group315",
		["modelType"] = "rangercombat_helmet",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["skin"] = 7,
		["rarity"] = 4,
		["head"] = true,
		["damage"] = 70
	},
	["rangerhelmet-p"] = {
		["name"] = "Desert Ranger Helmet [Purple]", -- CONVERTED ANARCHY HELMET DUE TO MILITIA ADDITION
		["desc"] = "A Riot Officer Specialist helmet repurposed by the New California Republic | DR - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true
		},
		["itemModel"] = "models/fallout/apparel/combatrangerhelmet.mdl",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group315",
		["modelType"] = "rangercombat_helmet",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["skin"] = 3,
		["rarity"] = 4,
		["head"] = true,
		["damage"] = 70
	},
	["rangerhelmet-w"] = {
		["name"] = "Desert Ranger Helmet [White]", -- CONVERTED ANARCHY HELMET DUE TO MILITIA ADDITION
		["desc"] = "A Riot Officer Specialist helmet repurposed by the New California Republic | DR - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true
		},
		["itemModel"] = "models/fallout/apparel/combatrangerhelmet.mdl",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group315",
		["modelType"] = "rangercombat_helmet",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["skin"] = 4,
		["rarity"] = 4,
		["head"] = true,
		["damage"] = 70
	},
	["rangerhelmet-red"] = {
		["name"] = "Desert Ranger Helmet [Red]", -- CONVERTED ANARCHY HELMET DUE TO MILITIA ADDITION
		["desc"] = "A Riot Officer Specialist helmet repurposed by the New California Republic | DR - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true
		},
		["itemModel"] = "models/fallout/apparel/combatrangerhelmet.mdl",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group315",
		["modelType"] = "rangercombat_helmet",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["skin"] = 1,
		["rarity"] = 4,
		["head"] = true,
		["damage"] = 70
	},
	["rangerhelmet-hero"] = {
		["name"] = "Desert Ranger Hero Helmet", -- CONVERTED ANARCHY HELMET DUE TO MILITIA ADDITION
		["desc"] = "A Riot Officer Specialist helmet repurposed by the New California Republic | DR - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true
		},
		["itemModel"] = "models/fallout/apparel/combatrangerhelmet.mdl",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group315",
		["modelType"] = "rangercombat_helmet",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["skin"] = 10,
		["rarity"] = 4,
		["head"] = true,
		["damage"] = 70
	},
-------------

	["rangerhelmet-r-militia"] = {
		["name"] = "Militia Anarchy Helmet [Red]",
		["desc"] = "A Riot Officer Specialist helmet repurposed by the New California Republic | MILITIA - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true
		},
		["modelType"] = "desertranger_helmet",
		["itemModel"] = "models/fallout/apparel/combatrangerhelmet.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["maleScale"] = 1,
		["femaleScale"] = 1,
		["skin"] = 11,
		["rarity"] = 4,
		["head"] = true,
		["damage"] = 70
	},
	["rangerhelmet-g-militia"] = {
		["name"] = "Militia Anarchy Helmet [Green]",
		["desc"] = "A Riot Officer Specialist helmet repurposed by the New California Republic | MILITIA - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true
		},
		["modelType"] = "desertranger_helmet",
		["itemModel"] = "models/fallout/apparel/combatrangerhelmet.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["maleScale"] = 1,
		["femaleScale"] = 1,
		["skin"] = 12,
		["rarity"] = 4,
		["head"] = true,
		["damage"] = 70
	},
	["rangerhelmet-p-militia"] = {
		["name"] = "Militia Anarchy Helmet [Purple]",
		["desc"] = "A Riot Officer Specialist helmet repurposed by the New California Republic | MILITIA - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true
		},
		["modelType"] = "desertranger_helmet",
		["itemModel"] = "models/fallout/apparel/combatrangerhelmet.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["maleScale"] = 1,
		["femaleScale"] = 1,
		["skin"] = 13,
		["rarity"] = 4,
		["head"] = true,
		["damage"] = 70
	},
	["rangerhelmet-w-militia"] = {
		["name"] = "Militia Anarchy Helmet [White]",
		["desc"] = "A Riot Officer Specialist helmet repurposed by the New California Republic | MILITIA - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true
		},
		["modelType"] = "desertranger_helmet",
		["itemModel"] = "models/fallout/apparel/combatrangerhelmet.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["maleScale"] = 1,
		["femaleScale"] = 1,
		["skin"] = 14,
		["rarity"] = 4,
		["head"] = true,
		["damage"] = 70
	},
	["rangerhelmet-orange-militia"] = {
		["name"] = "Militia Road Riot Helmet [Orange]",
		["desc"] = "A Riot Officer Specialist helmet repurposed by the New California Republic. However, the NCR never got even close to looking this stylish | MILITIA - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true
		},
		["itemModel"] = "models/fallout/apparel/combatrangerhelmet.mdl",
		["rootPath"] = "models/cgcclothing/humans/",
		["pathType"] = "militia_courier",
		["modelType"] = "militia_riot_helmet",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["noHead"] = true,
		["rarity"] = 4,
		["head"] = true,
		["damage"] = 70,
		["skin"] = 1
	},

	---------------
	["veteranrangerhelmet-g"] = {
		["name"] = "Desert Ranger Helmet [Green]",
		["desc"] = "A Riot Officer Specialist helmet repurposed by the New California Republic | DR - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true
		},
		["modelType"] = "desertranger_helmet",
		["itemModel"] = "models/fallout/apparel/combatrangerhelmet.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["maleScale"] = 1,
		["femaleScale"] = 1,
		["skin"] = 7,
		["rarity"] = 4,
		["head"] = true,
		["damage"] = 70
	},
	["veteranrangerhelmet-b"] = {
		["name"] = "NCR Veteran Ranger Helmet [Green]",
		["desc"] = "A Riot Officer Specialist helmet repurposed by the New California Republic | NCR - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true,
		},
		["modelType"] = "desertranger_helmet",
		["itemModel"] = "models/fallout/apparel/combatrangerhelmet.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["maleScale"] = 1,
		["femaleScale"] = 1,
		["skin"] = 7,
		["rarity"] = 4,
		["head"] = true,
		["damage"] = 70
	},
	["veteranrangerhelmet-r"] = {
		["name"] = "NCR Veteran Ranger Helmet [Red]",
		["desc"] = "A Riot Officer Specialist helmet repurposed by the New California Republic | NCR - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true
		},
		["modelType"] = "desertranger_helmet",
		["itemModel"] = "models/fallout/apparel/combatrangerhelmet.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["maleScale"] = 1,
		["femaleScale"] = 1,
		["skin"] = 6,
		["rarity"] = 4,
		["head"] = true,
		["damage"] = 70
	},
	["veteranrangerhelmet-g"] = {
		["name"] = "NCR Ranger Chief Helmet [Blue]",
		["desc"] = "A Riot Officer Specialist helmet repurposed by the New California Republic | NCR - FACTION OFFICER ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true,
		},
		["modelType"] = "desertranger_helmet",
		["itemModel"] = "models/fallout/apparel/combatrangerhelmet.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["maleScale"] = 1,
		["femaleScale"] = 1,
		["skin"] = 5,
		["rarity"] = 4,
		["head"] = true,
		["damage"] = 70
	},
	["veteranrangerhelmet-p"] = {
		["name"] = "NCR Veteran Ranger Helmet [Purple]",
		["desc"] = "A Riot Officer Specialist helmet repurposed by the New California Republic | NCR - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true
		},
		["modelType"] = "desertranger_helmet",
		["itemModel"] = "models/fallout/apparel/combatrangerhelmet.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["maleScale"] = 1,
		["femaleScale"] = 1,
		["skin"] = 8,
		["rarity"] = 4,
		["head"] = true,
		["damage"] = 70
	},
	["veteranrangerhelmet-w"] = {
		["name"] = "NCR Veteran Ranger Helmet [White]",
		["desc"] = "A Riot Officer Specialist helmet repurposed by the New California Republic | NCR - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true
		},
		["modelType"] = "desertranger_helmet",
		["itemModel"] = "models/fallout/apparel/combatrangerhelmet.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["maleScale"] = 1,
		["femaleScale"] = 1,
		["skin"] = 9,
		["rarity"] = 4,
		["head"] = true,
		["damage"] = 70
	},
	["sombrero"] = {
		["name"] = "Sombrero",
		["desc"] = "livin la vida loca!",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["itemModel"] = "models/fallout/headgear/cowboyhat5.mdl",
		["rootPath"] = "models/lazarusroleplay/",
		["pathType"] = "headgear",
		["modelType"] = "hats01",
		["bodygroup"] = 8,
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["maleScale"] = 1,
		["femaleScale"] = 1,
		["rarity"] = 3,
		["head"] = true,
		["damage"] = 35
	},
	["ncrmphelmet"] = {
		["name"] = "NCR Military Police Helmet",
		["desc"] = "A helmet crafted by NCR Engineers and used by NCR Military Police Personnel | NCR - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["modelType"] = "helmets01",
		["itemModel"] = "models/fallout/apparel/trooperhelm.mdl",
		["bodygroup"] = 7,
		["pathType"] = "headgear",
		["sex"] = "male",
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true
		},
		["head"] = true,
		["damage"] = 65,
		["speed"] = 0,
	},
	["riotcontrol"] = {
		["name"] = "Riot Helmet",
		["desc"] = "A helmet often used by Vault-Tec Security personnel and Pre-War Police for riot control | VT - FACTION NEUTRAL ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["modelType"] = "helmets01",
		["itemModel"] = "models/fallout/headgear/vaultsecurityhelmet.mdl",
		["bodygroup"] = 8,
		["pathType"] = "headgear",
		["sex"] = "male",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false
		},
		["head"] = true,
		["damage"] = 58
	},
	["welderfacemask"] = {
		["name"] = "Welder Face Mask",
		["desc"] = "A mask and helmet often used by Pre-War workers to protect their face from heat and sparks | FIENDS - FACTION ARMOR | -2 PER / -5 SPEED",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["modelType"] = "helmets01",
		["itemModel"] = "models/fallout/headgear/helmetraider02.mdl",
		["bodygroup"] = 9,
		["pathType"] = "headgear",
		["sex"] = "male",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false
		},
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "P", -2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "P")
		end,
		["head"] = true,
		["damage"] = 60,
		["speed"] = -5
	},
	["ncrberret"] = {
		["name"] = "NCR Officer Beret",
		["desc"] = "A beret often worn by Officers of the New California Republic| NCR - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["itemModel"] = "models/fallout/apparel/green_beret.mdl",
		["malePrefix"] = "",
		["femalePrefix"] = "fem_",
		["modelType"] = "hats01",
		["pathType"] = "headgear",
		["rootPath"] = "models/lazarusroleplay/",
		["bodygroup"] = 1,
		["head"] = true,
		["damage"] = 70
	},
	["ncrreconberret"] = {
		["name"] = "NCR 1st Recon Beret",
		["desc"] = "A beret often worn by Officers of the New California Republic| NCR - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["itemModel"] = "models/fallout/apparel/red_beret.mdl",
		["bodygroup"] = 2,
		["malePrefix"] = "",
		["femalePrefix"] = "fem_",
		["modelType"] = "hats01",
		["pathType"] = "headgear",
		["rootPath"] = "models/lazarusroleplay/",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "P", 3)
			BuffStat(ply, item, "E", 3)
		end,
		["OnRemove"] = function(ply, item)
			BuffStat(ply, item, "P", 3)
			BuffStat(ply, item, "E", 3)
		end,
		["head"] = true,
		["rarity"] = 2,
		["damage"] = 65
	},
	["bonnet"] = {
		["name"] = "Bonnet Hat",
		["desc"] = "A fancy hat that is over-doing it a bit.",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/headgear/cowboyhat4.mdl",
		["bodygroup"] = 3,
		["pathType"] = "headgear",
		["sex"] = "male",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = true
		},
		["head"] = true,
		["damage"] = 35
	},
	["strangerhat"] = {
		["name"] = "Stranger Hat",
		["desc"] = "A hat often worn only by the strangest of strangers.",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/apparel/strangerhat.mdl",
		["bodygroup"] = 5,
		["pathType"] = "headgear",
		["sex"] = "male",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = true
		},
		["rarity"] = 3,
		["head"] = true,
		["damage"] = 35
	},
	["scrapehelmet"] = {
		["name"] = "Metal Scrap Helmet",
		["desc"] = "A scrapy scavenged metal helmet designed for as much protection as it can dish out.",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/headgear/helmetmetalarmor.mdl",
		["bodygroup"] = 7,
		["pathType"] = "headgear",
		["sex"] = "male",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = true
		},
		["head"] = true,
		["damage"] = 42
	},
	["bajahat"] = {
		["name"] = "Baja Hat",
		["desc"] = "A celebratory hat often found in the Baja.",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "hats01",
		["itemModel"] = "models/fallout/apparel/cowboyhat3.mdl",
		["bodygroup"] = 7,
		["pathType"] = "headgear",
		["sex"] = "male",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = true
		},
		["head"] = true,
		["damage"] = 35
	},
	["eyebothelmet"] = {
		["name"] = "Eyebot Helmet",
		["desc"] = "A helmet made of a destroyed Eyebot",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "fullhats01",
		["itemModel"] = "models/llama/eyebot.mdl",
		["bodygroup"] = 1,
		["pathType"] = "headgear",
		["cannotWear"] = {
			["glasses"] = true,
			["mask"] = true
		},
		["head"] = true,
		["damage"] = 42
	},
	["raiderpsycho"] = {
		["name"] = "Raider Psycho Mask",
		["desc"] = "A mask and helmet often worn by Raiders of the Wasteland | FIEND / FORGED - FACTION NEUTRAL ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["modelType"] = "fullhats01",
		["itemModel"] = "models/fallout/apparel/helmetraider03.mdl",
		["bodygroup"] = 2,
		["pathType"] = "headgear",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false
		},
		["head"] = true,
		["damage"] = 54
	},
	["facebandages"] = {
		["name"] = "Face Bandages",
		["desc"] = "A wrapping of facial bandages",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "fullhats01",
		["itemModel"] = "models/fallout/headgear/headwrap.mdl",
		["bodygroup"] = 4,
		["pathType"] = "headgear",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false
		},
		["head"] = true,
		["damage"] = 35
	},
	["clownheadwear"] = {
		["name"] = "Clown Headwear",
		["desc"] = "A terrifying Clown Mascot headpiece",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "fullhats01",
		["itemModel"] = "models/fallout/apparel/partyhat.mdl",
		["bodygroup"] = 5,
		["pathType"] = "headgear",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false
		},
		["head"] = true,
		["damage"] = 42
	},
	["skinmask"] = {
		["name"] = "Skin Mask",
		["desc"] = "A mask created from stitched together skin fragments",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "fullhats01",
		["itemModel"] = "models/fallout/apparel/hockeymask.mdl",
		["bodygroup"] = 6,
		["pathType"] = "headgear",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
		},
		["head"] = true,
		["damage"] = 45
	},
	["slayermask"] = {
		["name"] = "Lobotomite Headgear",
		["desc"] = "A strange headgear piece often worn by the insane | TT - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "fullhats01",
		["itemModel"] = "models/fallout/apparel/hockeymask.mdl",
		["bodygroup"] = 8,
		["pathType"] = "headgear",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
		},
		["head"] = true,
		["damage"] = 55
	},
	["pitt"] = {
		["name"] = "Pitt Raider Helmet",
		["desc"] = "A miner's helmet that has been re-purposed into raider gear | PARADISE - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "fullhats01",
		["itemModel"] = "models/fallout/apparel/minerhelmetgo.mdl",
		["bodygroup"] = 9,
		["pathType"] = "headgear",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false
		},
		["head"] = true,
		["damage"] = 55
	},
	["long_coat_hat"] = { -- Custom Order
		["name"] = "Long Coat Hat",
		["desc"] = "A black cowboy hat worn typically worn its respected coat.",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group300",
		["modelType"] = "hat",
		["maleScale"] = 1.02,
		["femaleScale"] = 1,
		["maleSuffix"] = "_male",
		["femaleSuffix"] = "_female",
		["itemModel"] = "models/fallout/cowboyhat.mdl",
		["head"] = "true",
		["rarity"] = 3,
		["damage"] = 60,
	},
	["coated_stealth_suit_helmet"] = { -- Custom Order
		["name"] = "Coated Stealth Suit Helmet",
		["desc"] = "A Stealth Suit Helmet",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group301",
		["modelType"] = "helmet",
		["maleScale"] = 1.137,
		["femaleScale"] = 1.05,
		["maleSuffix"] = "_male",
		["femaleSuffix"] = "_male",
		["itemModel"] = "models/fallout/apparel/chinesestealthhelm.mdl",
		["head"] = "true",
		["rarity"] = 3,
		["damage"] = 45,
	},
	["great_khan_boss_helmet"] = { -- Custom order by Mr.Damplips#0564
		["name"] = "Great Khan Boss Helmet",
		["desc"] = "A scavenged helmet worn by the bosses of the Great Khans | GK - FACTION ARMOR",
		["type"] = "hat",
		["modelType"] = "helmet",
		["itemModel"] = "models/fallout/apparel/legionbandana_go.mdl",
		["bodygroup"] = 7,
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group526",
		["maleSuffix"] = "_m",
		["femaleSuffix"] = "_f",
		["rarity"] = 4,
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false
		},
		["noHead"] = true,
		["head"] = true,
		["damage"] = 63
	},
    ["nuclear_bucket_hat"] = { -- Custom order by Mr.Damplips#0564
        ["name"] = "Nuclear Bucket Hat",
        ["desc"] = "A boonie hat providing optimal protection agaisn't sun burns. | NP - FACTION ARMOR",
        ["type"] = "hat",
        ["hair"] = false,
        ["modelType"] = "helmet",
        ["itemModel"] = "models/fallout/apparel/trooperhelm.mdl",
        ["bodygroup"] = 7,
        ["rootPath"] = "models/thespireroleplay/humans/",
        ["pathType"] = "group550",
        ["maleSuffix"] = "_m",
        ["rarity"] = 4,
        ["cannotWear"] = {
            ["glasses"] = false,
            ["mask"] = false
        },
        ["head"] = true,
        ["damage"] = 65
    },
	-- POWER ARMOR HELMET --
	["t45powerarmor_helmet"] = { -- 5.0 Community Update
		["name"] = "T-45d Black Power Armor Helmet",
		["desc"] = "A refurbished T-45d Power Armor helmet.",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["rootPath"] = "models/cgcclothing/",
		["pathType"] = "t45",
		["modelType"] = "helmet",
		["maleSuffix"] = "",
		["femaleSuffix"] = "",
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["noHead"] = true,
		["rarity"] = 3,
		["damage"] = 75,
	},
	["armor_legion_pa_helmet"] = { -- 6.0 Community Update
		["name"] = "Legion Power Armor Helmet",
		["desc"] = "A set of Power Armor, with a painted bull. Worn by the Caesar's Legion | LEGION - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group892",
		["maleSuffix"] = "",
		["femaleSuffix"] = "",
		["modelType"] = "helmet",
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["noHead"] = true,
		["rarity"] = 3,
		["damage"] = 72,
	}, 
	["armor_legion_championpa_helmet"] = { -- 6.0 Community Update
		["name"] = "Legion Champion Helmet",
		["desc"] = "A set of Power Armor Helmet for the Champion(s) of the Legion.| LEGION - FACTION OFFICER ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group891",
		["maleSuffix"] = "",
		["femaleSuffix"] = "",
		["modelType"] = "helmet",
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["noHead"] = true,
		["rarity"] = 3,
		["damage"] = 75,
	},   
	["armor_legion_heavycent_helmet"] = { -- 6.0 Community Update
		["name"] = "Heavy Centurion Helmet",
		["desc"] = "An improved Centurion Helmet.| LEGION - FACTION OFFICER ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["modelType"] = "fullhats01",
		["itemModel"] = "models/fallout/apparel/centurionhelmet_go.mdl",
		["bodygroup"] = 9,
		["rootPath"] = "models/lazarusroleplay/headgear/factions/",
		["pathType"] = "legion",
		["malePrefix"] = "m_",
		["femalePrefix"] = "f_",
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 4,
		["damage"] = 80,
	},   
	["t45powerarmor_helmet_rusty"] = { -- 5.0 Community Update
		["name"] = "T-45d Rusty Power Armor Helmet",
		["desc"] = "A refurbished T-45d Power Armor helmet.",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["rootPath"] = "models/cgcclothing/",
		["pathType"] = "t45",
		["modelType"] = "helmet",
		["maleSuffix"] = "",
		["femaleSuffix"] = "",
		["skin"] = 1,
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["noHead"] = true,
		["rarity"] = 3,
		["damage"] = 75,
	},
	["t45powerarmor_helmet_outcast"] = { -- 5.0 Community Update
		["name"] = "T-45d Outcast Power Armor Helmet",
		["desc"] = "A refurbished T-45d Power Armor helmet.",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["rootPath"] = "models/cgcclothing/",
		["pathType"] = "t45",
		["modelType"] = "helmet",
		["maleSuffix"] = "",
		["femaleSuffix"] = "",
		["skin"] = 2,
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["noHead"] = true,
		["rarity"] = 3,
		["damage"] = 75,
	},
	["t45powerarmor_helmet_camo"] = { -- 5.0 Community Update
		["name"] = "T-45d Camo Power Armor Helmet",
		["desc"] = "A refurbished T-45d Power Armor helmet.",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["rootPath"] = "models/cgcclothing/",
		["pathType"] = "t45",
		["modelType"] = "helmet",
		["maleSuffix"] = "",
		["femaleSuffix"] = "",
		["skin"] = 3,
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["noHead"] = true,
		["rarity"] = 3,
		["damage"] = 75,
	},
	["t45powerarmor_helmet_salvaged"] = { -- 5.0 Community Update
		["name"] = "T-45d Crimson Power Armor Helmet",
		["desc"] = "A crimson T-45d Power Armor helmet.",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["rootPath"] = "models/cgcclothing/",
		["pathType"] = "t45",
		["modelType"] = "helmet",
		["maleSuffix"] = "",
		["femaleSuffix"] = "",
		["skin"] = 4,
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["noHead"] = true,
		["rarity"] = 3,
		["damage"] = 75,
	},
	["t45powerarmor_helmet_blue"] = { -- 5.0 Community Update
		["name"] = "T-45d Blue Power Armor Helmet",
		["desc"] = "A refurbished T-45d Power Armor helmet.",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["rootPath"] = "models/cgcclothing/",
		["pathType"] = "t45",
		["modelType"] = "helmet",
		["maleSuffix"] = "",
		["femaleSuffix"] = "",
		["skin"] = 5,
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["noHead"] = true,
		["rarity"] = 3,
		["damage"] = 75,
	},
	["t45powerarmor_helmet_white"] = { -- 5.0 Community Update
		["name"] = "T-45d White Power Armor Helmet",
		["desc"] = "A refurbished T-45d Power Armor helmet.",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["rootPath"] = "models/cgcclothing/",
		["pathType"] = "t45",
		["modelType"] = "helmet",
		["maleSuffix"] = "",
		["femaleSuffix"] = "",
		["skin"] = 6,
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["noHead"] = true,
		["rarity"] = 3,
		["damage"] = 75,
	},
	["t45powerarmor_helmet_boshex"] = { -- 5.0 Community Update
		["name"] = "T-45d BOS Hex Power Armor Helmet",
		["desc"] = "A refurbished T-45d Power Armor helmet used by the special forces of the Brotherhood of Steel | BOS - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["rootPath"] = "models/cgcclothing/",
		["pathType"] = "t45",
		["modelType"] = "helmet",
		["maleSuffix"] = "",
		["femaleSuffix"] = "",
		["skin"] = 7,
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["noHead"] = true,
		["rarity"] = 3,
		["damage"] = 75,
	},
	["t45powerarmor_helmet_dark"] = { -- 5.0 Community Update
		["name"] = "T-45d Dark Power Armor Helmet",
		["desc"] = "A refurbished T-45d Power Armor helmet.",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["rootPath"] = "models/cgcclothing/",
		["pathType"] = "t45",
		["modelType"] = "helmet",
		["maleSuffix"] = "",
		["femaleSuffix"] = "",
		["skin"] = 8,
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["noHead"] = true,
		["rarity"] = 3,
		["damage"] = 75,
	},
	["t45powerarmor_helmet_chinese"] = { -- 5.0 Community Update
		["name"] = "T-45d Chinese Power Armor Helmet",
		["desc"] = "A refurbished T-45d Power Armor helmet.",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["rootPath"] = "models/cgcclothing/",
		["pathType"] = "t45",
		["modelType"] = "helmet",
		["maleSuffix"] = "",
		["femaleSuffix"] = "",
		["skin"] = 9,
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["noHead"] = true,
		["rarity"] = 3,
		["damage"] = 75,
	},
	["t45powerarmor_helmet_gk"] = { -- 5.0 Community Update
		["name"] = "T-45d Great Khan Power Armor Helmet",
		["desc"] = "A refurbished T-45d Power Armor helmet.",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["rootPath"] = "models/cgcclothing/",
		["pathType"] = "t45",
		["modelType"] = "helmet",
		["maleSuffix"] = "",
		["femaleSuffix"] = "",
		["skin"] = 10,
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["noHead"] = true,
		["rarity"] = 3,
		["damage"] = 75,
	},
	["t45powerarmor_helmet_vt"] = { -- 5.0 Community Update
		["name"] = "T-45d Vault-Tec Armor Helmet",
		["desc"] = "A refurbished T-45d Power Armor helmet | VT - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["rootPath"] = "models/cgcclothing/",
		["pathType"] = "t45",
		["modelType"] = "helmet",
		["maleSuffix"] = "",
		["femaleSuffix"] = "",
		["skin"] = 11,
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["noHead"] = true,
		["rarity"] = 3,
		["damage"] = 75,
	},
	["t45powerarmor_helmet_army"] = { -- 5.0 Community Update
		["name"] = "T-45d Army Power Armor Helmet",
		["desc"] = "A refurbished T-45d Power Armor helmet.",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["rootPath"] = "models/cgcclothing/",
		["pathType"] = "t45",
		["modelType"] = "helmet",
		["maleSuffix"] = "",
		["femaleSuffix"] = "",
		["skin"] = 12,
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["noHead"] = true,
		["rarity"] = 3,
		["damage"] = 75,
	},
	["t45powerarmor_helmet_urban"] = { -- 5.0 Community Update
		["name"] = "T-45d Urban Power Armor Helmet",
		["desc"] = "A refurbished T-45d Power Armor helmet",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["rootPath"] = "models/cgcclothing/",
		["pathType"] = "t45",
		["modelType"] = "helmet",
		["maleSuffix"] = "",
		["femaleSuffix"] = "",
		["skin"] = 13,
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["noHead"] = true,
		["rarity"] = 3,
		["damage"] = 75,
	},
	["t45powerarmor_helmet_fury"] = { -- 5.0 Community Update
		["name"] = "T-45d Pink Fury Power Armor Helmet",
		["desc"] = "An incredibly cute refurbished T-45d Power Armor helmet",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["rootPath"] = "models/cgcclothing/",
		["pathType"] = "t45",
		["modelType"] = "helmet",
		["maleSuffix"] = "",
		["femaleSuffix"] = "",
		["skin"] = 14,
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["noHead"] = true,
		["rarity"] = 3,
		["damage"] = 75,
	},
	["t45powerarmor_helmet_house"] = { -- 5.0 Community Update
		["name"] = "T-45d High-Roller Power Armor Helmet",
		["desc"] = "A refurbished T-45d Power Armor helmet by and for House Industries | HOUSE - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["rootPath"] = "models/cgcclothing/",
		["pathType"] = "t45",
		["modelType"] = "helmet",
		["maleSuffix"] = "",
		["femaleSuffix"] = "",
		["skin"] = 15,
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["noHead"] = true,
		["rarity"] = 3,
		["damage"] = 75,
	},
	["t45powerarmor_helmet_talon"] = { -- 5.0 Community Update
		["name"] = "T-45d Talon Power Armor Helmet",
		["desc"] = "A refurbished T-45d Power Armor helmet by and for Talon Company | TALON - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["rootPath"] = "models/cgcclothing/",
		["pathType"] = "t45",
		["modelType"] = "helmet",
		["maleSuffix"] = "",
		["femaleSuffix"] = "",
		["skin"] = 16,
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["noHead"] = true,
		["rarity"] = 3,
		["damage"] = 75,
	},
	["t45powerarmor_helmet_fiends"] = { -- 5.0 Community Update
		["name"] = "T-45d Fiend Warlord Power Armor Helmet",
		["desc"] = "A refurbished T-45d Power Armor helmet by and for The Fiends | FIENDS - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["rootPath"] = "models/cgcclothing/humans/",
		["pathType"] = "fiendt45helmet",
		["modelType"] = "male",
		["maleSuffix"] = "",
		["femaleSuffix"] = "fe",
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 3,
		["damage"] = 75,
	},
	["t45ncrsalvaged_helmet"] = {
		["name"] = "Salvaged NCR Power Armor Helmet",
		["desc"] = "A refurbished T-45d Power Armor helmet salvaged by the NCR from dead Brotherhood of Steel Knights | NCR - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["modelType"] = "powerarmor01",
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["bodygroup"] = 1,
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "E", -2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "E")
		end,
		["pathType"] = "headgear",
		["head"] = true,
		["rarity"] = 3,
		["damage"] = 73,
		["speed"] = 0
	},
	["t45boshelmet"] = { -- 5.0 community update
		["name"] = "T-45d BOS Power Armor Helmet",
		["desc"] = "A Power Armor Helmet worn by the BOS | BOS - FACTION ARMOR",
        ["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
        ["rootPath"] = "models/",
        ["pathType"] = "fallout_3",
        ["maleScale"] = 1,
        ["femaleScale"] = 1,
        ["noHead"] = true,
        ["malePrefix"] = "",
        ["femalePrefix"] = "",
        ["cannotWear"] = {
            ["glasses"] = false,
            ["mask"] = false,
            ["extra"] = false,
        },
        ["hair"] = false,
        ["facialHair"] = false,
        ["modelType"] = "power_armor_admin_helmet",
        ["powerarmor"] = true,
        ["head"] = true,
        ["rarity"] = 3,
        ["type"] = "hat",
        ["damage"] = 75
	},
	["t45boshelmet_sgt"] = { -- Item is duplicate of above due to previously being different
		["name"] = "T-45d BOS NCO Power Armor Helmet",
		["desc"] = "A Power Armor Helmet worn by the BOS | BOS - FACTION ARMOR",
        ["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
        ["rootPath"] = "models/",
        ["pathType"] = "fallout_3",
        ["maleScale"] = 1,
        ["femaleScale"] = 1,
        ["malePrefix"] = "",
        ["femalePrefix"] = "",
        ["cannotWear"] = {
            ["glasses"] = false,
            ["mask"] = false,
            ["extra"] = false,
        },
        ["hair"] = false,
        ["facialHair"] = false,
        ["modelType"] = "power_armor_admin_helmet",
        ["powerarmor"] = true,
        ["head"] = true,
        ["rarity"] = 4,
        ["type"] = "hat",
        ["damage"] = 80
	},
	/**
	["t60_bos_helmet"] = { -- NOTE: Ported from legacy armor system (t60_bosss)
		["name"] = "T-60 BOS Power Armor Helmet",
		["desc"] = "A T-60 Power Armor Helmet worn by the BOS | BOS - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group524",
		["modelType"] = "helmet",
		["maleScale"] = 1,
		["femaleScale"] = 1,
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["hair"] = false,
		["facialHair"] = false,
		["powerarmor"] = true,
		["head"] = true,
		["noHead"] = true,
		["rarity"] = 4,
		["type"] = "hat",
		["damage"] = 83
	},
		**/
	["t45dtalonpowerarmor_helmet"] = {
		["name"] = "T-45d Talon Power Armor Helmet",
		["desc"] = "A T-45d Power Armor Helmet refurbished by Talon Company | TALON - FACTION ARMOR",
		["itemModel"] = "models/fallout/t45pahelmet.mdl",
		["rootPath"] = "models/cgcclothing/humans/",
		["pathType"] = "talonpowerarmor",
		["malePrefix"] = "",
				["femalePrefix"] = "",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["hair"] = false,
		["facialHair"] = false,
		["modelType"] = "helmet",
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 3,
		["type"] = "hat",
		["damage"] = 75
	},
	["t45powerarmormkii"] = {
		["name"] = "T-45d MKII Power Armor Helmet",
		["desc"] = "A T-45d Power Armor Helmet",
		["itemModel"] = "models/fallout/t45pahelmet.mdl",
		["rootPath"] = "models/illusion/",
		["pathType"] = "fallout",
		["maleScale"] = 1.1,
		["femaleScale"] = 1.1,
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["hair"] = false,
		["facialHair"] = false,
		["modelType"] = "t45pahelmetdrags",
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 3,
		["type"] = "hat",
		["damage"] = 75
	},
	["meftretrolancerhelmet"] = {
		["name"] = "MEF Zealot Power Armor Helmet",
		["desc"] = "A MEF Zealot Power Armor helmet | MEF - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/amwpahelmet.mdl",
		["rootPath"] = "models/cgcclothing/humans/",
		["pathType"] = "rangerpowerarmor",
		["maleScale"] = 1,
		["femaleScale"] = 1,
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["hair"] = false,
		["facialHair"] = false,
		["modelType"] = "helmet",
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 3,
		["type"] = "hat",
		["damage"] = 75
	},
	["wb-helmet-w"] = {
        ["name"] = "WB Scourge Power Armor Helmet (White)",
        ["desc"] = "An advanced power armor helmet used with the Scourge Power Armor | WB - FACTION ARMOR",
        ["itemModel"] = "models/fallout/apparel/amwpahelmet.mdl",
        ["rootPath"] = "models/player/",
        ["pathType"] = "wbos",
        ["maleScale"] = 1,
        ["femaleScale"] = 1,
        ["noHead"] = true,
        ["malePrefix"] = "",
        ["femalePrefix"] = "",
        ["cannotWear"] = {
            ["glasses"] = false,
            ["mask"] = false,
            ["extra"] = false,
        },
        ["hair"] = false,
        ["facialHair"] = false,
        ["modelType"] = "power-armor-helmet",
        ["powerarmor"] = true,
        ["head"] = true,
        ["rarity"] = 4,
        ["type"] = "hat",
        ["damage"] = 80
    },
    ["wb-helmet-p"] = {
        ["name"] = "WB Scourge Power Armor Helmet (Purple)",
        ["desc"] = "An advanced power armor helmet used with the Scourge Power Armor | WB - FACTION ARMOR",
        ["itemModel"] = "models/fallout/apparel/amwpahelmet.mdl",
        ["rootPath"] = "models/player/",
        ["pathType"] = "wbos",
        ["maleScale"] = 1,
        ["femaleScale"] = 1,
        ["noHead"] = true,
        ["skin"] = 1,
        ["malePrefix"] = "",
        ["femalePrefix"] = "",
        ["cannotWear"] = {
            ["glasses"] = false,
            ["mask"] = false,
            ["extra"] = false,
        },
        ["hair"] = false,
        ["facialHair"] = false,
        ["modelType"] = "power-armor-helmet",
        ["powerarmor"] = true,
        ["head"] = true,
        ["rarity"] = 4,
        ["type"] = "hat",
        ["damage"] = 80
    },
    ["wb-helmet-p-o"] = {
        ["name"] = "WB Scourge Officer Power Armor Helmet (Purple)",
        ["desc"] = "An advanced power armor helmet used with the Scourge Power Armor | WB - FACTION OFFICER ARMOR",
        ["itemModel"] = "models/fallout/apparel/amwpahelmet.mdl",
        ["rootPath"] = "models/player/",
        ["pathType"] = "wbos",
        ["maleScale"] = 1,
        ["femaleScale"] = 1,
        ["noHead"] = true,
        ["skin"] = 1,
        ["malePrefix"] = "",
        ["femalePrefix"] = "",
        ["cannotWear"] = {
            ["glasses"] = false,
            ["mask"] = false,
            ["extra"] = false,
        },
        ["hair"] = false,
        ["facialHair"] = false,
        ["modelType"] = "power-armor-helmet",
        ["powerarmor"] = true,
        ["head"] = true,
        ["rarity"] = 4,
        ["type"] = "hat",
        ["damage"] = 85
    },
    ["wb-helmet-w-o"] = {
        ["name"] = "WB Scourge Officer Power Armor Helmet (White)",
        ["desc"] = "An advanced power armor helmet used with the Scourge Power Armor | WB - FACTION OFFICER ARMOR",
        ["itemModel"] = "models/fallout/apparel/amwpahelmet.mdl",
        ["rootPath"] = "models/player/",
        ["pathType"] = "wbos",
        ["maleScale"] = 1,
        ["femaleScale"] = 1,
        ["noHead"] = true,
        ["malePrefix"] = "",
        ["femalePrefix"] = "",
        ["cannotWear"] = {
            ["glasses"] = false,
            ["mask"] = false,
            ["extra"] = false,
        },
        ["hair"] = false,
        ["facialHair"] = false,
        ["modelType"] = "power-armor-helmet",
        ["powerarmor"] = true,
        ["head"] = true,
        ["rarity"] = 4,
        ["type"] = "hat",
        ["damage"] = 85
    },
	["x02pahelmet"] = {
		["name"] = "X-02 Enclave Power Armor Helmet",
		["desc"] = "A X-02 Power Armor Helmet | ENCLAVE - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/enclave_power_armor_helmet.mdl",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group209",
		["modelType"] = "helmet",
--		["maleScale"] = 1.0,
--		["femaleScale"] = 1.0,
		["malePrefix"] = "",
		["femaleSuffix"] = "_female",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["noHead"] = true,
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 4,
		["type"] = "hat",
		["damage"] = 75
	},
	["x02pahelmet_nco"] = {
		["name"] = "X-02 Enclave NCO Power Armor Helmet",
		["desc"] = "A X-02 Power Armor Helmet | ENCLAVE - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/enclave_power_armor_helmet.mdl",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group209",
		["modelType"] = "helmet",
--		["maleScale"] = 1.0,
--		["femaleScale"] = 1.0,
		["malePrefix"] = "",
		["femaleSuffix"] = "_female",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["noHead"] = true,
		["powerarmor"] = true,
		["head"] = true,
		["skin"] = 1,
		["rarity"] = 4,
		["type"] = "hat",
		["damage"] = 80
	},
	["x02teslapahelmet"] = {
		["name"] = "X-02 Enclave Tesla Power Armor Helmet",
		["desc"] = "A X-02 Power Armor Helmet | ENCLAVE - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/enclave_power_armor_helmet.mdl",
		["rootPath"] = "models/",
		["pathType"] = "fallout_3",
		["modelType"] = "tesla_power_armor_helmet",
		["maleScale"] = 1.05,
		["femaleScale"] = 1.05,
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["noHead"] = true,
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 5,
		["type"] = "hat",
		["damage"] = 90
	},
	["x03hellfirepahelmet"] = {
		["name"] = "X-03 Enclave Hellfire Power Armor Helmet",
		["desc"] = "A X-03 Power Armor Helmet | ENCLAVE - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/hellfirehelm.mdl",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group211",
		["modelType"] = "helmet",
		["maleScale"] = 0.9,
		["femaleScale"] = 0.9,
		["malePrefix"] = "",
		["femaleSuffix"] = "_female",
		["noHead"] = true,
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["hair"] = false,
		["facialHair"] = false,
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 4,
		["type"] = "hat",
		["damage"] = 83,
	},
		["t45gunnerpowerarmorhelmet"] = {
		["name"] = "T-45d MKII Gunner Power Armor Helmet",
		["desc"] = "A T-45d Power Armor Helmet painted by the Gunners Mercenary Group | GUNNER - FACTION ARMOR",
		["itemModel"] = "models/fallout/t45pahelmet.mdl",
		["itemModelSkin"] = 3,
		["rootPath"] = "models/illusion/",
		["pathType"] = "fallout",
		["maleScale"] = 1.1,
		["femaleScale"] = 1.1,
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["hair"] = false,
		["facialHair"] = false,
		["modelType"] = "t45pahelmusarmy",
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 3,
		["type"] = "hat",
		["damage"] = 75
	},
	["t45outcastmakiihelmet"] = {
		["name"] = "T-45d MKII Outcast Power Armor Helmet",
		["desc"] = "A T-45d Power Armor Helmet painted by the Outcasts",
		["itemModel"] = "models/fallout/t45pahelmet.mdl",
		["itemModelSkin"] = 2,
		["rootPath"] = "models/illusion/",
		["pathType"] = "fallout",
		["maleScale"] = 1.1,
		["femaleScale"] = 1.1,
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["hair"] = false,
		["facialHair"] = false,
		["modelType"] = "t45pahelmoutcast.mdl",
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 3,
		["type"] = "hat",
		["damage"] = 75
	},
	["t45outcast-forged"] = {
		["name"] = "T-45d Forged Power Armor Helmet",
		["desc"] = "A T-45d Power Armor Helmet painted by the Forged",
		["itemModel"] = "models/fallout/t45pahelmet.mdl",
		["itemModelSkin"] = 2,
		["rootPath"] = "models/illusion/",
		["pathType"] = "fallout",
		["maleScale"] = 1.1,
		["femaleScale"] = 1.1,
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["hair"] = false,
		["facialHair"] = false,
		["modelType"] = "t45pahelmoutcast",
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 3,
		["type"] = "hat",
		["damage"] = 75
	},
	["armor_t45-scorched-helmet"] = { -- 5.0 Community Update
		["name"] = "T-45d Scorched Sierra Power Armor Helmet",
		["desc"] = "A set of T-45d Power Armor refurbished and upgraded by the New California Republic intended for use by high ranking officers of the republic | NCR - FACTION ARMOR",
		["type"] = "hat",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group521",
		["modelType"] = "helmet",
		["itemModel"] = "models/fallout/t45pahelmet.mdl",
		["armsModel"] = false,
		["noHead"] = true,
		["head"] = true,
		["rarity"] = 5,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 90,
		["noFall"] = true,
		["speed"] = 0
	},
	["t45bospowerarmormkii_helmet"] = { -- Item is duplicate of below due to previously being different
		["name"] = "T-51b BOS Power Armor Helmet",
		["desc"] = "A T-51b Power Armor Helmet painted by the Brotherhood of Steel | BOS - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/t51bpowerhelmet.mdl",
        ["rootPath"] = "models/lazarusroleplay/",
        ["pathType"] = "headgear",
		["bodygroup"] = 2,
        ["malePrefix"] = "",
        ["femalePrefix"] = "",
		["noHead"] = true,
        ["cannotWear"] = {
            ["glasses"] = false,
            ["mask"] = false,
            ["extra"] = false,
        },
        ["hair"] = false,
        ["facialHair"] = false,
        ["modelType"] = "m_powerarmor01",
        ["powerarmor"] = true,
        ["head"] = true,
        ["rarity"] = 4,
        ["type"] = "hat",
        ["damage"] = 80
	},
	["t45bospowerarmormkii_lord"] = { -- Item is duplicate of above due to previously being different
		["name"] = "T-51b BOS Lost Hills Power Armor Helmet",
		["desc"] = "A T-51b Power Armor Helmet painted by the Brotherhood of Steel | BOS - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/t51bpowerhelmet.mdl",
        ["rootPath"] = "models/lazarusroleplay/",
        ["pathType"] = "headgear",
		["bodygroup"] = 2,
		["skin"] = 1,
		["noHead"] = true,
        ["malePrefix"] = "",
        ["femalePrefix"] = "",
        ["cannotWear"] = {
            ["glasses"] = false,
            ["mask"] = false,
            ["extra"] = false,
        },
        ["hair"] = false,
        ["facialHair"] = false,
        ["modelType"] = "m_powerarmor01",
        ["powerarmor"] = true,
        ["head"] = true,
        ["rarity"] = 4,
        ["type"] = "hat",
        ["damage"] = 83
	},
	["t45bospowerarmormkii"] = {
		["name"] = "T-45d NCR Power Armor Helmet",
		["desc"] = "A T-45d Power Armor Helmet painted by the NCR | NCR - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["rootPath"] = "models/cgcclothing/",
		["pathType"] = "t45",
		["modelType"] = "helmet",
		["maleSuffix"] = "",
		["femaleSuffix"] = "",
		["skin"] = 17,
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["noHead"] = true,
		["rarity"] = 3,
		["damage"] = 75,
	},
	["t51npowerarmorhelmetii"] = {
		["name"] = "T-51b MKII Pre-War Power Armor Helmet",
		["desc"] = "A T-51b Power Armor Helmet",
		["itemModel"] = "models/fallout/t51pahelmet.mdl",
		["rootPath"] = "models/illusion/",
		["pathType"] = "fallout",
		["modelType"] = "t51pahelmclassic",
		["maleScale"] = 1.1,
		["femaleScale"] = 1.1,
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["hair"] = false,
		["facialHair"] = false,
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 4,
		["type"] = "hat",
		["damage"] = 80
	},
	["t51banchoragepowerarmorhelmet"] = {
		["name"] = "T-51b MKII Anchroage Power Armor Helmet",
		["desc"] = "A T-51b Power Armor Helmet",
		["itemModel"] = "models/fallout/t51pahelmet.mdl",
		["itemModelSkin"] = 3,
		["rootPath"] = "models/illusion/",
		["pathType"] = "fallout",
		["maleScale"] = 1.1,
		["femaleScale"] = 1.1,
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["hair"] = false,
		["facialHa ir"] = false,
		["modelType"] = "t51pahelmwinter",
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 4,
		["type"] = "hat",
		["damage"] = 80
	},
	["t51bminutemenpowerarmorhelmet"] = {
		["name"] = "T-51b MKII Minutemen Power Armor Helmet",
		["desc"] = "A T-51b Power Armor Helmet",
		["itemModel"] = "models/fallout/t51pahelmet.mdl",
		["itemModelSkin"] = 3,
		["rootPath"] = "models/illusion/",
		["pathType"] = "fallout",
		["maleScale"] = 1.1,
		["femaleScale"] = 1.1,
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["hair"] = false,
		["facialHa ir"] = false,
		["modelType"] = "t51pahelmminute",
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 4,
		["type"] = "hat",
		["damage"] = 80
	},
	["t51bdarkehlmmkii"] = {
		["name"] = "T-51b MKII BOS Power Armor Helmet",
		["desc"] = "A T-51b Power Armor Helmet",
		["itemModel"] = "models/fallout/t51pahelmet.mdl",
		["itemModelSkin"] = 1,
		["rootPath"] = "models/illusion/",
		["pathType"] = "fallout",
		["maleScale"] = 1.1,
		["femaleScale"] = 1.1,
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["hair"] = false,
		["facialHair"] = false,
		["modelType"] = "t51padraghelmnorm",
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 4,
		["type"] = "hat",
		["damage"] = 80
	},
	["t51boutcastehlmmkii"] = {
		["name"] = "T-51b MKII Outcast Power Armor Helmet",
		["desc"] = "A T-51b Power Armor Helmet",
		["itemModel"] = "models/illusion/fallout/t45pahelmusarmy.mdl",
		["itemModelSkin"] = 2,
		["rootPath"] = "models/illusion/",
		["pathType"] = "fallout",
		["maleScale"] = 1.1,
		["femaleScale"] = 1.1,
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["hair"] = false,
		["facialHair"] = false,
		["modelType"] = "t51outcastdraehelm",
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 4,
		["type"] = "hat",
		["damage"] = 80
	},
	["t51bpowerarmorhletmex"] = {
		["name"] = "T-51b Power Armor Helmet",
		["desc"] = "A T-51b Power Armor helmet.",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["modelType"] = "powerarmor01",
		["itemModel"] = "models/fallout/apparel/t51bpowerhelmet.mdl",
		["bodygroup"] = 2,
		["pathType"] = "headgear",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 4,
		["damage"] = 80,
	},
	["t51bpowerarmorhletmeblack"] = {
		["name"] = "T-51b Black Power Armor Helmet",
		["desc"] = "A T-51b Power Armor helmet.",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["modelType"] = "powerarmor01",
		["itemModel"] = "models/fallout/apparel/t51bpowerhelmet.mdl",
		["bodygroup"] = 2,
		["skin"] = 2,
		["pathType"] = "headgear",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 4,
		["damage"] = 80,
	},
	["advancedpowerarmorhelmet"] = {
		["name"] = "X-01 Richardson Elite Power Armor Helmet",
		["desc"] = "A highly advanced power armor helmet specifically worn by The Enclave | ENCLAVE - FACTION ARMOR",
		["type"] = "hat",
		["noHead"] = true,
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group600",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "helmet",
		["skin"] = 1,
		["itemModel"] = "models/fallout/apparel/adpowerarmorhelmet.mdl",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 4,
		["damage"] = 85,
	},
	["advancedpowerarmorhelmet-nco"] = {
		["name"] = "X-01 Advanced Power Armor Helmet",
		["desc"] = "A highly advanced power armor helmet specifically worn by The Enclave | ENCLAVE - FACTION ARMOR",
		["type"] = "hat",
		["noHead"] = true,
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group600",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "helmet",
		["skin"] = 2,
		["itemModel"] = "models/fallout/apparel/adpowerarmorhelmet.mdl",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 4,
		["damage"] = 85,
	},

	["advancedpowerarmorhelmet_tesla_enclave"] = {
		["name"] = "X-01 Tesla Elite Power Armor Helmet",
		["desc"] = "A highly advanced power armor helmet worn by the elite of the Enclave | ENCLAVE - FACTION ARMOR",
		["type"] = "hat",
		["noHead"] = true,
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group518",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "helmet",
		["itemModel"] = "models/fallout/apparel/adpowerarmorhelmet.mdl",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 5,
		["damage"] = 90,
	},
	["advancedpowerarmorhelmet_tesla_wasteland"] = {
		["name"] = "X-01 Advanced Tesla Power Armor Helmet",
		["desc"] = "A highly advanced power armor helmet worn previously by the elite of the Enclave",
		["type"] = "hat",
		["noHead"] = true,
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group518",
		["skin"] = 1,
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "helmet",
		["itemModel"] = "models/fallout/apparel/adpowerarmorhelmet.mdl",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 5,
		["damage"] = 90,
	},
	["advancedpowerarmorhelmet_uss"] = {
		["name"] = "X-01 U.S.S. Agent Power Armor Helmet",
		["desc"] = "A highly advanced power armor helmet specifically worn by The Enclave | ENCLAVE - FACTION ARMOR",
		["type"] = "hat",
		["noHead"] = true,
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group312",
		["modelType"] = "helmet",
		["malePrefix"] = "male_",
		["femalePrefix"] = "female_",
		["itemModel"] = "models/fallout/apparel/adpowerarmorhelmet.mdl",
		["skin"] = 2,
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 4,
		["damage"] = 90,
	},
	["advancedpowerarmorhelmet_uss_lead"] = {
		["name"] = "X-01 U.S.S. Lead Agent Power Armor Helmet",
		["desc"] = "A highly advanced power armor helmet specifically worn by The Enclave | ENCLAVE - FACTION ARMOR",
		["type"] = "hat",
		["noHead"] = true,
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group312",
		["modelType"] = "helmet",
		["malePrefix"] = "male_",
		["femalePrefix"] = "female_",
		["itemModel"] = "models/fallout/apparel/adpowerarmorhelmet.mdl",
		["bodygroup"] = {0,1},
		["skin"] = 2,
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 4,
		["damage"] = 90,
	},
	["militia_ranger_helmet"] = { -- Custom order by Meeps#0690
		["name"] = "Hopeville Patriot Helmet",
		["desc"] = "A Riot Ranger helmet repurposed by the Militia | MILITIA - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true
		},
		["itemModel"] = "models/fallout/apparel/combatrangerhelmet.mdl",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group527",
		["modelType"] = "helmet_m",
		["noHead"] = true,
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["rarity"] = 4,
		["head"] = true,
		["damage"] = 70
	},
	["dr_gunslinger_helmet"] = { -- Custom order by nootles#9609
		["name"] = "Desert Ranger Gunslinger Helmet",
		["desc"] = "A make-shift Desert Ranger helmet modified to be more mobile | DR - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true
		},
		["itemModel"] = "models/fallout/apparel/combatrangerhelmet.mdl",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group525",
		["modelType"] = "helmet",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["rarity"] = 4,
		["head"] = true,
		["damage"] = 70
	},
	["skybreaker_soldier_helmet"] = { -- Custom order by noctusterrorem#4953
		["name"] = "Skybreaker Nimbus Agent Helmet",
		["desc"] = "A set of futuristic armor designed for high altitude warfare worn by the Skybreakers | SKYBREAKER - FACTION ARMOR",
		["type"] = "hat",
		["noHead"] = true,
		["facialHair"] = false,
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true
		},
		["itemModel"] = "models/fallout/apparel/gscbanditmask.mdl",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group533",
		["modelType"] = "helmet",
		["maleSuffix"] = "_m",
		["femaleSuffix"] = "_f",
		["rarity"] = 2,
		["head"] = true,
		["damage"] = 55
	},
	["skybreaker_nco_helmet"] = { -- Custom order by noctusterrorem#4953
		["name"] = "Skybreaker Altitude Agent Helmet",
		["desc"] = "A set of futuristic armor designed for high altitude warfare worn by the Skybreakers | SKYBREAKER - FACTION ARMOR",
		["type"] = "hat",
		["noHead"] = true,
		["facialHair"] = false,
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true
		},
		["itemModel"] = "models/fallout/apparel/gscbanditmask.mdl",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group530",
		["modelType"] = "helmet",
		["maleSuffix"] = "_m",
		["femaleSuffix"] = "_f",
		["rarity"] = 3,
		["head"] = true,
		["damage"] = 65
	},
	["skybreaker_officer_helmet"] = { -- Custom order by noctusterrorem#4953
		["name"] = "Skybreaker Stratoranger Helmet",
		["desc"] = "A set of futuristic armor designed for high altitude warfare worn by the Skybreakers | SKYBREAKER - FACTION ARMOR",
		["type"] = "hat",
		["facialHair"] = false,
		["hair"] = false,
		["cannotWear"] = {
			["mask"] = true,
			["glasses"] = true
		},
		["itemModel"] = "models/fallout/apparel/stealthsuithelm.mdl",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group529",
		["modelType"] = "helmet",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["rarity"] = 4,
		["head"] = true,
		["damage"] = 70
	},
	["skybreaker_hellbreaker_pa_helmet"] = { -- Custom order by noctusterrorem#4953
		["name"] = "Skybreaker Meteor T-45s Power Armor Helmet",
		["desc"] = "A set of futuristic power armor worn by the Skybreakers | SKYBREAKER - FACTION ARMOR",
		["type"] = "hat",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group532",
		["modelType"] = "helmet",
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["armsModel"] = false,
		["noHead"] = true,
		["head"] = true,
		["rarity"] = 3,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = 0
	},
	["skybreaker_cosmic_pa_helmet"] = { -- Custom order by noctusterrorem#4953
		["name"] = "Skybreaker Cold Fusion CF1 Power Armor Helmet",
		["desc"] = "A set of futuristic tesla power armor worn by the Skybreakers | SKYBREAKER - FACTION ARMOR",
		["type"] = "hat",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group531",
		["modelType"] = "helmet",
		["itemModel"] = "models/fallout/apparel/amwpahelmet.mdl",
		["armsModel"] = false,
		["noHead"] = true,
		["head"] = true,
		["rarity"] = 4,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 80,
		["noFall"] = true,
		["speed"] = 0
	},
/**
	["x01_usss_autumn"] = {
		["name"] = "X-01 U.S.S. Agent Power Armor Helmet (Autumn)",
		["desc"] = "A set of especially constructed X-01 Power Armor used by the Enclave's Secret Service during their initial insurgence in New California. This power armor on top of superior resistance offers a cloaking technology for covert operations | ENCLAVE - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/adpowerarmorhelmet.mdl",
		["rootPath"] = "models/cgcclothing/",
		["pathType"] = "fallout",
		["modelType"] = "valentina_apa_helmet",
		["maleScale"] = 1.1,
		["femaleScale"] = 1,
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["hair"] = false,
		["facialHair"] = false,
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 4,
		["type"] = "hat",
		["damage"] = 90
	},
	["x01_usss_blue"] = {
		["name"] = "X-01 U.S.S. Agent Power Armor Helmet (Blue)",
		["desc"] = "A set of especially constructed X-01 Power Armor used by the Enclave's Secret Service during their initial insurgence in New California. This power armor on top of superior resistance offers a cloaking technology for covert operations | ENCLAVE - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/adpowerarmorhelmet.mdl",
		["rootPath"] = "models/cgcclothing/",
		["pathType"] = "fallout",
		["modelType"] = "valentina_apa_helmet",
		["skin"] = 1,
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["hair"] = false,
		["facialHair"] = false,
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 4,
		["type"] = "hat",
		["damage"] = 90
	},
	["x01_usss_red"] = {
		["name"] = "X-01 U.S.S. Agent Power Armor Helmet (Red)",
		["desc"] = "A set of especially constructed X-01 Power Armor used by the Enclave's Secret Service during their initial insurgence in New California. This power armor on top of superior resistance offers a cloaking technology for covert operations | ENCLAVE - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/adpowerarmorhelmet.mdl",
		["rootPath"] = "models/cgcclothing/",
		["pathType"] = "fallout",
		["modelType"] = "valentina_apa_helmet",
		["skin"] = 2,
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["hair"] = false,
		["facialHair"] = false,
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 4,
		["type"] = "hat",
		["damage"] = 90
	},
	["x01_usss_green"] = {
		["name"] = "X-01 U.S.S. Agent Power Armor Helmet (Green)",
		["desc"] = "A set of especially constructed X-01 Power Armor used by the Enclave's Secret Service during their initial insurgence in New California. This power armor on top of superior resistance offers a cloaking technology for covert operations | ENCLAVE - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/adpowerarmorhelmet.mdl",
		["rootPath"] = "models/cgcclothing/",
		["pathType"] = "fallout",
		["modelType"] = "valentina_apa_helmet",
		["skin"] = 3,
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["hair"] = false,
		["facialHair"] = false,
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 4,
		["type"] = "hat",
		["damage"] = 90
	},
	["x01_usss_white"] = {
		["name"] = "X-01 U.S.S. Agent Power Armor Helmet (White)",
		["desc"] = "A set of especially constructed X-01 Power Armor used by the Enclave's Secret Service during their initial insurgence in New California. This power armor on top of superior resistance offers a cloaking technology for covert operations | ENCLAVE - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/adpowerarmorhelmet.mdl",
		["rootPath"] = "models/cgcclothing/",
		["pathType"] = "fallout",
		["modelType"] = "valentina_apa_helmet",
		["skin"] = 4,
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["hair"] = false,
		["facialHair"] = false,
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 4,
		["type"] = "hat",
		["damage"] = 90
	},
**/
	["advancedpowerarmorhelmet_unique"] = {
		["name"] = "X-01 Advanced Power Armor Helmet",
		["desc"] = "A highly advanced power armor helmet worn by the Enclave in New California prior to their destruction",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group600",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["modelType"] = "helmet",
		--["skin"] = 1,
		["itemModel"] = "models/fallout/apparel/adpowerarmorhelmet.mdl",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["powerarmor"] = true,
		["head"] = true,
		["rarity"] = 5,
		["damage"] = 90,
	},
	-- GLASSES --
	["sunglasses"] = {
		["name"] = "Sunglasses",
		["desc"] = "Sunglasses often worn to protect from the sun.",
		["type"] = "glasses",
		["itemModel"] = "models/headspack/kleiner_glasses.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "combat_",
		["femalePrefix"] = "combat_",
		["modelType"] = "sunglasses",
		["rarity"] = 2,
		["maleScale"] = 0.93,
		["femaleScale"] = 0.87,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "P", 1)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "P")
		end,
		["head"] = true,
	},
	["tintedsunglasses"] = {
		["name"] = "Tinted Sunglasses",
		["desc"] = "Sunglasses often worn to protect from the sun.",
		["type"] = "glasses",
		["itemModel"] = "models/headspack/kleiner_glasses.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "combat_",
		["femalePrefix"] = "combat_",
		["modelType"] = "sunglasses",
		["maleScale"] = 0.93,
		["femaleScale"] = 0.87,
		["rarity"] = 2,
		["skin"] = 1,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "P", 1)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "P")
		end,
		["head"] = true,
	},
	["aviatorglasses"] = {
		["name"] = "Aviators",
		["desc"] = "Unique pre-war sunglasses only worn by the coolest of cats | +1 PER",
		["type"] = "glasses",
		["hair"] = true,
		["facialHair"] = true,
		["modelType"] = "glasses01",
		["itemModel"] = "models/headspack/kleiner_glasses.mdl",
		["bodygroup"] = 1,
		["pathType"] = "headgear",
		["rarity"] = 3,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "P", 1)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "P")
		end,
	},
	["blindglasses"] = {
		["name"] = "Blind Man's Glasses",
		["desc"] = "Glasses often worn by the Blind | -1 PER / +2 CHR",
		["type"] = "glasses",
		["modelType"] = "glasses01",
		["itemModel"] = "models/headspack/kleiner_glasses.mdl",
		["bodygroup"] = 2,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "P", -1)
			BuffStat(ply, item, "C", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "P")
			EndBuff(ply, item, "C")
		end,
		["head"] = true,
		["pathType"] = "headgear"
	},
	["heartglasses"] = {
		["name"] = "Heart Glasses",
		["desc"] = "Glasses in the shape of a heart | +2 LCK",
		["type"] = "glasses",
		["modelType"] = "glasses01",
		["itemModel"] = "models/headspack/kleiner_glasses.mdl",
		["bodygroup"] = 3,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "L", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "L")
		end,
		["head"] = true,
		["pathType"] = "headgear"
	},
	["auburntglasses"] = {
		["name"] = "Auburnt Glasses",
		["desc"] = "Glasses often worn by upset Librarians | +1 PER",
		["type"] = "glasses",
		["hair"] = true,
		["facialHair"] = true,
		["modelType"] = "glasses01",
		["itemModel"] = "models/headspack/kleiner_glasses.mdl",
		["bodygroup"] = 4,
		["pathType"] = "headgear",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "P", 1)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "P")
		end,
		["head"] = true,
	},
	["menreadingglasses"] = {
		["name"] = "Glasses",
		["desc"] = "Normal reading glasses often worn by Scholars",
		["type"] = "glasses",
		["hair"] = true,
		["facialHair"] = true,
		["modelType"] = "glasses01",
		["itemModel"] = "models/headspack/kleiner_glasses.mdl",
		["bodygroup"] = 5,
		["pathType"] = "headgear",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "I", 1)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "I")
		end,
		["head"] = true,
	},
	["womenreadingglasses"] = {
		["name"] = "Women's Glasses",
		["desc"] = "Normal reading glasses often worn by Scholars",
		["type"] = "glasses",
		["hair"] = true,
		["facialHair"] = true,
		["modelType"] = "glasses01",
		["itemModel"] = "models/headspack/kleiner_glasses.mdl",
		["bodygroup"] = 6,
		["pathType"] = "headgear",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "I", 1)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "I")
		end,
		["head"] = true,
	},
	["chinesestealthsuithelmet"] = {
		["name"] = "Stealth Suit Helmet",
		["desc"] = "A Stealth Suit Helmet",
		["itemModel"] = "models/fallout/apparel/chinesestealthhelm.mdl",
		["rootPath"] = "models/cgcclothing/humans/",
		["pathType"] = "chinastealth",
		["modelType"] = "helmet",
		["maleScale"] = 1.05,
		["femaleScale"] = 1,
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["hair"] = false,
		["facialHair"] = false,
		["head"] = true,
		["rarity"] = 4,
		["type"] = "hat",
		["damage"] = 55
	},
	["plaguedoctorheadwear"] = {
		["name"] = "Plague Doctor Headwear",
		["desc"] = "A headwear worn by crow lovers and medical proffesionals | FOLLOWERS - FACTION OFFICER ARMOR",
		["itemModel"] = "models/fallout/apparel/cowboyhat.mdl",
		["rootPath"] = "models/cgcclothing/humans/",
		["pathType"] = "plague",
		["modelType"] = "helmet",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false,
			["extra"] = false,
		},
		["hair"] = false,
		["facialHair"] = false,
		["head"] = true,
		["rarity"] = 4,
		["type"] = "hat",
		["damage"] = 25
	},
	["reconghillieheadwear"] = { -- Custom Order by Elliot
		["name"] = "NCR Recon Ghillie Headwear",
		["desc"] = "A Ghillie Headpiece worn for blending in | NCR - FACTION ARMOR",
		["itemModel"] = "models/fallout/ncrriothelmet.mdl",
		["rootPath"] = "models/cgcclothing/humans/",
		["pathType"] = "reconsniper",
		["modelType"] = "headwear",
		["maleScale"] = 1,
		["femaleScale"] = 1,
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["hair"] = false,
		["facialHair"] = true,
		["head"] = true,
		["rarity"] = 4,
		["type"] = "hat",
		["damage"] = 68
	},
	["paradise_raider_pa_helmet-street"] = { -- Custom Order by 'Dorian Gray#8127'
		["name"] = "Paradise Street Raider Power Armor Helmet",
		["desc"] = "A scrap taped would-be power armor helmet made by the Paradise Falls Slavers | PARADISE - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["rootPath"] = "models/cgcclothing/humans/",
		["pathType"] = "powerarmor_raider",
		["modelType"] = "powerarmor_raider_helmet",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["hair"] = false,
		["facialHair"] = false,
		["head"] = true,
		["noHead"] = true,
		["rarity"] = 3,
		["type"] = "hat",
		["powerarmor"] = true,
		["damage"] = 75
	},
	["paradise_raider_pa_helmet-flame"] = { -- Custom Order by 'Dorian Gray#8127'
		["name"] = "Paradise Flame Raider Power Armor Helmet",
		["desc"] = "A scrap taped would-be power armor helmet made by the Paradise Falls Slavers | PARADISE - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["rootPath"] = "models/cgcclothing/humans/",
		["pathType"] = "powerarmor_raider",
		["modelType"] = "powerarmor_raider_helmet",
		["maleScale"] = 1,
		["femaleScale"] = 1,
		["skin"] = 1,
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["hair"] = false,
		["facialHair"] = false,
		["head"] = true,
		["noHead"] = true,
		["rarity"] = 3,
		["type"] = "hat",
		["powerarmor"] = true,
		["damage"] = 75
	},
	["paradise_raider_pa_helmet-camo"] = { -- Custom Order by 'Dorian Gray#8127'
		["name"] = "Paradise Camo Raider Power Armor Helmet",
		["desc"] = "A scrap taped would-be power armor helmet made by the Paradise Falls Slavers | PARADISE - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["rootPath"] = "models/cgcclothing/humans/",
		["pathType"] = "powerarmor_raider",
		["modelType"] = "powerarmor_raider_helmet",
		["maleScale"] = 1,
		["femaleScale"] = 1,
		["skin"] = 2,
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["hair"] = false,
		["facialHair"] = false,
		["head"] = true,
		["noHead"] = true,
		["rarity"] = 3,
		["type"] = "hat",
		["powerarmor"] = true,
		["damage"] = 75
	},
	["paradise_raider_pa_helmet"] = { -- Custom Order by 'Dorian Gray#8127'
		["name"] = "Paradise Raider Power Armor Helmet",
		["desc"] = "A scrap taped would-be power armor helmet made by the Paradise Falls Slavers | PARADISE - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["rootPath"] = "models/cgcclothing/humans/",
		["pathType"] = "powerarmor_raider",
		["modelType"] = "powerarmor_raider_helmet",
		["maleScale"] = 1,
		["femaleScale"] = 1,
		["skin"] = 3,
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["hair"] = false,
		["facialHair"] = false,
		["head"] = true,
		["noHead"] = true,
		["rarity"] = 3,
		["type"] = "hat",
		["powerarmor"] = true,
		["damage"] = 75
	},
	["paradise_raider_pa_helmet-naval"] = { -- Custom Order by 'Dorian Gray#8127'
		["name"] = "Paradise Naval Raider Power Armor Helmet",
		["desc"] = "A scrap taped would-be power armor helmet made by the Paradise Falls Slavers | PARADISE - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/power_armor_helmet.mdl",
		["rootPath"] = "models/cgcclothing/humans/",
		["pathType"] = "powerarmor_raider",
		["modelType"] = "powerarmor_raider_helmet",
		["maleScale"] = 1,
		["femaleScale"] = 1,
		["skin"] = 4,
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["hair"] = false,
		["facialHair"] = false,
		["head"] = true,
		["noHead"] = true,
		["rarity"] = 3,
		["type"] = "hat",
		["powerarmor"] = true,
		["damage"] = 75
	},
	["mmsol_soldier_helmet"] = { -- Custom Order by 'Shadix Wildfang#9077'
		["name"] = "Minutemen Soldier Helmet",
		["desc"] = "A uniform helmet worn by soldiers of the U.T.C.R. | MM - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["itemModel"] = "models/fallout/apparel/panzerhelm.mdl",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group311",
		["modelType"] = "mmhelm",
		["maleSuffix"] = "",
		["femaleSuffix"] = "f",
		["rarity"] = 3,
		["head"] = true,
		["damage"] = 60
	},
	["xv92respirator"] = { -- NOTE: Duplicate of below due to male/female sex conflict
		["name"] = "XV-92 Respirator Mask",
		["desc"] = "A Mask worn by the Order of the Eternal Abyss | EA - FACTION ARMOR",
		["itemModel"] = "models/visualitygaming/fallout/prop/sol_shemagh2_mask.mdl",
		["rootPath"] = "models/cgcclothing/humans/",
		["pathType"] = "collosus",
		["modelType"] = "helmet",
		["maleScale"] = 1,
		["femaleScale"] = 1,
		["maleSuffix"] = "",
		["femaleSuffix"] = "f",
		["hair"] = true,
		["facialHair"] = true,
		["head"] = true,
		["rarity"] = 4,
		["type"] = "hat",
		["damage"] = 70,
	},
	["xv92respiratorfe"] = { -- NOTE: Duplicate of above due to male/female sex conflict
		["name"] = "XV-92 Respirator Mask",
		["desc"] = "A Mask worn by the Order of the Eternal Abyss | EA - FACTION ARMOR",
		["itemModel"] = "models/visualitygaming/fallout/prop/sol_shemagh2_mask.mdl",
		["rootPath"] = "models/cgcclothing/humans/",
		["pathType"] = "collosus",
		["modelType"] = "helmet",
		["maleScale"] = 1,
		["femaleScale"] = 1,
		["maleSuffix"] = "",
		["femaleSuffix"] = "f",
		["hair"] = true,
		["facialHair"] = true,
		["head"] = true,
		["rarity"] = 4,
		["type"] = "hat",
		["damage"] = 70,
	},
	["goggles"] = {
		["name"] = "Goggles",
		["desc"] = "Normal reading glasses often worn by Scholars",
		["type"] = "glasses",
		["hair"] = true,
		["facialHair"] = true,
		["modelType"] = "glasses01",
		["itemModel"] = "models/visualitygaming/fallout/prop/sol_goggles.mdl",
		["bodygroup"] = 7,
		["pathType"] = "headgear",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 1)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
		end,
		["head"] = true,
	},
	["nvgoggles"] = {
		["name"] = "Military Goggles",
		["desc"] = "Pre-war nightvision goggles.",
		["type"] = "glasses",
		["hair"] = true,
		["facialHair"] = true,
		["modelType"] = "glasses01",
		["itemModel"] = "models/visualitygaming/fallout/prop/sol_goggles.mdl",
		["bodygroup"] = 8,
		["pathType"] = "headgear",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 1)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
		end,
		["head"] = true,
	},
	["hoodtacticalhelmet"] = {
		["name"] = "Tactical Hood Combat Helmet",
		["desc"] = "A modified Combat Armor helmet",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "helmet",
		["itemModel"] = "models/fallout/headgear/combatarmorhelmet.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "sol_",
		["femalePrefix"] = "sol_",
		["rarity"] = 2,
		["head"] = true,
		["damage"] = 55,
	},
	["jackalraiderbosshelmet"] = { -- Custom armor
		["name"] = "Forged Raid Boss Helmet",
		["desc"] = "A custom-made raider combat helmet often made and worn by the Raider bosses of the Forged | FORGED - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["itemModel"] = "models/fallout/apparel/combatarmorhelmet.mdl",
		["rootPath"] = "models/cgcclothing/humans/",
		["pathType"] = "raiderdis",
		["modelType"] = "helmet",
		["maleSuffix"] = "",
		["femaleSuffix"] = "f",
		["maleScale"] = 1.20,
		["femaleScale"] = 1.1,
		["rarity"] = 4,
		["head"] = true,
		["damage"] = 70,
	},
	["tacticalhelmet"] = {
		["name"] = "Tactical Combat Helmet",
		["desc"] = "A modified Combat Armor helmet",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["modelType"] = "helmet",
		["bodygroup"] = 1,
		["itemModel"] = "models/fallout/apparel/combatarmorhelmet.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "sol_",
		["femalePrefix"] = "sol_",
		["rarity"] = 2,
		["head"] = true,
		["damage"] = 55,
	},
	["winterwear"] = {
		["name"] = "Winter Headwear",
		["desc"] = "Winter headwear worn during the cold",
		["type"] = "hat",
		["hair"] = false,
		["modelType"] = "hat1",
		["itemModel"] = "models/visualitygaming/fallout/prop/sol_hat1.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "sol_",
		["femalePrefix"] = "sol_",
		["rarity"] = 1,
		["head"] = true,
		["damage"] = 35,
	},
	-- MASKS --
	["gasmask"] = {
		["name"] = "Respirator Mask",
		["desc"] = "A pre-war breathing mask used for underwater filtration",
		["type"] = "mask",
		["hair"] = true,
		["facialHair"] = false,
		["modelType"] = "masks01",
		["itemModel"] = "models/visualitygaming/fallout/prop/sol_shemagh2_mask.mdl",
		["bodygroup"] = 1,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 0,
	},
	["hockeymask"] = {
		["name"] = "Hockey Mask",
		["desc"] = "A pre-war hock mask commonly worn by Bandits  | +1 STR",
		["type"] = "mask",
		["hair"] = true,
		["facialHair"] = false,
		["cannotWear"] = {
			["glasses"] = true
		},
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 1)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
		end,
		["modelType"] = "masks01",
		["itemModel"] = "models/fallout/apparel/hockeymask.mdl",
		["bodygroup"] = 2,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 0,
	},
	["paintedgasmask"] = {
		["name"] = "Red Eye Raider Gas Mask",
		["desc"] = "A painted Gas Mask worn often by those with a reason to hide their face | +1 PER",
		["type"] = "mask",
		["hair"] = true,
		["femalePrefix"] = "",
		["malePrefix"] = "",
		["facialHair"] = false,
		["cannotWear"] = {
			["glasses"] = true
		},
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "P", 1)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "P")
		end,
		["modelType"] = "masks",
		["itemModel"] = "models/fallout/apparel/raiderarmorhelmet.mdl",
		["bodygroup"] = 1,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 0,
	},
	["banditgasmask"] = {
		["name"] = "Bandit Gas Mask",
		["desc"] = "A Gas Mask often painted and worn by Raiders",
		["type"] = "mask",
		["facialHair"] = false,
		["modelType"] = "shemagh2_mask",
		["itemModel"] = "models/visualitygaming/fallout/prop/sol_shemagh2_mask.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["malePrefix"] = "sol_",
		["femalePrefix"] = "sol_",
		["rarity"] = 2,
		["head"] = true,
		["damage"] = 0
	},
	["raidergasmask"] = {
		["name"] = "Raider Gas Mask",
		["desc"] = "A painted Gas Mask worn often by those with a reason to hide their face | Immune to radiation",
		["type"] = "mask",
		["hair"] = true,
		["femalePrefix"] = "",
		["malePrefix"] = "",
		["facialHair"] = false,
		["cannotWear"] = {
			["glasses"] = true
		},
		["OnWear"] = function(ply, item)
			ply.isImmune = true
			ply:falloutNotify("Your gas mask makes you immune to radiation", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply.isImmune = ply:RadImmunity(true) -- Affirm rad immunity state
		end,
		["modelType"] = "masks",
		["itemModel"] = "models/fallout/apparel/minerhelmetgo.mdl",
		["bodygroup"] = 2,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 0
	},
	["prewargasmask"] = {
		["name"] = "Ghost Gas Mask",
		["desc"] = "A painted Gas Mask worn often by those with a reason to hide their face | Immune to radiation",
		["type"] = "mask",
		["hair"] = true,
		["femalePrefix"] = "",
		["malePrefix"] = "",
		["facialHair"] = false,
		["cannotWear"] = {
			["glasses"] = true
		},
		["OnWear"] = function(ply, item)
			ply.isImmune = true
			ply:falloutNotify("Your gas mask makes you immune to radiation", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply.isImmune = ply:RadImmunity(true) -- Affirm rad immunity state
		end,
		["modelType"] = "masks",
		["itemModel"] = "models/fallout/apparel/minerhelmetgo.mdl",
		["bodygroup"] = 3,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 0
	},
    ["np_clown_mask"] = {
        ["name"] = "Nuclear Clown Mask",
        ["desc"] = "A clown theme painted gas mask. | NP - FACTION ARMOR",
        ["type"] = "mask",
        ["itemModel"] = "models/fallout/apparel/gscbanditmask.mdl",
        ["rootPath"] = "models/cgcclothing/",
        ["pathType"] = "clowngasmask",
        ["modelType"] = "mask",
        ["malePrefix"] = "",
        ["femalePrefix"] = "",
        ["maleScale"] = 1,
        ["femaleScale"] = 1,
        ["rarity"] = 3,
        ["head"] = true,
        ["cannotWear"] = {
            ["mask"] = true,
            ["glasses"] = true
        },
		["OnWear"] = function(ply, item)
			ply.isImmune = true
			ply:falloutNotify("Your gas mask makes you immune to radiation", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply.isImmune = ply:RadImmunity(true) -- Affirm rad immunity state
		end,
        ["damage"] = 0
    },
	["bandana"] = {
		["name"] = "Skull Bandana Mask",
		["desc"] = "A painted Bandana Mask worn often by those with a reason to hide their face",
		["type"] = "mask",
		["hair"] = true,
		["femalePrefix"] = "",
		["malePrefix"] = "",
		["facialHair"] = false,
		["modelType"] = "masks",
		["itemModel"] = "models/fallout/apparel/gscbandit.mdl",
		["bodygroup"] = 4,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 0
	},
	["facemask"] = {
		["name"] = "Medical Face Mask",
		["desc"] = "A face mask commonly worn by medical professionals | Provides +5 to Medical Rolls",
		["type"] = "mask",
		["hair"] = true,
		["facialHair"] = false,
		["modelType"] = "masks01",
		["itemModel"] = "models/fallout/apparel/headwrap.mdl",
		["bodygroup"] = 3,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 0
	},
	["whiteglovemask"] = {
		["name"] = "White Glove Society Face Mask",
		["desc"] = "A costume mask often worn by The White Glove Society in New Vegas",
		["type"] = "mask",
		["hair"] = true,
		["facialHair"] = false,
		["cannotWear"] = {
			["glasses"] = false
		},
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "I", 1)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "I")
		end,
		["modelType"] = "masks01",
		["itemModel"] = "models/fallout/apparel/hockeymask.mdl",
		["bodygroup"] = 4,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 0
	},
	["revenant"] = {
		["name"] = "Wasteland Revenant Helmet",
		["desc"] = "A hand-crafted helmet of unknown origin, but has been passed down by Legendary Marksmens | Legendary Helmet",
		["type"] = "hat",
		["hair"] = false,
		["rootPath"] = "models/thespireroleplay/humans/",
		["maleSuffix"] = "_m",
		["femaleSuffix"] = "_f",
		["facialHair"] = false,
		["rarity"] = 5,
		["cannotWear"] = {
			["glasses"] = false,
			["mask"] = false
		},
		["modelType"] = "ncrhats",
		["itemModel"] = "models/fallout/apparel/gscexohelmetgo.mdl",
		["bodygroup"] = 3,
		["pathType"] = "headgear",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "P", 5)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "P")
		end,
		["head"] = true,
		["damage"] = 70,
		["speed"] = 0,
	},
	["ncrballistichelmet"] = {
		["name"] = "NCR Ballistic Helmet",
		["desc"] = "A custom made NCR Trooper Helmet designed for NCR Infantry | Male Armor | NCR - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["rootPath"] = "models/thespireroleplay/humans/",
		["maleSuffix"] = "_m",
		["femaleSuffix"] = "_f",
		["facialHair"] = true,
		["rarity"] = 3,
		["modelType"] = "ncrhats",
		["itemModel"] = "models/fallout/apparel/trooperhelm.mdl",
		["bodygroup"] = 2,
		["pathType"] = "headgear",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "P", 3)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "P")
		end,
		["head"] = true,
		["damage"] = 64,
		["speed"] = 0,
	},
	["ncrreconhelmet"] = {
		["name"] = "NCR Recon Helmet",
		["desc"] = "A custom made NCR Trooper Helmet designed for recon operations | Male Armor | NCR - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["rootPath"] = "models/thespireroleplay/humans/",
		["maleSuffix"] = "_m",
		["femaleSuffix"] = "_f",
		["facialHair"] = true,
		["rarity"] = 2,
		["modelType"] = "ncrhats",
		["itemModel"] = "models/fallout/apparel/trooperhelm.mdl",
		["bodygroup"] = 1,
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 60,
		["speed"] = 5,
	},
	["soldierhelm"] = {
		["name"] = "Pre-War Soldier Helmet",
		["desc"] = "A military helmet from before the war",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["rootPath"] = "models/thespireroleplay/humans/",
		["maleSuffix"] = "_m",
		["femaleSuffix"] = "_f",
		["modelType"] = "ncrhats",
		["itemModel"] = "models/fallout/apparel/trooperhelm.mdl",
		["bodygroup"] = 4,
		["head"] = true,
		["pathType"] = "headgear",
	},
	["ncrenlist"] = {
		["name"] = "NCR Enlisted Cap",
		["desc"] = "A cap worn by newly enlisted NCR Personnel | NCR - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["rarity"] = 2,
		["rootPath"] = "models/thespireroleplay/humans/",
		["maleSuffix"] = "_m",
		["femaleSuffix"] = "_f",
		["modelType"] = "ncrhats",
		["itemModel"] = "models/fallout/apparel/trooperhelm.mdl",
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 63,
	},
	["boscap"] = {
		["name"] = "BOS Field Scribe Cap",
		["desc"] = "A cap often worn by Field Scribes of the Brotherhood of Steel | BOS - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["rarity"] = 2,
		["rootPath"] = "models/thespireroleplay/humans/",
		["maleSuffix"] = "_m",
		["femaleSuffix"] = "_f",
		["modelType"] = "ncrhats",
		["itemModel"] = "models/fallout/apparel/sshelm.mdl",
		["pathType"] = "headgear",
		["head"] = true,
		["damage"] = 55,
	},
	-- EXTERNAL ARMOR --
	["lightexternalarmor"] = {
		["name"] = "Light External Gear",
		["desc"] = "A light external armor that provides increased resistance but decreases mobility | +DR / -AGI",
		["type"] = "armor",
		["cannotWear"] = {
			["armor"] = true
		},
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "gear",
		["femalePrefix"] = "female_",
		["malePrefix"] = "male_",
		["modelType"] = "armor",
		["itemModel"] = "models/thespireroleplay/items/clothes/group008.mdl",
		["damage"] = 0,
		["speed"] = 0,
	},
	["mediumexternalarmor"] = {
		["name"] = "Medium External Gear",
		["desc"] = "A medium external armor that provides increased resistance but decreases mobility | +DR / -AGI",
		["type"] = "armor",
		["cannotWear"] = {
			["armor"] = true
		},
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "gear",
		["femalePrefix"] = "female_",
		["malePrefix"] = "male_",
		["modelType"] = "armor",
		["itemModel"] = "models/thespireroleplay/items/clothes/group008.mdl",
		["bodygroup"] = {1, 2},
		["damage"] = 0,
		["speed"] = 0,
	},
	["heavyexternalarmor"] = {
		["name"] = "Heavy External Gear",
		["desc"] = "A medium external armor that provides increased resistance but decreases mobility",
		["type"] = "armor",
		["cannotWear"] = {
			["armor"] = true
		},
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "gear",
		["femalePrefix"] = "female_",
		["malePrefix"] = "male_",
		["modelType"] = "armor",
		["itemModel"] = "models/thespireroleplay/items/clothes/group008.mdl",
		["bodygroup"] = {1, 1},
		["damage"] = 0,
		["speed"] = 0,
	},
	["ncrmantle"] = {
		["name"] = "NCR Mantle",
		["desc"] = "A mantle accessory worn often by NCR Officers | Male Armor | +DR / -AGI",
		["type"] = "armor",
		["rootPath"] = "models/cgcclothing/humans/",
		["maleSuffix"] = "",
		["femaleSuffix"] = "",
		["pathType"] = "gear",
		["modelType"] = "mantle_m",
		["itemModel"] = "models/fallout/apparel/hazmat.mdl",
		["damage"] = 0,
		["speed"] = 0,
		["sex"] = "male"
	},
	["ncrbando"] = {
		["name"] = "NCR Bandolier",
		["desc"] = "A mantle accessory worn often by NCR NCOs | Male Armor | +DR / -AGI",
		["type"] = "armor",
		["rootPath"] = "models/thespireroleplay/humans/",
		["maleSuffix"] = "",
		["femaleSuffix"] = "",
		["pathType"] = "gear",
		["modelType"] = "bandolier_m",
		["itemModel"] = "models/fallout/apparel/hazmat.mdl",
		["damage"] = 0,
		["speed"] = 0,
		["sex"] = "male"
	},
	["satchel"] = {
		["name"] = "Satchel",
		["desc"] = "A satchel worn around the waist | Male Accessory",
		["type"] = "neck",
		["rootPath"] = "models/thespireroleplay/humans/",
		["maleSuffix"] = "_m",
		["pathType"] = "gear",
		["modelType"] = "satchel_m",
		["itemModel"] = "models/maxib123/dufflebag.mdl",
		["sex"] = "male"
	},
	["binoculars"] = {
		["name"] = "Bincoulars",
		["desc"] = "A set of binoculars worn around the neck | Male Accessory",
		["type"] = "neck",
		["rootPath"] = "models/thespireroleplay/humans/",
		["maleSuffix"] = "_m",
		["modelType"] = "binoc_m",
		["pathType"] = "gear",
		["itemModel"] = "models/maxib123/binoculars.mdl",
		["sex"] = "male"
	},
	["cloak"] = {
		["name"] = "Cloak",
		["desc"] = "A cloak worn around the neck | Legion - Faction Accessory",
		["type"] = "neck",
		["rootPath"] = "models/thespireroleplay/humans/gear/",
		["pathType"] = "legion",
		["femaleSuffix"] = "",
		["maleSuffix"] = "",
		["modelType"] = "cloak_f",
		["maleScale"] = 1.15,
		["itemModel"] = "models/thespireroleplay/items/clothes/group001.mdl",
	},
	["flamerbp"] = {
		["name"] = "Flame Fuel Ammo Backpack",
		["desc"] = "A backpack often used alongside a Flamethrower | This wear is purely cosmetic | Only wear with Power Armor",
		["type"] = "backpack",
		["femaleSuffix"] = "_f",
		["maleSuffix"] = "_m",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "gear",
		["modelType"] = "backpack",
		["itemModel"] = "models/weapons/flamer/w_flamer.mdl",
		["powerarmor"] = true,
	},
	["gatlingrbp"] = {
		["name"] = "Gatling Charger Ammo Backpack",
		["desc"] = "A backpack often used alongside a Gatling Laser | This wear is purely cosmetic | Only wear with Power Armor",
		["type"] = "backpack",
		["femaleSuffix"] = "_f",
		["maleSuffix"] = "_m",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "gear",
		["modelType"] = "backpack",
		["itemModel"] = "models/fallout/weapons/w_gatlinglasergo.mdl",
		["powerarmor"] = true,
		["bodygroup"] = 1,
	},
	["explosivebp"] = {
		["name"] = "Heavy Explosive Ammo Backpack",
		["desc"] = "A backpack often used alongside a Grenade Machinegun | This wear is purely cosmetic | Only wear with Power Armor",
		["type"] = "backpack",
		["femaleSuffix"] = "_f",
		["maleSuffix"] = "_m",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "gear",
		["modelType"] = "backpack",
		["itemModel"] = "models/fallout/weapons/c_l30_backpack.mdl",
		["powerarmor"] = true,
		["bodygroup"] = 2,
	},
	["minigunbp"] = {
		["name"] = "Minigun Ammo Backpack",
		["desc"] = "A backpack often used alongside a Minigun | This wear is purely cosmetic | Only wear with Power Armor",
		["type"] = "backpack",
		["femaleSuffix"] = "_f",
		["maleSuffix"] = "_m",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "gear",
		["modelType"] = "backpack",
		["itemModel"] = "models/fallout/weapons/minigunbackpack.mdl",
		["powerarmor"] = true,
		["bodygroup"] = 3,
	},
	["drduster"] = {
		["name"] = "Desert Ranger Duster",
		["desc"] = "A duster often worn by Rangers and the dangerous | DR - FACTION ARMOR",
		["type"] = "extra",
		["modelType"] = "rangercoat",
		["itemModel"] = "models/fallout/apparel/gscbandit.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["maleSuffix"] = "_male",
		["femaleSuffix"] = "_female",
		["rarity"] = 3,
		["damage"] = 0
	},
	["aldrduster"] = {
		["name"] = "Desert Ranger Armless Duster",
		["desc"] = "A duster often worn by Rangers and the dangerous | DR - FACTION ARMOR",
		["type"] = "extra",
		["modelType"] = "rangercoat",
		["itemModel"] = "models/fallout/apparel/gscbandit.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["maleSuffix"] = "_male",
		["femaleSuffix"] = "_female",
		["bodygroup"] = 1,
		["rarity"] = 3,
		["damage"] = 0
	},
	["whiteduster"] = {
		["name"] = "White Duster",
		["desc"] = "A duster often worn by Rangers and the dangerous",
		["type"] = "extra",
		["modelType"] = "rangercoat",
		["itemModel"] = "models/fallout/apparel/gscbandit.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["maleSuffix"] = "_male",
		["femaleSuffix"] = "_female",
		["skin"] = 2,
		["rarity"] = 3,
		["damage"] = 0
	},
	["alwhiteduster"] = {
		["name"] = "Armless White Duster",
		["desc"] = "A duster often worn by Rangers and the dangerous",
		["type"] = "extra",
		["modelType"] = "rangercoat",
		["itemModel"] = "models/fallout/apparel/gscbandit.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["maleSuffix"] = "_male",
		["femaleSuffix"] = "_female",
		["skin"] = 2,
		["bodygroup"] = 1,
		["rarity"] = 3,
		["damage"] = 0
	},
	["ncrrangerduster"] = {
		["name"] = "NCR Ranger Duster",
		["desc"] = "A duster often worn by Rangers and the dangerous | NCR - FACTION ARMOR",
		["type"] = "extra",
		["modelType"] = "rangercoat",
		["itemModel"] = "models/fallout/apparel/gscbandit.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["maleSuffix"] = "_male",
		["femaleSuffix"] = "_female",
		["skin"] = 1,
		["rarity"] = 3,
		["damage"] = 0
	},
	["alncrrangerduster"] = {
		["name"] = "NCR Armless Ranger Duster",
		["desc"] = "A duster often worn by Rangers and the dangerous | NCR - FACTION ARMOR",
		["type"] = "extra",
		["modelType"] = "rangercoat",
		["itemModel"] = "models/fallout/apparel/gscbandit.mdl",
		["rootPath"] = "models/visualitygaming/fallout/",
		["pathType"] = "prop",
		["maleSuffix"] = "_male",
		["femaleSuffix"] = "_female",
		["bodygroup"] = 1,
		["skin"] = 1,
		["rarity"] = 3,
		["damage"] = 0
	},
	["militia_riot_duster"] = {
		["name"] = "Militia Road Riot Duster",
		["desc"] = "An elite riot gear duster obtained from dead Riot Rangers. Refurbished to some how be even more American. | MILITIA - FACTION ARMOR",
		["type"] = "extra",
		["itemModel"] = "models/fallout/apparel/gscbandit.mdl",
		["rootPath"] = "models/cgcclothing/humans/",
		["pathType"] = "militia_courier",
		["modelType"] = "militia_duster",
		["maleSuffix"] = "",
		["femaleSuffix"] = "",
		["rarity"] = 4,
		["damage"] = 0
	},
	["bos_eldercoat"] = {
		["name"] = "BOS Chapter Elder Coat",
		["desc"] = "A coat worn by the Brotherhood of Steel Chapter Elder | BOS - FACTION ARMOR",
		["type"] = "extra",
		["modelType"] = "coat",
		["itemModel"] = "models/fallout/apparel/gscbandit.mdl",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group125",
		["maleSuffix"] = "",
		["femaleSuffix"] = "",
		["maleScale"] = 1.18,
		["rarity"] = 5,
	},
	["slave_collar_clothes"] = {
		["name"] = "Deactivated Slave Collar",
		["desc"] = "A deactivated slave collar often used to enslave the innocent",
		["type"] = "neck",
		["malePrefix"] = "m_",
		["femalePrefix"] = "f_",
		["modelType"] = "slavecollar",
		["rootPath"] = "models/cgcclothing/",
		["pathType"] = "slavecollar",
		["itemModel"] = "models/marvless/slavecollar.mdl",
		["rarity"] = 2,
	},
	["cotc_hood"] = {
		["name"] = "Child of the Cathedral Priest Hood",
		["desc"] = "A hood often worn by priests of the Cathedral | UNITY - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["itemModel"] = "models/fallout/apparel/headwrap.mdl",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group201",
		["modelType"] = "cathedralf_hood",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["head"] = true,
		["damage"] = 55,
		["rarity"] = 2,
	},
	["cotc_hood_agent"] = {
		["name"] = "Child of the Cathedral Agent Hood",
		["desc"] = "A hood often worn by priests of the Cathedral | UNITY - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["itemModel"] = "models/fallout/apparel/chinesestealthhelm.mdl",
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group210",
		["modelType"] = "helmet",
		["maleSuffix"] = "",
		["femaleSuffix"] = "f",
		["cannotWear"] = {
			["glasses"] = true,
		},
		["head"] = true,
		["damage"] = 55,
		["rarity"] = 4,
	},
	["milita_recon_hood"] = {
		["name"] = "Militia Hunter Hood",
		["desc"] = "A hunter hood often used by Militia specialists | MILITIA - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = true,
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group303",
		["modelType"] = "hood",
		["maleScale"] = 1,
		["femaleScale"] = 1,
		["maleSuffix"] = "_male",
		["femaleSuffix"] = "_female",
		["itemModel"] = "models/fallout/apparel/legionhood_go.mdl",
		["head"] = "true",
		["rarity"] = 3,
		["damage"] = 60,
		["speed"] = 0,
	},
	["ncrhc_headwear"] = { -- 5.0 Community Update
		["name"] = "NCR High Command Hat",
		["desc"] = "A hat worn in uniform by New California Republic high command | NCR - FACTION OFFICER ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group515",
		["maleSuffix"] = "_male",
		["femaleSuffix"] = "_female",
		["modelType"] = "hat",
		["itemModel"] = "models/fallout/generalhelmet.mdl",
		["head"] = true,
		["rarity"] = 4,
		["damage"] = 35,
	},
	["anchorage_headwear"] = { -- 5.0 Community Update
		["name"] = "Anchorage Combat Helmet",
		["desc"] = "A unique helmet worn by pre-war soldiers during Operation Anchorage",
		["type"] = "hat",
		["hair"] = false,
		["facialHair"] = false,
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "anchorage",
		["maleSuffix"] = "_male",
		["femaleSuffix"] = "_female",
		["modelType"] = "hat",
		["itemModel"] = "models/fallout/apparel/stealthsuithelm.mdl",
		["noHead"] = true,
		["head"] = true,
		["rarity"] = 3,
		["damage"] = 55,
	},
	["mysterious_fedora"] = { -- 5.0 Community Update
		["name"] = "Mysterious Fedora",
		["desc"] = "A unique fedora worn by an even more unique but strange individual",
		["type"] = "hat",
		["hair"] = false,
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group503",
		["maleSuffix"] = "_male",
		["femaleSuffix"] = "_female",
		["modelType"] = "hat",
		["itemModel"] = "models/fallout/apparel/cowboyhat4.mdl",
		["head"] = true,
		["rarity"] = 4,
		["damage"] = 45,
	},
	["chinese_officer_hat"] = { -- 6.0 Community Update
		["name"] = "Chinese Officer Hat",
		["desc"] = "A hat worn by the most respected soldiers in the great red PLA | PLA - FACTION ARMOR",
		["type"] = "hat",
		["hair"] = false,
		["rootPath"] = "models/thespireroleplay/humans/",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["pathType"] = "group890",
		["modelType"] = "hat",
		["itemModel"] = "models/fallout/fedora1.mdl",
		["head"] = true,
		["rarity"] = 3,
		["damage"] = 60,
	},	
    ["chinese_soldier_cap"] = { -- 6.0 Community Update
        ["name"] = "Chinese Ushanka",
        ["desc"] = "A ushanka worn by the most respected soldiers in the great Red PLA | PLA - FACTION ARMOR",
        ["type"] = "hat",
        ["hair"] = false,
        ["rootPath"] = "models/thespireroleplay/humans/",
        ["pathType"] = "group889",
        ["maleSuffix"] = "",
        ["femaleSuffix"] = "",
        ["modelType"] = "cap",
        ["itemModel"] = "models/fallout/leatherpilot.mdl",
        ["head"] = true,
        ["rarity"] = 2,
        ["damage"] = 55,
    },    
	["enclave_combat_mask"] = { -- 6.0 Community Update
		["name"] = "Enclave Combat Mask",
		["desc"] = "PLACE HOLDER",
		["type"] = "hat",
		["hair"] = false,
		["rootPath"] = "models/thespireroleplay/humans/",
		["pathType"] = "group888",
		["maleSuffix"] = "",
		["femaleSuffix"] = "",
		["modelType"] = "mask",
		["itemModel"] = "models/fallout/apparel/cowboyhat4.mdl",
		["head"] = true,
		["rarity"] = 4,
		["damage"] = 45,
}, 
}

Armor.Config.Bodies = {
	--["clothing"] = {
	--	["name"] = "(BASE) Clothing",
	--	["desc"] = "Clothing | This is a dev Item | Report this if you have it",
	--	["type"] = "body",
	--	["modelType"] = "group051",
	--	["itemModel"] = "models/thespireroleplay/items/clothes/group002.mdl",
	--	["bodygroup"] = 0,
	--	["cannotWear"] = {
	--		["hat"] = true
	--	},
	--	["damage"] = 10
	--},
	-- ALL ABOVE ARE EXAMPLE TABLES --
	["vaultboy"] = { -- DEFAULT CLOTHING
		["name"] = "Vault 77 Jumpsuit",
		["desc"] = "A jumpsuit from Vault 77 | VT - FACTION ARMOR",
		["modelType"] = "group010",
		["itemModel"] = "models/thespireroleplay/items/clothes/group010.mdl",
		["skin"] = 4,
		["damage"] = 10
	},
	["vaultsuit_101"] = {
		["name"] = "Vault 101 Jumpsuit",
		["desc"] = "A jumpsuit worn by vault dwellers.",
		["modelType"] = "group010",
		["itemModel"] = "models/thespireroleplay/items/clothes/group010.mdl",
		["skin"] = 0,
		["damage"] = 10
	},
	["vaultsuit_106"] = {
		["name"] = "Vault 106 Jumpsuit",
		["desc"] = "A jumpsuit worn by vault dwellers.",
		["modelType"] = "group010",
		["itemModel"] = "models/thespireroleplay/items/clothes/group010.mdl",
		["skin"] = 1,
		["damage"] = 10
	},
	["vaultsuit_112"] = {
		["name"] = "Vault 112 Jumpsuit",
		["desc"] = "A jumpsuit worn by vault dwellers.",
		["modelType"] = "group010",
		["itemModel"] = "models/thespireroleplay/items/clothes/group010.mdl",
		["skin"] = 2,
		["damage"] = 10
	},
	["vaultsuit_92"] = {
		["name"] = "Vault 92 Jumpsuit",
		["desc"] = "A jumpsuit worn by vault dwellers.",
		["modelType"] = "group010",
		["itemModel"] = "models/thespireroleplay/items/clothes/group010.mdl",
		["skin"] = 3,
		["damage"] = 10
	},
	/**
	["vaultsuit_77"] = { -- Exists as 'vaultboy' id
		["name"] = "Vault 77 Jumpsuit",
		["desc"] = "A jumpsuit worn by vault dwellers.",
		["modelType"] = "group010",
		["itemModel"] = "models/thespireroleplay/items/clothes/group010.mdl",
		["skin"] = 4,
		["damage"] = 10
	},
	**/
	["vaultsuit_21"] = {
		["name"] = "Vault 21 Jumpsuit",
		["desc"] = "A jumpsuit worn by vault dwellers.",
		["modelType"] = "group010",
		["itemModel"] = "models/thespireroleplay/items/clothes/group010.mdl",
		["skin"] = 5,
		["damage"] = 10
	},
	["vaultsuit_19"] = {
		["name"] = "Vault 19 Jumpsuit",
		["desc"] = "A jumpsuit worn by vault dwellers.",
		["modelType"] = "group010",
		["itemModel"] = "models/thespireroleplay/items/clothes/group010.mdl",
		["skin"] = 6,
		["damage"] = 10
	},
	["vaultsuit_11"] = {
		["name"] = "Vault 11 Jumpsuit",
		["desc"] = "A jumpsuit worn by vault dwellers.",
		["modelType"] = "group010",
		["itemModel"] = "models/thespireroleplay/items/clothes/group010.mdl",
		["skin"] = 7,
		["damage"] = 10
	},
	["vaultsuit_3"] = {
		["name"] = "Vault 3 Jumpsuit",
		["desc"] = "A jumpsuit worn by vault dwellers.",
		["modelType"] = "group010",
		["itemModel"] = "models/thespireroleplay/items/clothes/group010.mdl",
		["skin"] = 8,
		["damage"] = 10
	},
	-- -- ENCLAVE CLOTHING -- --
	["enclavescientistoutfit"] = {
		["name"] = "Enclave Biosuit",
		["desc"] = "An Enclave radiation resistant bio suit | ENCLAVE - FACTION ARMOR | Immune to Radiation | +8 INTEL",
		["type"] = "body",
		["path"] = "models/thespireroleplay/humans/group009/male.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group009/arms/male_arm.mdl",
		["itemModel"] = "models/thespireroleplay/items/clothes/group009.mdl",
		["itemModelSkin"] = 1,
		["bodygroup"] = 1,
		["rarity"] = 4,
		["skin"] = 1,
		["cannotWear"] = {
			["hat"] = true,
			["mask"] = true,
			["glasses"] = true,
			["hat"] = true
		},
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "I", 8)
			ply.isImmune = true
			ply:falloutNotify("You are dressed as a member of the Enclave", "ui/notify.mp3")
			ply:falloutNotify("Your unique Armor makes you immune to radiation", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "I")
			ply.isImmune = ply:RadImmunity(true) -- Affirm rad immunity state
			ply:falloutNotify("You are no longer dressed as a member of the Enclave", "ui/notify.mp3")
		end,
		["head"] = true,
		["damage"] = 40,
	},
	-- -- NCR CLOTHING -- --
	["ncrtraineeoutfit"] = {
		["name"] = "NCR Recruit Casuals",
		["desc"] = "An outfit worn by NCR Enlisted | NCR - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group037",
		["itemModel"] = "models/thespireroleplay/items/clothes/group020.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group020/arms/male_arm.mdl",
		["rarity"] = 1,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member NCR", "ui/notify.mp3")
		end,
		["damage"] = 63,
		["sex"] = "male"
	},
	["armor_ncrtrooper"] = {
		["name"] = "NCR Trooper Uniform",
		["desc"] = "An outfit worn by NCR Troopers | NCR - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group055",
		["itemModel"] = "models/thespireroleplay/items/clothes/group055.mdl",
		["rarity"] = 1,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "P", 2)
			BuffStat(ply, item, "E", 2)
			ply:falloutNotify("You are dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "P")
			EndBuff(ply, item, "E")
			ply:falloutNotify("You are no longer dressed as a member NCR", "ui/notify.mp3")
		end,
		["damage"] = 63,
	},
	["ncrfemaletrooperoutfit"] = {
		["name"] = "NCR Toured Uniform",
		["desc"] = "An outfit worn by NCR Troopers | NCR - FACTION ARMOR | +3 END",
		["type"] = "body",
		["modelType"] = "group055",
		["itemModel"] = "models/thespireroleplay/items/clothes/group055.mdl",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "P", 2)
			BuffStat(ply, item, "E", 2)
			ply:falloutNotify("You are dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "P")
			EndBuff(ply, item, "E")
			ply:falloutNotify("You are no longer dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["damage"] = 64,
	},
	["ncrsurvivalisttrooperoutfit"] = {
		["name"] = "NCR Survivalist Trooper Uniform",
		["desc"] = "An outfit worn by seasoned NCR Military Personel | NCR - FACTION ARMOR | +3 PER |+3 STR",
		["type"] = "body",
		["path"] = "models/thespireroleplay/humans/group029/male.mdl",
		["itemModel"] = "models/thespireroleplay/items/clothes/group055.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group055/arms/male_arm.mdl",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "P", 2)
			BuffStat(ply, item, "E", 2)
			ply:falloutNotify("You are dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "P")
			EndBuff(ply, item, "E")
			ply:falloutNotify("You are no longer dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["damage"] = 67,
	},
	["ncrassaultuniform"] = {
		["name"] = "NCR Assault Trooper Uniform",
		["desc"] = "An outfit worn by seasoned NCR Military Personel | NCR - FACTION ARMOR | +3 END",
		["type"] = "body",
		["path"] = "models/thespireroleplay/humans/group029/male.mdl",
		["itemModel"] = "models/thespireroleplay/items/clothes/group055.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group055/arms/male_arm.mdl",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "E", 3)
			ply:falloutNotify("You are dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "E")
			ply:falloutNotify("You are no longer dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["damage"] = 66,
	},
	["formalncrofficeroutfit"] = {
		["name"] = "NCR Formal Suit",
		["desc"] = "An outfit worn by officers during formal times or when off duty | NCR/CC - FACTION NUETRAL ARMOR",
		["type"] = "body",
		["modelType"] = "group027",
		["itemModel"] = "models/fallout/apparel/formalsuit.mdl",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["skin"] = 1,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are wearing a Faction Neutral clothing", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer wearing a Faction Neutral clothing", "ui/notify.mp3")
		end,
		["damage"] = 25,
	},
	["ncrfistreconelite"] = {
		["name"] = "NCR 1st Recon Masked Elite Uniform",
		["desc"] = "A masked outfit worn by seasoned NCR Military Personel | NCR - FACTION ARMOR",
		["type"] = "body",
		["path"] = "models/thespireroleplay/humans/group032/male.mdl",
		["itemModel"] = "models/thespireroleplay/items/clothes/group055.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group055/arms/male_arm.mdl",
		["rarity"] = 2,
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "E", 3)
			ply:falloutNotify("You are dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "E")
			ply:falloutNotify("You are no longer as a member of the NCR", "ui/notify.mp3")
		end,
		["damage"] = 65
	},
	["ncrfirstrecon"] = {
		["name"] = "NCR 1st Recon Scout Uniform",
		["desc"] = "An outfit worn by NCR First Recon Personnel | NCR - FACTION ARMOR | +3 AGL",
		["type"] = "body",
		["path"] = "models/thespireroleplay/humans/group031/male.mdl",
		["itemModel"] = "models/thespireroleplay/items/clothes/group055.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group055/arms/male_arm.mdl",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "E", 3)
			ply:falloutNotify("You are dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "E")
			ply:falloutNotify("You are no longer dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["damage"] = 65
	},
	["ncrmaskedmedicaloutfit"] = {
		["name"] = "NCR Masked Officer Uniform",
		["desc"] = "A uniform made and worn by New California Republic Officers | NCR - FACTION ARMOR | +5 END",
		["type"] = "body",
		["path"] = "models/thespireroleplay/humans/group033/male.mdl",
		["itemModel"] = "models/thespireroleplay/items/clothes/group055.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group055/arms/male_arm.mdl",
		["rarity"] = 3,
		["facialHair"] = false,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "E", 5)
			ply:falloutNotify("You are dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "E")
			ply:falloutNotify("You are no longer dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["damage"] = 70,
	},
	["armor_ncrofficer"] = {
		["name"] = "NCR Officer Uniform",
		["desc"] = "An outfit worn by NCR Demolition Troopers who carry explosives | NCR - FACTION ARMOR | +5 END",
		["type"] = "body",
		["path"] = "models/thespireroleplay/humans/group028/male.mdl",
		["itemModel"] = "models/thespireroleplay/items/clothes/group055.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group055/arms/male_arm.mdl",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["rarity"] = 3,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "E", 5)
			ply:falloutNotify("You are dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "E")
			ply:falloutNotify("You are no longer dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["damage"] = 70,
	},
	["heavyncrtrooperoutfit"] = {
		["name"] = "NCR Survivalist Uniform",
		["desc"] = "An outfit commonly worn by troopers equipped with heavy weaponry | NCR - FACTION ARMOR | +3 END",
		["type"] = "body",
		["path"] = "models/thespireroleplay/humans/group035/male.mdl",
		["itemModel"] = "models/thespireroleplay/items/clothes/group055.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group055/arms/male_arm.mdl",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "E", 3)
			ply:falloutNotify("You are dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "E")
			ply:falloutNotify("You are no longer dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["damage"] = 67,
	},
	["shockncrtrooperoutfit"] = {
		["name"] = "NCR Shock Assault Uniform",
		["desc"] = "An outfit commonly worn by troopers equipped with heavy weaponry | NCR - FACTION ARMOR | +3 STR",
		["type"] = "body",
		["path"] = "models/thespireroleplay/humans/group035/male.mdl",
		["itemModel"] = "models/thespireroleplay/items/clothes/group055.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group055/arms/male_arm.mdl",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 3)
			ply:falloutNotify("You are dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
			ply:falloutNotify("You are no longer dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["damage"] = 63,
	},
	["armor_ncrranger"] = {
		["name"] = "NCR Patrol Ranger Armor",
		["desc"] = "The NCR Ranger combat armor, also known as the Black armor | NCR - FACTION ARMOR | +1 PER / +2 END",
		["type"] = "body",
		["modelType"] = "group054",
		["itemModel"] = "models/thespireroleplay/items/clothes/group054.mdl",
		["rarity"] = 3,
		["cannotWear"] = {
			["extra"] = true,
			["armor"] = true,
		},
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "P", 2)
			BuffStat(ply, item, "E", 2)
			ply:falloutNotify("You are dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "P")
			EndBuff(ply, item, "E")
			ply:falloutNotify("You are no longer as a member of the NCR", "ui/notify.mp3")
		end,
		["damage"] = 67,
	},
	["armor_ncrveteranranger"] = {
		["name"] = "NCR Veteran Ranger Armor",
		["desc"] = "The NCR Ranger combat armor, also known as the Black armor | +3 PER | NCR - FACTION ARMOR",
		["type"] = "body",
		["path"] = "models/thespireroleplay/humans/group315/male.mdl",
		["itemModel"] = "models/fallout/apparel/combatranger.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["rarity"] = 4,
		["cannotWear"] = {
			["extra"] = true,
			["armor"] = true,
		},
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "P", 3)
			ply:falloutNotify("You are dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "P")
			ply:falloutNotify("You are no longer dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["damage"] = 70
	},
	["armor_desertranger"] = {
		["name"] = "Desert Ranger Armor",
		["desc"] = "The Desert Ranger combat armor, also known as the Black armor | DR - FACTION ARMOR",
		["type"] = "body",
		["path"] = "models/thespireroleplay/humans/group315/male.mdl",
		["skin"] = 1,
		["itemModel"] = "models/fallout/apparel/combatranger.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["rarity"] = 4,
		["cannotWear"] = {
			["extra"] = true,
			["armor"] = true,
		},
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of DR", "ui/notify.mp3")
			ply.FeatherFall = true
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of DR", "ui/notify.mp3")
			ply.FeatherFall = false
		end,
		["damage"] = 70
	},
	["armor_moddedncr"] = {
		["name"] = "Desert Ranger Officer Armor",
		["desc"] = "The Desert Ranger combat armor, also known as the Black armor | DR - FACTION ARMOR",
		["type"] = "body",
		["path"] = "models/thespireroleplay/humans/group315/male.mdl",
		["skin"] = 2,
		["itemModel"] = "models/fallout/apparel/combatranger.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["rarity"] = 4,
		["cannotWear"] = {
			["extra"] = true,
			["armor"] = true,
		},
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of DR", "ui/notify.mp3")
			ply.FeatherFall = true
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of DR", "ui/notify.mp3")
			ply.FeatherFall = false
		end,
		["damage"] = 70
	},
	["armor_savant"] = {
		["name"] = "Desert Ranger Hero Armor",
		["desc"] = "The Desert Ranger combat armor, also known as the Black armor | DR - FACTION OFFICER ARMOR",
		["type"] = "body",
		["path"] = "models/thespireroleplay/humans/group315/male.mdl",
		["skin"] = 3,
		["itemModel"] = "models/fallout/apparel/combatranger.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["rarity"] = 4,
		["cannotWear"] = {
			["extra"] = true,
			["armor"] = true,
		},
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of DR", "ui/notify.mp3")
			ply.FeatherFall = true
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of DR", "ui/notify.mp3")
			ply.FeatherFall = false
		end,
		["damage"] = 70
	},
	["armor_riotgear"] = {
		["name"] = "Riot Gear Armor",
		["desc"] = "Riot gear combat armor, also known as the Black armor",
		["type"] = "body",
		["path"] = "models/thespireroleplay/humans/group315/male.mdl",
		["skin"] = 4,
		["itemModel"] = "models/fallout/apparel/combatranger.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["rarity"] = 4,
		["cannotWear"] = {
			["extra"] = true,
			["armor"] = true,
		},
		["OnWear"] = function(ply, item)
			//ply:falloutNotify("You are dressed as a member of DR", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			//ply:falloutNotify("You are no longer dressed as a member of DR", "ui/notify.mp3")
		end,
		["damage"] = 70
	},
	["ncrengineeroutfit"] = {
		["name"] = "NCR Engineer Uniform",
		["desc"] = "A uniform worn by civilian Engineers, Technicians, and Research personnel of the NCR | NCR - FACTION ARMOR | +5 INTEL",
		["type"] = "body",
		["modelType"] = "group006",
		["itemModel"] = "models/thespireroleplay/items/clothes/group006.mdl",
		["itemModelSkin"] = 1,
		["skin"] = 2,
		["rarity"] = 1,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "I", 5)
			ply:falloutNotify("You are dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "I")
			ply:falloutNotify("You are no longer dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["damage"] = 25,
	},
	-- -- BOS CLOTHING -- --
	["armor_scribe"] = {
		["name"] = "BOS Scribe Robes",
		["desc"] = "A set of Robes worn by Brotherhood of Steel Scribes | BOS - FACTION ARMOR | +5 INTEL",
		["type"] = "body",
		["modelType"] = "group102",
		["itemModel"] = "models/thespireroleplay/items/clothes/group102.mdl",
		["rarity"] = 1,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "I", 5)
			ply:falloutNotify("You are dressed as a member of the BOS", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "I")
			ply:falloutNotify("You are no longer dressed as a member of the BOS", "ui/notify.mp3")
		end,
		["damage"] = 40
	},
	["armor_bosstealth"] = {
		["name"] = "BOS Specialist Armor",
		["desc"] = "A set of Robes worn by Brotherhood of Steel Scribes | BOS - FACTION ARMOR | +3 AGIL / +1 PERC",
		["type"] = "body",
		["modelType"] = "group005",
		["itemModel"] = "models/thespireroleplay/items/clothes/group005.mdl",
		["skin"] = 3,
		["rarity"] = 3,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "A", 3)
			BuffStat(ply, item, "P", 1)
			ply:falloutNotify("You are dressed as a member of the BOS", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "A")
			EndBuff(ply, item, "P")
			ply:falloutNotify("You are no longer dressed as a member of the BOS", "ui/notify.mp3")
		end,
		["damage"] = 60
	},
	["bos_fieldscribe"] = {
		["name"] = "BOS Field Scribe Uniform",
		["desc"] = "A uniform often worn by Bortherhood of Steel Scribes that are deployed into the Field | BOS - FACTION ARMOR | +2 INTEL",
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["path"] = "models/player/fieldscribeclothing.mdl",
		["itemModel"] = "models/fallout/apparel/bosscribe.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group020/arms/male_arm.mdl",
		["rarity"] = 2,
		["type"] = "body",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "I", 2)
			ply:falloutNotify("You are dressed as a BOS Member", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "I")
			ply:falloutNotify("You are no longer dressed as a BOS Member", "ui/notify.mp3")
		end,
		["damage"] = 55
	},
	["armor_elders"] = {
		["name"] = "Chapter Elder Robes",
		["desc"] = "A set of robes often strictly worn by Brotherhood of Steel Chapter Elders | BOS - FACTION ARMOR | +10 INTEL",
		["type"] = "body",
		["modelType"] = "group102",
		["itemModel"] = "models/thespireroleplay/items/clothes/group102.mdl",
		["itemModelSkin"] = 1,
		["skin"] = 1,
		["rarity"] = 5,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "I", 10)
			ply:falloutNotify("You are dressed as the Chapter Elder", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "I")
			ply:falloutNotify("You are no longer dressed as the Chapter Elder", "ui/notify.mp3")
		end,
		["damage"] = 70
	},
	-- -- LEGION CLOTHING  -- --
	["armor_legcenturion"] = {
		["name"] = "Legion Legatus Armor",
		["desc"] = "The armor appears to be a full suit of heavy gauge steel and offers full body protection. It also has a cloak in excellent condition, but the armor itself bears numerous battle scars and the helmet is missing half of the left horn | Male Armor | LEGION - FACTION OFFICER ARMOR | +5 STR ",
		["type"] = "body",
		["modelType"] = "group107",
		["itemModel"] = "models/thespireroleplay/items/clothes/group107.mdl",
		["rarity"] = 5,
		["powerarmor"] = true,
		["noCore"] = true,
		["footstep"] = Armor.PAFootstep,
		["noFall"] = true,
		["cannotWear"] = {
			["armor"] = true,
			["extra"] = true
		},
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 5)
			ply:falloutNotify("You are dressed as the Legatus", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
			ply:falloutNotify("You are no longer dressed as the Legatus", "ui/notify.mp3")
		end,
		["damage"] = 90,
		["speed"] = -10
	},
	["armor_caesar"] = {
		["name"] = "Caesar's Clothing",
		["desc"] = "Worn by the leader of the Legion, the tunic would appear to be a red sports jersey, coinciding with the football theme of Legion armor | Male Armor | LEGION - FACTION ARMOR | +10 INTEL",
		["type"] = "body",
		["modelType"] = "group105",
		["itemModel"] = "models/fallout/apparel/caesargo.mdl",
		["sex"] = "male",
		["rarity"] = 5,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "I", 10)
			ply:falloutNotify("You are dressed as the Caesar", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "I")
			ply:falloutNotify("You are no longer dressed as the Caesar", "ui/notify.mp3")
		end,
		["damage"] = 50
	},
	["centurionoutfit"] = {
		["name"] = "Legion Centurion Armor",
		["desc"] = "Armor available to the Caesar's Legion. The armor is composed from other pieces of armor taken from that of the wearer's defeated opponents in combat | LEGION - FACTION OFFICER ARMOR | +3 STR / +3 AGIL",
		["type"] = "body",
		["modelType"] = "group106",
		["itemModel"] = "models/fallout/apparel/centuriongo.mdl",
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "P", 3)
			BuffStat(ply, item, "A", 3)
			ply:falloutNotify("You are dressed as member of the Legion", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "P")
			EndBuff(ply, item, "A")
			ply:falloutNotify("You are no longer dressed as member of the Legion", "ui/notify.mp3")
		end,
		["damage"] = 70
	},
	["heavycenturionoutfit"] = {
		["name"] = "Legion Heavy Centurion Armor",
		["desc"] = "The strongest armor available to the Caesar's Legion. The armor is composed from other pieces of armor taken from that of the wearer's defeated opponents in combat | LEGION - FACTION OFFICER ARMOR | +3 STR / +3 AGIL",
		["type"] = "body",
		["modelType"] = "group523",
		["itemModel"] = "models/fallout/apparel/centuriongo.mdl",
		["rarity"] = 4,
		["powerarmor"] = true,
		["noCore"] = true,
		["footstep"] = Armor.PAFootstep,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as member of the Legion", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as member of the Legion", "ui/notify.mp3")
		end,
		["damage"] = 80,
		["speed"] = -20
	},
	["armor_legpraetorian"] = {
		["name"] = "Legion Praetorian Armor",
		["desc"] = "Similar to the recruit armor, the Praetorian outfit was distinguished by the metal bracers and the short red cape | LEGION - FACTION ARMOR | +5 STR / +3 AGIL",
		["type"] = "body",
		["modelType"] = "group108",
		["itemModel"] = "models/fallout/apparel/legiongo.mdl",
		["cannotWear"] = {
			["armor"] = true
		},
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 5)
			BuffStat(ply, item, "E", 3)
			ply:falloutNotify("You are dressed as member of the Legion", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
			EndBuff(ply, item, "E")
			ply:falloutNotify("You are no longer dressed as member of the Legion", "ui/notify.mp3")
		end,
		["damage"] = 68,
		["speed"] = 5
	},
	["armor_legavex"] = {
		["name"] = "Legion Vexillarius Uniform",
		["desc"] = "Vexillarius armor is worn by the bannermen of Caesar's Legion | LEGION - FACTION ARMOR | +2 STR / +2 AGIL",
		["type"] = "body",
		["modelType"] = "group304",
		["itemModel"] = "models/fallout/apparel/legiongo.mdl",
		["rarity"] = 3,
		["cannotWear"] = {
			["armor"] = true
		},
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 3)
			BuffStat(ply, item, "A", 3)
			ply:falloutNotify("You are dressed as member of the Legion", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
			EndBuff(ply, item, "A")
			ply:falloutNotify("You are no longer dressed as member of the Legion", "ui/notify.mp3")
		end,
		["damage"] = 68,
	},
	["armor_vetleglegion_decanus"] = {
		["name"] = "Veteran Decanus Uniform",
		["desc"] = "Compared to Legion prime armor, veteran armor has additional armor pads on the lower legs, as well as several sharp nails sticking out of the shoulder pads and the leather wrappings on the right arm | LEGION - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group110",
		["itemModel"] = "models/fallout/apparel/legiongo.mdl",
		["rarity"] = 3,
		["cannotWear"] = {
			["armor"] = true
		},
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 2)
			BuffStat(ply, item, "P", 2)
			BuffStat(ply, item, "A", 2)
			ply:falloutNotify("You are dressed as member of the Legion", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
			EndBuff(ply, item, "P")
			EndBuff(ply, item, "A")
			ply:falloutNotify("You are no longer dressed as member of the Legion", "ui/notify.mp3")
		end,
		["damage"] = 68,
	},
	["legionprimeoutfit_decanus"] = {
		["name"] = "Prime Decanus Uniform",
		["desc"] = "A suit of armor in the style of the Romans. The outfit looks similar to the recruit outfit, the only difference being their equipment and slight improvements | LEGION - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group057",
		["itemModel"] = "models/fallout/apparel/legiongo.mdl",
		["rarity"] = 3,
		["cannotWear"] = {
			["armor"] = true
		},
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 2)
			BuffStat(ply, item, "P", 2)
			BuffStat(ply, item, "A", 2)
			ply:falloutNotify("You are dressed as member of the Legion", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
			EndBuff(ply, item, "P")
			EndBuff(ply, item, "A")
			ply:falloutNotify("You are no longer dressed as member of the Legion", "ui/notify.mp3")
		end,
		["damage"] = 67
	},
	["armor_legionrecruit_decanus"] = {
		["name"] = "Recruit Decanus Uniform",
		["desc"] = "A suit of armor in the style of the Romans, using old suits of American football gear and stylized Roman blades - used by Legion Decanii | LEGION - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group109",
		["itemModel"] = "models/fallout/apparel/legiongo.mdl",
		["rarity"] = 3,
		["cannotWear"] = {
			["armor"] = true
		},
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 2)
			BuffStat(ply, item, "P", 2)
			BuffStat(ply, item, "A", 2)
			ply:falloutNotify("You are dressed as member of the Legion", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
			EndBuff(ply, item, "P")
			EndBuff(ply, item, "A")
			ply:falloutNotify("You are no longer dressed as member of the Legion", "ui/notify.mp3")
		end,
		["damage"] = 66
	},
	---
	["armor_vetleglegion"] = {
		["name"] = "Legion Veteran Uniform",
		["desc"] = "Compared to Legion prime armor, veteran armor has additional armor pads on the lower legs, as well as several sharp nails sticking out of the shoulder pads and the leather wrappings on the right arm | LEGION - FACTION ARMOR | +2 STR / +2 AGIL",
		["type"] = "body",
		["modelType"] = "group110",
		["itemModel"] = "models/fallout/apparel/legiongo.mdl",
		["rarity"] = 3,
		["cannotWear"] = {
			["armor"] = true
		},
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 2)
			BuffStat(ply, item, "P", 2)
			BuffStat(ply, item, "A", 2)
			ply:falloutNotify("You are dressed as member of the Legion", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
			EndBuff(ply, item, "P")
			EndBuff(ply, item, "A")
			ply:falloutNotify("You are no longer dressed as member of the Legion", "ui/notify.mp3")
		end,
		["damage"] = 65,
	},
	["legionprimeoutfit"] = {
		["name"] = "Legion Prime Uniform",
		["desc"] = "A suit of armor in the style of the Romans. The outfit looks similar to the recruit outfit, the only difference being their equipment and slight improvements | LEGION - FACTION ARMOR | +2 STR / +2 AGIL",
		["type"] = "body",
		["modelType"] = "group057",
		["itemModel"] = "models/fallout/apparel/legiongo.mdl",
		["rarity"] = 2,
		["cannotWear"] = {
			["armor"] = true
		},
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 2)
			BuffStat(ply, item, "P", 2)
			BuffStat(ply, item, "A", 2)
			ply:falloutNotify("You are dressed as member of the Legion", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
			EndBuff(ply, item, "P")
			EndBuff(ply, item, "A")
			ply:falloutNotify("You are no longer dressed as member of the Legion", "ui/notify.mp3")
		end,
		["damage"] = 64
	},
	["armor_legionrecruit"] = {
		["name"] = "Legion Recruit Uniform",
		["desc"] = "A suit of armor in the style of the Romans, using old suits of American football gear and stylized Roman blades - used by Legion recruits | LEGION - FACTION ARMOR | +1 STR / +1 AGIL",
		["type"] = "body",
		["modelType"] = "group109",
		["itemModel"] = "models/fallout/apparel/legiongo.mdl",
		["rarity"] = 1,
		["cannotWear"] = {
			["armor"] = true
		},
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 1)
			BuffStat(ply, item, "A", 2)
			ply:falloutNotify("You are dressed as member of the Legion", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
			EndBuff(ply, item, "A")
			ply:falloutNotify("You are no longer dressed as member of the Legion", "ui/notify.mp3")
		end,
		["damage"] = 63
	},
	["armor_slave"] = {
		["name"] = "Slave Clothes",
		["desc"] = "Dirty clothes often worn by Slaves | +3 END | LEGION / PARADISE - FACTION NEUTRAL ARMOR",
		["type"] = "body",
		["modelType"] = "group120",
		["itemModel"] = "models/fallout/apparel/slaverags_go.mdl",
		["rarity"] = 1,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 10)
			ply:falloutNotify("You wear the clothes of a slave . . .", "ui/notify.mp3")
			ply:ChatPrint("[ ! ]  As a slave, you must obey your Masters until you are rescued or earn your freedom")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
			ply:falloutNotify("You no longer wear the clothes of a slave", "ui/notify.mp3")
		end,
		["damage"] = 10
	},
	-------------------------------------------------------
	["pimpout"] = {
		["name"] = "Pimp Outfit",
		["desc"] = "A red pre-war slick and expensive zoot suit often worn by pimps.",
		["type"] = "body",
		["modelType"] = "group001",
		["itemModel"] = "models/thespireroleplay/items/clothes/group001.mdl",
		["rarity"] = 1,
		["damage"] = 35
	},
	["armor_gunrunnermalpais"] = {
		["name"] = "Gun Runner Special Forces Armor",
		["desc"] = "Ballistic vest and respective uniform worn by Salt-Lake City police officers. Repurposed by the Gun Runner Company for their Special Forces unit | GR - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group002",
		["itemModel"] = "models/fallout/apparel/raiderarmor04.mdl",
		["rarity"] = 3,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are wearing GR Faction Armor")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer wearing GR Faction Armor")
		end,
		["damage"] = 60
	}, -- LEGENDARY
	["cowboyoutfit"] = {
		["name"] = "Cowboy Outfit",
		["desc"] = "A set of Cowboy Clothing often worn by true Wild West heroin | +1 PERC",
		["type"] = "body",
		["modelType"] = "group003",
		["itemModel"] = "models/thespireroleplay/items/clothes/group014.mdl",
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "P", 1)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "P")
		end,
		["damage"] = 45,
		["speed"] = -5
	},
	["wastelandhoodie"] = {
		["name"] = "Wasteland Hoodie",
		["desc"] = "A dirty hoodie often worn by typically untrustworthy folk",
		["type"] = "body",
		["modelType"] = "group004",
		["itemModel"] = "models/thespireroleplay/items/clothes/group004.mdl",
		["rarity"] = 1,
		["damage"] = 25
	},
	["apacohoodie"] = {
		["name"] = "Apocalypse Hoodie",
		["desc"] = "A dirty hoodie often worn by typically untrustworthy folk",
		["type"] = "body",
		["modelType"] = "group004",
		["itemModel"] = "models/thespireroleplay/items/clothes/group004.mdl",
		["skin"] = 1,
		["rarity"] = 1,
		["damage"] = 25
	},
	["apacohoodie"] = {
		["name"] = "Necropolis Hoodie",
		["desc"] = "A dirty hoodie often worn by accepted Residents of Necropolis | NECROPOLIS - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group004",
		["itemModel"] = "models/thespireroleplay/items/clothes/group004.mdl",
		["skin"] = 1,
		["OnWear"] = function(ply, item)
		ply:falloutNotify("You are dressed as a member of Necropolis")
		 end,
		["OnRemove"] = function(ply, item)
		ply:falloutNotify("You are no longer dressed as a member of Necropolis")
		 end,
		["rarity"] = 1,
		["damage"] = 50
	},
	["ttadvanced"] = {
		["name"] = "Stealth Suit MKII",
		["desc"] = "A highly advanced Stealth Suit customized by Mysterious Reserchers far west. | TT - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group005",
		["itemModel"] = "models/thespireroleplay/items/clothes/group005.mdl",
		["itemModelSkin"] = 1,
		["skin"] = 1,
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:Give("weapon_stealthboy_infinite")
			ply:Give("weapon_medkit")
		end,
		["OnRemove"] = function(ply, item)
			ply:StripWeapon("weapon_stealthboy_infinite")
			ply:StripWeapon("weapon_medkit")
		end,
		["head"] = true,
		["damage"] = 5,
		["speed"] = 0,
	},
	["rarmor_chinesestealth"] = {
		["name"] = "Stealth Suit",
		["desc"] = "A highly advanced Stealth Suit customized by the Chinese Army for stealth operations | Has Stealthboy Attachment",
		["type"] = "body",
		["path"] = "models/cgcclothing/humans/chinastealth/male.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["itemModel"] = "models/fallout/apparel/chinesestealth.mdl",
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:Give("weapon_stealthboy_stealthsuit")
		end,
		["OnRemove"] = function(ply, item)
			ply:StripWeapon("weapon_stealthboy_stealthsuit")
		end,
		["damage"] = 45,
		["speed"] = 10,
	},
	["radiationsuit"] = {
		["name"] = "Radiation Suit",
		["desc"] = "A pre-war Radiation Suit worn to resist the effects of radiation | +2 INTEL | Immune to Radiation",
		["type"] = "body",
		["path"] = "models/thespireroleplay/humans/group009/male.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group009/arms/male_arm.mdl",
		["itemModel"] = "models/thespireroleplay/items/clothes/group009.mdl",
		["bodygroup"] = 1,
		["rarity"] = 3,
		["cannotWear"] = {
			["hat"] = true,
			["mask"] = true,
			["glasses"] = true,
			["hat"] = true
		},
		["OnWear"] = function(ply, item)
			ply:falloutNotify("Your unique Armor makes you immune to radiation", "ui/notify.mp3")
			BuffStat(ply, item, "I", 2)
			ply.isImmune = true
		 end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "I")
			ply.isImmune = ply:RadImmunity(true) -- Affirm rad immunity state
 		end,
		["head"] = true,
		["damage"] = 40
	},
	["armor_followerlabcoat"] = { -- Duplicate Item: lab coat to wipe previous followers Lab Coat item from eco
		["name"] = "Followers of the Apocalypse Clean Lab Coat",
		["desc"] = "A Lab Coat often worn by Researchers | +5 INTEL | FoA - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group007",
		["itemModel"] = "models/thespireroleplay/items/clothes/group007.mdl",
		["skin"] = 1,
		["rarity"] = 3,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "I", 5)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "I")
		end,
		["damage"] = 25
	},
	["real_armor_followerlabcoat"] = { -- replacement item for above armor set
		["name"] = "Followers of the Apocalypse Dirty Lab Coat",
		["desc"] = "A Lab Coat often worn by Researchers | +4 INTEL | FOLLOWERS - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group007",
		["itemModel"] = "models/thespireroleplay/items/clothes/group007.mdl",
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "I", 4)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "I")
		end,
		["damage"] = 25
	},
	["armor_labcoat"] = { -- FIXME: Remove later
		["name"] = "Followers of the Apocalypse Clean Lab Coat",
		["desc"] = "A Lab Coat often worn by Researchers | +5 INTEL | FOLLOWERS - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group007",
		["itemModel"] = "models/thespireroleplay/items/clothes/group007.mdl",
		["skin"] = 1,
		["rarity"] = 3,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "I", 5)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "I")
		end,
		["damage"] = 25
	},
	["armor_researcher1"] = {
		["name"] = "Pre-War Vault-Tec Lab Coat",
		["desc"] = "A Lab Coat often worn by Researchers | VT - FACTION ARMOR | +4 INTEL",
		["type"] = "body",
		["modelType"] = "group007",
		["itemModel"] = "models/thespireroleplay/items/clothes/group007.mdl",
		["itemModelSkin"] = 2,
		["skin"] = 2,
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "I", 4)
			ply:falloutNotify("You are wearing a Faction Neutral clothing", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "I")
			ply:falloutNotify("You are no longer wearing a Faction Neutral clothing", "ui/notify.mp3")
		end,
		["damage"] = 25
	},
	["vtresearcheroutfit"] = {
		["name"] = "Vault-Tec Lab Coat",
		["desc"] = "A Lab Coat often worn by Researchers | VT - FACTION ARMOR | +5 INTEL",
		["type"] = "body",
		["modelType"] = "group007",
		["itemModel"] = "models/thespireroleplay/items/clothes/group014.mdl",
		["itemModelSkin"] = 3,
		["skin"] = 3,
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "I", 5)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "I")
		end,
		["damage"] = 25
	},
	["riotrangergear"] = { -- Duplicate armor of below due to fixed model previously not existing
		["name"] = "Elite Riot Gear Armor",
		["desc"] = "A riot police officer uniform worn by the elite of the L.A.P.D. before the war. This specific armor was later adopted by the Riot Rangers, a now disbanded faction that sought to bring cold authority to the wasteland.",
		["type"] = "body",
		["path"] = "models/cgcclothing/riotgear/male.mdl",
		["itemModel"] = "models/fallout/apparel/centuriongo.mdl",
		["armsModel"] = "models/lazarusroleplay/thespireroleplay/humans/group122/arms/male_arm.mdl",
		["rarity"] = 4,
		["damage"] = 70,
		["speed"] = 0,
	},
	["riotrangergearfs"] = { -- Duplicate armor of above due to fixed model previously not existing
		["name"] = "Elite Riot Gear Armor",
		["desc"] = "A riot police officer uniform worn by the elite of the L.A.P.D. before the war. This specific armor was later adopted by the Riot Rangers, a now disbanded faction that sought to bring cold authority to the wasteland. | Nuclear Patriot Officer - Faction Armor",
		["type"] = "body",
		["path"] = "models/cgcclothing/riotgear/male.mdl",
		["itemModel"] = "models/fallout/apparel/centuriongo.mdl",
		["armsModel"] = "models/lazarusroleplay/thespireroleplay/humans/group122/arms/male_arm.mdl",
		["rarity"] = 4,
		["damage"] = 70,
		["speed"] = 0,
	},
	["armor_metalarmorone"] = {
		["name"] = "Wasteland Metal Armor",
		["desc"] = "A set of Metal Armor often worn by thugs",
		["type"] = "body",
		["modelType"] = "group011",
		["itemModel"] = "models/fallout/apparel/metalarmor.mdl",
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
		end,
		["damage"] = 43,
		["speed"] = -9,
	},
	["armor_metalarmortwo"] = {
		["name"] = "Apocalypse Metal Armor", -- CONVERTED APACO METAL ARMOR DUE TO JACKAL ARMOR VERSION
		["desc"] = "A set of Metal Armor often worn by thugs",
		["type"] = "body",
		["modelType"] = "group011",
		["itemModel"] = "models/fallout/apparel/metalarmor.mdl",
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "P", 1)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "P")
		end,
		["damage"] = 40
	},
	["armor_militarycombatmki"] = {
		["name"] = "Green Combat Armor MKI",
		["desc"] = "A set of Combat Armor often worn by proffesionalds in whatever field they work in. Good or Evil",
 		["type"] = "body",
		["modelType"] = "group520",
		["armsModel"] = false,
		["itemModel"] = "models/fallout/apparel/combatarmor.mdl",
		["rarity"] = 2,
		["damage"] = 55,
	},
	["armor_tancombatarmormkii"] = {
		["name"] = "Desert Combat Armor MKI",
		["desc"] = "A set of Combat Armor often worn by proffesionalds in whatever field they work in. Good or Evil.",
		["type"] = "body",
		["modelType"] = "group520",
		["armsModel"] = false,
		["itemModel"] = "models/thespireroleplay/items/clothes/group012.mdl",
		["itemModelSkin"] = 1,
		["skin"] = 1,
		["rarity"] = 2,
		["damage"] = 50,
	},
	["talcombatarmor"] = {
		["name"] = "Talon Company Combat Armor",
		["desc"] = "A set of Combat Armor often worn by proffesionals in whatever field they work in. Good or Evil | TALON - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group520",
		["armsModel"] = false,
		["itemModel"] = "models/thespireroleplay/items/clothes/group012.mdl",
		["itemModelSkin"] = 2,
		["skin"] = 2,
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of Talon", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of Talon", "ui/notify.mp3")
		end,
		["damage"] = 60,
		["speed"] = 0,
	},
	["armor_tancombatarmormkiii"] = {
		["name"] = "Forest Combat Armor MKI",
		["desc"] = "A set of Combat Armor often worn by proffesionalds in whatever field they work in. Good or Evil.",
		["type"] = "body",
		["modelType"] = "group520",
		["armsModel"] = false,
		["itemModel"] = "models/thespireroleplay/items/clothes/group012.mdl",
		["itemModelSkin"] = 3,
		["skin"] = 3,
		["rarity"] = 2,
		["damage"] = 50,
	},
	["armor_tancombatarmormkiifi"] = {
		["name"] = "Jaded Combat Armor MKI",
		["desc"] = "A set of Combat Armor often worn by proffesionalds in whatever field they work in. Good or Evil.",
		["type"] = "body",
		["modelType"] = "group520",
		["armsModel"] = false,
		["itemModel"] = "models/thespireroleplay/items/clothes/group012.mdl",
		["itemModelSkin"] = 2,
		["skin"] = 4,
		["rarity"] = 2,
		["damage"] = 50,
	},
	["armor_metalarmormki"] = {
		["name"] = "Ghost Combat Armor MKI",
		["desc"] = "A set of Combat Armor often worn by proffesionalds in whatever field they work in. Good or Evil.",
		["type"] = "body",
		["modelType"] = "group520",
		["armsModel"] = false,
		["itemModel"] = "models/thespireroleplay/items/clothes/group012.mdl",
		["itemModelSkin"] = 2,
		["skin"] = 5,
		["rarity"] = 2,
		["damage"] = 50,
	},
	["shadowcombatarmor"] = {
		["name"] = "Shadow Combat Armor MKI",
		["desc"] = "A set of Combat Armor often worn by proffesionalds in whatever field they work in. Good or Evil.",
		["type"] = "body",
		["modelType"] = "group520",
		["armsModel"] = false,
		["itemModel"] = "models/thespireroleplay/items/clothes/group012.mdl",
		["itemModelSkin"] = 2,
		["skin"] = 6,
		["rarity"] = 2,
		["damage"] = 50,
	},
	["wintercombatarmor"] = {
		["name"] = "Winter Combat Armor MKI",
		["desc"] = "A set of Combat Armor often worn by proffesionalds in whatever field they work in. Good or Evil.",
		["type"] = "body",
		["modelType"] = "group520",
		["armsModel"] = false,
		["itemModel"] = "models/thespireroleplay/items/clothes/group012.mdl",
		["itemModelSkin"] = 2,
		["skin"] = 9,
		["rarity"] = 2,
		["damage"] = 50,
	},
	["wintercombatarmor"] = { -- 5.0 Community Update
		["name"] = "Anchorage Combat Armor",
		["desc"] = "A set of Combat Armor worn by U.S. Soldiers during Operation Anchorage.",
		["type"] = "body",
		["modelType"] = "group520",
		["armsModel"] = false,
		["itemModel"] = "models/thespireroleplay/items/clothes/group012.mdl",
		["itemModelSkin"] = 2,
		["skin"] = 7,
		["rarity"] = 3,
		["damage"] = 55,
	},
	["taloncombatarmor"] = {
		["name"] = "Dark Combat Armor MKI",
		["desc"] = "A set of Combat Armor often worn by proffesionalds in whatever field they work in. Good or Evil.",
		["type"] = "body",
		["modelType"] = "group520",
		["armsModel"] = false,
		["itemModel"] = "models/thespireroleplay/items/clothes/group012.mdl",
		["itemModelSkin"] = 2,
		["skin"] = 8,
		["rarity"] = 2,
		["damage"] = 50,
	},
	/**["armor_bosinitiate"] = { -- Old Model version
		["name"] = "BOS Combat Armor MKI",
		["desc"] = "A set of Combat Armor often worn by proffesionalds in whatever field they work in. Good or Evil.",
		["type"] = "body",
		["modelType"] = "group520",
		["itemModel"] = "models/thespireroleplay/items/clothes/group053.mdl",
		["itemModelSkin"] = 3,
		["skin"] = 7,
		["rarity"] = 2,
		["damage"] = 60,
		["speed"] = -14
	},**/
	["armor_bosinitiate"] = {
		["name"] = "BOS Initiate Armor",
		["desc"] = "A set of under armor often worn by Brotherhood of Steel Knights under their Power Armor. Initiates are also known to wear this as they are working their way into proving themselves worthy of wearing Power Armor itself | +2 END / +1 INTEL | BOS - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group204",
		["armsModel"] = "models/lazarusroleplay/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["itemModel"] = "models/fallout/apparel/bosunderarmor.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are now dressed as a member of the BOS")
			BuffStat(ply, item, "E", 2)
			BuffStat(ply, item, "I", 1)
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the BOS")
			EndBuff(ply, item, "E")
			EndBuff(ply, item, "I")
		end,
		["rarity"] = 2,
		["damage"] = 55,
		["speed"] = 5
	},
	["grasscombatarmor"] = {
		["name"] = "Grassland Combat Armor MKI",
		["desc"] = "A set of Combat Armor often worn by proffesionalds in whatever field they work in. Good or Evil.",
		["type"] = "body",
		["modelType"] = "group520",
		["armsModel"] = false,
		["itemModel"] = "models/thespireroleplay/items/clothes/group012.mdl",
		["itemModelSkin"] = 3,
		["skin"] = 10,
		["rarity"] = 2,
		["damage"] = 50,
	},
	["dfarmeroveralls"] = {
		["name"] = "Dusty Farmer Clothes",
		["desc"] = "A set of Farmers Clothing | +2 STR / +2 END",
		["type"] = "body",
		["modelType"] = "group026",
		["itemModel"] = "models/thespireroleplay/items/clothes/group014.mdl",
		["itemModelSkin"] = 4,
		["sex"] = "male",
		["rarity"] = 1,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 2)
			BuffStat(ply, item, "A", 1)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
			EndBuff(ply, item, "A")
		end,
		["damage"] = 30,
		["speed"] = -5
	},
	["armor_researcher14"] = {
		["name"] = "Green Farmer Clothes",
		["desc"] = "A set of Farmers Clothing | +2 STR / +2 END",
		["type"] = "body",
		["modelType"] = "group026",
		["itemModel"] = "models/thespireroleplay/items/clothes/group014.mdl",
		["itemModelSkin"] = 6,
		["skin"] = 1,
		["sex"] = "male",
		["rarity"] = 1,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 2)
			BuffStat(ply, item, "A", 1)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
			EndBuff(ply, item, "A")
		end,
		["damage"] = 30,
		["speed"] = -5
	},
	["armor_researcher10"] = {
		["name"] = "Blue Farmer Clothes",
		["desc"] = "A set of Farmers Clothing | +2 STR / +2 END",
		["type"] = "body",
		["modelType"] = "group026",
		["itemModel"] = "models/thespireroleplay/items/clothes/group014.mdl",
		["itemModelSkin"] = 2,
		["skin"] = 2,
		["sex"] = "male",
		["rarity"] = 1,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 2)
			BuffStat(ply, item, "A", 1)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
			EndBuff(ply, item, "A")
		end,
		["damage"] = 30,
		["speed"] = -5
	},
	["bright_brotherhood"] = {
		["name"] = "Bright Brotherhood Robes",
		["desc"] = "A set of robes often worn by Apostles of the Holy Light | +5 INTEL",
		["type"] = "body",
		["modelType"] = "group102",
		["itemModel"] = "models/thespireroleplay/items/clothes/group102.mdl",
		["itemModelSkin"] = 2,
		["skin"] = 2,
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "I", 5)
			ply:falloutNotify("You are dressed as a member of the BOS", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "I")
			ply:falloutNotify("You are no longer dressed as a member of the BOS", "ui/notify.mp3")
		end,
		["damage"] = 40
	},
	["armor_researcher19"] = {
		["name"] = "Clean Farmer Clothes",
		["desc"] = "A set of Farmers Clothing | +2 STR / +2 END",
		["type"] = "body",
		["modelType"] = "group026",
		["itemModel"] = "models/thespireroleplay/items/clothes/group014.mdl",
		["itemModelSkin"] = 4,
		["skin"] = 3,
		["sex"] = "male",
		["rarity"] = 1,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 2)
			BuffStat(ply, item, "A", 1)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
			EndBuff(ply, item, "A")
		end,
		["damage"] = 30,
		["speed"] = -5
	},
	["farmersoveralls"] = {
		["name"] = "Red Settler Overalls",
		["desc"] = "A set of Settler Clothing | +2 STR / +2 END",
		["type"] = "body",
		["modelType"] = "group013",
		["itemModel"] = "models/thespireroleplay/items/clothes/group013.mdl",
		["rarity"] = 1,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 2)
			BuffStat(ply, item, "E", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
			EndBuff(ply, item, "E")
		end,
		["damage"] = 30,
		["speed"] = -5
	},
	["bluefarmersoveralls"] = {
		["name"] = "Settler Overalls",
		["desc"] = "A set of Settler Clothing | +2 STR / +2 END",
		["type"] = "body",
		["modelType"] = "group013",
		["itemModel"] = "models/thespireroleplay/items/clothes/group013.mdl",
		["rarity"] = 1,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 2)
			BuffStat(ply, item, "E", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
			EndBuff(ply, item, "E")
		end,
		["damage"] = 30,
		["speed"] = -5
	},
	["redfarmersoveralls"] = {
		["name"] = "Blue Settler Overalls",
		["desc"] = "A set of Settler Clothing | +2 STR / +2 END",
		["type"] = "body",
		["modelType"] = "group013",
		["itemModel"] = "models/thespireroleplay/items/clothes/group013.mdl",
		["skin"] = 1,
		["rarity"] = 1,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 2)
			BuffStat(ply, item, "E", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
			EndBuff(ply, item, "E")
		end,
		["damage"] = 30,
		["speed"] = -5
	},
	["cleanfarmersoveralls"] = {
		["name"] = "Clean Settler Overalls",
		["desc"] = "A set of Farmers Clothing | +2 STR / +2 END",
		["type"] = "body",
		["modelType"] = "group013",
		["itemModel"] = "models/thespireroleplay/items/clothes/group013.mdl",
		["skin"] = 2,
		["rarity"] = 1,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 2)
			BuffStat(ply, item, "E", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
			EndBuff(ply, item, "E")
		end,
		["damage"] = 30,
		["speed"] = -5
	},
	["cleanbluefarmersoveralls"] = {
		["name"] = "Clean Blue Settler Overalls",
		["desc"] = "A set of Farmers Clothing | +2 STR / +2 END",
		["type"] = "body",
		["modelType"] = "group013",
		["itemModel"] = "models/thespireroleplay/items/clothes/group013.mdl",
		["skin"] = 3,
		["rarity"] = 1,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 2)
			BuffStat(ply, item, "E", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
			EndBuff(ply, item, "E")
		end,
		["damage"] = 30,
		["speed"] = -5
	},
	["greenengineeroutfit"] = {
		["name"] = "Green Engineer Uniform",
		["desc"] = "A suit worn by Engineers, Technicians, Mechanics and handy-men alike | +5 INTEL",
		["type"] = "body",
		["modelType"] = "group006",
		["itemModel"] = "models/thespireroleplay/items/clothes/group006.mdl",
		["rarity"] = 1,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "I", 5)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "I")
		end,
		["damage"] = 25,
		["speed"] = -5
	},
	["whiteengineeroutfit"] = {
		["name"] = "White Engineer Uniform",
		["desc"] = "A suit worn by Engineers, Technicians, Mechanics and handy-men alike | +5 INTEL",
		["type"] = "body",
		["modelType"] = "group006",
		["itemModel"] = "models/thespireroleplay/items/clothes/group006.mdl",
		["itemModelSkin"] = 2,
		["skin"] = 1,
		["rarity"] = 1,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "I", 5)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "I")
		end,
		["damage"] = 25,
		["speed"] = -5
	},
	["petrochiko"] = {
		["name"] = "Petró Chikó Uniform",
		["desc"] = "An outfit worn by employees of the Petró Chikó Gas Company | +5 END",
		["type"] = "body",
		["modelType"] = "group006",
		["itemModel"] = "models/thespireroleplay/items/clothes/group006.mdl",
		["itemModelSkin"] = 5,
		["skin"] = 3,
		["rarity"] = 1,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "E", 5)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "E")
		end,
		["damage"] = 30,
		["speed"] = -5
	},
	["bloodengineer"] = {
		["name"] = "Blood Engineer Uniform",
		["desc"] = "A suit worn by Engineers, Technicians, Mechanics and handy-men alike | +5 INTEL",
		["type"] = "body",
		["modelType"] = "group006",
		["itemModel"] = "modecs/thespireroleplay/items/clothes/group001.mdl",
		["itemModelSkin"] = 3,
		["skin"] = 4,
		["rarity"] = 1,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "I", 5)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "I")
		end,
		["damage"] = 30,
		["speed"] = -5
	},
	["racerengineer"] = {
		["name"] = "Red Racer Engineer Uniform",
		["desc"] = "A suit worn by Engineers, Technicians, Mechanics and handy-men alike | +5 INTEL",
		["type"] = "body",
		["modelType"] = "group006",
		["itemModel"] = "models/thespireroleplay/items/clothes/group006.mdl",
		["itemModelSkin"] = 4,
		["skin"] = 4,
		["rarity"] = 1,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "I", 5)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "I")
		end,
		["damage"] = 30,
		["speed"] = -5
	},
	["repconnengineer"] = {
		["name"] = "Repconn Aerospace Engineer Uniform",
		["desc"] = "A suit worn by Aerospace Engineers for Repconn | +10 INTEL",
		["type"] = "body",
		["modelType"] = "group006",
		["itemModel"] = "models/thespireroleplay/items/clothes/group006.mdl",
		["itemModelSkin"] = 6,
		["skin"] = 6,
		["rarity"] = 5,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "I", 10)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "I")
		end,
		["damage"] = 30,
		["speed"] = -5
	},
	["robcoengineer"] = {
		["name"] = "Rob Co. Engineer Uniform",
		["desc"] = "A suit worn by Rob Co. Engineers | +10 INTEL",
		["type"] = "body",
		["modelType"] = "group006",
		["itemModel"] = "models/thespireroleplay/items/clothes/group006.mdl",
		["itemModelSkin"] = 6,
		["skin"] = 7,
		["rarity"] = 5,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "I", 10)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "I")
		end,
		["damage"] = 30,
		["speed"] = -5
	},
	["prewarformalwear"] = {
		["name"] = "Pre-War Formal Wear",
		["desc"] = "A formal Pre-War outfit commonly worn by those of wealthy status | +2 LCK",
		["type"] = "body",
		["modelType"] = "group014",
		["itemModel"] = "models/thespireroleplay/items/clothes/group014.mdl",
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "L", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "L")
		end,
		["damage"] = 15
	},
	["brownprewarformalwear"] = {
		["name"] = "Brown Pre-War Formal Wear",
		["desc"] = "A brown formal Pre-War outfit commonly worn by those of wealthy status | +2 LCK",
		["type"] = "body",
		["modelType"] = "group014",
		["itemModel"] = "models/thespireroleplay/items/clothes/group014.mdl",
		["itemModelSkin"] = 1,
		["skin"] = 1,
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "L", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "L")
		end,
		["damage"] = 15
	},
	["navyblueprewarformalwear"] = {
		["name"] = "Navy Blue Pre-War Formal Wear",
		["desc"] = "A Navy Blue formal Pre-War outfit commonly worn by those of wealthy status | +2 LCK",
		["type"] = "body",
		["modelType"] = "group014",
		["itemModel"] = "models/thespireroleplay/items/clothes/group014.mdl",
		["itemModelSkin"] = 2,
		["skin"] = 2,
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("")
			BuffStat(ply, item, "C", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "C")
		end,
		["damage"] = 15
	},
	["blackprewarformalwear"] = {
		["name"] = "Black Pre-War Formal Wear",
		["desc"] = "A Black formal Pre-War outfit commonly worn by those of wealthy status | +2 LCK",
		["type"] = "body",
		["modelType"] = "group014",
		["itemModel"] = "models/thespireroleplay/items/clothes/group014.mdl",
		["itemModelSkin"] = 3,
		["skin"] = 3,
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "L", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "L")
		end,
		["damage"] = 15
	},
	["crimsonprewarformalwear"] = {
		["name"] = "Crimson Pre-War Formal Wear",
		["desc"] = "A Crimson formal Pre-War outfit commonly worn by those of wealthy status | CC - FACTION ARMOR | +2 CHR",
		["type"] = "body",
		["modelType"] = "group014",
		["itemModel"] = "models/thespireroleplay/items/clothes/group014.mdl",
		["itemModelSkin"] = 4,
		["skin"] = 4,
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "C", 2)
			ply:falloutNotify("You are dressed as a member of CC")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "C")
			ply:falloutNotify("You are no longer dressed as a member of CC")
		end,
		["damage"] = 15
	},
	["darkblueprewarformalwear"] = {
		["name"] = "Dark Blue/Green Pre-War Formal Wear",
		["desc"] = "A dark blue formal Pre-War outfit (when worn by Male) and green dress (when worn by Female), however, always worn by those of wealthy status | VG/CC - FACTION ARMOR | | +2 LCK",
		["type"] = "body",
		["modelType"] = "group014",
		["itemModel"] = "models/thespireroleplay/items/clothes/group014.mdl",
		["itemModelSkin"] = 5,
		["skin"] = 5,
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "L", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "L")
		end,
		["damage"] = 15
	},
	["greenprewarformalwear"] = {
		["name"] = "Green/Yellow Pre-War Formal Wear",
		["desc"] = "A Green formal Pre-War outfit (when worn by Male) and yellow dress (when worn by Female), however, always worn by those of wealthy status | +2 LCK",
		["type"] = "body",
		["modelType"] = "group014",
		["itemModel"] = "models/thespireroleplay/items/clothes/group014.mdl",
		["itemModelSkin"] = 6,
		["skin"] = 6,
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "L", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "L")
		end,
		["damage"] = 15
	},
	["armor_vest"] = {
		["name"] = "Brown Pre-War Class Wear",
		["desc"] = "A Brown Pre-War Vest outfit commonly worn by those of middle class status | +2 CHR",
		["type"] = "body",
		["modelType"] = "group059",
		["itemModel"] = "models/thespireroleplay/items/clothes/group059.mdl",
		["rarity"] = 1,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "C", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "C")
		end,
		["damage"] = 10
	},
	["armor_grvest"] = {
		["name"] = "Green Pre-War Class Wear",
		["desc"] = "A Green Pre-War Vest outfit commonly worn by those of middle class status | +2 CHR | GR - FACTION NEUTRAL ARMOR",
		["type"] = "body",
		["modelType"] = "group059",
		["itemModel"] = "models/thespireroleplay/items/clothes/group059.mdl",
		["itemModelSkin"] = 2,
		["skin"] = 1,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are wearing a Faction Neutral clothing", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer wearing a Faction Neutral clothing", "ui/notify.mp3")
		end,
		["damage"] = 40
	},
	["armor_suit"] = {
		["name"] = "Pre-War Suit",
		["desc"] = "A nice suit worn often by Families Staff | CC/FAMILIES - FACTION NEUTRAL ARMOR",
		["type"] = "body",
		["modelType"] = "group027",
		["itemModel"] = "models/visualitygaming/fallout/prop/prewar3_ground.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are wearing a Faction Neutral clothing", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer wearing a Faction Neutral clothing", "ui/notify.mp3")
		end,
		["damage"] = 25
	},
	["familiesprewarsuit"] = {
		["name"] = "Families Red Suit",
		["desc"] = "A Red suit worn often by Families Staff | FAMILIES - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group027",
		["itemModel"] = "models/fallout/apparel/formalsuit.mdl",
		["skin"] = 2,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of House", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of House", "ui/notify.mp3")
		end,
		["damage"] = 25
	},
	["armor_raider"] = {
		["name"] = "Seeker Robes",
		["desc"] = "A Set of Robes often worn by Bandit Scouts",
		["type"] = "body",
		["modelType"] = "group015",
		["itemModel"] = "models/thespireroleplay/items/clothes/group015.mdl",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "P", 1)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "P")
		end,
		["damage"] = 40
	},
	["armor_pittraider"] = {
		["name"] = "Pitt Raider Armor",
		["desc"] = "A set of armor often worn by Paradise Raiders of the Wasteland | PARADISE - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group016",
		["itemModel"] = "models/fallout/apparel/minerarmorgo.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are wearing Paradise armor")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer wearing Paradise armor")
		end,
		["damage"] = 50,
		["speed"] = 10
	},
	["armor_fiendraider"] = {
		["name"] = "Fiend Sadist Armor",
		["desc"] = "A set of handmade raider clothing often worn by the morally questionable | FIEND - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group133",
		["itemModel"] = "models/fallout/apparel/raiderarmor01.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a Fiend")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a Fiend")
		end,
		["damage"] = 55,
		["speed"] = 10
	},
	["armor_blastmaster"] = { -- NOTE: This armor was "given" to them by us
		["name"] = "Fiend Blastmaster Armor",
		["desc"] = "A set of handmade raider clothing often worn by the morally questionable | FIEND - FACTION OFFICER ARMOR",
		["type"] = "body",
		["modelType"] = "group316",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a Fiend")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a Fiend")
		end,
		["itemModel"] = "models/fallout/apparel/raiderarmor01.mdl",
		["damage"] = 55,
		["speed"] = 10
	},
	["powerarmor_frame_armor"] = {
		["name"] = "Frame Armor",
		["desc"] = "A frame uniform worn under Power Armor",
		["type"] = "body",
		["modelType"] = "group113",
		["armsModel"] = "models/thespireroleplay/humans/group111/arms/male_arm.mdl",
		["itemModel"] = "models/fallout/apparel/bosunderarmor.mdl",
		["damage"] = 55,
		["speed"] = 0
	},
	["armor_vangraffth"] = {
		["name"] = "Advanced Leather Armor",
		["desc"] = "A set of quality-made Leather Armor designed for enhanced mobility | VG/CC - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group017",
		["itemModel"] = "models/thespireroleplay/items/clothes/group017.mdl",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "A", 1)
			ply:falloutNotify("You are wearing a Faction clothing", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "A")
			ply:falloutNotify("You are no longer wearing a Faction clothing", "ui/notify.mp3")
		end,
		["damage"] = 40,
		["speed"] = 13,
	},
	["roadwarrior"] = {
		["name"] = "Road Warrior Outfit",
		["desc"] = "A set of leather and scavenged-armor that smells of gas and dog hair",
		["type"] = "body",
		["modelType"] = "group112",
		["rarity"] = 3,
		["itemModel"] = "models/fallout/apparel/gscbandit.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You feel a lust for vengence surge within you")
		end,
		["OnRemove"] = function(ply, item)
		end,
		["damage"] = 40,
		["sex"] = "male"
	},
	["necrosiswarrior"] = {
		["name"] = "Necropolis Enforcer Uniform",
		["desc"] = "A leather set of armor often worn by the enforcers of Necropolis | NECROPOLIS - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group112",
		["rarity"] = 3,
		["itemModel"] = "models/fallout/apparel/gscbandit.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of Necropolis")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of Necropolis")
		end,
		["damage"] = 55,
	},
	["hitman"] = {
		["name"] = "Rebel Jacket",
		["desc"] = "A unique designer Jacket that's been adapated for Wasteland Life | Artifact Item",
		["type"] = "body",
		["path"] = "models/player/rebeljacket.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group111/arms/male_arm.mdl",
		["rarity"] = 5,
		["itemModel"] = "models/fallout/apparel/gscbandit.mdl",
		["damage"] = 70,
		["noFall"] = true,
		["OnWear"] = function(ply, item)
			ply.RRVetCooldown = ply.RRVetCooldown or CurTime()

			if (ply.RRVetCooldown > CurTime()) then return end
			ply:falloutNotify("The jackets weighs heavy on your shoulders . . .", "fallout/reveal.wav")
			ply.RRVetCooldown = CurTime() + 60
		end,
	},
	["armor_mercenary"] = {
		["name"] = "Mercenary Charmer Outfit",
		["desc"] = "A set of handmade armor often worn by charming Mercenaries | +2 CHR",
		["type"] = "body",
		["modelType"] = "group018",
		["itemModel"] = "models/thespireroleplay/items/clothes/group018.mdl",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "C", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "C")
		end,
		["damage"] = 40,
	},
	["armor_mercenaryvet"] = {
		["name"] = "Mercenary Veteran Outfit",
		["desc"] = "A set of handmade armor often worn by charming Mercenaries | +2 END",
		["type"] = "body",
		["modelType"] = "group019",
		["itemModel"] = "models/thespireroleplay/items/clothes/group019.mdl",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "E", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "E")
		end,
		["damage"] = 40,
	},
	["armor_mercoutfit"] = {
		["name"] = "Mercenary Troublemaker Outfit",
		["desc"] = "A set of handmade armor often worn by Troublemaking Mercenaries | +1 STR",
		["type"] = "body",
		["modelType"] = "group021",
		["itemModel"] = "models/thespireroleplay/items/clothes/group021.mdl",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 1)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
		end,
		["damage"] = 40,
	},
	["armor_mercgrunt"] = {
		["name"] = "Grunt Outfit",
		["desc"] = "A set of armor often worn by Mercenary Grunts",
		["type"] = "body",
		["modelType"] = "group020",
		["itemModel"] = "models/thespireroleplay/items/clothes/group020.mdl",
		["damage"] = 30,
		["speed"] = 10,
	},
	["mercgruntdirty"] = {
		["name"] = "Dirty Grunt Outfit",
		["desc"] = "A set of armor often worn by Mercenary Grunts",
		["type"] = "body",
		["modelType"] = "group020",
		["skin"] = 1,
		["itemModel"] = "models/thespireroleplay/items/clothes/group020.mdl",
		["itemModelSkin"] = 1,
		["damage"] = 30,
		["speed"] = 10,
	},
	["mercgruntbloody"] = {
		["name"] = "Bloody Grunt Outfit",
		["desc"] = "A set of armor often worn by Mercenary Grunts",
		["type"] = "body",
		["modelType"] = "group020",
		["skin"] = 2,
		["itemModel"] = "models/thespireroleplay/items/clothes/group020.mdl",
		["itemModelSkin"] = 2,
		["damage"] = 30,
		["speed"] = 10,
	},
	["armor_childd"] = {
		["name"] = "Waster Rags",
		["desc"] = "Dirty ragged clothing often worn by the squaters of the wasteland | COA - FACTION NEUTRAL ARMOR",
		["type"] = "body",
		["modelType"] = "group022",
		["itemModel"] = "models/fallout/apparel/slaverags_go.mdl",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "E", 1)
			ply:falloutNotify("You are wearing a Faction Neutral clothing", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "E")
			ply:falloutNotify("You are no longer wearing a Faction Neutral clothing", "ui/notify.mp3")
		end,
		["damage"] = 50,
		["speed"] = -7,
	},
	["armor_leathermki"] = {
		["name"] = "Tan Combat Armor MKII",
		["desc"] = "Improved Combat Armor designed for combat effectiveness",
		["type"] = "body",
		["modelType"] = "group024",
		["itemModel"] = "models/thespireroleplay/items/clothes/group053.mdl",
		["itemModelSkin"] = 2,
		["damage"] = 55,
		["speed"] = 5,
	},
	["armor_leathermkii"] = {
		["name"] = "Gold Combat Armor MKII",
		["desc"] = "Improved Combat Armor designed for combat effectiveness",
		["type"] = "body",
		["modelType"] = "group024",
		["skin"] = 1,
		["itemModel"] = "models/thespireroleplay/items/clothes/group053.mdl",
		["itemModelSkin"] = 2,
		["damage"] = 55,
		["speed"] = 5,
	},
	["armor_militarycombatmkii"] = {
		["name"] = "Blue Combat Armor MKII",
		["desc"] = "Improved Combat Armor designed for combat effectiveness",
		["type"] = "body",
		["modelType"] = "group024",
		["skin"] = 2,
		["itemModel"] = "models/thespireroleplay/items/clothes/group053.mdl",
		["itemModelSkin"] = 3,
		["damage"] = 55,
		["speed"] = 5,
	},
	["armor_combatarmormkii"] = {
		["name"] = "Green Combat Armor MKII",
		["desc"] = "Improved Combat Armor designed for combat effectiveness",
		["type"] = "body",
		["modelType"] = "group024",
		["skin"] = 3,
		["itemModel"] = "models/thespireroleplay/items/clothes/group053.mdl",
		["damage"] = 55,
		["speed"] = 5,
	},
	["armor_metalarmormkii"] = {
		["name"] = "Navy Blue Combat Armor MKII",
		["desc"] = "Improved Combat Armor designed for combat effectiveness",
		["type"] = "body",
		["modelType"] = "group024",
		["skin"] = 4,
		["itemModel"] = "models/thespireroleplay/items/clothes/group053.mdl",
		["itemModelSkin"] = 1,
		["damage"] = 55,
		["speed"] = 5,
	},
	["armor_metalarmormkii"] = {
		["name"] = "Sky Blue Combat Armor MKII",
		["desc"] = "Improved Combat Armor designed for combat effectiveness",
		["type"] = "body",
		["modelType"] = "group024",
		["skin"] = 5,
		["itemModel"] = "models/thespireroleplay/items/clothes/group053.mdl",
		["itemModelSkin"] = 1,
		["damage"] = 55,
		["speed"] = 5,
	},
	["redcombatarmor"] = {
		["name"] = "Crimson Combat Armor MKII",
		["desc"] = "Improved Combat Armor designed for combat effectiveness",
		["type"] = "body",
		["modelType"] = "group024",
		["skin"] = 6,
		["itemModel"] = "models/thespireroleplay/items/clothes/group053.mdl",
		["itemModelSkin"] = 3,
		["damage"] = 55,
		["speed"] = 5,
	},
	["armor_leathermemeII"] = {
		["name"] = "Violet Combat Armor MKII",
		["desc"] = "Improved Combat Armor designed for combat effectiveness",
		["type"] = "body",
		["modelType"] = "group024",
		["skin"] = 7,
		["itemModel"] = "models/thespireroleplay/items/clothes/group053.mdl",
		["itemModelSkin"] = 1,
		["damage"] = 55,
		["speed"] = 5,
	},
	["limecombatarmor"] = {
		["name"] = "Dark Green Combat Armor MKII",
		["desc"] = "Improved Combat Armor designed for combat effectiveness",
		["type"] = "body",
		["modelType"] = "group024",
		["skin"] = 8,
		["itemModel"] = "models/thespireroleplay/items/clothes/group053.mdl",
		["damage"] = 55,
		["speed"] = 5,
	},
	["vaultgang_male"] = {
		["name"] = "Vault Gang Jacket",
		["desc"] = "Woah slick, watch where you're going ye? | VT/BOOMER - FACTION NEUTRAL ARMOR",
		["itemModel"] = "models/fallout/apparel/vaultsuit.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group055/arms/male_arm.mdl",
		["path"] = "models/cgcclothing/humans/vaultgang/male.mdl",
		["rarity"] = 2,
		["type"] = "body",
		["damage"] = 35,
		["speed"] = 0,
		["sex"] = "male"
	},
	["vaultgang_female"] = {
		["name"] = "Vault Gang Jacket",
		["desc"] = "Woah slick, watch where you're going ye?",
		["itemModel"] = "models/fallout/apparel/vaultsuit.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group055/arms/female_arm.mdl",
		["path"] = "models/cgcclothing/humans/vaultgang/female.mdl",
		["rarity"] = 2,
		["type"] = "body",
		["damage"] = 35,
		["speed"] = 0,
		["sex"] = "female"
	},
	["boomerjacket_male"] = {
		["name"] = "Boomer Jacket",
		["desc"] = "A jacket outfit worn by Boomers | BOOMER - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/vaultsuit.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group055/arms/male_arm.mdl",
		["path"] = "models/cgcclothing/humans/vaultgang/male.mdl",
		["OnWear"] = function(ply, item)
				ply:falloutNotify("You are wearing a Boomer Faction Uniform", "ui/notify.mp3")
			end,
			["OnRemove"] = function(ply, item)
				ply:falloutNotify("You are no longer wearing Boomer Faction Uniform", "ui/notify.mp3")
			end,
		["rarity"] = 2,
		["type"] = "body",
		["damage"] = 60,
		["speed"] = 0,
		["sex"] = "male"
	},
	["boomerjacket_female"] = {
		["name"] = "Boomer Jacket",
		["desc"] = "A jacket outfit worn by Boomers | BOOMER - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/vaultsuit.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group055/arms/female_arm.mdl",
		["path"] = "models/cgcclothing/humans/vaultgang/female.mdl",
		["OnWear"] = function(ply, item)
				ply:falloutNotify("You are wearing a Boomer Faction Uniform", "ui/notify.mp3")
			end,
			["OnRemove"] = function(ply, item)
				ply:falloutNotify("You are no longer wearing Boomer Faction Uniform", "ui/notify.mp3")
			end,
		["rarity"] = 2,
		["type"] = "body",
		["damage"] = 60,
		["speed"] = 0,
		["sex"] = "female"
	},
	["greaser"] = {
		["name"] = "Greaser Outfit",
		["desc"] = "A slick leather jacket | AC - FACTION NEUTRAL ARMOR | +1 CHR / +1 LCK",
		["type"] = "body",
		["modelType"] = "group051",
		["skin"] = 1,
		["itemModel"] = "models/thespireroleplay/items/clothes/group051.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are wearing a Faction Neutral outfit", "ui/notify.mp3")
			BuffStat(ply, item, "C", 1)
			BuffStat(ply, item, "L", 1)
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer wearing a Faction Neutral outfit", "ui/notify.mp3")
			EndBuff(ply, item, "C")
			EndBuff(ply, item, "L")
		end,
		["damage"] = 25,
		["speed"] = 10,
	},
	["armor_kings"] = {
		["name"] = "Kings Outfit",
		["desc"] = "A leather jacket often worn by The Kings in New Vegas | +1 CHR / +1 LCK",
		["type"] = "body",
		["modelType"] = "group051",
		["itemModel"] = "models/thespireroleplay/items/clothes/group051.mdl",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "C", 1)
			BuffStat(ply, item, "L", 1)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "C")
			EndBuff(ply, item, "L")
		end,
		["damage"] = 25,
		["speed"] = 10,
	},
	["armor_leathermeme"] = {
		["name"] = "Basic Leather Armor",
		["desc"] = "Leather Armor handmade for mobility | +1 AGIL / +1 END",
		["type"] = "body",
		["modelType"] = "group052",
		["itemModel"] = "models/thespireroleplay/items/clothes/group052.mdl",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "A", 1)
			BuffStat(ply, item, "E", 1)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "A")
			EndBuff(ply, item, "E")
		end,
		["damage"] = 35,
		["speed"] = 8,
	},
	["armor_combatarmormkiii"] = {
		["name"] = "Green Combat Armor MKIII",
		["desc"] = "Highly Advanced & Well made Combat Armor designed for effectiveness",
		["type"] = "body",
		["modelType"] = "group053",
		["itemModel"] = "models/thespireroleplay/items/clothes/group053.mdl",
		["damage"] = 63,
	},
	["armor_militarycombatmkiii"] = {
		["name"] = "Dark Combat Armor MKIII",
		["desc"] = "Highly Advanced & Well made Combat Armor designed for effectiveness",
		["type"] = "body",
		["modelType"] = "group053",
		["skin"] = 1,
		["itemModel"] = "models/thespireroleplay/items/clothes/group053.mdl",
		["itemModelSkin"] = 1,
		["damage"] = 63,
	},
	["armor_leathermkiii"] = {
		["name"] = "Brass Combat Armor MKIII",
		["desc"] = "Highly Advanced & Well made Combat Armor designed for effectiveness",
		["type"] = "body",
		["modelType"] = "group053",
		["skin"] = 2,
		["itemModel"] = "models/thespireroleplay/items/clothes/group053.mdl",
		["itemModelSkin"] = 2,
		["damage"] = 63,
	},
	["armor_metalarmormkiii"] = {
		["name"] = "Platinum Combat Armor MKIII",
		["desc"] = "Highly Advanced & Well made Combat Armor designed for effectiveness",
		["type"] = "body",
		["modelType"] = "group053",
		["skin"] = 3,
		["itemModel"] = "models/thespireroleplay/items/clothes/group053.mdl",
		["itemModelSkin"] = 3,
		["damage"] = 63,
	},
	["mercveterancaged"] = {
		["name"] = "Mercenary Caged Veteran Outfit",
		["desc"] = "A set of handmade armor often worn by Veteran Mercenaries | +1 AGL / +1 END",
		["type"] = "body",
		["modelType"] = "group060",
		["itemModel"] = "models/thespireroleplay/items/clothes/group060.mdl",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "E", 1)
			BuffStat(ply, item, "A", 1)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "E")
			EndBuff(ply, item, "A")
		end,
		["damage"] = 40,
	},
	["armor_mercenaryad"] = {
		["name"] = "Crimson Caravan Employee Clothing",
		["desc"] = "Armor often worn by Bodyguards and Employees of the Crimson Caravan | CC - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group061",
		["itemModel"] = "models/thespireroleplay/items/clothes/group061.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of CC", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of CC", "ui/notify.mp3")
		end,
		["damage"] = 40,
	},
	["armor_trader"] = {
		["name"] = " Trader Outfit",
		["desc"] = "Outfit worn by people with good skills sets, outfit is equipped with all sorts of handyman tools!",
		["type"] = "body",
		["modelType"] = "group104",
		["itemModel"] = "models/thespireroleplay/items/clothes/group104.mdl",
		["damage"] = 40,
	},
	["armor_labcoattttt"] = {
		["name"] = "Blue Scientist Scrubs",
		["desc"] = "The scrubs are a set of dark blue Pre-War scientist scrubs that have a belt and collar | +8 INTEL | TT - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group119",
		["rarity"] = 3,
		["itemModel"] = "models/thespireroleplay/items/clothes/group014.mdl",
		["itemModelSkin"] = 5,
		["OnWear"] = function(ply, item)
				BuffStat(ply, item, "I", 8)
				ply:falloutNotify("You are wearing a TT Faction Uniform", "ui/notify.mp3")
			end,
			["OnRemove"] = function(ply, item)
				EndBuff(ply, item, "I")
				ply:falloutNotify("You are no longer wearing TT Faction Uniform", "ui/notify.mp3")
			end,
		["damage"] = 40,
	},
	["scientistscrubsa"] = {
		["name"] = "Green Scientist Scrubs",
		["desc"] = "The scrubs are a set of green Pre-War scientist scrubs that have a belt and collar | +8 INTEL | TT - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group119",
		["rarity"] = 3,
		["itemModel"] = "models/thespireroleplay/items/clothes/group007.mdl",
		["itemModelSkin"] = 6,
		["skin"] = 1,
		["OnWear"] = function(ply, item)
				BuffStat(ply, item, "I", 8)
				ply:falloutNotify("You are wearing a TT Faction Uniform", "ui/notify.mp3")
			end,
			["OnRemove"] = function(ply, item)
				EndBuff(ply, item, "I")
				ply:falloutNotify("You are no longer wearing TT Faction Uniform", "ui/notify.mp3")
			end,
		["damage"] = 40,
	},
	["armor_labcoatttt"] = {
		["name"] = "Red Scientist Scrubs",
		["desc"] = "The scrubs are a set of red Pre-War scientist scrubs that have a belt and collar | +8 INTEL | TT - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group119",
		["itemModel"] = "models/thespireroleplay/items/clothes/group007.mdl",
		["itemModelSkin"] = 4,
		["skin"] = 2,
		["rarity"] = 3,
		["OnWear"] = function(ply, item)
				BuffStat(ply, item, "I", 8)
				ply:falloutNotify("You are wearing a TT Faction Uniform", "ui/notify.mp3")
			end,
			["OnRemove"] = function(ply, item)
				EndBuff(ply, item, "I")
				ply:falloutNotify("You are no longer wearing TT Faction Uniform", "ui/notify.mp3")
			end,
		["damage"] = 40,
	},
	["scientistscrubsc"] = {
		["name"] = "White Scientist Scrubs",
		["desc"] = "The scrubs are a set of white Pre-War scientist scrubs that have a belt and collar | +8 INTEL  | TT - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group119",
		["itemModel"] = "models/thespireroleplay/items/clothes/group007.mdl",
		["itemModelSkin"] = 3,
		["skin"] = 3,
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
				BuffStat(ply, item, "I", 8)
				ply:falloutNotify("You are wearing a TT Faction Uniform", "ui/notify.mp3")
			end,
			["OnRemove"] = function(ply, item)
				EndBuff(ply, item, "I")
				ply:falloutNotify("You are no longer wearing TT Faction Uniform", "ui/notify.mp3")
			end,
		["damage"] = 40,
	},
	["armor_grcombat"] = {
		["name"] = "Gun Runner Security Uniform",
		["desc"] = "Armored Security Outfit for those who guard the Gun Runners and their supplies | GR - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group118",
		["itemModel"] = "models/thespireroleplay/items/clothes/group106.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of GR", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of GR", "ui/notify.mp3")
		end,
		["damage"] = 50,
	},
	["armor_grcombatsr"] = {
		["name"] = "Gun Runner Senior Security Uniform",
		["desc"] = "Armored Security Outfit for those the Senior Employees who guard the Gun Runners and their supplies | GR - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group118",
		["itemModel"] = "models/thespireroleplay/items/clothes/group106.mdl",
		["skin"] = 1,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of GR", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of GR", "ui/notify.mp3")
		end,
		["damage"] = 55,
	},
	["armor_vaultsec"] = {
		["name"] = "Vault-Tec Security Uniform",
		["desc"] = "Armored Security Outfit worn by Vault-Tec Security Personnel | VT - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group118",
		["itemModel"] = "models/fallout/apparel/vaultsecurity.mdl",
		["skin"] = 2,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of VT", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of VT", "ui/notify.mp3")
		end,
		["damage"] = 50,
	},
	["armor_vaultsecsr"] = {
		["name"] = "Vault-Tec Senior Security Uniform",
		["desc"] = "Armored Security Outfit worn by Senior Vault-Tec Security Personnel | VT - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group118",
		["itemModel"] = "models/fallout/apparel/vaultsecurity.mdl",
		["skin"] = 2,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of VT", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of VT", "ui/notify.mp3")
		end,
		["damage"] = 55,
	},
	["memphiskidoutfit"] = {
		["name"] = "Memphis Kid Outfit",
		["desc"] = "A typically greaser outfit - White shirt and jeans.",
		["type"] = "body",
		["modelType"] = "group101",
		["itemModel"] = "models/thespireroleplay/items/clothes/group101.mdl",
		["damage"] = 40,
	},
	["armor_greatkhansimpleoutfit"] = {
		["name"] = "Great Khan Vest",
		["desc"] = "A Leather vest and slightly armored pants given to Great Khans chem runners | Great Khans - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group117",
		["itemModel"] = "models/thespireroleplay/items/clothes/group021.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of GK", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of GK", "ui/notify.mp3")
		end,
		["damage"] = 58,
	},
	["armor_greatkhanboss"] = {
		["name"] = "Great Khan Flame Vest",
		["desc"] = "A regular leather vest and slightly armored pants worn by Great Khan combatants | Great Khans - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group116",
		["itemModel"] = "models/thespireroleplay/items/clothes/group021.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of GK", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of GK", "ui/notify.mp3")
		end,
		["damage"] = 63,
	},
	["armor_ncrpatrolrangertwo"] = {
		["name"] = "NCR Tan Ranger Casuals",
		["desc"] = "A set of wild clothing often worn by heroic cowboy-types | NCR - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group058",
		["itemModel"] = "models/thespireroleplay/items/clothes/group058.mdl",
		["rarity"] = 3,
		["bodygroup"] = {1,1},
		["OnWear"] = function(ply, item)
				BuffStat(ply, item, "P", 1)
				BuffStat(ply, item, "E", 2)
				ply:falloutNotify("You are dressed as a member of the NCR", "ui/notify.mp3")
			end,
			["OnRemove"] = function(ply, item)
				EndBuff(ply, item, "P")
				EndBuff(ply, item, "E")
				ply:falloutNotify("You are no longer dressed as a member of the NCR", "ui/notify.mp3")
			end,
		["damage"] = 64,
	},
	["armor_ncrrealranger"] = {
		["name"] = "NCR Brown Ranger Casuals",
		["desc"] = "A set of wild clothing often worn by heroic cowboy-types | NCR - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group058",
		["itemModel"] = "models/thespireroleplay/items/clothes/group058.mdl",
		["itemModelSkin"] = 1,
		["rarity"] = 3,
		["bodygroup"] = {1,1},
		["skin"] = 1,
		["OnWear"] = function(ply, item)
				BuffStat(ply, item, "P", 1)
				BuffStat(ply, item, "E", 2)
				ply:falloutNotify("You are dressed as a member of the NCR", "ui/notify.mp3")
			end,
			["OnRemove"] = function(ply, item)
				EndBuff(ply, item, "P")
				EndBuff(ply, item, "E")
				ply:falloutNotify("You are no longer dressed as a member of the NCR", "ui/notify.mp3")
			end,
		["damage"] = 64,
	},
	["dustycrangerb"] = {
		["name"] = "NCR Light Ranger Casuals",
		["desc"] = "A set of wild clothing often worn by heroic cowboy-types | NCR - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group058",
		["itemModel"] = "models/thespireroleplay/items/clothes/group021.mdl",
		["itemModelSkin"] = 2,
		["rarity"] = 3,
		["bodygroup"] = {1,1},
		["skin"] = 2,
		["OnWear"] = function(ply, item)
				BuffStat(ply, item, "P", 1)
				BuffStat(ply, item, "E", 2)
				ply:falloutNotify("You are dressed as a member of the NCR", "ui/notify.mp3")
			end,
			["OnRemove"] = function(ply, item)
				EndBuff(ply, item, "P")
				EndBuff(ply, item, "E")
				ply:falloutNotify("You are no longer dressed as a member of the NCR", "ui/notify.mp3")
			end,
		["damage"] = 64,
	},
	["cowboycasuals"] = {
		["name"] = "Blue Cowboy Casuals ",
		["desc"] = "A set of wild clothing often worn by heroic cowboy-types",
		["type"] = "body",
		["modelType"] = "group058",
		["itemModel"] = "models/thespireroleplay/items/clothes/group013.mdl",
		["itemModelSkin"] = 1,
		["rarity"] = 1,
		["skin"] = 3,
		["damage"] = 40,
	},
	["cowboycasualsa"] = {
		["name"] = "Navy Cowboy Casuals ",
		["desc"] = "A set of wild clothing often worn by heroic cowboy-types",
		["type"] = "body",
		["modelType"] = "group058",
		["itemModel"] = "models/thespireroleplay/items/clothes/group013.mdl",
		["itemModelSkin"] = 1,
		["rarity"] = 1,
		["skin"] = 4,
		["damage"] = 40,
	},
	["cowboycasualsb"] = {
		["name"] = "Dusty Cowboy Casuals ",
		["desc"] = "A set of wild clothing often worn by heroic cowboy-types",
		["type"] = "body",
		["modelType"] = "group058",
		["itemModel"] = "models/thespireroleplay/items/clothes/group013.mdl",
		["rarity"] = 1,
		["skin"] = 5,
		["damage"] = 40,
	},
	["cowboycasualsc"] = {
		["name"] = "Checkered Cowboy Casuals ",
		["desc"] = "A set of wild clothing often worn by heroic cowboy-types",
		["type"] = "body",
		["modelType"] = "group058",
		["itemModel"] = "models/thespireroleplay/items/clothes/group013.mdl",
		["itemModelSkin"] = 4,
		["rarity"] = 1,
		["skin"] = 6,
		["damage"] = 40,
	},
	["cowboycasualsd"] = {
		["name"] = "Jaded Cowboy Casuals ",
		["desc"] = "A set of wild clothing often worn by heroic cowboy-types",
		["type"] = "body",
		["modelType"] = "group058",
		["itemModel"] = "models/thespireroleplay/items/clothes/group013.mdl",
		["itemModelSkin"] = 4,
		["rarity"] = 1,
		["skin"] = 7,
		["damage"] = 40,
	},
	["cowboycasualse"] = {
		["name"] = "Dirty Cowboy Casuals ",
		["desc"] = "A set of wild clothing often worn by heroic cowboy-types",
		["type"] = "body",
		["modelType"] = "group058",
		["itemModel"] = "models/thespireroleplay/items/clothes/group013.mdl",
		["rarity"] = 1,
		["skin"] = 8,
		["damage"] = 40,
	},
	["cowboycasualsf"] = {
		["name"] = "Worn Cowboy Casuals ",
		["desc"] = "A set of wild clothing often worn by heroic cowboy-types",
		["type"] = "body",
		["modelType"] = "group058",
		["itemModel"] = "models/thespireroleplay/items/clothes/group013.mdl",
		["rarity"] = 1,
		["skin"] = 9,
		["damage"] = 40,
	},
	["cowboycasualsg"] = {
		["name"] = "Red Cowboy Casuals ",
		["desc"] = "A set of wild clothing often worn by heroic cowboy-types",
		["type"] = "body",
		["modelType"] = "group058",
		["itemModel"] = "models/thespireroleplay/items/clothes/group013.mdl",
		["rarity"] = 2,
		["skin"] = 11,
		["damage"] = 40,
	},
	["cowboycasualsx"] = {
		["name"] = "Worn Checkered Cowboy Casuals ",
		["desc"] = "A set of wild clothing often worn by heroic cowboy-types",
		["type"] = "body",
		["modelType"] = "group058",
		["itemModel"] = "models/thespireroleplay/items/clothes/group013.mdl",
		["itemModelSkin"] = 2,
		["rarity"] = 2,
		["skin"] = 12,
		["damage"] = 40,
	},
	["cowboycasualsz"] = {
		["name"] = "Tan Checkered Cowboy Casuals ",
		["desc"] = "A set of wild clothing often worn by heroic cowboy-types",
		["type"] = "body",
		["modelType"] = "group058",
		["itemModel"] = "models/thespireroleplay/items/clothes/group013.mdl",
		["rarity"] = 2,
		["skin"] = 13,
		["damage"] = 40,
	},
	["researcherclothing"] = {
		["name"] = "Researcher Clothing",
		["desc"] = "A lab coat and fitting atire often worn by researchers and scholars.",
		["type"] = "body",
		["modelType"] = "group121",
		["itemModel"] = "models/thespireroleplay/items/clothes/group007.mdl",
		["rarity"] = 3,
		["OnWear"] = function(ply, item)
				BuffStat(ply, item, "I", 4)
			end,
			["OnRemove"] = function(ply, item)
				EndBuff(ply, item, "I")
			end,
		["damage"] = 35,
	},
	["researcherclothinga"] = {
		["name"] = "Pre-War Researcher Clothing",
		["desc"] = "A pre-war lab coat and fitting atire often worn by researchers and scholars.",
		["type"] = "body",
		["modelType"] = "group121",
		["itemModel"] = "models/thespireroleplay/items/clothes/group007.mdl",
		["skin"] = 1,
		["rarity"] = 3,
		["OnWear"] = function(ply, item)
				BuffStat(ply, item, "I", 4)
			end,
			["OnRemove"] = function(ply, item)
				EndBuff(ply, item, "I")
			end,
		["damage"] = 35,
	},
	["researcherclothingx"] = {
		["name"] = "Nobel Peace Lab Coat",
		["desc"] = "A pre-war lab coat worn by a now long dead famous researcher.",
		["type"] = "body",
		["modelType"] = "group121",
		["itemModel"] = "models/thespireroleplay/items/clothes/group007.mdl",
		["itemModelSkin"] = 3,
		["skin"] = 2,
		["rarity"] = 5,
		["OnWear"] = function(ply, item)
				BuffStat(ply, item, "I", 15)
			end,
			["OnRemove"] = function(ply, item)
				EndBuff(ply, item, "I")
			end,
		["damage"] = 35,
	},
	["researcherclothingc"] = {
		["name"] = "Gray Researcher Coat",
		["desc"] = "A pre-war lab coat and fitting atire often worn by researchers and scholars | FOLLOWERS - FACTION NUETRAL ARMOR",
		["type"] = "body",
		["modelType"] = "group121",
		["itemModel"] = "models/thespireroleplay/items/clothes/group007.mdl",
		["itemModelSkin"] = 3,
		["skin"] = 3,
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
				BuffStat(ply, item, "I", 6)
			end,
			["OnRemove"] = function(ply, item)
				EndBuff(ply, item, "I")
			end,
		["damage"] = 35,
	},
	["armor_lobot"] = {
		["name"] = "Lobotomite Pull-Ups",
		["desc"] = "A set of clothing often worn by those who know how to throw a rock but unable to find where they threw it  | +3 STR / -20 INT | TT - FACTION NEUTRAL ARMOR",
		["type"] = "body",
		["modelType"] = "group023",
		["itemModel"] = "models/fallout/apparel/raiderarmor03.mdl",
		["rarity"] = 1,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 3)
			BuffStat(ply, item, "I", -20)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
			EndBuff(ply, item, "I")
		end,
		["damage"] = 55,
		["speed"] = -5
	},

	-- CUSTOM ARMORS --
	["lordoflightcombatarmor"] = {
		["name"] = "Regiis Combat Armor MKIII",
		["desc"] = "Highly Advanced & Well made Combat Armor designed for effectiveness | Female Armor | REGIIS - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group077",
		["sex"] = "female",
		["itemModel"] = "models/thespireroleplay/items/clothes/group053.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a Lord of Light member", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are dressed as a Lord of Light member", "ui/notify.mp3")
		end,
		["itemModelSkin"] = 3,
		["damage"] = 70,
	},
	["jackal_metalarmor"] = {
		["name"] = "Forged Metal Armor",
		["desc"] = "A set of Metal Armor often worn by thugs | +2 STR | FORGED - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group011",
		["itemModel"] = "models/fallout/apparel/metalarmor.mdl",
		["skin"] = 1,
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a FORGED", "ui/notify.mp3")
			BuffStat(ply, item, "S", 2)
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a FORGED", "ui/notify.mp3")
			EndBuff(ply, item, "S")
		end,
		["damage"] = 70,
		["speed"] = -8,
	},
	["jackals_combatarmortanker"] = {
		["name"] = "Forged Tanker Combat Armor",
		["desc"] = "Highly Advanced & Well made Combat Armor designed for effectiveness | FORGED - FACTION ARMOR",
		["path"] = "models/cgcclothing/humans/raidercombat04/male.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group055/arms/male_arm.mdl",
		["itemModel"] = "models/thespireroleplay/items/clothes/group053.mdl",
		["rarity"] = 3,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a Forged", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a Forged", "ui/notify.mp3")
		end,
		["damage"] = 65,
		["speed"] = -14,
		["sex"] = "male"
	},
	["jackalsf_combatarmortanker"] = {
		["name"] = "Forged Tanker Combat Armor",
		["desc"] = "Highly Advanced & Well made Combat Armor designed for effectiveness | Forged - FACTION ARMOR",
		["path"] = "models/cgcclothing/humans/raidercombat04/female.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group055/arms/male_arm.mdl",
		["itemModel"] = "models/thespireroleplay/items/clothes/group053.mdl",
		["rarity"] = 3,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a Forged", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a Forged", "ui/notify.mp3")
		end,
		["damage"] = 65,
		["speed"] = -14,
		["sex"] = "female"
	},
	["jackals_combatarmorrunner"] = {
		["name"] = "Forged Runner Combat Armor",
		["desc"] = "Highly Advanced & Well made Combat Armor designed for effectiveness | Forged - FACTION ARMOR",
		["path"] = "models/cgcclothing/humans/raidercombat10/male.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group055/arms/male_arm.mdl",
		["itemModel"] = "models/thespireroleplay/items/clothes/group053.mdl",
		["rarity"] = 3,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a Forged", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a Forged", "ui/notify.mp3")
		end,
		["damage"] = 53,
		["speed"] = 10,
		["sex"] = "male"
	},
	["jackalfs_combatarmorrunner"] = {
		["name"] = "Forged Runner Combat Armor",
		["desc"] = "Highly Advanced & Well made Combat Armor designed for effectiveness | Forged - FACTION ARMOR",
		["path"] = "models/cgcclothing/humans/raidercombat10/female.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group055/arms/female_arm.mdl",
		["itemModel"] = "models/thespireroleplay/items/clothes/group053.mdl",
		["rarity"] = 3,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a Forged", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a Forged", "ui/notify.mp3")
		end,
		["damage"] = 53,
		["speed"] = 10,
		["sex"] = "female"
	},
	["militia_road_riot"] = {
		["name"] = "Militia Road Riot Armor",
		["desc"] = "A highly customized suit of combat armor refurbished from dead NCR Veteran Rangers | MILITIA - FACTION ARMOR",
		["path"] = "models/cgcclothing/humans/militia_courier/militia_riot.mdl",
		["armsModel"] = "models/lazarusroleplay/thespireroleplay/humans/group122/arms/male_arm.mdl",
		["itemModel"] = "models/fallout/apparel/centuriongo.mdl",
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of The Militia", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of The Militia", "ui/notify.mp3")
		end,
		["damage"] = 70,
		["speed"] = 0,
	},
	["militia_combatarmor"] = {
		["name"] = "Militia Road King Armor",
		["desc"] = "A highly customized leather jacket and combat armor custom trimmed by The Militia faction | MILITIA - FACTION ARMOR",
		["path"] = "models/cgcclothing/humans/geonox/male.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group006/arms/male_arm.mdl",
		["itemModel"] = "models/thespireroleplay/items/clothes/group051.mdl",
		["rarity"] = 4,
		["bodygroup"] = {1, 1},
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of The Militia", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of The Militia", "ui/notify.mp3")
		end,
		["damage"] = 70,
		["speed"] = 0,
		["sex"] = "male"
	},
	["vestmilitia_combatarmor"] = {
		["name"] = "Militia Vested Road King Armor",
		["desc"] = "A highly customized leather jacket and combat armor custom trimmed by The Militia faction | MILITIA - FACTION ARMOR",
		["path"] = "models/cgcclothing/humans/geonox/male.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group006/arms/male_arm.mdl",
		["itemModel"] = "models/thespireroleplay/items/clothes/group051.mdl",
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of The Militia", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of The Militia", "ui/notify.mp3")
		end,
		["damage"] = 70,
		["speed"] = 0,
		["sex"] = "male"
	},
	["militia_combatarmor_female"] = {
		["name"] = "Militia Road King Armor",
		["desc"] = "A highly customized leather jacket and combat armor custom trimmed by The Militia faction | MILITIA - FACTION ARMOR",
		["path"] = "models/cgcclothing/humans/geonox/female.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group006/arms/male_arm.mdl",
		["itemModel"] = "models/thespireroleplay/items/clothes/group051.mdl",
		["rarity"] = 4,
		["bodygroup"] = {1, 1},
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of The Militia", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of The Militia", "ui/notify.mp3")
		end,
		["damage"] = 70,
		["speed"] = 0,
		["sex"] = "female"
	},
	["vestmilitia_combatarmor_female"] = {
		["name"] = "Militia Vested Road King Armor",
		["desc"] = "A highly customized leather jacket and combat armor custom trimmed by The Militia faction | MILITIA - FACTION ARMOR",
		["path"] = "models/cgcclothing/humans/geonox/female.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group006/arms/male_arm.mdl",
		["itemModel"] = "models/thespireroleplay/items/clothes/group051.mdl",
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of The Militia", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of The Militia", "ui/notify.mp3")
		end,
		["damage"] = 70,
		["speed"] = 0,
		["sex"] = "female"
	},
	["militia_combatarmorwarrior"] = {
		["name"] = "Militia Road Warrior Armor",
		["desc"] = "A highly customized leather jacket and combat armor custom trimmed by The Militia faction | MILITIA - FACTION ARMOR",
		["path"] = "models/cgcclothing/humans/roadfighter/male.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group122/arms/female_arm.mdl",
		["itemModel"] = "models/thespireroleplay/items/clothes/group051.mdl",
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of The Militia", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of The Militia", "ui/notify.mp3")
		end,
		["damage"] = 65,
		["speed"] = 0,
	},
	["mm_general"] = {
		["name"] = "Minutemen General Uniform",
		["desc"] = "A jacket and clothing that is worn by the Minutemen Officers | MM - FACTION OFFICER ARMOR",
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["path"] = "models/player/prestonmeme.mdl",
		["itemModel"] = "models/fallout/apparel/raiderarmor03.mdl",
		["armsModel"] = "models/lazarusroleplay/thespireroleplay/humans/group122/arms/male_arm.mdl",
		["rarity"] = 3,
		["type"] = "body",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a Minuteman", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a Minuteman", "ui/notify.mp3")
		end,
		["damage"] = 63
	},
	["mmsol_soldier"] = { -- Custom Order by 'Shadix Wildfang#9077'
		["name"] = "Minutemen Soldier Uniform",
		["desc"] = "A uniform worn by soldiers of the U.T.C.R. | MM - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/leatherarmor.mdl",
		["modelType"] = "group311",
		["maleSuffix"] = "",
		["femaleSuffix"] = "",
		["rarity"] = 3,
		["type"] = "body",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a Minuteman", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a Minuteman", "ui/notify.mp3")
		end,
		["damage"] = 60
	},
	["rr_armor"] = {
		["name"] = "Railroad Heavy Armor",
		["desc"] = "A full body armor jacket worn by combatants of the Railroad | RAILROAD - FACTION ARMOR",
		["itemModel"] = "models/visualitygaming/fallout/prop/pimpmyscarf.mdl",
		["path"] = "models/player/armoredcoat.mdl",
		["itemModel"] = "models/fallout/apparel/gscexo.mdl",
		["armsModel"] = "models/lazarusroleplay/thespireroleplay/humans/group122/arms/male_arm.mdl",
		["rarity"] = 3,
		["type"] = "body",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the Railroad", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as member of the Railroad", "ui/notify.mp3")
		end,
		["damage"] = 65
	},
	["cc_serviceclothing_male"] = { -- Has duplicate version (below) due to original misconfiguration
		["name"] = "Crimson Caravan Manager Uniform",
		["desc"] = "A set of bullet resistant clothing often worn by Crimson Caravan Management | CC - FACTION ARMOR",
		["path"] = "models/cgcclothing/humans/graham/male.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["itemModel"] = "models/thespireroleplay/items/clothes/group051.mdl",
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the Crimson Caravan", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the Crimson Caravan", "ui/notify.mp3")
		end,
		["damage"] = 65,
		["speed"] = 0
	},
	["cc_serviceclothing_female"] = { -- Has duplicate version (above) due to original misconfiguration
		["name"] = "Crimson Caravan Manager Uniform",
		["desc"] = "A set of bullet resistant clothing often worn by Crimson Caravan Management | CC - FACTION ARMOR",
		["path"] = "models/cgcclothing/humans/graham/male.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group123/arms/female_arm.mdl",
		["itemModel"] = "models/thespireroleplay/items/clothes/group051.mdl",
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the Crimson Caravan", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the Crimson Caravan", "ui/notify.mp3")
		end,
		["damage"] = 65,
		["speed"] = 0
	},
	["families_prewarwear"] = {
		["name"] = "Families Formal Suit",
		["desc"] = "A set of bullet resistant clothing often worn by Casino Operators | FAMILIES - FACTION ARMOR",
		["path"] = "models/cgcclothing/humans/prewar/male.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group123/arms/female_arm.mdl",
		["itemModel"] = "models/visualitygaming/fallout/prop/prewar3_ground.mdl",
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the Families", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the Families", "ui/notify.mp3")
		end,
		["damage"] = 65,
		["speed"] = 0,
		["sex"] = "male"
	},
	["families_prewarwearfe"] = {
		["name"] = "Families Formal Suit",
		["desc"] = "A set of bullet resistant clothing often worn by Casino Operators | FAMILIES - FACTION ARMOR",
		["path"] = "models/cgcclothing/humans/prewar/female.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["itemModel"] = "models/visualitygaming/fallout/prop/prewar3_ground.mdl",
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the Families", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the Families", "ui/notify.mp3")
		end,
		["damage"] = 65,
		["speed"] = 0,
		["sex"] = "female"
	},
	["ncrreconghillie"] = {
		["name"] = "NCR Recon Ghillie Suit",
		["desc"] = "A Ghillie suit used for and by recon or special operations | ncrmantle - FACTION ARMOR",
		["path"] = "models/cgcclothing/humans/reconsniper/male.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["itemModel"] = "models/thespireroleplay/items/clothes/group058.mdl",
		["itemModelSkin"] = 2,
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["damage"] = 68,
		["speed"] = 0,
	},
	["exodus_combatarmor"] = { -- Custom order | NOTE: Duplicate of below due to misconfig | FIXME: Has female variant, needs fixed directory
		["name"] = "Order of the Eternal Abyss Combat Armor",
		["desc"] = "A highly advanced combat armor worn by the Order of the Eternal Abyss faction | EA - FACTION ARMOR",
		["modelType"] = "group516",
		--["armsModel"] = "models/thespireroleplay/humans/group012/arms/male_arm.mdl",
		["itemModel"] = "models/fallout/apparel/centuriongo.mdl",
		["rarity"] = 3,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of EA", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of EA", "ui/notify.mp3")
		end,
		["damage"] = 60,
	},
	["exodus_combatarmorfe"] = { -- Custom order | NOTE: Duplicate of above due to misconfig | FIXME: Has female variant, needs fixed directory
		["name"] = "Order of the Eternal Abyss Combat Armor",
		["desc"] = "A highly advanced combat armor worn by the Order of the Eternal Abyss faction | EA - FACTION ARMOR",
		["modelType"] = "group516",
		--["armsModel"] = "models/thespireroleplay/humans/group012/arms/male_arm.mdl",
		["itemModel"] = "models/fallout/apparel/centuriongo.mdl",
		["rarity"] = 3,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of EA", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of EA", "ui/notify.mp3")
		end,
		["damage"] = 60
	},

	--- POWER ARMOR ---
	["t45dpowerarmor"] = {
		["name"] = "T-45d Power Armor",
		["desc"] = "A set of T-45d Power Armor",
		["type"] = "body",
		["modelType"] = "group056",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group111/arms/male_arm.mdl",
		["rarity"] = 3,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -20
	},
	["armor_t45-dblack"] = { -- 5.0 Community Update
		["name"] = "T-45d Black Power Armor",
		["desc"] = "A set of black T-45d Power Armor",
		["type"] = "body",
		["path"] = "models/cgcclothing/t45/body.mdl",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["armsModel"] = false,
		["rarity"] = 3,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -20
	},
	["t45dpowerarmor_rusted"] = { -- 5.0 Community Update
		["name"] = "T-45d Rusty Power Armor",
		["desc"] = "A set of rusted T-45d Power Armor",
		["type"] = "body",
		["path"] = "models/cgcclothing/t45/body.mdl",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["armsModel"] = false,
		["skin"] = 1,
		["rarity"] = 3,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -20
	},
	["armor_t45-doutcast"] = { -- 5.0 Community Update
		["name"] = "T-45d Outcast Power Armor",
		["desc"] = "A set of T-45d Power Armor worn by members of the splinter cell known as the Outcasts",
		["type"] = "body",
		["path"] = "models/cgcclothing/t45/body.mdl",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["armsModel"] = false,
		["skin"] = 2,
		["rarity"] = 3,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -20
	},
	["t45dpowerarmor_camo"] = { -- 5.0 Community Update
		["name"] = "T-45d Camo Power Armor",
		["desc"] = "A set of army issue T-45d Power Armor | GUNNERS - FACTION ARMOR",
		["type"] = "body",
		["path"] = "models/cgcclothing/t45/body.mdl",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["armsModel"] = false,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the Gunners", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the Gunners", "ui/notify.mp3")
		end,
		["skin"] = 3,
		["rarity"] = 3,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -20
	},
	["armor_t45-dblue"] = { -- 5.0 Community Update
		["name"] = "T-45d Blue Power Armor",
		["desc"] = "A set of blue T-45d Power Armor",
		["type"] = "body",
		["path"] = "models/cgcclothing/t45/body.mdl",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["armsModel"] = false,
		["skin"] = 5,
		["rarity"] = 3,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -20
	},
	["armor_t45-dwhite"] = { -- 5.0 Community Update
		["name"] = "T-45d White Power Armor",
		["desc"] = "A set of white T-45d Power Armor",
		["type"] = "body",
		["path"] = "models/cgcclothing/t45/body.mdl",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["armsModel"] = false,
		["skin"] = 6,
		["rarity"] = 3,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -20
	},
	["armor_t45-hex"] = { -- 5.0 Community Update
		["name"] = "T-45d BOS Hex Power Armor",
		["desc"] = "A set of T-45d Power Armor refurbished by the Brotherhood of Steel for use in special operations | BOS - FACTION ARMOR",
		["type"] = "body",
		["path"] = "models/cgcclothing/t45/body.mdl",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["armsModel"] = false,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the BOS", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the BOS", "ui/notify.mp3")
		end,
		["skin"] = 7,
		["rarity"] = 3,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -20
	},
	["armor_t45-dark"] = { -- 5.0 Community Update
		["name"] = "T-45d Dark Power Armor",
		["desc"] = "A set of dark T-45d Power Armor",
		["type"] = "body",
		["path"] = "models/cgcclothing/t45/body.mdl",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["armsModel"] = false,
		["skin"] = 8,
		["rarity"] = 3,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -20
	},
	["armor_t45-dchina"] = { -- 5.0 Community Update
		["name"] = "T-45d Chinese Power Armor",
		["desc"] = "A set of T-45d Power Armor used by the Chinese Army | PLA - FACTION ARMOR",
		["type"] = "body",
		["path"] = "models/cgcclothing/t45/body.mdl",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["armsModel"] = false,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the PLA", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the PLA", "ui/notify.mp3")
		end,
		["skin"] = 9,
		["rarity"] = 3,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -20
	},
	["armor_t45-khan"] = { -- 5.0 Community Update
		["name"] = "T-45d Great Khan Power Armor",
		["desc"] = "A set of T-45d Power Armor refurbished by and for the Great Khans | GK - FACTION ARMOR",
		["type"] = "body",
		["path"] = "models/cgcclothing/t45/body.mdl",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["armsModel"] = false,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the Khans", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the Khans", "ui/notify.mp3")
		end,
		["skin"] = 10,
		["rarity"] = 3,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -20
	},
	["armor_t45-vt"] = { -- 5.0 Community Update
		["name"] = "T-45d Vault-Tec Power Armor",
		["desc"] = "A set of T-45d Power Armor refurbished by and for Vault-Tec | VT - FACTION ARMOR",
		["type"] = "body",
		["path"] = "models/cgcclothing/t45/body.mdl",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["armsModel"] = false,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of VT", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of VT", "ui/notify.mp3")
		end,
		["skin"] = 11,
		["rarity"] = 3,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -20
	},
	["armor_t45-army"] = { -- 5.0 Community Update
		["name"] = "T-45d Army Power Armor",
		["desc"] = "A set of T-45d Power Armor used by the United States Army before the Great War",
		["type"] = "body",
		["path"] = "models/cgcclothing/t45/body.mdl",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["armsModel"] = false,
		["skin"] = 12,
		["rarity"] = 3,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -20
	},
	["armor_t45-durban"] = { -- 5.0 Community Update
		["name"] = "T-45d Urban Power Armor",
		["desc"] = "A set of T-45d Power Armor used by the United States Special Forces before the Great War",
		["type"] = "body",
		["path"] = "models/cgcclothing/t45/body.mdl",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["armsModel"] = false,
		["skin"] = 13,
		["rarity"] = 3,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -20
	},
	["armor_pinkfury"] = { -- 5.0 Community Update
		["name"] = "T-45d Pink Fury Power Armor",
		["desc"] = "A set of T-45d Power Armor refurbished and painted to be utterly fucking adorable",
		["type"] = "body",
		["path"] = "models/cgcclothing/t45/body.mdl",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["armsModel"] = false,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You feel . . . cute . . .", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You feel . . . less cute", "ui/notify.mp3")
		end,
		["skin"] = 14,
		["rarity"] = 5,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -20
	},
	["armor_t45-dfamilies"] = { -- 5.0 Community Update
		["name"] = "T-45d High-Roller Power Armor",
		["desc"] = "A set of T-45d Power Armor refurbished by and for House Industries | HOUSE - FACTION ARMOR",
		["type"] = "body",
		["path"] = "models/cgcclothing/t45/body.mdl",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["armsModel"] = false,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of House", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of House", "ui/notify.mp3")
		end,
		["skin"] = 15,
		["rarity"] = 3,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -20
	},
	["armor_T45-dcrimson"] = { -- 5.0 Community Update
		["name"] = "T-45d Crimson Power Armor",
		["desc"] = "A set of crimson T-45d Power Armor",
		["type"] = "body",
		["path"] = "models/cgcclothing/t45/body.mdl",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["armsModel"] = false,
		["skin"] = 4,
		["rarity"] = 3,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -20
	},
	["warlordpoweramrorxd"] = {
		["name"] = "T-45d Fiend Warlord Power Armor",
		["desc"] = "A set of T-51b Power Armor, standard issue | FIENDS - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group124",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["rarity"] = 3,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a Fiend", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a Fiend", "ui/notify.mp3")
		end,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -20
	},
	["t45powerarmorfo4"] = {
		["name"] = "T-45d MKII Power Armor",
		["desc"] = "A T-45d Power Armor Suit often found used by the Pre-War East Coast United States Military",
		["itemModel"] = "models/fallout/apparel/t60pago.mdl",
		["armsModel"] = "models/lazarusroleplay/headgear/m_hats01.mdl",
		["path"] = "models/illusion/fallout/t45pa.mdl",
		["rarity"] = 3,
		["type"] = "body",
		["powerarmor"] = true,
		["maleScale"] = 0.95,
		["femaleScale"] = 0.85,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -20,
	},
	["armor_T45-dcamo"] = {
		["name"] = "T-45d MKII Gunner Power Armor",
		["desc"] = "A T-45d Power Armor Suit often found used by the Pre-War East Coast United States Military, now painted by the Gunners Mercenary Group | GUNNER - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/t60pago.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group056/arms/male_arm.mdl",
		["path"] = "models/illusion/fallout/t45usarmy.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the Gunners", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the Gunners", "ui/notify.mp3")
		end,
		["rarity"] = 3,
		["type"] = "body",
		["powerarmor"] = true,
		["maleScale"] = 0.95,
		["femaleScale"] = 0.85,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -20,
	},
	["armor_X-02"] = { -- keith note: model conflict in Custom Models 8
		["name"] = "X-02 Enclave Power Armor",
		["desc"] = "The X-02 power armor was specially developed for and by the Enclave. The Enclave represented one of the most advanced paramilitary forces in the world before the war, controlling the United States from the shadows. The ultralight components of the X-02 model allow it to surpass its predecessor in terms of speed and agility | ENCLAVE - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/enclave_power_armor.mdl",
		["armsModel"] = "models/lazarusroleplay/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["type"] = "body",
		["modelType"] = "group209",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the Enclave", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the Enclave", "ui/notify.mp3")
		end,
		["rarity"] = 4,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -20,
	},
	["armor_X-02_nco"] = {-- keith note: model conflict in Custom Models 8
		["name"] = "X-02 Enclave NCO Power Armor",
		["desc"] = "The X-02 power armor was specially developed for and by the Enclave. The Enclave represented one of the most advanced paramilitary forces in the world before the war, controlling the United States from the shadows. The ultralight components of the X-02 model allow it to surpass its predecessor in terms of speed and agility. This model specifically has the signature marking of an Enclave NCO | ENCLAVE - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/enclave_power_armor.mdl",
		["armsModel"] = "models/lazarusroleplay/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["type"] = "body",
		["modelType"] = "group209",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the Enclave", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the Enclave", "ui/notify.mp3")
		end,
		["rarity"] = 4,
		["skin"] = 1,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 80,
		["noFall"] = true,
		["speed"] = -20,
	},
	["armor_tesla"] = {
		["name"] = "X-02 Enclave Tesla Power Armor",
		["desc"] = "The X-02 power armor was specially developed for the Department of the Army of the Enclave which represented one of the most advanced paramilitary force in the world. The ultralight components of the X-02 model allow it to surpass its predecessor in terms of speed and agility | ENCLAVE - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/enclave_power_armor.mdl",
		["armsModel"] = false,
		["path"] = "models/fallout_3/tesla_power_armor_body.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the Enclave", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the Enclave", "ui/notify.mp3")
		end,
		["rarity"] = 5,
		["type"] = "body",
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 90,
		["noFall"] = true,
		["speed"] = -20,
	},
	["armor_X-03"] = {
		["name"] = "X-03 Enclave Hellfire Power Armor",
		["desc"] = "The X-03 power armor was specially developed for the Department of the Army of the Enclave which represented one of the most advanced paramilitary force in the world. The ultralight components of the X-02 model allow it to surpass its predecessor in terms of speed and agility | ENCLAVE - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/hellfire.mdl",
		["armsModel"] = "models/lazarusroleplay/thespireroleplay/humans/group122/arms/male_arm.mdl",
		["type"] = "body",
		["modelType"] = "group211",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the Enclave", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the Enclave", "ui/notify.mp3")
		end,
		["rarity"] = 4,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 83,
		["noFall"] = true,
		["speed"] = -20,
	},


	
	["armor_t51-bos"] = { -- "T-51b BOS Power Armor" replacement from Vex's armor system
		["name"] = "T-51b BOS Paladin Power Armor",
		["desc"] = "A set of T-51b that has been heavily refurbished and modified by the Brotherhood of Steel. This armor in particular is commonly worn by officers of the Brotherhood. | BOS - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/t51bpowerarmor.mdl",
		["armsModel"] = "models/lazarusroleplay/thespireroleplay/humans/group122/arms/male_arm.mdl",
		["path"] = "models/thespireroleplay/humans/group123/male.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a Paladin of the BOS", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a Paladin of the BOS", "ui/notify.mp3")
		end,
		["rarity"] = 4,
		["type"] = "body",
		["powerarmor"] = true,
		["maleScale"] = 1,
		["femaleScale"] = 1,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 83,
		["noFall"] = true,
		["speed"] = -20,
	},
	["armor_t51-bblack"] = { -- "T-51b BOS Black Power Armor" replacement from Vex's armor system
		["name"] = "T-51b BOS Lost Hills Power Armor",
		["desc"] = "A set of T-51b that has been heavily refurbished and modified by the Brotherhood of Steel. This armor in particular is commonly worn by the commanding officers of the Brotherhood. | BOS - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/t51bpowerarmor.mdl",
		["armsModel"] = "models/lazarusroleplay/thespireroleplay/humans/group122/arms/male_arm.mdl",
		["path"] = "models/thespireroleplay/humans/group123/male.mdl",
		["skin"] = 1,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a Paladin of the BOS", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a Paladin of the BOS", "ui/notify.mp3")
		end,
		["rarity"] = 4,
		["type"] = "body",
		["powerarmor"] = true,
		["maleScale"] = 1,
		["femaleScale"] = 1,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 83,
		["noFall"] = true,
		["speed"] = -20,
	},
	/**["armor_t45-dbos"] = { 								-- Old model version
		["name"] = "T-45d BOS Knight Power Armor",
		["desc"] = "A T-45d Power Armor Suit often found used by the Pre-War East Coast United States Military, now refurbished by the Brotherhood of Steel | BOS - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["armsModel"] = false,
		["path"] = "models/player/yates/bosknightbody.mdl",
		--["path"] = "models/illusion/fallout/t45pa.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the BOS", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the BOS", "ui/notify.mp3")
		end,
		["rarity"] = 3,
		["type"] = "body",
		["powerarmor"] = true,
		["maleScale"] = 1,
		["femaleScale"] = 1,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -25,
	},
	["armor_T45-dbos"] = { 							-- Duplicate armor version / Old model version
		["name"] = "T-45d BOS Power Armor",
		["desc"] = "A T-45d Power Armor Suit often found used by the Pre-War East Coast United States Military, now refurbished by the Brotherhood of Steel | BOS - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["armsModel"] = false,
		["path"] = "models/player/yates/bosknightbody.mdl",
		--["path"] = "models/illusion/fallout/t45pa.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the BOS", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the BOS", "ui/notify.mp3")
		end,
		["rarity"] = 3,
		["type"] = "body",
		["powerarmor"] = true,
		["maleScale"] = 1,
		["femaleScale"] = 1,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -25,
	},**/

	
	["armor_t45-dhex"] = { 								-- T-45d BOS Hex Power Armor model replacement
		["name"] = "T-45d BOS NCO Power Armor",
		["desc"] = "A T-45d Power Armor Suit often found used by the Pre-War East Coast United States Military, now refurbished by the Brotherhood of Steel. This armor in particular is commonly worn by NCOs of the Brotherhood. | BOS - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["type"] = "body",
		--["modelType"] = "group203",
		["path"] = "models/fallout_3/power_armor_admin_body.mdl",
		["skin"] = 1,
		["armsModel"] = false,
		--["path"] = "models/illusion/fallout/t45pa.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the BOS", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the BOS", "ui/notify.mp3")
		end,
		["rarity"] = 3,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 80,
		["noFall"] = true,
		["speed"] = -20,
	},
	["armor_t45-dbos"] = { -- Has a duplicate armor (below) due to original configuration mistake done on system deployment
		["name"] = "T-45d BOS Knight Power Armor",
		["desc"] = "A T-45d Power Armor Suit often found used by the Pre-War East Coast United States Military, now refurbished by the Brotherhood of Steel | BOS - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["type"] = "body",
		--["modelType"] = "group203",
		["path"] = "models/fallout_3/power_armor_admin_body.mdl",
		["armsModel"] = false,
		--["path"] = "models/illusion/fallout/t45pa.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the BOS", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the BOS", "ui/notify.mp3")
		end,
		["rarity"] = 3,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -20,
	},
	["armor_T45-dbos"] = { -- Has a duplicate armor (above) due to original configuration mistake done on system deployment
		["name"] = "T-45d BOS Knight Power Armor",
		["desc"] = "A T-45d Power Armor Suit often found used by the Pre-War East Coast United States Military, now refurbished by the Brotherhood of Steel | BOS - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["type"] = "body",
		--["modelType"] = "group203",
		["path"] = "models/fallout_3/power_armor_admin_body.mdl",
		["armsModel"] = false,
		--["path"] = "models/illusion/fallout/t45pa.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the BOS", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the BOS", "ui/notify.mp3")
		end,
		["rarity"] = 3,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -20,
	},
	/**
	["armor_t60-bosss"] = { -- NOTE: Ported from legacy armor system (T60-bosss)
		["name"] = "T-60 BOS Power Armor",
		["desc"] = "A T-60 Power Armor Suit often found used by the Pre-War East Coast United States Military, now refurbished by the Brotherhood of Steel. This armor in particular is commonly worn by NCOs of the Brotherhood. | BOS - FACTION ARMOR",
		["itemModel"] = "models/thespireroleplay/items/clothes/group056.mdl",
		["type"] = "body",
		["path"] = "models/thespireroleplay/humans/group524/armor.mdl",
		["armsModel"] = false,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the BOS", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the BOS", "ui/notify.mp3")
		end,
		["rarity"] = 4,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 83,
		["noFall"] = true,
		["speed"] = -27,
	},
	**/
	["t45mkiincr"] = {
		["name"] = "T-45d NCR Power Armor",
		["desc"] = "A T-45d Power Armor Suit often found used by the Pre-War East Coast United States Military, now refurbished by the Brotherhood of Steel | NCR - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/t60pago.mdl",
		["armsModel"] = false,
		["path"] = "models/cgcclothing/t45/body.mdl",
		["skin"] = 17,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["rarity"] = 3,
		["type"] = "body",
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -20,
	},
	["armor_t45-dtalon"] = { -- "T-45d Talon Power Armor" replacement in Vex's Armor System
		["name"] = "T-45d Talon Power Armor",
		["desc"] = "A T-45d Power Armor suit refurbished by Talon Company to fully functioning order | TALON - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["armsModel"] = "models/lazarusroleplay/thespireroleplay/humans/group122/arms/male_arm.mdl",
		["path"] = "models/cgcclothing/t45/body.mdl",
		["skin"] = 16,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of Talon", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of Talon", "ui/notify.mp3")
		end,
		["rarity"] = 3,
		["type"] = "body",
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -20,
	},
	["t45dbospowerarmor"] = {
		["name"] = "T-45d Forged Power Armor",
		["desc"] = "A T-45d Power Armor Suit often found used by the Pre-War East Coast United States Military, now used by the Forged",
		["itemModel"] = "models/fallout/apparel/t60pago.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group056/arms/male_arm.mdl",
		["path"] = "models/illusion/fallout/t45outcast.mdl",
		["rarity"] = 3,
		["type"] = "body",
		["powerarmor"] = true,
		["damage"] = 75,
		["noFall"] = true,
		["speed"] = -20,
	},
	["t51bpowerarmormkii"] = {
		["name"] = "T-51b MKII BOS Power Armor",
		["desc"] = "A T-51b Power Armor Suit often found used by the Pre-War East Coast United States Military, now used by the Brotherhood of Steel | BOS - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/t51bpowerarmor.mdl",
		["armsModel"] = false,
		["path"] = "models/illusion/fallout/t51bospa.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the BOS", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the BOS", "ui/notify.mp3")
		end,
		["rarity"] = 4,
		["type"] = "body",
		["powerarmor"] = true,
		["maleScale"] = 0.95,
		["femaleScale"] = 0.85,
		["damage"] = 80,
		["noFall"] = true,
		["speed"] = -20,
	},
	["t51bminutemenpowerarmormkii"] = {
		["name"] = "T-51b MKII Minutemen Power Armor",
		["desc"] = "A T-51b Power Armor Suit often found used by the Pre-War East Coast United States Militaryl | MM - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/t51bpowerarmor.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group056/arms/male_arm.mdl",
		["path"] = "models/illusion/fallout/t51paminute.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the Minutemen", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the Minutemen", "ui/notify.mp3")
		end,
		["rarity"] = 4,
		["type"] = "body",
		["powerarmor"] = true,
		["maleScale"] = 0.95,
		["femaleScale"] = 0.85,
		["damage"] = 80,
		["noFall"] = true,
		["speed"] = -20,
	},
	["t51bpowerarmorblackmkii"] = {
		["name"] = "T-51b MKII Black Power Armor",
		["desc"] = "A T-51b Power Armor Suit often found used by the Pre-War East Coast United States Military",
		["itemModel"] = "models/fallout/apparel/t51bpowerarmor.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group056/arms/male_arm.mdl",
		["path"] = "models/illusion/fallout/t51panorm.mdl",
		["rarity"] = 4,
		["type"] = "body",
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 80,
		["noFall"] = true,
		["speed"] = -20,
	},
	["t51bmkiioutcast"] = {
		["name"] = "T-51b MKII Outcast Power Armor",
		["desc"] = "A T-51b Power Armor Suit often found used by the Pre-War East Coast United States Military",
		["itemModel"] = "models/fallout/apparel/t51bpowerarmor.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group056/arms/male_arm.mdl",
		["path"] = "models/illusion/fallout/t51paoutcast.mdl",
		["rarity"] = 4,
		["type"] = "body",
		["powerarmor"] = true,
		["maleScale"] = 0.95,
		["femaleScale"] = 0.85,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 80,
		["noFall"] = true,
		["speed"] = -20,
	},
	["t51bmkiianchorage"] = {
		["name"] = "T-51b MKII Anchorage Power Armor",
		["desc"] = "A T-51b Power Armor Suit often found used by the Pre-War East Coast United States Military",
		["itemModel"] = "models/fallout/apparel/t51bpowerarmor.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group056/arms/male_arm.mdl",
		["path"] = "models/illusion/fallout/t51pawinter.mdl",
		["rarity"] = 4,
		["type"] = "body",
		["powerarmor"] = true,
		["maleScale"] = 0.95,
		["femaleScale"] = 0.85,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 80,
		["noFall"] = true,
		["speed"] = -20,
	},
	["t51bprewarpowerarmor"] = {
		["name"] = "T-51b Pre-War Power Armor",
		["desc"] = "A set of T-51b Power Armor, standard issue",
		["type"] = "body",
		["modelType"] = "group123",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["skin"] = 1,
		["rarity"] = 4,
		["powerarmor"] = true,
		["maleScale"] = 0.95,
		["femaleScale"] = 0.85,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 80,
		["noFall"] = true,
		["speed"] = -20
	},
	["t51bblackpowerarmor"] = {
		["name"] = "T-51b Black Power Armor",
		["desc"] = "A set of T-51b Power Armor, standard issue",
		["type"] = "body",
		["modelType"] = "group123",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["skin"] = 2,
		["rarity"] = 4,
		["powerarmor"] = true,
		["maleScale"] = 0.95,
		["femaleScale"] = 0.85,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 80,
		["noFall"] = true,
		["speed"] = -20
	},
	["armor_X-RE"] = {
		["name"] = "X-01 Richardson Elite Power Armor",
		["desc"] = "The armor was created by the Enclave's skilled team of engineers and scientists after the Great War as a result of a research program initiated in 2198, part of a larger project to develop various technologies | ENCLAVE - FACTION ARMOR",
		["type"] = "body",
		["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["path"] = "models/thespireroleplay/humans/group600/armor.mdl",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		--"modelType"] = "group115",
		["itemModel"] = "models/fallout/apparel/adpowerarmor.mdl",
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of The Enclave", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of The Enclave", "ui/notify.mp3")
		end,
		["skin"] = 1,
		["powerarmor"] = true,
		["maleScale"] = 0.95,
		["femaleScale"] = 0.85,
		["footstep"] = Armor.PAFootstep,
		["noFall"] = true,
		["damage"] = 85,
		["speed"] = -20
	},
	["armor_X-RE-NCO"] = {
		["name"] = "X-01 Advanced Power Armor",
		["desc"] = "The armor was created by the Enclave's skilled team of engineers and scientists after the Great War as a result of a research program initiated in 2198, part of a larger project to develop various technologies | ENCLAVE - FACTION ARMOR",
		["type"] = "body",
		["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["path"] = "models/thespireroleplay/humans/group600/armor.mdl",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		--"modelType"] = "group115",
		["itemModel"] = "models/fallout/apparel/adpowerarmor.mdl",
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of The Enclave", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of The Enclave", "ui/notify.mp3")
		end,
		["skin"] = 2,
		["powerarmor"] = true,
		["maleScale"] = 1,
		["femaleScale"] = 0.85,
		["footstep"] = Armor.PAFootstep,
		["noFall"] = true,
		["damage"] = 83,
		["speed"] = -20
	},
	["apa_tesla_enclave"] = {
		["name"] = "X-01 Tesla Elite Power Armor",
		["desc"] = "One of the most advanced technological power armors known to man. This power armor created by and for the Enclave electrifies the surrounding air in it's wake. | ENCLAVE - FACTION LEADER ARMOR",
		["type"] = "body",
		["path"] = "models/thespireroleplay/humans/group518/armor.mdl",
		["itemModel"] = "models/fallout/apparel/adpowerarmor.mdl",
		["rarity"] = 5,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of The Enclave", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of The Enclave", "ui/notify.mp3")
		end,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["noFall"] = true,
		["damage"] = 90,
		["speed"] = -20
	},
	["apa_tesla_wasteland"] = {
		["name"] = "X-01 Advanced Tesla Power Armor",
		["desc"] = "The armor was created by the Enclave's skilled team of engineers and scientists after the Great War as a result of a research program initiated in 2198, part of a larger project to develop various technologies",
		["type"] = "body",
		["path"] = "models/thespireroleplay/humans/group518/armor.mdl",
		["itemModel"] = "models/fallout/apparel/adpowerarmor.mdl",
		["rarity"] = 5,
		["skin"] = 1,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["noFall"] = true,
		["damage"] = 90,
		["speed"] = -20
	},
/**
	["armor_remnant"] = {
		["name"] = "X-01 U.S.S. Agent Power Armor (Autumn)",
		["desc"] = "A set of especially constructed X-01 Power Armor used by the Enclave's Secret Service during their initial insurgence in New California. This power armor on top of superior resistance offers a cloaking technology for covert operations | ENCLAVE - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/adpowerarmor.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["path"] = "models/cgcclothing/fallout/valentina_apa.mdl",
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the Enclave", "ui/notify.mp3")
			ply:Give("weapon_stealthboy_cgc")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the Enclave", "ui/notify.mp3")
			ply:StripWeapon("weapon_stealthboy_cgc")
		end,
		["type"] = "body",
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 90,
		["noFall"] = true,
		["speed"] = -25,
	},
	["armor_remnant_blue"] = {
		["name"] = "X-01 U.S.S. Agent Power Armor (Blue)",
		["desc"] = "A set of especially constructed X-01 Power Armor used by the Enclave's Secret Service during their initial insurgence in New California. This power armor on top of superior resistance offers a cloaking technology for covert operations | ENCLAVE - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/adpowerarmor.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["path"] = "models/cgcclothing/fallout/valentina_apa.mdl",
		["skin"] = 1,
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the Enclave", "ui/notify.mp3")
			ply:Give("weapon_stealthboy_cgc")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the Enclave", "ui/notify.mp3")
			ply:StripWeapon("weapon_stealthboy_cgc")
		end,
		["type"] = "body",
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 90,
		["noFall"] = true,
		["speed"] = -25,
	},
	["armor_remnant_red"] = {
		["name"] = "X-01 U.S.S. Agent Power Armor (Red)",
		["desc"] = "A set of especially constructed X-01 Power Armor used by the Enclave's Secret Service during their initial insurgence in New California. This power armor on top of superior resistance offers a cloaking technology for covert operations | ENCLAVE - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/adpowerarmor.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["path"] = "models/cgcclothing/fallout/valentina_apa.mdl",
		["skin"] = 2,
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the Enclave", "ui/notify.mp3")
			ply:Give("weapon_stealthboy_cgc")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the Enclave", "ui/notify.mp3")
			ply:StripWeapon("weapon_stealthboy_cgc")
		end,
		["type"] = "body",
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 90,
		["noFall"] = true,
		["speed"] = -25,
	},
	["armor_remnant_green"] = {
		["name"] = "X-01 U.S.S. Agent Power Armor (Green)",
		["desc"] = "A set of especially constructed X-01 Power Armor used by the Enclave's Secret Service during their initial insurgence in New California. This power armor on top of superior resistance offers a cloaking technology for covert operations | ENCLAVE - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/adpowerarmor.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["path"] = "models/cgcclothing/fallout/valentina_apa.mdl",
		["skin"] = 3,
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the Enclave", "ui/notify.mp3")
			ply:Give("weapon_stealthboy_cgc")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the Enclave", "ui/notify.mp3")
			ply:StripWeapon("weapon_stealthboy_cgc")
		end,
		["type"] = "body",
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 90,
		["noFall"] = true,
		["speed"] = -25,
	},
	["armor_remnant_white"] = {
		["name"] = "X-01 U.S.S. Agent Power Armor (White)",
		["desc"] = "A set of especially constructed X-01 Power Armor used by the Enclave's Secret Service during their initial insurgence in New California. This power armor on top of superior resistance offers a cloaking technology for covert operations | ENCLAVE - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/adpowerarmor.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["path"] = "models/cgcclothing/fallout/valentina_apa.mdl",
		["skin"] = 4,
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the Enclave", "ui/notify.mp3")
			ply:Give("weapon_stealthboy_cgc")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the Enclave", "ui/notify.mp3")
			ply:StripWeapon("weapon_stealthboy_cgc")
		end,
		["type"] = "body",
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 90,
		["noFall"] = true,
		["speed"] = -25,
	},
**/
	["armor_remnant"] = {
		["name"] = "X-01 U.S.S. Agent Power Armor",
		["desc"] = "A set of especially constructed X-01 Power Armor used by the Enclave's Secret Service during their initial insurgence in New California. This power armor on top of superior resistance offers a cloaking technology for covert operations | ENCLAVE - FACTION ARMOR",
		["type"] = "body",
		["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["path"] = "models/thespireroleplay/humans/group312/male.mdl",
		--["modelType"] = "group312",
		["itemModel"] = "models/fallout/apparel/adpowerarmor.mdl",
		["skin"]  = 2,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the Enclave", "ui/notify.mp3")
			ply:Give("weapon_stealthboy_cgc")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the Enclave", "ui/notify.mp3")
			ply:StripWeapon("weapon_stealthboy_cgc")
		end,
		["rarity"] = 4,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["noFall"] = true,
		["damage"] = 90,
		["speed"] = -20
	},
	["armor_X-RE_unique"] = {
		["name"] = "X-01 Advanced Power Armor",
		["desc"] = "The armor was created by the Enclave's skilled team of engineers and scientists after the Great War as a result of a research program initiated in 2198, part of a larger project to develop various technologies",
		["type"] = "body",
		["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["path"] = "models/thespireroleplay/humans/group600/armor.mdl",
		--["modelType"] = "group312",
		["itemModel"] = "models/fallout/apparel/adpowerarmor.mdl",
		["rarity"] = 5,
		--["skin"] = 1,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["noFall"] = true,
		["damage"] = 90,
		["speed"] = -20
	},
	["t51bpowerarmor"] = {
		["name"] = "T-51b Power Armor",
		["desc"] = "A set of T-51b Power Armor | Power Armor",
		["type"] = "body",
		["modelType"] = "group113",
		["itemModel"] = "models/fallout/apparel/t51bpowerarmor.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["bodygroup"] = {2, 2, 2, 2, 2, 1, 1, 1, 2, 2},
		["rarity"] = 4,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 80,
		["noFall"] = true,
		["speed"] = -20
	},
	["t51bpowerarmora"] = {
		["name"] = "T-51b Desert Power Armor",
		["desc"] = "A set of T-51b Power Armor | Power Armor",
		["type"] = "body",
		["modelType"] = "group113",
		["itemModel"] = "models/fallout/apparel/t51bpowerarmor.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["skin"] = 1,
		["bodygroup"] = {2, 2, 2, 2, 2, 1, 1, 1, 2, 2},
		["rarity"] = 4,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 80,
		["noFall"] = true,
		["speed"] = -20
	},
	["t51bpowerarmorb"] = {
		["name"] = "T-51b Gunners Power Armor",
		["desc"] = "A set of T-51b Gunner Power Armor | Power Armor | GUNNERS - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group113",
		["itemModel"] = "models/fallout/apparel/t51bpowerarmor.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["skin"] = 2,
		["bodygroup"] = {2, 2, 2, 2, 2, 1, 1, 1, 2, 2},
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a Gunner", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a Gunner", "ui/notify.mp3")
		end,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 80,
		["noFall"] = true,
		["speed"] = -20
	},
	["t51bpowerarmorc"] = {
		["name"] = "T-51b Outcast Power Armor",
		["desc"] = "A set of T-51b Gunner Power Armor | Power Armor",
		["type"] = "body",
		["modelType"] = "group113",
		["itemModel"] = "models/fallout/apparel/t51bpowerarmor.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["skin"] = 3,
		["bodygroup"] = {2, 2, 2, 2, 2, 1, 1, 1, 2, 2},
		["rarity"] = 4,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 80,
		["noFall"] = true,
		["speed"] = -20
	},
	["t51bpowerarmord"] = {
		["name"] = "T-51b BOS Power Armor",
		["desc"] = "A set of T-51b BOS Power Armor | Power Armor | BOS - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group113",
		["itemModel"] = "models/fallout/apparel/t51bpowerarmor.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["skin"] = 4,
		["bodygroup"] = {2, 2, 2, 2, 2, 1, 1, 1, 2, 2},
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the BOS", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the BOS", "ui/notify.mp3")
		end,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 80,
		["noFall"] = true,
		["speed"] = -22
	},
	["armor_t45-dncr"] = {
		["name"] = "Salvaged NCR Power Armor",
		["desc"] = "A set of Salvaged Power Armor refurbished by the NCR and obtained from dead Brotherhood of Steel Knights | Does not require Power Armor Training | Cannot wield heavy weapons | -2 END / -1 AGIL | NCR - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group111",
		["itemModel"] = "models/fallout/apparel/gscexo.mdl",
		["rarity"] = 3,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["cannotWear"] = {
			["extra"] = true,
			["armor"] = true,
		},
		["damage"] = 73,
		["noFall"] = true,
		["powerarmor"] = true,
		["noCore"] = true,
		["footstep"] = Armor.PAFootstep,
		["speed"] = -10
	},
	["t45salvaged"] = {
		["name"] = "Salvaged Power Armor",
		["desc"] = "A scrapped together Power Armor parts that provides utility of Power Armor without knowing how to operate it | Does not require Power Armor Training / Cannot wield heavy weapons / has debuff effects",
		["type"] = "body",
		["path"] = "models/cgcclothing/t45/body.mdl",
		["armsModel"] = false,
		["skin"] = 4,
		["itemModel"] = "models/fallout/apparel/gscexo.mdl",
		["rarity"] = 3,
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "E", -2)
			BuffStat(ply, item, "A", -1)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "E")
			EndBuff(ply, item, "A")
		end,
		["cannotWear"] = {
			["extra"] = true,
			["armor"] = true,
		},
		["damage"] = 75,
		["noFall"] = true,
		["footstep"] = Armor.PAFootstep,
		["speed"] = -20
	},
	["mefretrolancer"] = {
		["name"] = "MEF Zealot Power Armor",
		["desc"] = "A set of MEF Zealot Power Armor often worn by frontline soldiers | MEF - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/amwpa.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["path"] = "models/cgcclothing/humans/rangerpowerarmor/male.mdl",
		["rarity"] = 3,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of MEF", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of MEF", "ui/notify.mp3")
		end,
		["type"] = "body",
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noCore"] = true,
		["noFall"] = true,
		["speed"] = -20,
	},
	["exoduspowerarmor"] = { -- Custom order | NOTE: Duplicate of below due to sex misconfig | FIXME: Has female variant; requires new dir
		["name"] = "XV-92 Colossus Power Armor",
		["desc"] = "A set of XV-92 Power Armor often worn by the Order of the Eternal Abyss | EA - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/amwpa.mdl",
		["modelType"] = "group519",
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of EA", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of EA", "ui/notify.mp3")
		end,
		["type"] = "body",
		["powerarmor"] = true,
		["maleScale"] = 0.95,
		["femaleScale"] = 0.85,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 80,
		["noFall"] = true,
		["speed"] = -20,
	},
	["exoduspowerarmorfe"] = { -- Custom order | NOTE: Duplicate of below due to sex misconfig | FIXME: Has female variant; requires new dir
		["name"] = "XV-92 Colossus Power Armor",
		["desc"] = "A set of XV-92 Power Armor often worn by the Order of the Eternal Abyss | EA - FACTION ARMOR",
		["itemModel"] = "models/fallout/apparel/amwpa.mdl",
		["modelType"] = "group519",
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of EA", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of EA", "ui/notify.mp3")
		end,
		["type"] = "body",
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 80,
		["noFall"] = true,
		["speed"] = -20	,
	},
	["plaguedoctor"] = {
		["name"] = "Plague Doctor Clothing",
		["desc"] = "Clothing worn by the most ethical of the unethical | +10 to Medical Rolls | FOLLOWERS - FACTION OFFICER ARMOR",
		["itemModel"] = "models/thespireroleplay/items/clothes/group051.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group122/arms/male_arm.mdl",
		["path"] = "models/cgcclothing/humans/plague/male.mdl",
		["rarity"] = 4,
		["type"] = "body",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the Followers", "ui/notify.mp3")
			BuffStat(ply, item, "I", 7)
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the Followers", "ui/notify.mp3")
			EndBuff(ply, item, "I")
		end,
		["damage"] = 25,
	},
	["armor_enclaveofficer"] = {
		["name"] = "Enclave Scout Armor",
		["desc"] = "An trooper uniform worn by military personnel of The Enclave | ENCLAVE - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group199",
		["itemModel"] = "models/fallout/apparel/combatarmor.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as an Enclave member", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as an Enclave member", "ui/notify.mp3")
		end,
		["damage"] = 65
	},
	["armor_cotc"] = { -- "Children of the Cathedral Inductee Robes" replacement from Vex's Armor System
		["name"] = "Children of the Cathedral Inductee Robes",
		["desc"] = "Robes worn by the Children of the Cathedral | UNITY - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group200",
		["itemModel"] = "models/thespireroleplay/items/clothes/group102.mdl",
		["armsModel"] = "models/lazarusroleplay/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["itemModelSkin"] = 1,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a Unity member", "ui/notify.mp3")
			BuffStat(ply, item, "I", 1)
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a Unity member", "ui/notify.mp3")
			EndBuff(ply, item, "I")
		end,
		["damage"] = 55
	},
	["armor_cotcr"] = { -- "Children of the Cathedral Robes [Male]" replacement from Vex's Armor System / Has duplicate due to Vex's system sex model difference (below)
		["name"] = "Children of the Cathedral Priest Robes",
		["desc"] = "Robes worn by the Children of the Cathedral priests | UNITY - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group201",
		["itemModel"] = "models/thespireroleplay/items/clothes/group102.mdl",
		["armsModel"] = "models/lazarusroleplay/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["itemModelSkin"] = 1,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a Unity member", "ui/notify.mp3")
			BuffStat(ply, item, "I", 2)
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a Unity member", "ui/notify.mp3")
			EndBuff(ply, item, "I")
		end,
		["damage"] = 55,
		["rarity"] = 2,
	},
	["armor_cotcf"] = { -- "Children of the Cathedral Robes [Female]" replacement from Vex's Armor System / Has duplicate due to Vex's system sex model difference (above)
		["name"] = "Children of the Cathedral Priest Robes",
		["desc"] = "Robes worn by the Children of the Cathedral priests | UNITY - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group201",
		["itemModel"] = "models/thespireroleplay/items/clothes/group102.mdl",
		["armsModel"] = "models/lazarusroleplay/thespireroleplay/humans/group123/arms/male_arm.mdl",
		["itemModelSkin"] = 1,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a Unity member", "ui/notify.mp3")
			BuffStat(ply, item, "I", 2)
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a Unity member", "ui/notify.mp3")
			EndBuff(ply, item, "I")
		end,
		["damage"] = 55,
		["rarity"] = 2,
	},
	["armor_cotc_surveyor"] = { -- Custom Order
		["name"] = "Children of the Cathedral Agent Suit",
		["desc"] = "A suit often worn by Children of the Cathedral scouts and informats | UNITY - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group210",
		["itemModel"] = "models/fallout/apparel/chinesestealth.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group122/arms/male_arm.mdl",
		["itemModelSkin"] = 1,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a Unity member", "ui/notify.mp3")
			BuffStat(ply, item, "E", 2)
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a Unity member", "ui/notify.mp3")
			EndBuff(ply, item, "E")
		end,
		["damage"] = 55,
		["speed"] = 10,
		["rarity"] = 4,
	},
	["coated_stealthsuit"] = { -- Custom Order
		["name"] = "UE Enhanced Incognito Maneuverability Suit",
		["desc"] = "A stealth suit produced by UE, at least if you believe them. UE swears up and down the wasteland that the design is completely homemade and not the same as the Chinese Stealth Suits used by Chinese Remnants. | UE - FACTION ARMOR",
		["type"] = "body",
		["armsModel"] = false,
		["modelType"] = "group895",
		["itemModel"] = "models/fallout/apparel/chinesestealth.mdl",
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of Universal Energy", "ui/notify.mp3")
			ply:Give("weapon_stealthboy_stealthsuit")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as an Universal Energy member", "ui/notify.mp3")
			ply:StripWeapon("weapon_stealthboy_stealthsuit")
		end,
		["damage"] = 25,
		["speed"] = 10,
	},
	["black_long_coatx"] = { -- Custom Order
		["name"] = "UE Engineer Coat",
		["desc"] = "An industrial coat used by Engineers of Universal Energy, made to cover the skin to avoid any hazardous dangers to the body while on the job while also offering decent protection. | UE - FACTION ARMOR",
		["type"] = "body",
		["armsModel"] = false,
		["modelType"] = "group896",
		["itemModel"] = "models/thespireroleplay/items/clothes/group005.mdl",
		["rarity"] = 3,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of Universal Energy", "ui/notify.mp3")
			BuffStat(ply, item, "E", 4)
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as an Universal Energy member", "ui/notify.mp3")
			EndBuff(ply, item, "E")
		end,
		["damage"] = 60,
		["speed"] = 0,
	},
	["ue_combat_armor"] = { -- Custom Order
		["name"] = "T.S.I. Combat Armor",
		["desc"] = "An armor used by the T.S.I. Contractors that guard UE Facilities. T.S.I. was absorbed into UE’s company following the bombs dropping, wasn’t many left to contest the merger afterall. | UE - FACTION ARMOR",
		["type"] = "body",
		["armsModel"] = false,
		["path"] = "models/thespireroleplay/humans/group894/armor.mdl",
		["itemModel"] = "models/thespireroleplay/items/clothes/group005.mdl",
		["rarity"] = 3,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of Universal Energy", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as an Universal Energy member", "ui/notify.mp3")
		end,
		["damage"] = 65,
		["speed"] = 0,
	},
	--["black_long_coatx_ue_default"] = { -- Custom Order
	--	["name"] = "UE Long Coat",
	--	["desc"] = "A blue coat worn by members of the Universal Energy | UE - FACTION ARMOR",
	--	["type"] = "body",
	--	["armsModel"] = false,
	--	["modelType"] = "group896",
	--	["itemModel"] = "models/thespireroleplay/items/clothes/group005.mdl",
	--	["rarity"] = 3,
	--	["OnWear"] = function(ply, item)
	--		ply:falloutNotify("You are dressed as a member of Universal Energy", "ui/notify.mp3")
	--		BuffStat(ply, item, "E", 4)
	--	end,
	--	["OnRemove"] = function(ply, item)
	--		ply:falloutNotify("You are no longer dressed as an Universal Energy member", "ui/notify.mp3")
	--		EndBuff(ply, item, "E")
	--	end,
	--	["damage"] = 60,
	--	["speed"] = 0,
	--},
	--["black_long_coatx_ue_black"] = { -- Custom Order
	--	["name"] = "UE Long Coat (Stealth Variant)",
	--	["desc"] = "A blue coat covering stealth armor worn by members of the Universal Energy | UE - FACTION ARMOR",
	--	["type"] = "body",
	--	["armsModel"] = false,
	--	["modelType"] = "group895",
	--	["itemModel"] = "models/thespireroleplay/items/clothes/group005.mdl",
	--	["rarity"] = 3,
	--	["OnWear"] = function(ply, item)
	--		ply:falloutNotify("You are dressed as a member of Universal Energy", "ui/notify.mp3")
	--		ply:Give("weapon_stealthboy_stealthsuit")
	--	end,
	--	["OnRemove"] = function(ply, item)
	--		ply:falloutNotify("You are no longer dressed as an Universal Energy member", "ui/notify.mp3")
	--		ply:StripWeapon("weapon_stealthboy_stealthsuit")
	--	end,
	--	["damage"] = 40,
	--	["speed"] = 0,
	--},
	["militia_recon"] = { -- Custom Order
		["name"] = "Militia Hunter Armor",
		["desc"] = "A set of Militia Hunter Armor that is often used by specialists within the faction  | MILITIA - FACTION ARMOR",
		["type"] = "body",
		["armsModel"] = "models/thespireroleplay/humans/group122/arms/male_arm.mdl",
		["modelType"] = "group303",
		["itemModel"] = "models/thespireroleplay/items/clothes/group017.mdl",
		["rarity"] = 3,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of Milita", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a Milita member", "ui/notify.mp3")
		end,
		["damage"] = 60,
		["speed"] = 10,
	},
	["jackal_officer_combat"] = { -- Custom Order
		["name"] = "Forged Raid Boss Armor",
		["desc"] = "A highly customized metalcombat armor variant created by and for the Forged raiders | Forged - FACTION ARMOR",
		["type"] = "body",
		["armsModel"] = false,
		["modelType"] = "group310",
		["itemModel"] = "models/thespireroleplay/items/clothes/group017.mdl",
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a Forged", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed a Forged", "ui/notify.mp3")
		end,
		["damage"] = 70,
		["speed"] = 0,
	},
	["armor_paradise-raider"] = { -- Custom Order by 'Dorian Gray#8127' : replacement for 'paradise-raider' in legacy reg.
		["name"] = "Paradise Raider Power Armor",
		["desc"] = "A set of reverse-engineered Power Armor used by the Paradise Slavers | PARADISE - FACTION ARMOR",
		["itemModel"] = "models/thespireroleplay/items/clothes/group056.mdl",
		["armsModel"] = false,
		["path"] = "models/cgcclothing/humans/powerarmor_raider/powerarmor_raider.mdl",
		["skin"] = 3,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of Paradise", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of Paradise", "ui/notify.mp3")
		end,
		["type"] = "body",
		["rarity"] = 3,
		["powerarmor"] = true,
		["noFall"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["speed"] = -20,
	},
	["armor_paradise-raider-flame"] = { -- Custom Order by 'Dorian Gray#8127' : replacement for 'paradise-raider-flame' in legacy reg.
		["name"] = "Paradise Flame Raider Power Armor",
		["desc"] = "A set of reverse-engineered Power Armor used by the Paradise Slavers | PARADISE - FACTION ARMOR",
		["itemModel"] = "models/thespireroleplay/items/clothes/group056.mdl",
		["armsModel"] = false,
		["path"] = "models/cgcclothing/humans/powerarmor_raider/powerarmor_raider.mdl",
		["skin"] = 1,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of Paradise", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of Paradise", "ui/notify.mp3")
		end,
		["type"] = "body",
		["rarity"] = 3,
		["powerarmor"] = true,
		["noFall"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["speed"] = -20,
	},
	["armor_paradise-raider-street"] = { -- Custom Order by 'Dorian Gray#8127'
		["name"] = "Paradise Street Raider Power Armor",
		["desc"] = "A set of reverse-engineered Power Armor used by the Paradise Slavers | PARADISE - FACTION ARMOR",
		["itemModel"] = "models/thespireroleplay/items/clothes/group056.mdl",
		["armsModel"] = false,
		["path"] = "models/cgcclothing/humans/powerarmor_raider/powerarmor_raider.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of Paradise", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of Paradise", "ui/notify.mp3")
		end,
		["type"] = "body",
		["rarity"] = 3,
		["powerarmor"] = true,
		["noFall"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["speed"] = -20,
	},
	["armor_paradise-raider-camo"] = { -- Custom Order by 'Dorian Gray#8127'
		["name"] = "Paradise Camo Raider Power Armor",
		["desc"] = "A set of reverse-engineered Power Armor used by the Paradise Slavers | PARADISE - FACTION ARMOR",
		["itemModel"] = "models/thespireroleplay/items/clothes/group056.mdl",
		["armsModel"] = false,
		["path"] = "models/cgcclothing/humans/powerarmor_raider/powerarmor_raider.mdl",
		["skin"] = 2,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of Paradise", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of Paradise", "ui/notify.mp3")
		end,
		["type"] = "body",
		["rarity"] = 3,
		["powerarmor"] = true,
		["noFall"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["speed"] = -20,
	},
	["armor_paradise-raider-naval"] = { -- Custom Order by 'Dorian Gray#8127'
		["name"] = "Paradise Naval Raider Power Armor",
		["desc"] = "A set of reverse-engineered Power Armor used by the Paradise Slavers | PARADISE - FACTION ARMOR",
		["itemModel"] = "models/thespireroleplay/items/clothes/group056.mdl",
		["armsModel"] = false,
		["path"] = "models/cgcclothing/humans/powerarmor_raider/powerarmor_raider.mdl",
		["skin"] = 4,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of Paradise", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of Paradise", "ui/notify.mp3")
		end,
		["type"] = "body",
		["rarity"] = 3,
		["powerarmor"] = true,
		["noFall"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["speed"] = -20,
	},
    ["armor_pittslave"] = { -- 5.0 Community Update
        ["name"] = "Pitt Slave Armor",
        ["desc"] = "A set of clothing worn typically by experienced slaves and those found in the Pitt | +3 END",
        ["type"] = "body",
        ["modelType"] = "group500",
        ["itemModel"] = "models/fallout/apparel/raiderarmor02.mdl",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "E", 3)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "E")
		end,
        ["damage"] = 35,
		["rarity"] = 3,
        ["speed"] = 0
    },
    ["armor_mysteriousstranger"] = { -- 5.0 Community Update
        ["name"] = "Mysterious Stranger Suit",
        ["desc"] = "A suit worn by the true hero of the wasteland. Is this just a duplicate? I hope for your sake. | +2 PER",
        ["type"] = "body",
        ["modelType"] = "group503",
        ["itemModel"] = "models/fallout/apparel/wastelandmerchant01.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You feel . . . mysterious", "44Magnum/mysterious.mp3")
			BuffStat(ply, item, "P", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "P")
		end,
        ["damage"] = 65,
		["rarity"] = 4,
        ["speed"] = 0
    },
    ["armor_raidercommando"] = { -- 5.0 Community Update
        ["name"] = "Raider Commando Armor",
        ["desc"] = "A set of armor often worn by the truly experienced killers of the wastleand | +2 STR",
        ["type"] = "body",
        ["modelType"] = "group501",
        ["itemModel"] = "models/thespireroleplay/items/clothes/group052.mdl",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "S", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "S")
		end,
		["rarity"] = 3,
        ["damage"] = 45,
        ["speed"] = 10
    },
    ["armor_jailrocker"] = { -- 5.0 Community Update
        ["name"] = "Jailhouse Rocker Outfit",
        ["desc"] = "Placeholder Description | +3 CHR",
        ["type"] = "body",
        ["modelType"] = "group502",
        ["itemModel"] = "models/thespireroleplay/items/clothes/group002.mdl",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "C", 3)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "C")
		end,
		["rarity"] = 2,
        ["damage"] = 35,
        ["speed"] = 5
    },
    ["armor_powderganger"] = { -- 5.0 Community Update
        ["name"] = "Powder Ganger Armor",
        ["desc"] = "A uniform with the New California Republic Correctional Facility markings rebranded by a gang of convicts known as the Powder Gangers",
        ["type"] = "body",
        ["modelType"] = "group504",
        ["itemModel"] = "models/thespireroleplay/items/clothes/group011.mdl",
		["rarity"] = 3,
        ["damage"] = 50,
        ["speed"] = 0
    },
    ["armor_raiderbadlands"] = { -- 5.0 Community Update
        ["name"] = "Badlands Armor",
        ["desc"] = "A set of armor worn by killers whom are familiar with the paths less traveled",
        ["type"] = "body",
        ["modelType"] = "group507",
        ["itemModel"] = "models/fallout/apparel/raiderarmor03.mdl",
		["rarity"] = 3,
        ["damage"] = 40,
        ["speed"] = 10
    },
    ["armor_formalwear"] = { -- 5.0 Community Update
        ["name"] = "Formal Wear Outfit",
        ["desc"] = "A set of clean and fancy clothing typically worn by those only with the highest of standards | +2 CHR / +2 INTEL",
        ["type"] = "body",
        ["modelType"] = "group505",
        ["itemModel"] = "models/fallout/apparel/casualwear.mdl",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "C", 2)
			BuffStat(ply, item, "I", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "C")
			EndBuff(ply, item, "I")
		end,
		["rarity"] = 3,
        ["damage"] = 25,
        ["speed"] = 0
    },
    ["armor_prostitute"] = { -- 5.0 Community Update
        ["name"] = "Prostitute Outfit",
        ["desc"] = ". . . Don't get any dumb ideas . . . | +2 CHR",
        ["type"] = "body",
        ["modelType"] = "group508",
        ["itemModel"] = "models/fallout/apparel/raiderarmor02.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You feel immediate regret . . .", "ui/notify.mp3")
			BuffStat(ply, item, "C", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "C")
		end,
		["rarity"] = 2,
        ["damage"] = 25,
        ["speed"] = 0
    },
    ["armor_nightwear"] = { -- 5.0 Community Update
        ["name"] = "Naughty Nightwear Outfit",
        ["desc"] = ". . . Don't get any dumb ideas . . .  | +2 CHR",
        ["type"] = "body",
        ["modelType"] = "group510",
        ["itemModel"] = "models/thespireroleplay/items/clothes/group013.mdl",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You feel immediate regret . . .", "ui/notify.mp3")
			BuffStat(ply, item, "C", 2)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "C")
		end,
		["rarity"] = 2,
        ["damage"] = 25,
        ["speed"] = 0
    },
    ["armor_whitelegs"] = { -- 5.0 Community Update
        ["name"] = "Tribal Clothing",
        ["desc"] = "A set of rags and clothing worn by tribals of the wasteland | +3 END",
        ["type"] = "body",
        ["modelType"] = "group509",
        ["itemModel"] = "models/fallout/apparel/raiderarmor04.mdl",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "E", 3)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "E")
		end,
		["rarity"] = 3,
        ["damage"] = 45,
        ["speed"] = 10
    },
    ["armor_markedscout"] = { -- 5.0 Community Update
        ["name"] = "Marked Scout Armor",
        ["desc"] = "Armor typically worn by those whom have suffered pain far greater than anyone ever should.",
        ["type"] = "body",
        ["modelType"] = "group513",
        ["itemModel"] = "models/fallout/apparel/legiongo.mdl",
		["rarity"] = 3,
        ["damage"] = 55,
        ["speed"] = 0
    },
    ["armor_oasisdruid"] = {
        ["name"] = "Druid Robes Outfit",
        ["desc"] = "A set of robes known to be worn by cultists and fantastics",
        ["type"] = "body",
        ["modelType"] = "group512",
        ["itemModel"] = "models/fallout/apparel/hazmat.mdl",
		["rarity"] = 3,
        ["damage"] = 35,
        ["speed"] = 0
    },
    ["armor_courierduster"] = { -- 5.0 Community Update
        ["name"] = "Courier-21 Duster Outfit",
        ["desc"] = "The duster of legend belonging to the one and only Courier",
        ["type"] = "body",
        ["modelType"] = "group514",
        ["itemModel"] = "models/fallout/apparel/leatherarmor.mdl",
		["rarity"] = 5,
        ["damage"] = 70,
        ["speed"] = 10
    },
    ["armor_courierduster_ncr"] = {
        ["name"] = "NCR Courier Duster Outfit",
        ["desc"] = "The duster of legend belonging to the mysterious hero of the New California Republic",
        ["type"] = "body",
        ["modelType"] = "group514",
        ["itemModel"] = "models/fallout/apparel/leatherarmor.mdl",
		["skin"] = 1,
		["rarity"] = 5,
        ["damage"] = 70,
        ["speed"] = 10
    },
    ["armor_courierduster_legion"] = { -- 5.0 Community Update
        ["name"] = "Legion Courier Duster Outfit",
        ["desc"] = "The duster of legend belonging to the mysterious hero of Caesar's Legion",
        ["type"] = "body",
        ["modelType"] = "group514",
        ["itemModel"] = "models/fallout/apparel/leatherarmor.mdl",
		["skin"] = 2,
		["rarity"] = 5,
        ["damage"] = 70,
        ["speed"] = 10
    },
    ["bounty_hunter_duster"] = { -- 5.0 Community Update
        ["name"] = "Bounty Hunter Duster Outfit",
        ["desc"] = "A duster formally worn by Bounty Hunters of the wasteland",
        ["type"] = "body",
        ["modelType"] = "group511",
        ["itemModel"] = "models/fallout/apparel/leatherarmor.mdl",
		["rarity"] = 4,
        ["damage"] = 60,
        ["speed"] = 5
    },
    ["armor_armoredexecutivesuit"] = { -- elliot#0002 Custom Order
        ["name"] = "Armored Executive Suit",
        ["desc"] = "A custom tailored suit equipped with bodyarmor worn by Executives | CC - FACTION ARMOR ",
        ["type"] = "body",
        ["modelType"] = "group517",
        ["itemModel"] = "models/fallout/apparel/formalsuit.mdl",
        ["damage"] = 65,
        ["speed"] = 0,
        ["rarity"] = 3,
    },
    ["ncrhcuniform"] = { -- elliot#0002 Custom Order
        ["name"] = "NCR High Command Uniform",
        ["desc"] = "A uniform typically worn by the highest ranking members of the New California Republic | NCR - FACTION OFFICER ARMOR ",
        ["type"] = "body",
        ["modelType"] = "group515",
        ["itemModel"] = "models/fallout/apparel/centuriongo.mdl",
		["OnWear"] = function(ply, item)
			BuffStat(ply, item, "C", 15)
			ply:falloutNotify("You are dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "C")
			ply:falloutNotify("You are no longer dressed as a member of the NCR", "ui/notify.mp3")
		end,
		["damage"] = 35,
        ["rarity"] = 4,
        ["speed"] = 0,
    },
	["followers_medical_scrubs"] = { -- 5.0 Community Update
		["name"] = "Followers Medical Scrubs",
		["desc"] = "The scrubs are a set of white Pre-War scientist scrubs that have a belt and collar | +5 INTEL  | FOLLOWERS - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group119",
		["itemModel"] = "models/thespireroleplay/items/clothes/group007.mdl",
		["itemModelSkin"] = 3,
		["skin"] = 3,
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
				BuffStat(ply, item, "I", 5)
				ply:falloutNotify("You are wearing a FOA uniform", "ui/notify.mp3")
			end,
			["OnRemove"] = function(ply, item)
				EndBuff(ply, item, "I")
				ply:falloutNotify("You are no longer wearing FOA uniform", "ui/notify.mp3")
			end,
		["damage"] = 40,
	},
	["armor_recon"] = { -- Custom order import for bsharps#7467
		["name"] = "MEF Combat Armor",
		["desc"] = "Combat armor worn by the Midwestern chapters of the Brotherhood of Steel | MEF - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group520",
		["armsModel"] = false,
		["itemModel"] = "models/thespireroleplay/items/clothes/group012.mdl",
		["itemModelSkin"] = 2,
		["skin"] = 12,
		["rarity"] = 3,
		["damage"] = 60,
		["speed"] = -2
	},
	["armor_scorched"] = { -- 5.0 Community Update
		["name"] = "T-45d Scorched Sierra Power Armor",
		["desc"] = "A set of army issue T-45d Power Armor | NCR - FACTION ARMOR",
		["type"] = "body",
		["path"] = "models/thespireroleplay/humans/group521/armor.mdl",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["armsModel"] = false,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a Colonel of the NCR", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a Colonel of the NC ", "ui/notify.mp3")
		end,
		["rarity"] = 5,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 90,
		["noFall"] = true,
		["speed"] = -20
	},
	["armor_colonel"] = { -- Ported from legacy system
		["name"] = "Enclave Officer Uniform",
		["desc"] = "An outfit worn by the commander of the Enclave | ENCLAVE - FACTION OFFICER ARMOR",
		["type"] = "body",
		["itemModel"] = "models/fallout/apparel/centuriongo.mdl",
		["modelType"] = "group522",
		["armsModel"] = false,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the Enclave", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the Enclave ", "ui/notify.mp3")
		end,
		["rarity"] = 5,
		["damage"] = 70,
		["noFall"] = true,
	},
	["great_khan_boss_armor"] = { -- Custom order by Mr.Damplips#0564
		["name"] = "Great Khan Boss Armor",
		["desc"] = "A scavenged armor set worn by the bosses of the Great Khans | GK - FACTION ARMOR",
		["type"] = "body",
		["itemModel"] = "models/fallout/apparel/legiongo.mdl",
		["modelType"] = "group526",
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a Great Khan", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a Great Khan", "ui/notify.mp3")
		end,
		["rarity"] = 4,
		["damage"] = 63,
		["noFall"] = true,
		["speed"] = 8
	},
	["militia_ranger_armor"] = { -- Custom order by Meeps#0690
		["name"] = "Hopeville Patriot Armor",
		["desc"] = "A set of Elite Riot Gear refurbished from dead Riot Rangers to wield the mark of the Militia | MILITIA - FACTION ARMOR",
		["type"] = "body",
		["path"] = "models/thespireroleplay/humans/group527/male.mdl",
		["itemModel"] = "models/fallout/apparel/centuriongo.mdl",
		["armsModel"] = "models/thespireroleplay/humans/group527/arms/male_arm.mdl",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of the Militia", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of the Militia", "ui/notify.mp3")
		end,
		["damage"] = 70,
	},
    ["nuclear_short_shorts"] = {
        ["name"] = "Nuclear Shorts Armor",
        ["desc"] = "Short shorts that give the wearer optimal air flow to the area that matters the most. | NP - FACTION ARMOR",
        ["type"] = "body",
        ["itemModel"] = "models/thespireroleplay/items/clothes/group020.mdl",
        ["modelType"] = "group550",
        ["OnWear"] = function(ply, item)
            ply:falloutNotify("You are dressed as a Nuclear Patriot", "ui/notify.mp3")
        end,
        ["OnRemove"] = function(ply, item)
            ply:falloutNotify("You are no longer dressed as a Nuclear Patriot", "ui/notify.mp3")
        end,
        ["rarity"] = 4,
        ["damage"] = 60,
        ["noFall"] = true,
        ["speed"] = 10
    },
	["dr_gunslinger_armor"] = { -- Custom order by Meeps#0690
		["name"] = "Desert Ranger Gunslinger Armor",
		["desc"] = "A make-shift set of Desert Ranger armor modified to be more mobile | DR - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group525",
		["itemModel"] = "models/fallout/apparel/leatherarmor.mdl",
		["armsModel"] = false,
		["rarity"] = 4,
		["noFall"] = true,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a member of DR", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a member of DR", "ui/notify.mp3")
		end,
		["damage"] = 63,
		["speed"] = 8
	},
	["skybreaker_soldier_armor"] = { -- Custom order by noctusterrorem#4953
		["name"] = "Skybreaker Nimbus Agent Armor",
		["desc"] = "A set of futuristic armor designed for high altitude warfare worn by the Skybreakers | SKYBREAKER - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group533",
		["itemModel"] = "models/thespireroleplay/items/clothes/group101.mdl",
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a Skybreaker", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a Skybreaker", "ui/notify.mp3")
		end,
		["damage"] = 55,
		["speed"] = 0
	},
	["skybreaker_nco_armor"] = { -- Custom order by noctusterrorem#4953
		["name"] = "Skybreaker Altitude Agent Armor",
		["desc"] = "A set of futuristic armor designed for high altitude warfare worn by the Skybreakers | SKYBREAKER - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group530",
		["itemModel"] = "models/thespireroleplay/items/clothes/group101.mdl",
		["rarity"] = 3,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a Skybreaker", "ui/notify.mp3")
			ply:Give("weapon_stealthboy_stealthsuit")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a Skybreaker", "ui/notify.mp3")
			ply:StripWeapon("weapon_stealthboy_stealthsuit")
		end,
		["damage"] = 62,
		["speed"] = 0
	},
	["skybreaker_officer_armor"] = { -- Custom order by noctusterrorem#4953
		["name"] = "Skybreaker Stratoranger Armor",
		["desc"] = "A set of futuristic armor designed for high altitude warfare worn by the Skybreakers | SKYBREAKER - FACTION ARMOR",
		["type"] = "body",
		["path"] = "models/thespireroleplay/humans/group529/male.mdl",
		["malePrefix"] = "",
		["femalePrefix"] = "",
		["itemModel"] = "models/fallout/apparel/centuriongo.mdl",
		["armsModel"] = false,
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a Skybreaker", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a Skybreaker", "ui/notify.mp3")
		end,
		["damage"] = 68,
		["speed"] = 0
	},
	["skybreaker_hellbreaker_pa"] = { -- Custom order by noctusterrorem#4953
		["name"] = "Skybreaker Meteor T-45s Power Armor",
		["desc"] = "A set of futuristic power armor worn by the Skybreakers | SKYBREAKER - FACTION ARMOR",
		["type"] = "body",
		["path"] = "models/thespireroleplay/humans/group532/armor.mdl",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["armsModel"] = false,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a Skybreaker", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a Skybreaker", "ui/notify.mp3")
		end,
		["rarity"] = 3,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,	-- FIXME: Placeholder
		["noFall"] = true,
		["speed"] = -20	-- FIXME: Placeholder
	},
	["skybreaker_cosmic_pa"] = { -- Custom order by noctusterrorem#4953
		["name"] = "Skybreaker Cold Fusion C-F1 Power Armor",
		["desc"] = "A set of futuristic tesla power armor worn by the Skybreakers | SKYBREAKER - FACTION ARMOR",
		["type"] = "body",
		["path"] = "models/thespireroleplay/humans/group531/male.mdl",
		["itemModel"] = "models/fallout/apparel/amwpa.mdl",
		["armsModel"] = false,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as a Skybreaker", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as a Skybreaker", "ui/notify.mp3")
		end,
		["rarity"] = 4,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 80,
		["noFall"] = true,
		["speed"] = -20,
	},
	["armor_legion_pa"] = { -- 6.0 Armor Update
		["name"] = "Legion Power Armor",
		["desc"] = "A set of Power Armor, with a painted bull. Worn by the Caesar's Legion | LEGION - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group892",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as the Legion", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as the Legion", "ui/notify.mp3")
		end,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 72,
		["noCore"] = true,
		["noFall"] = true,
		["speed"] = -10
	},
	
	["armor_legion_championpa"] = { -- 6.0 Armor Update
		["name"] = "Legion Champion Power Armor",
		["desc"] = "A set of Power Armor for the Champion(s) of the Legion.| LEGION - FACTION OFFICER ARMOR",
		["type"] = "body",
		["modelType"] = "group891",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as the Legion", "ui/notify.mp3")
			BuffStat(ply, item, "P", 3)
			BuffStat(ply, item, "S", 3)
			BuffStat(ply, item, "A", 3)
		end,
		["OnRemove"] = function(ply, item)
			EndBuff(ply, item, "A")
			EndBuff(ply, item, "S")
			EndBuff(ply, item, "P")
			ply:falloutNotify("You are no longer dressed as the Legion", "ui/notify.mp3")
		end,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 75,
		["noCore"] = true,
		["noFall"] = true,
		["speed"] = -20
	},
	["armor_legion_centurionheavy"] = { -- 6.0 Armor Update
		["name"] = "Centurion Heavy Power Armor",
		["desc"] = "A set of centurion armor with a T-51 shoulder pad, allowing for more extensive protection and mobility. | LEGION - FACTION OFFICER ARMOR",
		["type"] = "body",
		["modelType"] = "group523",
		["itemModel"] = "models/fallout/apparel/power_armor.mdl",
		["rarity"] = 4,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as the Legion", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as the Legion", "ui/notify.mp3")
		end,
		["powerarmor"] = true,
		["footstep"] = Armor.PAFootstep,
		["damage"] = 80,
		["noCore"] = true,
		["noFall"] = true,
		["speed"] = -20
	},
	["ranger_outfit"] = {  -- 6.0 Armor Update
		["name"] = "NCR Ranger Outfit",
		["desc"] = "A set quality made pants and shirt for baddest cowboy | NCR - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group506",
		["itemModel"] = "models/thespireroleplay/items/clothes/group101.mdl",
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as the NCR", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as the NCR", "ui/notify.mp3")
		end,
		["damage"] = 63,
		["speed"] = 0
	},
	["pla_infantry_green"] = { -- 6.0 Armor Update
		["name"] = "Chinese Army Uniform",
		["desc"] = "A green camo like Chinese Army Uniform used by the great Red Army | PLA - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group889",
		["itemModel"] = "models/thespireroleplay/items/clothes/group006.mdl",
		
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as the PLA", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as the PLA", "ui/notify.mp3")
		end,
		["damage"] = 60,
		["speed"] = 0
	},
	["pla_infantry_urban"] = { -- 6.0 Armor Update
		["name"] = "Urban Chinese Army Uniform",
		["desc"] = "An urban camo like Chinese Army Uniform used by the great Red Army | PLA - FACTION ARMOR",
		["type"] = "body",
		["modelType"] = "group890",
		["itemModel"] = "models/thespireroleplay/items/clothes/group006.mdl",
		["rarity"] = 2,
		["OnWear"] = function(ply, item)
			ply:falloutNotify("You are dressed as the PLA", "ui/notify.mp3")
		end,
		["OnRemove"] = function(ply, item)
			ply:falloutNotify("You are no longer dressed as the PLA", "ui/notify.mp3")
		end,
		["damage"] = 55,
		["speed"] = 0
	},
	["wb-power-armor-w"] = {
        ["name"] = "WB Scourge Power Armor (White)",
        ["desc"] = "A set of advanced power armor used by the Washington Brotherhood | WB - FACTION ARMOR",
        ["itemModel"] = "models/fallout/apparel/amwpa.mdl",
        ["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
        ["path"] = "models/player/wbos/power-armor.mdl",
        ["rarity"] = 4,
        ["type"] = "body",
        ["powerarmor"] = true,
        ["footstep"] = Armor.PAFootstep,
        ["damage"] = 80,
        ["noCore"] = true,
        ["noFall"] = true,
        ["speed"] = -20,
    },
    ["wb-power-armor-p"] = {
        ["name"] = "WB Scourge Power Armor (Purple)",
        ["desc"] = "A set of advanced power armor used by the Washington Brotherhood | WB - FACTION ARMOR",
        ["itemModel"] = "models/fallout/apparel/amwpa.mdl",
        ["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
        ["path"] = "models/player/wbos/power-armor.mdl",
        ["rarity"] = 4,
        ["skin"] = 1,
        ["type"] = "body",
        ["powerarmor"] = true,
        ["footstep"] = Armor.PAFootstep,
        ["damage"] = 80,
        ["noCore"] = true,
        ["noFall"] = true,
        ["speed"] = -20,
    },
    ["wb-power-armor-o-p"] = {
        ["name"] = "WB Scourge Officer Power Armor (Purple)",
        ["desc"] = "A set of advanced power armor used by the Washington Brotherhood | WB - FACTION OFFICER ARMOR",
        ["itemModel"] = "models/fallout/apparel/amwpa.mdl",
        ["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
        ["path"] = "models/player/wbos/power-armor-command.mdl",
        ["rarity"] = 4,
        ["skin"] = 1,
        ["type"] = "body",
        ["powerarmor"] = true,
        ["footstep"] = Armor.PAFootstep,
        ["damage"] = 85,
        ["noCore"] = true,
        ["noFall"] = true,
        ["speed"] = -20,
    },
    ["wb-power-armor-o"] = {
        ["name"] = "WB Scourge Officer Power Armor (White)",
        ["desc"] = "A set of advanced power armor used by the Washington Brotherhood | WB - FACTION OFFICER ARMOR",
        ["itemModel"] = "models/fallout/apparel/amwpa.mdl",
        ["armsModel"] = "models/thespireroleplay/humans/group123/arms/male_arm.mdl",
        ["path"] = "models/player/wbos/power-armor-command.mdl",
        ["rarity"] = 4,
        ["type"] = "body",
        ["powerarmor"] = true,
        ["footstep"] = Armor.PAFootstep,
        ["damage"] = 85,
        ["noCore"] = true,
        ["noFall"] = true,
        ["speed"] = -20,
    },
}
Armor.Config.WeaponAccessories = {}
Armor.Config.SkillPoints = 9
Armor.Config.SurgeryCost = 0
Armor.Config.SurgeonModel = "models/visualitygaming/fallout/prop/autodoc_mk3.mdl"
Armor.Config.ExistanceDistance = 4500
Armor.Config.ViewmodelArms = nil
Armor.Config.DefaultBody = "group100"
Armor.Config.DefaultClothing = "mercgruntdirty"

Armor.Config.UseOldCharCreation = {
	["robot"] = true,
	["firegeckos"] = true,
	["molemen"] = true,
	["monster"] = true,
	["sentry"] = true,
	["feral"] = true,
	["supermutant"] = true,
	["mefsuper"] = true,
	["talonsuper"] = true,
	["mefsuper"] = true,
	["thinktanksuper"] = true,
	["unity"] = true,
	["institute"] = true,
	["mefdeathclaw"] = true,
	["securitron"] = true,
	["creature"] = true,
	["hunter"] = true
}

Armor.Config.SkillDescs = {
	["Strength"] = "Strength is a measure of your raw physical power. It affects the damage of your melee attacks & melee skills.",
	["Perception"] = "Perception is your environmental awareness and 'sixth sense', it affects damage of your ranged attacks.",
	["Endurance"] = "Endurance is a measure of your overall physical fitness. It affects your stamina.",
	["Charisma"] = "Charisma is your ability to charm and convince others. It affects your passive caps gain & social research.",
	["Intelligence"] = "Intelligence is a measure of your overall mental acuity. It affects research & crafting skills.",
	["Agility"] = "Agility is a measure of your overall finese and reflexes. It affects your speed and agility skills.",
	["Luck"] = "Luck is a measure of your general good fortune, and affects your chances to get higher tier loot in many scenarios."
}

Armor.Config.PrecachePaths = {
	"models/thespireroleplay/humans",
	"models/thespireroleplay/items",
	"models/lazarusroleplay"
}

Armor.Config.DescLength = 325 -- Maximum length of description
Armor.Config.DescLenMin = 5 -- Minimum length of description
