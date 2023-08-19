PLUGIN.name = "Audit"
PLUGIN.desc = "A Super Admin exclusive command that opens an interface displaying the wealth of players."
PLUGIN.author = "Pilot"

if (SERVER) then
	util.AddNetworkString("nutAuditPanel")
end

nut.command.add("audit", {
	superAdminOnly = true,
	onRun = function(client, arguments)
		nut.db.query("SELECT _name, _money, _lastJoinTime, _steamID FROM nut_characters ORDER BY _money DESC LIMIT 50", function(data)
			net.Start("nutAuditPanel")
			net.WriteTable(data)
			net.Send(client)
		end)
	end
})