CLASS.name = "Securitron - Officer"
CLASS.faction = FACTION_HOUSE
CLASS.isDefault = false
CLASS.IsRobot = true
CLASS.Officer = true
CLASS.health = 1500 -- Unique class HP
CLASS.noArmor = false -- Allow for equip of a unique legacy armor

function CLASS:onSpawn(client) -- Unique class loadout
	client:Give("weapon_laser_rcw")
	client:Give("weapon_smmg_len")
end

CLASS_SECURITRON_HC = CLASS.index
