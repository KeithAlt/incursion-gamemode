local npcXPVals = {
	-- RADSCORPION --
    ["npc_vj_fo3_rs_albino_radscorpion"] = 5,
    ["npc_vj_fo3_rs_bark_scorpion"] = 1,
    ["npc_vj_fo3_rs_giant_radscorpion"] = 8,
    ["npc_vj_fo3_rs_glow_radscorpion"] = 10,
	["npc_vj_fo3_rs_radscorpion"] = 8,
	-- DEATHCLAW --
	["npc_vj_fo3_dc_deathclaw_baby"] = 5,
	["npc_vj_fo3_dc_deathclaw"] = 12,
	["npc_vj_fo3_dc_deathclaw_mother"] = 15,
	["npc_vj_fo3_dc_deathclaw_enclave"] = 12,
	-- MIRELURK --
	["npc_vj_fo3_mirelurk_hunter"] = 8,
	["npc_vj_fo3_swamplurk"] = 8,
	["npc_vj_fo3_mirelurk_king"] = 8,
	-- FERAL GHOULS --
	["npc_vj_fo3_fg_feralghoul_armored"] = 8,
	["npc_vj_fo3_fg_feralghoul_glowing"] = 5,
	["npc_vj_fo3_fg_feralghoul_trooper_glowing"] = 10,
	["npc_vj_fo3_fg_feralghoul_roamer"] = 5,
	["npc_vj_fo3_fg_feralghoul_trooper_roaming"] = 5,
	["npc_vj_fo3_fg_feralghoul_trooper"] = 5,
	["npc_vj_fo3_fg_feralghoul_robco"] = 5,
	["npc_vj_fo3_fg_feralghoul_roamer_robco"] = 5,
	["npc_vj_fo3_fg_feralghoul_glowing_robco"] = 10,
	["npc_vj_fo3_fg_feralghoul_swamp_robco"] = 5,
	["npc_vj_fo3_fg_feralghoul_swamp"] = 1,
	["npc_vj_fo3_fg_feralghoul_trooper_swamp"] = 1,
	-- CREATURE --
	["npc_vj_fallout_bighorner"] = 3,
	["npc_vj_fallout_brahmin"] = 3,
	["npc_vj_fallout_brahminpack"] = 3,
	["npc_vj_fallout_brahminwater"] = 3,
	["npc_vj_fallout_coyote"] = 3,
	["npc_vj_fallout_mongrel"] = 3,
	["npc_vj_fallout_dog"] = 0,
	["npc_vj_fallout_giantrat"] = 3,
	["npc_vj_fo3_glowroach"] = 5,
	["npc_vj_fo3_radroach"] = 3,
	["npc_vj_fallout_nightstalker"] = 5,
	["npc_vj_fallout_viciousdog"] = 3,
	-- BOSSES --
	["npc_vj_fallout_supermutant_behemoth"] = 45,
	["npc_vj_fallout_yaoguai"] = 35,
	["npc_vj_fallout_giantantqueen"] = 35,
	["npc_vj_fo3_rs_nuka_radscorpion"] = 35,
	["npc_vj_fo3_nukaroach"] = 35,
	["npc_vj_fo3_dc_deathclaw_alpha"] = 45,
	["npc_vj_fo3_magmalurk"] = 45,
	["npc_vj_fo3_mirelurk_queen"] = 35,
	["npc_vj_fo3_nukalurk"] = 35,
}

hook.Add("OnNPCKilled", "NpcXP", function(npc, attacker, inflictor)
    if attacker:IsPlayer() then
        local amt = 5
        local class = npc:GetClass()

        if npcXPVals[class] then amt = npcXPVals[class] end
        nut.leveling.giveXP(attacker, amt)
    end
end)

hook.Add("PlayerDeath", "XPReward", function(victim, inflictor, attacker)
	if IsValid(attacker) and attacker:IsPlayer() and attacker != victim then
		nut.leveling.giveXP(attacker, 2)
	end
end)
