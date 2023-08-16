CLASS.name = "Think Tank - Robot Officer"
CLASS.faction = FACTION_THINKTANK
CLASS.isDefault = false
CLASS.IsRobot = true
CLASS.Officer = true
CLASS.health = 850 -- Unique class HP
CLASS.noArmor = false -- Allow for equip of a unique legacy armor
CLASS.verify = true -- Verify faction of ply (due to an earlier registry mistake)

function CLASS:onSpawn(ply) -- Unique class loadout
	ply:Give("weapon_thinktankrelay")
end

CLASS_ROBOTTHINKTANK = CLASS.index
