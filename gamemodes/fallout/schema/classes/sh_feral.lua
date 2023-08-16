CLASS.name = "Feral Ghoul Default"-- FIXME: This should be updated into classvar
CLASS.faction = FACTION_FERAL
CLASS.isDefault = true
CLASS.noHunger = true -- Immune to hunger/thirst
CLASS.None = true
CLASS.Color = Color(255, 0, 0)

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
	    pk_pills.apply(ply, "feral", "lock-life")
	    ply:ChatPrint("☢ You are a Feral Ghoul | You must kill, no exceptions ☢")
	    ply:ChatPrint("· Unholster to attack (Hold R)")
	    ply:ChatPrint("· Right-Click to charge")
	    ply:ChatPrint("· Left-Click to strike")
	    ply:ChatPrint("· R/F to taunt")
	    ply:ChatPrint("· Failing to attack others will result in class ban")
	    ply:ChatPrint("· Voice Chat is disabled for this class")
		end)
	end
end

CLASS_FERAL = CLASS.index
