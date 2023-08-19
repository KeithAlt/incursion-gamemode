CLASS.name = "Securitron - Soldier"
CLASS.faction = FACTION_HOUSE
CLASS.IsRobot = true
CLASS.isDefault = false
CLASS.health = 1500 -- Unique class HP
CLASS.noArmor = false -- Allow for equip of a unique legacy armor

function CLASS:onSpawn(client) -- Unique class loadout
	client:Give("weapon_laser_rcw")
	client:Give("weapon_smmg_len")
end

CLASS_SECURITRON = CLASS.index
