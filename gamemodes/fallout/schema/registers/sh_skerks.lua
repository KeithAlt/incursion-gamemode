local skerks = {
	["heavyweapons"] = {
		["title"] = "Broad Shoulders",
		["desc"] = "Do you lift bro? You can now wield heavy weapons without the use of Power Armor.",
		["model"] = "models/fallout/weapons/proj_mininuke.mdl",
		["tiers"] = {
			[1] = {
				["desc"] = "Ability to wield heavy weapons with no negative effects.",
				["level"] = 50,
				["points"] = 5,
				["special"] = {
					["S"] = 15,
				},
			},
		},
	},
	["nofalldmg"] = {
		["title"] = "Rubber Bones",
		["desc"] = "Thanks to the high level of rubber in your bones you no longer take fall damage.",
		["model"] = "models/props_junk/shoe001a.mdl",
		["tiers"] = {
			[1] = {
				["desc"] = "Fall damage is cut down by half.",
				["level"] = 1,
				["points"] = 2,
			},
			[2] = {
				["desc"] = "Total immunity from all fall damage.",
				["level"] = 40,
				["points"] = 3,
			},
		},
	},
	["healingkill"] = {
		["title"] = "Grim Healer",
		["desc"] = "Gain the ability to leech health from your fallen foes.",
		["model"] = "models/Gibs/HGIBS.mdl",
		["tiers"] = {
			[1] = {
				["desc"] = "Restores 10 health when you kill another player.\n(Can only be triggered once every 30 seconds)",
				["level"] = 30,
				["points"] = 3,
			},
			[2] = {
				["desc"] = "Restores 20 health when you kill another player.\n(Can only be triggered once every 15 seconds)",
				["level"] = 50,
				["points"] = 4,
			},
		},
	},
	["weapcrafting"] = {
		["title"] = "Tinker Tim",
		["desc"] = "Gain the ability to craft most projectile weapons at the workbench.",
		["model"] = "models/halokiller38/fallout/weapons/pistols/10mmpistolextendedmag.mdl",
		["tiers"] = {
			[1] = {
				["desc"] = "Allows to you use blueprints and materials to craft most projecwtile weapons.",
				["level"] = 10,
				["points"] = 2,
			},
		},
	},
	["noaddict"] = {
		["title"] = "Frequent Addict",
		["desc"] = "Your frequent chem use grants you half the likelyhood to get addicted.",
		["model"] = "models/mosi/fallout4/props/aid/daddyo.mdl",
		["tiers"] = {
			[1] = {
				["desc"] = "You become half as likely to get addicted to chems.",
				["level"] = 35,
				["points"] = 5
			}
		}
	},
	["norads"] = {
		["title"] = "Rad Man",
		["desc"] = "You become immune to radiation.",
		["model"] = "models/fallout/apparel/gscexohelmetgo.mdl",
		["tiers"] = {
			[1] = {
				["desc"] = "You become immune to radiation.",
				["level"] = 30,
				["points"] = 3
			}
		}
	},
	["lockpick"] = {
		["title"] = "Lockpicking",
		["desc"] = "Get into places you shouldn't be.",
		["model"] = "models/mosi/fallout4/buildkit/wood/door.mdl",
		["tiers"] = {
			[1] = {
				["desc"] = "You can lockpick average doors.",
				["level"] = 10,
				["points"] = 2
			},
			[2] = {
				["desc"] = "You can lockpick deployable utility doors.",
				["level"] = 20,
				["points"] = 3
			},
			[3] = {
				["desc"] = "You can lockpick extractors.",
				["level"] = 50,
				["points"] = 6
			}
		}
	},
	["chemist"] = {
		["title"] = "Heisenberg",
		["desc"] = "Your experience in chemistry makes your chems more potent.",
		["model"] = "models/mosi/fallout4/props/aid/jet.mdl",
		["tiers"] = {
			[1] = {
				["desc"] = "Chems concocted by you are 10% more potent.",
				["level"] = 20,
				["points"] = 3,
				["special"] = {
					["I"] = 10
				},
			},
			[2] = {
				["desc"] = "Chems concocted by you are 15% more potent.",
				["level"] = 35,
				["points"] = 3,
				["special"] = {
					["I"] = 20
				},
			}
		}
	},
/**
	["armormodding"] = {
		["title"] = "Armorsmith",
		["desc"] = "You have the skills to modify armor.",
		["model"] = "models/fallout/headgear/combatarmorhelmet.mdl",
		["tiers"] = {
			[1] = {
				["desc"] = "You can modify armor (Not including PA)",
				["level"] = 15,
				["points"] = 1,
				["special"] = {
					["I"] = 5
				},
			},
		}
	},
	["paarmormodding"] = {
		["title"] = "Power Armor Modding",
		["desc"] = "You have the skills to modify Power Armor.",
		["model"] = "models/fallout/apparel/t60pahelmetgo.mdl",
		["tiers"] = {
			[1] = {
				["desc"] = "You can modify Power Armor.",
				["level"] = 30,
				["points"] = 5,
				["prerequisite"] = {
					["armormodding"] = 1,
				},
				["special"] = {
					["I"] = 20
				},
			},
		}
	},
**/
	["vats"] = {
		["title"] = "VATS",
		["desc"] = "You have the ability to use VATS",
		["model"] = "models/llama/pipboy3000.mdl",
		["tiers"] = {
			[1] = {
				["desc"] = "You can use VATS.",
				["level"] = 15,
				["points"] = 3,
				["special"] = {
					["P"] = 15
				},
			},
		}
	}
}

for id, skerk in pairs(skerks) do
	nut.skerk.register(id, skerk)
end
