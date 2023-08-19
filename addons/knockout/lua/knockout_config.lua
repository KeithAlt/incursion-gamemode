knockoutConfig.knockoutTime = 15
knockoutConfig.chanceKnockoutTime = 9
knockoutConfig.weps = {
	["nut_hands"] = true, -- jfists.lua is real class name
	["meleearts_axe_battleaxe"] = true,
	["weapon_baseballbat_hub"] = true,
	["weapon_sledgehammer_hub"] = true,
	["weapon_supersledge_hub"] = true,
	["weapon_nailboard_hub"] = true,
	["weapon_powerfist_hub"] = true,
	["weapon_thermiclance_hub"] = true,
	["weapon_fireaxe_hub"] = true,
	["weapon_leadpipe_hub"] = true,
	["weapon_fireaxe_hub"] = true,
	["weapon_hatchet_hub"] = true,
	["weapon_spikedknuckles"] = true,
	["weapon_shovel"] = true,
	["weapon_cattleprod"] = true,
	-----------------------------------
	["meleearts_bludgeon_bat"] = true,
	["meleearts_bludgeon_boommic"] = true,
	["meleearts_throwable_bottle"] = true,
	["meleearts_staff_bamboo"] = true,
	["meleearts_bludgeon_crowbar"] = true,
	["meleearts_bludgeon_guitar"] = true,
	["meleearts_staff_iron"] = true,
	["meleearts_bludgeon_pipe"] = true,
	["meleearts_staff_nunchucks"] = true,
	["meleearts_staff_poolcue"] = true,
	["meleearts_spear_pushbroom"] = true,
	["meleearts_spear_shovel"] = true,
	["meleearts_bludgeon_sledgehammer"] = true,
	["meleearts_bludgeon_stunstick"] = true,
	["meleearts_axe_battleaxe"] = true,
	["meleearts_staff_shock"] = true,
	["weapon_baseballbat_len_m2"] = true,
	["weapon_boxinggloves_len_m2"] = true,
	["weapon_brassknuckles_len_m2"] = true,
	["weapon_commiewacker_len_m2"] = true,
	["weapon_leadpipe_len_m2"] = true,
	["weapon_policebaton_len_m2"] = true,
	["weapon_powerfist_len_m2"] = true,
	["weapon_rebarclub_len_m2"] = true,
	["weapon_warclub_ke"] = true,
}
knockoutConfig.knockoutChance = { -- Knockout chance per level of the perk
	10,
	15
}
knockoutConfig.chargedKnockoutChance = 25 -- Knockout chance if the weapon is charged
knockoutConfig.powerArmorPenalty = 10 -- How much the chance is reduced by if the target is wearing PA
knockoutConfig.cuffTime = 3 -- Time in seconds that it will take to cuff a player
knockoutConfig.immunity = {
	["STEAM_0:0:551001551"] = true,
	["STEAM_0:0:12225865"] = true
}

knockoutConfig.forcedWeapon = "nut_keys"
