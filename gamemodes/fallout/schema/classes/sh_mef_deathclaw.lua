CLASS.name = "MEF - Cyborg"
CLASS.faction = FACTION_VIGILANTS
CLASS.isDefault = false
CLASS.IsRobot = true
CLASS.modelOverride = "models/cgcclothing/robots/calculator.mdl"

CLASS_MEFDEATHCLAW = CLASS.index

if SERVER then
	function CLASS:onSpawn(ply) -- Custom spawn loadout of 'Cyborg' class
		timer.Simple(0.5, function() -- Added because SetJumpPower() does not work less called on next tick
			if !IsValid(ply) then return end
			ply:SetHealth(500)
			ply:SetMaxHealth(500)
			ply:Give("weapon_gecko")
		end)
	end
end
