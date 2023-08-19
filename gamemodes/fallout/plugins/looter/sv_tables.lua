local droptables = {}

droptables["consumables"] = {
	common = {"ant_meat", "cig", "food_instamash", "electronics", "food_bubblegum", "food_sugar_bombs", "food_buzz_bites", "food_potato_crisps", "food_blambo_mac_and_cheese", "food_dog_food", "food_cotton_candy", "food_pork_and_beans", "human_flesh", "brahman_meat", "mole_meat", "radroach_meat", "food_preserved_cram", "food_dandy_boy_apples", "drink_dirty_water"},

	rare   = {"jet", "food_moldy_food", "cig_pack", "drink_vim", "ketoacid", "food_longneck_sardines", "food_funnel_cake", "food_fancy_lad_cakes", "drink_milk", "drink_lemonade", "food_salisbury_steak", "berrymentats", "orangementats", "grapementats", "psycho", "turbo", "steady", "rebound", "stimpack"},

	epic = {"modulator", "fixer", "drink_rum", "drink_bourbon", "daytripper", "doctorbag"},

	legendary = {"armormod_endurance", "food_the_cake", "food_mre", "armormod_strength", "food_deathclaw_egg", "armormod_intelligence", "armormod_luck", "xcell", "realdoctorsbag"}
}

droptables["blueprints"] = {
	common    = {},

	uncommon  = {},

	rare      = {"bp_weapon_r91assaultrifle", "bp_weapon_assaultcarbine", "bp_weapon_combatshotgun", "bp_weapon_battlerifle", "bp_weapon_laserriflescp", "bp_weapon_laserrifle", "bp_weapon_22mmpistolsil", "bp_weapon_44revolver", "bp_weapon_serviceriflereflex", "bp_weapon_caravanshotgun", "bp_weapon_9mmsmgdrum", "bp_weapon_9mmpistol", "bp_weapon_32pistol", "bp_weapon_45smg", "bp_weapon_45autopistol", "bp_weapon_32pistol", "bp_weapon_sawedoffshotgun", "bp_weapon_singleshotgun"},

	epic      = {"bp_weapon_varmintriflesilext", "bp_weapon_huntingshotgun", "bp_weapon_laserpdw", "bp_weapon_357revolverlonghdcyl", "bp_weapon_policepistol", "bp_weapon_laserpistol"},

	exotic    = {"bp_weapon_sniperriflesil", "bp_weapon_sniperrifle", "bp_weapon_marksmancarbine", "bp_weapon_cowboyrepeater", "bp_weapon_trailcarbine", "bp_weapon_127mmsmgsil", "bp_weapon_riotshotgun", "bp_weapon_chineseassaultrifle", "bp_weapon_huntingrifleext", "bp_weapon_plasmarifle"},

	legendary =	{"bp_weapon_huntingriflescp", "bp_weapon_tribeam", "bp_weapon_multiplasrifle", "bp_weapon_chinesepistol", "weapon_127mmpistolsil", "bp_weapon_plasmadefender"},

	mythic    = {"bp_weapon_grenaderifle", "bp_weapon_lmgext", "bp_weapon_smmg", "bp_weapon_bar", "bp_weapon_leveractionrifle", "bp_weapon_railwayrifle", "bp_weapon_missilelauncher", "bp_flamethrower", "bp_weapon_minigun", "bp_weapon_gatlinglaser"},

	cosmic    = {"bp_weapon_greatbeargrenaderifle", "bp_weapon_thumpthump", "bp_weapon_45autopistolu"}
}

droptables["frames_primary"] = {
	common    = {},

	uncommon  = {},

	rare      = {"frame_weapon_r91assaultrifle", "frame_weapon_assaultcarbine", "frame_weapon_caravanshotgun", "frame_weapon_combatshotgun", "frame_weapon_battlerifle", "frame_weapon_laserriflescp", "frame_weapon_laserrifle", "frame_weapon_serviceriflereflex", "frame_weapon_9mmsmgdrum", "frame_weapon_sawedoffshotgun", "frame_weapon_singleshotgun", "frame_weapon_45smg"},

	epic      = {"frame_weapon_varmintriflesilext", "frame_weapon_huntingshotgun", "frame_weapon_laserpdw"},

	exotic    = {"frame_weapon_sniperriflesil", "frame_weapon_sniperrifle", "frame_weapon_marksmancarbine", "frame_weapon_trailcarbine", "frame_weapon_cowboyrepeater", "frame_weapon_127mmsmgsil", "frame_weapon_riotshotgun", "frame_weapon_chineseassaultrifle", "frame_weapon_huntingrifleext", "frame_weapon_plasmarifle"},

	legendary =	{"frame_weapon_huntingriflescp", "frame_weapon_tribeam", "frame_weapon_multiplasrifle"},

	mythic    = {"frame_weapon_grenaderifle", "frame_weapon_bar", "frame_weapon_smmg",  "frame_weapon_lmgext", "frame_weapon_leveractionrifle", "frame_weapon_railwayrifle"},

	cosmic    = {"frame_weapon_greatbeargrenaderifle", "frame_weapon_thumpthump", "frame_weapon_gatlinglaser", "frame_flamethrower", "frame_weapon_missilelauncher"}
}

