local last
concommand.Add("casinokit_econ_resetchips", function(p, cmd, args)
	if IsValid(p) then return p:ChatPrint("run from RCON") end

	if last and last.time < CurTime()-10 then
		MsgN("Previous reset command expired.")
		last = nil
	end
	if not last then
		last = {time = CurTime(), seq = math.random(1000, 9999)}
		MsgN("Type 'casinokit_econ_resetchips " .. last.seq .. "' to confirm resetting EVERY player's chips.")
		return
	end

	if args[1] ~= tostring(last.seq) then
		MsgN("Invalid confirmation number.")
		return
	end

	MsgN("Deleting everyone's chips..")

	for _,p in pairs(player.GetAll()) do
		p:CKit_SetChips(0)
	end

	CasinoKit.resetAllChipsUnSafe()

	MsgN("Everyone's chips reset.")
end)