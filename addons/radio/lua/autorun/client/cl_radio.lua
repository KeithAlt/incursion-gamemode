net.Receive("FactionRadioMsg", function()
	local msg = net.ReadString()
	local sender = net.ReadEntity()
	local officer = net.ReadBool()
	local settings, factionName = FactionRadio.GetSettings(sender)
	local color = settings.Color
	local senderNick = sender:Nick()

	if !settings then return end

	if sender:Team() != LocalPlayer():Team() then -- Changed done by Keith to hide meta sensitive info
		color = Color(255, 255, 0)
		factionName = "COMMS"
		officer = false
		senderNick = ""

		if settings.Censor then
			msg = jlib.RandomString(32)
		end
	end

	chat.AddText(color, '[' .. (factionName or "Faction") .. (officer and " - Officers" or "") .. '] ' .. senderNick .. ' says: "' .. msg .. '"')
end)
