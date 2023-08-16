CLASS.name = "Cyber Initiative - Human Soldier"
CLASS.faction = FACTION_CYBER_INITATIVE
CLASS.isDefault = false
CLASS.Color = Color(255, 203, 73)

function CLASS:onSpawn(ply) -- This is added because there is a strange bug that gives this class as much HP as it's main faction classes
	timer.Simple(0.5, function()
		if SERVER then
			ply:SetMaxHealth(100)
			ply:SetHealth(100)
		end
	end)
end

CLASS_CYBER_INITATIVE_SOLDIER = CLASS.index
