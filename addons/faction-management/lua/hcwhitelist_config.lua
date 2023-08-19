hcWhitelist.config.steamAPIKey = "601BD514840668E6830591D582E574E6"
hcWhitelist.config.maxMOTDLen = 10000 --Maximum amount of characters in an MOTD
hcWhitelist.config.avatarCacheMaxAge = 259200 --How old does the cached avatar image need to be to be updated
hcWhitelist.config.popupTimeout = 60 --After how many seconds should the notification alert go away
hcWhitelist.config.pageLen = 60 --How many members should we show on one page
hcWhitelist.config.NCOCooldown = 300 --How often an NCO can perform the same action again
hcWhitelist.config.debug = true --Whether or not we should print debug info to console

--Theme config
hcWhitelist.theme = hcWhitelist.theme or {}
hcWhitelist.theme.primary    = Color(45, 45, 45, 255)
hcWhitelist.theme.border     = Color(35, 35, 35, 200)
hcWhitelist.theme.background = Color(45, 45, 45, 240)
hcWhitelist.theme.dropShadow = Color(0, 0, 0, 55)
hcWhitelist.theme.textColor  = Color(209, 209, 209, 255)
hcWhitelist.theme.popupColor = Color(255, 199, 44, 255)

hcWhitelist.theme.blur = true


/** -- Fallout 4 Neon Green style
hcWhitelist.theme = hcWhitelist.theme or {}
hcWhitelist.theme.primary    = Color(45, 45, 45, 255)
hcWhitelist.theme.border     = Color(35, 35, 35, 200)
hcWhitelist.theme.background = Color(45, 45, 45, 240)
hcWhitelist.theme.dropShadow = Color(0, 0, 0, 55)
hcWhitelist.theme.textColor  = Color(209, 209, 209, 255)
hcWhitelist.theme.popupColor = Color(25, 255, 25, 255)

hcWhitelist.theme.blur = true
**/
