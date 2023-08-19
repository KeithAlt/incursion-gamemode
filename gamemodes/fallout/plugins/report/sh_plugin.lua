local PLUGIN = PLUGIN

PLUGIN.name = "Player Report"
PLUGIN.author = "Vex"
PLUGIN.desc = "Generate a report of a player and their characters."

nut.util.include("sv_plugin.lua")

if (CLIENT) then
	netstream.Hook("nutReport", function(data)
		vgui.Create("nutReport"):populate(data)
	end)
end

nut.command.add("report", {
	syntax = "<steamID64>",
	superAdminOnly = true,
	onRun = function(client, arguments)
		if (SERVER) then
			netstream.Start(client, "nutReport", PLUGIN:GenerateReport(arguments[1]))
		end
	end
})
