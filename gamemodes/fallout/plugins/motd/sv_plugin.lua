local PLUGIN = PLUGIN

hook.Add("InitializedPlugins", "forp_notification_box", function()
    local path = "nutscript/"..SCHEMA.folder.."/notif_box.txt"
    local status, decoded = pcall(pon.decode, file.Read(path, "DATA"))

    local tbl

	if (status and decoded) then
		local value = decoded[1]

		if (value != nil) then
			tbl = value
		else
			tbl = {}
		end
	else
		tbl = {}
    end
    
    PLUGIN.boxTitle = tbl[1]
    PLUGIN.boxText = tbl[2]
end)

hook.Add("ShutDown", "forp_notification_box2", function()
    local path = "nutscript/"..SCHEMA.folder.."/notif_box.txt"
	file.CreateDir("nutscript/"..SCHEMA.folder.."/")
    
    file.Write( path, pon.encode({{PLUGIN.boxTitle, PLUGIN.boxText}}) )
end)

netstream.Hook("foMotdEdit", function(client, title, text)
    if (!client:IsSuperAdmin()) then return end

    PLUGIN.boxTitle = title or PLUGIN.boxTitle
    PLUGIN.boxText = text or PLUGIN.boxText

    netstream.Start(player.GetAll(), "foMotdData", PLUGIN.boxTitle, PLUGIN.boxText)
end)

function PLUGIN:PlayerInitialSpawn(client)
    netstream.Start(client, "foMotdData", PLUGIN.boxTitle, PLUGIN.boxText)
end