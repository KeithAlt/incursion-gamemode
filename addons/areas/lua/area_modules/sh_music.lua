Areas.AddVar("Music", "Table", true, {})

hook.Add("InitPostEntity", "AreasMusic", function()
	nut.command.add("zonemusic", {
		superAdminOnly = true,
		onRunClient = function()
			local area = LocalPlayer():GetArea()
			if IsValid(area) then
				Areas.Music.OpenConfig(area)
			end
		end
	})
end)
