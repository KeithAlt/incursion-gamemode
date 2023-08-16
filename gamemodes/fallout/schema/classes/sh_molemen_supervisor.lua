CLASS.name = "Moleman - Supervisor" -- FIXME: Either finish or remove
CLASS.faction = FACTION_MOLEMEN
CLASS.isDefault = false
CLASS.Officer = true
CLASS.Color = Color(255, 74, 74)

CLASS_MOLEMAN_SUPERVISOR = CLASS.index

function CLASS:onSpawn(client)
	if SERVER then
		client:Give("weapon_chinese_ar_mole")
		client:Give("weapon_moleminer_len")
		client:Give("weapon_hook_len_m2")
	end
end
