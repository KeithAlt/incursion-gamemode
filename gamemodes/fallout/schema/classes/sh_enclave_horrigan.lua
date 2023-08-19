CLASS.name = "Enclave - Horrigan"
CLASS.faction = FACTION_ENCLAVE
CLASS.isDefault = false
CLASS.noHunger = true -- Immune to hunger/thirst
CLASS.IsMutant = true
CLASS.pill = "fo3_frankhorrigan"

CLASS.specialBuffs = {	-- Special buffs on spawn
	["E"] = 25,
}

function CLASS:onSpawn(ply)
	ply:AddEFlags(EFL_NO_DAMAGE_FORCES)
end

CLASS_ENCLAVE_HORRIGAN = CLASS.index
