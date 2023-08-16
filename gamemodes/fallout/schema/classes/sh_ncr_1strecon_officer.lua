CLASS.name = "NCR - 1st Recon Officer"
CLASS.faction = FACTION_NCR
CLASS.isDefault = false
CLASS.Officer = true
CLASS.Color = Color(255, 203, 73)

CLASS.specialBuffs = {	-- Special buffs on spawn
    ["E"] = 2,
    ["P"] = 2
}

CLASS_NCR1STRECON_OFFICER = CLASS.index

function CLASS:onSpawn(client)
	if SERVER then
		client:Give("weapon_huntingrifle_len")
		client:Give("weapon_core_markrifle")
		client:Give("weapon_bowieknife_len_m2")
	end
end
--Customer Order by Mikvik#1443--
