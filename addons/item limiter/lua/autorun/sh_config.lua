-- Initialize our in-game config vars
hook.Add("InitPostEntity", "ItemLimiterLoader", function()
	nut.config.add("itemLimit", 300, "How many items should be allowed to exist before we force a cleanup", nil, {
		data = {min = 50, max = 1000},
		category = "Item Limiter"
	})

	nut.config.add("limitTime", 600, "How frequently (in seconds) should we check the world for items", nil, {
		data = {min = 300, max = 18000},
		category = "Item Limiter"
	})
end)
