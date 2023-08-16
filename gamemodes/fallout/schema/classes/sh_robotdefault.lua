CLASS.name = "Robot - Default"
CLASS.faction = FACTION_ROBOT
CLASS.noHunger = true
CLASS.isDefault = true
CLASS.IsRobot = true

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

CLASS_ROBOT = CLASS.index