droptables["frames_sidearm"] = {
	common    = {},

	uncommon  = {"frame_weapon_9mmpistol", "frame_weapon_32pistol", "frame_weapon_45autopistol", "frame_weapon_32pistol"},

	rare      = {"frame_weapon_22mmpistolsil", "frame_weapon_44revolver"},

	epic      = {"frame_weapon_357revolverlonghdcyl", "frame_weapon_policepistol", "frame_weapon_laserpistol"},

	exotic    = {"frame_weapon_chinesepistol", "weapon_127mmpistolsil", "frame_weapon_plasmadefender"},

	legendary =	{"frame_weapon_huntingrevolver", "frame_weapon_plasmapistol"},

	mythic    = {"frame_weapon_rangersequoia"},

	cosmic    = {"frame_weapon_45autopistolu"},
}

droptables["components"] = {
	common   = {"scrap", "scrap", "scrap", "scrap", "component_wood", "component_ceramic", "component_wood", "component_ceramic", "component_wood", "component_ceramic", "component_wood", "component_ceramic", "component_adhesive"},

	uncommon = {"component_steel", "component_springs", "component_screws", "component_rubber", "component_steel", "component_springs", "component_screws", "component_rubber", "component_steel", "component_springs", "component_screws", "component_rubber", "component_steel", "component_springs", "component_screws", "component_rubber"},

	rare     = {"component_adhesive", "component_nuclear_material", "component_adhesive", "component_adhesive", "component_adhesive"},

	epic     = {"component_nuclear_material", "component_fiberoptics", "component_nuclear_material", "component_fiberoptics", "component_nuclear_material", "component_fiberoptics"}
}

droptables["firearms"] = {
	uncommon = {"weapon_bbgun"},

	epic      = {"tfa_fwp_combatrifle", "tfa_fwp_piperiflesemi", "weapon_handmadear", "tfa_fwp_piperevolver"},

	mythic    = {"weapon_acr", "weapon_corder_m14", "weapon_laser_rcw", "weapon_sniper_len", "tfa_fwp_plasmapistol", "weapon_cowboyrepeater_len", "weapon_combatshot"  },
}

droptables["melee"] = {
	common    = {"weapon_poolcue", "weapon_kitchenknife", "weapon_bballbatdirty", "weapon_shovel", "weapon_nailboard", "weapon_brassknuckles"},

	uncommon  = {"weapon_tireiron", "weapon_policebaton", "weapon_spikedknuckles", "weapon_cleaver", "weapon_straightrazor"},

	rare      = {"weapon_sledgehammer", "weapon_bowieknife", "weapon_nineiron", "weapon_combatknife", "weapon_trenchknife", "weapon_machete"},

	epic      = {"weapon_leadpipe", "weapon_fireaxe"},

	exotic    = {"weapon_hatchet"},

	legendary = {"weapon_dresscane", "weapon_commiewacker_len_m2", "weapon_boxinggloves_len_m2"},

	mythic    = {"weapon_deathclawgauntlet", "weapon_chineseofficersword", "weapon_bumpersword", "orbital", "chemx"},

	cosmic    = {"weapon_chancesknife", "weapon_lilysblade", "weapon_supersledge"}
}

droptables["armors"] = {
	common    = {},

	uncommon  = {},

	rare      = {"sunglasses", "tintedsunglasses", "blindglasses", "heartglasses", "menreadingglasses", "goggles", "greaser", "armor_kings", "wastelandhoodie", "headwrap", "tradercap", "baseball", "constructionhat"},

	epic      = {"bandana", "satchel", "armor_leathermeme","armor_trader", "memphiskidoutfit", "armor_vest", "cleanfarmersoveralls", "policehat", "prospectorhood", "motorlandhood", "hood", "partyhat"},

	exotic    = {"hoodtacticalhelmet", "armor_prostitute", "armor_whitelegs", "armor_raiderbadlands", "armor_jailrocker", "mysterious_fedora", "winterwear", "sombrero", "prewargasmask", "raidergasmask",  "hockeymask", "banditgasmask", "cowboycasualsb", "armor_suit", "mercgruntbloody", "mercgruntdirty", "bonnet", "firefighterhelmet", "shemaghgashood"},

	legendary = {"lightexternalarmor", "bounty_hunter_duster", "armor_oasisdruid", "armor_markedscout", "armor_nightwear", "armor_powderganger", "armor_raidercommando", "wintercombatarmor", "anchorage_headwear", "researcherclothing", "researcherclothinga", "researcherclothingc", "pimpout", "radiationsuit", "armor_mercenaryvet", "armor_mercoutfit", "skinmask", "tophat", "pimphat", "shemaghgas"},

	mythic    = {"whiteduster", "armor_courierduster", "alwhiteduster", "researcherclothingc", "strangerhat"},

	cosmic    = {"revenant"}
}

droptables["misc"] = {
	exotic = {"enclavekeycard"},

	orbital = {"unstablefev"}, -- Unique orbital drop only items

	cosmic    = {"transform_mutant", "weapon_corder_minilauncher", "weapon_corder_m2browning", "weapon_corder_cyberdog", "weapon_357lucky_len", "weapon_44mysterious_len", "weapon_maria_len", "weapon_corder_mefcaster", "weapon_corder_railwaysniper", "weapon_corder_r91"},
}

for i, v in pairs(droptables) do
	for x, y in pairs(v) do
		for b, z in pairs(y) do
			local _, err = nut.loot.addItem("master", x, z)
			if (err) then print(err) end;
		end;
	end;
end;
