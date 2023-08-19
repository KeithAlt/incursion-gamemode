hook.Add("InitPostEntity", "InitalizeMugging", function()
	MsgC(Color(255,0,0), "[MUGGING] ", Color(255,255,255), "Initalizing mugging system...\n")

	-- Purpose: General configs
	nut.config.add("mugCooldown", 300, "How much time (in seconds) until a player can mug again?", nil, {
		data = {min = 10, max = 500000},
		category = "muggingConfig"
	})

	nut.config.add("mugVictimCooldown", 300, "How much time (in seconds) until a player can be mugged again?", nil, {
		data = {min = 10, max = 500000},
		category = "muggingConfig"
	})

	-- Purpose: Declare the allowed amounts of mugging
	nut.config.add("Level 1-10", 200, "What amount of money can be mugged from players within this level?", nil, {
		data = {min = 10, max = 500000},
		category = "muggingConfig"
	})

	nut.config.add("Level 11-25", 500, "What amount of money can be mugged from players within this level?", nil, {
		data = {min = 10, max = 500000},
		category = "muggingConfig"
	})

	nut.config.add("Level 26-40", 1000, "What amount of money can be mugged from players within this level?", nil, {
		data = {min = 10, max = 500000},
		category = "muggingConfig"
	})

	nut.config.add("Level 41-49", 2000, "What amount of money can be mugged from players within this level?", nil, {
		data = {min = 10, max = 500000},
		category = "muggingConfig"
	})

	nut.config.add("Level 50+", 3500, "What amount of money can be mugged from players at or beyond this level?", nil, {
		data = {min = 10, max = 500000},
		category = "muggingConfig"
	})

	nut.config.add("PK Active Time", 120, "How long the mugger should be PK active for after mugging someone, in seconds.", nil, {
		data = {min = 60, max = 500000},
		category = "muggingConfig"
	})

	if CLIENT then
		-- Purpose: Search a player with a ziptie
		nut.playerInteract.addFunc("mugChar", {
			nameLocalized = "Mug Caps",
			callback = function(target)
				net.Start("nutMugAction")
					net.WriteEntity(target)
				net.SendToServer()
			end,
			canSee = function(target)
				return target:getNetVar("restricted") and not LocalPlayer():getNetVar("restricted")
			end
		})
	end

	MsgC(Color(255,0,0), "[MUGGING] ", Color(255,255,255), "Successfully initalized mugging system\n")
end)
