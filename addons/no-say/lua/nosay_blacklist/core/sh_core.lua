noSayBlacklist.Core.Words = noSayBlacklist.Core.Words or {}
noSayBlacklist.Core.SettingsCache = noSayBlacklist.Core.SettingsCache or {}

-- All the in-game config options
-- name: The display name
-- desc: The description
-- setting: The unique name
-- value: The default value
-- switch: if it should be a toggle input
noSayBlacklist.Core.Settings = {}
noSayBlacklist.Core.Settings[1] = {name = "Enabled", desc = "Should messages be checked for bad words? (Disable/Enable the addon)", setting = "enable", value = true, switch = true}
noSayBlacklist.Core.Settings[2] = {name = "Chat Command", desc = "The command to open the menu.", setting = "chat_command", value = "!nosay", switch = false}
noSayBlacklist.Core.Settings[3] = {name = "Still post", desc = "Should messages still be shown in chat?", setting = "still_post", value = true, switch = true}
noSayBlacklist.Core.Settings[4] = {name = "Censor words", desc = "Should the bad words be censored? Example: 'Get the **** out'.", setting = "censor", value = true, switch = true}
noSayBlacklist.Core.Settings[5] = {name = "Strike", desc = "Should users be striked for saying bad words?", setting = "strike", value = true, switch = true}
noSayBlacklist.Core.Settings[6] = {name = "Multistrike", desc = "Should a user be given multiple strikes if they say multiple bad words in 1 message?", setting = "multistrike", value = false, switch = true}
noSayBlacklist.Core.Settings[7] = {name = "Strike limit", desc = "How many strikes before the user is kicked? (Put to 0 to disable)", setting = "strike_limit", value = 3, switch = false, numeric = true}
noSayBlacklist.Core.Settings[8] = {name = "Kick message", desc = "The message the user is kicked for.", setting = "kick_message", value = "You have reached the strike limit.", switch = false}
noSayBlacklist.Core.Settings[9] = {name = "Strike lookup", desc = "Should everyone be able to access 'Strike Lookup'?", setting = "strike_lookup", value = true, switch = true}
noSayBlacklist.Core.Settings[10] = {name = "Admin override", desc = "Should admins be able to bypass the filter?", setting = "admin_override", value = false, switch = true}
noSayBlacklist.Core.Settings[11] = {name = "Word target", desc = "When filtering, should it only filter full words?", setting = "word_target", value = false, switch = true}
noSayBlacklist.Core.Settings[12] = {name = "Warn message", desc = "The message the user is given when saying a 'bad word'", setting = "warn_message", value = "You have said '%s', which is considered a bad word, you will be striked. This is strike %i/%i.", switch = false}
noSayBlacklist.Core.Settings[13] = {name = "Smart find (beta)", desc = "Smart find tries to prevent work arounds. This can be resource heavy so be careful using it.", setting = "smart_find", value = false, switch = true}

-- Check if the user has "admin" permissions
function noSayBlacklist.Core.CheckPrivilege(ply)
	return noSayBlacklist.Config.GroupAccess[ply:GetUserGroup()] or noSayBlacklist.Config.GroupAccess[ply:SteamID()] or noSayBlacklist.Config.GroupAccess[ply:SteamID64()]
end

-- Update the settings for the current session
function noSayBlacklist.Core.UpdateSetting(setting, value)
	-- Cache is our friend
	noSayBlacklist.Core.SettingsCache[setting] = value
	-- Update the settings table's values
	for k, v in pairs(noSayBlacklist.Core.Settings) do
		if v.setting != setting then continue end

		if v.switch then
			v.value = tobool(value)
		else
			v.value = value
		end
	end
end

-- Get the current state of a setting
function noSayBlacklist.Core.GetSetting(setting)
	-- Everyone loves cache
	if noSayBlacklist.Core.SettingsCache[setting] then
		return noSayBlacklist.Core.SettingsCache[setting]
	end

	-- If no cache, pull it from the settings table
	for k, v in pairs(noSayBlacklist.Core.Settings) do
		if v.setting == setting then
			return v.value
		end
	end
end