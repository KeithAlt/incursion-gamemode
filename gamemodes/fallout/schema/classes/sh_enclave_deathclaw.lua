CLASS.name = "Enclave - Deathclaw"
CLASS.faction = FACTION_ENCLAVE
CLASS.noHunger = true -- Immune to hunger/thirst
CLASS.isDefault = false
CLASS.bloodcolor = BLOOD_COLOR_GREEN
CLASS.Color = Color(255, 74, 74)

CLASS.specialBuffs = {	-- Special buffs on spawn
	["E"] = 25,
}

if SERVER then
	function CLASS:onSpawn(ply) -- This should be made into a global function with CLASS.Variable
		local char = ply:getChar()
		local charNick = ply:Nick()
		ply:ChatPrint("[ NOTICE ]  You will fully spawn in 9 Seconds . . .")

	  timer.Simple(9, function() -- Added to mitigate a spawn immunity conflict
			if (ply:getChar() != char) or (ply:Nick() != charNick) or !ply:Alive() then return end -- Checks if ply has changed characters between lapse time
			ply:SetPos(ply:GetPos() + Vector(0,0,5)) -- Anti stuck
			-- Everything below here should be rewritten in future ---
			pk_pills.apply(ply, "deathclaw_enclave", "lock-life")
	    ply:ChatPrint("☢ You are a Enclave Deathclaw | You are optional KOS ☢")
	    ply:ChatPrint("· Unholster to attack (Hold R)")
	    ply:ChatPrint("· Right-Click to charge attack")
	    ply:ChatPrint("· Left-Click to strike")
	    ply:ChatPrint("· CTRL to burrow")
	    ply:ChatPrint("· R/F to taunt")
	    ply:ChatPrint("· No, you're not Hyper-Intellgient. You're just trained.")
	    ply:ChatPrint("· Voice Chat is disabled for this class")
			ply:SetNoTarget(true)
			ply:SetMaxHealth(1200)
			ply:SetHealth(1200)
	  end)
	end
end

CLASS_ENCLAVE_DEATHCLAW = CLASS.index
