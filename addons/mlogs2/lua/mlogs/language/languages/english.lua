--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

// FILE VERSION: 1 - View lastest versions here: https://docs.m4dsolutions.com/#/category/1/article/4
mLogs.config.fileVersions = mLogs.config.fileVersions or {}
mLogs.config.fileVersions["language/languages/english.lua"] = 1.3

// Documentation: https://docs.m4dsolutions.com/#/category/1/article/2

// The english translation of mLogs, this file will be updated so visit https://docs.m4dsolutions.com/#/category/1/article/4 for the lastest version.
// If you want to create your own language create a file in this directory and follow the same schema as this file.
local lang = {
	// --- UI Translations --- //

	// General
	error = "Error",
	
	// mLogs
	mlogs = "mLogs 2",
	
	// Config
	invalid_config = "Error! The config is invalid!",
	loaded_config = "Loaded Config Successfully!",

	// Core
	not_loaded = "%s has tried to use mLogs before being loaded, if this problem occurs often check your storage settings! e.g. MySQL not being able to connect",
	not_validated = "Not validated",
	not_validated_msg = "Sorry, you have not been validated to use mLogs yet, please try again later!",
	no_storage_connection = "%s has tried to use mLogs however we do not have a storage connection! Please check your provider settings!",
	not_online = "Not online",
	not_online_msg = "Sorry, mLogs is not online at the moment! Please try again later!",
	loading = "Loading...",
	please_wait_before_trying = "Please wait before trying again!",
	
	// Permissions
	invalid_permissions = "Invalid Permission",
	no_permission_for_action = "You do not have permission to perform this action!",
	no_access = "No Access",
	no_access_msg = "You do not have access to do this!",

	// Automation
	automation_reset = "Automation times reset successfully!",

	// Menus
	logs = "Logs",
	settings = "Settings",
	
	// Logs
	found_category_x = "Found Category: %s",
	enable_category_x = "Enabling Category: %s",
	
	// Log View
	time = "Time",
	category = "Category",
	log = "Log",
	page_x_x = "Page %i/%i",
	quick_search = "Quick Search",
	jump = "Jump",
	no_logs_found = "No logs found",
	jump_to_page = "Jump to Page",
	jump_to_page_desc = "Enter a page number to jump to:",
	page_number = "Page Number e.g. 5",
	copy_x = "Copy %s",
	name = "Name",
	profile = "Profile",
	players = "Players",
	positions = "Positions",
	x_position = "%s Position",
	position_instructions = "Move: WASD | Look: Click + Drag or Arrow Keys",

	// Advanced Search
	advanced_search = "Advanced Search",
	available_tags = "Available Tags",
	select_type = "Select Type:",
	criteria = "Criteria",
	online_players = "Online Players",
	additional_text = "Additional Search Query",
	too_complex = "Too Complex",
	too_complex_msg = "Your query is too complex! Please only select 10 options!",

	// Info
	user_online = "User Online",
	user_offline = "User Offline",

	// Settings - not all translatable
	server = "Server",
	client = "Client",
	general = "General", -- general settings
	loggers = "Loggers", -- logger settings
	permissions = "Permissions", -- permissions
	storage_management = "Storage Management", -- storage settings
	format_types = "Format Types",
	automation = "Automation",

	ui = "UI Settings",
	format = "Log Format",
	log_colors = "Log Colors",
	commands = "Commands",

	reset = "Reset",
	save = "Save",
	invalid_fields = "Invalid Fields",
	fix_fields = "Please fix the following fields: %s",
	success = "Success",
	save_success = "Successfully updated settings",
	are_you_sure = "Are you sure?",
}

