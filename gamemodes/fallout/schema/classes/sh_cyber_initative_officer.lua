CLASS.name = "Cyber Initative - Officer"
CLASS.faction = FACTION_CYBER_INITATIVE
CLASS.IsRobot = true
CLASS.modelOverride = "models/nutscript/player/keitho/robotrace.mdl"
CLASS.noArmor = false
CLASS.health = 900
CLASS.isDefault = false
CLASS.Officer = true

CLASS_CYBER_INITATIVE_OFFICER = CLASS.index

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
