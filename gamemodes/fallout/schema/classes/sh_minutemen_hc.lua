CLASS.name = "Minutemen - Officer"
CLASS.faction = FACTION_MM
CLASS.isDefault = false
CLASS.Officer = true
CLASS.Color = Color(255, 203, 73)

CLASS_MINUTEMEN_OFFICER = CLASS.index

function CLASS:onSpawn(client)
	if SERVER then
		client:Give("weapon_lasermusketscopd")
	end
end