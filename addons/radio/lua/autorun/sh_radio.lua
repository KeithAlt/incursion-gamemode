FactionRadio = FactionRadio or {}
FactionRadio.Defaults = {
	["Color"] = Color(255, 182, 66, 255), --The color that the message will appear in
	["Sounds"] = { --One of these sounds will be randomly chosen and played when a message is sent
		"npc/metropolice/vo/off1.wav",
		"npc/metropolice/vo/off2.wav",
		"npc/metropolice/vo/off3.wav"
	},
	["Volume"] = {60, 70}, --The volume of the sound will be a random number between these two numbers
	["Pitch"] = {80, 120}, --The pitch of the sound will be a random number between these two numbers
	["Censor"] = false --Whether or not to censor the message for non-faction members
}
FactionRadio.Aliases = {"fac", "faction", "f"}
FactionRadio.OfficerAliases = {"officer", "o"}

function FactionRadio.GetSettings(ply)
	if !IsValid(ply) then return end

	local char = ply:getChar()
	if !char then return end

	local faction = char:getFaction()
	if !faction then return end

	local factionTbl = nut.faction.indices[faction]
	if !factionTbl then return end

	if factionTbl.Radio == false then
		return false
	end

	return factionTbl.Radio or FactionRadio.Defaults, factionTbl.name
end

function FactionRadio.SendMsg(sender, msg, filter, officer)
	net.Start("FactionRadioMsg")
		net.WriteString(msg)
		net.WriteEntity(sender)
		net.WriteBool(officer)
	net.Send(filter)
end

function FactionRadio.AddChatRange(sender, filter)
	local range = nut.config.get("chatRange", 280)
	local rangeSqr = range ^ 2

	for i, listener in ipairs(player.GetAll()) do
		if listener:GetPos():DistToSqr(sender:GetPos()) < rangeSqr then
			filter:AddPlayer(listener)
		end
	end
end

function FactionRadio.SendToTeam(sender, msg)
	local filter = RecipientFilter()
	filter:AddRecipientsByTeam(sender:Team())
	FactionRadio.AddChatRange(sender, filter)

	FactionRadio.SendMsg(sender, msg, filter, false)
end

function FactionRadio.SendToOfficers(sender, msg)
	local filter = RecipientFilter()
	filter:AddRecipientsByTeam(sender:Team())

	for i, listener in ipairs(filter:GetPlayers()) do
		if !hcWhitelist.isHC(listener) then
			filter:RemovePlayer(listener)
		end
	end

	FactionRadio.AddChatRange(sender, filter)

	FactionRadio.SendMsg(sender, msg, filter, true)
end

function FactionRadio.OnRun(ply, args, officer)
	local settings = FactionRadio.GetSettings(ply)

	if settings == false then
		ply:ChatPrint("This faction does not support faction radios.")
		return
	elseif !ply:GetNW2Bool("GlobalRadioAccess") then
		jlib.Announce(ply,
			Color(255,0,0), "[RADIO] ",
			Color(255,255,255), "You need to own and have a radio item turned on to use radio comms"
		)
		return
	end

	if !settings then return end

	local msg = table.concat(args, " ")

	ply:EmitSound(settings.Sounds[math.random(1, #settings.Sounds)], math.random(settings.Volume[1], settings.Volume[2]), math.random(settings.Pitch[1], settings.Pitch[2]))

	if officer then
		FactionRadio.SendToOfficers(ply, msg)
	else
		FactionRadio.SendToTeam(ply, msg)
	end
end

hook.Add("InitPostEntity", "FactionRadioInit", function()
	for i, alias in ipairs(FactionRadio.Aliases) do
		nut.command.add(alias, {onRun = FactionRadio.OnRun, syntax = "<message>"})
	end

	for i, alias in ipairs(FactionRadio.OfficerAliases) do
		nut.command.add(alias, {onRun = function(ply, args)
			if !hcWhitelist.isHC(ply) then
				ply:ChatPrint("You are not an officer of your faction.")
				return
			end

			FactionRadio.OnRun(ply, args, true)
		end,
		syntax = "<message>"})
	end
end)
