CLASS.name = "Unity - Child of the Cathedral"
CLASS.faction = FACTION_UNITY
CLASS.isDefault = false
CLASS.Color = Color(255, 203, 73)

CLASS_UNITY_COTC = CLASS.index

function CLASS:onSpawn(ply) -- This is added because there is a strange bug that gives this class as much HP as it's main faction classes
	timer.Simple(0, function()
		if SERVER then
			ply:SetMaxHealth(100)
			ply:SetHealth(100)
		end
	end)
end
