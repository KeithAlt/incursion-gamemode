CLASS.name = "NCR - Ranger"
CLASS.faction = FACTION_NCR
CLASS.isDefault = false
CLASS.NCO = true
CLASS.Color = Color(255, 203, 73)

CLASS.specialBuffs = {	-- Special buffs on spawn
    ["E"] = 2,
    ["P"] = 2
}

CLASS_NCRRANGER = CLASS.index

function CLASS:onSpawn(client)
	if SERVER then
		client:Give("weapon_core_cowboyrep")
	end
end