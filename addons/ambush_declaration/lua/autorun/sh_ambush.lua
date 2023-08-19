Ambush = Ambush or {}

hook.Add("InitPostEntity", "LoadAmbushStateCommands", function()
	-- Enter your faction into an ambush state
	nut.command.add("ambush", {
		syntax = "",
		onRun = function(ply)
			if IsValid(ply) and ply:IsPlayer() and ply:getChar() and ply:getChar():getFaction() then

				if Ambush.GetActive(ply:getChar():getFaction()) then
					jlib.RequestBool("Do you want to end your ambush?", function(bool)
						if !bool then return end

							Ambush.End(ply:getChar():getFaction())

					end, ply, "Yes", "No")
					return
				else
					Ambush.Start(ply:getChar():getFaction(), ply)
				end
			end
		end
	})

	-- Initalize our related configuration settings
	nut.config.add("ambushCooldown", 300, "How long until another ambush can be declared? (In seconds)", nil, {
		data = {min = 10, max = 3600},
		category = "warConfig"
	})

	nut.config.add("ambushDuration", 100, "How long does an ambush last when declared? (In seconds)", nil, {
		data = {min = 10, max = 3600},
		category = "warConfig"
	})
end)