// The following table is for log translations, each table is converted to a string with the variables replaced on the client.
// This allows for translations for the local client's language instead of a server-wide language
// Do not translate words starting with "^" as these are variables
local logTranslations = {
	// --- Log Translations --- //
	
	// Types
	world = "The world", -- falldamage/crushing/worldspawn damage
	weapon = "weapon", -- default name for weapon
	vehicle = "vehicle", -- default name for vehicle
	prop = "prop", -- default name for prop
	entity = "entity", -- default name for entity
	unknown_player = "player", -- default name for player
	unknown_entity = "unknown entity", -- if something goes horribly wrong, this is the last resort

	// Logs
	all_logs = "All Logs",
	deep_storage = "Deep Storage",

	// General //
	general = "General",

	// Connections
	connect_server = {"^player1", "connected to the server"},
	disconnect_server = {"^player1", "disconnected from the server"},
	
	// Kills
	kill = {"^attacker", "killed", "^player1"},
	kill_inflictor = {"^attacker", "killed", "^player1", "with a", "^inflictor"},
	kill_no_player = {"^player1", "was killed by a", "^inflictor"},
	kill_owner = {"^player1", "was killed by a", "^inflictor", "owned by", "^owner"},
	kill_suicide = {"^player1", "committed suicide"},
	
	// Damage
	dmg = {"^attacker", "damaged", "^player1", "for", "^damage", "damage"},
	dmg_inflictor = {"^attacker", "damaged", "^player1", "for", "^damage", "damage", "with a", "^inflictor"},
	dmg_no_player = {"^player1", "was damaged by a", "^inflictor", "for", "^damage", "damage"},
	dmg_owner = {"^player1", "was damaged by a", "^inflictor", "owned by", "^owner", "for", "^damage", "damage"},
	dmg_self = {"^player1", "damaged", "themself", "for", "^damage", "damage"},
	dmg_self_inflictor = {"^player1", "damaged", "themself", "for", "^damage", "damage with a", "^inflictor"},

	// Pickups
	pickup = {"^player1", "picked up a", "^item"},

	// Sandbox //
	// Toolgun
	toolgun = {"^player1", "used", "^tool", "on a", "^ent", "owned by", "^owner"},
	toolgun_no_owner = {"^player1", "used", "^tool", "on a", "^ent"},
	toolgun_world = {"^player1", "used", "^tool"},

	// Spawns
	spawns = {"^player1", "spawned a", "^item"},

	// DarkRP //
	// Agendas
	agenda_update = {"^player1", "updated the", "^title", "to:", "^msg"},
	agenda_remove = {"^player1", "removed the", "^title"},

	// Arrests
	arrest = {"^player1", "arrested", "^player2"},
	unarrest = {"^player1", "released", "^player2"},

	// Battering Ram
	ram_success = {"^player1", "successfully rammed the door of", "^owner"},
	ram_success_vehicle = {"^player1", "successfully rammed a", "^vehicle", "of", "^owner"},
	ram_success_unowned = {"^player1", "successfully rammed an unowned door"},
	ram_success_unowned_vehicle = {"^player1", "successfully rammed an unowned", "^vehicle"},

	ram_fail = {"^player1", "failed to ram the door of", "^owner"},
	ram_fail_vehicle = {"^player1", "failed to ram a", "^vehicle", "of", "^owner"},
	ram_fail_unowned = {"^player1", "failed to ram an unowned door"},
	ram_fail_unowned_vehicle = {"^player1", "failed to ram a unowned", "^vehicle"},

	// Cheques
	cheque_drop = {"^player1", "wrote a cheque of", "^amt", "for", "^player2"},
	cheque_pickup = {"^player1", "picked up a cheque of", "^amt", "from", "^player2"},
	cheque_tore = {"^player1", "tore up a cheque of", "^amt", "intended for", "^player2"},

	// Demotes
	demote = {"^player1", "demoted", "^player2", "for", "^reason"},
	demote_afk = {"^player1", "was demoted for being AFK"},

	// Doors
	door_sold = {"^player1", "sold a door"},
	door_buy = {"^player1", "bought a door"},

	// Money
	money_drop = {"^player1", "dropped", "^amt"},
	money_pickup = {"^player1", "picked up", "^amt", "dropped by", "^owner"},
	money_pickup_unowned = {"^player1", "picked up", "^amt"},

	// Hits
	hit_request = {"^customer", "has requested a hit on", "^target", "with", "^hitman", "for", "^price"},
	hit_accept = {"^hitman", "has accepted a hit on", "^target", "requested by", "^customer"},
	hit_complete = {"^hitman", "has completed a hit on", "^target", "requested by", "^customer"},

	// Jobs
	job = {"^player1", "changed from", "^team1", "to", "^team2"},

	// Lockpick
	lockpick_started = {"^player1", "started lockpicking the door of", "^owner"},
	lockpick_started_vehicle = {"^player1", "started lockpicking a", "^vehicle", "of", "^owner"},
	lockpick_started_unowned = {"^player1", "started lockpicking an unowned door"},
	lockpick_started_unowned_vehicle = {"^player1", "started lockpicking a unowned", "^vehicle"},

	lockpick_success = {"^player1", "has successfully lockpicked the door of", "^owner"},
	lockpick_success_vehicle = {"^player1", "has successfully lockpicked a", "^vehicle", "of", "^owner"},
	lockpick_success_unowned = {"^player1", "has successfully lockpicked an unowned door"},
	lockpick_success_unowned_vehicle = {"^player1", "has successfully lockpicked a unowned", "^vehicle"},

	lockpick_fail = {"^player1", "has failed to lockpicked the door of", "^owner"},
	lockpick_fail_vehicle = {"^player1", "has failed to lockpicked a", "^vehicle", "of", "^owner"},
	lockpick_fail_unowned = {"^player1", "has failed to lockpicked an unowned door"},
	lockpick_fail_unowned_vehicle = {"^player1", "has failed to lockpicked a unowned", "^vehicle"},

	// Name Changes
	name = {"^player1", "changed their name from", "^name1", "to", "^name2"},

	// Pocket
	pocket = {"^player1", "put a", "^item", "in their pocket"},
	pocket_drop = {"^player1", "dropped a", "^item", "from their pocket"},

	// Purchases
	purchase = {"^player1", "bought a", "^item", "for", "^price"},
	purchase_shipment = {"^player1", "bought a shipment of", "^amt", "^item", "for", "^price"},

	// Wanted
	wanted = {"^cop", "made", "^target", "wanted", "for", "^reason"},
	unwanted = {"^cop", "made", "^target", "no longer wanted"},

	// Warrant
	warrant = {"^cop", "filed a warrant on", "^target", "for", "^reason"},
	unwarrant = {"^cop", "removed the warrant on", "^target"},

	// Weapon Checks
	wep_check = {"^player1", "checked", "^target", "for weapons"},
	wep_confiscate = {"^player1", "confiscated the weapons of", "^target"},
	wep_return = {"^player1", "returned the weapons of", "^target"},

	// TTT //
	// Equipment
	equipment = {"^player1", "bought", "^item"},

	// DNA
	dna = {"^player1", "found the DNA of", "^player2", "on their body"},
	dna_weapon = {"^player1", "found the DNA of", "^player2", "on their", "^weapon"},

	// Karma
	karma = {"^player1", "has been kicked for low karma"},

	// Body
	body = {"^player1", "found the body of", "^player2"},

	// Murder //
	// Loot
	loot = {"^player1", "picked up loot"},

	// Cinema //
	// Queue
	cinema_queue = {"^player1", "queued", "^title", "at", "^theater"},

	// Theatre Joins
	cinema_enter = {"^player1", "entered", "^theater"},
	cinema_leave = {"^player1", "left", "^theater"},
	
	//------ v1.0.3 ------
	hit_fail = {"^hitman", "has failed a hit on", "^target", "because", "^reason"},
}
mLogs.addLanguage("en",lang,logTranslations)