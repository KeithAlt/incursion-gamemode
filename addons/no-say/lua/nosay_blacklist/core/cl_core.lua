-- Add messages to user's chats that are sent by the server
noSayBlacklist.Core.Msg = function(msg)
	chat.AddText(Color(50, 125, 255), noSayBlacklist.Translate.Prefix..": ", Color( 255, 255, 255 ), msg)
end
net.Receive("nosay_msg", function()
	noSayBlacklist.Core.Msg(net.ReadString())
end)

-- Open the UI
net.Receive("nosay_admin_ui", function()
	noSayBlacklist.UI.Panel(net.ReadTable())
end)

-- Received when settings are changed
net.Receive("nosay_admin_network_setting", function()
	local data = net.ReadTable()

	noSayBlacklist.Core.UpdateSetting(data.setting, data.value)
end)

-- Received when a new bad word is added
net.Receive("nosay_admin_network_word", function()
	local word = net.ReadString()
	local replace = net.ReadString()

	if replace == "" then
		noSayBlacklist.Core.Words[word] = true
	else
		noSayBlacklist.Core.Words[word] = replace
	end
end)

-- Received when a bad word is removed
net.Receive("nosay_admin_network_word_remove", function()
	local word = net.ReadString()
	noSayBlacklist.Core.Words[word] = nil
end)

-- Receives the inital settings & words from the server.
net.Receive("nosay_admin_inital_settings", function()
	local data = net.ReadTable()
	for k,v in pairs(data) do
		noSayBlacklist.Core.UpdateSetting(v.setting, v.value)
	end
end)
net.Receive("nosay_admin_inital_words", function()
	local data = net.ReadTable()
	for k,v in pairs(data) do
		if(v == "") then
			noSayBlacklist.Core.Words[k] = true
		else
			noSayBlacklist.Core.Words[k] = v
		end
	end
end)