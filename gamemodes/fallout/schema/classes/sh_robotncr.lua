CLASS.name = "Robot - NCR"
CLASS.faction = FACTION_NCR
CLASS.isDefault = false
CLASS.IsRobot = true
CLASS.verify = true -- Verify faction of ply (due to an earlier registry mistake)

function CLASS:onSpawn(ply) -- Generic class pending transfer
	jlib.Announce(ply,
		Color(255,0,0), "[NOTICE] ",
		Color(255,100,100), "You are the generic robot class!",
		Color(255,255,255), "\nRequest a staff member to set your class as either:" ..
		"\n· Gutsy" ..
		"\n· Protectron" ..
		"\n· Eyebot"
	)
end

CLASS_ROBOTNCR = CLASS.index
