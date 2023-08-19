local PLUGIN = PLUGIN

PLUGIN.name = "Deployables"
PLUGIN.author = "jonjo"
PLUGIN.desc = "Register deployable items"

PLUGIN.TotalLimit = 10
PLUGIN.DefaultIndividualLimit = 1

PLUGIN.DeployableLimits = {
	["turrets"] = 4,
	["doors"] = 2,
	["vehicle"] = 2
}

PLUGIN.Deployables = {
	["barcrate"] = {
		name = "Artillery Gun",
		desc = "A deployable artillery gun",
		model = "models/comradealex/bf1/fk96/fk96.mdl",
		ent = "turret_grenade"
	},
	["chimera"] = {
		name = "Chimera Tank Deployment Beacon",
		desc = "A receptor beacon used to deploy a Chimera Tank.",
		model = "models/props_lab/tpplug.mdl",
		ent = "chimera_tank"
	},
	["cloudgenerator"] = {
		name = "Pathogen Emitter",
		desc = "A deployable Cloud Emitter.",
		model = "models/props_junk/wood_crate002a.mdl",
		ent = "cloudgenerator",
		limit = 3
	},
	["cross"] = {
		name = "Legion Cross",
		desc = "A deployable crucifix that can be used to mount profligates.",
		model = "models/mosi/fallout4/props/fortifications/vaultcrate02.mdl",
		extra = function(ply, item, ent)
			ply:ChatPrint("[ CROSS ]  A victim will die after 3 minutes of being crucified")
		end,
		ent = "playercapture_cross"
	},
	["deployableturret"] = {
		name = "Deployable 14mm Turret",
		desc = "A deployable 14mm Turret.",
		model = "models/reach/weapons/turret/hmg_fix.mdl",
		ent = "turret_bullets2"
	},
	["deployableturret2"] = {
		name = "Deployable 40MM HE Turret",
		desc = "A deployable 14mm Turret.",
		model = "models/reach/weapons/turret/hmg_fix.mdl",
		ent = "turret_grenade"
	},
	["deployableturret3"] = {
		name = "Deployable 7.62x39mm Turret",
		desc = "A deployable 14mm Turret.",
		model = "models/reach/weapons/turret/hmg_fix.mdl",
		ent = "turret_bullets"
	},
	["deployableturret4"] = {
		name = "Deployable Railcannon Turret",
		desc = "A deployable 14mm Turret.",
		model = "models/reach/weapons/turret/hmg_fix.mdl",
		ent = "turret_rail"
	},
	["deployableturret6"] = {
		name = "Deployable 7.62mm Turret",
		desc = "A deployable 14mm Turret.",
		model = "models/reach/weapons/turret/hmg_fix.mdl",
		ent = "turret_bullets"
	},
	["draw_blackboard"] = {
		name = "Blackboard",
		desc = "A blackboard often used for educational purposes.",
		model = "models/metamist/blackboard.mdl",
		ent = "gsign_blackboard",
		extra = function(ply, item, ent)
			ent:SetSignOwnerID(ply:SteamID())
		end
	},
	["draw_poster"] = {
		name = "Wanted Poster",
		desc = "A paintable wanted poster.",
		model = "models/metamist/wantedposter.mdl",
		ent = "gsign_wantedposter",
		extra = function(ply, item, ent)
			ent:SetSignOwnerID(ply:SteamID())
		end
	},
	["draw_sign"] = {
		name = "Sign",
		desc = "A paintable sign.",
		model = "models/metamist/sign.mdl",
		ent = "gsign_normal",
		extra = function(ply, item, ent)
			ent:SetSignOwnerID(ply:SteamID())
		end
	},
	["draw_whiteboard"] = {
		name = "Whiteboard",
		desc = "A whiteboard often used for educational purposes.",
		model = "models/metamist/whiteboard.mdl",
		ent = "gsign_whiteboard",
		extra = function(ply, item, ent)
			ent:SetSignOwnerID(ply:SteamID())
		end
	},
	["farmwater"] = {
		name = "Farm Water",
		desc = "Water used to grow crops. Use and place this at a plot to help seeds grow.",
		model = "models/props_junk/metalgascan.mdl",
		ent = "farm_water"
	},
	["holotape"] = {
		name = "Holotape",
		desc = "A old dusted Holotape, the data seems lost but it could still be used to store new information.",
		model = "models/unconid/pc_models/floppy_disk_3_5.mdl",
		ent = "trm_disk"
	},
	/**
	["weapon_nuclearinit"] = {
		name = "Nuclear Warhead Signal Strike",
		desc = "A single-use nuclear strike that devestates the area of impact and covers the surrounding area in radiation fog | This item can be used any where at any time for any reason",
		model = "models/llama/briefcasedhalfopen.mdl",
		ent = "weapon_nuclearinit"
	},
	**/
	["mole_mininuke"] = {
		name = "Mole Miner Mininuke",
		desc = "A detonatable mininuke crafted and sold by the Mole Miners.",
		model = "models/cwfo3cwrp/mininuke.mdl",
		ent = "gb_mininuke"
	},
	["mole_superbomb"] = {
		name = "Mole Miner Superbomb",
		desc = "A detonatable bomb crafted and sold by the Mole Miners.",
		model = "models/chappi/bl15.mdl",
		ent = "gb_bl15"
	},
	["musicradio"] = {
		name = "[Base Utility] Musical Radio",
		desc = "A musical radio that played only the best tunes in the Wasteland.",
		model = "models/clutter/radio.mdl",
		ent = "fallout_radio"
	},
	["musicradio_enclave"] = {
		name = "Enclave Speaker",
		desc = "A mountable speaker that plays popular American songs and Eden speeches.",
		model = "models/props_wasteland/speakercluster01a.mdl",
		ent = "fallout_radio_enclave"
	},
	["refinedcrate"] = {
		name = "Refined Crate",
		desc = "A box that can be used to store Refined metal.",
		model = "models/zerochain/props_mining/zrms_storagecrate_closed.mdl",
		ent = "zrms_basket"
	},
	["repairkit"] = {
		name = "Terminal Repair Kit",
		desc = "A kit used to repair terminals.",
		model = "models/props_junk/cardboard_box004a_gib01.mdl",
		ent = "trm_repairkit"
	},
	["rocketammo"] = {
		name = "[Base Defense] Rocket Turret Ammo",
		desc = "A crate of ammo used to reload the rocket turrets.",
		model = "models/items/ammocrate_ar2.mdl",
		ent = "alydusbasesystems_consumable_samammo",
	},
	["slavecell"] = {
		name = "Slave Cell",
		desc = "A Cell used to hold uncooperative stock.",
		model = "models/scp173box/scp173containmentbox.mdl",
		ent = "playercapture_cell"
	},
	["terminal"] = {
		name = "Terminal",
		desc = "A terminal used to write on holotapes.",
		model = "models/sd_fallout4/terminal1.mdl",
		ent = "trm_terminal",
		limit = 2
	},
	["turretammo"] = {
		name = "[Base Defense] Defense Turret Ammo",
		desc = "A crate of ammo used to reload weapon turrets.",
		model = "models/items/ammocrate_ar2.mdl",
		ent = "alydusbasesystems_consumable_turretammo",
	},
	["armorbench"] = {
		name = "Armor Workbench",
		desc = "A bench that can be used to upgrade your armor.",
		model = "models/mosi/fallout4/furniture/workstations/weaponworkbench02.mdl",
		ent = "nut_modtable_armor"
	},
	["basealarm"] = {
		name = "[Base Defense] Siren",
		desc = "A base alarm that can be connected to a Base Controller to sound an alarm.",
		model = "models/weapons/keitho/turrets/workshopsiren.mdl",
		ent = "alydusbasesystems_module_fallout_siren",
		limit = 1
	},
	["basecamera"] = {
		name = "[Base Utility] Base Camera",
		desc = "A base camera that can be connected to a base controller and used to view your surroundings remotley.",
		model = "models/items/item_item_crate.mdl",
		ent = "alydusbasesystems_module_camera",
		extra = function(ply, item, ent)
			ply:ChatPrint("[ BASE DEFENSES ]  Make sure to Activate the Base Defense with a claimed Base Controller")
		end,
		limit = 2
	},
	["basecontroller"] = {
		name = "[Base Defense] Base Controller",
		desc = "A base controller that can be setup anywhere.",
		model = "models/weapons/keitho/turrets/workshopterminal.mdl",
		ent = "alydusbasesystems_basecontroller",
		extra = function(ply, item, ent)
			ply:ChatPrint("[ BASE DEFENSES ]  Claim the Controller and Deploy/Claim base defenses to activate")
		end,
		limit = 1
	},
	["baseproxyscanner"] = {
		name = "[Base Defense] Proximity Scanner",
		desc = "A base alarm that can be connected to a Base Controller to notify you when a person or creature approaches.",
		model = "models/items/item_item_crate.mdl",
		ent = "alydusbasesystems_module_proximitytrigger",
		extra = function(ply, item, ent)
			ply:ChatPrint("[ BASE DEFENSES ] Make sure to Activate the Base Defense with a claimed Base Controller")
		end,
		limit = 2
	},
	["baserocketturret"] = {
		name = "[Base Defense] Rocket Defense Turret",
		desc = "A base defense turret that can be setup and connected to a base controller. The rocket turret will shoot ALL incoming air vehicles. Make sure to fill the turret up with ammo!",
		model = "models/weapons/keitho/turrets/rocketturret.mdl",
		ent = "alydusbasesystems_module_fallout_rocket_turret",
		extra = function(ply, item, ent)
			ply:ChatPrint("[ BASE DEFENSES ] Make sure to Activate the Base Defense with a claimed Base Controller")
		end,
		limit = "turrets"
	},
	["basesearchlight"] = {
		name = "[Base Defense] Spotlight",
		desc = "A base searchlight that can be connected to a base controller. The lights will track whom are not yourself.",
		model = "models/weapons/keitho/turrets/spotlight.mdl",
		ent = "alydusbasesystems_module_fallout_searchlight",
		extra = function(ply, item, ent)
			ply:ChatPrint("[ BASE DEFENSES ] Make sure to Activate the Base Defense with a claimed Base Controller")
		end,
		limit = 2
	},
	["baseservo"] = {
		name = "[Base Utility] Base Doorservo",
		desc = "A base door servo that can be connected to a base controller and connected to a door allowing you to control it remotley.",
		model = "models/items/item_item_crate.mdl",
		ent = "alydusbasesystems_module_doorservo",
		limit = "doors"
	},
	["basetransmitter"] = {
		name = "[Base Utility] Local Transmitter",
		desc = "A base broadcaster that can be connected to a base controller and used to spread your voice through.",
		model = "models/props_lab/citizenradio.mdl",
		ent = "alydusbasesystems_module_transmitter",
		limit = 2
	},
	["baseturret"] = {
		name = "[Base Defense] MKI Auto Turret",
		desc = "A base defense turret that can be setup and connected to a base controller. You can adjust the targets of the turret via the controller. Make sure to fill the turret up with ammo!",
		model = "models/weapons/keitho/turrets/basicturret.mdl",
		ent = "alydusbasesystems_module_fallout_basic_turret",
		extra = function(ply, item, ent)
			ply:ChatPrint("[ BASE DEFENSES ]  Make sure to Activate the Base Defense with a claimed Base Controller")
		end,
		limit = "turrets"
	},
	["baseturretmkii"] = {
		name = "[Base Defense] MKII Auto Turret",
		desc = "An upgraded base defense turret that can be setup and connected to a base controller. You can adjust the targets of the turret via the controller. Make sure to fill the turret up with ammo!",
		model = "models/weapons/keitho/turrets/heavyturret.mdl",
		ent = "alydusbasesystems_module_fallout_basic_turret_2",
		extra = function(ply, item, ent)
			ply:ChatPrint("[ BASE DEFENSES ] Make sure to Activate the Base Defense with a claimed Base Controller")
		end,
		limit = "turrets"
	},
	["bomb"] = {
		name = "Improvised Mininuclear Timed Explosive",
		desc = "A deployable bomb that can be set to explode | This item can be deployed any where for any reason",
		model = "models/props_junk/cardboard_box004a_gib01.mdl",
		ent = "ent_timebomb"
	},
	["campfire"] = {
		name = "[Base Utility] Campfire",
		desc = "A campfire that can be setup anywhere.",
		model = "models/optinvfallout/campfire3.mdl",
		ent = "sent_vj_fireplace",
		limit = 1
	},
	["capturepod"] = {
		name = "[Base Utility] Capture Pod",
		desc = "A pod that can be used to hold kidnapped victims forcefully.",
		model = "models/maxib123/enclavedisplay.mdl",
		ent = "playercapture_pod"
	},
	["door"] = {
		name = "[Base Defense] Placeable Door",
		desc = "A placeable door used to protect you from the outside world",
		model = "models/optinvfallout/utilitydoor1.mdl",
		ent = "nut_anidoor_utilsmall",
		extra = function(ply, item, ent)
			ply:ChatPrint("[ BASE DEFENSES ]  Use the command '/pass' to specify a Password for the Door\n>> Use the command '/key' to create a Keycard to enter it")
		end,
		limit = "turrets"
	},
	["door_large"] = {
		name = "[Base Defense] Placeable Large Door",
		desc = "A placeable large door used to protect you from the outside world",
		model = "models/optinvfallout/utilitydoor1.mdl",
		ent = "nut_anidoor_utillarge",
		extra = function(ply, item, ent)
			ply:ChatPrint("[ BASE DEFENSES ]  Use the command '/pass' to specify a Password for the Door\n>> Use the command '/key' to create a Keycard to enter it")
		end,
		limit = "turrets"
	},
	["farmplot"] = {
		name = "[Base Utility] Farm Plot",
		desc = "A farm plot that can be setup anywhere.",
		model = "models/fallout/plot/planter.mdl",
		ent = "farm_planter",
		extra = function(ply, item, ent)
			ply:ChatPrint("[ FARMING ]  Seeds & Farm Water are needed to harvest crops")
		end,
		limit = 4
	},
	["healthstation"] = {
		name = "[Base Utility] Health Dispenser",
		desc = "A health station that can be placed and used to regenerate your vigor.",
		model = "models/health_dispenser.mdl",
		ent = "item_healthcharger",
		extra = function(ply, item, ent)
			ent:SetModel("models/health_dispenser.mdl")
		end,
		limit = 1
	},
	["jukebox"] = {
		name = "[Base Utility] Jukebox",
		desc = "A Pre-war Jukebox that has some classics!",
		model = "models/mosi/fallout4/props/radio/jukebox.mdl",
		ent = "fallout_jukebox",
		limit = 2
	},
	["fallout_jukebox_jazz"] = {
		name = "[Base Utility] Jazzy Jukebox",
		desc = "A Pre-war jazzy jukebox only found in the coolest of clubs",
		model = "models/mosi/fallout4/props/radio/jukebox.mdl",
		ent = "fallout_jukebox_jazz",
		limit = 2
	},
	["enclave_radio_tower"] = {
		name = "[Base Utility] Enclave Propoganda Tower",
		desc = "A broadcast tower that emits a very loud variety of Enclave music",
		model = "models/mosi/fallout4/props/fortifications/vaultcrate03.mdl",
		ent = "enclave_radio_tower",
		limit = 2
	},
	["laserammo"] = {
		name = "[Base Defense] Laser Turret Ammo",
		desc = "A crate of ammo used to reload the laser turrets.",
		model = "models/items/ammocrate_ar2.mdl",
		ent = "alydusbasesystems_consumable_laserammo",
	},
	["laserturret"] = {
		name = "[Base Defense] MKI Laser Turret",
		desc = "A base defense turret that can be setup and connected to a base controller. You can adjust the targets of the turret via the controller. Make sure to fill the turret up with ammo!",
		model = "models/weapons/keitho/turrets/laserturret.mdl",
		ent = "alydusbasesystems_module_fallout_laser_turret_1",
		extra = function(ply, item, ent)
			ply:ChatPrint("[ BASE DEFENSES ]  Make sure to Activate the Base Defense with a claimed Base Controller")
		end,
		limit = "turrets"
	},
	["laserturretmkii"] = {
		name = "[Base Defense] MKII Laser Turret",
		desc = "An upgraded base defense turret that can be setup and connected to a base controller. You can adjust the targets of the turret via the controller. Make sure to fill the turret up with ammo!",
		model = "models/weapons/keitho/turrets/laseradv.mdl",
		ent = "alydusbasesystems_module_fallout_laser_turret_2",
		extra = function(ply, item, ent)
			ply:ChatPrint("[ BASE DEFENSES ]  Make sure to Activate the Base Defense with a claimed Base Controller")
		end,
		limit = "turrets"
	},
	["melter"] = {
		name = "[Base Utility] Melter",
		desc = "A melter that can be used to melt refined metal into bars.",
		model = "models/zerochain/props_mining/zrms_melter.mdl",
		ent = "zrms_melter"
	},
	["minestation"] = {
		name = "[Base Utility] Mining Station",
		desc = "A mining entrance that will collect raw mine materials occasionally.",
		model = "models/zerochain/props_mining/mining_entrance.mdl",
		ent = "zrms_mineentrance_base"
	},
	["nukamachine"] = {
		name = "[Base Utility] Nuka-Cola Machine",
		desc = "A Nuka-Cola vending machine that dispenses cold Cola!",
		model = "models/vex/newvegas/nukacolamachine.mdl",
		ent = "nut_nukamachineclassic"
	},
	-- ["radio"] = {
	-- 	name = "[Base Utility] Radio",
	-- 	desc = "A deployable music radio.",
	-- 	model = "models/mosi/fallout4/props/radio/radio_prewar.mdl",
	-- 	ent = "fallout_radio_prewar",
	-- 	limit = 3
	-- },
	["researchpod"] = {
		name = "[Base Utility] Research Pod",
		desc = "A pod that can be used to hold kidnapped victims forcefully.",
		model = "models/themask/gow2/tank.mdl",
		ent = "playercapture_researchpod"
	},
	["tradebench"] = {
		name = "[Base Utility] Trade-up Workbench",
		desc = "A bench that can be used to upgrade your weapons.",
		model = "models/fallout new vegas/reload_bench.mdl",
		ent = "wrarity_tradeupbench"
	},
	["tranq"] = {
		name = "Tranquillizer Gun",
		desc = "A tranquillizer gun container of which can be used to kidnap people far more effectively.",
		model = "models/mosi/fallout4/props/fortifications/vaultcrate01.mdl",
		ent = "weapon_m9"
	},
	["turret"] = {
		name = "[Base Utility] Deployable Turret",
		desc = "A deployable turret that can be manned for defense.",
		model = "models/mosi/fallout4/props/fortifications/vaultcrate02.mdl",
		ent = "turret_bullets2",
		limit = "turrets"
	},
	["weaponsbench"] = {
		name = "Weapons Workstation",
		desc = "A weapons bench that can be placed and used to craft weapons.",
		model = "models/mosi/fallout4/furniture/workstations/weaponworkbench01.mdl",
		ent = "nut_craftingtable_weapons"
	},
	["gambit"] = { -- Air Vehicle
		name = "The Gambit Deployment Beacon",
		desc = "A deployable signal to call upon the Gambit | Only one of the Gambit maybe spawned at a time",
		model = "models/props_lab/tpplug.mdl",
		ent = "fo4_gambit",
		extra = function(ply, item, ent)
			jlib.EntSafety(ent)
			ent:SetPos(ent:GetPos() + Vector(0, 0, 75))
		end,
		limit = 1
	},
	["vertibird_transport_0"] = { -- Air Vehicle
		name = "VB-T-02 NCR Deployment Beacon",
		desc = "Short for Vertibird Transport, a sparingly used air vehicle during the Great War by the United States Armed Forces.",
		model = "models/props_lab/tpplug.mdl",
		ent = "fof_vb02_trans",
		extra = function(ply, item, ent)
			jlib.EntSafety(ent)
			ent:SetPos(ent:GetPos() + Vector(0, 0, 200))
		end,
		limit = "vehicle"
	},
	["vertibird_transport_1"] = { -- Air Vehicle
		name = "VB-T-02 Legion Deployment Beacon",
		desc = "Short for Vertibird Transport, a sparingly used air vehicle during the Great War by the United States Armed Forces.",
		model = "models/props_lab/tpplug.mdl",
		ent = "fof_vb02_trans",
		extra = function(ply, item, ent)
			jlib.EntSafety(ent)
			ent:SetSkin(1)
			ent:SetPos(ent:GetPos() + Vector(0, 0, 200))
		end,
		limit = "vehicle"
	},
	["vertibird_transport_2"] = { -- Air Vehicle
		name = "VB-T-02 Enclave Deployment Beacon",
		desc = "Short for Vertibird Transport, a sparingly used air vehicle during the Great War by the United States Armed Forces.",
		model = "models/props_lab/tpplug.mdl",
		ent = "fof_vb02_trans",
		extra = function(ply, item, ent)
			jlib.EntSafety(ent)
			ent:SetSkin(2)
			ent:SetPos(ent:GetPos() + Vector(0, 0, 200))
		end,
		limit = "vehicle"
	},
	["vertibird_transport_3"] = { -- Air Vehicle
		name = "VB-T-02 BOS Deployment Beacon",
		desc = "Short for Vertibird Transport, a sparingly used air vehicle during the Great War by the United States Space Force.",
		model = "models/props_lab/tpplug.mdl",
		ent = "fof_vb02_trans",
		extra = function(ply, item, ent)
			jlib.EntSafety(ent)
			ent:SetSkin(3)
			ent:SetPos(ent:GetPos() + Vector(0, 0, 200))
		end,
		limit = "vehicle"
	},
	["vertibird02_7"] = { -- Air Vehicle
		name = "VB-02 Skybreakers Deployment Beacon",
		desc = "A receptor beacon used to deploy a Vertibird.",
		model = "models/props_lab/tpplug.mdl",
		ent = "fo3_vb02",
		extra = function(ply, item, ent)
			jlib.EntSafety(ent)
			ent:SetSkin(8)
			ent:SetPos(ent:GetPos() + Vector(0, 0, 200))
		end,
		limit = "vehicle"
	},
	["vertibird02_6"] = { -- Air Vehicle
		name = "VB-02 USSS Deployment Beacon",
		desc = "A receptor beacon used to deploy a Vertibird.",
		model = "models/props_lab/tpplug.mdl",
		ent = "fo3_vb02",
		extra = function(ply, item, ent)
			jlib.EntSafety(ent)
			ent:SetSkin(8)
			ent:SetPos(ent:GetPos() + Vector(0, 0, 200))
		end,
		limit = "vehicle"
	},
	["vertibird02_5"] = { -- Air Vehicle
		name = "VB-02 Enclave Deployment Beacon",
		desc = "A receptor beacon used to deploy a Vertibird.",
		model = "models/props_lab/tpplug.mdl",
		ent = "fo3_vb02",
		extra = function(ply, item, ent)
			jlib.EntSafety(ent)
			ent:SetPos(ent:GetPos() + Vector(0, 0, 200))
		end,
		limit = "vehicle"
	},
	["vertibird02_4"] = { -- Air Vehicle
		name = "VB-02 NCR Deployment Beacon",
		desc = "A receptor beacon used to deploy a Vertibird.",
		model = "models/props_lab/tpplug.mdl",
		ent = "fo3_vb02",
		extra = function(ply, item, ent)
			jlib.EntSafety(ent)
			ent:SetSkin(4)
			ent:SetPos(ent:GetPos() + Vector(0, 0, 200))
		end,
		limit = "vehicle"
	},
	["vertibird02_3"] = { -- Air Vehicle
		name = "VB-02 BOS Deployment Beacon",
		desc = "A receptor beacon used to deploy a Vertibird.",
		model = "models/props_lab/tpplug.mdl",
		ent = "fo3_vb02",
		extra = function(ply, item, ent)
			jlib.EntSafety(ent)
			ent:SetSkin(3)
			ent:SetPos(ent:GetPos() + Vector(0, 0, 200))
		end,
		limit = "vehicle"
	},
	["vertibird02_2"] = { -- Air Vehicle
		name = "VB-02 Striped Deployment Beacon",
		desc = "A receptor beacon used to deploy a Vertibird.",
		model = "models/props_lab/tpplug.mdl",
		ent = "fo3_vb02",
		extra = function(ply, item, ent)
			jlib.EntSafety(ent)
			ent:SetSkin(5)
			ent:SetPos(ent:GetPos() + Vector(0, 0, 200))
		end,
		limit = "vehicle"
	},
	["vertibird02_8"] = { -- Air Vehicle
	name = "VB-02 W-B Deployment Beacon",
	desc = "A receptor beacon used to deploy a Vertibird.",
	model = "models/props_lab/tpplug.mdl",
	ent = "fo3_vb02",
	extra = function(ply, item, ent)
		jlib.EntSafety(ent)
		ent:SetSkin(6)
		ent:SetPos(ent:GetPos() + Vector(0, 0, 200))
	end,
	limit = "vehicle"
},
	["vertibird02_1"] = { -- Air Vehicle
		name = "VB-02 Chinese Deployment Beacon",
		desc = "A receptor beacon used to deploy a Vertibird.",
		model = "models/props_lab/tpplug.mdl",
		ent = "fo3_vb02",
		extra = function(ply, item, ent)
			jlib.EntSafety(ent)
			ent:SetSkin(1)
			ent:SetPos(ent:GetPos() + Vector(0, 0, 200))
		end,
		limit = "vehicle"
	},
	["vertibird02_0"] = { -- Air Vehicle
		name = "VB-02 Deployment Beacon",
		desc = "A receptor beacon used to deploy a Vertibird.",
		model = "models/props_lab/tpplug.mdl",
		ent = "fo3_vb02",
		extra = function(ply, item, ent)
			jlib.EntSafety(ent)
			ent:SetSkin(0)
			ent:SetPos(ent:GetPos() + Vector(0, 0, 200))
		end,
		limit = "vehicle"
	},
	["vertibird_0"] = { -- Air Vehicle
		name = "VB-01 Deployment Beacon",
		desc = "A receptor beacon used to deploy a Vertibird.",
		model = "models/props_lab/tpplug.mdl",
		ent = "fo4_vb02",
		extra = function(ply, item, ent)
			jlib.EntSafety(ent)
			ent:SetPos(ent:GetPos() + Vector(0, 0, 50))
		end,
		limit = "vehicle"
	},
	["vertibird_2"] = { -- Air Vehicle
		name = "VB-01 Gunner Deployment Beacon",
		desc = "A receptor beacon used to deploy a Vertibird.",
		model = "models/props_lab/tpplug.mdl",
		ent = "fo4_vb02",
		extra = function(ply, item, ent)
			jlib.EntSafety(ent)
			ent:SetSkin(2)
			ent:SetPos(ent:GetPos() + Vector(0, 0, 50))
		end,
		limit = "vehicle"
	},
	["vertibird_3"] = { -- Air Vehicle
		name = "VB-01 Minutemen Deployment Beacon",
		desc = "A receptor beacon used to deploy a Vertibird.",
		model = "models/props_lab/tpplug.mdl",
		ent = "fo4_vb02",
		extra = function(ply, item, ent)
			jlib.EntSafety(ent)
			ent:SetSkin(3)
			ent:SetPos(ent:GetPos() + Vector(0, 0, 50))
		end,
		limit = "vehicle"
	},
	["vertibird_4"] = { -- Air Vehicle
		name = "VB-01 Army Deployment Beacon",
		desc = "A receptor beacon used to deploy a Vertibird.",
		model = "models/props_lab/tpplug.mdl",
		ent = "fo4_vb02",
		extra = function(ply, item, ent)
			jlib.EntSafety(ent)
			ent:SetSkin(4)
			ent:SetPos(ent:GetPos() + Vector(0, 0, 50))
		end,
		limit = "vehicle"
	},
	["vertibird_5"] = { -- Air Vehicle
		name = "VB-01 National Guard Deployment Beacon",
		desc = "A receptor beacon used to deploy a Vertibird.",
		model = "models/props_lab/tpplug.mdl",
		ent = "fo4_vb02",
		extra = function(ply, item, ent)
			jlib.EntSafety(ent)
			ent:SetSkin(5)
			ent:SetPos(ent:GetPos() + Vector(0, 0, 50))
		end,
		limit = "vehicle"
	},
	["vertibird_6"] = { -- Air Vehicle
		name = "VB-01 Air Force Deployment Beacon",
		desc = "A receptor beacon used to deploy a Vertibird.",
		model = "models/props_lab/tpplug.mdl",
		ent = "fo4_vb02",
		extra = function(ply, item, ent)
			jlib.EntSafety(ent)
			ent:SetSkin(6)
			ent:SetPos(ent:GetPos() + Vector(0, 0, 50))
		end,
		limit = "vehicle"
	},
	["vertibird_7"] = { -- Air Vehicle
		name = "VB-01 Railroad Deployment Beacon",
		desc = "A receptor beacon used to deploy a Vertibird.",
		model = "models/props_lab/tpplug.mdl",
		ent = "fo4_vb02",
		extra = function(ply, item, ent)
			jlib.EntSafety(ent)
			ent:SetSkin(7)
			ent:SetPos(ent:GetPos() + Vector(0, 0, 50))
		end,
		limit = "vehicle"
	},
	["vertibird_8"] = { -- Air Vehicle
		name = "VB-01 Vault-Tec Deployment Beacon",
		desc = "A receptor beacon used to deploy a Vertibird.",
		model = "models/props_lab/tpplug.mdl",
		ent = "fo4_vb02",
		extra = function(ply, item, ent)
			jlib.EntSafety(ent)
			ent:SetSkin(8)
			ent:SetPos(ent:GetPos() + Vector(0, 0, 50))
		end,
		limit = "vehicle"
	},
	["vertibird_bos"] = { -- Air Vehicle
		name = "VB-01 BOS Deployment Beacon",
		desc = "A receptor beacon used to deploy a Vertibird.",
		model = "models/props_lab/tpplug.mdl",
		ent = "fo4_vb02",
		extra = function(ply, item, ent)
			jlib.EntSafety(ent)
			ent:SetSkin(1)
			ent:SetPos(ent:GetPos() + Vector(0, 0, 50))
		end,
		limit = "vehicle"
	},
	["transportcombatjeep"] = { -- Land Vehicle
		name = "Deployable Transport Combat Jeep",
		desc = "A deployable combat jeep armed for 7 individuals.",
		model = "models/props_junk/gascan001a.mdl",
		ent = "combat_jeep_transport",
		limit = "vehicle"
	},
	["combatjeep"] = { -- Land Vehicle
		name = "Deployable Combat Jeep",
		desc = "A deployable raider buggy.",
		model = "models/props_junk/gascan001a.mdl",
		ent = "combat_jeep2",
		limit = "vehicle"
	},
	["dualcombatjeep"] = { -- Land Vehicle
		name = "Deployable Dual Combat Jeep",
		desc = "A deployable raider buggy.",
		model = "models/props_junk/gascan001a.mdl",
		ent = "combat_jeep3",
		limit = "vehicle"
	},
	["raiderjeep"] = { -- Land Vehicle
		name = "Raider Buggy",
		desc = "A deployable raider buggy.",
		model = "models/props_junk/gascan001a.mdl",
		ent = "combat_jeep1",
		limit = "vehicle"
	},
	["multiplecombatjeep"] = { -- Land Vehicle
		name = "Deployable Multiple Combat Jeep",
		desc = "A deployable raider buggy.",
		model = "models/props_junk/gascan001a.mdl",
		ent = "combat_jeep2",
		limit = "vehicle"
	},
	["tank"] = { -- Land Vehicle
		name = "Refurbished Tank Deployment Beacon",
		desc = "A receptor beacon used to deploy a Tank.",
		model = "models/props_junk/gascan001a.mdl",
		type = "vehicle",
		ent = "FO_Tank",
		extra = function(ply, item, ent)
			ent:SetHealth(20000)
			jlib.EntSafety(ent)
		end,
		limit = "vehicle"
	},
	["motorbike"] = { -- Land Vehicle
		name = "Motorcycle Deployment Beacon",
		desc = "A receptor beacon used to deploy a Motorcycle.",
		model = "models/props_junk/gascan001a.mdl",
		type = "vehicle",
		ent = "fo4bike_sgm",
		extra = function(ply, item, ent)
			ent:SetHealth(3000)
			jlib.EntSafety(ent)
		end,
		limit = "vehicle"
	},
	["militiabike"] = { -- Land Vehicle
		name = "Militia Death Bike",
		desc = "A deployable Death Bike.",
		model = "models/props_junk/gascan001a.mdl",
		type = "vehicle",
		ent = "deathbike_sgm",
		extra = function(ply, item, ent)
			ent:SetHealth(8000)
			ent:SetColor(Color(0,0,0))
			jlib.EntSafety(ent)
		end,
		limit = "vehicle"
	},
	["humvee_4"] = { -- Land Vehicle
		name = "Humvee Night-Ops Deployment Beacon",
		desc = "A receptor beacon used to deploy a Humvee.",
		model = "models/props_junk/gascan001a.mdl",
		type = "vehicle",
		ent = "humvee_fo3_sgm",
		extra = function(ply, item, ent)
			ent:SetHealth(5000)
			ent:SetSkin(4)
			jlib.EntSafety(ent)
		end,
		limit = "vehicle"
	},
	["humvee_3"] = { -- Land Vehicle
		name = "Humvee Deployment Beacon",
		desc = "A receptor beacon used to deploy a Humvee.",
		model = "models/props_junk/gascan001a.mdl",
		type = "vehicle",
		ent = "humvee_fo3_sgm",
		extra = function(ply, item, ent)
			ent:SetHealth(5000)
			ent:SetSkin(3)
			jlib.EntSafety(ent)
		end,
		limit = "vehicle"
	},
	["humvee_2"] = { -- Land Vehicle
		name = "Humvee BOS Deployment Beacon",
		desc = "A receptor beacon used to deploy a Humvee.",
		model = "models/props_junk/gascan001a.mdl",
		type = "vehicle",
		ent = "humvee_fo3_sgm",
		extra = function(ply, item, ent)
			ent:SetHealth(5000)
			ent:SetSkin(2)
			jlib.EntSafety(ent)
		end,
		limit = "vehicle"
	},
	["humvee_1"] = { -- Land Vehicle
		name = "Humvee Enclave Deployment Beacon",
		desc = "A receptor beacon used to deploy a Humvee.",
		model = "models/props_junk/gascan001a.mdl",
		type = "vehicle",
		ent = "humvee_fo3_sgm",
		extra = function(ply, item, ent)
			ent:SetHealth(5000)
			ent:SetSkin(1)
			jlib.EntSafety(ent)
		end,
		limit = "vehicle"
	},
	["humvee_0"] = { -- Land Vehicle
		name = "Humvee NCR Deployment Beacon",
		desc = "A receptor beacon used to deploy a Humvee.",
		model = "models/props_junk/gascan001a.mdl",
		type = "vehicle",
		ent = "humvee_fo3_sgm",
		extra = function(ply, item, ent)
			ent:SetHealth(5000)
			jlib.EntSafety(ent)
		end,
		limit = "vehicle"
	},
	["apc"] = { -- Land Vehicle
		name = "Refurbished APC Deployment Beacon",
		desc = "A receptor beacon used to deploy a APC.",
		model = "models/props_junk/gascan001a.mdl",
		type = "vehicle",
		ent = "apc_fo4_sgm",
		extra = function(ply, item, ent)
			ent:SetHealth(7500)
			jlib.EntSafety(ent)
		end,
		limit = "vehicle"
	},
	["highwayman_sgm"] = { -- Custom order by Keinecat#3411
		name = "Pre-War Highwayman Comero",
		desc = "A receptor beacon used to deploy a Highwayman Vehicle.",
		model = "models/props_junk/gascan001a.mdl",
		type = "vehicle",
		ent = "highwayman_sgm",
		extra = function(ply, item, ent)
			ent:SetHealth(4000)
			jlib.EntSafety(ent)
		end,
		limit = "vehicle"
	},
	["chair_wood"] = { -- Misc. Entity
		name = "[Base Utility] Wood Chair",
		desc = "A placeable chair | Can be sat in if deployed",
		model = "models/nova/chair_wood01.mdl",
		type = "vehicle",
		ent = "Chair_Wood"
	},
	["chair_office"] = { -- Misc. Entity
		name = "[Base Utility] Office Chair",
		desc = "A placeable chair | Can be sat in if deployed",
		model = "models/nova/chair_office01.mdl",
		type = "vehicle",
		ent = "Chair_Office"
	},
	["chair_metal"] = { -- Misc. Entity
		name = "[Base Utility] Metal Chair",
		desc = "A placeable chair | Can be sat in if deployed",
		model = "models/nova/chair_wood01.mdl",
		type = "vehicle",
		ent = "Chair_Plastic"
	},
	["chair_jeep"] = { -- Misc. Entity
		name = "[Base Utility] Jeep Chair",
		desc = "A placeable chair | Can be sat in if deployed",
		model =	"models/nova/jeep_seat.mdl",
		type = "vehicle",
		ent = "Seat_Jeep"
	},
	["chair_fancy"] = { -- Misc. Entity
		name = "[Base Utility] Fancy Chair",
		desc = "A placeable chair | Can be sat in if deployed",
		model =	"models/props_combine/breenchair.mdl",
		type = "vehicle",
		ent = "Chair_Office2"
	},
	["gallows"] = { -- Custom order by Tonio#4097
		name = "Gallows",
		desc = "A deployable execution stable.",
		model = "models/props_junk/wood_crate002a.mdl",
		ent = "gallows",
		limit = 2
	},
}

