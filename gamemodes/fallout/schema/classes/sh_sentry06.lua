CLASS.name = "UE - Alpha Droid"
CLASS.faction = FACTION_BOOMERS
CLASS.isDefault = false
CLASS.IsRobot = true
CLASS.health = 850
CLASS.noArmor = false -- Allow for equipment of their unique legacy armor item

CLASS_SENTRYONYX = CLASS.index

function CLASS:onSpawn(client) -- Unique class loadout
	client:Give("weapon_laser_rcw")
	client:Give("weapon_smmg_len")

	-- Faction validation fix due to previous mistake
	if client:getChar():getFaction() != nut.faction.indices[FACTION_BOOMERS].index then
		jlib.TransferFaction(client, FACTION_BOOMERS)
	end
end
