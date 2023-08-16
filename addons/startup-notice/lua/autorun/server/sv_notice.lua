hook.Add("Initialize", "OnlineDiscordNotification", function()
	timer.Simple(10, function()
		DiscordEmbed(
			"**is now online & joinable**\n\n" ..
			"**·** ``Click here to quick-connect:``\n steam://connect/" .. game.GetIPAddress(),
			GetHostName(),
			Color(0,0,255),
			"IncursionChat"
		)
	end)
end)
