-- Notify players that lag is expected
hook.Add("InitPostEntity", "startupLagMessage", function()
	timer.Create("startupMessage", 200, 18, function()
		for k, v in pairs(player.GetAll()) do
			jlib.Announce(v,
				Color(255,0,0), "[NOTICE] ",
				Color(255,155,155), "The server is expected to experience lag spikes as it loads new models",
				Color(255,255,255),	"\n· This lag can be expected for the first hour"
			)
		end
	end)
end)
