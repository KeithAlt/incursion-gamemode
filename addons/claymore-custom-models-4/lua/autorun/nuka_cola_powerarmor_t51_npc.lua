local NPC = {
	Name = "Nuka Cola T-51 Power Armor FRIENDLY",
	Class = "npc_citizen",
	Model = "models/kuma96/powerarmor_t51/resized/nkpowerarmor_t51_npc1.mdl",
	KeyValues = {citizentype = 4},
	Category = "Fallout 4"
}
list.Set("NPC", "nuka_cola_powerarmor_t51_mini_good", NPC)

NPC = {
	Name = "Nuka Cola T-51 Power Armor HOSTILE",
	Class = "npc_combine_s",
	Model = "models/kuma96/powerarmor_t51/resized/nkpowerarmor_t51_npc2.mdl",
	Weapons = { "weapon_smg1", "weapon_ar2" },
	Numgrenades = "4",
	Category = "Fallout 4"
}
list.Set("NPC", "nuka_cola_powerarmor_t51_mini_bad", NPC)