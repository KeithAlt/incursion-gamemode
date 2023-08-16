WorkshopDL.LoadScreenModelInterval = 10
WorkshopDL.LoadScreenHintsInterval = 15

WorkshopDL.RequiredContent = {
	"2172077074", -- Claymore Creature Content - Loading screen NPCs & materials
	"131759821", -- VJ Base
	"808687122", -- Runescape overhnead chat text material
	"104691717", -- PAC3, to risky to not DL
	"685130934", -- Server Guard required assets
	"2901462949", -- Required cgc_capitalwasteland map file
	"553208927", -- Required rp_fallout3_v002 Materials 1
	"917181417", -- Required rp_fallout3_v002 Materials and Models
	"553164977", -- Requiredrp_fallout3_v002 Models
	"2901576932", -- Claymore Gaming Icons 2.0 (https://steamcommunity.com/sharedfiles/filedetails/?id=2901576932)

	/**
	"2247476467", -- Unlisted Model Essentials (rp_newvegas_urfim Map Models)
	"2247498470", -- Unlisted Material Essentials (rp_newvegas_urfim Map Materials)
	"2181121782", -- Unlisted cgc_capitalwasteland map assets & bsp
	"553196039", -- rp_fallout3_v002 Materials 1 - Map content
	"553208927", -- rp_fallout3_v002 Materials 2 - Map content
	"917181417", -- rp_fallout3_v002 Materials & Models - Map content
	"553184886", -- rp_fallout3_v002 Sounds - Map content
	"553164977", --rp_fallout3_v002 Models - Map content
	"746838981", --TheHub.Click - F:NV RP Models - Loading screen models
	"750318333", --TheHub.Click - F:NV RP NPCs Materials - Loading screen models
	**/
}

WorkshopDL.LoadscreenSequences = {
	["models/fallout/mantis.mdl"] = {
		"walk",
		"run",
		"mtidle",
		"specialidle_alert"
	},
	["models/fallout/cazadore.mdl"] = {
		"walk",
		"run",
		"mtidle",
		"h2haim"
	},
	["models/fallout/gecko.mdl"] = {
		"walk",
		"run",
		"mtidle"
	},
	["models/fallout/deathclaw.mdl"] = {
		"walk",
		"run",
		"mtidle"
	},
	["models/fallout/mistergutsy.mdl"] = {
		"walk",
		"run",
		"mtidle"
	},
	["models/fallout/sentrybot.mdl"] = {
		"walk_hurt",
		"walk",
		"run",
		"mtidle",
		"2hhattackspin"
	},
	["models/fallout/centaur.mdl"] = {
		"walk_hurt",
		"walk",
		"run",
		"mtidle",
		"h2haim"
	},
	["models/fallout/radscorpion.mdl"] = {
		"walk_hurt",
		"walk",
		"run",
		"mtidle",
		"h2hattackpower"
	}
}
WorkshopDL.LoadscreenNoBodygroups = {
	["models/fallout/gecko.mdl"] = true
}

WorkshopDL.Hints = {
	"Eating and drinking are musts in the Wasteland. Make sure to stock up on Nuka Cola and Cram!",
	"[S.]P.E.C.I.A.L. - Your Strength stat increases your Melee Damage and ability to resist kidnappers!",
	"S.[P.]E.C.I.A.L. - Your Perception stat increases your firearm effeciency!",
	"S.P.[E.]C.I.A.L. - Your Endurance stat increases your AP Pool, improving VATS and your Sprint duration!",
	"S.P.E.[C.]I.A.L. - Your Charisma stat gifts you with passive cap income!",
	"S.P.E.C.[I.]A.L. - Your Intelligence stat improves your research effeciency and allows you to craft advanced weapons/consumables!",
	"S.P.E.C.I.[A.]L. - Your Agility stat improves your AP regeneration and sprint speed!",
	"S.P.E.C.I.A.[L.] - Your Luck stat improves your EXP gain from looting and gives you better loot drops!",
	"The Wasteland has many factions. Make sure to explore and learn more about them before choosing!",
	"All wastelanders have their own Karma Repuation. You gain and lose karma based on your faction and who you murder in your travels.",
	"Even though it's the Wasteland, there are rules we all follow. Make sure to read them before getting to adventurous!",
	"If you're unsure of what to do when first arriving, try exploring the Wasteland and meeting some of the people. We highly recommend you join a faction.",
	"Be wary of strangers. Not everyone is out to be a friendly fellow.",
	"The New California Republic stands for democracy and justice. They continue their fight to protect those who can't do it themselves. They also are fond of taxes.",
	"The Brotherhood of Steel stands for honor and the greater good. They continue their campaign of extermination against the Mutant threats and the preservation of technology.",
	"Caesar's Legion stands for strength and absolutes. They continue their conquest against the profligates who dare rival the one and only Caesar.",
	"Ad Victoriam - To Victory, a Latin phrase often used by Brotherhood of Steel soldiers.",
	"Profligate - Waste of Resources, a Latin phrase and name often used by Caesar's Legion to insult those who oppose them.",
	"Dissolute - One without purpose, a Latin phrase and name often used by Caesar's Legion on those who have no value to the Legion.",
	"Ranger Business - I would tell you, but it's Ranger business.",
	"Steel be with you - A phrase often used by members of Elder Lyon's Chapter of the Brotherhood of Steel to wish someone the best in their next journey.",
	"The Wasteland is best explored with a partner. It's highly advised you find one.",
	"Press and hold 'R' to unholster a weapon.",
	"Press 'F1' to open your inventory and character menu.",
	"Press 'G' to raise your hands and surrender.",
	"Type '!help <Message>' to request staff assistance if you need it.",
	"Type '@ <Message>' to report someone breaking the rules if you spot it.",
	"Getting addicted to a chem gives you a passive buff if you continue to feed your addiction.",
	"You gain EXP for looting, farming, harvesting, killing, and just for playing!",
	"Kidnapping is a real threat in the Wasteland. Always watch your back and never trust free candy.",
	"If you have performance issues, we recommend the x64 build of Garry's Mod.",
	"Never say 'Knock Knock Enclave'.",
	"Make sure to join our Discord. Many factions require it!"
}

WorkshopDL.Collections = {"948435070"}
WorkshopDL.ImgurAlbumID = "qcOIWGP"
WorkshopDL.ImgurClientID = "c57ca2ca8306be5"
