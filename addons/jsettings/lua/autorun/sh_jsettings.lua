--[[
	jSettings
	Author: jonjo
]]

jSettings = jSettings or {}
jSettings.Print = jlib.GetPrintFunction("[jSettings]", Color(202, 44, 146, 255))
jSettings.CommandAliases = {"settings", "options", "preferences"}

hook.Add("InitPostEntity", "jSettings", function()
	for i, alias in ipairs(jSettings.CommandAliases) do
		nut.command.add(alias, {
			onRunClient = function()
				jSettings.OpenMenu()
			end
		})
	end
end)
