CLASS.name = "Unity - Child of the Cathedral NCO"
CLASS.faction = FACTION_UNITY
CLASS.isDefault = false
CLASS.Color = Color(255, 203, 73)
CLASS.NCO = true

CLASS_UNITY_COTC_NCO = CLASS.index

function CLASS:onSpawn(ply) -- This is added because there is a strange bug that gives this class as much HP as it's main faction classes
	timer.Simple(0, function()
		if SERVER then
			ply:SetMaxHealth(100)
			ply:SetHealth(100)
		end
	end)
end
