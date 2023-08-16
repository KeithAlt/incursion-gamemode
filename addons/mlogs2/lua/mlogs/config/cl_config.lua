--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright � 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

// FILE VERSION: 2 - View lastest versions here: https://docs.m4dsolutions.com/#/category/1/article/4
mLogs.config.fileVersions = mLogs.config.fileVersions or {}
mLogs.config.fileVersions["config/cl_config.lua"] = 2

// Documentation: https://docs.m4dsolutions.com/#/category/1/article/2

mLogs.config.colors = mLogs.config.colors or {}
mLogs.config.blur = mLogs.config.blur or {}

// Blur
// mLogs.config.blur.bg = true // Set mLogs to use a Blur Background (will need to adjust alpha of all colors)

// Main
mLogs.config.colors.bg = Color(60,68,82) // Background Color
mLogs.config.colors.head = Color(76,86,103) // Header Color
mLogs.config.colors.hover = Color(68,77,92) // Hovered Button Color
mLogs.config.colors.accent = Color(211, 84, 0) // Accent Color
mLogs.config.colors.sidebar = Color(53,60,72) // Sidebar Color
mLogs.config.colors.border = Color(76,85,98) // Border Color
mLogs.config.colors.panel = Color(53,60,72) // Panel Color
mLogs.config.colors.uiBorder = Color(120,130,140,51) // UI Border
mLogs.config.colors.tableAlternate = Color(0,0,0,26) // Alternate Table Line Color
mLogs.config.colors.tableHighlight = Color(63,70,82) // Current Table Line Color
mLogs.config.colors.scrollGrip = Color(190,190,190,102) // Scroll Grip Color

// Log Colors (configurable in client's menu)
mLogs.config.colors.player = Color(250,190,88) // Player
mLogs.config.colors.entity = Color(148,124,176) // Entity
mLogs.config.colors.weapon = Color(246, 36, 89) // Weapon
mLogs.config.colors.vehicle = Color(27, 188, 155) // Vehicle
mLogs.config.colors.info = Color(236,100,75) // Info in (brackets)

// Fonts
mLogs.config.regularFont = "Roboto Medium"
mLogs.config.clearFont = "Roboto Regular"