local function GetDeployableCateogry(item)
	return isstring(item.limit) and item.limit or item.ent
end

function PLUGIN:InitializedPlugins()
	for uid, data in pairs(self.Deployables) do
		local ITEM = nut.item.register(uid, nil, false, nil, true)
		ITEM.name = data.name
		ITEM.desc = data.desc
		ITEM.model = data.model
		ITEM.ent = data.ent
		ITEM.limit = isstring(data.limit) and PLUGIN.DeployableLimits[data.limit] or (data.limit or PLUGIN.DefaultIndividualLimit)
		ITEM.isVehicle = data.type == "vehicle"

		ITEM.functions.use = {
			name = "Use",
			tip = "useTip",
			icon = "icon16/pencil.png",
			onRun = function(item)
				local ply = item.player

				local cat = GetDeployableCateogry(data)

				ply.DeployablesSpawned = ply.DeployablesSpawned or {}

				if (ply.DeployablesSpawned.Total or 0) >= PLUGIN.TotalLimit or (ply.DeployablesSpawned[cat] or 0) >= item.limit then
					ply:falloutNotify("You have reached the limit for spawning this item.")
					return false
				end

				local traceDat = {}
				traceDat.start = ply:GetShootPos()
				traceDat.endpos = traceDat.start + (ply:GetAimVector() * 96)
				traceDat.filter = ply
				local trace = util.TraceLine(traceDat)

				if trace.HitPos then
					local ent = !item.isVehicle and ents.Create(item.ent) or jlib.CreateVehicle(item.ent)
					ent:SetPos(trace.HitPos + trace.HitNormal * 10)
					ent:Spawn()
					ent:CallOnRemove("UpdateDeployablesCount", function(entity)
						if IsValid(ply) and ply.DeployablesSpawned.Total then
							ply.DeployablesSpawned.Total = ply.DeployablesSpawned.Total - 1
							ply.DeployablesSpawned[cat] = ply.DeployablesSpawned[cat] - 1
						end
					end)

					ply.DeployablesSpawned.Total = (ply.DeployablesSpawned.Total or 0) + 1
					ply.DeployablesSpawned[cat] = (ply.DeployablesSpawned[cat] or 0) + 1

					if isfunction(data.extra) then
						data.extra(ply, item, ent)
					end

					if item.isVehicle then
						hook.Run("PlayerSpawnedVehicle", ply, ent)
					else
						hook.Run("PlayerSpawnedSENT", ply, ent)
					end
				end

				return true
			end
		}
	end
end
