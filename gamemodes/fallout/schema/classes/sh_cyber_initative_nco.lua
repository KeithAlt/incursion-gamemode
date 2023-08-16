CLASS.name = "Cyber Initative - NCO"
CLASS.faction = FACTION_CYBER_INITATIVE
CLASS.modelOverride = "models/nutscript/player/keitho/robotrace.mdl"
CLASS.isDefault = false
CLASS.IsRobot = true
CLASS.noArmor = false
CLASS.health = 900
CLASS.NCO = true

CLASS_CYBER_INITATIVE_NCO = CLASS.index

if SERVER then
	function CLASS:onSpawn(ply) -- Custom spawn loadout of 'Cybers' class
		timer.Simple(0.5, function() -- Added because SetJumpPower() does not work less called on next tick
			if !IsValid(ply) then return end
			ply:SetHealth(900)
			ply:SetMaxHealth(900)
			ply:Give("weapon_gecko")
		end)
	end
end
