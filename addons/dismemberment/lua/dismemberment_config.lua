--[[
	Format:
	["<Weapon classname>"] = "<Caliber name>"
]]
Dismemberment.Config.Weapons = {
	["weapon_357"] = "Sniper"
}

--[[
	Format:
	["<Caliber name>"] = {
		["Multipliers"] = {
			[<Hitgroup enum>] = <Damage multiplier>
		},
		["LethalDismembermentChance"] = <Chance of dismemberment on a lethal shot>
	}
]]
Dismemberment.Config.Calibers = {
	["Sniper"] = {
		["Multipliers"] = {
			[HITGROUP_HEAD] = 6,
			[HITGROUP_LEFTARM] = 0.75,
			[HITGROUP_RIGHTARM] = 0.75,
			[HITGROUP_LEFTLEG] = 0.75,
			[HITGROUP_RIGHTLEG] = 0.75,
			[HITGROUP_STOMACH] = 1,
			[HITGROUP_CHEST] = 1
		},
		["LethalDismembermentChance"] = 1
	},
	["Heavy"] = {
		["Multipliers"] = {
			[HITGROUP_HEAD] = 1.25,
			[HITGROUP_LEFTARM] = 0.75,
			[HITGROUP_RIGHTARM] = 0.75,
			[HITGROUP_LEFTLEG] = 0.75,
			[HITGROUP_RIGHTLEG] = 0.75,
			[HITGROUP_STOMACH] = 1,
			[HITGROUP_CHEST] = 1
		},
		["LethalDismembermentChance"] = 0.5
	},
	["Shotgun"] = {
		["Multipliers"] = {
			[HITGROUP_HEAD] = 1.25,
			[HITGROUP_LEFTARM] = 0.75,
			[HITGROUP_RIGHTARM] = 0.75,
			[HITGROUP_LEFTLEG] = 0.75,
			[HITGROUP_RIGHTLEG] = 0.75,
			[HITGROUP_STOMACH] = 1,
			[HITGROUP_CHEST] = 1
		},
		["LethalDismembermentChance"] = 0.5
	},
	["Rifle"] = {
		["Multipliers"] = {
			[HITGROUP_HEAD] = 1.5,
			[HITGROUP_LEFTARM] = 0.75,
			[HITGROUP_RIGHTARM] = 0.75,
			[HITGROUP_LEFTLEG] = 0.75,
			[HITGROUP_RIGHTLEG] = 0.75,
			[HITGROUP_STOMACH] = 1,
			[HITGROUP_CHEST] = 1
		},
		["LethalDismembermentChance"] = 0.8
	},
	["Energy"] = {
		["Multipliers"] = {
			[HITGROUP_HEAD] = 1.8,
			[HITGROUP_LEFTARM] = 0.5,
			[HITGROUP_RIGHTARM] = 0.5,
			[HITGROUP_LEFTLEG] = 0.5,
			[HITGROUP_RIGHTLEG] = 0.5,
			[HITGROUP_STOMACH] = 1.2,
			[HITGROUP_CHEST] = 1.2
		},
		["LethalDismembermentChance"] = 0.8
	},
	["Revolver"] = {
		["Multipliers"] = {
			[HITGROUP_HEAD] = 8,
			[HITGROUP_LEFTARM] = 1,
			[HITGROUP_RIGHTARM] = 1,
			[HITGROUP_LEFTLEG] = 1,
			[HITGROUP_RIGHTLEG] = 1,
			[HITGROUP_STOMACH] = 1,
			[HITGROUP_CHEST] = 1
		},
		["LethalDismembermentChance"] = 1
	},
	["Pistol"] = {
		["Multipliers"] = {
			[HITGROUP_HEAD] = 1.5,
			[HITGROUP_LEFTARM] = 1,
			[HITGROUP_RIGHTARM] = 1,
			[HITGROUP_LEFTLEG] = 1,
			[HITGROUP_RIGHTLEG] = 1,
			[HITGROUP_STOMACH] = 1,
			[HITGROUP_CHEST] = 1
		},
		["LethalDismembermentChance"] = 1
	},
	["Energypistol"] = {
		["Multipliers"] = {
			[HITGROUP_HEAD] = 1.8,
			[HITGROUP_LEFTARM] = 0.75,
			[HITGROUP_RIGHTARM] = 0.75,
			[HITGROUP_LEFTLEG] = 0.75,
			[HITGROUP_RIGHTLEG] = 0.75,
			[HITGROUP_STOMACH] = 1.2,
			[HITGROUP_CHEST] = 1.2
		},
		["LethalDismembermentChance"] = 0.5
	},
	["Meleelight"] = {
		["Multipliers"] = {
			[HITGROUP_HEAD] = 2,
			[HITGROUP_LEFTARM] = 1,
			[HITGROUP_RIGHTARM] = 1,
			[HITGROUP_LEFTLEG] = 1,
			[HITGROUP_RIGHTLEG] = 1,
			[HITGROUP_STOMACH] = 1,
			[HITGROUP_CHEST] = 1
		},
		["LethalDismembermentChance"] = 1
	},
	["Meleeheavy"] = {
		["Multipliers"] = {
			[HITGROUP_HEAD] = 2,
			[HITGROUP_LEFTARM] = 1,
			[HITGROUP_RIGHTARM] = 1,
			[HITGROUP_LEFTLEG] = 1,
			[HITGROUP_RIGHTLEG] = 1,
			[HITGROUP_STOMACH] = 1,
			[HITGROUP_CHEST] = 1
		},
		["LethalDismembermentChance"] = 1
	}
}

--Arm gib = models/gibs/humans/mgib_06.mdl
--Leg gib = models/gibs/humans/mgib_07.mdl
Dismemberment.Config.DismembermentZones = {
	[HITGROUP_HEAD] = {
		["Bone"] = "ValveBiped.Bip01_Head1",
		["Attachment"] = 1,
		["ScaleBones"] = {
			"ValveBiped.Bip01_Head1"
		},
		["Gibs"] = {
			["models/gibs/humans/eye_gib.mdl"] = 2,
			["models/gibs/humans/brain_gib.mdl"] = 1
		}
	}
}

--If a weapon is not in Dismemberment.Config.Weapons it will be assumed to be this caliber
Dismemberment.Config.DefaultCaliber = "Rifle"
Dismemberment.Config.GibLife = 6 --How long gibs will exist for
