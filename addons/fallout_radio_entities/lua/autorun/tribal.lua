local NPC = {
	Name = "Tribal Power Armor [F]",
	Class = "npc_citizen",
	Model = "models/models/adi/tribalpowerarmor/tribalpa_helm_npc.mdl",
	KeyValues = {citizentype = 4},
	Category = "Fallout 3"
}
list.Set("NPC", "tribalpa_frien", NPC)

NPC = {
	Name = "Tribal Power Armor [H]",
	Class = "npc_combine_s",
	Model = "models/models/adi/tribalpowerarmor/tribalpa_helm_npc.mdl",
	Weapons = { "weapon_smg1", "weapon_ar2" },
	Numgrenades = "4",
	Category = "Fallout 3"
}
list.Set("NPC", "tribalpa_host", NPC)